From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH net-next 07/15] 6lowpan: store fragment
	tag values per device instead of net stack wide
Date: Tue, 23 Oct 2012 00:09:49 -0400
Message-ID: <1350965397-12384-8-git-send-email-tony.cheneau@amnesiak.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1350965397-12384-1-git-send-email-tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
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
 net/ieee802154/6lowpan.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 38cecaf..eb8003b 100644
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
 
@@ -1022,14 +1022,14 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
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
@@ -1095,7 +1095,7 @@ static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	pr_debug("frame is too big, fragmentation is needed\n");
-	err = lowpan_skb_fragmentation(skb);
+	err = lowpan_skb_fragmentation(skb, dev);
 error:
 	dev_kfree_skb(skb);
 out:
@@ -1216,6 +1216,7 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 		return -ENODEV;
 
 	lowpan_dev_info(dev)->real_dev = real_dev;
+	lowpan_dev_info(dev)->fragment_tag = 0;
 	mutex_init(&lowpan_dev_info(dev)->dev_list_mtx);
 
 	entry = kzalloc(sizeof(struct lowpan_dev_record), GFP_KERNEL);
-- 
1.7.8.6


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_sfd2d_oct
