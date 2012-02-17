From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 08/10] ethoc: set addr_assign_type if random_ether_addr() used
Date: Fri, 17 Feb 2012 16:43:29 +0100
Message-ID: <1329493411-25750-9-git-send-email-danny.kukawka@bisect.de>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Richard Cochran <richard.cochran@omicron.at>,
	Jiri Kosina <jkosina@suse.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set addr_assign_type correctly to NET_ADDR_RANDOM in case
a random MAC address was generated and assigned to the netdevice.

Fixed ethoc_set_mac_address() to check if the given mac
address is valid and set also dev_addr of the net_device.
Check also the return value of ethoc_set_mac_address() in
ethoc_probe().

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

v2: set net_device->dev_addr in ethoc_set_mac_address(),
    check if given address is valid

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/ethoc.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 60f0e78..cfc0ce0 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -776,10 +776,16 @@ static int ethoc_set_mac_address(struct net_device *dev, void *addr)
 	struct ethoc *priv = netdev_priv(dev);
 	u8 *mac = (u8 *)addr;
 
+	if(!is_valid_ether_addr(mac))
+		return -EADDRNOTAVAIL;
+        
 	ethoc_write(priv, MAC_ADDR0, (mac[2] << 24) | (mac[3] << 16) |
 				     (mac[4] <<  8) | (mac[5] <<  0));
 	ethoc_write(priv, MAC_ADDR1, (mac[0] <<  8) | (mac[1] <<  0));
 
+	memcpy(dev->dev_addr, mac, ETH_ALEN);
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
+
 	return 0;
 }
 
@@ -909,6 +915,7 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 	unsigned int phy;
 	int num_bd;
 	int ret = 0;
+	bool random_mac = false;
 
 	/* allocate networking device */
 	netdev = alloc_etherdev(sizeof(struct ethoc));
@@ -1050,10 +1057,19 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 
 	/* Check the MAC again for validity, if it still isn't choose and
 	 * program a random one. */
-	if (!is_valid_ether_addr(netdev->dev_addr))
+	if (!is_valid_ether_addr(netdev->dev_addr)) {
 		random_ether_addr(netdev->dev_addr);
+		random_mac = true;
+	}
 
-	ethoc_set_mac_address(netdev, netdev->dev_addr);
+	ret = ethoc_set_mac_address(netdev, netdev->dev_addr);
+	if (ret) {
+		dev_err(&netdev->dev, "failed to set MAC address\n");
+		goto error;
+	}
+	
+	if (random_mac)
+		netdev->addr_assign_type |= NET_ADDR_RANDOM;
 
 	/* register MII bus */
 	priv->mdio = mdiobus_alloc();
-- 
1.7.8.3
