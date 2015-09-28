From: Liviu Dudau <Liviu.Dudau@arm.com>
Subject: RESEND: [PATCH v3 net-next] sky2: use random address if EEPROM is bad
Date: Mon, 28 Sep 2015 17:51:51 +0100
Message-ID: <1443459111-15595-1-git-send-email-Liviu.Dudau@arm.com>
Cc: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Mirko Lindner <mlindner@marvell.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ryan Harkin <ryan.harkin@linaro.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some embedded systems the EEPROM does not contain a valid MAC address.
In that case it is better to fallback to a generated mac address and
let init scripts fix the value later.

Reported-by: Liviu Dudau <Liviu.Dudau@arm.com>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
[Changed handcoded setup to use eth_hw_addr_random() and to save new address into HW]
Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>
---
 drivers/net/ethernet/marvell/sky2.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index d9f4498..5606a04 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -4819,6 +4819,18 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
 		memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
 			      ETH_ALEN);
 
+	/* if the address is invalid, use a random value */
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		struct sockaddr sa = { AF_UNSPEC };
+
+		netdev_warn(dev,
+			    "Invalid MAC address, defaulting to random\n");
+		eth_hw_addr_random(dev);
+		memcpy(sa.sa_data, dev->dev_addr, ETH_ALEN);
+		if (sky2_set_mac_address(dev, &sa))
+			netdev_warn(dev, "Failed to set MAC address.\n");
+	}
+
 	return dev;
 }
 
-- 
2.5.1
