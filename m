From: Mark Lord <mlord@pobox.com>
Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
Date: Tue, 19 Nov 2013 09:02:27 -0500
Message-ID: <528B6F73.7040801@pobox.com>
References: <52890C7E.6000607@pobox.com> <52891178.2080509@pobox.com> <52891341.4020403@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B742B@saturn3.aculab.com> <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com> <528A9A36.50903@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070103020705010902070906"
To: David Laight <David.Laight@ACULAB.COM>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ming Lei <ming.lei@canonical.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:50663 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771Ab3KSOC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 09:02:29 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070103020705010902070906
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 13-11-19 05:04 AM, David Laight wrote:
>> From: Mark Lord
..
>> except the ax88179_178a driver still does not work in linux-3.12,
>> whereas it works fine in all earlier kernels.
>>
>> That's a regression.
>> And a simple revert (earlier in this thread) fixes it.
>> So.. let's revert it for now, until a proper xhci compatible patch is produced.
...
> There is a patch to xhci-ring.c that should fix the SG problem.
> http://www.spinics.net/lists/linux-usb/msg97176.html
> 
> I think it should apply to the 3.12 sources.

I am running with that patch here now (thanks),
and it too appears to prevent the lockups.

But is this patch upstream already?
If yes, then it needs to get pushed out to -stable for 3.12 at least.

If not upstream, then the revert is probably safest for -stable,
rather than new code that has never been upstream before.

Both patches are attached to this email.
One or the other is required for the USB 3.0 network adapters to function in 3.12.

Thanks
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com

--------------070103020705010902070906
Content-Type: text/x-patch;
 name="51_ax88179_178a_revert_3.12_lockups.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="51_ax88179_178a_revert_3.12_lockups.patch"

Revert USB 3.0 network driver changes that break the adapter (lockups)
in 3.12.  This just puts back the original code from previous kernels.

Signed-off-by: Mark Lord <mlord@pobox.com>

--- linux/drivers/net/usb/ax88179_178a.c.orig	2013-11-03 18:41:51.000000000 -0500
+++ linux/drivers/net/usb/ax88179_178a.c	2013-11-17 13:23:39.525734277 -0500
@@ -1177,18 +1177,31 @@
 	int frame_size = dev->maxpacket;
 	int mss = skb_shinfo(skb)->gso_size;
 	int headroom;
+	int tailroom;
 
 	tx_hdr1 = skb->len;
 	tx_hdr2 = mss;
 	if (((skb->len + 8) % frame_size) == 0)
 		tx_hdr2 |= 0x80008000;	/* Enable padding */
 
-	headroom = skb_headroom(skb) - 8;
+	headroom = skb_headroom(skb);
+	tailroom = skb_tailroom(skb);
 
-	if ((skb_header_cloned(skb) || headroom < 0) &&
-	    pskb_expand_head(skb, headroom < 0 ? 8 : 0, 0, GFP_ATOMIC)) {
+	if (!skb_header_cloned(skb) &&
+	    !skb_cloned(skb) &&
+	    (headroom + tailroom) >= 8) {
+		if (headroom < 8) {
+			skb->data = memmove(skb->head + 8, skb->data, skb->len);
+			skb_set_tail_pointer(skb, skb->len);
+		}
+	} else {
+		struct sk_buff *skb2;
+
+		skb2 = skb_copy_expand(skb, 8, 0, flags);
 		dev_kfree_skb_any(skb);
-		return NULL;
+		skb = skb2;
+		if (!skb)
+			return NULL;
 	}
 
 	skb_push(skb, 4);

--------------070103020705010902070906
Content-Type: text/x-patch;
 name="55_usb_xhci_TRB_scatter_gather_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="55_usb_xhci_TRB_scatter_gather_fix.patch"

Section 4.11.7.1 of rev 1.0 of the xhci specification states that a link TRB
can only occur at a boundary between underlying USB frames (512 bytes for 480M).

If this isn't done the USB frames aren't formatted correctly and, for example,
the USB3 ethernet ax88179_178a card will stop sending (while still receiving)
when running a netperf tcp transmit test with (say) and 8k buffer.

This should be a candidate for stable, the ax88179_178a driver defaults to
gso and tso enabled so it passes a lot of fragmented skb to the USB stack.

Signed-off-by: David Laight &lt;david.laight@xxxxxxxxxx&gt;
---

Changes for v2:

1) Only act on bulk endpoints.
   While isoc endpoints could suffer from the same problem it is much less
   likely and can't be fixed by adding NOP TRBs (they would stop data being
   sent in the poll interval).

2) When writing the NOP TRB use the count of TRBs instead of scanning for
   the link TRB.

 drivers/usb/host/xhci-ring.c | 53 ++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 51 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/host/xhci-ring.c b/drivers/usb/host/xhci-ring.c
index 5480215..c1342dc 100644
--- a/drivers/usb/host/xhci-ring.c
+++ b/drivers/usb/host/xhci-ring.c
@@ -2929,8 +2929,57 @@
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
+			if (ep_ring->type != TYPE_BULK)
+				/*
+				 * While isoc transfers might have a buffer that
+				 * crosses a 64k boundary it is unlikely.
+				 * Since we can't add NOPs without generating
+				 * gaps in the traffic just hope it never
+				 * happens at the end of the ring.
+				 * This could be fixed by writing a LINK TRB
+				 * instead of the first NOP - however the
+				 * TRB_TYPE_LINK_LE32() calls would all need
+				 * changing to check the ring length. */
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
+			ep_ring->num_trbs_free -= usable;
+			do {
+				trb->generic.field[0] = 0;
+				trb->generic.field[1] = 0;
+				trb->generic.field[2] = 0;
+				trb->generic.field[3] = nop_cmd;
+				trb++;
+			} while (--usable);
+			ep_ring->enqueue = trb;
+			if (room_on_ring(xhci, ep_ring, num_trbs))
+				break;
+		}
 
 		if (ep_ring == xhci->cmd_ring) {
 			xhci_err(xhci, "Do not support expand command ring\n");

--------------070103020705010902070906--
