From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.18-rc7 2/9] NetXen: Hardware access routines
Date: Tue, 19 Sep 2006 08:20:47 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609190819220.25990@dut39>
References: <Pine.LNX.4.64.0609151124560.7710@dut39> <Pine.LNX.4.64.0609151139170.7710@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	brazilnut@us.ibm.com, wendyx@us.ibm.com,
	"Amit S. Kale" <amitkale@netxen.com>,
	Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:51823 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1750840AbWISPUw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 11:20:52 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0609151139170.7710@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_hw.c linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_hw.c
--- linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_hw.c	2006-09-15 10:51:59.000000000 -0700
+++ linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_hw.c	2006-09-19 07:51:20.000000000 -0700
@@ -44,7 +44,6 @@
  #define NETXEN_PHANTOM_MEM_BASE	(NETXEN_FLASH_BASE)
  #define NETXEN_MAX_MTU		8000
  #define NETXEN_MIN_MTU          64
-#define NETXEN_MTU_MASK		0xFFFF0000
  #define NETXEN_ETH_FCS_SIZE     4
  #define NETXEN_ENET_HEADER_SIZE 14
  #define NETXEN_WINDOW_ONE 0x2000000	/* CRB Window: bit 25 of CRB address */
@@ -77,9 +76,9 @@
  	return 0;
  }

