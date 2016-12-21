From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next] bnx2x: ethtool -x support for rss_key
Date: Wed, 21 Dec 2016 09:48:18 -0800
Message-ID: <1482342498.8944.62.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476810487.5650.68.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480875338.18162.475.camel@edumazet-glaptop3.roam.corp.google.com>
         <BL2PR07MB2306F104F51FD4494FDC172E8D830@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Ariel Elior <ariel.elior@qlogic.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34051 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751175AbcLURsg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 12:48:36 -0500
Received: by mail-pg0-f68.google.com with SMTP id b1so17021895pgc.1
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 09:48:35 -0800 (PST)
In-Reply-To: <BL2PR07MB2306F104F51FD4494FDC172E8D830@BL2PR07MB2306.namprd07.prod.outlook.com>
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
f0:7e:81:59:c7:c9:5b:26:f7:14:7e:9e:29:01:50:99:b6:e9:8d:e1:3a:13:0c:54:71:cf:9d:72:f5:d6:c7:e0:fd:26:e2:7c:52:db:ea:e8
lpk51:~# cat /proc/sys/net/core/netdev_rss_key
f0:7e:81:59:c7:c9:5b:26:f7:14:7e:9e:29:01:50:99:b6:e9:8d:e1:3a:13:0c:54:71:cf:9d:72:f5:d6:c7:e0:fd:26:e2:7c:52:db:ea:e8:f0:89:dc:69:2f:fa:c7:71:30:a0:0c:7a

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ariel Elior <ariel.elior@qlogic.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
---
net-next is closed, merge can wait !
v3: Addressed Yuval feedback given on v2 (I hope I understood well)
v2: support CONFIG_BNX2X_SRIOV=y

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |   45 ++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c      |    9 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h      |    4 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c    |    2 
 4 files changed, 42 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 5f19427c7b278b99ee34a20b4d854e1d1293..5f31d0d52d3cdf02ded6670e032d335ac32c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -3429,6 +3429,13 @@ static u32 bnx2x_get_rxfh_indir_size(struct net_device *dev)
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
@@ -3438,23 +3445,28 @@ static int bnx2x_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 
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
+		WARN_ON_ONCE(bnx2x_get_rxfh_key_size(dev) != T_ETH_RSS_KEY * 4);
+		bnx2x_get_rss_key(&bp->rss_conf_obj, key);
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
@@ -3636,6 +3648,7 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_ethtool_stats	= bnx2x_get_ethtool_stats,
 	.get_rxnfc		= bnx2x_get_rxnfc,
 	.set_rxnfc		= bnx2x_set_rxnfc,
+	.get_rxfh_key_size	= bnx2x_get_rxfh_key_size,
 	.get_rxfh_indir_size	= bnx2x_get_rxfh_indir_size,
 	.get_rxfh		= bnx2x_get_rxfh,
 	.set_rxfh		= bnx2x_set_rxfh,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index cea6bdcde33f0be220815378142ea9e8dfc7..08ba33ccef87ba1f0d29ae4bdd48261fb901 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4538,9 +4538,11 @@ static int bnx2x_setup_rss(struct bnx2x *bp,
 	/* RSS keys */
 	if (test_bit(BNX2X_RSS_SET_SRCH, &p->rss_flags)) {
 		u8 *dst = (u8 *)(data->rss_key) + sizeof(data->rss_key);
-		const u8 *src = (const u8 *)p->rss_key;
+		const u8 *src = (const u8 *)o->rss_key;
 		int i;
 
+		/* Remember the last configuration */
+		memcpy(o->rss_key, p->rss_key, T_ETH_RSS_KEY * 4);
 		/* Apparently, bnx2x reads this array in reverse order
 		 * We need to byte swap rss_key to comply with Toeplitz specs.
 		 */
@@ -4596,6 +4598,11 @@ void bnx2x_get_rss_ind_table(struct bnx2x_rss_config_obj *rss_obj,
 	memcpy(ind_table, rss_obj->ind_table, sizeof(rss_obj->ind_table));
 }
 
+void bnx2x_get_rss_key(const struct bnx2x_rss_config_obj *rss_obj, u8 *key)
+{
+	memcpy(key, rss_obj->rss_key, T_ETH_RSS_KEY * 4);
+}
+
 int bnx2x_config_rss(struct bnx2x *bp,
 		     struct bnx2x_config_rss_params *p)
 {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 0bf2fd470819e64d2d7788b57caee6569b9b..2244107e1da103559c899b1774b815bcc0f9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -760,6 +760,8 @@ struct bnx2x_rss_config_obj {
 	/* Last configured indirection table */
 	u8			ind_table[T_ETH_INDIRECTION_TABLE_SIZE];
 
+	u32			rss_key[T_ETH_RSS_KEY];
+
 	/* flags for enabling 4-tupple hash on UDP */
 	u8			udp_rss_v4;
 	u8			udp_rss_v6;
@@ -1530,6 +1532,8 @@ int bnx2x_config_rss(struct bnx2x *bp,
 void bnx2x_get_rss_ind_table(struct bnx2x_rss_config_obj *rss_obj,
 			     u8 *ind_table);
 
+void bnx2x_get_rss_key(const struct bnx2x_rss_config_obj *rss_obj, u8 *key);
+
 #define PF_MAC_CREDIT_E2(bp, func_num)					\
 	((MAX_MAC_CREDIT_E2 - GET_NUM_VFS_PER_PATH(bp) * VF_MAC_CREDIT_CNT) / \
 	 func_num + GET_NUM_VFS_PER_PF(bp) * VF_MAC_CREDIT_CNT)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index bfae300cf25ff881292dc36ad56e51e37132..79e4e1890e94e244a72d50d76d41963a4b23 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -1985,7 +1985,7 @@ static void bnx2x_vf_mbx_update_rss(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	/* set vfop params according to rss tlv */
 	memcpy(rss.ind_table, rss_tlv->ind_table,
 	       T_ETH_INDIRECTION_TABLE_SIZE);
-	memcpy(rss.rss_key, rss_tlv->rss_key, sizeof(rss_tlv->rss_key));
+	memcpy(&vf->rss_conf_obj.rss_key, rss_tlv->rss_key, sizeof(rss_tlv->rss_key));
 	rss.rss_obj = &vf->rss_conf_obj;
 	rss.rss_result_mask = rss_tlv->rss_result_mask;
 
