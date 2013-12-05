From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 06/16] bfin_mac: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:47:39 +0000
Message-ID: <1386287259.1516.131.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34846 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755111Ab3LEXrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:47:43 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only (thanks to the kbuild test robot).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/adi/bfin_mac.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 75fb1d20d6fd..0d4f29579879 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -667,8 +667,8 @@ static u32 bfin_select_phc_clock(u32 input_clk, unsigned int *shift_result)
 	return 1000000000UL / ppn;
 }
 
-static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
-		struct ifreq *ifr, int cmd)
+static int bfin_mac_hwtstamp_set(struct net_device *netdev,
+				 struct ifreq *ifr)
 {
 	struct hwtstamp_config config;
 	struct bfin_mac_local *lp = netdev_priv(netdev);
@@ -824,6 +824,16 @@ static int bfin_mac_hwtstamp_ioctl(struct net_device *netdev,
 		-EFAULT : 0;
 }
 
+static int bfin_mac_hwtstamp_get(struct net_device *netdev,
+				 struct ifreq *ifr)
+{
+	struct bfin_mac_local *lp = netdev_priv(netdev);
+
+	return copy_to_user(ifr->ifr_data, &lp->stamp_cfg,
+			    sizeof(lp->stamp_cfg)) ?
+		-EFAULT : 0;
+}
+
 static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
 {
 	struct bfin_mac_local *lp = netdev_priv(netdev);
@@ -1062,7 +1072,8 @@ static void bfin_phc_release(struct bfin_mac_local *lp)
 #else
 # define bfin_mac_hwtstamp_is_none(cfg) 0
 # define bfin_mac_hwtstamp_init(dev)
-# define bfin_mac_hwtstamp_ioctl(dev, ifr, cmd) (-EOPNOTSUPP)
+# define bfin_mac_hwtstamp_set(dev, ifr) (-EOPNOTSUPP)
+# define bfin_mac_hwtstamp_get(dev, ifr) (-EOPNOTSUPP)
 # define bfin_rx_hwtstamp(dev, skb)
 # define bfin_tx_hwtstamp(dev, skb)
 # define bfin_phc_init(netdev, dev) 0
@@ -1496,7 +1507,9 @@ static int bfin_mac_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
-		return bfin_mac_hwtstamp_ioctl(netdev, ifr, cmd);
+		return bfin_mac_hwtstamp_set(netdev, ifr);
+	case SIOCGHWTSTAMP:
+		return bfin_mac_hwtstamp_get(netdev, ifr);
 	default:
 		if (lp->phydev)
 			return phy_mii_ioctl(lp->phydev, ifr, cmd);


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
