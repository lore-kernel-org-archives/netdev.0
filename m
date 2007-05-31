From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH]: sky2: Fix VLAN unregistration
Date: Thu, 31 May 2007 10:19:45 -0700
Message-ID: <20070531101945.2b19faa7@freepuppy>
References: <4659D174.70301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:45761 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754782AbXEaRbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 13:31:10 -0400
In-Reply-To: <4659D174.70301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 27 May 2007 20:44:04 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Fix sky2 disabling VLAN completely when the first vid is unregistered.
> 
> For some reason the VLAN code insists on the driver providing a
> vlan_rx_kill_vid function even if only NETIF_F_HW_VLAN_RX and not
> NETIF_F_HW_VLAN_FILTER is set, so this patch keeps an empty
> function. This seems to be a bug though, vlan_rx_add_vid is only
> required with NETIF_F_HW_VLAN_FILTER. Ben?
> 

Reading other drivers, it looks like a better patch would be to
handle mode change in both set and kill.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

 drivers/net/sky2.c |   32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

--- a/drivers/net/sky2.c	2007-05-31 10:00:34.000000000 -0700
+++ b/drivers/net/sky2.c	2007-05-31 10:15:53.000000000 -0700
@@ -1042,34 +1042,50 @@ static int sky2_ioctl(struct net_device 
 }
 
 #ifdef SKY2_VLAN_TAG_USED
-static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
+static void sky2_set_vlan_mode(struct sky2_port *sky2)
 {
-	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	u16 port = sky2->port;
 
+	if (sky2->vlgrp) {
+		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
+			     RX_VLAN_STRIP_ON);
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_VLAN_TAG_ON);
+	} else {
+		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
+			     RX_VLAN_STRIP_OFF);
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_VLAN_TAG_OFF);
+	}
+}
+
+static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
+{
+	struct sky2_port *sky2 = netdev_priv(dev);
+
 	netif_tx_lock_bh(dev);
+	netif_poll_disable(sky2->hw->dev[0]);
 
-	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), RX_VLAN_STRIP_ON);
-	sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_VLAN_TAG_ON);
 	sky2->vlgrp = grp;
+	sky2_set_vlan_mode(sky2);
 
 	netif_tx_unlock_bh(dev);
+	netif_poll_enable(sky2->hw->dev[0]);
 }
 
 static void sky2_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	struct sky2_hw *hw = sky2->hw;
-	u16 port = sky2->port;
 
 	netif_tx_lock_bh(dev);
+	netif_poll_disable(sky2->hw->dev[0]);
 
-	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), RX_VLAN_STRIP_OFF);
-	sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_VLAN_TAG_OFF);
 	vlan_group_set_device(sky2->vlgrp, vid, NULL);
+	sky2_set_vlan_mode(sky2);
 
 	netif_tx_unlock_bh(dev);
+	netif_poll_enable(sky2->hw->dev[0]);
 }
 #endif
 
