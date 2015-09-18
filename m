From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: add ethtool support to read and change RSS
 key
Date: Fri, 18 Sep 2015 15:21:52 -0700
Message-ID: <1442614912.14037.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ariel Elior <ariel.elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33388 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbbIRWVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 18:21:55 -0400
Received: by pacex6 with SMTP id ex6so61733824pac.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 15:21:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While trying to understand why bnx2x RSS hash was not matching
Toeplitz specifications, I implemented driver code to support
ethtool -x|-X to try various RSS key combinations easily.

Then, after some debugging, I understood bnx2x was reading the rss_key
in reverse order.

If we want consistent Toeplitz hashes with different NIC, we need
to byte swap user key.

Tested:

lpk51:~# cat /proc/sys/net/core/netdev_rss_key
61:4a:0d:3e:2e:b1:30:cd:42:f5:0f:9c:a9:71:dd:1c:2f:f1:d6:60:d1:de:b2:b2:1e:bd:3c:ed:bf:84:e3:e3:d5:88:a2:12:e4:f4:4a:f6:1a:10:c0:16:b4:56:4f:aa:a4:fa:0a:b1

lpk51:~# ethtool -x eth1 | tail -2
RSS hash key:
61:4a:0d:3e:2e:b1:30:cd:42:f5:0f:9c:a9:71:dd:1c:2f:f1:d6:60:d1:de:b2:b2:1e:bd:3c:ed:bf:84:e3:e3:d5:88:a2:12:e4:f4:4a:f6

lpk51:~# ethtool -X eth1 hkey
03:0e:e2:43:fa:82:0e:73:14:2d:c0:68:21:9e:82:99:b9:84:d0:22:e2:b3:64:9f:4a:af:00:fa:cc:05:b4:4a:17:05:14:73:76:58:bd:2f

lpk51:~# ethtool -x eth1 | tail -2
RSS hash key:
03:0e:e2:43:fa:82:0e:73:14:2d:c0:68:21:9e:82:99:b9:84:d0:22:e2:b3:64:9f:4a:af:00:fa:cc:05:b4:4a:17:05:14:73:76:58:bd:2f


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Since rss_key was random, I guess there is no hurry to fix this bug in
stable kernels, and/or to split this patch in two parts.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |    7 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h     |    4 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |   77 +++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c      |   11 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h      |    5 
 5 files changed, 60 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 44173be..5f06267 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2073,7 +2073,7 @@ static int bnx2x_init_rss(struct bnx2x *bp)
 	 * For 57712 and newer on the other hand it's a per-function
 	 * configuration.
 	 */
