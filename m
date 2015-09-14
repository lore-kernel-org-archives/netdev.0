From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: DSA: phy polling
Date: Mon, 14 Sep 2015 11:42:54 +0100
Message-ID: <20150914104254.GI21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:47283 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755409AbbINKnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 06:43:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew,

I think you're the current maintainer of the Marvell DSA code, as being
the most recent author of changes to it. :)

I've noticed in my testing that the Marvell DSA code seems to poll the
internal phy link status in mv88e6xxx_poll_link(), and set the network
device carrier status according to the results.

However, the internal phys are created using phylib, which also polls
the phys for their link status, and controls the associated netdev
carrier status.

The side effect of this is that I see duplicated link status messages in
the kernel log when connecting or disconnecting cables from the switch,
caused by the code in mv88e6xxx_poll_link() racing with the phylib code.
>From what I can see, the code in mv88e6xxx_poll_link() is entirely
redundant as the phylib layer will take care of any phy attached to the
switch.

To prove this, I have the following code in my tree, which disables the
polling on a port where we have a phy attached (either an internal or
external phy).  The result is that the per-port network devices are still
updated with the link status even though this code is disabled - thanks
to the phylib polling.

I'm left wondering whether the DSA specific phy polling does anything
useful, or whether the entire polling code both in mv88e6xxx.c and
net/dsa can be removed (mv88e6xxx.c seems to be its only user.)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 26ec2fbfaa89..4c324eafeef2 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -400,6 +400,13 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 		if (dev == NULL)
 			continue;
 
+		/*
+		 * Ignore ports which have a phy; phylib will take care
+		 * of polling the link status for these.
+		 */
+		if (dsa_slave_has_phy(dev))
+			continue;
+
 		link = 0;
 		if (dev->flags & IFF_UP) {
 			port_status = mv88e6xxx_reg_read(ds, REG_PORT(i),
diff --git a/include/net/dsa.h b/include/net/dsa.h
index fbca63ba8f73..b31e9da43ea7 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -176,6 +176,8 @@ static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
 	return ds->phys_port_mask & (1 << p) && ds->ports[p];
 }
 
+extern bool dsa_slave_has_phy(struct net_device *);
+
 static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 {
 	struct dsa_switch_tree *dst = ds->dst;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 35c47ddd04f0..a107242816ff 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -10,6 +10,7 @@
 
 #include <linux/list.h>
 #include <linux/etherdevice.h>
+#include <linux/export.h>
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
@@ -873,6 +874,14 @@ int dsa_slave_resume(struct net_device *slave_dev)
 	return 0;
 }
 
+bool dsa_slave_has_phy(struct net_device *slave_dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(slave_dev);
+
+	return p->phy != NULL;
+}
+EXPORT_SYMBOL_GPL(dsa_slave_has_phy);
+
 int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		     int port, char *name)
 {


-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
