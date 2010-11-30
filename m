From: Joe Perches <joe@perches.com>
Subject: [net-next PATCH V2] ehea: Use the standard logging functions
Date: Tue, 30 Nov 2010 10:18:44 -0800
Message-ID: <1291141124.18026.254.camel@Joe-Laptop>
References: <1290790908.11971.303.camel@Joe-Laptop>
	 <1290792387-12331-1-git-send-email-leitao@linux.vnet.ibm.com>
	 <1290814046.11971.320.camel@Joe-Laptop>
	 <4CF52E7C.7010308@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2011 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755491Ab0K3SSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 13:18:46 -0500
In-Reply-To: <4CF52E7C.7010308@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove ehea_error, ehea_info and ehea_debug macros.
Use pr_fmt, pr_<level>, netdev_<level> and netif_<level> as appropriate.
Fix messages to use trailing "\n", some messages had an extra one
as the old ehea_<level> macros added a trailing "\n".
Coalesced long format strings.

Uncompiled/untested.

Signed-off-by: Joe Perches <joe@perches.com>

---

v2: Update to current net-next

 drivers/net/ehea/ehea.h         |   13 --
 drivers/net/ehea/ehea_ethtool.c |   18 +-
 drivers/net/ehea/ehea_main.c    |  407 +++++++++++++++++++--------------------
 drivers/net/ehea/ehea_phyp.c    |   40 ++--
 drivers/net/ehea/ehea_qmr.c     |   89 +++++-----
 5 files changed, 274 insertions(+), 293 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 8e745e7..45e709f 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -130,19 +130,6 @@
 
 /* utility functions */
 
-#define ehea_info(fmt, args...) \
-	printk(KERN_INFO DRV_NAME ": " fmt "\n", ## args)
-
-#define ehea_error(fmt, args...) \
-	printk(KERN_ERR DRV_NAME ": Error in %s: " fmt "\n", __func__, ## args)
-
-#ifdef DEBUG
-#define ehea_debug(fmt, args...) \
-	printk(KERN_DEBUG DRV_NAME ": " fmt, ## args)
-#else
-#define ehea_debug(fmt, args...) do {} while (0)
-#endif
-
 void ehea_dump(void *adr, int len, char *msg);
 
 #define EHEA_BMASK(pos, length) (((pos) << 16) + (length))
diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index 75b099c..273fedb 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -26,6 +26,8 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ehea.h"
 #include "ehea_phyp.h"
 
@@ -118,10 +120,10 @@ doit:
 	ret = ehea_set_portspeed(port, sp);
 
 	if (!ret)
-		ehea_info("%s: Port speed successfully set: %dMbps "
-			  "%s Duplex",
-			  port->netdev->name, port->port_speed,
-			  port->full_duplex == 1 ? "Full" : "Half");
+		netdev_info(dev,
+			    "Port speed successfully set: %dMbps %s Duplex\n",
+			    port->port_speed,
+			    port->full_duplex == 1 ? "Full" : "Half");
 out:
 	return ret;
 }
@@ -134,10 +136,10 @@ static int ehea_nway_reset(struct net_device *dev)
 	ret = ehea_set_portspeed(port, EHEA_SPEED_AUTONEG);
 
 	if (!ret)
-		ehea_info("%s: Port speed successfully set: %dMbps "
-			  "%s Duplex",
-			  port->netdev->name, port->port_speed,
-			  port->full_duplex == 1 ? "Full" : "Half");
+		netdev_info(port->netdev,
+			    "Port speed successfully set: %dMbps %s Duplex\n",
+			    port->port_speed,
+			    port->full_duplex == 1 ? "Full" : "Half");
 	return ret;
 }
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index a84c389..f700c76 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -26,6 +26,8 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
@@ -136,8 +138,8 @@ void ehea_dump(void *adr, int len, char *msg)
 	int x;
 	unsigned char *deb = adr;
 	for (x = 0; x < len; x += 16) {
-		printk(DRV_NAME " %s adr=%p ofs=%04x %016llx %016llx\n", msg,
-			  deb, x, *((u64 *)&deb[0]), *((u64 *)&deb[8]));
+		pr_info("%s adr=%p ofs=%04x %016llx %016llx\n",
+			msg, deb, x, *((u64 *)&deb[0]), *((u64 *)&deb[8]));
 		deb += 16;
 	}
 }
@@ -337,7 +339,7 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 
 	cb2 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb2) {
-		ehea_error("no mem for cb2");
+		netdev_err(dev, "no mem for cb2\n");
 		goto out;
 	}
 
@@ -345,7 +347,7 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 				      port->logical_port_id,
 				      H_PORT_CB2, H_PORT_CB2_ALL, cb2);
 	if (hret != H_SUCCESS) {
-		ehea_error("query_ehea_port failed");
+		netdev_err(dev, "query_ehea_port failed\n");
 		goto out_herr;
 	}
 
