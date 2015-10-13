From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/17] i40e: Convert CEE App TLV selector to IEEE selector
Date: Mon, 12 Oct 2015 22:53:07 -0700
Message-ID: <1444715598-20970-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Bowers <gregory.j.bowers@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2285 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042AbbJMFx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:26 -0400
In-Reply-To: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Bowers <gregory.j.bowers@intel.com>

Changes the parsing of CEE App TLVs to fill in the App selector in struct
i40e_dcbx_config with the IEEE App selector so the caller doesn't have to
consider whether the App came from a CEE or IEEE DCBX negotiation.

Change-ID: Ia7d9d664cde04d2ebcc9822fd22e4929c6edab3a
Signed-off-by: Greg Bowers <gregory.j.bowers@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_dcb.c  | 16 ++++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_type.h |  2 ++
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
index 251a841..2691277 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
@@ -380,7 +380,7 @@ static void i40e_parse_cee_app_tlv(struct i40e_cee_feat_tlv *tlv,
 {
 	u16 length, typelength, offset = 0;
 	struct i40e_cee_app_prio *app;
-	u8 i, up;
+	u8 i, up, selector;
 
 	typelength = ntohs(tlv->hdr.typelen);
 	length = (u16)((typelength & I40E_LLDP_TLV_LEN_MASK) >>
@@ -397,9 +397,17 @@ static void i40e_parse_cee_app_tlv(struct i40e_cee_feat_tlv *tlv,
 				break;
 		}
 		dcbcfg->app[i].priority = up;
-		/* Get Selector from lower 2 bits */
-		dcbcfg->app[i].selector = (app->upper_oui_sel &
-					   I40E_CEE_APP_SELECTOR_MASK);
+
+		/* Get Selector from lower 2 bits, and convert to IEEE */
+		selector = (app->upper_oui_sel & I40E_CEE_APP_SELECTOR_MASK);
+		if (selector == I40E_CEE_APP_SEL_ETHTYPE)
+			dcbcfg->app[i].selector = I40E_APP_SEL_ETHTYPE;
+		else if (selector == I40E_CEE_APP_SEL_TCPIP)
+			dcbcfg->app[i].selector = I40E_APP_SEL_TCPIP;
+		else
+			/* Keep selector as it is for unknown types */
+			dcbcfg->app[i].selector = selector;
+
 		dcbcfg->app[i].protocolid = ntohs(app->protocol);
 		/* Move to next app */
 		offset += sizeof(*app);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index c8f7a52..4ec3ffa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -418,6 +418,8 @@ struct i40e_fc_info {
 #define I40E_APP_PROTOID_FIP		0x8914
 #define I40E_APP_SEL_ETHTYPE		0x1
 #define I40E_APP_SEL_TCPIP		0x2
+#define I40E_CEE_APP_SEL_ETHTYPE	0x0
+#define I40E_CEE_APP_SEL_TCPIP		0x1
 
 /* CEE or IEEE 802.1Qaz ETS Configuration data */
 struct i40e_dcb_ets_config {
-- 
2.4.3
