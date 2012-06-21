From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 15/20] batman-adv: Prefix soft-interface
	non-static functions with batadv_
Date: Thu, 21 Jun 2012 18:57:51 +0200
Message-ID: <1340297876-29923-16-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

batman-adv can be compiled as part of the kernel instead of an module. In that
case the linker will see all non-static symbols of batman-adv and all other
non-static symbols of the kernel. This could lead to symbol collisions. A
prefix for the batman-adv symbols that defines their private namespace avoids
such a problem.

Reported-by: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/hard-interface.c |    8 ++++----
 net/batman-adv/routing.c        |    9 +++++----
 net/batman-adv/send.c           |    2 +-
 net/batman-adv/soft-interface.c |   16 ++++++++--------
 net/batman-adv/soft-interface.h |   13 ++++++-------
 net/batman-adv/unicast.c        |    6 +++---
 6 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 7392ae2..93acf2b 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -71,7 +71,7 @@ static int is_valid_iface(const struct net_device *net_dev)
 		return 0;
 
 	/* no batman over batman */
-	if (softif_is_valid(net_dev))
+	if (batadv_softif_is_valid(net_dev))
 		return 0;
 
 	/* Device is being bridged */
@@ -284,7 +284,7 @@ int batadv_hardif_enable_interface(struct hard_iface *hard_iface,
 	soft_iface = dev_get_by_name(&init_net, iface_name);
 
 	if (!soft_iface) {
-		soft_iface = softif_create(iface_name);
+		soft_iface = batadv_softif_create(iface_name);
 
 		if (!soft_iface) {
 			ret = -ENOMEM;
@@ -295,7 +295,7 @@ int batadv_hardif_enable_interface(struct hard_iface *hard_iface,
 		dev_hold(soft_iface);
 	}
 
-	if (!softif_is_valid(soft_iface)) {
+	if (!batadv_softif_is_valid(soft_iface)) {
 		pr_err("Can't create batman mesh interface %s: already exists as regular interface\n",
 		       soft_iface->name);
 		ret = -EINVAL;
@@ -396,7 +396,7 @@ void batadv_hardif_disable_interface(struct hard_iface *hard_iface)
 
 	/* nobody uses this interface anymore */
 	if (!bat_priv->num_ifaces)
-		softif_destroy(hard_iface->soft_iface);
+		batadv_softif_destroy(hard_iface->soft_iface);
 
 	hard_iface->soft_iface = NULL;
 	hardif_free_ref(hard_iface);
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index d7d05b2..0e98221 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -982,7 +982,8 @@ int batadv_recv_unicast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 
 	/* packet for me */
 	if (is_my_mac(unicast_packet->dest)) {
-		interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size);
+		batadv_interface_rx(recv_if->soft_iface, skb, recv_if,
+				    hdr_size);
 		return NET_RX_SUCCESS;
 	}
 
@@ -1018,8 +1019,8 @@ int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
 		if (!new_skb)
 			return NET_RX_SUCCESS;
 
-		interface_rx(recv_if->soft_iface, new_skb, recv_if,
-			     sizeof(struct unicast_packet));
+		batadv_interface_rx(recv_if->soft_iface, new_skb, recv_if,
+				    sizeof(struct unicast_packet));
 		return NET_RX_SUCCESS;
 	}
 
@@ -1104,7 +1105,7 @@ int batadv_recv_bcast_packet(struct sk_buff *skb, struct hard_iface *recv_if)
 		goto out;
 
 	/* broadcast for me */
-	interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size);
+	batadv_interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size);
 	ret = NET_RX_SUCCESS;
 	goto out;
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index bceb3d7..8226b1c 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -51,7 +51,7 @@ int batadv_send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
 	}
 
 	/* push to the ethernet header. */
-	if (my_skb_head_push(skb, ETH_HLEN) < 0)
+	if (batadv_skb_head_push(skb, ETH_HLEN) < 0)
 		goto send_skb_err;
 
 	skb_reset_mac_header(skb);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e15d474..cbc36f0 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -61,7 +61,7 @@ static const struct ethtool_ops bat_ethtool_ops = {
 	.get_sset_count = batadv_get_sset_count,
 };
 