@@ -461,8 +463,9 @@ static int ehea_refill_rq_def(struct ehea_port_res *pr,
 		if (!skb) {
 			q_skba->os_skbs = fill_wqes - i;
 			if (q_skba->os_skbs == q_skba->len - 2) {
-				ehea_info("%s: rq%i ran dry - no mem for skb",
-					  pr->port->netdev->name, rq_nr);
+				netdev_info(pr->port->netdev,
+					    "rq%i ran dry - no mem for skb\n",
+					    rq_nr);
 				ret = -ENOMEM;
 			}
 			break;
@@ -627,8 +630,8 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 
 	if (cqe->status & EHEA_CQE_STAT_FAT_ERR_MASK) {
 		if (netif_msg_rx_err(pr->port)) {
-			ehea_error("Critical receive error for QP %d. "
-				   "Resetting port.", pr->qp->init_attr.qp_nr);
+			pr_err("Critical receive error for QP %d. Resetting port.\n",
+			       pr->qp->init_attr.qp_nr);
 			ehea_dump(cqe, sizeof(*cqe), "CQE");
 		}
 		ehea_schedule_port_reset(pr->port);
@@ -730,8 +733,8 @@ static int ehea_proc_rwqes(struct net_device *dev,
 							  skb_arr_rq1_len,
 							  wqe_index);
 				if (unlikely(!skb)) {
-					if (netif_msg_rx_err(port))
-						ehea_error("LL rq1: skb=NULL");
+					netif_err(port, rx_err, dev,
+						  "LL rq1: skb=NULL\n");
 
 					skb = netdev_alloc_skb(dev,
 							       EHEA_L_PKT_SIZE);
@@ -746,8 +749,8 @@ static int ehea_proc_rwqes(struct net_device *dev,
 				skb = get_skb_by_index(skb_arr_rq2,
 						       skb_arr_rq2_len, cqe);
 				if (unlikely(!skb)) {
-					if (netif_msg_rx_err(port))
-						ehea_error("rq2: skb=NULL");
+					netif_err(port, rx_err, dev,
+						  "rq2: skb=NULL\n");
 					break;
 				}
 				ehea_fill_skb(dev, skb, cqe);
@@ -757,8 +760,8 @@ static int ehea_proc_rwqes(struct net_device *dev,
 				skb = get_skb_by_index(skb_arr_rq3,
 						       skb_arr_rq3_len, cqe);
 				if (unlikely(!skb)) {
-					if (netif_msg_rx_err(port))
-						ehea_error("rq3: skb=NULL");
+					netif_err(port, rx_err, dev,
+						  "rq3: skb=NULL\n");
 					break;
 				}
 				ehea_fill_skb(dev, skb, cqe);
@@ -830,7 +833,7 @@ static void check_sqs(struct ehea_port *port)
 					 msecs_to_jiffies(100));
 
 		if (!ret) {
-			ehea_error("HW/SW queues out of sync");
+			pr_err("HW/SW queues out of sync\n");
 			ehea_schedule_port_reset(pr->port);
 			return;
 		}
@@ -863,14 +866,14 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 		}
 
 		if (cqe->status & EHEA_CQE_STAT_ERR_MASK) {
-			ehea_error("Bad send completion status=0x%04X",
-				   cqe->status);
+			pr_err("Bad send completion status=0x%04X\n",
+			       cqe->status);
 
 			if (netif_msg_tx_err(pr->port))
 				ehea_dump(cqe, sizeof(*cqe), "Send CQE");
 
 			if (cqe->status & EHEA_CQE_STAT_RESET_MASK) {
-				ehea_error("Resetting port");
+				pr_err("Resetting port\n");
 				ehea_schedule_port_reset(pr->port);
 				break;
 			}
@@ -988,8 +991,8 @@ static irqreturn_t ehea_qp_aff_irq_handler(int irq, void *param)
 
 	while (eqe) {
 		qp_token = EHEA_BMASK_GET(EHEA_EQE_QP_TOKEN, eqe->entry);
-		ehea_error("QP aff_err: entry=0x%llx, token=0x%x",
-			   eqe->entry, qp_token);
+		pr_err("QP aff_err: entry=0x%llx, token=0x%x\n",
+		       eqe->entry, qp_token);
 
 		qp = port->port_res[qp_token].qp;
 
@@ -1007,7 +1010,7 @@ static irqreturn_t ehea_qp_aff_irq_handler(int irq, void *param)
 	}
 
 	if (reset_port) {
-		ehea_error("Resetting port");
+		pr_err("Resetting port\n");
 		ehea_schedule_port_reset(port);
 	}
 
@@ -1035,7 +1038,7 @@ int ehea_sense_port_attr(struct ehea_port *port)
 	/* may be called via ehea_neq_tasklet() */
 	cb0 = (void *)get_zeroed_page(GFP_ATOMIC);
 	if (!cb0) {
-		ehea_error("no mem for cb0");
+		pr_err("no mem for cb0\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -1127,7 +1130,7 @@ int ehea_set_portspeed(struct ehea_port *port, u32 port_speed)
 
 	cb4 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb4) {
-		ehea_error("no mem for cb4");
+		pr_err("no mem for cb4\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -1178,16 +1181,16 @@ int ehea_set_portspeed(struct ehea_port *port, u32 port_speed)
 				break;
 			}
 		} else {
-			ehea_error("Failed sensing port speed");
+			pr_err("Failed sensing port speed\n");
 			ret = -EIO;
 		}
 	} else {
 		if (hret == H_AUTHORITY) {
-			ehea_info("Hypervisor denied setting port speed");
+			pr_info("Hypervisor denied setting port speed\n");
 			ret = -EPERM;
 		} else {
 			ret = -EIO;
-			ehea_error("Failed setting port speed");
+			pr_err("Failed setting port speed\n");
 		}
 	}
 	if (!prop_carrier_state || (port->phy_link == EHEA_PHY_LINK_UP))
@@ -1204,80 +1207,78 @@ static void ehea_parse_eqe(struct ehea_adapter *adapter, u64 eqe)
 	u8 ec;
 	u8 portnum;
 	struct ehea_port *port;
+	struct net_device *dev;
 
 	ec = EHEA_BMASK_GET(NEQE_EVENT_CODE, eqe);
 	portnum = EHEA_BMASK_GET(NEQE_PORTNUM, eqe);
 	port = ehea_get_port(adapter, portnum);
+	dev = port->netdev;
 
 	switch (ec) {
 	case EHEA_EC_PORTSTATE_CHG:	/* port state change */
 
 		if (!port) {
-			ehea_error("unknown portnum %x", portnum);
+			netdev_err(dev, "unknown portnum %x\n", portnum);
 			break;
 		}
 
 		if (EHEA_BMASK_GET(NEQE_PORT_UP, eqe)) {
-			if (!netif_carrier_ok(port->netdev)) {
+			if (!netif_carrier_ok(dev)) {
 				ret = ehea_sense_port_attr(port);
 				if (ret) {
-					ehea_error("failed resensing port "
-						   "attributes");
+					netdev_err(dev, "failed resensing port attributes\n");
 					break;
 				}
 
-				if (netif_msg_link(port))
-					ehea_info("%s: Logical port up: %dMbps "
-						  "%s Duplex",
-						  port->netdev->name,
-						  port->port_speed,
-						  port->full_duplex ==
-						  1 ? "Full" : "Half");
+				netif_info(port, link, dev,
+					   "Logical port up: %dMbps %s Duplex\n",
+					   port->port_speed,
+					   port->full_duplex == 1 ?
+					   "Full" : "Half");
 
-				netif_carrier_on(port->netdev);
-				netif_wake_queue(port->netdev);
+				netif_carrier_on(dev);
+				netif_wake_queue(dev);
 			}
 		} else
-			if (netif_carrier_ok(port->netdev)) {
-				if (netif_msg_link(port))
-					ehea_info("%s: Logical port down",
-						  port->netdev->name);
-				netif_carrier_off(port->netdev);
-				netif_stop_queue(port->netdev);
+			if (netif_carrier_ok(dev)) {
+				netif_info(port, link, dev,
+					   "Logical port down\n");
+				netif_carrier_off(dev);
+				netif_stop_queue(dev);
 			}
 
 		if (EHEA_BMASK_GET(NEQE_EXTSWITCH_PORT_UP, eqe)) {
 			port->phy_link = EHEA_PHY_LINK_UP;
-			if (netif_msg_link(port))
-				ehea_info("%s: Physical port up",
-					  port->netdev->name);
+			netif_info(port, link, dev,
+				   "Physical port up\n");
 			if (prop_carrier_state)
-				netif_carrier_on(port->netdev);
+				netif_carrier_on(dev);
 		} else {
 			port->phy_link = EHEA_PHY_LINK_DOWN;
-			if (netif_msg_link(port))
-				ehea_info("%s: Physical port down",
-					  port->netdev->name);
+			netif_info(port, link, dev,
+				   "Physical port down\n");
 			if (prop_carrier_state)
-				netif_carrier_off(port->netdev);
+				netif_carrier_off(dev);
 		}
 
 		if (EHEA_BMASK_GET(NEQE_EXTSWITCH_PRIMARY, eqe))
-			ehea_info("External switch port is primary port");
+			netdev_info(dev,
+				    "External switch port is primary port\n");
 		else
-			ehea_info("External switch port is backup port");
+			netdev_info(dev,
+				    "External switch port is backup port\n");
 
 		break;
 	case EHEA_EC_ADAPTER_MALFUNC:
-		ehea_error("Adapter malfunction");
+		netdev_err(dev, "Adapter malfunction\n");
 		break;
 	case EHEA_EC_PORT_MALFUNC:
-		ehea_info("Port malfunction: Device: %s", port->netdev->name);
-		netif_carrier_off(port->netdev);
-		netif_stop_queue(port->netdev);
+		netdev_info(dev, "Port malfunction\n");
+		netif_carrier_off(dev);
+		netif_stop_queue(dev);
 		break;
 	default:
-		ehea_error("unknown event code %x, eqe=0x%llX", ec, eqe);
+		netdev_err(dev, "unknown event code %x, eqe=0x%llX\n", ec, eqe);
 		break;
 	}
 }
@@ -1289,13 +1290,13 @@ static void ehea_neq_tasklet(unsigned long data)
 	u64 event_mask;
 
 	eqe = ehea_poll_eq(adapter->neq);
-	ehea_debug("eqe=%p", eqe);
+	pr_debug("eqe=%p\n", eqe);
 
 	while (eqe) {
-		ehea_debug("*eqe=%lx", eqe->entry);
+		pr_debug("*eqe=%lx\n", eqe->entry);
 		ehea_parse_eqe(adapter, eqe->entry);
 		eqe = ehea_poll_eq(adapter->neq);
-		ehea_debug("next eqe=%p", eqe);
+		pr_debug("next eqe=%p\n", eqe);
 	}
 
 	event_mask = EHEA_BMASK_SET(NELR_PORTSTATE_CHG, 1)
@@ -1344,14 +1345,14 @@ static int ehea_reg_interrupts(struct net_device *dev)
 				  ehea_qp_aff_irq_handler,
 				  IRQF_DISABLED, port->int_aff_name, port);
 	if (ret) {
-		ehea_error("failed registering irq for qp_aff_irq_handler:"
-			   "ist=%X", port->qp_eq->attr.ist1);
+		netdev_err(dev, "failed registering irq for qp_aff_irq_handler:ist=%X\n",
+			   port->qp_eq->attr.ist1);
 		goto out_free_qpeq;
 	}
 
-	if (netif_msg_ifup(port))
-		ehea_info("irq_handle 0x%X for function qp_aff_irq_handler "
-			  "registered", port->qp_eq->attr.ist1);
+	netif_info(port, ifup, dev,
+		   "irq_handle 0x%X for function qp_aff_irq_handler registered\n",
+		   port->qp_eq->attr.ist1);
 
 
 	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
@@ -1363,14 +1364,13 @@ static int ehea_reg_interrupts(struct net_device *dev)
 					  IRQF_DISABLED, pr->int_send_name,
 					  pr);
 		if (ret) {
-			ehea_error("failed registering irq for ehea_queue "
-				   "port_res_nr:%d, ist=%X", i,
-				   pr->eq->attr.ist1);
+			netdev_err(dev, "failed registering irq for ehea_queue port_res_nr:%d, ist=%X\n",
+				   i, pr->eq->attr.ist1);
 			goto out_free_req;
 		}
-		if (netif_msg_ifup(port))
-			ehea_info("irq_handle 0x%X for function ehea_queue_int "
-				  "%d registered", pr->eq->attr.ist1, i);
+		netif_info(port, ifup, dev,
+			   "irq_handle 0x%X for function ehea_queue_int %d registered\n",
+			   pr->eq->attr.ist1, i);
 	}
 out:
 	return ret;
@@ -1401,16 +1401,16 @@ static void ehea_free_interrupts(struct net_device *dev)
 	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
 		pr = &port->port_res[i];
 		ibmebus_free_irq(pr->eq->attr.ist1, pr);
-		if (netif_msg_intr(port))
-			ehea_info("free send irq for res %d with handle 0x%X",
-				  i, pr->eq->attr.ist1);
+		netif_info(port, intr, dev,
+			   "free send irq for res %d with handle 0x%X\n",
+			   i, pr->eq->attr.ist1);
 	}
 
 	/* associated events */
 	ibmebus_free_irq(port->qp_eq->attr.ist1, port);
-	if (netif_msg_intr(port))
-		ehea_info("associated event interrupt for handle 0x%X freed",
-			  port->qp_eq->attr.ist1);
+	netif_info(port, intr, dev,
+		   "associated event interrupt for handle 0x%X freed\n",
+		   port->qp_eq->attr.ist1);
 }
 
 static int ehea_configure_port(struct ehea_port *port)
@@ -1479,7 +1479,7 @@ int ehea_gen_smrs(struct ehea_port_res *pr)
 out_free:
 	ehea_rem_mr(&pr->send_mr);
 out:
-	ehea_error("Generating SMRS failed\n");
+	pr_err("Generating SMRS failed\n");
 	return -EIO;
 }
 
