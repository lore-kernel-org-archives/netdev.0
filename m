From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 7/8] 6lowpan: move lowpan
	frag_info out of 802.15.4 headers
Date: Fri, 14 Mar 2014 16:23:32 +0100
Message-ID: <1394810613-5657-8-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1394810613-5657-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1394810613-5657-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Fragmentation and reassembly information for 6lowpan is independent from
the 802.15.4 stack and used only by the 6lowpan reassembly process. Move
the ieee802154_frag_info struct to a private are, it needn't be in the
802.15.4 skb control block.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 include/net/ieee802154_netdev.h |    8 --------
 net/ieee802154/reassembly.c     |   27 ++++++++++++++++++---------
 2 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 827e3e3..e1717cb 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -187,13 +187,6 @@ static inline void ieee802154_addr_to_sa(struct ieee802154_addr_sa *sa,
 	}
 }
 
-
-struct ieee802154_frag_info {
-	__be16 d_tag;
-	u16 d_size;
-	u8 d_offset;
-};
-
 /*
  * A control block of skb passed between the ARPHRD_IEEE802154 device
  * and other stack parts.
@@ -202,7 +195,6 @@ struct ieee802154_mac_cb {
 	u8 lqi;
 	u8 flags;
 	u8 seq;
-	struct ieee802154_frag_info frag_info;
 	struct ieee802154_addr source;
 	struct ieee802154_addr dest;
 };
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index a2b9e4e..ef2d543 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -30,6 +30,17 @@
 
 #include "reassembly.h"
 
+struct lowpan_frag_info {
+	__be16 d_tag;
+	u16 d_size;
+	u8 d_offset;
+};
+
+struct lowpan_frag_info *lowpan_cb(struct sk_buff *skb)
+{
+	return (struct lowpan_frag_info *)skb->cb;
+}
+
 static struct inet_frags lowpan_frags;
 
 static int lowpan_frag_reasm(struct lowpan_frag_queue *fq,
@@ -102,7 +113,7 @@ out:
 }
 
 static inline struct lowpan_frag_queue *
-fq_find(struct net *net, const struct ieee802154_frag_info *frag_info,
+fq_find(struct net *net, const struct lowpan_frag_info *frag_info,
 	const struct ieee802154_addr *src,
 	const struct ieee802154_addr *dst)
 {
@@ -137,8 +148,8 @@ static int lowpan_frag_queue(struct lowpan_frag_queue *fq,
 	if (fq->q.last_in & INET_FRAG_COMPLETE)
 		goto err;
 
-	offset = mac_cb(skb)->frag_info.d_offset << 3;
-	end = mac_cb(skb)->frag_info.d_size;
+	offset = lowpan_cb(skb)->d_offset << 3;
+	end = lowpan_cb(skb)->d_size;
 
 	/* Is this the final fragment? */
 	if (offset + skb->len == end) {
@@ -164,15 +175,13 @@ static int lowpan_frag_queue(struct lowpan_frag_queue *fq,
 	 * this fragment, right?
 	 */
 	prev = fq->q.fragments_tail;
-	if (!prev || mac_cb(prev)->frag_info.d_offset <
-		     mac_cb(skb)->frag_info.d_offset) {
+	if (!prev || lowpan_cb(prev)->d_offset < lowpan_cb(skb)->d_offset) {
 		next = NULL;
 		goto found;
 	}
 	prev = NULL;
 	for (next = fq->q.fragments; next != NULL; next = next->next) {
-		if (mac_cb(next)->frag_info.d_offset >=
-		    mac_cb(skb)->frag_info.d_offset)
+		if (lowpan_cb(next)->d_offset >= lowpan_cb(skb)->d_offset)
 			break;	/* bingo! */
 		prev = next;
 	}
@@ -319,7 +328,7 @@ out_oom:
 }
 
 static int lowpan_get_frag_info(struct sk_buff *skb, const u8 frag_type,
-				struct ieee802154_frag_info *frag_info)
+				struct lowpan_frag_info *frag_info)
 {
 	bool fail;
 	u8 pattern = 0, low = 0;
@@ -346,7 +355,7 @@ int lowpan_frag_rcv(struct sk_buff *skb, const u8 frag_type)
 {
 	struct lowpan_frag_queue *fq;
 	struct net *net = dev_net(skb->dev);
-	struct ieee802154_frag_info *frag_info = &mac_cb(skb)->frag_info;
+	struct lowpan_frag_info *frag_info = lowpan_cb(skb);
 	struct ieee802154_addr source, dest;
 	int err;
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
