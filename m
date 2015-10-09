From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/16] i40e: Add parsing for CEE DCBX TLVs
Date: Thu,  8 Oct 2015 18:32:42 -0700
Message-ID: <1444354374-24351-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54300 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755430AbbJIBc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:32:57 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

This patch adds parsing for CEE DCBX TLVs from the LLDP MIB.

While the driver gets the DCB CEE operational configuration from Firmware
using the "Get CEE DCBX Oper Config" AQ command there is a need to get
the CEE DesiredCfg Tx by firmware and DCB configuration Rx from peer; for
debug and other application purposes.

Change-ID: I9140edf1a25a2852c7eff805d81e5eff6266178d
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c | 179 +++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_dcb.h |  39 +++++++
 2 files changed, 218 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 9aee35d..89e60e3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -292,6 +292,182 @@ static void i40e_parse_ieee_tlv(struct i40e_lldp_org_tlv *tlv,
 }
 
 /**
+ * i40e_parse_cee_pgcfg_tlv
+ * @tlv: CEE DCBX PG CFG TLV
+ * @dcbcfg: Local store to update ETS CFG data
+ *
+ * Parses CEE DCBX PG CFG TLV
+ **/
+static void i40e_parse_cee_pgcfg_tlv(struct i40e_cee_feat_tlv *tlv,
+				     struct i40e_dcbx_config *dcbcfg)
+{
+	struct i40e_dcb_ets_config *etscfg;
+	u8 *buf = tlv->tlvinfo;
+	u16 offset = 0;
+	u8 priority;
+	int i;
+
+	etscfg = &dcbcfg->etscfg;
+
+	if (tlv->en_will_err & I40E_CEE_FEAT_TLV_WILLING_MASK)
+		etscfg->willing = 1;
+
+	etscfg->cbs = 0;
+	/* Priority Group Table (4 octets)
+	 * Octets:|    1    |    2    |    3    |    4    |
+	 *        -----------------------------------------
+	 *        |pri0|pri1|pri2|pri3|pri4|pri5|pri6|pri7|
+	 *        -----------------------------------------
+	 *   Bits:|7  4|3  0|7  4|3  0|7  4|3  0|7  4|3  0|
+	 *        -----------------------------------------
+	 */
+	for (i = 0; i < 4; i++) {
+		priority = (u8)((buf[offset] & I40E_CEE_PGID_PRIO_1_MASK) >>
+				 I40E_CEE_PGID_PRIO_1_SHIFT);
+		etscfg->prioritytable[i * 2] =  priority;
+		priority = (u8)((buf[offset] & I40E_CEE_PGID_PRIO_0_MASK) >>
+				 I40E_CEE_PGID_PRIO_0_SHIFT);
+		etscfg->prioritytable[i * 2 + 1] = priority;
+		offset++;
+	}
+
+	/* PG Percentage Table (8 octets)
+	 * Octets:| 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
+	 *        ---------------------------------
+	 *        |pg0|pg1|pg2|pg3|pg4|pg5|pg6|pg7|
+	 *        ---------------------------------
+	 */
+	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++)
+		etscfg->tcbwtable[i] = buf[offset++];
+
+	/* Number of TCs supported (1 octet) */
+	etscfg->maxtcs = buf[offset];
+}
+
+/**
+ * i40e_parse_cee_pfccfg_tlv
+ * @tlv: CEE DCBX PFC CFG TLV
+ * @dcbcfg: Local store to update PFC CFG data
+ *
+ * Parses CEE DCBX PFC CFG TLV
+ **/
+static void i40e_parse_cee_pfccfg_tlv(struct i40e_cee_feat_tlv *tlv,
+				      struct i40e_dcbx_config *dcbcfg)
+{
+	u8 *buf = tlv->tlvinfo;
+
+	if (tlv->en_will_err & I40E_CEE_FEAT_TLV_WILLING_MASK)
+		dcbcfg->pfc.willing = 1;
+
+	/* ------------------------
+	 * | PFC Enable | PFC TCs |
+	 * ------------------------
+	 * | 1 octet    | 1 octet |
+	 */
+	dcbcfg->pfc.pfcenable = buf[0];
+	dcbcfg->pfc.pfccap = buf[1];
+}
+
+/**
+ * i40e_parse_cee_app_tlv
+ * @tlv: CEE DCBX APP TLV
+ * @dcbcfg: Local store to update APP PRIO data
+ *
+ * Parses CEE DCBX APP PRIO TLV
+ **/
+static void i40e_parse_cee_app_tlv(struct i40e_cee_feat_tlv *tlv,
+				   struct i40e_dcbx_config *dcbcfg)
+{
+	u16 length, typelength, offset = 0;
+	struct i40e_cee_app_prio *app;
+	u8 i, up;
+
+	typelength = ntohs(tlv->hdr.typelen);
+	length = (u16)((typelength & I40E_LLDP_TLV_LEN_MASK) >>
+		       I40E_LLDP_TLV_LEN_SHIFT);
+
+	dcbcfg->numapps = length / sizeof(*app);
+	if (!dcbcfg->numapps)
+		return;
+
+	for (i = 0; i < dcbcfg->numapps; i++) {
+		app = (struct i40e_cee_app_prio *)(tlv->tlvinfo + offset);
+		for (up = 0; up < I40E_MAX_USER_PRIORITY; up++) {
+			if (app->prio_map & (1 << up))
+				break;
+		}
+		dcbcfg->app[i].priority = up;
+		/* Get Selector from lower 2 bits */
+		dcbcfg->app[i].selector = (app->upper_oui_sel &
+					   I40E_CEE_APP_SELECTOR_MASK);
+		dcbcfg->app[i].protocolid = ntohs(app->protocol);
+		/* Move to next app */
+		offset += sizeof(*app);
+	}
+}
+
+/**
+ * i40e_parse_cee_tlv
+ * @tlv: CEE DCBX TLV
+ * @dcbcfg: Local store to update DCBX config data
+ *
+ * Get the TLV subtype and send it to parsing function
+ * based on the subtype value
+ **/
+static void i40e_parse_cee_tlv(struct i40e_lldp_org_tlv *tlv,
+			       struct i40e_dcbx_config *dcbcfg)
+{
+	u16 len, tlvlen, sublen, typelength;
+	struct i40e_cee_feat_tlv *sub_tlv;
+	u8 subtype, feat_tlv_count = 0;
+	u32 ouisubtype;
+
+	ouisubtype = ntohl(tlv->ouisubtype);
+	subtype = (u8)((ouisubtype & I40E_LLDP_TLV_SUBTYPE_MASK) >>
+		       I40E_LLDP_TLV_SUBTYPE_SHIFT);
+	/* Return if not CEE DCBX */
+	if (subtype != I40E_CEE_DCBX_TYPE)
+		return;
+
+	typelength = ntohs(tlv->typelength);
+	tlvlen = (u16)((typelength & I40E_LLDP_TLV_LEN_MASK) >>
+			I40E_LLDP_TLV_LEN_SHIFT);
+	len = sizeof(tlv->typelength) + sizeof(ouisubtype) +
+	      sizeof(struct i40e_cee_ctrl_tlv);
+	/* Return if no CEE DCBX Feature TLVs */
+	if (tlvlen <= len)
+		return;
+
+	sub_tlv = (struct i40e_cee_feat_tlv *)((char *)tlv + len);
+	while (feat_tlv_count < I40E_CEE_MAX_FEAT_TYPE) {
+		typelength = ntohs(sub_tlv->hdr.typelen);
+		sublen = (u16)((typelength &
+				I40E_LLDP_TLV_LEN_MASK) >>
+				I40E_LLDP_TLV_LEN_SHIFT);
+		subtype = (u8)((typelength & I40E_LLDP_TLV_TYPE_MASK) >>
+				I40E_LLDP_TLV_TYPE_SHIFT);
+		switch (subtype) {
+		case I40E_CEE_SUBTYPE_PG_CFG:
+			i40e_parse_cee_pgcfg_tlv(sub_tlv, dcbcfg);
+			break;
+		case I40E_CEE_SUBTYPE_PFC_CFG:
+			i40e_parse_cee_pfccfg_tlv(sub_tlv, dcbcfg);
+			break;
+		case I40E_CEE_SUBTYPE_APP_PRI:
+			i40e_parse_cee_app_tlv(sub_tlv, dcbcfg);
+			break;
+		default:
+			return; /* Invalid Sub-type return */
+		}
+		feat_tlv_count++;
+		/* Move to next sub TLV */
+		sub_tlv = (struct i40e_cee_feat_tlv *)((char *)sub_tlv +
+						sizeof(sub_tlv->hdr.typelen) +
+						sublen);
+	}
+}
+
+/**
  * i40e_parse_org_tlv
  * @tlv: Organization specific TLV
  * @dcbcfg: Local store to update ETS REC data
@@ -312,6 +488,9 @@ static void i40e_parse_org_tlv(struct i40e_lldp_org_tlv *tlv,
 	case I40E_IEEE_8021QAZ_OUI:
 		i40e_parse_ieee_tlv(tlv, dcbcfg);
 		break;
+	case I40E_CEE_DCBX_OUI:
+		i40e_parse_cee_tlv(tlv, dcbcfg);
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.h b/drivers/net/ethernet/intel/i40e/i40e_dcb.h
index 50fc894..92d0104 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.h
@@ -44,6 +44,15 @@
 #define I40E_IEEE_SUBTYPE_PFC_CFG	11
 #define I40E_IEEE_SUBTYPE_APP_PRI	12
 
+#define I40E_CEE_DCBX_OUI		0x001b21
+#define I40E_CEE_DCBX_TYPE		2
+
+#define I40E_CEE_SUBTYPE_CTRL		1
+#define I40E_CEE_SUBTYPE_PG_CFG		2
+#define I40E_CEE_SUBTYPE_PFC_CFG	3
+#define I40E_CEE_SUBTYPE_APP_PRI	4
+
+#define I40E_CEE_MAX_FEAT_TYPE		3
 /* Defines for LLDP TLV header */
 #define I40E_LLDP_TLV_LEN_SHIFT		0
 #define I40E_LLDP_TLV_LEN_MASK		(0x01FF << I40E_LLDP_TLV_LEN_SHIFT)
