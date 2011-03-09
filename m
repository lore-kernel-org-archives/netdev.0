From: Tom Lendacky <tahm@linux.vnet.ibm.com>
Subject: Re: Network performance with small packets - continued
Date: Wed, 9 Mar 2011 16:51:39 -0600
Message-ID: <201103091651.41246.tahm@linux.vnet.ibm.com>
References: <201103071631.41964.tahm@linux.vnet.ibm.com> <20110309071558.GA25757@redhat.com> <201103091009.27932.tahm@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:59184 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814Ab1CIWvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 17:51:45 -0500
In-Reply-To: <201103091009.27932.tahm@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, March 09, 2011 10:09:26 am Tom Lendacky wrote:
> On Wednesday, March 09, 2011 01:15:58 am Michael S. Tsirkin wrote:
> > On Mon, Mar 07, 2011 at 04:31:41PM -0600, Tom Lendacky wrote:
> > > We've been doing some more experimenting with the small packet network
> > > performance problem in KVM.  I have a different setup than what Steve
> > > D. was using so I re-baselined things on the kvm.git kernel on both
> > > the host and guest with a 10GbE adapter.  I also made use of the
> > > virtio-stats patch.
> > > 
> > > The virtual machine has 2 vCPUs, 8GB of memory and two virtio network
> > > adapters (the first connected to a 1GbE adapter and a LAN, the second
> > > connected to a 10GbE adapter that is direct connected to another system
> > > with the same 10GbE adapter) running the kvm.git kernel.  The test was
> > > a TCP_RR test with 100 connections from a baremetal client to the KVM
> > > guest using a 256 byte message size in both directions.
> > > 
> > > I used the uperf tool to do this after verifying the results against
> > > netperf. Uperf allows the specification of the number of connections as
> > > a parameter in an XML file as opposed to launching, in this case, 100
> > > separate instances of netperf.
> > > 
> > > Here is the baseline for baremetal using 2 physical CPUs:
> > >   Txn Rate: 206,389.59 Txn/Sec, Pkt Rate: 410,048 Pkts/Sec
> > >   TxCPU: 7.88%  RxCPU: 99.41%
> > > 
> > > To be sure to get consistent results with KVM I disabled the
> > > hyperthreads, pinned the qemu-kvm process, vCPUs, vhost thread and
> > > ethernet adapter interrupts (this resulted in runs that differed by
> > > only about 2% from lowest to highest).  The fact that pinning is
> > > required to get consistent results is a different problem that we'll
> > > have to look into later...
> > > 
> > > Here is the KVM baseline (average of six runs):
> > >   Txn Rate: 87,070.34 Txn/Sec, Pkt Rate: 172,992 Pkts/Sec
> > >   Exits: 148,444.58 Exits/Sec
> > >   TxCPU: 2.40%  RxCPU: 99.35%
> > > 
> > > About 42% of baremetal.
> > 
> > Can you add interrupt stats as well please?
> 
> Yes I can.  Just the guest interrupts for the virtio device?
> 
> > > empty.  So I coded a quick patch to delay freeing of the used Tx
> > > buffers until more than half the ring was used (I did not test this
> > > under a stream condition so I don't know if this would have a negative
> > > impact). Here are the results
> > > 
> > > from delaying the freeing of used Tx buffers (average of six runs):
> > >   Txn Rate: 90,886.19 Txn/Sec, Pkt Rate: 180,571 Pkts/Sec
> > >   Exits: 142,681.67 Exits/Sec
> > >   TxCPU: 2.78%  RxCPU: 99.36%
> > > 
> > > About a 4% increase over baseline and about 44% of baremetal.
> > 
> > Hmm, I am not sure what you mean by delaying freeing.
> 
> In the start_xmit function of virtio_net.c the first thing done is to free
> any used entries from the ring.  I patched the code to track the number of
> used tx ring entries and only free the used entries when they are greater
> than half the capacity of the ring (similar to the way the rx ring is
> re-filled).
> 
> > I think we do have a problem that free_old_xmit_skbs
> > tries to flush out the ring aggressively:
> > it always polls until the ring is empty,
> > so there could be bursts of activity where
> > we spend a lot of time flushing the old entries
> > before e.g. sending an ack, resulting in
> > latency bursts.
> > 
> > Generally we'll need some smarter logic,
> > but with indirect at the moment we can just poll
> > a single packet after we post a new one, and be done with it.
> > Is your patch something like the patch below?
> > Could you try mine as well please?
> 
> Yes, I'll try the patch and post the results.
> 
> > > This spread out the kick_notify but still resulted in alot of them.  I
> > > decided to build on the delayed Tx buffer freeing and code up an
> > > "ethtool" like coalescing patch in order to delay the kick_notify until
> > > there were at least 5 packets on the ring or 2000 usecs, whichever
> > > occurred first.  Here are the
> > > 
> > > results of delaying the kick_notify (average of six runs):
> > >   Txn Rate: 107,106.36 Txn/Sec, Pkt Rate: 212,796 Pkts/Sec
> > >   Exits: 102,587.28 Exits/Sec
> > >   TxCPU: 3.03%  RxCPU: 99.33%
> > > 
> > > About a 23% increase over baseline and about 52% of baremetal.
> > > 
> > > Running the perf command against the guest I noticed almost 19% of the
> > > time being spent in _raw_spin_lock.  Enabling lockstat in the guest
> > > showed alot of contention in the "irq_desc_lock_class". Pinning the
> > > virtio1-input interrupt to a single cpu in the guest and re-running the
> > > last test resulted in
> > > 
> > > tremendous gains (average of six runs):
> > >   Txn Rate: 153,696.59 Txn/Sec, Pkt Rate: 305,358 Pkgs/Sec
> > >   Exits: 62,603.37 Exits/Sec
> > >   TxCPU: 3.73%  RxCPU: 98.52%
> > > 
> > > About a 77% increase over baseline and about 74% of baremetal.
> > > 
> > > Vhost is receiving a lot of notifications for packets that are to be
> > > transmitted (over 60% of the packets generate a kick_notify).  Also, it
> > > looks like vhost is sending a lot of notifications for packets it has
> > > received before the guest can get scheduled to disable notifications
> > > and begin processing the packets
> > 
> > Hmm, is this really what happens to you?  The effect would be that guest
> > gets an interrupt while notifications are disabled in guest, right? Could
> > you add a counter and check this please?
> 
> The disabling of the interrupt/notifications is done by the guest.  So the
> guest has to get scheduled and handle the notification before it disables
> them.  The vhost_signal routine will keep injecting an interrupt until this
> happens causing the contention in the guest.  I'll try the patches you
> specify below and post the results.  They look like they should take care
> of this issue.
> 
> > Another possible thing to try would be these old patches to publish used
> > 
> > index from guest to make sure this double interrupt does not happen:
> >  [PATCHv2] virtio: put last seen used index into ring itself
> >  [PATCHv2] vhost-net: utilize PUBLISH_USED_IDX feature

