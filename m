From: Jeff Garzik <jgarzik@pobox.com>
Subject: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Fri, 21 Mar 2003 09:46:04 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E7B25AC.5030604@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010801030101000207060008"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010801030101000207060008
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

For review by the list... The other e100/e1000 changes are in the 2.5 
nightly snapshot on kernel.org...

--------------010801030101000207060008
Content-Type: message/rfc822;
 name="[E1000] NAPI re-insertion w/ changes"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="[E1000] NAPI re-insertion w/ changes"

Return-Path: <bk-commits-head-owner@vger.kernel.org>
Delivered-To: garzik@gtf.org
Received: from kumquat.pobox.com (kumquat.pobox.com [64.119.218.68])
	by havoc.gtf.org (Postfix) with ESMTP id CDD6A6646
	for <garzik@gtf.org>; Fri, 21 Mar 2003 07:35:11 +0000 (US/Central)
Received: from kumquat.pobox.com (localhost.localdomain [127.0.0.1])
	by kumquat.pobox.com (Postfix) with ESMTP id E46D759E7A
	for <garzik@gtf.org>; Fri, 21 Mar 2003 02:35:10 -0500 (EST)
Delivered-To: jgarzik@pobox.com
Received: from vger.kernel.org (vger.kernel.org [209.116.70.75])
	by kumquat.pobox.com (Postfix) with ESMTP id AD87C59E7F
	for <jgarzik@pobox.com>; Fri, 21 Mar 2003 02:35:09 -0500 (EST)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
	id <S263465AbTCUHYE>; Fri, 21 Mar 2003 02:24:04 -0500
Received: (majordomo@vger.kernel.org) by vger.kernel.org
	id <S263545AbTCUHYE>; Fri, 21 Mar 2003 02:24:04 -0500
Received: from hera.kernel.org ([63.209.29.2]:11673 "EHLO hera.kernel.org")
	by vger.kernel.org with ESMTP id <S263465AbTCUHCv>;
	Fri, 21 Mar 2003 02:02:51 -0500
Received: (from dwmw2@localhost)
	by hera.kernel.org (8.11.6/8.11.6) id h2L7Dn802239
	for bk-commits-head@vger.kernel.org; Thu, 20 Mar 2003 23:13:49 -0800
Message-Id: <200303210713.h2L7Dn802239@hera.kernel.org>
Subject: [E1000] NAPI re-insertion w/ changes
Date: Fri, 21 Mar 2003 04:46:10 +0000
From: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: bk-commits-head@vger.kernel.org
X-BK-Repository: hera.kernel.org:/home/dwmw2/BK/linus-2.5
X-BK-ChangeSetKey: cramerj@intel.com|ChangeSet|20030321044610|02292
Sender: bk-commits-head-owner@vger.kernel.org
Precedence: bulk
X-Mailing-List: bk-commits-head@vger.kernel.org
X-Spam-Status: No, hits=0.0 required=5.0
	tests=PATCH_UNIFIED_DIFF,SPAM_PHRASE_00_01,TO_BE_REMOVED_REPLY,
	      X_MAILING_LIST
	version=2.43
X-Spam-Level: 

ChangeSet 1.1101.22.17, 2003/03/20 23:46:10-05:00, cramerj@intel.com

	[E1000] NAPI re-insertion w/ changes
	
	* Previous patch wiped NAPI support, adding it back here.  But,
	  with a twist: this one doesn't disable/enable interrupts each
	  time we enter/leave polling.  (It's EXPERIMENTAL).


# This patch includes the following deltas:
#	           ChangeSet	1.1101.22.16 -> 1.1101.22.17
#	drivers/net/e1000/e1000_main.c	1.60    -> 1.61   
#

 e1000_main.c |   70 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 69 insertions(+), 1 deletion(-)


diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	Thu Mar 20 23:13:52 2003
+++ b/drivers/net/e1000/e1000_main.c	Thu Mar 20 23:13:52 2003
@@ -155,8 +155,14 @@
 static inline void e1000_irq_disable(struct e1000_adapter *adapter);
 static inline void e1000_irq_enable(struct e1000_adapter *adapter);
 static void e1000_intr(int irq, void *data, struct pt_regs *regs);
-static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter);
+#ifdef CONFIG_E1000_NAPI
+static int e1000_clean(struct net_device *netdev, int *budget);
+static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter,
+                                    int *work_done, int work_to_do);
+#else
 static boolean_t e1000_clean_rx_irq(struct e1000_adapter *adapter);
