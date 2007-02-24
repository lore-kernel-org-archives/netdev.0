From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 5/6] S2IO: Avoid printing the Enhanced statistics for Xframe
 I card.
Date: Sat, 24 Feb 2007 02:03:22 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10702240201380.3434-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, sreenivasa.honnur@neterion.com,
	ramkrishna.vepa@neterion.com, santosh.rastapur@neterion.com,
	alicia.pena@neterion.com, sriram.rapuru@neterion.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:45803 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933404AbXBXHDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 02:03:24 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Enhanced Statistics are supported only for Xframe II (Herculas) card. Add 
  condition check such Enhanced statistics will included only in the case of
  Xframe II card.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN patch4/drivers/net/s2io.c patch5/drivers/net/s2io.c
--- patch4/drivers/net/s2io.c	2007-02-21 15:22:13.000000000 +0530
+++ patch5/drivers/net/s2io.c	2007-02-21 15:23:00.000000000 +0530
@@ -139,7 +139,7 @@ static char s2io_gstrings[][ETH_GSTRING_
 	"BIST Test\t(offline)"
 };
 
-static char ethtool_stats_keys[][ETH_GSTRING_LEN] = {
+static char ethtool_xena_stats_keys[][ETH_GSTRING_LEN] = {
 	{"tmac_frms"},
 	{"tmac_data_octets"},
 	{"tmac_drop_frms"},
@@ -233,7 +233,10 @@ static char ethtool_stats_keys[][ETH_GST
 	{"rxd_rd_cnt"},
 	{"rxd_wr_cnt"},
 	{"txf_rd_cnt"},
-	{"rxf_wr_cnt"},
+	{"rxf_wr_cnt"}
+};
+
+static char ethtool_enhanced_stats_keys[][ETH_GSTRING_LEN] = {
 	{"rmac_ttl_1519_4095_frms"},
 	{"rmac_ttl_4096_8191_frms"},
 	{"rmac_ttl_8192_max_frms"},
@@ -249,7 +252,10 @@ static char ethtool_stats_keys[][ETH_GST
 	{"rmac_red_discard"},
 	{"rmac_rts_discard"},
 	{"rmac_ingm_full_discard"},
-	{"link_fault_cnt"},
+	{"link_fault_cnt"}
+};
+
+static char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
 	{"\n DRIVER STATISTICS"},
 	{"single_bit_ecc_errs"},
 	{"double_bit_ecc_errs"},
@@ -277,8 +283,16 @@ static char ethtool_stats_keys[][ETH_GST
 	("lro_avg_aggr_pkts"),
 };
 
-#define S2IO_STAT_LEN sizeof(ethtool_stats_keys)/ ETH_GSTRING_LEN
-#define S2IO_STAT_STRINGS_LEN S2IO_STAT_LEN * ETH_GSTRING_LEN
+#define S2IO_XENA_STAT_LEN sizeof(ethtool_xena_stats_keys)/ ETH_GSTRING_LEN
+#define S2IO_ENHANCED_STAT_LEN sizeof(ethtool_enhanced_stats_keys)/ \
+					ETH_GSTRING_LEN
+#define S2IO_DRIVER_STAT_LEN sizeof(ethtool_driver_stats_keys)/ ETH_GSTRING_LEN
+
+#define XFRAME_I_STAT_LEN (S2IO_XENA_STAT_LEN + S2IO_DRIVER_STAT_LEN )
+#define XFRAME_II_STAT_LEN (XFRAME_I_STAT_LEN + S2IO_ENHANCED_STAT_LEN )
+
+#define XFRAME_I_STAT_STRINGS_LEN ( XFRAME_I_STAT_LEN * ETH_GSTRING_LEN )
+#define XFRAME_II_STAT_STRINGS_LEN ( XFRAME_II_STAT_LEN * ETH_GSTRING_LEN )
 
 #define S2IO_TEST_LEN	sizeof(s2io_gstrings) / ETH_GSTRING_LEN
 #define S2IO_STRINGS_LEN	S2IO_TEST_LEN * ETH_GSTRING_LEN
@@ -4609,7 +4623,11 @@ static void s2io_ethtool_gdrvinfo(struct
 	info->regdump_len = XENA_REG_SPACE;
 	info->eedump_len = XENA_EEPROM_SPACE;
 	info->testinfo_len = S2IO_TEST_LEN;
-	info->n_stats = S2IO_STAT_LEN;
+
+	if (sp->device_type == XFRAME_I_DEVICE)
+		info->n_stats = XFRAME_I_STAT_LEN;
+	else
+		info->n_stats = XFRAME_II_STAT_LEN;
 }
 
 /**
@@ -5631,22 +5649,30 @@ static void s2io_get_ethtool_stats(struc
 	tmp_stats[i++] = le32_to_cpu(stat_info->rxd_wr_cnt);
 	tmp_stats[i++] = le32_to_cpu(stat_info->txf_rd_cnt);
 	tmp_stats[i++] = le32_to_cpu(stat_info->rxf_wr_cnt);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_1519_4095_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_4096_8191_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_8192_max_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_gt_max_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_osized_alt_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_jabber_alt_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_gt_max_alt_frms);
-        tmp_stats[i++] = le64_to_cpu(stat_info->rmac_vlan_frms);
-        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_len_discard);
-        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_fcs_discard);
-        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_pf_discard);
-        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_da_discard);
-        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_red_discard);
-        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_rts_discard);
-        tmp_stats[i++] = le32_to_cpu(stat_info->rmac_ingm_full_discard);
-        tmp_stats[i++] = le32_to_cpu(stat_info->link_fault_cnt);
+
+	/* Enhanced statistics exist only for Hercules */
+	if(sp->device_type == XFRAME_II_DEVICE) {
+		tmp_stats[i++] =
+				le64_to_cpu(stat_info->rmac_ttl_1519_4095_frms);
+		tmp_stats[i++] =
+				le64_to_cpu(stat_info->rmac_ttl_4096_8191_frms);
+		tmp_stats[i++] =
+				le64_to_cpu(stat_info->rmac_ttl_8192_max_frms);
+		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_gt_max_frms);
+		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_osized_alt_frms);
+		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_jabber_alt_frms);
+		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_gt_max_alt_frms);
+		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_vlan_frms);
+		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_len_discard);
+		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_fcs_discard);
+		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_pf_discard);
+		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_da_discard);
+		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_red_discard);
+		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_rts_discard);
+		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_ingm_full_discard);
+		tmp_stats[i++] = le32_to_cpu(stat_info->link_fault_cnt);
+	}
+
 	tmp_stats[i++] = 0;
 	tmp_stats[i++] = stat_info->sw_stat.single_ecc_errs;
 	tmp_stats[i++] = stat_info->sw_stat.double_ecc_errs;
