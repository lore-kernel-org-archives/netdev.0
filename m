From: Greg Kurz <gkurz@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] Fix AF_PACKET ABI breakage in 4.2
Date: Fri, 25 Sep 2015 14:33:12 +0200
Message-ID: <20150925143312.1e1cadd8@bahia.local>
References: <1443019470.74600.6.camel@infradead.org>
	<20150923.110926.1369752430685358746.davem@davemloft.net>
	<1443033908.74600.21.camel@infradead.org>
	<20150924092545.28d3ae52@bahia.local>
	<20150924124443-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	linux-api@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150924124443-mutt-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Sep 2015 12:50:59 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Thu, Sep 24, 2015 at 09:25:45AM +0200, Greg Kurz wrote:
> > On Wed, 23 Sep 2015 19:45:08 +0100
> > David Woodhouse <dwmw2@infradead.org> wrote:
> > 
> > > Commit 7d82410950aa ("virtio: add explicit big-endian support to memory
> > > accessors") accidentally changed the virtio_net header used by
> > > AF_PACKET with PACKET_VNET_HDR from host-endian to big-endian.
> > > 
> > 
> > Hi David,
> > 
> > Oops my bad... I obviously overlooked this one when adding cross-endian
> > support.
> > 
> > > Since virtio_legacy_is_little_endian() is a very long identifier,
> > > define a VIO_LE macro and use that throughout the code instead of the
> > 
> > VIO usually refers to virtual IO adapters for the PowerPC pSeries platform.
> > 
> > > hard-coded 'false' for little-endian.
> > > 
> > 
> > What about introducing dedicated accessors as it is done in many other
> > locations where we do virtio byteswap ? Something like:
> > 
> > static inline bool packet_is_little_endian(void)
> > {
> > 	return virtio_legacy_is_little_endian();
> > }
> > 
> > static inline u16 packet16_to_cpu(__virtio16 val)
> > {
> > 	return __virtio16_to_cpu(packet_is_little_endian(), val);
> > }
> > 
> > static inline __virtio16 cpu_to_packet16(u16 val)
> > {
> > 	return __cpu_to_virtio16(packet_is_little_endian(), val);
> > }
> > 
> > It results in prettier code IMHO. Have a look at drivers/net/tun.c or
> > drivers/vhost/vhost.c.
> > 
> > > This restores the ABI to match 4.1 and earlier kernels, and makes my
> > > test program work again.
> > > 
> > 
> > BTW, there is still work to do if we want to support cross-endian legacy or
> > virtio 1 on a big endian arch...
> > 
> > Cheers.
> > 
> > --
> > Greg
> 
> It seems the API that we have is a confusing one.
> 
> virtio endian-ness is either native or little, depending on a flag, so
> __virtio16_to_cpu seems to mean "either native to cpu or little to cpu
> depending on flag".
> 
> It used to be like that, but not anymore.
> 
> This leads to all kind of bugs.
> 
> For example, I have only now realized vhost_is_little_endian isn't a
> constant on LE hosts if cross-endian support is not compiled.
> 
> I think we need to fix it, but also think about a better API.
> 

Your original API is good and works well for all the callers that
don't care for cross-endian support.

I guess we'd rather move the cross-endian burden to the few callers who
need it, i.e. tun, macvtap and vhost when cross-endian is compiled.

More or less like this:

/* Original API : either little-endian or native */
static inline u16 __virtio16_to_cpu(bool little_endian, __virtio16 val)
{
        if (little_endian)
                return le16_to_cpu((__force __le16)val);
        else
                return (__force u16)val;
}

#ifdef CONFIG_VHOST_CROSS_ENDIAN_LEGACY

static inline u16 vhost16_to_cpu(struct vhost_virtqueue *vq, __virtio16 val)
{
	/* little-endian because of virtio 1 */
	if (vhost_has_feature(vq, VIRTIO_F_VERSION_1))
		return __virtio16_to_cpu(true, val);

#ifdef __LITTLE_ENDIAN
	/* native little-endian */
	return (__force u16)val;
#else
	/* native big-endian */
	return be16_to_cpu((__force __be16)val);
#endif
}

#else

static inline u16 vhost16_to_cpu(struct vhost_virtqueue *vq, __virtio16 val)
{
#ifdef __LITTLE_ENDIAN
	/* fast path for little-endian host */
	return __virtio16_to_cpu(true, val);
#else
	/* slow path for big-endian host */
	return __virtio16_to_cpu(vhost_has_feature(vq, VIRTIO_F_VERSION_1), val);
#endif
}

#endif

Does it make sense ?

> 
> > > Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> > > ---
> > > On Wed, 2015-09-23 at 11:09 -0700, David Miller wrote:
> > > > > +#define VIO_LE virtio_legacy_is_little_endian()
> > > > 
> > > > When you define a shorthand macro, the defines to a function call,
> > > > make the macro have parenthesis too.
> > > 
> > > In which case I suppose it also wants to be lower-case. Although
> > > "function call" is a bit strong since it's effectively just a constant.
> > > I'm still wondering if it'd be nicer just to use (__force u16) instead.
> > > 
> > > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > > index 7b8e39a..aa4b15c 100644
> > > --- a/net/packet/af_packet.c
> > > +++ b/net/packet/af_packet.c
> > > @@ -230,6 +230,8 @@ struct packet_skb_cb {
> > >  	} sa;
> > >  };
> > >  
> > > +#define vio_le() virtio_legacy_is_little_endian()
> > > +
> > >  #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
> > >  
> > >  #define GET_PBDQC_FROM_RB(x)	((struct tpacket_kbdq_core *)(&(x)->prb_bdqc))
> > > @@ -2680,15 +2682,15 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
> > >  			goto out_unlock;
> > >  
> > >  		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
> > > -		    (__virtio16_to_cpu(false, vnet_hdr.csum_start) +
> > > -		     __virtio16_to_cpu(false, vnet_hdr.csum_offset) + 2 >
> > > -		      __virtio16_to_cpu(false, vnet_hdr.hdr_len)))
> > > -			vnet_hdr.hdr_len = __cpu_to_virtio16(false,
> > > -				 __virtio16_to_cpu(false, vnet_hdr.csum_start) +
> > > -				__virtio16_to_cpu(false, vnet_hdr.csum_offset) + 2);
> > > +		    (__virtio16_to_cpu(vio_le(), vnet_hdr.csum_start) +
> > > +		     __virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset) + 2 >
> > > +		      __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len))) actually
> > > +			vnet_hdr.hdr_len = __cpu_to_virtio16(vio_le(),
> > > +				 __virtio16_to_cpu(vio_le(), vnet_hdr.csum_start) +
> > > +				__virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset) + 2);
> > >  
> > >  		err = -EINVAL;
> > > -		if (__virtio16_to_cpu(false, vnet_hdr.hdr_len) > len)
> > > +		if (__virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len) > len)
> > >  			goto out_unlock;
> > >  
> > >  		if (vnet_hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
> > > @@ -2731,7 +2733,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
> > >  	hlen = LL_RESERVED_SPACE(dev);
> > >  	tlen = dev->needed_tailroom;
> > >  	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len,
> > > -			       __virtio16_to_cpu(false, vnet_hdr.hdr_len),
> > > +			       __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len),
> > >  			       msg->msg_flags & MSG_DONTWAIT, &err);
> > >  	if (skb == NULL)
> > >  		goto out_unlock;
> > > @@ -2778,8 +2780,8 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
> > >  
> > >  	if (po->has_vnet_hdr) {
> > >  		if (vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
> > > -			u16 s = __virtio16_to_cpu(false, vnet_hdr.csum_start);
> > > -			u16 o = __virtio16_to_cpu(false, vnet_hdr.csum_offset);
> > > +			u16 s = __virtio16_to_cpu(vio_le(), vnet_hdr.csum_start);
> > > +			u16 o = __virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset);
> > >  			if (!skb_partial_csum_set(skb, s, o)) {
> > >  				err = -EINVAL;
> > >  				goto out_free;
> > > @@ -2787,7 +2789,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
> > >  		}
> > >  
> > >  		skb_shinfo(skb)->gso_size =
> > > -			__virtio16_to_cpu(false, vnet_hdr.gso_size);
> > > +			__virtio16_to_cpu(vio_le(), vnet_hdr.gso_size);
> > >  		skb_shinfo(skb)->gso_type = gso_type;
> > >  
> > >  		/* Header must be checked, and gso_segs computed. */
> > > @@ -3161,9 +3163,9 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
> > >  
> > >  			/* This is a hint as to how much should be linear. */
> > >  			vnet_hdr.hdr_len =
> > > -				__cpu_to_virtio16(false, skb_headlen(skb));
> > > +				__cpu_to_virtio16(vio_le(), skb_headlen(skb));
> > >  			vnet_hdr.gso_size =
> > > -				__cpu_to_virtio16(false, sinfo->gso_size);
> > > +				__cpu_to_virtio16(vio_le(), sinfo->gso_size);
> > >  			if (sinfo->gso_type & SKB_GSO_TCPV4)
> > >  				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
> > >  			else if (sinfo->gso_type & SKB_GSO_TCPV6)
> > > @@ -3181,9 +3183,9 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
> > >  
> > >  		if (skb->ip_summed == CHECKSUM_PARTIAL) {
> > >  			vnet_hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
> > > -			vnet_hdr.csum_start = __cpu_to_virtio16(false,
> > > +			vnet_hdr.csum_start = __cpu_to_virtio16(vio_le(),
> > >  					  skb_checksum_start_offset(skb));
> > > -			vnet_hdr.csum_offset = __cpu_to_virtio16(false,
> > > +			vnet_hdr.csum_offset = __cpu_to_virtio16(vio_le(),
> > >  							 skb->csum_offset);
> > >  		} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
> > >  			vnet_hdr.flags = VIRTIO_NET_HDR_F_DATA_VALID;
> > > 
> 



-- 
Gregory Kurz                                     kurzgreg@fr.ibm.com
                                                 gkurz@linux.vnet.ibm.com
Software Engineer @ IBM/LTC                      http://www.ibm.com
Tel 33-5-6218-1607

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
