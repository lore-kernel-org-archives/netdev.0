From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 3/7] net: Move check for multiple
	vlans to drivers
Date: Thu, 26 Mar 2015 14:01:16 +0900
Message-ID: <1427346080-12086-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

To allow drivers to handle the features check for multiple tags,
move the check to ndo_features_check().
As no drivers currently handle multiple tagged TSO, introduce
dflt_features_check() and call it if the driver does not have
ndo_features_check().

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  1 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |  1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  1 +
 include/linux/if_vlan.h                          | 22 ++++++++++++++++++++++
 net/core/dev.c                                   | 21 +++++++++------------
 5 files changed, 34 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9677431..039b0c1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12557,6 +12557,7 @@ static netdev_features_t bnx2x_features_check(struct sk_buff *skb,
 					      struct net_device *dev,
 					      netdev_features_t features)
 {
+	features = vlan_features_check(skb, features);
 	return vxlan_features_check(skb, features);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index a8339e9..ebc93a1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2373,6 +2373,7 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
 						struct net_device *dev,
 						netdev_features_t features)
 {
+	features = vlan_features_check(skb, features);
 	return vxlan_features_check(skb, features);
 }
 #endif
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index a430a34a..367f397 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -507,6 +507,7 @@ static netdev_features_t qlcnic_features_check(struct sk_buff *skb,
 					       struct net_device *dev,
 					       netdev_features_t features)
 {
+	features = vlan_features_check(skb, features);
 	return vxlan_features_check(skb, features);
 }
 #endif
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index bc649dd..5ceb38f 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -606,4 +606,26 @@ static inline bool skb_vlan_tagged_multi(struct sk_buff *skb)
 	return true;
 }
 
+/**
+ * vlan_features_check - drop unsafe features for skb with multiple tags.
+ * @skb: skbuff to query
+ * @features: features to be checked
+ *
+ * Returns features without unsafe ones if the skb has multiple tags.
+ */
+static inline netdev_features_t vlan_features_check(struct sk_buff *skb,
+						    netdev_features_t features)
+{
+	if (skb_vlan_tagged_multi(skb))
+		features = netdev_intersect_features(features,
+						     NETIF_F_SG |
+						     NETIF_F_HIGHDMA |
+						     NETIF_F_FRAGLIST |
+						     NETIF_F_GEN_CSUM |
+						     NETIF_F_HW_VLAN_CTAG_TX |
+						     NETIF_F_HW_VLAN_STAG_TX);
+
+	return features;
+}
+
 #endif /* !(_LINUX_IF_VLAN_H_) */
diff --git a/net/core/dev.c b/net/core/dev.c
index 04bffcd..41d0db55 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2562,6 +2562,13 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 	return features;
 }
 
+static netdev_features_t dflt_features_check(struct sk_buff *skb,
+					     struct net_device *dev,
+					     netdev_features_t features)
+{
+	return vlan_features_check(skb, features);
+}
+
 netdev_features_t netif_skb_features(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
@@ -2583,22 +2590,12 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 						     dev->vlan_features |
 						     NETIF_F_HW_VLAN_CTAG_TX |
 						     NETIF_F_HW_VLAN_STAG_TX);
-	else
-		goto finalize;
 
-	if (skb_vlan_tagged_multi(skb))
-		features = netdev_intersect_features(features,
-						     NETIF_F_SG |
-						     NETIF_F_HIGHDMA |
-						     NETIF_F_FRAGLIST |
-						     NETIF_F_GEN_CSUM |
-						     NETIF_F_HW_VLAN_CTAG_TX |
-						     NETIF_F_HW_VLAN_STAG_TX);
-
-finalize:
 	if (dev->netdev_ops->ndo_features_check)
 		features &= dev->netdev_ops->ndo_features_check(skb, dev,
 								features);
+	else
+		features &= dflt_features_check(skb, dev, features);
 
 	return harmonize_features(skb, features);
 }
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