@@ -1534,7 +1534,7 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 
 	pr->eq = ehea_create_eq(adapter, eq_type, EHEA_MAX_ENTRIES_EQ, 0);
 	if (!pr->eq) {
-		ehea_error("create_eq failed (eq)");
+		pr_err("create_eq failed (eq)\n");
 		goto out_free;
 	}
 
@@ -1542,7 +1542,7 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 				     pr->eq->fw_handle,
 				     port->logical_port_id);
 	if (!pr->recv_cq) {
-		ehea_error("create_cq failed (cq_recv)");
+		pr_err("create_cq failed (cq_recv)\n");
 		goto out_free;
 	}
 
@@ -1550,19 +1550,19 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 				     pr->eq->fw_handle,
 				     port->logical_port_id);
 	if (!pr->send_cq) {
-		ehea_error("create_cq failed (cq_send)");
+		pr_err("create_cq failed (cq_send)\n");
 		goto out_free;
 	}
 
 	if (netif_msg_ifup(port))
-		ehea_info("Send CQ: act_nr_cqes=%d, Recv CQ: act_nr_cqes=%d",
-			  pr->send_cq->attr.act_nr_of_cqes,
-			  pr->recv_cq->attr.act_nr_of_cqes);
+		pr_info("Send CQ: act_nr_cqes=%d, Recv CQ: act_nr_cqes=%d\n",
+			pr->send_cq->attr.act_nr_of_cqes,
+			pr->recv_cq->attr.act_nr_of_cqes);
 
 	init_attr = kzalloc(sizeof(*init_attr), GFP_KERNEL);
 	if (!init_attr) {
 		ret = -ENOMEM;
-		ehea_error("no mem for ehea_qp_init_attr");
+		pr_err("no mem for ehea_qp_init_attr\n");
 		goto out_free;
 	}
 
@@ -1587,18 +1587,18 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 
 	pr->qp = ehea_create_qp(adapter, adapter->pd, init_attr);
 	if (!pr->qp) {
-		ehea_error("create_qp failed");
+		pr_err("create_qp failed\n");
 		ret = -EIO;
 		goto out_free;
 	}
 
 	if (netif_msg_ifup(port))
-		ehea_info("QP: qp_nr=%d\n act_nr_snd_wqe=%d\n nr_rwqe_rq1=%d\n "
-			  "nr_rwqe_rq2=%d\n nr_rwqe_rq3=%d", init_attr->qp_nr,
-			  init_attr->act_nr_send_wqes,
-			  init_attr->act_nr_rwqes_rq1,
-			  init_attr->act_nr_rwqes_rq2,
-			  init_attr->act_nr_rwqes_rq3);
+		pr_info("QP: qp_nr=%d\n act_nr_snd_wqe=%d\n nr_rwqe_rq1=%d\n nr_rwqe_rq2=%d\n nr_rwqe_rq3=%d\n",
+			init_attr->qp_nr,
+			init_attr->act_nr_send_wqes,
+			init_attr->act_nr_rwqes_rq1,
+			init_attr->act_nr_rwqes_rq2,
+			init_attr->act_nr_rwqes_rq3);
 
 	pr->sq_skba_size = init_attr->act_nr_send_wqes + 1;
 
@@ -1749,7 +1749,7 @@ static void write_swqe2_TSO(struct sk_buff *skb,
 			swqe->descriptors++;
 		}
 	} else
-		ehea_error("cannot handle fragmented headers");
+		pr_err("cannot handle fragmented headers\n");
 }
 
 static void write_swqe2_nonTSO(struct sk_buff *skb,
@@ -1845,8 +1845,8 @@ static int ehea_broadcast_reg_helper(struct ehea_port *port, u32 hcallid)
 				     port->logical_port_id,
 				     reg_type, port->mac_addr, 0, hcallid);
 	if (hret != H_SUCCESS) {
-		ehea_error("%sregistering bc address failed (tagged)",
-			   hcallid == H_REG_BCMC ? "" : "de");
+		pr_err("%sregistering bc address failed (tagged)\n",
+		       hcallid == H_REG_BCMC ? "" : "de");
 		ret = -EIO;
 		goto out_herr;
 	}
@@ -1857,8 +1857,8 @@ static int ehea_broadcast_reg_helper(struct ehea_port *port, u32 hcallid)
 				     port->logical_port_id,
 				     reg_type, port->mac_addr, 0, hcallid);
 	if (hret != H_SUCCESS) {
-		ehea_error("%sregistering bc address failed (vlan)",
-			   hcallid == H_REG_BCMC ? "" : "de");
+		pr_err("%sregistering bc address failed (vlan)\n",
+		       hcallid == H_REG_BCMC ? "" : "de");
 		ret = -EIO;
 	}
 out_herr:
@@ -1880,7 +1880,7 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 	cb0 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb0) {
-		ehea_error("no mem for cb0");
+		pr_err("no mem for cb0\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -1928,11 +1928,11 @@ out:
 static void ehea_promiscuous_error(u64 hret, int enable)
 {
 	if (hret == H_AUTHORITY)
-		ehea_info("Hypervisor denied %sabling promiscuous mode",
-			  enable == 1 ? "en" : "dis");
+		pr_info("Hypervisor denied %sabling promiscuous mode\n",
+			enable == 1 ? "en" : "dis");
 	else
-		ehea_error("failed %sabling promiscuous mode",
-			   enable == 1 ? "en" : "dis");
+		pr_err("failed %sabling promiscuous mode\n",
+		       enable == 1 ? "en" : "dis");
 }
 
 static void ehea_promiscuous(struct net_device *dev, int enable)
@@ -1946,7 +1946,7 @@ static void ehea_promiscuous(struct net_device *dev, int enable)
 
 	cb7 = (void *)get_zeroed_page(GFP_ATOMIC);
 	if (!cb7) {
-		ehea_error("no mem for cb7");
+		pr_err("no mem for cb7\n");
 		goto out;
 	}
 
@@ -2006,7 +2006,7 @@ static int ehea_drop_multicast_list(struct net_device *dev)
 		hret = ehea_multicast_reg_helper(port, mc_entry->macaddr,
 						 H_DEREG_BCMC);
 		if (hret) {
-			ehea_error("failed deregistering mcast MAC");
+			pr_err("failed deregistering mcast MAC\n");
 			ret = -EIO;
 		}
 
@@ -2029,7 +2029,8 @@ static void ehea_allmulti(struct net_device *dev, int enable)
 			if (!hret)
 				port->allmulti = 1;
 			else
-				ehea_error("failed enabling IFF_ALLMULTI");
+				netdev_err(dev,
+					   "failed enabling IFF_ALLMULTI\n");
 		}
 	} else
 		if (!enable) {
@@ -2038,7 +2039,8 @@ static void ehea_allmulti(struct net_device *dev, int enable)
 			if (!hret)
 				port->allmulti = 0;
 			else
-				ehea_error("failed disabling IFF_ALLMULTI");
+				netdev_err(dev,
+					   "failed disabling IFF_ALLMULTI\n");
 		}
 }
 
@@ -2049,7 +2051,7 @@ static void ehea_add_multicast_entry(struct ehea_port *port, u8 *mc_mac_addr)
 
 	ehea_mcl_entry = kzalloc(sizeof(*ehea_mcl_entry), GFP_ATOMIC);
 	if (!ehea_mcl_entry) {
-		ehea_error("no mem for mcl_entry");
+		pr_err("no mem for mcl_entry\n");
 		return;
 	}
 
