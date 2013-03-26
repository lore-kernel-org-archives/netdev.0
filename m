From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH v2 net-next 08/12] 6lowpan: store
	fragment tag values per device instead of net stack wide
Date: Mon, 25 Mar 2013 23:59:28 -0400
Message-ID: <1364270372-19430-9-git-send-email-tony.cheneau@amnesiak.org>
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

Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 61eee9d..f952451 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -104,6 +104,7 @@ static const u8 lowpan_llprefix[] = {0xfe, 0x80};
 struct lowpan_dev_info {
 	struct net_device	*real_dev; /* real WPAN device ptr */
 	struct mutex		dev_list_mtx; /* mutex for list ops */
+	unsigned short fragment_tag;
 };
 
 struct lowpan_dev_record {
@@ -120,7 +121,6 @@ struct lowpan_fragment {
 	struct list_head	list;		/* fragments list */
 };
 
-static unsigned short fragment_tag;
 static LIST_HEAD(lowpan_fragments);
 static DEFINE_SPINLOCK(flist_lock);
 
@@ -1027,14 +1027,14 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
 }
 
 static int
-lowpan_skb_fragmentation(struct sk_buff *skb)
+lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 {
 	int  err, header_length, payload_length, tag, offset = 0;
 	u8 head[5];
 
 	header_length = lowpan_get_mac_header_length(skb);
 	payload_length = skb->len - header_length;
-	tag = fragment_tag++;
+	tag = lowpan_dev_info(dev)->fragment_tag++;
 
 	/* first fragment header */
 	head[0] = LOWPAN_DISPATCH_FRAG1 | ((payload_length >> 8) & 0x7);
@@ -1099,7 +1099,7 @@ static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	pr_debug("frame is too big, fragmentation is needed\n");
-	err = lowpan_skb_fragmentation(skb);
+	err = lowpan_skb_fragmentation(skb, dev);
 error:
 	dev_kfree_skb(skb);
 out:
@@ -1243,6 +1243,7 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 		return -ENODEV;
 
 	lowpan_dev_info(dev)->real_dev = real_dev;
+	lowpan_dev_info(dev)->fragment_tag = 0;
 	mutex_init(&lowpan_dev_info(dev)->dev_list_mtx);
 
 	entry = kzalloc(sizeof(struct lowpan_dev_record), GFP_KERNEL);
-- 
1.7.12.4


------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
