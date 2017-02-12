From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40e: Save link FEC info from link up event
Date: Sat, 11 Feb 2017 21:30:24 -0800
Message-ID: <20170212053028.98581-11-jeffrey.t.kirsher@intel.com>
References: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Cc: Henry Tieman <henry.w.tieman@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:15779 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751136AbdBLFad (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 00:30:33 -0500
In-Reply-To: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henry Tieman <henry.w.tieman@intel.com>

Store the FEC status bits from the link up event into the
hw_link_info structure.

Change-ID: I9a7b256f6dfb0dce89c2f503075d0d383526832e
Signed-off-by: Henry Tieman <henry.w.tieman@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 21 +++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h |  1 +
 4 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 1287359..fc73e4e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1838,6 +1838,8 @@ i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
 	hw_link_info->link_speed = (enum i40e_aq_link_speed)resp->link_speed;
 	hw_link_info->link_info = resp->link_info;
 	hw_link_info->an_info = resp->an_info;
+	hw_link_info->fec_info = resp->config & (I40E_AQ_CONFIG_FEC_KR_ENA |
+						 I40E_AQ_CONFIG_FEC_RS_ENA);
 	hw_link_info->ext_info = resp->ext_info;
 	hw_link_info->loopback = resp->loopback;
 	hw_link_info->max_frame_size = le16_to_cpu(resp->max_frame_size);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0f00b1a..fa4a04d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5272,6 +5272,8 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 	enum i40e_aq_link_speed new_speed;
 	char *speed = "Unknown";
 	char *fc = "Unknown";
+	char *fec = "";
+	char *an = "";
 
 	new_speed = vsi->back->hw.phy.link_info.link_speed;
 
@@ -5331,8 +5333,23 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 		break;
 	}
 
-	netdev_info(vsi->netdev, "NIC Link is Up %sbps Full Duplex, Flow Control: %s\n",
-		    speed, fc);
+	if (vsi->back->hw.phy.link_info.link_speed == I40E_LINK_SPEED_25GB) {
+		fec = ", FEC: None";
+		an = ", Autoneg: False";
+
+		if (vsi->back->hw.phy.link_info.an_info & I40E_AQ_AN_COMPLETED)
+			an = ", Autoneg: True";
+
+		if (vsi->back->hw.phy.link_info.fec_info &
+		    I40E_AQ_CONFIG_FEC_KR_ENA)
+			fec = ", FEC: CL74 FC-FEC/BASE-R";
+		else if (vsi->back->hw.phy.link_info.fec_info &
+			 I40E_AQ_CONFIG_FEC_RS_ENA)
+			fec = ", FEC: CL108 RS-FEC";
+	}
+
+	netdev_info(vsi->netdev, "NIC Link is Up, %sbps Full Duplex%s%s, Flow Control: %s\n",
+		    speed, fec, an, fc);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 9e9ae9f..939f9fd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -184,6 +184,7 @@ struct i40e_link_status {
 	enum i40e_aq_link_speed link_speed;
 	u8 link_info;
 	u8 an_info;
+	u8 fec_info;
 	u8 ext_info;
 	u8 loopback;
 	/* is Link Status Event notification to SW enabled */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 3f19dff..16bb880 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -158,6 +158,7 @@ struct i40e_link_status {
 	enum i40e_aq_link_speed link_speed;
 	u8 link_info;
 	u8 an_info;
+	u8 fec_info;
 	u8 ext_info;
 	u8 loopback;
 	/* is Link Status Event notification to SW enabled */
-- 
2.10.2
