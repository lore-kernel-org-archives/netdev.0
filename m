From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: 25G FEC status improvements
Date: Sun, 27 Aug 2017 17:15:56 -0700
Message-ID: <20170828001603.75876-9-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Mariusz Stachura <mariusz.stachura@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:39313 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751674AbdH1AQT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:19 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mariusz Stachura <mariusz.stachura@intel.com>

This patch improves the system log message. The log message will
be expanded to include the FEC mode the FW requested before link
was established.

Signed-off-by: Mariusz Stachura <mariusz.stachura@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3a6a752c6c58..5a06cd23b9e6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5354,6 +5354,7 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 	char *speed = "Unknown";
 	char *fc = "Unknown";
 	char *fec = "";
+	char *req_fec = "";
 	char *an = "";
 
 	new_speed = vsi->back->hw.phy.link_info.link_speed;
@@ -5415,6 +5416,7 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 	}
 
 	if (vsi->back->hw.phy.link_info.link_speed == I40E_LINK_SPEED_25GB) {
+		req_fec = ", Requested FEC: None";
 		fec = ", FEC: None";
 		an = ", Autoneg: False";
 
@@ -5427,10 +5429,22 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 		else if (vsi->back->hw.phy.link_info.fec_info &
 			 I40E_AQ_CONFIG_FEC_RS_ENA)
 			fec = ", FEC: CL108 RS-FEC";
+
+		/* 'CL108 RS-FEC' should be displayed when RS is requested, or
+		 * both RS and FC are requested
+		 */
+		if (vsi->back->hw.phy.link_info.req_fec_info &
+		    (I40E_AQ_REQUEST_FEC_KR | I40E_AQ_REQUEST_FEC_RS)) {
+			if (vsi->back->hw.phy.link_info.req_fec_info &
+			    I40E_AQ_REQUEST_FEC_RS)
+				req_fec = ", Requested FEC: CL108 RS-FEC";
+			else
+				req_fec = ", Requested FEC: CL74 FC-FEC/BASE-R";
+		}
 	}
 
-	netdev_info(vsi->netdev, "NIC Link is Up, %sbps Full Duplex%s%s, Flow Control: %s\n",
-		    speed, fec, an, fc);
+	netdev_info(vsi->netdev, "NIC Link is Up, %sbps Full Duplex%s%s%s, Flow Control: %s\n",
+		    speed, req_fec, fec, an, fc);
 }
 
 /**
-- 
2.14.1
