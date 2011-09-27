From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH 1/2] virtio-net: Verify page list size before fitting
 into skb
Date: Tue, 27 Sep 2011 09:44:02 +0300
Message-ID: <1317105842.3467.3.camel@lappy>
References: <1317058869-19276-1-git-send-email-levinsasha928@gmail.com>
	 <20110926184445.GA22278@redhat.com> <1317065842.20885.3.camel@lappy>
	 <20110926195541.GA23086@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110926195541.GA23086@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-09-26 at 22:55 +0300, Michael S. Tsirkin wrote:
> On Mon, Sep 26, 2011 at 10:37:22PM +0300, Sasha Levin wrote:
> > On Mon, 2011-09-26 at 21:44 +0300, Michael S. Tsirkin wrote:
> > > On Mon, Sep 26, 2011 at 08:41:08PM +0300, Sasha Levin wrote:
> > > > This patch verifies that the length of a buffer stored in a linked list
> > > > of pages is small enough to fit into a skb.
> > > > 
> > > > If the size is larger than a max size of a skb, it means that we shouldn't
> > > > go ahead building skbs anyway since we won't be able to send the buffer as
> > > > the user requested.
> > > > 
> > > > Cc: Rusty Russell <rusty@rustcorp.com.au>
> > > > Cc: "Michael S. Tsirkin" <mst@redhat.com>
> > > > Cc: virtualization@lists.linux-foundation.org
> > > > Cc: netdev@vger.kernel.org
> > > > Cc: kvm@vger.kernel.org
> > > > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > > 
> > > Interesting.  This is a theoretical issue, correct?
> > > Not a crash you actually see.
> > 
> > Actually it was an actual crash caused when our virtio-net driver in kvm
> > tools did funny things and passed '(u32)-1' length as a buffer length to
> > the guest kernel.
> > 
> > > This crash would mean device is giving us packets
> > > that are way too large. Avoiding crashes even in the face of
> > > a misbehaved device is a good idea, but should
> > > we print a diagnostic to a system log?
> > > Maybe rate-limited or print once to avoid filling
> > > up the disk. Other places in driver print with pr_debug
> > > I'm not sure that's right but better than nothing.
> > 
> > Yup, I'll add some debug info.
> > 
> > > > ---
> > > >  drivers/net/virtio_net.c |    3 +++
> > > >  1 files changed, 3 insertions(+), 0 deletions(-)
> > > > 
> > > > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > > > index 0c7321c..64e0717 100644
> > > > --- a/drivers/net/virtio_net.c
> > > > +++ b/drivers/net/virtio_net.c
> > > > @@ -165,6 +165,9 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
> > > >  	unsigned int copy, hdr_len, offset;
> > > >  	char *p;
> > > >  
> > > > +	if (len > MAX_SKB_FRAGS * PAGE_SIZE)
> > > 
> > > unlikely()?
> > > 
> > > Also, this seems too aggressive: at this point len includes the header
> > > and the linear part. The right place for this
> > > test is probably where we fill in the frags, just before
> > > while (len)
> > > 
> > > The whole can only happen when mergeable buffers
> > > are disabled, right?
> > 
> > >From what I understand it can happen whenever you're going to build a
> > skb longer than PAGE_SIZE.
> 
> Hmm how exactly?  With mergeable buffers this only gets
> the length of the 1st chunk which is up to 4K unless the driver
> is buggy ...

What about the case where TSO or ECN features are set? The code flow
suggests that mergeable would get ignored in that case:

	/* If we can receive ANY GSO packets, we must allocate large ones. */
	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO4) ||
	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_TSO6) ||
	    virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_ECN))
		vi->big_packets = true;

	[...]

	if (!vi->mergeable_rx_bufs && !vi->big_packets) {
		skb = buf;
		len -= sizeof(struct virtio_net_hdr);
		skb_trim(skb, len);
	} else {
		page = buf;
		skb = page_to_skb(vi, page, len);
		...


I haven't actually tested it with mergeable buffers enabled, but could
do it later today.
-- 

Sasha.
