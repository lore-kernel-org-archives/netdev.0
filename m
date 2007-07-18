From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH] eHEA: Fix bonding support
Date: Wed, 18 Jul 2007 17:34:09 +0200
Message-ID: <200707181734.09278.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:51970 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333AbXGRPeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 11:34:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver didn't allow an interface's MAC address to be modified if the
respective interface wasn't setup - a failing Hcall was the result. Thus
bonding wasn't usable. The fix moves the failing Hcall which was registering
a MAC address for the reception of BC packets in firmware from the port up
and down functions to the port resources setup functions. Additionally the
missing update of the last_rx member of the netdev structure was added.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>

---
 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |   37 +++++++++++++++++++------------------
 2 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 6628fa6..489c8b2 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0070"
+#define DRV_VERSION	"EHEA_0071"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 1d1571c..4c70a93 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -466,6 +466,8 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 							 cqe->vlan_tag);
 			else
 				netif_receive_skb(skb);
+
+			dev->last_rx = jiffies;
 		} else {
 			pr->p_stats.poll_receive_errors++;
 			port_reset = ehea_treat_poll_error(pr, rq, cqe,
@@ -1433,7 +1435,8 @@ static int ehea_broadcast_reg_helper(struct ehea_port *port, u32 hcallid)
 				     port->logical_port_id,
 				     reg_type, port->mac_addr, 0, hcallid);
 	if (hret != H_SUCCESS) {
-		ehea_error("reg_dereg_bcmc failed (tagged)");
+		ehea_error("%sregistering bc address failed (tagged)",
+                           hcallid == H_REG_BCMC ? "" : "de");
 		ret = -EIO;
 		goto out_herr;
 	}
@@ -1444,7 +1447,8 @@ static int ehea_broadcast_reg_helper(struct ehea_port *port, u32 hcallid)
 				     port->logical_port_id,
 				     reg_type, port->mac_addr, 0, hcallid);
 	if (hret != H_SUCCESS) {
-		ehea_error("reg_dereg_bcmc failed (vlan)");
+		ehea_error("%sregistering bc address failed (vlan)",
+			   hcallid == H_REG_BCMC ? "" : "de");
 		ret = -EIO;
 	}
 out_herr:
@@ -2170,7 +2174,6 @@ static int ehea_up(struct net_device *dev)
 {
 	int ret, i;
 	struct ehea_port *port = netdev_priv(dev);
-	u64 mac_addr = 0;
 
 	if (port->state == EHEA_PORT_UP)
 		return 0;
@@ -2189,18 +2192,10 @@ static int ehea_up(struct net_device *dev)
 		goto out_clean_pr;
 	}
 
-	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
-	if (ret) {
-		ret = -EIO;
-		ehea_error("out_clean_pr");
-		goto out_clean_pr;
-	}
-	mac_addr = (*(u64*)dev->dev_addr) >> 16;
-
 	ret = ehea_reg_interrupts(dev);
 	if (ret) {
-		ehea_error("out_dereg_bc");
-		goto out_dereg_bc;
+		ehea_error("reg_interrupts failed. ret:%d", ret);
+		goto out_clean_pr;
 	}
 
 	for(i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
@@ -2226,9 +2221,6 @@ static int ehea_up(struct net_device *dev)
 out_free_irqs:
 	ehea_free_interrupts(dev);
 
-out_dereg_bc:
-	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
-
 out_clean_pr:
 	ehea_clean_all_portres(port);
 out:
@@ -2273,7 +2265,6 @@ static int ehea_down(struct net_device *dev)
 				&port->port_res[i].d_netdev->state))
 			msleep(1);
 
-	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	port->state = EHEA_PORT_DOWN;
 
 	ret = ehea_clean_all_portres(port);
@@ -2655,12 +2646,18 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 
 	INIT_WORK(&port->reset_task, ehea_reset_port);
 
+	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
+	if (ret) {
+		ret = -EIO;
+		goto out_unreg_port;
+	}
+
 	ehea_set_ethtool_ops(dev);
 
 	ret = register_netdev(dev);
 	if (ret) {
 		ehea_error("register_netdev failed. ret=%d", ret);
-		goto out_unreg_port;
+		goto out_dereg_bc;
 	}
 
 	ret = ehea_get_jumboframe_status(port, &jumbo);
@@ -2675,6 +2672,9 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 
 	return port;
 
+out_dereg_bc:
+	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
+
 out_unreg_port:
 	ehea_unregister_port(port);
 
@@ -2694,6 +2694,7 @@ static void ehea_shutdown_single_port(struct ehea_port *port)
 {
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
+	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	kfree(port->mc_list);
 	free_netdev(port->netdev);
 	port->adapter->active_ports--;
-- 
1.5.2




