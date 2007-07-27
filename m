From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [PATCH 2/2] HW VLAN filtering control (resend)
Date: Fri, 27 Jul 2007 14:30:27 -0700
Message-ID: <1185571827.28574.26.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31809 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933586AbXG0Va1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 17:30:27 -0400
Received: from strongmad.jf.intel.com (strongmad.jf.intel.com [10.23.35.99])
	by nwlxmail01.jf.intel.com (8.12.11.20060308/8.12.9/MailSET/Hub) with ESMTP id l6RLURuK011351
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2007 14:30:27 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support to e1000 for enabling/disabling hardware VLAN filtering
at runtime.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urpN -X dontdiff linux-2.6.22.1-clean/drivers/net/e1000/e1000_main.c linux-2.6.22.1/drivers/net/e1000/e1000_main.c
--- linux-2.6.22.1-clean/drivers/net/e1000/e1000_main.c	2007-07-10 11:56:30.000000000 -0700
+++ linux-2.6.22.1/drivers/net/e1000/e1000_main.c	2007-07-27 13:16:52.000000000 -0700
@@ -197,6 +197,9 @@ static void e1000_vlan_rx_register(struc
 static void e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid);
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
+#ifdef HAVE_VLAN_FLAGS
+static int e1000_vlan_set_flag(struct net_device *netdev, unsigned int flag, int value);
+#endif
 
 static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
 #ifdef CONFIG_PM
@@ -938,6 +941,10 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->vlan_rx_register = e1000_vlan_rx_register;
 	netdev->vlan_rx_add_vid = e1000_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = e1000_vlan_rx_kill_vid;
+#ifdef HAVE_VLAN_FLAGS
+	netdev->vlan_set_flag = e1000_vlan_set_flag;
+#endif
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e1000_netpoll;
 #endif
@@ -4973,7 +4980,42 @@ e1000_vlan_rx_register(struct net_device
 
 	e1000_irq_enable(adapter);
 }
+#ifdef HAVE_VLAN_FLAGS
+static int
+e1000_vlan_set_flag(struct net_device *netdev, unsigned int flag, int value)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	uint32_t rctl;
 
+	/* The only flag we currently care about is bit 1,
+	   which controls HW filtering. */
+	e1000_irq_disable(adapter);
+	if (adapter->hw.mac_type == e1000_ich8lan)
+		return -EPERM;
+
+	if (flag == VLAN_FLAG_DISABLE_FILTER) {
+		if (value) {
+			/* disable VLAN filtering */
+			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl &= ~E1000_RCTL_VFE;
+			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			netdev->features &= ~NETIF_F_HW_VLAN_FILTER;
+		} else {
+			/* enable VLAN receive filtering */
+			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl |= E1000_RCTL_VFE;
+			rctl &= ~E1000_RCTL_CFIEN;
+			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			netdev->features |= NETIF_F_HW_VLAN_FILTER;
+			e1000_restore_vlan(adapter);
+			e1000_update_mng_vlan(adapter);
+		}
+	}
+
+	e1000_irq_enable(adapter);
+	return 0;
+}
+#endif
 static void
 e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
 {
