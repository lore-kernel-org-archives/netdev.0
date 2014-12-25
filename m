From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 00/10] Split UFO into v4 and v6 versions.
Date: Thu, 25 Dec 2014 09:14:35 +0200
Message-ID: <20141225071435.GA6687@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
	<586203981.237162.1418880532523.JavaMail.zimbra@redhat.com>
	<1419444680.4705.129.camel@decadent.org.uk>
	<20141224185922.GA30934@redhat.com>
	<1419476521.27992.1@smtp.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevich@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>, stefanha@redhat.com,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1419476521.27992.1@smtp.corp.redhat.com>
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

On Thu, Dec 25, 2014 at 03:10:01AM +0008, Jason Wang wrote:
> 
> 
> On Thu, Dec 25, 2014 at 2:59 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >On Wed, Dec 24, 2014 at 07:11:20PM +0100, Ben Hutchings wrote:
> >> On Thu, 2014-12-18 at 00:28 -0500, Jason Wang wrote:
> >> >  > ----- Original Message -----
> >> > > UFO support in the kernel applies to both IPv4 and IPv6 protocols
> >> > > with the same device feature.  However some devices may not be able
> >> > > to support one of the offloads.  For this we split the UFO offload
> >> > > feature into 2 pieces.  NETIF_F_UFO now controlls the IPv4 part and
> >> > > this series introduces NETIF_F_UFO6.
> >> > >  > > As a result of this work, we can now re-enable NETIF_F_UFO on
> >> > > virtio_net devices and restore UDP over IPv4 performance for
> >>guests.
> >> > > We also continue to support legacy guests that assume that UFO6
> >> > > support included into UFO(4).
> >> > >  > > Without this work, migrating a guest to a 3.18 kernel fails.
> >> > >  >  > This series eliminate the ambiguous NETIF_F_UFO.
> >> >  > But VIRTIO_NET_F_{HOST|GUEST}_UFO and VIRTIO_NET_F_HDR_GSO_UDP is
> >>still
> >> > ambigious. I know it was used to keep compatibility for legacy guest.
> >>But
> >> > what's the future plan? Differentiate UFOv4 and UFOv6 in virtio
> >>features and
> >> > gso type in vnet header looks sufficient?
> >> [...]
> >>   The IPv6 fragmentation ID needs to be added to the vnet header, to do
> >> UFOv6 properly.  If it wasn't for that lack, we wouldn't have to split
> >> the feature flag.
> >> Ben.
> >
> >
> >Right.
> >
> >I think a good plan is as follows:
> >
> >1. add code generating IDs on rx path for virtio,
> >   and re-enable UFO (4+6).
> >
> >2. Ben's patch doing similar things for tun/macvtap
> 
> I wonder whether or not we can do this lazily.
> 
> E.g during UFO6 software segment for dodgy packets?
> 
> And this can eliminate the effort of duplicating it in all untrusted
> sources?

But then we'll need to then change it again in step 5,
probably by setting some flag?
Might as well do it directly.

> >
> >3. similarly for packet sockets
> >
> >
> >above seem appropriate for stable
> >
> >4. 4+6 split, to make it easier for drivers
> >   to identify when fragment ID is needed
> >
> >5. extend vnet header, and add ways to enable it,
> >   when enabled, use that to pass
> >   fragment ID for tun/virtio/vhost/macvtap/packet socket
> >
> >4 is what this patchset does.
> >
> >
> >> --  Ben Hutchings
> >> If more than one person is responsible for a bug, no one is at fault.
> >
> >
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
