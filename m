From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 2/4] enic: Add rq allocation failure stats
Date: Sat, 31 Jan 2015 17:58:08 +0530
Message-ID: <1422707290-939-3-git-send-email-_govind@gmx.com>
References: <1422707290-939-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com, edumazet@google.com,
	ben@decadent.org.uk, Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:53234 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002AbbAaM3T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2015 07:29:19 -0500
In-Reply-To: <1422707290-939-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds rq buff allocation failure stats.

cache_alloc_err: incremented when higher order page allocation fails.

enic_rq_alloc_buf: incremented rq buff fails. Either due to page alloc
failure or build_skb.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 2 ++
 drivers/net/ethernet/cisco/enic/enic_main.c    | 3 +++
 drivers/net/ethernet/cisco/enic/vnic_stats.h   | 2 ++
 3 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 0c396c1..3f9d91b 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -86,6 +86,8 @@ static const struct enic_stat enic_rx_stats[] = {
 
 static const struct enic_stat enic_gen_stats[] = {
 	ENIC_GEN_STAT(dma_map_error),
+	ENIC_GEN_STAT(cache_alloc_err),
+	ENIC_GEN_STAT(rq_alloc_err),
 };
 
 static const unsigned int enic_n_tx_stats = ARRAY_SIZE(enic_tx_stats);
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index d9cad93..f15687d 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -962,6 +962,7 @@ struct enic_alloc_cache *enic_page_refill(struct enic *enic, size_t sz,
 		goto no_ec;
 	ec->frag.page = alloc_pages_node(NUMA_NO_NODE, gfp_comp, order);
 	if (unlikely(!ec->frag.page)) {
+		enic->gen_stats.cache_alloc_err++;
 		order = get_order(sz);
 		ec->frag.page = alloc_pages_node(NUMA_NO_NODE, gfp, order);
 		if (!ec->frag.page)
@@ -1105,6 +1106,8 @@ static int enic_rq_alloc_buf(struct vnic_rq *rq)
 	return 0;
 
 alloc_fail:
+	enic->gen_stats.rq_alloc_err++;
+
 	return -ENOMEM;
 }
 
diff --git a/drivers/net/ethernet/cisco/enic/vnic_stats.h b/drivers/net/ethernet/cisco/enic/vnic_stats.h
index 74c81ed..b2a4528 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_stats.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_stats.h
@@ -65,6 +65,8 @@ struct vnic_rx_stats {
 /* Generic statistics */
 struct vnic_gen_stats {
 	u64 dma_map_error;
+	u64 cache_alloc_err;	/* alloc_pages(enic->order) failures */
+	u64 rq_alloc_err;	/* rq buf + skb alloc failures */
 };
 
 struct vnic_stats {
-- 
2.2.2