-/**
+/*
   * netxen_nic_set_multi - Multicast
- **/
+ */
  void netxen_nic_set_multi(struct net_device *netdev)
  {
  	struct netxen_port *port = netdev_priv(netdev);
@@ -89,15 +88,15 @@

  	mc_ptr = netdev->mc_list;
  	if (netdev->flags & IFF_PROMISC) {
-		if (adapter->ops->set_promisc_mode)
-			adapter->ops->set_promisc_mode(adapter,
-						       port->portnum,
-						       NETXEN_NIU_PROMISCOUS_MODE);
+		if (adapter->ops->set_promisc)
+			adapter->ops->set_promisc(adapter,
+						  port->portnum,
+						  NETXEN_NIU_PROMISC_MODE);
  	} else {
-		if (adapter->ops->unset_promisc_mode)
-			adapter->ops->unset_promisc_mode(adapter,
-							 port->portnum,
-							 NETXEN_NIU_NON_PROMISCOUS_MODE);
+		if (adapter->ops->unset_promisc)
+			adapter->ops->unset_promisc(adapter,
+						    port->portnum,
+						    NETXEN_NIU_NON_PROMISC_MODE);
  	}
  	if (adapter->ahw.board_type == NETXEN_NIC_XGBE) {
  		netxen_nic_mcr_set_mode_select(netxen_mac_addr_cntl_data, 0x03);
@@ -136,31 +135,21 @@
   * netxen_nic_change_mtu - Change the Maximum Transfer Unit
   * @returns 0 on success, negative on failure
   */
-int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu)
+int netxen_nic_change_mtu(struct net_device *netdev, int mtu)
  {
  	struct netxen_port *port = netdev_priv(netdev);
-	int max_mtu = new_mtu + NETXEN_ENET_HEADER_SIZE + NETXEN_ETH_FCS_SIZE;
-
-	if (max_mtu & NETXEN_MTU_MASK)
-		return -EINVAL;
-
-	if (max_mtu > NETXEN_MAX_MTU) {
-		printk(KERN_ERR
-		       "%s: %s MTU > NETXEN_MAX_MTU is not supported\n",
-		       netxen_nic_driver_name, netdev->name);
-		return -EINVAL;
-	}
+	struct netxen_adapter *adapter = port->adapter;
+	int eff_mtu = mtu + NETXEN_ENET_HEADER_SIZE + NETXEN_ETH_FCS_SIZE;

-	if (max_mtu > NETXEN_MIN_MTU) {
-		printk(KERN_ERR
-		       "%s: %s MTU < NETXEN_MIN_MTU is not supported\n",
-		       netxen_nic_driver_name, netdev->name);
+	if ((eff_mtu > NETXEN_MAX_MTU) || (eff_mtu < NETXEN_MIN_MTU)) {
+		printk(KERN_ERR "%s: %s %d is not supported.\n",
+		       netxen_nic_driver_name, netdev->name, mtu);
  		return -EINVAL;
  	}

-	if (port->adapter->ops->set_mtu)
-		port->adapter->ops->set_mtu(port, new_mtu);
-	netdev->mtu = new_mtu;
+	if (adapter->ops->set_mtu)
+		adapter->ops->set_mtu(port, mtu);
+	netdev->mtu = mtu;

  	return 0;
  }
@@ -181,7 +170,7 @@
  	struct netxen_rcv_desc_crb *rcv_desc_crb = NULL;
  	struct netxen_recv_context *recv_ctx;
  	struct netxen_rcv_desc_ctx *rcv_desc;
-	struct cmd_desc_type0_t *pcmd;
+	struct cmd_desc_type0 *pcmd;

  	DPRINTK(INFO, "pci_base: %lx\n", adapter->ahw.pci_base);
  	DPRINTK(INFO, "crb_base: %lx %lx", NETXEN_PCI_CRBSPACE,
@@ -226,7 +215,7 @@
  	DPRINTK(INFO, "Recieve Peg ready too. starting stuff\n");

  	addr = pci_alloc_consistent(adapter->ahw.pdev,
-				    sizeof(struct cmd_desc_type0_t) *
+				    sizeof(struct cmd_desc_type0) *
  				    adapter->max_tx_desc_count,
  				    &hw->cmd_desc_phys_addr);
  	if (addr == NULL) {
@@ -236,16 +225,16 @@
  	}

  	/* we need to prelink all of the cmd descriptors */
-	pcmd = (struct cmd_desc_type0_t *)addr;
+	pcmd = (struct cmd_desc_type0 *)addr;
  	for (i = 1; i < adapter->max_tx_desc_count; i++) {
  		pcmd->netxen_next =
-		    (card_cmdring + i * sizeof(struct cmd_desc_type0_t));
+		    (card_cmdring + i * sizeof(struct cmd_desc_type0));
  		pcmd++;
  	}
  	/* fill in last link (point to first) */
  	pcmd->netxen_next = card_cmdring;

-	hw->cmd_desc_head = (struct cmd_desc_type0_t *)addr;
+	hw->cmd_desc_head = (struct cmd_desc_type0 *)addr;

  	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
  		recv_ctx = &adapter->recv_ctx[ctx];
@@ -262,7 +251,7 @@
  				err = -ENOMEM;
  				return err;
  			}
-			rcv_desc->desc_head = (struct rcv_desc_t *)addr;
+			rcv_desc->desc_head = (struct rcv_desc *)addr;
  		}

  		addr = pci_alloc_consistent(adapter->ahw.pdev,
@@ -276,7 +265,7 @@
  			err = -ENOMEM;
  			return err;
  		}
-		recv_ctx->rcv_status_desc_head = (struct status_desc_t *)addr;
+		recv_ctx->rcv_status_desc_head = (struct status_desc *)addr;
  		for (ring = 0; ring < NUM_RCV_DESC_RINGS; ring++) {
  			rcv_desc = &recv_ctx->rcv_desc[ring];
  			rcv_desc_crb =
@@ -322,7 +311,7 @@

  	if (adapter->ahw.cmd_desc_head != NULL) {
  		pci_free_consistent(adapter->ahw.pdev,
-				    sizeof(struct cmd_desc_type0_t) *
+				    sizeof(struct cmd_desc_type0) *
  				    adapter->max_tx_desc_count,
  				    adapter->ahw.cmd_desc_head,
  				    adapter->ahw.cmd_desc_phys_addr);
@@ -355,7 +344,7 @@
  }

  void netxen_tso_check(struct netxen_adapter *adapter,
-		      struct cmd_desc_type0_t *desc, struct sk_buff *skb)
+		      struct cmd_desc_type0 *desc, struct sk_buff *skb)
  {
  	if (desc->mss) {
  		desc->total_hdr_length = sizeof(struct ethhdr) +
@@ -838,9 +827,10 @@
  	netxen_nic_read_w0(adapter, NETXEN_NIU_MODE, &mode);
  	if (netxen_get_niu_enable_ge(mode)) {	/* Gb 10/100/1000 Mbps mode */
  		if (adapter->ops->phy_read
-		    && adapter->ops->phy_read(adapter, port->portnum,
-					      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					      &status) == 0) {
+		    && adapter->ops->
+		    phy_read(adapter, port->portnum,
+			     NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
+			     &status) == 0) {
  			if (netxen_get_phy_link(status)) {
  				switch (netxen_get_phy_speed(status)) {
  				case 0:
@@ -853,7 +843,7 @@
  					port->link_speed = SPEED_1000;
  					break;
  				default:
-					port->link_speed = -1;	/* unknown speed */
+					port->link_speed = -1;
  					break;
  				}
  				switch (netxen_get_phy_duplex(status)) {
@@ -864,15 +854,14 @@
  					port->link_duplex = DUPLEX_FULL;
  					break;
  				default:
-					port->link_duplex = -1;	/* unknown mode */
+					port->link_duplex = -1;
  					break;
  				}
  				if (adapter->ops->phy_read
-				    && adapter->ops->phy_read(adapter,
-							      port->portnum,
-							      NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-							      (__le32 *) &
-							      autoneg) != 0)
+				    && adapter->ops->
+				    phy_read(adapter, port->portnum,
+					     NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
+					     (__le32 *) & autoneg) != 0)
  					port->link_autoneg = autoneg;
  			} else
  				goto link_down;