@@ -2062,7 +2064,7 @@ static void ehea_add_multicast_entry(struct ehea_port *port, u8 *mc_mac_addr)
 	if (!hret)
 		list_add(&ehea_mcl_entry->list, &port->mc_list->list);
 	else {
-		ehea_error("failed registering mcast MAC");
+		pr_err("failed registering mcast MAC\n");
 		kfree(ehea_mcl_entry);
 	}
 }
@@ -2095,9 +2097,8 @@ static void ehea_set_multicast_list(struct net_device *dev)
 		}
 
 		if (netdev_mc_count(dev) > port->adapter->max_mc_mac) {
-			ehea_info("Mcast registration limit reached (0x%llx). "
-				  "Use ALLMULTI!",
-				  port->adapter->max_mc_mac);
+			pr_info("Mcast registration limit reached (0x%llx). Use ALLMULTI!\n",
+				port->adapter->max_mc_mac);
 			goto out;
 		}
 
@@ -2303,10 +2304,10 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	pr->swqe_id_counter += 1;
 
-	if (netif_msg_tx_queued(port)) {
-		ehea_info("post swqe on QP %d", pr->qp->init_attr.qp_nr);
+	netif_info(port, tx_queued, dev,
+		   "post swqe on QP %d\n", pr->qp->init_attr.qp_nr);
+	if (netif_msg_tx_queued(port))
 		ehea_dump(swqe, 512, "swqe");
-	}
 
 	if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))) {
 		netif_stop_queue(dev);
@@ -2342,14 +2343,14 @@ static void ehea_vlan_rx_register(struct net_device *dev,
 
 	cb1 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb1) {
-		ehea_error("no mem for cb1");
+		pr_err("no mem for cb1\n");
 		goto out;
 	}
 
 	hret = ehea_h_modify_ehea_port(adapter->handle, port->logical_port_id,
 				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
 	if (hret != H_SUCCESS)
-		ehea_error("modify_ehea_port failed");
+		pr_err("modify_ehea_port failed\n");
 
 	free_page((unsigned long)cb1);
 out:
@@ -2366,14 +2367,14 @@ static void ehea_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 
 	cb1 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb1) {
-		ehea_error("no mem for cb1");
+		pr_err("no mem for cb1\n");
 		goto out;
 	}
 
 	hret = ehea_h_query_ehea_port(adapter->handle, port->logical_port_id,
 				      H_PORT_CB1, H_PORT_CB1_ALL, cb1);
 	if (hret != H_SUCCESS) {
-		ehea_error("query_ehea_port failed");
+		pr_err("query_ehea_port failed\n");
 		goto out;
 	}
 
@@ -2383,7 +2384,7 @@ static void ehea_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	hret = ehea_h_modify_ehea_port(adapter->handle, port->logical_port_id,
 				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
 	if (hret != H_SUCCESS)
-		ehea_error("modify_ehea_port failed");
+		pr_err("modify_ehea_port failed\n");
 out:
 	free_page((unsigned long)cb1);
 	return;
@@ -2401,14 +2402,14 @@ static void ehea_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 
 	cb1 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb1) {
-		ehea_error("no mem for cb1");
+		pr_err("no mem for cb1\n");
 		goto out;
 	}
 
 	hret = ehea_h_query_ehea_port(adapter->handle, port->logical_port_id,
 				      H_PORT_CB1, H_PORT_CB1_ALL, cb1);
 	if (hret != H_SUCCESS) {
-		ehea_error("query_ehea_port failed");
+		pr_err("query_ehea_port failed\n");
 		goto out;
 	}
 
@@ -2418,7 +2419,7 @@ static void ehea_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	hret = ehea_h_modify_ehea_port(adapter->handle, port->logical_port_id,
 				       H_PORT_CB1, H_PORT_CB1_ALL, cb1);
 	if (hret != H_SUCCESS)
-		ehea_error("modify_ehea_port failed");
+		pr_err("modify_ehea_port failed\n");
 out:
 	free_page((unsigned long)cb1);
 }
@@ -2440,7 +2441,7 @@ int ehea_activate_qp(struct ehea_adapter *adapter, struct ehea_qp *qp)
 	hret = ehea_h_query_ehea_qp(adapter->handle, 0, qp->fw_handle,
 				    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF), cb0);
 	if (hret != H_SUCCESS) {
-		ehea_error("query_ehea_qp failed (1)");
+		pr_err("query_ehea_qp failed (1)\n");
 		goto out;
 	}
 
@@ -2449,14 +2450,14 @@ int ehea_activate_qp(struct ehea_adapter *adapter, struct ehea_qp *qp)
 				     EHEA_BMASK_SET(H_QPCB0_QP_CTL_REG, 1), cb0,
 				     &dummy64, &dummy64, &dummy16, &dummy16);
 	if (hret != H_SUCCESS) {
-		ehea_error("modify_ehea_qp failed (1)");
+		pr_err("modify_ehea_qp failed (1)\n");
 		goto out;
 	}
 
 	hret = ehea_h_query_ehea_qp(adapter->handle, 0, qp->fw_handle,
 				    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF), cb0);
 	if (hret != H_SUCCESS) {
-		ehea_error("query_ehea_qp failed (2)");
+		pr_err("query_ehea_qp failed (2)\n");
 		goto out;
 	}
 
@@ -2465,14 +2466,14 @@ int ehea_activate_qp(struct ehea_adapter *adapter, struct ehea_qp *qp)
 				     EHEA_BMASK_SET(H_QPCB0_QP_CTL_REG, 1), cb0,
 				     &dummy64, &dummy64, &dummy16, &dummy16);
 	if (hret != H_SUCCESS) {
-		ehea_error("modify_ehea_qp failed (2)");
+		pr_err("modify_ehea_qp failed (2)\n");
 		goto out;
 	}
 
 	hret = ehea_h_query_ehea_qp(adapter->handle, 0, qp->fw_handle,
 				    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF), cb0);
 	if (hret != H_SUCCESS) {
-		ehea_error("query_ehea_qp failed (3)");
+		pr_err("query_ehea_qp failed (3)\n");
 		goto out;
 	}
 
@@ -2481,14 +2482,14 @@ int ehea_activate_qp(struct ehea_adapter *adapter, struct ehea_qp *qp)
 				     EHEA_BMASK_SET(H_QPCB0_QP_CTL_REG, 1), cb0,
 				     &dummy64, &dummy64, &dummy16, &dummy16);
 	if (hret != H_SUCCESS) {
-		ehea_error("modify_ehea_qp failed (3)");
+		pr_err("modify_ehea_qp failed (3)\n");
 		goto out;
 	}
 
 	hret = ehea_h_query_ehea_qp(adapter->handle, 0, qp->fw_handle,
 				    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF), cb0);
 	if (hret != H_SUCCESS) {
-		ehea_error("query_ehea_qp failed (4)");
+		pr_err("query_ehea_qp failed (4)\n");
 		goto out;
 	}
 
@@ -2509,7 +2510,7 @@ static int ehea_port_res_setup(struct ehea_port *port, int def_qps,
 				   EHEA_MAX_ENTRIES_EQ, 1);
 	if (!port->qp_eq) {
 		ret = -EINVAL;
-		ehea_error("ehea_create_eq failed (qp_eq)");
+		pr_err("ehea_create_eq failed (qp_eq)\n");
 		goto out_kill_eq;
 	}
 
@@ -2590,27 +2591,27 @@ static int ehea_up(struct net_device *dev)
 	ret = ehea_port_res_setup(port, port->num_def_qps,
 				  port->num_add_tx_qps);
 	if (ret) {
-		ehea_error("port_res_failed");
+		netdev_err(dev, "port_res_failed\n");
 		goto out;
 	}
 
 	/* Set default QP for this port */
 	ret = ehea_configure_port(port);
 	if (ret) {
-		ehea_error("ehea_configure_port failed. ret:%d", ret);
+		netdev_err(dev, "ehea_configure_port failed. ret:%d\n", ret);
 		goto out_clean_pr;
 	}
 
 	ret = ehea_reg_interrupts(dev);
 	if (ret) {
-		ehea_error("reg_interrupts failed. ret:%d", ret);
+		netdev_err(dev, "reg_interrupts failed. ret:%d\n", ret);
 		goto out_clean_pr;
 	}
 
 	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
 		ret = ehea_activate_qp(port->adapter, port->port_res[i].qp);
 		if (ret) {
-			ehea_error("activate_qp failed");
+			netdev_err(dev, "activate_qp failed\n");
 			goto out_free_irqs;
 		}
 	}
