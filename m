From: "David Laight" <David.Laight@ACULAB.COM>
Subject: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Thu, 7 Nov 2013 17:20:49 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73EF@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	"Sarah Sharp" <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45684 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753150Ab3KGRYu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 12:24:50 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26501-03 for <netdev@vger.kernel.org>;
 Thu,  7 Nov 2013 17:24:47 +0000 (GMT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Section 4.11.7.1 of rev 1.0 of the xhci specification states that a link TRB
can only occur at a boundary between underlying USB frames (512 bytes for 480M).

If this isn't done the USB frames aren't formatted correctly and, for example,
the USB3 ethernet ax88179_178a card will stop sending (while still receiving)
when running a netperf tcp transmit test with (say) and 8k buffer.

While this change improves things a lot (it runs for 20 minutes rather than
a few seconds), there is still something else wrong.

This should be a candidate for stable, the ax88179_178a driver defaults to
gso and tso enabled so it passes a lot of fragmented skb to the USB stack.

Signed-off-by: David Laight <david.laight@aculab.com>
---

Although I've got a USB2 analyser its trigger and trace stuff is almost
unusable! In any case this fails much faster on USB3 (Intel i7 cpu).

diff --git a/drivers/usb/host/xhci-ring.c b/drivers/usb/host/xhci-ring.c
index 5480215..23abc9b 100644
--- a/drivers/usb/host/xhci-ring.c
+++ b/drivers/usb/host/xhci-ring.c
@@ -2927,8 +2932,43 @@ static int prepare_ring(struct xhci_hcd *xhci, struct xhci_ring *ep_ring,
 	}
 
 	while (1) {
-		if (room_on_ring(xhci, ep_ring, num_trbs))
-			break;
+		if (room_on_ring(xhci, ep_ring, num_trbs)) {
+			union xhci_trb *trb = ep_ring->enqueue;
+			unsigned int usable = ep_ring->enq_seg->trbs +
+					TRBS_PER_SEGMENT - 1 - trb;
+			u32 nop_cmd;
+
+			/*
+			 * Section 4.11.7.1 TD Fragments states that a link
+			 * TRB must only occur at the boundary between
+			 * data bursts (eg 512 bytes for 480M).
+			 * While it is possible to split a large fragment
+			 * we don't know the size yet.
+			 * Simplest solution is to fill the trb before the
+			 * LINK with nop commands.
+			 */
+			if (num_trbs == 1 || num_trbs <= usable || usable == 0)
+				break;
+
+			if (num_trbs >= TRBS_PER_SEGMENT) {
+				xhci_err(xhci, "Too many fragments %d, max %d\n",
+						num_trbs, TRBS_PER_SEGMENT - 1);
+				return -ENOMEM;
+			}
+
+			nop_cmd = cpu_to_le32(TRB_TYPE(TRB_TR_NOOP) |
+					ep_ring->cycle_state);
+			for (; !TRB_TYPE_LINK_LE32(trb->link.control); trb++) {
+				trb->generic.field[0] = 0;
+				trb->generic.field[1] = 0;
+				trb->generic.field[2] = 0;
+				trb->generic.field[3] = nop_cmd;
+				ep_ring->num_trbs_free--;
+			}
+			ep_ring->enqueue = trb;
+			if (room_on_ring(xhci, ep_ring, num_trbs))
+				break;
+		}
 
 		if (ep_ring == xhci->cmd_ring) {
 			xhci_err(xhci, "Do not support expand command ring\n");
