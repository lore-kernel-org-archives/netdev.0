From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [RFC] virtio: orphan skbs if we're relying on timer to free them
Date: Mon, 18 May 2009 22:18:47 +0930
Message-ID: <200905182218.47975.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42998 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbZERMsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2009 08:48:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We check for finished xmit skbs on every xmit, or on a timer (unless
the host promises to force an interrupt when the xmit ring is empty).
This can penalize userspace tasks which fill their sockbuf.  Not much
difference with TSO, but measurable with large numbers of packets.

There are a finite number of packets which can be in the transmission
queue.  We could fire the timer more than every 100ms, but that would
just hurt performance for a corner case.  This seems neatest.

With interrupt when Tx ring empty:
				Seconds	TxPkts	TxIRQs
 1G TCP Guest->Host:		3.76	32833	32758
 1M normal pings:		111	1000008	997463
 1M 1k pings (-l 120):		55	1000007	488920

Without interrupt, without orphaning:
 1G TCP Guest->Host:		3.64	32806	1
 1M normal pings:		106	1000008	1
 1M 1k pings (-l 120):		68	1000005	1

With orphaning:
 1G TCP Guest->Host:		3.86	32821	1
 1M normal pings:		102	1000007	1
 1M 1k pings (-l 120):		43	1000005	1

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -522,6 +522,11 @@ static int start_xmit(struct sk_buff *sk
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
+	/* We queue a limited number; don't let that delay writers if
+	 * we are slow in getting tx interrupt. */
+	if (!vi->free_in_tasklet)
+		skb_orphan(skb);
+
 again:
 	/* Free up any pending old buffers before queueing new ones. */
 	free_old_xmit_skbs(vi);

