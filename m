From: Jonathan Nieder <jrnieder@gmail.com>
Subject: [PATCH 2.6.32.y] netxen: support for GbE port settings
Date: Sun, 11 Mar 2012 23:35:39 -0500
Message-ID: <20120312043539.GA15903@burratino>
References: <1300172175-16853-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	Sony Chacko <sony.chacko@qlogic.com>,
	Ana Guerrero <ana@debian.org>,
	Michael Mastrogiacomo <mmastrogiacomo@ultralogistics.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46896 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab2CLEfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 00:35:52 -0400
Content-Disposition: inline
In-Reply-To: <1300172175-16853-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Tue, 15 Mar 2011 14:54:55 -0700

commit bfd823bd74333615783d8108889814c6d82f2ab0 upstream.

o Enable setting speed and auto negotiation parameters for GbE ports.
o Hardware do not support half duplex setting currently.

David Miller:
	Amit please update your patch to silently reject link setting
	attempts that are unsupported by the device.

[jn: backported for 2.6.32.y by Ana Guerrero]

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Tested-by: Ana Guerrero <ana@debian.org> # HP NC375i
Signed-off-by: Jonathan Nieder <jrnieder@gmail.com>
---
Hi Dave,

Michael Mastrogiacomo reports[1]:

> The HP NC375i network card on an HP ML370 G6 server with Debian
> squeeze OS installed as problems.
>
> The server is connected to a switch that does only 100/full and it
> fails to autonegotiate correctly during reboot.  A network
> connection can be used if the switch side gets locked to 100 half
> however which seems to be what the HP card assumes if negotiaton
> fails.  The HP card seems to assume a speed of 1000 which is
> incorrect.  It should learn a speed of 100 advertised by the switch
> which it fails to do.  
>
> Certain ethtool and miitool functions do not seem to work such as
> ethtool -s (you can't set any parameters at all).   ethtool -t also
> fails.  

Ana Guerrero wrote:

> Yes, it is a driver bug. We hit in this same problem because the
> switches are not configured to allow auto-negociated GbE.
> Eg with ethtool:
> 
> # ethtool -s eth0 autoneg off
>     Cannot set new settings: Input/output error not setting autoneg
> #
> 
> The patch at
> [...]h=bfd823bd74333615783d8108889814c6d82f2ab0
>
> fixes this problem. I am attaching it already updated to work on top
> of 2.6.32-41.
>
> The patch has been tested successfully with a HP NC3751 card like
> the reporter.

Therefore I would like to see this patch in a future 2.6.32.y kernel,
so everyone using that as a baseline can benefit from the fix.  The
patch hit mainline in the 2.6.39 merge window.

What is the right way to submit networking patches for the 2.6.32.y
tree?  Should I send them to you or directly to Willy, are your
requirements for them the same as the usual stable_kernel_rules.txt or
other ones, and is [2] the right place to find a preview of patches
destined for longterm trees or do they go somewhere else?

Looking forward to your thoughts,
Jonathan

[1] http://bugs.debian.org/638921
[2] http://patchwork.ozlabs.org/bundle/davem/stable/?state=*

 drivers/net/netxen/netxen_nic.h         |    7 +++-
 drivers/net/netxen/netxen_nic_ctx.c     |   15 ++++++++
 drivers/net/netxen/netxen_nic_ethtool.c |   58 ++++++++-----------------------
 3 files changed, 35 insertions(+), 45 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index e52af5b75b18..50d2af886cd1 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -700,7 +700,8 @@ struct netxen_recv_context {
 #define NX_CDRP_CMD_READ_PEXQ_PARAMETERS	0x0000001c
 #define NX_CDRP_CMD_GET_LIC_CAPABILITIES	0x0000001d
 #define NX_CDRP_CMD_READ_MAX_LRO_PER_BOARD	0x0000001e
-#define NX_CDRP_CMD_MAX				0x0000001f
+#define NX_CDRP_CMD_CONFIG_GBE_PORT		0x0000001f
+#define NX_CDRP_CMD_MAX				0x00000020
 
 #define NX_RCODE_SUCCESS		0
 #define NX_RCODE_NO_HOST_MEM		1
@@ -1015,6 +1016,7 @@ typedef struct {
 #define NX_FW_CAPABILITY_BDG			(1 << 8)
 #define NX_FW_CAPABILITY_FVLANTX		(1 << 9)
 #define NX_FW_CAPABILITY_HW_LRO			(1 << 10)
+#define NX_FW_CAPABILITY_GBE_LINK_CFG		(1 << 11)
 
 /* module types */
 #define LINKEVENT_MODULE_NOT_PRESENT			1
@@ -1323,6 +1325,9 @@ int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip, int cmd);
 int netxen_linkevent_request(struct netxen_adapter *adapter, int enable);
 void netxen_advert_link_change(struct netxen_adapter *adapter, int linkup);
 
+int nx_fw_cmd_set_gbe_port(struct netxen_adapter *adapter,
+		u32 speed, u32 duplex, u32 autoneg);
+
 int nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu);
 int netxen_nic_change_mtu(struct net_device *netdev, int new_mtu);
 int netxen_config_hw_lro(struct netxen_adapter *adapter, int enable);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 9cb8f6878047..f48cdb2bfaf0 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -112,6 +112,21 @@ nx_fw_cmd_set_mtu(struct netxen_adapter *adapter, int mtu)
 	return 0;
 }
 