I was able to apply these patches with a little work, but unfortunately the 
guest oops during boot up in virtqueue_add_buf_gfp.  It happens in the 
virtio_blk driver.  Any chance you can re-work these patches against the 
kvm.git tree?

> >  
> > > resulting in some lock contention in the guest (and
> > > high interrupt rates).
> > > 
> > > Some thoughts for the transmit path...  can vhost be enhanced to do
> > > some adaptive polling so that the number of kick_notify events are
> > > reduced and replaced by kick_no_notify events?
> > 
> > Worth a try.
> > 
> > > Comparing the transmit path to the receive path, the guest disables
> > > notifications after the first kick and vhost re-enables notifications
> > > after completing processing of the tx ring.
> > 
> > Is this really what happens? I though the host disables notifications
> > after the first kick.
> 
> Yup, sorry for the confusion.  The kick is done by the guest and then vhost
> disables notifications.  Maybe a similar approach to the above patches of
> checking the used index in the virtio_net driver could also help here?
> 
> > >  Can a similar thing be done for the
> > > 
> > > receive path?  Once vhost sends the first notification for a received
> > > packet it can disable notifications and let the guest re-enable
> > > notifications when it has finished processing the receive ring.  Also,
> > > can the virtio-net driver do some adaptive polling (or does napi take
> > > care of that for the guest)?
> > 
> > Worth a try. I don't think napi does anything like this.
> > 
> > > Running the same workload on the same configuration with a different
> > > hypervisor results in performance that is almost equivalent to
> > > baremetal without doing any pinning.
> > > 
> > > Thanks,
> > > Tom Lendacky
> > 
> > There's no need to flush out all used buffers
> > before we post more for transmit: with indirect,
> > just a single one is enough. Without indirect we'll
> > need more possibly, but just for testing this should
> > be enough.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > 
> > ---
> > 
> > Note: untested.
> > 
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index 82dba5a..ebe3337 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -514,11 +514,11 @@ static unsigned int free_old_xmit_skbs(struct
> > virtnet_info *vi) struct sk_buff *skb;
> > 
> >  	unsigned int len, tot_sgs = 0;
> > 
> > -	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
> > +	if ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
> > 
> >  		pr_debug("Sent skb %p\n", skb);
> >  		vi->dev->stats.tx_bytes += skb->len;
> >  		vi->dev->stats.tx_packets++;
> > 
> > -		tot_sgs += skb_vnet_hdr(skb)->num_sg;
> > +		tot_sgs = 2+MAX_SKB_FRAGS;
> > 
> >  		dev_kfree_skb_any(skb);
> >  	
> >  	}
> >  	return tot_sgs;
> > 
> > @@ -576,9 +576,6 @@ static netdev_tx_t start_xmit(struct sk_buff *skb,
> > struct net_device *dev) struct virtnet_info *vi = netdev_priv(dev);
> > 
> >  	int capacity;
> > 
> > -	/* Free up any pending old buffers before queueing new ones. */
> > -	free_old_xmit_skbs(vi);
> > -
> > 
> >  	/* Try to transmit */
> >  	capacity = xmit_skb(vi, skb);
> > 
> > @@ -605,6 +602,10 @@ static netdev_tx_t start_xmit(struct sk_buff *skb,
> > struct net_device *dev) skb_orphan(skb);
> > 
> >  	nf_reset(skb);
> > 
> > +	/* Free up any old buffers so we can queue new ones. */
> > +	if (capacity < 2+MAX_SKB_FRAGS)
> > +		capacity += free_old_xmit_skbs(vi);
> > +
> > 
> >  	/* Apparently nice girls don't return TX_BUSY; stop the queue
> >  	
> >  	 * before it gets out of hand.  Naturally, this wastes entries. */
> >  	
> >  	if (capacity < 2+MAX_SKB_FRAGS) {
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe kvm" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
