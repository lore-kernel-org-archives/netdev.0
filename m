From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/2] net: dsa: introduce MICREL KSZ8893MQL/BL ethernet
 switch chip support
Date: Wed, 21 Jul 2010 09:40:27 -0700
Message-ID: <1279730427.1714.34.camel@Joe-Laptop.home>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
	 <1279719442-10174-2-git-send-email-vapier@gentoo.org>
	 <20100721151608.GM21121@mail.wantstofly.org>
	 <1279726393.2452.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org,
	Karl Beldan <karl.beldan@gmail.com>,
	Graf Yang <graf.yang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2006 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328Ab0GUQka (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 12:40:30 -0400
In-Reply-To: <1279726393.2452.60.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-07-21 at 17:33 +0200, Eric Dumazet wrote:
> It is used by all pr_err() friends

Shouldn't these drivers be moved into
something like drivers/net/dsa/ rather
than be kept in net?

The #define pr_fmt would be more standard as
	#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
The printks could be netdev_<level>

Suggested patches:

diff --git a/net/dsa/ksz8893m.c b/net/dsa/ksz8893m.c
index 98cce04..80fb0ac 100644
--- a/net/dsa/ksz8893m.c
+++ b/net/dsa/ksz8893m.c
@@ -8,7 +8,7 @@
  * Licensed under the GPL-2 or later.
  */
 
-#define pr_fmt(fmt) "ksz8893m: " fmt
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/list.h>
 #include <linux/netdevice.h>
@@ -42,11 +42,14 @@ static int ksz8893m_read(unsigned char *din, unsigned char reg, int len)
 	spi_message_init(&message);
 	spi_message_add_tail(t, &message);
 	ret = spi_sync(sw.dev, &message);
-	if (!ret)
-		return message.status;
+	if (ret) {
+		pr_err("read reg%d failed, ret=%d\n", reg, ret);
+		return ret;
+	}
+	if (message.status)
+		pr_err("read reg%d failed, status=%d\n", reg, message.status);
 
-	pr_err("read reg%d failed, ret=%d\n", reg, ret);
-	return ret;
+	return message.status;
 }
 
 static int ksz8893m_write(unsigned char *dout, unsigned char reg, int len)
@@ -65,11 +68,14 @@ static int ksz8893m_write(unsigned char *dout, unsigned char reg, int len)
 	spi_message_init(&message);
 	spi_message_add_tail(t, &message);
 	ret = spi_sync(sw.dev, &message);
-	if (!ret)
-		return message.status;
+	if (ret) {
+		pr_err("write reg%d failed, ret=%d\n", reg, ret);
+		return ret;
+	}
+	if (message.status)
+		pr_err("write reg%d failed, status=%d\n", reg, message.status);
 
-	pr_err("write reg%d failed, ret=%d\n", reg, ret);
-	return ret;
+	return message.status;
 }
 
 static char *ksz8893m_probe(struct mii_bus *bus, int sw_addr)
@@ -168,8 +174,8 @@ static int ksz8893m_setup_port(struct dsa_switch *ds, int p)
 	if (val < 0)
 		return val;
 	val |= AN_ENABLE | FORCE_100 | FORCE_FULL_DUPLEX;
-	val &= ~(POWER_DOWN | DISABLE_MDIX | DIS_FAR_END_FAULT |\
-			DISABLE_TRANSMIT | DISABLE_LED);
+	val &= ~(POWER_DOWN | DISABLE_MDIX | DIS_FAR_END_FAULT |
+		 DISABLE_TRANSMIT | DISABLE_LED);
 	ret = mdiobus_write(ds->master_mii_bus, p, MII_BMCR, val);
 	if (ret < 0)
 		return ret;
@@ -228,8 +234,7 @@ ksz8893m_phy_read(struct dsa_switch *ds, int port, int regnum)
 }
 
 static int
-ksz8893m_phy_write(struct dsa_switch *ds,
-			      int port, int regnum, u16 val)
+ksz8893m_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 {
 	int phy_addr = ksz8893m_port_to_phy_addr(port);
 	return mdiobus_write(ds->master_mii_bus, phy_addr, regnum, val);
@@ -263,7 +268,7 @@ static void ksz8893m_poll_link(struct dsa_switch *ds)
 
 		if (!link) {
 			if (netif_carrier_ok(dev)) {
-				printk(KERN_INFO "%s: link down\n", dev->name);
+				netdev_info(dev, "link down\n");
 				netif_carrier_off(dev);
 			}
 			continue;
@@ -274,8 +279,8 @@ static void ksz8893m_poll_link(struct dsa_switch *ds)
 		val = mdiobus_read(ds->master_mii_bus, i, MII_BMSR);
 		if (val < 0)
 			continue;
-		val &= HALF_10_CAPABLE | FULL_10_CAPABLE |\
-		       HALF_100_CAPABLE | FULL_100_CAPABLE;
+		val &= (HALF_10_CAPABLE | FULL_10_CAPABLE |
+			HALF_100_CAPABLE | FULL_100_CAPABLE);
 		if (val & FULL_100_CAPABLE) {
 			speed = 100;
 			duplex = 1;
@@ -288,8 +293,8 @@ static void ksz8893m_poll_link(struct dsa_switch *ds)
 		}
 
 		if (!netif_carrier_ok(dev)) {
-			printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex\n",
-					dev->name, speed, duplex ? "full" : "half");
+			netdev_info(dev, "link up, %d Mb/s, %s duplex\n",
+				    speed, duplex ? "full" : "half");
 			netif_carrier_on(dev);
 		}
 	}