-int my_skb_head_push(struct sk_buff *skb, unsigned int len)
+int batadv_skb_head_push(struct sk_buff *skb, unsigned int len)
 {
 	int result;
 
@@ -204,7 +204,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 		if (!primary_if)
 			goto dropped;
 
-		if (my_skb_head_push(skb, sizeof(*bcast_packet)) < 0)
+		if (batadv_skb_head_push(skb, sizeof(*bcast_packet)) < 0)
 			goto dropped;
 
 		bcast_packet = (struct bcast_packet *)skb->data;
@@ -256,9 +256,9 @@ end:
 	return NETDEV_TX_OK;
 }
 
-void interface_rx(struct net_device *soft_iface,
-		  struct sk_buff *skb, struct hard_iface *recv_if,
-		  int hdr_size)
+void batadv_interface_rx(struct net_device *soft_iface,
+			 struct sk_buff *skb, struct hard_iface *recv_if,
+			 int hdr_size)
 {
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	struct ethhdr *ethhdr;
@@ -357,7 +357,7 @@ static void interface_setup(struct net_device *dev)
 	memset(priv, 0, sizeof(*priv));
 }
 
-struct net_device *softif_create(const char *name)
+struct net_device *batadv_softif_create(const char *name)
 {
 	struct net_device *soft_iface;
 	struct bat_priv *bat_priv;
@@ -445,7 +445,7 @@ out:
 	return NULL;
 }
 
-void softif_destroy(struct net_device *soft_iface)
+void batadv_softif_destroy(struct net_device *soft_iface)
 {
 	batadv_debugfs_del_meshif(soft_iface);
 	batadv_sysfs_del_meshif(soft_iface);
@@ -453,7 +453,7 @@ void softif_destroy(struct net_device *soft_iface)
 	unregister_netdevice(soft_iface);
 }
 
-int softif_is_valid(const struct net_device *net_dev)
+int batadv_softif_is_valid(const struct net_device *net_dev)
 {
 	if (net_dev->netdev_ops->ndo_start_xmit == interface_tx)
 		return 1;
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 0203006..7e2bfaf 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -22,12 +22,11 @@
 #ifndef _NET_BATMAN_ADV_SOFT_INTERFACE_H_
 #define _NET_BATMAN_ADV_SOFT_INTERFACE_H_
 
-int my_skb_head_push(struct sk_buff *skb, unsigned int len);
-void interface_rx(struct net_device *soft_iface,
-		  struct sk_buff *skb, struct hard_iface *recv_if,
-		  int hdr_size);
-struct net_device *softif_create(const char *name);
-void softif_destroy(struct net_device *soft_iface);
-int softif_is_valid(const struct net_device *net_dev);
+int batadv_skb_head_push(struct sk_buff *skb, unsigned int len);
+void batadv_interface_rx(struct net_device *soft_iface, struct sk_buff *skb,
+			 struct hard_iface *recv_if, int hdr_size);
+struct net_device *batadv_softif_create(const char *name);
+void batadv_softif_destroy(struct net_device *soft_iface);
+int batadv_softif_is_valid(const struct net_device *net_dev);
 
 #endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index 6bb3bb9..52179c8 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -242,8 +242,8 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	memcpy(&tmp_uc, unicast_packet, uc_hdr_len);
 	skb_split(skb, frag_skb, data_len / 2 + uc_hdr_len);
 
-	if (my_skb_head_push(skb, ucf_hdr_len - uc_hdr_len) < 0 ||
-	    my_skb_head_push(frag_skb, ucf_hdr_len) < 0)
+	if (batadv_skb_head_push(skb, ucf_hdr_len - uc_hdr_len) < 0 ||
+	    batadv_skb_head_push(frag_skb, ucf_hdr_len) < 0)
 		goto drop_frag;
 
 	frag1 = (struct unicast_frag_packet *)skb->data;
@@ -314,7 +314,7 @@ find_router:
 	if (!neigh_node)
 		goto out;
 
-	if (my_skb_head_push(skb, sizeof(*unicast_packet)) < 0)
+	if (batadv_skb_head_push(skb, sizeof(*unicast_packet)) < 0)
 		goto out;
 
 	unicast_packet = (struct unicast_packet *)skb->data;
-- 
1.7.9.4
