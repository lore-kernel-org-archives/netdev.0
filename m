From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 2/7] vlan: Introduce helper functions
	to check if skb is tagged
Date: Thu, 26 Mar 2015 14:01:15 +0900
Message-ID: <1427346080-12086-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1427346080-12086-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ariel Elior <ariel.elior@qlogic.com>, Amir Vadai <amirv@mellanox.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>, Linux NICS <linux.nics@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1427346080-12086-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Separate the two checks for single vlan and multiple vlans in
netif_skb_features().  This allows us to move the check for multiple
vlans to another function later.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 include/linux/if_vlan.h | 45 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c          | 24 ++++++++----------------
 2 files changed, 53 insertions(+), 16 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index b11b28a..bc649dd 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -561,4 +561,49 @@ static inline void vlan_set_encap_proto(struct sk_buff *skb,
 		skb->protocol = htons(ETH_P_802_2);
 }
 
+/**
+ * skb_vlan_tagged - check if skb is vlan tagged.
+ * @skb: skbuff to query
+ *
+ * Returns true if the skb is tagged, regardless of whether it is hardware
+ * accelerated or not.
+ */
+static inline bool skb_vlan_tagged(struct sk_buff *skb)
+{
+	if (!skb_vlan_tag_present(skb) &&
+	    likely(skb->protocol != htons(ETH_P_8021Q) &&
+		   skb->protocol != htons(ETH_P_8021AD)))
+		return false;
+
+	return true;
+}
+
+/**
+ * skb_vlan_tagged_multi - check if skb is vlan tagged with multiple headers.
+ * @skb: skbuff to query
+ *
+ * Returns true if the skb is tagged with multiple vlan headers, regardless
+ * of whether it is hardware accelerated or not.
+ */
+static inline bool skb_vlan_tagged_multi(struct sk_buff *skb)
+{
+	__be16 protocol = skb->protocol;
+
+	if (!skb_vlan_tag_present(skb)) {
+		struct vlan_ethhdr *veh;
+
+		if (likely(protocol != htons(ETH_P_8021Q) &&
+			   protocol != htons(ETH_P_8021AD)))
+			return false;
+
+		veh = (struct vlan_ethhdr *)skb->data;
+		protocol = veh->h_vlan_encapsulated_proto;
+	}
+
+	if (protocol != htons(ETH_P_8021Q) && protocol != htons(ETH_P_8021AD))
+		return false;
+
+	return true;
+}
+
 #endif /* !(_LINUX_IF_VLAN_H_) */
diff --git a/net/core/dev.c b/net/core/dev.c
index a0408d4..04bffcd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2567,7 +2567,6 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	netdev_features_t features = dev->features;
 	u16 gso_segs = skb_shinfo(skb)->gso_segs;
-	__be16 protocol = skb->protocol;
 
 	if (gso_segs > dev->gso_max_segs || gso_segs < dev->gso_min_segs)
 		features &= ~NETIF_F_GSO_MASK;
@@ -2579,22 +2578,15 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 	if (skb->encapsulation)
 		features &= dev->hw_enc_features;
 
-	if (!skb_vlan_tag_present(skb)) {
-		if (unlikely(protocol == htons(ETH_P_8021Q) ||
-			     protocol == htons(ETH_P_8021AD))) {
-			struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
-			protocol = veh->h_vlan_encapsulated_proto;
-		} else {
-			goto finalize;
-		}
-	}
-
-	features = netdev_intersect_features(features,
-					     dev->vlan_features |
-					     NETIF_F_HW_VLAN_CTAG_TX |
-					     NETIF_F_HW_VLAN_STAG_TX);
+	if (skb_vlan_tagged(skb))
+		features = netdev_intersect_features(features,
+						     dev->vlan_features |
+						     NETIF_F_HW_VLAN_CTAG_TX |
+						     NETIF_F_HW_VLAN_STAG_TX);
+	else
+		goto finalize;
 
-	if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD))
+	if (skb_vlan_tagged_multi(skb))
 		features = netdev_intersect_features(features,
 						     NETIF_F_SG |
 						     NETIF_F_HIGHDMA |
-- 
1.8.1.2



------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