@@ -98,6 +107,36 @@ struct i40e_lldp_org_tlv {
 	__be32 ouisubtype;
 	u8 tlvinfo[1];
 };
+
+struct i40e_cee_tlv_hdr {
+	__be16 typelen;
+	u8 operver;
+	u8 maxver;
+};
+
+struct i40e_cee_ctrl_tlv {
+	struct i40e_cee_tlv_hdr hdr;
+	__be32 seqno;
+	__be32 ackno;
+};
+
+struct i40e_cee_feat_tlv {
+	struct i40e_cee_tlv_hdr hdr;
+	u8 en_will_err; /* Bits: |En|Will|Err|Reserved(5)| */
+#define I40E_CEE_FEAT_TLV_ENABLE_MASK	0x80
+#define I40E_CEE_FEAT_TLV_WILLING_MASK	0x40
+#define I40E_CEE_FEAT_TLV_ERR_MASK	0x20
+	u8 subtype;
+	u8 tlvinfo[1];
+};
+
+struct i40e_cee_app_prio {
+	__be16 protocol;
+	u8 upper_oui_sel; /* Bits: |Upper OUI(6)|Selector(2)| */
+#define I40E_CEE_APP_SELECTOR_MASK	0x03
+	__be16 lower_oui;
+	u8 prio_map;
+};
 #pragma pack()
 
 i40e_status i40e_get_dcbx_status(struct i40e_hw *hw,
-- 
2.4.3