+#endif
+static boolean_t e1000_clean_tx_irq(struct e1000_adapter *adapter);
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter);
 static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
 static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
@@ -418,6 +424,10 @@
 	netdev->do_ioctl = &e1000_ioctl;
 	netdev->tx_timeout = &e1000_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
+#ifdef CONFIG_E1000_NAPI
+	netdev->poll = &e1000_clean;
+	netdev->weight = 64;
+#endif
 	netdev->vlan_rx_register = e1000_vlan_rx_register;
 	netdev->vlan_rx_add_vid = e1000_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = e1000_vlan_rx_kill_vid;
@@ -1977,7 +1987,9 @@
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev->priv;
 	uint32_t icr = E1000_READ_REG(&adapter->hw, ICR);
+#ifndef CONFIG_E1000_NAPI
 	int i;
+#endif
 
 	if(!icr)
 		return;  /* Not our interrupt */
@@ -1987,12 +1999,46 @@
 		mod_timer(&adapter->watchdog_timer, jiffies);
 	}
 
+#ifdef CONFIG_E1000_NAPI
+	/* Don't disable interrupts - rely on h/w interrupt
+	 * moderation to keep interrupts low.  netif_rx_schedule
+	 * is NOP if already polling. */
+	netif_rx_schedule(netdev);
+#else
 	for(i = 0; i < E1000_MAX_INTR; i++)
 		if(!e1000_clean_rx_irq(adapter) &&
 		   !e1000_clean_tx_irq(adapter))
 			break;
+#endif
+}
 
+#ifdef CONFIG_E1000_NAPI
+/**
+ * e1000_clean - NAPI Rx polling callback
+ * @adapter: board private structure
+ **/
+
+static int
+e1000_clean(struct net_device *netdev, int *budget)
+{
+	struct e1000_adapter *adapter = netdev->priv;
+	int work_to_do = min(*budget, netdev->quota);
+	int work_done = 0;
+	
+	while(work_done < work_to_do)
+		if(!e1000_clean_rx_irq(adapter, &work_done, work_to_do) &&
+		   !e1000_clean_tx_irq(adapter))
+			break;
+
+	*budget -= work_done;
+	netdev->quota -= work_done;
+	
+	if(work_done < work_to_do)
+		netif_rx_complete(netdev);
+
+	return (work_done >= work_to_do);
 }
+#endif
 
 /**
  * e1000_clean_tx_irq - Reclaim resources after transmit completes
@@ -2054,7 +2100,12 @@
  **/
 
 static boolean_t
+#ifdef CONFIG_E1000_NAPI
+e1000_clean_rx_irq(struct e1000_adapter *adapter, int *work_done,
+                   int work_to_do)
+#else
 e1000_clean_rx_irq(struct e1000_adapter *adapter)
+#endif
 {
 	struct e1000_desc_ring *rx_ring = &adapter->rx_ring;
 	struct net_device *netdev = adapter->netdev;
@@ -2071,6 +2122,13 @@
 
 	while(rx_desc->status & E1000_RXD_STAT_DD) {
 
+#ifdef CONFIG_E1000_NAPI
+		if(*work_done >= work_to_do)
+			break;
+
+		(*work_done)++;
+#endif
+
 		cleaned = TRUE;
 
 		pci_unmap_single(pdev,
@@ -2133,12 +2191,22 @@
 		e1000_rx_checksum(adapter, rx_desc, skb);
 
 		skb->protocol = eth_type_trans(skb, netdev);
+#ifdef CONFIG_E1000_NAPI
+		if(adapter->vlgrp && (rx_desc->status & E1000_RXD_STAT_VP)) {
+			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
+				(rx_desc->special & E1000_RXD_SPC_VLAN_MASK));
+		} else {
+			netif_receive_skb(skb);
+		}
+#else /* CONFIG_E1000_NAPI */
 		if(adapter->vlgrp && (rx_desc->status & E1000_RXD_STAT_VP)) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
 				(rx_desc->special & E1000_RXD_SPC_VLAN_MASK));
 		} else {
 			netif_rx(skb);
 		}
+#endif /* CONFIG_E1000_NAPI */
+
 		netdev->last_rx = jiffies;
 
 		rx_desc->status = 0;
-
To unsubscribe from this list: send the line "unsubscribe bk-commits-head" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



--------------010801030101000207060008--
