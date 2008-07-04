From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes for .26
Date: Fri, 4 Jul 2008 08:54:22 -0400
Message-ID: <20080704125422.GA30282@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:38364 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155AbYGDMyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:54:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/ehea/ehea.h        |    8 ++++--
 drivers/net/ehea/ehea_main.c   |   42 +++++++++++++++++++++++----------------
 drivers/net/forcedeth.c        |   15 ++++++++++++-
 drivers/net/fs_enet/mac-fcc.c  |    3 ++
 drivers/net/ibm_newemac/core.c |    8 +++++++
 drivers/net/pasemi_mac.c       |    2 +-
 drivers/net/wan/hdlc_fr.c      |    1 +
 7 files changed, 56 insertions(+), 23 deletions(-)

Jan-Bernd Themann (3):
      ehea: fix might sleep problem
      ehea: add MODULE_DEVICE_TABLE
      ehea: fix race condition

Krzysztof Halasa (1):
      Add missing skb->dev assignment in Frame Relay RX code

Laurent Pinchart (1):
      fs_enet: restore promiscuous and multicast settings in restart()

Roland Dreier (2):
      ehea: Access iph->tot_len with correct endianness
      pasemi_mac: Access iph->tot_len with correct endianness

Sathya Narayanan (2):
      ibm_newemac: Fixes kernel crashes when speed of cable connected changes
      ibm_newemac: Fixes entry of short packets

Tobias Diedrich (1):
      forcedeth: fix lockdep warning on ethtool -s

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index fe872fb..e01926b 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0091"
+#define DRV_VERSION	"EHEA_0092"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -452,7 +452,7 @@ struct ehea_bcmc_reg_entry {
 struct ehea_bcmc_reg_array {
 	struct ehea_bcmc_reg_entry *arr;
 	int num_entries;
-	struct mutex lock;
+	spinlock_t lock;
 };
 
 #define EHEA_PORT_UP 1
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
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 075fd54..0920b79 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -118,6 +118,7 @@ static struct of_device_id ehea_device_table[] = {
 	},
 	{},
 };
+MODULE_DEVICE_TABLE(of, ehea_device_table);
 
 static struct of_platform_driver ehea_driver = {
 	.name = "ehea",
@@ -137,6 +138,12 @@ void ehea_dump(void *adr, int len, char *msg)
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
@@ -241,7 +248,7 @@ static void ehea_update_bcmc_registrations(void)
 		}
 
 	if (num_registrations) {
-		arr = kzalloc(num_registrations * sizeof(*arr), GFP_KERNEL);
+		arr = kzalloc(num_registrations * sizeof(*arr), GFP_ATOMIC);
 		if (!arr)
 			return;  /* Keep the existing array */
 	} else
@@ -301,7 +308,7 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 
 	memset(stats, 0, sizeof(*stats));
 
-	cb2 = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	cb2 = kzalloc(PAGE_SIZE, GFP_ATOMIC);
 	if (!cb2) {
 		ehea_error("no mem for cb2");
 		goto out;
@@ -587,7 +594,7 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 				   "Resetting port.", pr->qp->init_attr.qp_nr);
 			ehea_dump(cqe, sizeof(*cqe), "CQE");
 		}
-		schedule_work(&pr->port->reset_task);
+		ehea_schedule_port_reset(pr->port);
 		return 1;
 	}
 
@@ -616,7 +623,7 @@ static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
 	*tcph = tcp_hdr(skb);
 
 	/* check if ip header and tcp header are complete */
-	if (iph->tot_len < ip_len + tcp_hdrlen(skb))
+	if (ntohs(iph->tot_len) < ip_len + tcp_hdrlen(skb))
 		return -1;
 
 	*hdr_flags = LRO_IPV4 | LRO_TCP;
@@ -765,7 +772,7 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 			ehea_error("Send Completion Error: Resetting port");
 			if (netif_msg_tx_err(pr->port))
 				ehea_dump(cqe, sizeof(*cqe), "Send CQE");
-			schedule_work(&pr->port->reset_task);
+			ehea_schedule_port_reset(pr->port);
 			break;
 		}
 
@@ -885,7 +892,7 @@ static irqreturn_t ehea_qp_aff_irq_handler(int irq, void *param)
 		eqe = ehea_poll_eq(port->qp_eq);
 	}
 
-	schedule_work(&port->reset_task);
+	ehea_schedule_port_reset(port);
 
 	return IRQ_HANDLED;
 }
@@ -1763,7 +1770,7 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 	memcpy(dev->dev_addr, mac_addr->sa_data, dev->addr_len);
 
-	mutex_lock(&ehea_bcmc_regs.lock);
+	spin_lock(&ehea_bcmc_regs.lock);
 
 	/* Deregister old MAC in pHYP */
 	if (port->state == EHEA_PORT_UP) {
@@ -1785,7 +1792,7 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 out_upregs:
 	ehea_update_bcmc_registrations();
-	mutex_unlock(&ehea_bcmc_regs.lock);
+	spin_unlock(&ehea_bcmc_regs.lock);
 out_free:
 	kfree(cb0);
 out:
@@ -1947,7 +1954,7 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 	ehea_promiscuous(dev, 0);
 
-	mutex_lock(&ehea_bcmc_regs.lock);
+	spin_lock(&ehea_bcmc_regs.lock);
 
 	if (dev->flags & IFF_ALLMULTI) {
 		ehea_allmulti(dev, 1);
@@ -1978,7 +1985,7 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 out:
 	ehea_update_bcmc_registrations();
-	mutex_unlock(&ehea_bcmc_regs.lock);
+	spin_unlock(&ehea_bcmc_regs.lock);
 	return;
 }
 
@@ -2497,7 +2504,7 @@ static int ehea_up(struct net_device *dev)
 		}
 	}
 
