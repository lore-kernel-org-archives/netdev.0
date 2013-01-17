From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: [PATCH v2 1/2] 6lowpan: Refactor packet
	delivery into a function
Date: Thu, 17 Jan 2013 00:09:47 -0500
Message-ID: <1358399388-30062-2-git-send-email-alan@signal11.us>
References: <1358315037-10043-1-git-send-email-alan@signal11.us>
	<1358399388-30062-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1358399388-30062-1-git-send-email-alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Refactor the handing of the skb's to the individual lowpan devices into a
function.

Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 38 ++++++++++++++++++++++++--------------
 1 file changed, 24 insertions(+), 14 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index f651da6..1714cfa 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -594,10 +594,32 @@ static int lowpan_header_create(struct sk_buff *skb,
 	}
 }
 
+static int lowpan_give_skb_to_devices(struct sk_buff *skb)
+{
+	struct lowpan_dev_record *entry;
+	struct sk_buff *skb_cp;
+	int stat = NET_RX_SUCCESS;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(entry, &lowpan_devices, list)
+		if (lowpan_dev_info(entry->ldev)->real_dev == skb->dev) {
+			skb_cp = skb_copy(skb, GFP_ATOMIC);
+			if (!skb_cp) {
+				stat = -ENOMEM;
+				break;
+			}
+
+			skb_cp->dev = entry->ldev;
+			stat = netif_rx(skb_cp);
+		}
+	rcu_read_unlock();
+
+	return stat;
+}
+
 static int lowpan_skb_deliver(struct sk_buff *skb, struct ipv6hdr *hdr)
 {
 	struct sk_buff *new;
-	struct lowpan_dev_record *entry;
 	int stat = NET_RX_SUCCESS;
 
 	new = skb_copy_expand(skb, sizeof(struct ipv6hdr), skb_tailroom(skb),
@@ -614,19 +636,7 @@ static int lowpan_skb_deliver(struct sk_buff *skb, struct ipv6hdr *hdr)
 	new->protocol = htons(ETH_P_IPV6);
 	new->pkt_type = PACKET_HOST;
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(entry, &lowpan_devices, list)
-		if (lowpan_dev_info(entry->ldev)->real_dev == new->dev) {
-			skb = skb_copy(new, GFP_ATOMIC);
-			if (!skb) {
-				stat = -ENOMEM;
-				break;
-			}
-
-			skb->dev = entry->ldev;
-			stat = netif_rx(skb);
-		}
-	rcu_read_unlock();
+	stat = lowpan_give_skb_to_devices(new);
 
 	kfree_skb(new);
 
-- 
1.7.11.2


------------------------------------------------------------------------------
Master Visual Studio, SharePoint, SQL, ASP.NET, C# 2012, HTML5, CSS,
MVC, Windows 8 Apps, JavaScript and much more. Keep your skills current
with LearnDevNow - 3,200 step-by-step video tutorials by Microsoft
MVPs and experts. ON SALE this month only -- learn more at:
http://p.sf.net/sfu/learnmore_122712
