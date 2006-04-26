From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: ixp2000: handle enp2611s with two gigabit ports
Date: Thu, 27 Apr 2006 00:24:11 +0200
Message-ID: <20060426222411.GA9882@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:61920 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S964862AbWDZWYM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 18:24:12 -0400
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ixp2000 driver for the enp2611 was developed on a board with
three gigabit ports, but some enp2611 models only have two ports
(and only one onboard PM3386.)  The current driver assumes there
are always three ports and so it doesn't work on the two-port
version of the board at all.

This patch adds a bit of logic to the enp2611 driver to limit the
number of ports to 2 if the second PM3386 isn't detected.

Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

diff -urN linux-2.6.17-rc2.orig/drivers/net/ixp2000/enp2611.c linux-2.6.17-rc2/drivers/net/ixp2000/enp2611.c
--- linux-2.6.17-rc2.orig/drivers/net/ixp2000/enp2611.c	2006-04-19 21:54:58.000000000 +0200
+++ linux-2.6.17-rc2/drivers/net/ixp2000/enp2611.c	2006-04-19 22:03:05.000000000 +0200
@@ -149,6 +149,8 @@
 		int status;
 
 		dev = nds[i];
+		if (dev == NULL)
+			continue;
 
 		status = pm3386_is_link_up(i);
 		if (status && !netif_carrier_ok(dev)) {
@@ -191,6 +193,7 @@
 
 static int __init enp2611_init_module(void)
 { 
+	int ports;
 	int i;
 
 	if (!machine_is_enp2611())
@@ -199,7 +202,8 @@
 	caleb_reset();
 	pm3386_reset();
 
-	for (i = 0; i < 3; i++) {
+	ports = pm3386_port_count();
+	for (i = 0; i < ports; i++) {
 		nds[i] = ixpdev_alloc(i, sizeof(struct enp2611_ixpdev_priv));
 		if (nds[i] == NULL) {
 			while (--i >= 0)
@@ -215,8 +219,8 @@
 
 	ixp2400_msf_init(&enp2611_msf_parameters);
 
-	if (ixpdev_init(3, nds, enp2611_set_port_admin_status)) {
-		for (i = 0; i < 3; i++)
+	if (ixpdev_init(ports, nds, enp2611_set_port_admin_status)) {
+		for (i = 0; i < ports; i++)
 			free_netdev(nds[i]);
 		return -EINVAL;
 	}
@@ -236,8 +240,10 @@
 	del_timer_sync(&link_check_timer);
 
 	ixpdev_deinit();
-	for (i = 0; i < 3; i++)
-		free_netdev(nds[i]);
+	for (i = 0; i < 3; i++) {
+		if (nds[i] != NULL)
			free_netdev(nds[i]);
+	}
 }
 
 module_init(enp2611_init_module);
diff -urN linux-2.6.17-rc2.orig/drivers/net/ixp2000/pm3386.c linux-2.6.17-rc2/drivers/net/ixp2000/pm3386.c
--- linux-2.6.17-rc2.orig/drivers/net/ixp2000/pm3386.c	2006-03-20 06:53:29.000000000 +0100
+++ linux-2.6.17-rc2/drivers/net/ixp2000/pm3386.c	2006-04-19 22:01:39.000000000 +0200
@@ -86,40 +86,53 @@
 	pm3386_reg_write(port >> 1, reg, value);
 }
 
+int pm3386_secondary_present(void)
+{
+	return pm3386_reg_read(1, 0) == 0x3386;
+}
 
 void pm3386_reset(void)
 {
 	u8 mac[3][6];
+	int secondary;
+
+	secondary = pm3386_secondary_present();
 
 	/* Save programmed MAC addresses.  */
 	pm3386_get_mac(0, mac[0]);
 	pm3386_get_mac(1, mac[1]);
-	pm3386_get_mac(2, mac[2]);
+	if (secondary)
+		pm3386_get_mac(2, mac[2]);
 
 	/* Assert analog and digital reset.  */
 	pm3386_reg_write(0, 0x002, 0x0060);
-	pm3386_reg_write(1, 0x002, 0x0060);
+	if (secondary)
+		pm3386_reg_write(1, 0x002, 0x0060);
 	mdelay(1);
 
 	/* Deassert analog reset.  */
 	pm3386_reg_write(0, 0x002, 0x0062);
-	pm3386_reg_write(1, 0x002, 0x0062);
+	if (secondary)
+		pm3386_reg_write(1, 0x002, 0x0062);
 	mdelay(10);
 
 	/* Deassert digital reset.  */
 	pm3386_reg_write(0, 0x002, 0x0063);
-	pm3386_reg_write(1, 0x002, 0x0063);
+	if (secondary)
+		pm3386_reg_write(1, 0x002, 0x0063);
 	mdelay(10);
 
 	/* Restore programmed MAC addresses.  */
 	pm3386_set_mac(0, mac[0]);
 	pm3386_set_mac(1, mac[1]);
-	pm3386_set_mac(2, mac[2]);
+	if (secondary)
+		pm3386_set_mac(2, mac[2]);
 
 	/* Disable carrier on all ports.  */
 	pm3386_set_carrier(0, 0);
 	pm3386_set_carrier(1, 0);
-	pm3386_set_carrier(2, 0);
+	if (secondary)
+		pm3386_set_carrier(2, 0);
 }
 
 static u16 swaph(u16 x)
@@ -127,6 +140,11 @@
 	return ((x << 8) | (x >> 8)) & 0xffff;
 }
 
+int pm3386_port_count(void)
+{
+	return 2 + !!pm3386_secondary_present();
+}
+
 void pm3386_init_port(int port)
 {
 	int pm = port >> 1;
diff -urN linux-2.6.17-rc2.orig/drivers/net/ixp2000/pm3386.h linux-2.6.17-rc2/drivers/net/ixp2000/pm3386.h
--- linux-2.6.17-rc2.orig/drivers/net/ixp2000/pm3386.h	2006-03-20 06:53:29.000000000 +0100
+++ linux-2.6.17-rc2/drivers/net/ixp2000/pm3386.h	2006-04-19 21:56:55.000000000 +0200
@@ -13,6 +13,7 @@
 #define __PM3386_H
 
 void pm3386_reset(void);
+int pm3386_port_count(void);
 void pm3386_init_port(int port);
 void pm3386_get_mac(int port, u8 *mac);
 void pm3386_set_mac(int port, u8 *mac);
