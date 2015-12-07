From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 1/1] cxgb3: Convert simple_strtoul to kstrtox
Date: Mon,  7 Dec 2015 14:11:33 +0100
Message-ID: <1449493893-18055-2-git-send-email-clabbe.montjoie@gmail.com>
References: <1449493893-18055-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: santosh@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449493893-18055-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the simple_strtoul function is obsolete. This patch replace it by
kstrtox.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c | 14 +++++++------
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c      | 28 ++++++++++++++++++-------
 2 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 8f7aa53..60908ea 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -701,15 +701,16 @@ static ssize_t attr_store(struct device *d,
 			  ssize_t(*set) (struct net_device *, unsigned int),
 			  unsigned int min_val, unsigned int max_val)
 {
-	char *endp;
 	ssize_t ret;
 	unsigned int val;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	val = simple_strtoul(buf, &endp, 0);
-	if (endp == buf || val < min_val || val > max_val)
+	ret = kstrtouint(buf, 0, &val);
+	if (ret)
+		return ret;
+	if (val < min_val || val > max_val)
 		return -EINVAL;
 
 	rtnl_lock();
@@ -829,14 +830,15 @@ static ssize_t tm_attr_store(struct device *d,
 	struct port_info *pi = netdev_priv(to_net_dev(d));
 	struct adapter *adap = pi->adapter;
 	unsigned int val;
-	char *endp;
 	ssize_t ret;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	val = simple_strtoul(buf, &endp, 0);
-	if (endp == buf || val > 10000000)
+	ret = kstrtouint(buf, 0, &val);
+	if (ret)
+		return ret;
+	if (val > 10000000)
 		return -EINVAL;
 
 	rtnl_lock();
diff --git a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
index a22768c..ee04caa 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
@@ -709,11 +709,21 @@ static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 			return ret;
 	}
 
-	p->cclk = simple_strtoul(vpd.cclk_data, NULL, 10);
-	p->mclk = simple_strtoul(vpd.mclk_data, NULL, 10);
-	p->uclk = simple_strtoul(vpd.uclk_data, NULL, 10);
-	p->mdc = simple_strtoul(vpd.mdc_data, NULL, 10);
-	p->mem_timing = simple_strtoul(vpd.mt_data, NULL, 10);
+	ret = kstrtouint(vpd.cclk_data, 10, &p->cclk);
+	if (ret)
+		return ret;
+	ret = kstrtouint(vpd.mclk_data, 10, &p->mclk);
+	if (ret)
+		return ret;
+	ret = kstrtouint(vpd.uclk_data, 10, &p->uclk);
+	if (ret)
+		return ret;
+	ret = kstrtouint(vpd.mdc_data, 10, &p->mdc);
+	if (ret)
+		return ret;
+	ret = kstrtouint(vpd.mt_data, 10, &p->mem_timing);
+	if (ret)
+		return ret;
 	memcpy(p->sn, vpd.sn_data, SERNUM_LEN);
 
 	/* Old eeproms didn't have port information */
@@ -723,8 +733,12 @@ static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	} else {
 		p->port_type[0] = hex_to_bin(vpd.port0_data[0]);
 		p->port_type[1] = hex_to_bin(vpd.port1_data[0]);
-		p->xauicfg[0] = simple_strtoul(vpd.xaui0cfg_data, NULL, 16);
-		p->xauicfg[1] = simple_strtoul(vpd.xaui1cfg_data, NULL, 16);
+		ret = kstrtou16(vpd.xaui0cfg_data, 16, &p->xauicfg[0]);
+		if (ret)
+			return ret;
+		ret = kstrtou16(vpd.xaui1cfg_data, 16, &p->xauicfg[1]);
+		if (ret)
+			return ret;
 	}
 
 	ret = hex2bin(p->eth_base, vpd.na_data, 6);
-- 
2.4.10
