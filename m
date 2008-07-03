From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 3/3] ehea: fix race condition
Date: Thu, 3 Jul 2008 15:18:51 +0100
Message-ID: <200807031618.52707.ossthema@de.ibm.com>
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
	Thomas Klein <tklein@de.ibm.com>, kamalesh@linux.vnet.ibm.com,
	hering2@de.ibm.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:36165 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271AbYGCOTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 10:19:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ehea_stop is called the function 
cancel_work_sync(&port->reset_task) is used to ensure
that the reset task is not running anymore. We need an 
additional flag to ensure that it can not be scheduled
after this call again for a certain time.


Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

---

diff -Nurp -X dontdiff linux-2.6.26-rc8/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.26-rc8/drivers/net/ehea/ehea.h	2008-07-02 16:52:13.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2008-07-02 17:01:39.000000000 +0200
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0091"
+#define DRV_VERSION	"EHEA_0092"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -478,6 +478,7 @@ struct ehea_port {
 	int num_add_tx_qps;
 	int num_mcs;
 	int resets;
+	u64 flags;
 	u64 mac_addr;
 	u32 logical_port_id;
 	u32 port_speed;
@@ -501,7 +502,8 @@ struct port_res_cfg {
 };
 
 enum ehea_flag_bits {
-	__EHEA_STOP_XFER
+	__EHEA_STOP_XFER,
+	__EHEA_DISABLE_PORT_RESET
 };
 
 void ehea_set_ethtool_ops(struct net_device *netdev);
diff -Nurp -X dontdiff linux-2.6.26-rc8/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.26-rc8/drivers/net/ehea/ehea_main.c	2008-07-02 17:01:18.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2008-07-02 17:01:39.000000000 +0200
@@ -138,6 +138,12 @@ void ehea_dump(void *adr, int len, char 
 	}
 }
 
+void ehea_schedule_port_reset(struct ehea_port *port)
+{
+	if (!test_bit(__EHEA_DISABLE_PORT_RESET, &port->flags))
+		schedule_work(&port->reset_task);
+}
+
 static void ehea_update_firmware_handles(void)
 {
 	struct ehea_fw_handle_entry *arr = NULL;
@@ -588,7 +594,7 @@ static int ehea_treat_poll_error(struct 
 				   "Resetting port.", pr->qp->init_attr.qp_nr);
 			ehea_dump(cqe, sizeof(*cqe), "CQE");
 		}
-		schedule_work(&pr->port->reset_task);
+		ehea_schedule_port_reset(pr->port);
 		return 1;
 	}
 
@@ -766,7 +772,7 @@ static struct ehea_cqe *ehea_proc_cqes(s
 			ehea_error("Send Completion Error: Resetting port");
 			if (netif_msg_tx_err(pr->port))
 				ehea_dump(cqe, sizeof(*cqe), "Send CQE");
-			schedule_work(&pr->port->reset_task);
+			ehea_schedule_port_reset(pr->port);
 			break;
 		}
 
@@ -886,7 +892,7 @@ static irqreturn_t ehea_qp_aff_irq_handl
 		eqe = ehea_poll_eq(port->qp_eq);
 	}
 
-	schedule_work(&port->reset_task);
+	ehea_schedule_port_reset(port);
 
 	return IRQ_HANDLED;
 }
@@ -2606,13 +2612,14 @@ static int ehea_stop(struct net_device *
 	if (netif_msg_ifdown(port))
 		ehea_info("disabling port %s", dev->name);
 
+	set_bit(__EHEA_DISABLE_PORT_RESET, &port->flags);
 	cancel_work_sync(&port->reset_task);
-
 	mutex_lock(&port->port_lock);
 	netif_stop_queue(dev);
 	port_napi_disable(port);
 	ret = ehea_down(dev);
 	mutex_unlock(&port->port_lock);
+	clear_bit(__EHEA_DISABLE_PORT_RESET, &port->flags);
 	return ret;
 }
 
@@ -2942,7 +2949,7 @@ static void ehea_tx_watchdog(struct net_
 
 	if (netif_carrier_ok(dev) &&
 	    !test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))
-		schedule_work(&port->reset_task);
+		ehea_schedule_port_reset(port);
 }
 
 int ehea_sense_adapter_attr(struct ehea_adapter *adapter)
