From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/6] net: dsa: add uses_hw_tag
Date: Wed,  7 Oct 2015 19:48:26 -0400
Message-ID: <1444261711-1829-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of checking that the dsa_switch_tree rcv pointer is not NULL,
add a uses_hw_tag boolean to net_device to explicit whether it uses
hardware inserted tag or not.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/linux/netdevice.h | 6 ++++--
 include/net/dsa.h         | 5 -----
 net/dsa/dsa.c             | 1 +
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b337440..73f0510 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1422,6 +1422,7 @@ enum netdev_priv_flags {
  *	@allmulti:		Counter, enables or disables allmulticast mode
  *
  *	@vlan_info:	VLAN info
+ *	@uses_hw_tag:	Whether the device uses hardware inserted tag or not
  *	@dsa_ptr:	dsa specific data
  *	@tipc_ptr:	TIPC specific data
  *	@atalk_ptr:	AppleTalk link
@@ -1640,6 +1641,7 @@ struct net_device {
 	struct vlan_info __rcu	*vlan_info;
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA)
+	bool uses_hw_tag;
 	struct dsa_switch_tree	*dsa_ptr;
 #endif
 #if IS_ENABLED(CONFIG_TIPC)
@@ -1891,8 +1893,8 @@ void dev_net_set(struct net_device *dev, struct net *net)
 static inline bool netdev_uses_dsa(struct net_device *dev)
 {
 #if IS_ENABLED(CONFIG_NET_DSA)
-	if (dev->dsa_ptr != NULL)
-		return dsa_uses_tagged_protocol(dev->dsa_ptr);
+	if (dev->uses_hw_tag)
+		return true;
 #endif
 	return false;
 }
diff --git a/include/net/dsa.h b/include/net/dsa.h
index b34d812..3e9eb6c 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -333,9 +333,4 @@ static inline void *ds_to_priv(struct dsa_switch *ds)
 {
 	return (void *)(ds + 1);
 }
-
-static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
-{
-	return dst->rcv != NULL;
-}
 #endif
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index aa398bc..51b3815 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -834,6 +834,7 @@ static void dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	 */
 	wmb();
 	dev->dsa_ptr = (void *)dst;
+	dev->uses_hw_tag = dst->tag_protocol != DSA_TAG_PROTO_NONE;
 
 	if (dst->link_poll_needed) {
 		INIT_WORK(&dst->link_poll_work, dsa_link_poll_work);
-- 
2.6.0
