From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 1/2] 6lowpan: move frame
	allocation code to a separate function
Date: Thu, 26 Apr 2012 13:35:50 +0400
Message-ID: <1335432951-17340-2-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1335432951-17340-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1335432951-17340-1-git-send-email-alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Separate frame allocation routine from data processing function.
This makes code more human readable and easier for understanding.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c |   81 +++++++++++++++++++++++++++-------------------
 1 files changed, 48 insertions(+), 33 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index b570dbf..f406ac8 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -650,6 +650,53 @@ static void lowpan_fragment_timer_expired(unsigned long entry_addr)
 	kfree(entry);
 }
 
+static struct lowpan_fragment *
+lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u8 tag)
+{
+	struct lowpan_fragment *frame;
+
+	frame = kzalloc(sizeof(struct lowpan_fragment),
+			GFP_ATOMIC);
+	if (!frame)
+		goto frame_err;
+
+	INIT_LIST_HEAD(&frame->list);
+
+	frame->length = (iphc0 & 7) | (len << 3);
+	frame->tag = tag;
+
+	/* allocate buffer for frame assembling */
+	frame->skb = alloc_skb(frame->length +
+			       sizeof(struct ipv6hdr), GFP_ATOMIC);
+
+	if (!frame->skb)
+		goto skb_err;
+
+	frame->skb->priority = skb->priority;
+	frame->skb->dev = skb->dev;
+
+	/* reserve headroom for uncompressed ipv6 header */
+	skb_reserve(frame->skb, sizeof(struct ipv6hdr));
+	skb_put(frame->skb, frame->length);
+
+	init_timer(&frame->timer);
+	/* time out is the same as for ipv6 - 60 sec */
+	frame->timer.expires = jiffies + LOWPAN_FRAG_TIMEOUT;
+	frame->timer.data = (unsigned long)frame;
+	frame->timer.function = lowpan_fragment_timer_expired;
+
+	add_timer(&frame->timer);
+
+	list_add_tail(&frame->list, &lowpan_fragments);
+
+	return frame;
+
+skb_err:
+	kfree(frame);
+frame_err:
+	return NULL;
+}
+
 static int
 lowpan_process_data(struct sk_buff *skb)
 {
@@ -692,41 +739,9 @@ lowpan_process_data(struct sk_buff *skb)
 
 		/* alloc new frame structure */
 		if (!found) {
-			frame = kzalloc(sizeof(struct lowpan_fragment),
-								GFP_ATOMIC);
+			frame = lowpan_alloc_new_frame(skb, iphc0, len, tag);
 			if (!frame)
 				goto unlock_and_drop;
-
-			INIT_LIST_HEAD(&frame->list);
-
-			frame->length = (iphc0 & 7) | (len << 3);
-			frame->tag = tag;
-
-			/* allocate buffer for frame assembling */
-			frame->skb = alloc_skb(frame->length +
-					sizeof(struct ipv6hdr), GFP_ATOMIC);
-
-			if (!frame->skb) {
-				kfree(frame);
-				goto unlock_and_drop;
-			}
-
-			frame->skb->priority = skb->priority;
-			frame->skb->dev = skb->dev;
-
-			/* reserve headroom for uncompressed ipv6 header */
-			skb_reserve(frame->skb, sizeof(struct ipv6hdr));
-			skb_put(frame->skb, frame->length);
-
-			init_timer(&frame->timer);
-			/* time out is the same as for ipv6 - 60 sec */
-			frame->timer.expires = jiffies + LOWPAN_FRAG_TIMEOUT;
-			frame->timer.data = (unsigned long)frame;
-			frame->timer.function = lowpan_fragment_timer_expired;
-
-			add_timer(&frame->timer);
-
-			list_add_tail(&frame->list, &lowpan_fragments);
 		}
 
 		if ((iphc0 & LOWPAN_DISPATCH_MASK) == LOWPAN_DISPATCH_FRAG1)
-- 
1.7.2.3


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
