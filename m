From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 1/1] cxgb3: fix up vpd strings for kstrto*()
Date: Wed, 17 Feb 2016 12:36:37 -0800
Message-ID: <20160217233126.E0815E0753@smtp.ogc.us>
Cc: santosh@chelsio.com, davem@davemloft.net, hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:47164 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030368AbcBQXb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 18:31:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vpd strings are left justified, in a fixed length array, with possible
trailing white space and no NUL.  So fix them up before calling kstrto*().

This is a recent regression which causes cxgb3 to fail to load.

Fixes:e72c932('cxgb3: Convert simple_strtoul to kstrtox')

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c | 32 +++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
index ee04caa..bfd4a7f 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
@@ -681,6 +681,24 @@ int t3_seeprom_wp(struct adapter *adapter, int enable)
 	return t3_seeprom_write(adapter, EEPROM_STAT_ADDR, enable ? 0xc : 0);
 }
 
+static int vpdstrtouint(char *s, int len, unsigned int base, unsigned int *val)
+{
+	char tok[len+1];
+
+	memcpy(tok, s, len);
+	tok[len] = 0;
+	return kstrtouint(strim(tok), base, val);
+}
+
+static int vpdstrtou16(char *s, int len, unsigned int base, u16 *val)
+{
+	char tok[len+1];
+
+	memcpy(tok, s, len);
+	tok[len] = 0;
+	return kstrtou16(strim(tok), base, val);
+}
+
 /**
  *	get_vpd_params - read VPD parameters from VPD EEPROM
  *	@adapter: adapter to read
@@ -709,19 +727,19 @@ static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 			return ret;
 	}
 
-	ret = kstrtouint(vpd.cclk_data, 10, &p->cclk);
+	ret = vpdstrtouint(vpd.cclk_data, vpd.cclk_len, 10, &p->cclk);
 	if (ret)
 		return ret;
-	ret = kstrtouint(vpd.mclk_data, 10, &p->mclk);
+	ret = vpdstrtouint(vpd.mclk_data, vpd.mclk_len, 10, &p->mclk);
 	if (ret)
 		return ret;
-	ret = kstrtouint(vpd.uclk_data, 10, &p->uclk);
+	ret = vpdstrtouint(vpd.uclk_data, vpd.uclk_len, 10, &p->uclk);
 	if (ret)
 		return ret;
-	ret = kstrtouint(vpd.mdc_data, 10, &p->mdc);
+	ret = vpdstrtouint(vpd.mdc_data, vpd.mdc_len, 10, &p->mdc);
 	if (ret)
 		return ret;
-	ret = kstrtouint(vpd.mt_data, 10, &p->mem_timing);
+	ret = vpdstrtouint(vpd.mt_data, vpd.mt_len, 10, &p->mem_timing);
 	if (ret)
 		return ret;
 	memcpy(p->sn, vpd.sn_data, SERNUM_LEN);
@@ -733,10 +751,10 @@ static int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	} else {
 		p->port_type[0] = hex_to_bin(vpd.port0_data[0]);
 		p->port_type[1] = hex_to_bin(vpd.port1_data[0]);
-		ret = kstrtou16(vpd.xaui0cfg_data, 16, &p->xauicfg[0]);
+		ret = vpdstrtou16(vpd.xaui0cfg_data, vpd.xaui0cfg_len, 16, &p->xauicfg[0]);
 		if (ret)
 			return ret;
-		ret = kstrtou16(vpd.xaui1cfg_data, 16, &p->xauicfg[1]);
+		ret = vpdstrtou16(vpd.xaui1cfg_data, vpd.xaui1cfg_len, 16, &p->xauicfg[1]);
 		if (ret)
 			return ret;
 	}
-- 
2.7.0