@@ -2618,7 +2619,7 @@ static int ehea_up(struct net_device *dev)
 	for (i = 0; i < port->num_def_qps; i++) {
 		ret = ehea_fill_port_res(&port->port_res[i]);
 		if (ret) {
-			ehea_error("out_free_irqs");
+			netdev_err(dev, "out_free_irqs\n");
 			goto out_free_irqs;
 		}
 	}
@@ -2641,7 +2642,7 @@ out_clean_pr:
 	ehea_clean_all_portres(port);
 out:
 	if (ret)
-		ehea_info("Failed starting %s. ret=%i", dev->name, ret);
+		netdev_info(dev, "Failed starting. ret=%i\n", ret);
 
 	ehea_update_bcmc_registrations();
 	ehea_update_firmware_handles();
@@ -2672,8 +2673,7 @@ static int ehea_open(struct net_device *dev)
 
 	mutex_lock(&port->port_lock);
 
-	if (netif_msg_ifup(port))
-		ehea_info("enabling port %s", dev->name);
+	netif_info(port, ifup, dev, "enabling port\n");
 
 	ret = ehea_up(dev);
 	if (!ret) {
@@ -2708,8 +2708,7 @@ static int ehea_down(struct net_device *dev)
 
 	ret = ehea_clean_all_portres(port);
 	if (ret)
-		ehea_info("Failed freeing resources for %s. ret=%i",
-			  dev->name, ret);
+		netdev_info(dev, "Failed freeing resources. ret=%i\n", ret);
 
 	ehea_update_firmware_handles();
 
@@ -2721,8 +2720,7 @@ static int ehea_stop(struct net_device *dev)
 	int ret;
 	struct ehea_port *port = netdev_priv(dev);
 
-	if (netif_msg_ifdown(port))
-		ehea_info("disabling port %s", dev->name);
+	netif_info(port, ifdown, dev, "disabling port\n");
 
 	set_bit(__EHEA_DISABLE_PORT_RESET, &port->flags);
 	cancel_work_sync(&port->reset_task);
@@ -2763,7 +2761,7 @@ static void ehea_flush_sq(struct ehea_port *port)
 			 msecs_to_jiffies(100));
 
 		if (!ret) {
-			ehea_error("WARNING: sq not flushed completely");
+			pr_err("WARNING: sq not flushed completely\n");
 			break;
 		}
 	}
@@ -2799,7 +2797,7 @@ int ehea_stop_qps(struct net_device *dev)
 					    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF),
 					    cb0);
 		if (hret != H_SUCCESS) {
-			ehea_error("query_ehea_qp failed (1)");
+			pr_err("query_ehea_qp failed (1)\n");
 			goto out;
 		}
 
@@ -2811,7 +2809,7 @@ int ehea_stop_qps(struct net_device *dev)
 							    1), cb0, &dummy64,
 					     &dummy64, &dummy16, &dummy16);
 		if (hret != H_SUCCESS) {
-			ehea_error("modify_ehea_qp failed (1)");
+			pr_err("modify_ehea_qp failed (1)\n");
 			goto out;
 		}
 
@@ -2819,14 +2817,14 @@ int ehea_stop_qps(struct net_device *dev)
 					    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF),
 					    cb0);
 		if (hret != H_SUCCESS) {
-			ehea_error("query_ehea_qp failed (2)");
+			pr_err("query_ehea_qp failed (2)\n");
 			goto out;
 		}
 
 		/* deregister shared memory regions */
 		dret = ehea_rem_smrs(pr);
 		if (dret) {
-			ehea_error("unreg shared memory region failed");
+			pr_err("unreg shared memory region failed\n");
 			goto out;
 		}
 	}
@@ -2895,7 +2893,7 @@ int ehea_restart_qps(struct net_device *dev)
 
 		ret = ehea_gen_smrs(pr);
 		if (ret) {
-			ehea_error("creation of shared memory regions failed");
+			netdev_err(dev, "creation of shared memory regions failed\n");
 			goto out;
 		}
 
@@ -2906,7 +2904,7 @@ int ehea_restart_qps(struct net_device *dev)
 					    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF),
 					    cb0);
 		if (hret != H_SUCCESS) {
-			ehea_error("query_ehea_qp failed (1)");
+			netdev_err(dev, "query_ehea_qp failed (1)\n");
 			goto out;
 		}
 
@@ -2918,7 +2916,7 @@ int ehea_restart_qps(struct net_device *dev)
 							    1), cb0, &dummy64,
 					     &dummy64, &dummy16, &dummy16);
 		if (hret != H_SUCCESS) {
-			ehea_error("modify_ehea_qp failed (1)");
+			netdev_err(dev, "modify_ehea_qp failed (1)\n");
 			goto out;
 		}
 
@@ -2926,7 +2924,7 @@ int ehea_restart_qps(struct net_device *dev)
 					    EHEA_BMASK_SET(H_QPCB0_ALL, 0xFFFF),
 					    cb0);
 		if (hret != H_SUCCESS) {
-			ehea_error("query_ehea_qp failed (2)");
+			netdev_err(dev, "query_ehea_qp failed (2)\n");
 			goto out;
 		}
 
@@ -2963,8 +2961,7 @@ static void ehea_reset_port(struct work_struct *work)
 
 	ehea_set_multicast_list(dev);
 
-	if (netif_msg_timer(port))
-		ehea_info("Device %s resetted successfully", dev->name);
+	netif_info(port, timer, dev, "reset successful\n");
 
 	port_napi_enable(port);
 
@@ -2979,7 +2976,7 @@ static void ehea_rereg_mrs(struct work_struct *work)
 	int ret, i;
 	struct ehea_adapter *adapter;
 
-	ehea_info("LPAR memory changed - re-initializing driver");
+	pr_info("LPAR memory changed - re-initializing driver\n");
 
 	list_for_each_entry(adapter, &adapter_list, list)
 		if (adapter->active_ports) {
@@ -3011,8 +3008,7 @@ static void ehea_rereg_mrs(struct work_struct *work)
 			/* Unregister old memory region */
 			ret = ehea_rem_mr(&adapter->mr);
 			if (ret) {
-				ehea_error("unregister MR failed - driver"
-					   " inoperable!");
+				pr_err("unregister MR failed - driver inoperable!\n");
 				goto out;
 			}
 		}
@@ -3024,8 +3020,7 @@ static void ehea_rereg_mrs(struct work_struct *work)
 			/* Register new memory region */
 			ret = ehea_reg_kernel_mr(adapter, &adapter->mr);
 			if (ret) {
-				ehea_error("register MR failed - driver"
-					   " inoperable!");
+				pr_err("register MR failed - driver inoperable!\n");
 				goto out;
 			}
 
@@ -3048,7 +3043,7 @@ static void ehea_rereg_mrs(struct work_struct *work)
 				}
 			}
 		}
-	ehea_info("re-initializing driver complete");
+	pr_info("re-initializing driver complete\n");
 out:
 	return;
 }
@@ -3101,7 +3096,7 @@ int ehea_get_jumboframe_status(struct ehea_port *port, int *jumbo)
 	/* (Try to) enable *jumbo frames */
 	cb4 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb4) {
-		ehea_error("no mem for cb4");
+		pr_err("no mem for cb4\n");
 		ret = -ENOMEM;
 		goto out;
 	} else {
@@ -3163,13 +3158,13 @@ static struct device *ehea_register_port(struct ehea_port *port,
 
 	ret = of_device_register(&port->ofdev);
 	if (ret) {
-		ehea_error("failed to register device. ret=%d", ret);
+		pr_err("failed to register device. ret=%d\n", ret);
 		goto out;
 	}
 
 	ret = device_create_file(&port->ofdev.dev, &dev_attr_log_port_id);
 	if (ret) {
-		ehea_error("failed to register attributes, ret=%d", ret);
+		pr_err("failed to register attributes, ret=%d\n", ret);
 		goto out_unreg_of_dev;
 	}
 
@@ -3219,7 +3214,7 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	dev = alloc_etherdev(sizeof(struct ehea_port));
 
 	if (!dev) {
-		ehea_error("no mem for net_device");
+		pr_err("no mem for net_device\n");
 		ret = -ENOMEM;
 		goto out_err;
 	}
@@ -3270,7 +3265,7 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 
 	ret = register_netdev(dev);
 	if (ret) {
-		ehea_error("register_netdev failed. ret=%d", ret);
+		pr_err("register_netdev failed. ret=%d\n", ret);
 		goto out_unreg_port;
 	}
 
@@ -3278,11 +3273,10 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 
 	ret = ehea_get_jumboframe_status(port, &jumbo);
 	if (ret)
-		ehea_error("failed determining jumbo frame status for %s",
-			   port->netdev->name);
+		netdev_err(dev, "failed determining jumbo frame status\n");
 
-	ehea_info("%s: Jumbo frames are %sabled", dev->name,
-		  jumbo == 1 ? "en" : "dis");
+	netdev_info(dev, "Jumbo frames are %sabled\n",
+		    jumbo == 1 ? "en" : "dis");
 
 	adapter->active_ports++;
 
@@ -3298,8 +3292,8 @@ out_free_ethdev:
 	free_netdev(dev);
 
 out_err:
-	ehea_error("setting up logical port with id=%d failed, ret=%d",
-		   logical_port_id, ret);
+	pr_err("setting up logical port with id=%d failed, ret=%d\n",
+	       logical_port_id, ret);
 	return NULL;
 }
 
@@ -3327,13 +3321,13 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)
 		dn_log_port_id = of_get_property(eth_dn, "ibm,hea-port-no",
 						 NULL);
 		if (!dn_log_port_id) {
-			ehea_error("bad device node: eth_dn name=%s",
-				   eth_dn->full_name);
+			pr_err("bad device node: eth_dn name=%s\n",
+			       eth_dn->full_name);
 			continue;
 		}
 
 		if (ehea_add_adapter_mr(adapter)) {
-			ehea_error("creating MR failed");
+			pr_err("creating MR failed\n");
 			of_node_put(eth_dn);
 			return -EIO;
 		}