+int
+nx_fw_cmd_set_gbe_port(struct netxen_adapter *adapter,
+	u32 speed, u32 duplex, u32 autoneg)
+{
+
+	return netxen_issue_cmd(adapter,
+		adapter->ahw.pci_func,
+		NXHAL_VERSION,
+		speed,
+		duplex,
+		autoneg,
+		NX_CDRP_CMD_CONFIG_GBE_PORT);
+
+}
+
 static int
 nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 {
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 714f38791a9a..7e34840dfe59 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -216,7 +216,6 @@ skip:
 			check_sfp_module = netif_running(dev) &&
 				adapter->has_link_events;
 		} else {
-			ecmd->autoneg = AUTONEG_ENABLE;
 			ecmd->supported |= (SUPPORTED_TP |SUPPORTED_Autoneg);
 			ecmd->advertising |=
 				(ADVERTISED_TP | ADVERTISED_Autoneg);
@@ -254,53 +253,24 @@ static int
 netxen_nic_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
-	__u32 status;
+	int ret;
 
-	/* read which mode */
-	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
-		/* autonegotiation */
-		if (adapter->phy_write
-		    && adapter->phy_write(adapter,
-					  NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG,
-					  ecmd->autoneg) != 0)
-			return -EIO;
-		else
-			adapter->link_autoneg = ecmd->autoneg;
+	if (adapter->ahw.port_type != NETXEN_NIC_GBE)
+		return -EOPNOTSUPP;
 
-		if (adapter->phy_read
-		    && adapter->phy_read(adapter,
-					 NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					 &status) != 0)
-			return -EIO;
+	if (!(adapter->capabilities & NX_FW_CAPABILITY_GBE_LINK_CFG))
+		return -EOPNOTSUPP;
 
-		/* speed */
-		switch (ecmd->speed) {
-		case SPEED_10:
-			netxen_set_phy_speed(status, 0);
-			break;
-		case SPEED_100:
-			netxen_set_phy_speed(status, 1);
-			break;
-		case SPEED_1000:
-			netxen_set_phy_speed(status, 2);
-			break;
-		}
-		/* set duplex mode */
-		if (ecmd->duplex == DUPLEX_HALF)
-			netxen_clear_phy_duplex(status);
-		if (ecmd->duplex == DUPLEX_FULL)
-			netxen_set_phy_duplex(status);
-		if (adapter->phy_write
-		    && adapter->phy_write(adapter,
-					  NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
-					  *((int *)&status)) != 0)
-			return -EIO;
-		else {
-			adapter->link_speed = ecmd->speed;
-			adapter->link_duplex = ecmd->duplex;
-		}
-	} else
+	ret = nx_fw_cmd_set_gbe_port(adapter, ecmd->speed, ecmd->duplex,
+				     ecmd->autoneg);
+	if (ret == NX_RCODE_NOT_SUPPORTED)
 		return -EOPNOTSUPP;
+	else if (ret)
+		return -EIO;
+
+	adapter->link_speed = ecmd->speed;
+	adapter->link_duplex = ecmd->duplex;
+	adapter->link_autoneg = ecmd->autoneg;
 
 	if (!netif_running(dev))
 		return 0;
-- 
1.7.9.2