-	return bnx2x_config_rss_eth(bp, bp->port.pmf || !CHIP_IS_E1x(bp));
+	return bnx2x_config_rss_eth(bp);
 }
 
 int bnx2x_rss(struct bnx2x *bp, struct bnx2x_rss_config_obj *rss_obj,
@@ -2122,11 +2122,8 @@ int bnx2x_rss(struct bnx2x *bp, struct bnx2x_rss_config_obj *rss_obj,
 
 	memcpy(params.ind_table, rss_obj->ind_table, sizeof(params.ind_table));
 
-	if (config_hash) {
-		/* RSS keys */
-		netdev_rss_key_fill(params.rss_key, T_ETH_RSS_KEY * 4);
+	if (config_hash)
 		__set_bit(BNX2X_RSS_SET_SRCH, &params.rss_flags);
-	}
 
 	if (IS_PF(bp))
 		return bnx2x_config_rss(bp, &params);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index b7d32e8..c5d6cce 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -913,8 +913,10 @@ static inline int func_by_vn(struct bnx2x *bp, int vn)
 	return 2 * vn + BP_PORT(bp);
 }
 
-static inline int bnx2x_config_rss_eth(struct bnx2x *bp, bool config_hash)
+static inline int bnx2x_config_rss_eth(struct bnx2x *bp)
 {
+	bool config_hash = bp->port.pmf || !CHIP_IS_E1x(bp);
+
 	return bnx2x_rss(bp, &bp->rss_conf_obj, config_hash, true);
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index aeb7ce6..0c613fa 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -3419,6 +3419,11 @@ static u32 bnx2x_get_rxfh_indir_size(struct net_device *dev)
 	return T_ETH_INDIRECTION_TABLE_SIZE;
 }
 
+static u32 bnx2x_get_rxfh_key_size(struct net_device *dev)
+{
+	return T_ETH_RSS_KEY * 4;
+}
+
 static int bnx2x_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 			  u8 *hfunc)
 {
@@ -3428,24 +3433,25 @@ static int bnx2x_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 
 	if (hfunc)
 		*hfunc = ETH_RSS_HASH_TOP;
-	if (!indir)
-		return 0;
+	if (indir) {
 
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
+		/* Get the current configuration of the RSS indirection table */
+		bnx2x_get_rss_ind_table(&bp->rss_conf_obj, ind_table);
 
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
+	if (key)
+		memcpy(key, bp->rss_conf_obj.rss_key, T_ETH_RSS_KEY * 4);
 	return 0;
 }
 
@@ -3453,32 +3459,34 @@ static int bnx2x_set_rxfh(struct net_device *dev, const u32 *indir,
 			  const u8 *key, const u8 hfunc)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	size_t i;
 
 	/* We require at least one supported parameter to be changed and no
 	 * change in any of the unsupported parameters
 	 */
-	if (key ||
-	    (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP))
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
 
-	if (!indir)
-		return 0;
-
-	for (i = 0; i < T_ETH_INDIRECTION_TABLE_SIZE; i++) {
-		/*
-		 * The same as in bnx2x_get_rxfh: we can't use a memcpy()
-		 * as an internal storage of an indirection table is a u8 array
-		 * while indir->ring_index points to an array of u32.
-		 *
-		 * Indirection table contains the FW Client IDs, so we need to
-		 * align the received table to the Client ID of the leading RSS
-		 * queue
-		 */
-		bp->rss_conf_obj.ind_table[i] = indir[i] + bp->fp->cl_id;
+	if (indir) {
+		size_t i;
+
+		for (i = 0; i < T_ETH_INDIRECTION_TABLE_SIZE; i++) {
+			/*
+			 * The same as in bnx2x_get_rxfh: we can't use a memcpy()
+			 * as an internal storage of an indirection table is a u8 array
+			 * while indir->ring_index points to an array of u32.
+			 *
+			 * Indirection table contains the FW Client IDs, so we need to
+			 * align the received table to the Client ID of the leading RSS
+			 * queue
+			 */
+			bp->rss_conf_obj.ind_table[i] = indir[i] + bp->fp->cl_id;
+		}
 	}
 
-	return bnx2x_config_rss_eth(bp, false);
+	if (key)
+		memcpy(bp->rss_conf_obj.rss_key, key, T_ETH_RSS_KEY * 4);
+
+	return bnx2x_config_rss_eth(bp);
 }
 
 /**
@@ -3627,6 +3635,7 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_rxnfc		= bnx2x_get_rxnfc,
 	.set_rxnfc		= bnx2x_set_rxnfc,
 	.get_rxfh_indir_size	= bnx2x_get_rxfh_indir_size,
+	.get_rxfh_key_size	= bnx2x_get_rxfh_key_size,
 	.get_rxfh		= bnx2x_get_rxfh,
 	.set_rxfh		= bnx2x_set_rxfh,
 	.get_channels		= bnx2x_get_channels,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index c9bd7f1..90d2a2f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4319,8 +4319,14 @@ static int bnx2x_setup_rss(struct bnx2x *bp,
 
 	/* RSS keys */
 	if (test_bit(BNX2X_RSS_SET_SRCH, &p->rss_flags)) {
-		memcpy(&data->rss_key[0], &p->rss_key[0],
-		       sizeof(data->rss_key));
+		u8 *dst = (u8 *)(data->rss_key) + sizeof(data->rss_key);
+		const u8 *src = (const u8 *)bp->rss_conf_obj.rss_key;
+		int i;
+
+		/* Apparently, bnx2x reads this array in reverse order */
+		for (i = 0; i < sizeof(data->rss_key); i++)
+			*--dst = *src++;
+
 		caps |= ETH_RSS_UPDATE_RAMROD_DATA_UPDATE_RSS_KEY;
 	}
 
@@ -4408,6 +4414,7 @@ void bnx2x_init_rss_config_obj(struct bnx2x *bp,
 	bnx2x_init_raw_obj(&rss_obj->raw, cl_id, cid, func_id, rdata,
 			   rdata_mapping, state, pstate, type);
 
+	netdev_rss_key_fill(rss_obj->rss_key, sizeof(rss_obj->rss_key));
 	rss_obj->engine_id  = engine_id;
 	rss_obj->config_rss = bnx2x_setup_rss;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 4048fc5..6431979 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -734,8 +734,6 @@ struct bnx2x_config_rss_params {
 	/* Indirection table */
 	u8		ind_table[T_ETH_INDIRECTION_TABLE_SIZE];
 
-	/* RSS hash values */
-	u32		rss_key[10];
 
 	/* valid only iff BNX2X_RSS_UPDATE_TOE is set */
 	u16		toe_rss_bitmap;
@@ -754,6 +752,9 @@ struct bnx2x_rss_config_obj {
 	u8			udp_rss_v4;
 	u8			udp_rss_v6;
 
+	/* RSS hash values */
+	u32		rss_key[T_ETH_RSS_KEY];
+
 	int (*config_rss)(struct bnx2x *bp,
 			  struct bnx2x_config_rss_params *p);
 };