-	mutex_lock(&ehea_bcmc_regs.lock);
+	spin_lock(&ehea_bcmc_regs.lock);
 
 	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
 	if (ret) {
@@ -2520,7 +2527,7 @@ out:
 		ehea_info("Failed starting %s. ret=%i", dev->name, ret);
 
 	ehea_update_bcmc_registrations();
-	mutex_unlock(&ehea_bcmc_regs.lock);
+	spin_unlock(&ehea_bcmc_regs.lock);
 
 	ehea_update_firmware_handles();
 	mutex_unlock(&ehea_fw_handles.lock);
@@ -2575,7 +2582,7 @@ static int ehea_down(struct net_device *dev)
 
 	mutex_lock(&ehea_fw_handles.lock);
 
-	mutex_lock(&ehea_bcmc_regs.lock);
+	spin_lock(&ehea_bcmc_regs.lock);
 	ehea_drop_multicast_list(dev);
 	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 
@@ -2584,7 +2591,7 @@ static int ehea_down(struct net_device *dev)
 	port->state = EHEA_PORT_DOWN;
 
 	ehea_update_bcmc_registrations();
-	mutex_unlock(&ehea_bcmc_regs.lock);
+	spin_unlock(&ehea_bcmc_regs.lock);
 
 	ret = ehea_clean_all_portres(port);
 	if (ret)
@@ -2605,13 +2612,14 @@ static int ehea_stop(struct net_device *dev)
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
 
@@ -2941,7 +2949,7 @@ static void ehea_tx_watchdog(struct net_device *dev)
 
 	if (netif_carrier_ok(dev) &&
 	    !test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))
-		schedule_work(&port->reset_task);
+		ehea_schedule_port_reset(port);
 }
 
 int ehea_sense_adapter_attr(struct ehea_adapter *adapter)
@@ -3590,7 +3598,7 @@ int __init ehea_module_init(void)
 	memset(&ehea_bcmc_regs, 0, sizeof(ehea_bcmc_regs));
 
 	mutex_init(&ehea_fw_handles.lock);
-	mutex_init(&ehea_bcmc_regs.lock);
+	spin_lock_init(&ehea_bcmc_regs.lock);
 
 	ret = check_module_parm();
 	if (ret)
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 2cb2447..20d4fe9 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4194,12 +4194,23 @@ static int nv_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 
 	netif_carrier_off(dev);
 	if (netif_running(dev)) {
+		unsigned long flags;
+
 		nv_disable_irq(dev);
 		netif_tx_lock_bh(dev);
-		spin_lock(&np->lock);
+		/* with plain spinlock lockdep complains */
+		spin_lock_irqsave(&np->lock, flags);
 		/* stop engines */
+		/* FIXME:
+		 * this can take some time, and interrupts are disabled
+		 * due to spin_lock_irqsave, but let's hope no daemon
+		 * is going to change the settings very often...
+		 * Worst case:
+		 * NV_RXSTOP_DELAY1MAX + NV_TXSTOP_DELAY1MAX
+		 * + some minor delays, which is up to a second approximately
+		 */
 		nv_stop_rxtx(dev);
-		spin_unlock(&np->lock);
+		spin_unlock_irqrestore(&np->lock, flags);
 		netif_tx_unlock_bh(dev);
 	}
 
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index e363211..8268b35 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -463,6 +463,9 @@ static void restart(struct net_device *dev)
 	else
 		C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
 
+	/* Restore multicast and promiscuous settings */
+	set_multicast_list(dev);
+
 	S32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);
 }
 
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 5d2108c..babc79a 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1636,6 +1636,12 @@ static int emac_poll_rx(void *param, int budget)
 			goto next;
 		}
 
+		if (len < ETH_HLEN) {
+			++dev->estats.rx_dropped_stack;
+			emac_recycle_rx_skb(dev, slot, len);
+			goto next;
+		}
+
 		if (len && len < EMAC_RX_COPY_THRESH) {
 			struct sk_buff *copy_skb =
 			    alloc_skb(len + EMAC_RX_SKB_HEADROOM + 2, GFP_ATOMIC);
@@ -2719,6 +2725,8 @@ static int __devinit emac_probe(struct of_device *ofdev,
 	/* Clean rings */
 	memset(dev->tx_desc, 0, NUM_TX_BUFF * sizeof(struct mal_descriptor));
 	memset(dev->rx_desc, 0, NUM_RX_BUFF * sizeof(struct mal_descriptor));
+	memset(dev->tx_skb, 0, NUM_TX_BUFF * sizeof(struct sk_buff *));
+	memset(dev->rx_skb, 0, NUM_RX_BUFF * sizeof(struct sk_buff *));
 
 	/* Attach to ZMII, if needed */
 	if (emac_has_feature(dev, EMAC_FTR_HAS_ZMII) &&
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 3b2a6c5..993d87c 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -277,7 +277,7 @@ static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
 	*tcph = tcp_hdr(skb);
 
 	/* check if ip header and tcp header are complete */
-	if (iph->tot_len < ip_len + tcp_hdrlen(skb))
+	if (ntohs(iph->tot_len) < ip_len + tcp_hdrlen(skb))
 		return -1;
 
 	*hdr_flags = LRO_IPV4 | LRO_TCP;
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 520bb0b..6d35155 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -1008,6 +1008,7 @@ static int fr_rx(struct sk_buff *skb)
 		stats->rx_bytes += skb->len;
 		if (pvc->state.becn)
 			stats->rx_compressed++;
+		skb->dev = dev;
 		netif_rx(skb);
 		return NET_RX_SUCCESS;
 	} else {
