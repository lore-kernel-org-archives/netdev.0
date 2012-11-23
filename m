From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Qemu-devel] tap devices not receiving packets from a bridge
Date: Fri, 23 Nov 2012 13:01:46 +0200
Message-ID: <20121123110146.GC7051@redhat.com>
References: <50AE36E0.8000307@dlhnet.de>
 <20121123070211.GC22787@stefanha-thinkpad.hitronhub.home>
 <E85C6011-548D-4507-A776-1028DD3E3515@dlhnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Hajnoczi <stefanha@gmail.com>, qemu-devel@nongnu.org,
	netdev@vger.kernel.org
To: Peter Lieven <pl@dlhnet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6019 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753647Ab2KWK7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2012 05:59:01 -0500
Content-Disposition: inline
In-Reply-To: <E85C6011-548D-4507-A776-1028DD3E3515@dlhnet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 23, 2012 at 10:41:21AM +0100, Peter Lieven wrote:
> 
> Am 23.11.2012 um 08:02 schrieb Stefan Hajnoczi:
> 
> > On Thu, Nov 22, 2012 at 03:29:52PM +0100, Peter Lieven wrote:
> >> is anyone aware of a problem with the linux network bridge that in very rare circumstances stops
> >> a bridge from sending pakets to a tap device?
> >> 
> >> My problem occurs in conjunction with vanilla qemu-kvm-1.2.0 and Ubuntu Kernel 3.2.0-34.53
> >> which is based on Linux 3.2.33.
> >> 
> >> I was not yet able to reproduce the issue, it happens in really rare cases. The symptom is that
> >> the tap does not have any TX packets. RX is working fine. I see the packets coming in at
> >> the physical interface on the host, but they are not forwarded to the tap interface.
> >> The bridge itself has learnt the mac address of the vServer that is connected to the tap interface.
> >> It does not help to toggle the bridge link status,  the tap interface status or the interface in the vServer.
> >> It seems that problem occurs if a tap interface that has previously been used, but set to nonpersistent
> >> is set persistent again and then is by chance assigned to the same vServer (=same mac address on same
> >> bridge) again. Unfortunately it seems not to be reproducible.
> > 
> > Not sure but this patch from Michael Tsirkin may help - it solves an
> > issue with persistent tap devices:
> > 
> > http://patchwork.ozlabs.org/patch/198598/
> 
> Hi Stefan,
> 
> thanks for the pointer. I have seen this patch, but I have neglected it because it was dealing
> with persistent taps. But maybe the taps in the kernel are not deleted directly. 
> Can you remember what the syptomps of the above issue have been? Sorry for
> being vague, but I currently have no clue whats going on.
> 
> Can someone who has more internal knowledge of the bridging/tap code say if qemu can
> be responsible at all if the tap device is not receiving packets from the bridge.
> 
> If I have the following config. Lets say packets coming in via physical interface eth1.123,
> and a bridge called br123.I further have a virtual machine with tap0. Both eth1.123
> and tap0 are member of br123. 
> 
> If the issue occurs the vServer has no network connectivity inbound. If I sent a ping
> from the vServer I see it on tap0 and leaving on eth1.123. I see further the arp reply coming
> in via eth1.123, but the reply can't be seen on tap0.
> 
> Peter

If guest is not consuming packets, a TX queue in tap device
will with time overrun (there's space for 1000 packets there).
This is code from tun:

        if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
                          >= dev->tx_queue_len / tun->numqueues){
                if (!(tun->flags & TUN_ONE_QUEUE)) {
                        /* Normal queueing mode. */
                        /* Packet scheduler handles dropping of further
 * packets. */
                        netif_stop_subqueue(dev, txq);

                        /* We won't see all dropped packets
 * individually, so overrun
                         * error is more appropriate. */
                        dev->stats.tx_fifo_errors++;


So you can detect that this triggered by looking at fifo errors counter in device.

Once this happens TX queue is stopped, then you hit this path:

                        if (!netif_xmit_stopped(txq)) {
                                __this_cpu_inc(xmit_recursion);
                                rc = dev_hard_start_xmit(skb, dev, txq);
                                __this_cpu_dec(xmit_recursion);
                                if (dev_xmit_complete(rc)) {
                                        HARD_TX_UNLOCK(dev, txq);
                                        goto out;
                                }
                        }

so packets are not passed to device anymore.
It will stay this way until guest consumes some packets and
queue is restarted.

> > 
> > Stefan
