From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] e1000: enhance frame fragment detection
Date: Mon, 28 Dec 2009 15:10:05 -0500
Message-ID: <20091228201005.GC18422@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@tuxdriver.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50190 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbZL1UKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 15:10:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	A security discussion was recently given:
http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
And a patch that I submitted awhile back was brought up.  Apparently some of
their testing revealed that they were able to force a buffer fragment in e1000
in which the trailing fragment was greater than 4 bytes.  As a result the
fragment check I introduced failed to detect the fragement and a partial invalid
frame was passed up into the network stack.  I've written this patch to correct
it.  I'm in the process of testing it now, but it makes good logical sense to
me.  Effectively it maintains a per-adapter state variable which detects a
non-EOP frame, and discards it and subsequent non-EOP frames leading up to _and_
_including_ the next positive-EOP frame (as it is by definition the last
fragment).  This should prevent any and all partial frames from entering the
network stack from e1000

Regards
Neil


 e1000.h      |    3 ++-
 e1000_main.c |   14 ++++++++++++--
 2 files changed, 14 insertions(+), 3 deletions(-)


diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 2a567df..3d421ab 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -331,7 +331,8 @@ struct e1000_adapter {
 enum e1000_state_t {
 	__E1000_TESTING,
 	__E1000_RESETTING,
-	__E1000_DOWN
+	__E1000_DOWN,
+	__E1000_DISCARDING
 };
 
 extern char e1000_driver_name[];
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7e855f9..0731779 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3850,16 +3850,26 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		length = le16_to_cpu(rx_desc->length);
 		/* !EOP means multiple descriptors were used to store a single
-		 * packet, also make sure the frame isn't just CRC only */
-		if (unlikely(!(status & E1000_RXD_STAT_EOP) || (length <= 4))) {
+		 * packet, if thats the case we need to toss it.  In fact, we
+		 * to toss every packet with the EOP bit clear and the next
+		 * frame that _does_ have the EOP bit set, as it is by
+		 * definition only a frame fragment
+		 */
+		if (unlikely(!(status & E1000_RXD_STAT_EOP)))
+			set_bit(__E1000_DISCARDING, &adapter->flags);
+
+		if (test_bit(__E1000_DISCARDING, &adapter->flags)) {
 			/* All receives must fit into a single buffer */
 			E1000_DBG("%s: Receive packet consumed multiple"
 				  " buffers\n", netdev->name);
 			/* recycle */
 			buffer_info->skb = skb;
+			if (status & E1000_RXD_STAT_EOP)
+				clear_bit(__E1000_DISCARDING, &adapter->flags);
 			goto next_desc;
 		}
 
+
 		if (unlikely(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
 			u8 last_byte = *(skb->data + length - 1);
 			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
