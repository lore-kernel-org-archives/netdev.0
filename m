From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] bnx2x: ethtool -x full support
Date: Sun, 04 Dec 2016 10:15:38 -0800
Message-ID: <1480875338.18162.475.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476810487.5650.68.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Ariel Elior <ariel.elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35898 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbcLDSPk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 13:15:40 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so13885533pgx.3
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 10:15:40 -0800 (PST)
In-Reply-To: <1476810487.5650.68.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Implement ethtool -x full support, so that rss key can be fetched
instead of assuming it matches /proc/sys/net/core/netdev_rss_key
content.

We might add "ethtool --rxfh" support later to set a different rss key.

Tested:

lpk51:~# ethtool --show-rxfh eth0 | grep -A1 'hash key'
RSS hash key:
8b:a9:3a:ff:3e:f8:44:bd:5a:44:b7:b5:6d:e8:2d:f0:f0:72:98:54:03:86:8f:39:a4:42:5a:b3:84:71:5c:4f:1c:18:d6:a3:04:68:85:ac
lpk51:~# cat /proc/sys/net/core/netdev_rss_key
8b:a9:3a:ff:3e:f8:44:bd:5a:44:b7:b5:6d:e8:2d:f0:f0:72:98:54:03:86:8f:39:a4:42:5a:b3:84:71:5c:4f:1c:18:d6:a3:04:68:85:ac:22:1f:50:76:d4:c8:a5:20:7b:61:3c:0c

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ariel Elior <ariel.elior@qlogic.com>
---
v2: support CONFIG_BNX2X_SRIOV=y

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |    2 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |   47 ++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c      |    2 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h      |    5 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c    |    5 -
 5 files changed, 38 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index ed42c1009685..28af24ae0092 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2106,7 +2106,7 @@ int bnx2x_rss(struct bnx2x *bp, struct bnx2x_rss_config_obj *rss_obj,
 
 	if (config_hash) {
 		/* RSS keys */
-		netdev_rss_key_fill(params.rss_key, T_ETH_RSS_KEY * 4);
+		netdev_rss_key_fill(&rss_obj->rss_key, T_ETH_RSS_KEY * 4);
 		__set_bit(BNX2X_RSS_SET_SRCH, &params.rss_flags);
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 85a7800bfc12..28bc9479fc74 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -3421,6 +3421,13 @@ static u32 bnx2x_get_rxfh_indir_size(struct net_device *dev)
 	return T_ETH_INDIRECTION_TABLE_SIZE;
 }
 
+static u32 bnx2x_get_rxfh_key_size(struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+
+	return (bp->port.pmf || !CHIP_IS_E1x(bp)) ? T_ETH_RSS_KEY * 4 : 0;
+}
+
 static int bnx2x_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 			  u8 *hfunc)
 {
@@ -3430,23 +3437,30 @@ static int bnx2x_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 
 	if (hfunc)
 		*hfunc = ETH_RSS_HASH_TOP;
-	if (!indir)
-		return 0;
 
-	/* Get the current configuration of the RSS indirection table */
-	bnx2x_get_rss_ind_table(&bp->rss_conf_obj, ind_table);
-
-	/*
-	 * We can't use a memcpy() as an internal storage of an
-	 * indirection table is a u8 array while indir->ring_index
-	 * points to an array of u32.
-	 *
-	 * Indirection table contains the FW Client IDs, so we need to
-	 * align the returned table to the Client ID of the leading RSS
-	 * queue.
-	 */
-	for (i = 0; i < T_ETH_INDIRECTION_TABLE_SIZE; i++)
-		indir[i] = ind_table[i] - bp->fp->cl_id;
+	if (key) {
+		if (bp->port.pmf || !CHIP_IS_E1x(bp))
+			memcpy(key, &bp->rss_conf_obj.rss_key, T_ETH_RSS_KEY * 4);
+		else
+			memset(key, 0, T_ETH_RSS_KEY * 4);
+	}
+
+	if (indir) {
+		/* Get the current configuration of the RSS indirection table */
+		bnx2x_get_rss_ind_table(&bp->rss_conf_obj, ind_table);
+
+		/*
+		 * We can't use a memcpy() as an internal storage of an
+		 * indirection table is a u8 array while indir->ring_index
+		 * points to an array of u32.
+		 *
+		 * Indirection table contains the FW Client IDs, so we need to
+		 * align the returned table to the Client ID of the leading RSS
+		 * queue.
+		 */
+		for (i = 0; i < T_ETH_INDIRECTION_TABLE_SIZE; i++)
+			indir[i] = ind_table[i] - bp->fp->cl_id;
+	}
 
 	return 0;
 }
