From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH v2 net-next 07/12] 6lowpan: add debug
	messages for 6LoWPAN fragmentation
Date: Mon, 25 Mar 2013 23:59:27 -0400
Message-ID: <1364270372-19430-8-git-send-email-tony.cheneau@amnesiak.org>
References: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364270372-19430-1-git-send-email-tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Add pr_debug() call in order to debug 6LoWPAN fragmentation and
reassembly.

Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 4a62289..61eee9d 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -742,10 +742,16 @@ lowpan_process_data(struct sk_buff *skb)
 		/* adds the 3 MSB to the 8 LSB to retrieve the 11 bits length */
 		len = ((iphc0 & 7) << 8) | slen;
 
-		/* FRAGN */
-		if ((iphc0 & LOWPAN_DISPATCH_MASK) != LOWPAN_DISPATCH_FRAG1) {
+		if ((iphc0 & LOWPAN_DISPATCH_MASK) == LOWPAN_DISPATCH_FRAG1) {
+			pr_debug("%s received a FRAG1 packet (tag: %d, "
+				 "size of the entire IP packet: %d)",
+				 __func__, tag, len);
+		} else { /* FRAGN */
 			if (lowpan_fetch_skb_u8(skb, &offset))
 				goto unlock_and_drop;
+			pr_debug("%s received a FRAGN packet (tag: %d, "
+				 "size of the entire IP packet: %d, "
+				 "offset: %d)", __func__, tag, len, offset * 8);
 		}
 
 		/*
@@ -762,6 +768,8 @@ lowpan_process_data(struct sk_buff *skb)
 
 		/* alloc new frame structure */
 		if (!found) {
+			pr_debug("%s first fragment received for tag %d, "
+				 "begin packet reassembly", __func__, tag);
 			frame = lowpan_alloc_new_frame(skb, len, tag);
 			if (!frame)
 				goto unlock_and_drop;
@@ -784,6 +792,9 @@ lowpan_process_data(struct sk_buff *skb)
 			list_del(&frame->list);
 			spin_unlock_bh(&flist_lock);
 
+			pr_debug("%s successfully reassembled fragment "
+				 "(tag %d)", __func__, tag);
+
 			dev_kfree_skb(skb);
 			skb = frame->skb;
 			kfree(frame);
@@ -1034,8 +1045,11 @@ lowpan_skb_fragmentation(struct sk_buff *skb)
 	err = lowpan_fragment_xmit(skb, head, header_length, LOWPAN_FRAG_SIZE,
 				   0, LOWPAN_DISPATCH_FRAG1);
 
-	if (err)
+	if (err) {
+		pr_debug("%s unable to send FRAG1 packet (tag: %d)",
+			 __func__, tag);
 		goto exit;
+	}
 
 	offset = LOWPAN_FRAG_SIZE;
 
@@ -1053,8 +1067,11 @@ lowpan_skb_fragmentation(struct sk_buff *skb)
 
 		err = lowpan_fragment_xmit(skb, head, header_length,
 					   len, offset, LOWPAN_DISPATCH_FRAGN);
-		if (err)
+		if (err) {
+			pr_debug("%s unable to send a subsequent FRAGN packet "
+				 "(tag: %d, offset: %d", __func__, tag, offset);
 			goto exit;
+		}
 
 		offset += len;
 	}
-- 
1.7.12.4


------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