@@ -5726,18 +5752,42 @@ static int s2io_ethtool_self_test_count(
 static void s2io_ethtool_get_strings(struct net_device *dev,
 				     u32 stringset, u8 * data)
 {
+	int stat_size = 0;
+	struct s2io_nic *sp = dev->priv;
+
 	switch (stringset) {
 	case ETH_SS_TEST:
 		memcpy(data, s2io_gstrings, S2IO_STRINGS_LEN);
 		break;
 	case ETH_SS_STATS:
-		memcpy(data, &ethtool_stats_keys,
-		       sizeof(ethtool_stats_keys));
+		stat_size = sizeof(ethtool_xena_stats_keys);
+		memcpy(data, &ethtool_xena_stats_keys,stat_size);
+		if(sp->device_type == XFRAME_II_DEVICE) {
+			memcpy(data + stat_size,
+				&ethtool_enhanced_stats_keys,
+				sizeof(ethtool_enhanced_stats_keys));
+			stat_size += sizeof(ethtool_enhanced_stats_keys);
+		}
+
+		memcpy(data + stat_size, &ethtool_driver_stats_keys,
+			sizeof(ethtool_driver_stats_keys));
 	}
 }
 static int s2io_ethtool_get_stats_count(struct net_device *dev)
 {
-	return (S2IO_STAT_LEN);
+	struct s2io_nic *sp = dev->priv;
+	int stat_count = 0;
+	switch(sp->device_type) {
+	case XFRAME_I_DEVICE:
+		stat_count = XFRAME_I_STAT_LEN;
+	break;
+
+	case XFRAME_II_DEVICE:
+		stat_count = XFRAME_II_STAT_LEN;
+	break;
+	}
+
+	return stat_count;
 }
 
 static int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)

