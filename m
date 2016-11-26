From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 08/10] net/mlx5e: Add support for loopback selftest
Date: Sat, 26 Nov 2016 16:18:32 +0200
Message-ID: <1480169914-22347-9-git-send-email-saeedm@mellanox.com>
References: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Kamal Heib <kamalh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41850 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751634AbcKZOTb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 09:19:31 -0500
In-Reply-To: <1480169914-22347-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the self diagnostic tests to support loopback test.

The loopback test doesn't require the offline flag, it will use the
generic dev_queue_xmit and a dedicated packet_type to capture and verify
mlx5e selftest loopback packets.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Kamal Heib <kamalh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   3 +-
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |   7 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   2 +-
 .../net/ethernet/mellanox/mlx5/core/en_selftest.c  | 218 +++++++++++++++++++++
 4 files changed, 227 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index f7bb4a7..9cf32d3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -885,7 +885,8 @@ void mlx5e_destroy_tir(struct mlx5_core_dev *mdev,
 		       struct mlx5e_tir *tir);
 int mlx5e_create_mdev_resources(struct mlx5_core_dev *mdev);
 void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev);
-int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5_core_dev *mdev);
+int mlx5e_refresh_tirs_self_loopback(struct mlx5_core_dev *mdev,
+				     bool enable_uc_lb);
 
 struct mlx5_eswitch_rep;
 int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
index 029e856..f175518 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
@@ -137,7 +137,8 @@ void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev)
 	mlx5_unmap_free_uar(mdev, &res->cq_uar);
 }
 
-int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5_core_dev *mdev)
+int mlx5e_refresh_tirs_self_loopback(struct mlx5_core_dev *mdev,
+				     bool enable_uc_lb)
 {
 	struct mlx5e_tir *tir;
 	void *in;
@@ -149,6 +150,10 @@ int mlx5e_refresh_tirs_self_loopback_enable(struct mlx5_core_dev *mdev)
 	if (!in)
 		return -ENOMEM;
 
+	if (enable_uc_lb)
+		MLX5_SET(modify_tir_in, in, ctx.self_lb_block,
+			 MLX5_TIRC_SELF_LB_BLOCK_BLOCK_UNICAST_);
+
 	MLX5_SET(modify_tir_in, in, bitmask.self_lb_en, 1);
 
 	list_for_each_entry(tir, &mdev->mlx5e_res.td.tirs_list, list) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f5b93c2..89d5c65 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2136,7 +2136,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 		goto err_clear_state_opened_flag;
 	}
 
-	err = mlx5e_refresh_tirs_self_loopback_enable(priv->mdev);
+	err = mlx5e_refresh_tirs_self_loopback(priv->mdev, false);
 	if (err) {
 		netdev_err(netdev, "%s: mlx5e_refresh_tirs_self_loopback_enable failed, %d\n",
 			   __func__, err);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
index a25dfc5..a823054 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c
@@ -30,12 +30,16 @@
  * SOFTWARE.
  */
 
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <net/udp.h>
 #include "en.h"
 
 enum {
 	MLX5E_ST_LINK_STATE,
 	MLX5E_ST_LINK_SPEED,
 	MLX5E_ST_HEALTH_INFO,
+	MLX5E_ST_LOOPBACK,
 	MLX5E_ST_NUM,
 };
 
@@ -43,6 +47,7 @@ const char mlx5e_self_tests[MLX5E_ST_NUM][ETH_GSTRING_LEN] = {
 	"Link Test",
 	"Speed Test",
 	"Health Test",
+	"Loopback Test",
 };
 
 int mlx5e_self_test_num(struct mlx5e_priv *priv)
@@ -88,10 +93,223 @@ static int mlx5e_test_link_speed(struct mlx5e_priv *priv)
 	return 1;
 }
 