@@ -3628,6 +3642,7 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_ethtool_stats	= bnx2x_get_ethtool_stats,
 	.get_rxnfc		= bnx2x_get_rxnfc,
 	.set_rxnfc		= bnx2x_set_rxnfc,
+	.get_rxfh_key_size	= bnx2x_get_rxfh_key_size,
 	.get_rxfh_indir_size	= bnx2x_get_rxfh_indir_size,
 	.get_rxfh		= bnx2x_get_rxfh,
 	.set_rxfh		= bnx2x_set_rxfh,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index cea6bdcde33f..3b1becc23160 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4538,7 +4538,7 @@ static int bnx2x_setup_rss(struct bnx2x *bp,
 	/* RSS keys */
 	if (test_bit(BNX2X_RSS_SET_SRCH, &p->rss_flags)) {
 		u8 *dst = (u8 *)(data->rss_key) + sizeof(data->rss_key);
-		const u8 *src = (const u8 *)p->rss_key;
+		const u8 *src = (const u8 *)o->rss_key;
 		int i;
 
 		/* Apparently, bnx2x reads this array in reverse order
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 0bf2fd470819..0092991796d3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -744,9 +744,6 @@ struct bnx2x_config_rss_params {
 	/* Indirection table */
 	u8		ind_table[T_ETH_INDIRECTION_TABLE_SIZE];
 
-	/* RSS hash values */
-	u32		rss_key[10];
-
 	/* valid only iff BNX2X_RSS_UPDATE_TOE is set */
 	u16		toe_rss_bitmap;
 };
@@ -760,6 +757,8 @@ struct bnx2x_rss_config_obj {
 	/* Last configured indirection table */
 	u8			ind_table[T_ETH_INDIRECTION_TABLE_SIZE];
 
+	u32     rss_key[T_ETH_RSS_KEY];
+
 	/* flags for enabling 4-tupple hash on UDP */
 	u8			udp_rss_v4;
 	u8			udp_rss_v6;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index bfae300cf25f..9a8f36f12b07 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -811,7 +811,8 @@ int bnx2x_vfpf_config_rss(struct bnx2x *bp,
 		      sizeof(struct channel_list_end_tlv));
 
 	memcpy(req->ind_table, params->ind_table, T_ETH_INDIRECTION_TABLE_SIZE);
-	memcpy(req->rss_key, params->rss_key, sizeof(params->rss_key));
+	memcpy(req->rss_key, params->rss_obj->rss_key,
+	       sizeof(params->rss_obj->rss_key));
 	req->ind_table_size = T_ETH_INDIRECTION_TABLE_SIZE;
 	req->rss_key_size = T_ETH_RSS_KEY;
 	req->rss_result_mask = params->rss_result_mask;
@@ -1985,7 +1986,7 @@ static void bnx2x_vf_mbx_update_rss(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	/* set vfop params according to rss tlv */
 	memcpy(rss.ind_table, rss_tlv->ind_table,
 	       T_ETH_INDIRECTION_TABLE_SIZE);
-	memcpy(rss.rss_key, rss_tlv->rss_key, sizeof(rss_tlv->rss_key));
+	memcpy(&vf->rss_conf_obj.rss_key, rss_tlv->rss_key, sizeof(rss_tlv->rss_key));
 	rss.rss_obj = &vf->rss_conf_obj;
 	rss.rss_result_mask = rss_tlv->rss_result_mask;
 
