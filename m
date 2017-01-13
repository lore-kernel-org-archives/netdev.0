From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: use fallback for selecting txq
Date: Thu, 12 Jan 2017 16:18:22 -0800
Message-ID: <20170113001822.GA10813@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0064.outbound.protection.outlook.com ([104.47.41.64]:15651
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751095AbdAMATZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 19:19:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satanand Burla <satananda.burla@cavium.com>

Remove assignment to ndo_select_queue so that fallback is used for
selecting txq.  Also remove the now-useless function that used to be
assigned to ndo_select_queue.

Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 20 --------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 21 ---------------------
 2 files changed, 41 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index cc825d5..2b89ec2 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2223,25 +2223,6 @@ static void if_cfg_callback(struct octeon_device *oct,
 	wake_up_interruptible(&ctx->wc);
 }
 
-/**
- * \brief Select queue based on hash
- * @param dev Net device
- * @param skb sk_buff structure
- * @returns selected queue number
- */
-static u16 select_q(struct net_device *dev, struct sk_buff *skb,
-		    void *accel_priv __attribute__((unused)),
-		    select_queue_fallback_t fallback __attribute__((unused)))
-{
-	u32 qindex = 0;
-	struct lio *lio;
-
-	lio = GET_LIO(dev);
-	qindex = skb_tx_hash(dev, skb);
-
-	return (u16)(qindex % (lio->linfo.num_txpciq));
-}
-
 /** Routine to push packets arriving on Octeon interface upto network layer.
  * @param oct_id   - octeon device id.
  * @param skbuff   - skbuff struct to be passed to network layer.
@@ -3755,7 +3736,6 @@ static const struct net_device_ops lionetdevops = {
 	.ndo_set_vf_vlan	= liquidio_set_vf_vlan,
 	.ndo_get_vf_config	= liquidio_get_vf_config,
 	.ndo_set_vf_link_state  = liquidio_set_vf_link_state,
-	.ndo_select_queue	= select_q
 };
 
 /** \brief Entry point for the liquidio module
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index ad2e72d..19d88fb 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1455,26 +1455,6 @@ static void if_cfg_callback(struct octeon_device *oct,
 	wake_up_interruptible(&ctx->wc);
 }
 
-/**
- * \brief Select queue based on hash
- * @param dev Net device
- * @param skb sk_buff structure
- * @returns selected queue number
- */
-static u16 select_q(struct net_device *dev, struct sk_buff *skb,
-		    void *accel_priv __attribute__((unused)),
-		    select_queue_fallback_t fallback __attribute__((unused)))
-{
-	struct lio *lio;
-	u32 qindex;
-
-	lio = GET_LIO(dev);
-
-	qindex = skb_tx_hash(dev, skb);
-
-	return (u16)(qindex % (lio->linfo.num_txpciq));
-}
-
 /** Routine to push packets arriving on Octeon interface upto network layer.
  * @param oct_id   - octeon device id.
  * @param skbuff   - skbuff struct to be passed to network layer.
@@ -2717,7 +2697,6 @@ static const struct net_device_ops lionetdevops = {
 	.ndo_set_features	= liquidio_set_features,
 	.ndo_udp_tunnel_add     = liquidio_add_vxlan_port,
 	.ndo_udp_tunnel_del     = liquidio_del_vxlan_port,
-	.ndo_select_queue	= select_q,
 };
 
 static int lio_nic_info(struct octeon_recv_info *recv_info, void *buf)