@@ -3342,9 +3336,8 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)
 							  *dn_log_port_id,
 							  eth_dn);
 		if (adapter->port[i])
-			ehea_info("%s -> logical port id #%d",
-				  adapter->port[i]->netdev->name,
-				  *dn_log_port_id);
+			netdev_info(adapter->port[i]->netdev,
+				    "logical port id #%d\n", *dn_log_port_id);
 		else
 			ehea_remove_adapter_mr(adapter);
 
@@ -3389,21 +3382,20 @@ static ssize_t ehea_probe_port(struct device *dev,
 	port = ehea_get_port(adapter, logical_port_id);
 
 	if (port) {
-		ehea_info("adding port with logical port id=%d failed. port "
-			  "already configured as %s.", logical_port_id,
-			  port->netdev->name);
+		netdev_info(port->netdev, "adding port with logical port id=%d failed: port already configured\n",
+			    logical_port_id);
 		return -EINVAL;
 	}
 
 	eth_dn = ehea_get_eth_dn(adapter, logical_port_id);
 
 	if (!eth_dn) {
-		ehea_info("no logical port with id %d found", logical_port_id);
+		pr_info("no logical port with id %d found\n", logical_port_id);
 		return -EINVAL;
 	}
 
 	if (ehea_add_adapter_mr(adapter)) {
-		ehea_error("creating MR failed");
+		pr_err("creating MR failed\n");
 		return -EIO;
 	}
 
@@ -3418,8 +3410,8 @@ static ssize_t ehea_probe_port(struct device *dev,
 				break;
 			}
 
-		ehea_info("added %s (logical port id=%d)", port->netdev->name,
-			  logical_port_id);
+		netdev_info(port->netdev, "added: (logical port id=%d)\n",
+			    logical_port_id);
 	} else {
 		ehea_remove_adapter_mr(adapter);
 		return -EIO;
@@ -3442,8 +3434,8 @@ static ssize_t ehea_remove_port(struct device *dev,
 	port = ehea_get_port(adapter, logical_port_id);
 
 	if (port) {
-		ehea_info("removed %s (logical port id=%d)", port->netdev->name,
-			  logical_port_id);
+		netdev_info(port->netdev, "removed: (logical port id=%d)\n",
+			    logical_port_id);
 
 		ehea_shutdown_single_port(port);
 
@@ -3453,8 +3445,8 @@ static ssize_t ehea_remove_port(struct device *dev,
 				break;
 			}
 	} else {
-		ehea_error("removing port with logical port id=%d failed. port "
-			   "not configured.", logical_port_id);
+		pr_err("removing port with logical port id=%d failed. port not configured.\n",
+		       logical_port_id);
 		return -EINVAL;
 	}
 
@@ -3491,7 +3483,7 @@ static int __devinit ehea_probe_adapter(struct platform_device *dev,
 	int ret;
 
 	if (!dev || !dev->dev.of_node) {
-		ehea_error("Invalid ibmebus device probed");
+		pr_err("Invalid ibmebus device probed\n");
 		return -EINVAL;
 	}
 
@@ -3639,17 +3631,17 @@ static int ehea_mem_notifier(struct notifier_block *nb,
 
 	switch (action) {
 	case MEM_CANCEL_OFFLINE:
-		ehea_info("memory offlining canceled");
+		pr_info("memory offlining canceled\n");
 		/* Readd canceled memory block */
 	case MEM_ONLINE:
-		ehea_info("memory is going online");
+		pr_info("memory is going online\n");
 		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
 		if (ehea_add_sect_bmap(arg->start_pfn, arg->nr_pages))
 			goto out_unlock;
 		ehea_rereg_mrs(NULL);
 		break;
 	case MEM_GOING_OFFLINE:
-		ehea_info("memory is going offline");
+		pr_info("memory is going offline\n");
 		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
 		if (ehea_rem_sect_bmap(arg->start_pfn, arg->nr_pages))
 			goto out_unlock;
@@ -3675,7 +3667,7 @@ static int ehea_reboot_notifier(struct notifier_block *nb,
 				unsigned long action, void *unused)
 {
 	if (action == SYS_RESTART) {
-		ehea_info("Reboot: freeing all eHEA resources");
+		pr_info("Reboot: freeing all eHEA resources\n");
 		ibmebus_unregister_driver(&ehea_driver);
 	}
 	return NOTIFY_DONE;
@@ -3691,22 +3683,22 @@ static int check_module_parm(void)
 
 	if ((rq1_entries < EHEA_MIN_ENTRIES_QP) ||
 	    (rq1_entries > EHEA_MAX_ENTRIES_RQ1)) {
-		ehea_info("Bad parameter: rq1_entries");
+		pr_info("Bad parameter: rq1_entries\n");
 		ret = -EINVAL;
 	}
 	if ((rq2_entries < EHEA_MIN_ENTRIES_QP) ||
 	    (rq2_entries > EHEA_MAX_ENTRIES_RQ2)) {
-		ehea_info("Bad parameter: rq2_entries");
+		pr_info("Bad parameter: rq2_entries\n");
 		ret = -EINVAL;
 	}
 	if ((rq3_entries < EHEA_MIN_ENTRIES_QP) ||
 	    (rq3_entries > EHEA_MAX_ENTRIES_RQ3)) {
-		ehea_info("Bad parameter: rq3_entries");
+		pr_info("Bad parameter: rq3_entries\n");
 		ret = -EINVAL;
 	}
 	if ((sq_entries < EHEA_MIN_ENTRIES_QP) ||
 	    (sq_entries > EHEA_MAX_ENTRIES_SQ)) {
-		ehea_info("Bad parameter: sq_entries");
+		pr_info("Bad parameter: sq_entries\n");
 		ret = -EINVAL;
 	}
 
@@ -3726,8 +3718,7 @@ int __init ehea_module_init(void)
 {
 	int ret;
 
-	printk(KERN_INFO "IBM eHEA ethernet device driver (Release %s)\n",
-	       DRV_VERSION);
+	pr_info("IBM eHEA ethernet device driver (Release %s)\n", DRV_VERSION);
 
 
 	INIT_WORK(&ehea_rereg_mr_task, ehea_rereg_mrs);
@@ -3747,27 +3738,27 @@ int __init ehea_module_init(void)
 
 	ret = register_reboot_notifier(&ehea_reboot_nb);
 	if (ret)
-		ehea_info("failed registering reboot notifier");
+		pr_info("failed registering reboot notifier\n");
 
 	ret = register_memory_notifier(&ehea_mem_nb);
 	if (ret)
-		ehea_info("failed registering memory remove notifier");
+		pr_info("failed registering memory remove notifier\n");
 
 	ret = crash_shutdown_register(ehea_crash_handler);
 	if (ret)
-		ehea_info("failed registering crash handler");
+		pr_info("failed registering crash handler\n");
 
 	ret = ibmebus_register_driver(&ehea_driver);
 	if (ret) {
-		ehea_error("failed registering eHEA device driver on ebus");
+		pr_err("failed registering eHEA device driver on ebus\n");
 		goto out2;
 	}
 
 	ret = driver_create_file(&ehea_driver.driver,
 				 &driver_attr_capabilities);
 	if (ret) {
-		ehea_error("failed to register capabilities attribute, ret=%d",
-			   ret);
+		pr_err("failed to register capabilities attribute, ret=%d\n",
+		       ret);
 		goto out3;
 	}
 
@@ -3793,7 +3784,7 @@ static void __exit ehea_module_exit(void)
 	unregister_reboot_notifier(&ehea_reboot_nb);
 	ret = crash_shutdown_unregister(ehea_crash_handler);
 	if (ret)
-		ehea_info("failed unregistering crash handler");
+		pr_info("failed unregistering crash handler\n");
 	unregister_memory_notifier(&ehea_mem_nb);
 	kfree(ehea_fw_handles.arr);
 	kfree(ehea_bcmc_regs.arr);
diff --git a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ehea/ehea_phyp.c
index 8fe9dca..0506967 100644
--- a/drivers/net/ehea/ehea_phyp.c
+++ b/drivers/net/ehea/ehea_phyp.c
@@ -26,6 +26,8 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ehea_phyp.h"
 
 
@@ -67,12 +69,11 @@ static long ehea_plpar_hcall_norets(unsigned long opcode,
 		}
 
 		if (ret < H_SUCCESS)
-			ehea_error("opcode=%lx ret=%lx"
-				   " arg1=%lx arg2=%lx arg3=%lx arg4=%lx"
-				   " arg5=%lx arg6=%lx arg7=%lx ",
-				   opcode, ret,
-				   arg1, arg2, arg3, arg4, arg5,
-				   arg6, arg7);
+			pr_err("opcode=%lx ret=%lx"
+			       " arg1=%lx arg2=%lx arg3=%lx arg4=%lx"
+			       " arg5=%lx arg6=%lx arg7=%lx\n",
+			       opcode, ret,
+			       arg1, arg2, arg3, arg4, arg5, arg6, arg7);
 
 		return ret;
 	}
@@ -114,19 +115,18 @@ static long ehea_plpar_hcall9(unsigned long opcode,
 		    && (((cb_cat == H_PORT_CB4) && ((arg3 == H_PORT_CB4_JUMBO)
 		    || (arg3 == H_PORT_CB4_SPEED))) || ((cb_cat == H_PORT_CB7)
 		    && (arg3 == H_PORT_CB7_DUCQPN)))))
-			ehea_error("opcode=%lx ret=%lx"
-				   " arg1=%lx arg2=%lx arg3=%lx arg4=%lx"
-				   " arg5=%lx arg6=%lx arg7=%lx arg8=%lx"
-				   " arg9=%lx"
-				   " out1=%lx out2=%lx out3=%lx out4=%lx"
-				   " out5=%lx out6=%lx out7=%lx out8=%lx"
-				   " out9=%lx",
-				   opcode, ret,
-				   arg1, arg2, arg3, arg4, arg5,
-				   arg6, arg7, arg8, arg9,
-				   outs[0], outs[1], outs[2], outs[3],
-				   outs[4], outs[5], outs[6], outs[7],
-				   outs[8]);
+			pr_err("opcode=%lx ret=%lx"
+			       " arg1=%lx arg2=%lx arg3=%lx arg4=%lx"
+			       " arg5=%lx arg6=%lx arg7=%lx arg8=%lx"
+			       " arg9=%lx"
+			       " out1=%lx out2=%lx out3=%lx out4=%lx"
+			       " out5=%lx out6=%lx out7=%lx out8=%lx"
+			       " out9=%lx\n",
+			       opcode, ret,
+			       arg1, arg2, arg3, arg4, arg5,
+			       arg6, arg7, arg8, arg9,
+			       outs[0], outs[1], outs[2], outs[3], outs[4],
+			       outs[5], outs[6], outs[7], outs[8]);
 		return ret;
 	}
 
@@ -515,7 +515,7 @@ u64 ehea_h_register_rpage_mr(const u64 adapter_handle, const u64 mr_handle,
 			     const u64 log_pageaddr, const u64 count)
 {
 	if ((count > 1) && (log_pageaddr & ~PAGE_MASK)) {
-		ehea_error("not on pageboundary");
+		pr_err("not on pageboundary\n");
 		return H_PARAMETER;
 	}
 
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 89128b6..cd44bb8 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -26,6 +26,8 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include "ehea.h"
@@ -45,7 +47,7 @@ static void *hw_qpageit_get_inc(struct hw_queue *queue)
 		queue->current_q_offset -= queue->pagesize;
 		retvalue = NULL;
 	} else if (((u64) retvalue) & (EHEA_PAGESIZE-1)) {
-		ehea_error("not on pageboundary");
+		pr_err("not on pageboundary\n");
 		retvalue = NULL;
 	}
 	return retvalue;
@@ -58,15 +60,15 @@ static int hw_queue_ctor(struct hw_queue *queue, const u32 nr_of_pages,
 	int i, k;
 
 	if ((pagesize > PAGE_SIZE) || (!pages_per_kpage)) {
-		ehea_error("pagesize conflict! kernel pagesize=%d, "
-			   "ehea pagesize=%d", (int)PAGE_SIZE, (int)pagesize);
+		pr_err("pagesize conflict! kernel pagesize=%d, ehea pagesize=%d\n",
+		       (int)PAGE_SIZE, (int)pagesize);
 		return -EINVAL;
 	}
 
 	queue->queue_length = nr_of_pages * pagesize;
 	queue->queue_pages = kmalloc(nr_of_pages * sizeof(void *), GFP_KERNEL);
 	if (!queue->queue_pages) {
-		ehea_error("no mem for queue_pages");
+		pr_err("no mem for queue_pages\n");
 		return -ENOMEM;
 	}
 
@@ -130,7 +132,7 @@ struct ehea_cq *ehea_create_cq(struct ehea_adapter *adapter,
 
 	cq = kzalloc(sizeof(*cq), GFP_KERNEL);
 	if (!cq) {
-		ehea_error("no mem for cq");
+		pr_err("no mem for cq\n");
 		goto out_nomem;
 	}
 
@@ -147,7 +149,7 @@ struct ehea_cq *ehea_create_cq(struct ehea_adapter *adapter,
 	hret = ehea_h_alloc_resource_cq(adapter->handle, &cq->attr,
 					&cq->fw_handle, &cq->epas);
 	if (hret != H_SUCCESS) {
-		ehea_error("alloc_resource_cq failed");
+		pr_err("alloc_resource_cq failed\n");
 		goto out_freemem;
 	}
 
@@ -159,7 +161,7 @@ struct ehea_cq *ehea_create_cq(struct ehea_adapter *adapter,
 	for (counter = 0; counter < cq->attr.nr_pages; counter++) {
 		vpage = hw_qpageit_get_inc(&cq->hw_queue);
 		if (!vpage) {
-			ehea_error("hw_qpageit_get_inc failed");
+			pr_err("hw_qpageit_get_inc failed\n");
 			goto out_kill_hwq;
 		}
 
@@ -168,9 +170,8 @@ struct ehea_cq *ehea_create_cq(struct ehea_adapter *adapter,
 					     0, EHEA_CQ_REGISTER_ORIG,
 					     cq->fw_handle, rpage, 1);
 		if (hret < H_SUCCESS) {
-			ehea_error("register_rpage_cq failed ehea_cq=%p "
-				   "hret=%llx counter=%i act_pages=%i",
-				   cq, hret, counter, cq->attr.nr_pages);
+			pr_err("register_rpage_cq failed ehea_cq=%p hret=%llx counter=%i act_pages=%i\n",
+			       cq, hret, counter, cq->attr.nr_pages);
 			goto out_kill_hwq;
 		}
 
@@ -178,14 +179,14 @@ struct ehea_cq *ehea_create_cq(struct ehea_adapter *adapter,
 			vpage = hw_qpageit_get_inc(&cq->hw_queue);
 
 			if ((hret != H_SUCCESS) || (vpage)) {
-				ehea_error("registration of pages not "
-					   "complete hret=%llx\n", hret);
+				pr_err("registration of pages not complete hret=%llx\n",
+				       hret);
 				goto out_kill_hwq;
 			}
 		} else {
 			if (hret != H_PAGE_REGISTERED) {
-				ehea_error("CQ: registration of page failed "
-					   "hret=%llx\n", hret);
+				pr_err("CQ: registration of page failed hret=%llx\n",
+				       hret);
 				goto out_kill_hwq;
 			}
 		}
@@ -241,7 +242,7 @@ int ehea_destroy_cq(struct ehea_cq *cq)
 	}
 
 	if (hret != H_SUCCESS) {
-		ehea_error("destroy CQ failed");
+		pr_err("destroy CQ failed\n");
 		return -EIO;
 	}
 
@@ -259,7 +260,7 @@ struct ehea_eq *ehea_create_eq(struct ehea_adapter *adapter,
 
 	eq = kzalloc(sizeof(*eq), GFP_KERNEL);
 	if (!eq) {
-		ehea_error("no mem for eq");
+		pr_err("no mem for eq\n");
 		return NULL;
 	}
 
@@ -272,21 +273,21 @@ struct ehea_eq *ehea_create_eq(struct ehea_adapter *adapter,
 	hret = ehea_h_alloc_resource_eq(adapter->handle,
 					&eq->attr, &eq->fw_handle);
 	if (hret != H_SUCCESS) {
-		ehea_error("alloc_resource_eq failed");
+		pr_err("alloc_resource_eq failed\n");
 		goto out_freemem;
 	}
 
 	ret = hw_queue_ctor(&eq->hw_queue, eq->attr.nr_pages,
 			    EHEA_PAGESIZE, sizeof(struct ehea_eqe));
 	if (ret) {
-		ehea_error("can't allocate eq pages");
+		pr_err("can't allocate eq pages\n");
 		goto out_freeres;
 	}
 
 	for (i = 0; i < eq->attr.nr_pages; i++) {
 		vpage = hw_qpageit_get_inc(&eq->hw_queue);
 		if (!vpage) {
-			ehea_error("hw_qpageit_get_inc failed");
+			pr_err("hw_qpageit_get_inc failed\n");
 			hret = H_RESOURCE;
 			goto out_kill_hwq;
 		}
@@ -370,7 +371,7 @@ int ehea_destroy_eq(struct ehea_eq *eq)
 	}
 
 	if (hret != H_SUCCESS) {
-		ehea_error("destroy EQ failed");
+		pr_err("destroy EQ failed\n");
 		return -EIO;
 	}
 
@@ -395,7 +396,7 @@ int ehea_qp_alloc_register(struct ehea_qp *qp, struct hw_queue *hw_queue,
 	for (cnt = 0; cnt < nr_pages; cnt++) {
 		vpage = hw_qpageit_get_inc(hw_queue);
 		if (!vpage) {
-			ehea_error("hw_qpageit_get_inc failed");
+			pr_err("hw_qpageit_get_inc failed\n");
 			goto out_kill_hwq;
 		}
 		rpage = virt_to_abs(vpage);
@@ -403,7 +404,7 @@ int ehea_qp_alloc_register(struct ehea_qp *qp, struct hw_queue *hw_queue,
 					     0, h_call_q_selector,
 					     qp->fw_handle, rpage, 1);
 		if (hret < H_SUCCESS) {
-			ehea_error("register_rpage_qp failed");
+			pr_err("register_rpage_qp failed\n");
 			goto out_kill_hwq;
 		}
 	}
@@ -432,7 +433,7 @@ struct ehea_qp *ehea_create_qp(struct ehea_adapter *adapter,
 
 	qp = kzalloc(sizeof(*qp), GFP_KERNEL);
 	if (!qp) {
-		ehea_error("no mem for qp");
+		pr_err("no mem for qp\n");
 		return NULL;
 	}
 
@@ -441,7 +442,7 @@ struct ehea_qp *ehea_create_qp(struct ehea_adapter *adapter,
 	hret = ehea_h_alloc_resource_qp(adapter->handle, init_attr, pd,
 					&qp->fw_handle, &qp->epas);
 	if (hret != H_SUCCESS) {
-		ehea_error("ehea_h_alloc_resource_qp failed");
+		pr_err("ehea_h_alloc_resource_qp failed\n");
 		goto out_freemem;
 	}
 
@@ -455,7 +456,7 @@ struct ehea_qp *ehea_create_qp(struct ehea_adapter *adapter,
 				     init_attr->act_wqe_size_enc_sq, adapter,
 				     0);
 	if (ret) {
-		ehea_error("can't register for sq ret=%x", ret);
+		pr_err("can't register for sq ret=%x\n", ret);
 		goto out_freeres;
 	}
 
@@ -465,7 +466,7 @@ struct ehea_qp *ehea_create_qp(struct ehea_adapter *adapter,
 				     init_attr->act_wqe_size_enc_rq1,
 				     adapter, 1);
 	if (ret) {
-		ehea_error("can't register for rq1 ret=%x", ret);
+		pr_err("can't register for rq1 ret=%x\n", ret);
 		goto out_kill_hwsq;
 	}
 
@@ -476,7 +477,7 @@ struct ehea_qp *ehea_create_qp(struct ehea_adapter *adapter,
 					     init_attr->act_wqe_size_enc_rq2,
 					     adapter, 2);
 		if (ret) {
-			ehea_error("can't register for rq2 ret=%x", ret);
+			pr_err("can't register for rq2 ret=%x\n", ret);
 			goto out_kill_hwr1q;
 		}
 	}
@@ -488,7 +489,7 @@ struct ehea_qp *ehea_create_qp(struct ehea_adapter *adapter,
 					     init_attr->act_wqe_size_enc_rq3,
 					     adapter, 3);
 		if (ret) {
-			ehea_error("can't register for rq3 ret=%x", ret);
+			pr_err("can't register for rq3 ret=%x\n", ret);
 			goto out_kill_hwr2q;
 		}
 	}
@@ -553,7 +554,7 @@ int ehea_destroy_qp(struct ehea_qp *qp)
 	}
 
 	if (hret != H_SUCCESS) {
-		ehea_error("destroy QP failed");
+		pr_err("destroy QP failed\n");
 		return -EIO;
 	}
 
@@ -842,7 +843,7 @@ static u64 ehea_reg_mr_section(int top, int dir, int idx, u64 *pt,
 		    (hret != H_PAGE_REGISTERED)) {
 			ehea_h_free_resource(adapter->handle, mr->handle,
 					     FORCE_FREE);
-			ehea_error("register_rpage_mr failed");
+			pr_err("register_rpage_mr failed\n");
 			return hret;
 		}
 	}
@@ -896,7 +897,7 @@ int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 
 	pt = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!pt) {
-		ehea_error("no mem");
+		pr_err("no mem\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -906,14 +907,14 @@ int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 					&mr->handle, &mr->lkey);
 
 	if (hret != H_SUCCESS) {
-		ehea_error("alloc_resource_mr failed");
+		pr_err("alloc_resource_mr failed\n");
 		ret = -EIO;
 		goto out;
 	}
 
 	if (!ehea_bmap) {
 		ehea_h_free_resource(adapter->handle, mr->handle, FORCE_FREE);
-		ehea_error("no busmap available");
+		pr_err("no busmap available\n");
 		ret = -EIO;
 		goto out;
 	}
@@ -929,7 +930,7 @@ int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)
 
 	if (hret != H_SUCCESS) {
 		ehea_h_free_resource(adapter->handle, mr->handle, FORCE_FREE);
-		ehea_error("registering mr failed");
+		pr_err("registering mr failed\n");
 		ret = -EIO;
 		goto out;
 	}
@@ -952,7 +953,7 @@ int ehea_rem_mr(struct ehea_mr *mr)
 	hret = ehea_h_free_resource(mr->adapter->handle, mr->handle,
 				    FORCE_FREE);
 	if (hret != H_SUCCESS) {
-		ehea_error("destroy MR failed");
+		pr_err("destroy MR failed\n");
 		return -EIO;
 	}
 
@@ -987,14 +988,14 @@ void print_error_data(u64 *data)
 		length = EHEA_PAGESIZE;
 
 	if (type == EHEA_AER_RESTYPE_QP)
-		ehea_error("QP (resource=%llX) state: AER=0x%llX, AERR=0x%llX, "
-			   "port=%llX", resource, data[6], data[12], data[22]);
+		pr_err("QP (resource=%llX) state: AER=0x%llX, AERR=0x%llX, port=%llX\n",
+		       resource, data[6], data[12], data[22]);
 	else if (type == EHEA_AER_RESTYPE_CQ)
-		ehea_error("CQ (resource=%llX) state: AER=0x%llX", resource,
-			   data[6]);
+		pr_err("CQ (resource=%llX) state: AER=0x%llX\n",
+		       resource, data[6]);
 	else if (type == EHEA_AER_RESTYPE_EQ)
-		ehea_error("EQ (resource=%llX) state: AER=0x%llX", resource,
-			   data[6]);
+		pr_err("EQ (resource=%llX) state: AER=0x%llX\n",
+		       resource, data[6]);
 
 	ehea_dump(data, length, "error data");
 }
@@ -1008,7 +1009,7 @@ u64 ehea_error_data(struct ehea_adapter *adapter, u64 res_handle,
 
 	rblock = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!rblock) {
-		ehea_error("Cannot allocate rblock memory.");
+		pr_err("Cannot allocate rblock memory\n");
 		goto out;
 	}
 
@@ -1020,9 +1021,9 @@ u64 ehea_error_data(struct ehea_adapter *adapter, u64 res_handle,
 		*aerr = rblock[12];
 		print_error_data(rblock);
 	} else if (ret == H_R_STATE) {
-		ehea_error("No error data available: %llX.", res_handle);
+		pr_err("No error data available: %llX\n", res_handle);
 	} else
-		ehea_error("Error data could not be fetched: %llX", res_handle);
+		pr_err("Error data could not be fetched: %llX\n", res_handle);
 
 	free_page((unsigned long)rblock);
 out:


