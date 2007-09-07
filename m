From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 1/2][RESEND] ehea: propagate physical port state
Date: Fri, 7 Sep 2007 12:30:17 +0200
Message-ID: <200709071230.18395.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:63201 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965073AbXIGKad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 06:30:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduces a module parameter to decide whether the physical
port link state is propagated to the network stack or not.
It makes sense not to take the physical port state into account
on machines with more logical partitions that communicate
with each other. This is always possible no matter what the physical
port state is. Thus eHEA can be considered as a switch there.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---
 drivers/net/ehea/ehea.h      |    5 ++++-
 drivers/net/ehea/ehea_main.c |   14 +++++++++++++-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index d67f97b..8d58be5 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0073"
+#define DRV_VERSION	"EHEA_0074"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -402,6 +402,8 @@ struct ehea_mc_list {
 
 #define EHEA_PORT_UP 1
 #define EHEA_PORT_DOWN 0
+#define EHEA_PHY_LINK_UP 1
+#define EHEA_PHY_LINK_DOWN 0
 #define EHEA_MAX_PORT_RES 16
 struct ehea_port {
 	struct ehea_adapter *adapter;	 /* adapter that owns this port */
@@ -427,6 +429,7 @@ struct ehea_port {
 	u32 msg_enable;
 	u32 sig_comp_iv;
 	u32 state;
+	u8 phy_link;
 	u8 full_duplex;
 	u8 autoneg;
 	u8 num_def_qps;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index db57474..1e9fd6f 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -53,17 +53,21 @@ static int rq3_entries = EHEA_DEF_ENTRIES_RQ3;
 static int sq_entries = EHEA_DEF_ENTRIES_SQ;
 static int use_mcs = 0;
 static int num_tx_qps = EHEA_NUM_TX_QP;
+static int prop_carrier_state = 0;
 
 module_param(msg_level, int, 0);
 module_param(rq1_entries, int, 0);
 module_param(rq2_entries, int, 0);
 module_param(rq3_entries, int, 0);
 module_param(sq_entries, int, 0);
+module_param(prop_carrier_state, int, 0);
 module_param(use_mcs, int, 0);
 module_param(num_tx_qps, int, 0);
 
 MODULE_PARM_DESC(num_tx_qps, "Number of TX-QPS");
 MODULE_PARM_DESC(msg_level, "msg_level");
+MODULE_PARM_DESC(prop_carrier_state, "Propagate carrier state of physical "
+		 "port to stack. 1:yes, 0:no.  Default = 0 ");
 MODULE_PARM_DESC(rq3_entries, "Number of entries for Receive Queue 3 "
 		 "[2^x - 1], x = [6..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_RQ3) ")");
@@ -814,7 +818,9 @@ int ehea_set_portspeed(struct ehea_port *port, u32 port_speed)
 			ehea_error("Failed setting port speed");
 		}
 	}
-	netif_carrier_on(port->netdev);
+	if (!prop_carrier_state || (port->phy_link == EHEA_PHY_LINK_UP))
+		netif_carrier_on(port->netdev);
+
 	kfree(cb4);
 out:
 	return ret;
@@ -869,13 +875,19 @@ static void ehea_parse_eqe(struct ehea_adapter *adapter, u64 eqe)
 			}
 
 		if (EHEA_BMASK_GET(NEQE_EXTSWITCH_PORT_UP, eqe)) {
+			port->phy_link = EHEA_PHY_LINK_UP;
 			if (netif_msg_link(port))
 				ehea_info("%s: Physical port up",
 					  port->netdev->name);
+			if (prop_carrier_state)
+				netif_carrier_on(port->netdev);
 		} else {
+			port->phy_link = EHEA_PHY_LINK_DOWN;
 			if (netif_msg_link(port))
 				ehea_info("%s: Physical port down",
 					  port->netdev->name);
+			if (prop_carrier_state)
+				netif_carrier_off(port->netdev);
 		}
 
 		if (EHEA_BMASK_GET(NEQE_EXTSWITCH_PRIMARY, eqe))
-- 
1.5.2