+/* loopback test */
+#define MLX5E_TEST_PKT_SIZE (MLX5_MPWRQ_SMALL_PACKET_THRESHOLD - NET_IP_ALIGN)
+static const char mlx5e_test_text[ETH_GSTRING_LEN] = "MLX5E SELF TEST";
+#define MLX5E_TEST_MAGIC 0x5AEED15C001
+
+struct mlx5ehdr {
+	__be32 version;
+	__be64 magic;
+	char   text[ETH_GSTRING_LEN];
+};
+
+static struct sk_buff *mlx5e_test_get_udp_skb(struct mlx5e_priv *priv)
+{
+	struct sk_buff *skb = NULL;
+	struct mlx5ehdr *mlxh;
+	struct ethhdr *ethh;
+	struct udphdr *udph;
+	struct iphdr *iph;
+	int datalen, iplen;
+
+	datalen = MLX5E_TEST_PKT_SIZE -
+		  (sizeof(*ethh) + sizeof(*iph) + sizeof(*udph));
+
+	skb = netdev_alloc_skb(priv->netdev, MLX5E_TEST_PKT_SIZE);
+	if (!skb) {
+		netdev_err(priv->netdev, "\tFailed to alloc loopback skb\n");
+		return NULL;
+	}
+
+	prefetchw(skb->data);
+	skb_reserve(skb, NET_IP_ALIGN);
+
+	/*  Reserve for ethernet and IP header  */
+	ethh = (struct ethhdr *)skb_push(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);
+
+	skb_set_network_header(skb, skb->len);
+	iph = (struct iphdr *)skb_put(skb, sizeof(struct iphdr));
+
+	skb_set_transport_header(skb, skb->len);
+	udph = (struct udphdr *)skb_put(skb, sizeof(struct udphdr));
+
+	/* Fill ETH header */
+	ether_addr_copy(ethh->h_dest, priv->netdev->dev_addr);
+	eth_zero_addr(ethh->h_source);
+	ethh->h_proto = htons(ETH_P_IP);
+
+	/* Fill UDP header */
+	udph->source = htons(9);
+	udph->dest = htons(9); /* Discard Protocol */
+	udph->len = htons(datalen + sizeof(struct udphdr));
+	udph->check = 0;
+
+	/* Fill IP header */
+	iph->ihl = 5;
+	iph->ttl = 32;
+	iph->version = 4;
+	iph->protocol = IPPROTO_UDP;
+	iplen = sizeof(struct iphdr) + sizeof(struct udphdr) + datalen;
+	iph->tot_len = htons(iplen);
+	iph->frag_off = 0;
+	iph->saddr = 0;
+	iph->daddr = 0;
+	iph->tos = 0;
+	iph->id = 0;
+	ip_send_check(iph);
+
+	/* Fill test header and data */
+	mlxh = (struct mlx5ehdr *)skb_put(skb, sizeof(*mlxh));
+	mlxh->version = 0;
+	mlxh->magic = cpu_to_be64(MLX5E_TEST_MAGIC);
+	strlcpy(mlxh->text, mlx5e_test_text, sizeof(mlxh->text));
+	datalen -= sizeof(*mlxh);
+	memset(skb_put(skb, datalen), 0, datalen);
+
+	skb->csum = 0;
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	udp4_hwcsum(skb, iph->saddr, iph->daddr);
+
+	skb->protocol = htons(ETH_P_IP);
+	skb->pkt_type = PACKET_HOST;
+	skb->dev = priv->netdev;
+
+	return skb;
+}
+
+struct mlx5e_lbt_priv {
+	struct packet_type pt;
+	struct completion comp;
+	bool loopback_ok;
+};
+
+static int
+mlx5e_test_loopback_validate(struct sk_buff *skb,
+			     struct net_device *ndev,
+			     struct packet_type *pt,
+			     struct net_device *orig_ndev)
+{
+	struct mlx5e_lbt_priv *lbtp = pt->af_packet_priv;
+	struct mlx5ehdr *mlxh;
+	struct ethhdr *ethh;
+	struct udphdr *udph;
+	struct iphdr *iph;
+
+	/* We are only going to peek, no need to clone the SKB */
+	if (skb->protocol != htons(ETH_P_IP))
+		goto out;
+
+	if (MLX5E_TEST_PKT_SIZE - ETH_HLEN > skb_headlen(skb))
+		goto out;
+
+	ethh = (struct ethhdr *)skb_mac_header(skb);
+	if (!ether_addr_equal(ethh->h_dest, orig_ndev->dev_addr))
+		goto out;
+
+	iph = ip_hdr(skb);
+	if (iph->protocol != IPPROTO_UDP)
+		goto out;
+
+	udph = udp_hdr(skb);
+	if (udph->dest != htons(9))
+		goto out;
+
+	mlxh = (struct mlx5ehdr *)((char *)udph + sizeof(*udph));
+	if (mlxh->magic != cpu_to_be64(MLX5E_TEST_MAGIC))
+		goto out; /* so close ! */
+
+	/* bingo */
+	lbtp->loopback_ok = true;
+	complete(&lbtp->comp);
+out:
+	kfree_skb(skb);
+	return 0;
+}
+
+static int mlx5e_test_loopback_setup(struct mlx5e_priv *priv,
+				     struct mlx5e_lbt_priv *lbtp)
+{
+	int err = 0;
+
+	err = mlx5e_refresh_tirs_self_loopback(priv->mdev, true);
+	if (err) {
+		netdev_err(priv->netdev,
+			   "\tFailed to enable UC loopback err(%d)\n", err);
+		return err;
+	}
+
+	lbtp->loopback_ok = false;
+	init_completion(&lbtp->comp);
+
+	lbtp->pt.type = htons(ETH_P_ALL);
+	lbtp->pt.func = mlx5e_test_loopback_validate;
+	lbtp->pt.dev = priv->netdev;
+	lbtp->pt.af_packet_priv = lbtp;
+	dev_add_pack(&lbtp->pt);
+	return err;
+}
+
+static void mlx5e_test_loopback_cleanup(struct mlx5e_priv *priv,
+					struct mlx5e_lbt_priv *lbtp)
+{
+	dev_remove_pack(&lbtp->pt);
+	mlx5e_refresh_tirs_self_loopback(priv->mdev, false);
+}
+
+#define MLX5E_LB_VERIFY_TIMEOUT (msecs_to_jiffies(200))
+static int mlx5e_test_loopback(struct mlx5e_priv *priv)
+{
+	struct mlx5e_lbt_priv *lbtp;
+	struct sk_buff *skb = NULL;
+	int err;
+
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		netdev_err(priv->netdev,
+			   "\tCan't perform loobpack test while device is down\n");
+		return -ENODEV;
+	}
+
+	lbtp = kzalloc(sizeof(*lbtp), GFP_KERNEL);
+	if (!lbtp)
+		return -ENOMEM;
+	lbtp->loopback_ok = false;
+
+	err = mlx5e_test_loopback_setup(priv, lbtp);
+	if (err)
+		goto out;
+
+	skb = mlx5e_test_get_udp_skb(priv);
+	if (!skb) {
+		err = -ENOMEM;
+		goto cleanup;
+	}
+
+	skb_set_queue_mapping(skb, 0);
+	err = dev_queue_xmit(skb);
+	if (err) {
+		netdev_err(priv->netdev,
+			   "\tFailed to xmit loopback packet err(%d)\n",
+			   err);
+		goto cleanup;
+	}
+
+	wait_for_completion_timeout(&lbtp->comp, MLX5E_LB_VERIFY_TIMEOUT);
+	err = !lbtp->loopback_ok;
+
+cleanup:
+	mlx5e_test_loopback_cleanup(priv, lbtp);
+out:
+	kfree(lbtp);
+	return err;
+}
+
 int (*mlx5e_st_func[MLX5E_ST_NUM])(struct mlx5e_priv *) = {
 	mlx5e_test_link_state,
 	mlx5e_test_link_speed,
 	mlx5e_test_health_info,
+	mlx5e_test_loopback
 };
 
 void mlx5e_self_test(struct net_device *ndev, struct ethtool_test *etest,
-- 
2.7.4
