From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 7/9] jme: Refill receive unicase MAC addr after resume
Date: Mon, 14 Feb 2011 12:27:40 +0800
Message-ID: <1297657662-30289-7-git-send-email-cooldavid@cooldavid.org>
References: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:48734 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755481Ab1BNE2j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 23:28:39 -0500
In-Reply-To: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

The value of the register which holds receive Unicast MAC Address
sometimes get messed-up after resume.
This patch refill it before enabling the hardware filter.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   28 ++++++++++++++++++----------
 drivers/net/jme.h |    1 +
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index dd41324..ed35e17 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -898,6 +898,7 @@ jme_enable_rx_engine(struct jme_adapter *jme)
 	/*
 	 * Setup Unicast Filter
 	 */
+	jme_set_unicastaddr(jme->dev);
 	jme_set_multi(jme->dev);
 
 	/*
@@ -2114,27 +2115,34 @@ jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	return NETDEV_TX_OK;
 }
 
+static void
+jme_set_unicastaddr(struct net_device *netdev)
+{
+	struct jme_adapter *jme = netdev_priv(netdev);
+	u32 val;
+
+	val = (netdev->dev_addr[3] & 0xff) << 24 |
+	      (netdev->dev_addr[2] & 0xff) << 16 |
+	      (netdev->dev_addr[1] & 0xff) <<  8 |
+	      (netdev->dev_addr[0] & 0xff);
+	jwrite32(jme, JME_RXUMA_LO, val);
+	val = (netdev->dev_addr[5] & 0xff) << 8 |
+	      (netdev->dev_addr[4] & 0xff);
+	jwrite32(jme, JME_RXUMA_HI, val);
+}
+
 static int
 jme_set_macaddr(struct net_device *netdev, void *p)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
 	struct sockaddr *addr = p;
-	u32 val;
 
 	if (netif_running(netdev))
 		return -EBUSY;
 
 	spin_lock_bh(&jme->macaddr_lock);
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-
-	val = (addr->sa_data[3] & 0xff) << 24 |
-	      (addr->sa_data[2] & 0xff) << 16 |
-	      (addr->sa_data[1] & 0xff) <<  8 |
-	      (addr->sa_data[0] & 0xff);
-	jwrite32(jme, JME_RXUMA_LO, val);
-	val = (addr->sa_data[5] & 0xff) << 8 |
-	      (addr->sa_data[4] & 0xff);
-	jwrite32(jme, JME_RXUMA_HI, val);
+	jme_set_unicastaddr(netdev);
 	spin_unlock_bh(&jme->macaddr_lock);
 
 	return 0;
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 668958c..b7ae0c7 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -1258,6 +1258,7 @@ static inline int new_phy_power_ctrl(u8 chip_main_rev)
  */
 static int jme_set_settings(struct net_device *netdev,
 				struct ethtool_cmd *ecmd);
+static void jme_set_unicastaddr(struct net_device *netdev);
 static void jme_set_multi(struct net_device *netdev);
 
 #endif
-- 
1.7.2.2

