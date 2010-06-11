From: Anton Vorontsov <avorontsov@mvista.com>
Subject: [PATCH] gianfar: Fix oversized packets handling
Date: Sat, 12 Jun 2010 00:51:03 +0400
Message-ID: <20100611205103.GA4255@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:10272 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760491Ab0FKUvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 16:51:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Issuing the following command on host:

$ ifconfig eth2 mtu 1600 ; ping 10.0.0.27 -s 1485 -c 1

Makes some boards (tested with MPC8315 rev 1.1 and MPC8313 rev 1.0)
oops like this:

  skb_over_panic: text:c0195914 len:1537 put:1537 head:c79e4800 data:c79e4880 tail:0xc79e4e81 end:0xc79e4e80 dev:eth1
  ------------[ cut here ]------------
  kernel BUG at net/core/skbuff.c:127!
  Oops: Exception in kernel mode, sig: 5 [#1]
  MPC831x RDB
  last sysfs file: /sys/kernel/uevent_seqnum
  Modules linked in:
  NIP: c01c1840 LR: c01c1840 CTR: c016d918
  [...]
  NIP [c01c1840] skb_over_panic+0x48/0x5c
  LR [c01c1840] skb_over_panic+0x48/0x5c
  Call Trace:
  [c0339d50] [c01c1840] skb_over_panic+0x48/0x5c (unreliable)
  [c0339d60] [c01c3020] skb_put+0x5c/0x60
  [c0339d70] [c0195914] gfar_clean_rx_ring+0x25c/0x3d0
  [c0339dc0] [c01976e8] gfar_poll+0x170/0x1bc

Dumped buffer descriptors showed that eTSEC's length/truncation
logic sometimes passes oversized packets, i.e. for the above ICMP
packet the following two buffer descriptors may become ready:

  status=1400 length=1536
  status=1800 length=1541

So, it seems that gianfar actually receives the whole big frame,
and it tries to place the packet into two BDs. This situation
confuses the driver, and so the skb_put() sanity check fails.

This patch fixes the issue by adding an appropriate check, i.e.
the driver should not try to process frames with buffer
descriptor's length over rx_buffer_size (i.e. maxfrm and mrblr).

Note that sometimes eTSEC works correctly, i.e. in the second
(last) buffer descriptor bits 'truncated' and 'crcerr' are set,
and so there's no oops. Though I couldn't find any logic when
it works correctly and when not.

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/gianfar.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 46c69cd..7c31f0f 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2642,6 +2642,10 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
 				priv->rx_buffer_size, DMA_FROM_DEVICE);
 
+		if (unlikely(!(bdp->status & RXBD_ERR) &&
+				bdp->length > priv->rx_buffer_size))
+			bdp->status = RXBD_LARGE;
+
 		/* We drop the frame if we failed to allocate a new buffer */
 		if (unlikely(!newskb || !(bdp->status & RXBD_LAST) ||
 				 bdp->status & RXBD_ERR)) {
-- 
1.7.0.5
