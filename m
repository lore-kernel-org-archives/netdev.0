From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] net: dsa: bcm_sf2: add support for Wake-on-LAN
Date: Thu, 18 Sep 2014 17:31:25 -0700
Message-ID: <1411086685-18684-5-git-send-email-f.fainelli@gmail.com>
References: <1411086685-18684-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:52771 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898AbaISAbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 20:31:50 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so2424917pdb.11
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 17:31:50 -0700 (PDT)
In-Reply-To: <1411086685-18684-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order for Wake-on-LAN to work properly, we query the parent network
device Wake-on-LAN features and advertise those. Similarly, when
configuring Wake-on-LAN on a per-port network interface, we make sure
that we do not accept something the master network devices does not
support.

Finally, we need to maintain a bitmask of the ports enabled for
Wake-on-LAN to prevent the suspend() callback from disabling a port that
is used for waking up the system.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 58 +++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/bcm_sf2.h |  3 +++
 2 files changed, 61 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 77b5a64560fa..e1f88de19145 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -22,6 +22,7 @@
 #include <linux/of_irq.h>
 #include <linux/of_address.h>
 #include <net/dsa.h>
+#include <linux/ethtool.h>
 
 #include "bcm_sf2.h"
 #include "bcm_sf2_regs.h"
@@ -242,6 +243,9 @@ static void bcm_sf2_port_disable(struct dsa_switch *ds, int port)
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	u32 off, reg;
 
+	if (priv->wol_ports_mask & (1 << port))
+		return;
+
 	if (dsa_is_cpu_port(ds, port))
 		off = CORE_IMP_CTL;
 	else
@@ -674,6 +678,58 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 	return 0;
 }
 
+static void bcm_sf2_sw_get_wol(struct dsa_switch *ds, int port,
+			       struct ethtool_wolinfo *wol)
+{
+	struct net_device *p = ds->dst[ds->index].master_netdev;
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct ethtool_wolinfo pwol;
+
+	/* Get the parent device WoL settings */
+	p->ethtool_ops->get_wol(p, &pwol);
+
+	/* Advertise the parent device supported settings */
+	wol->supported = pwol.supported;
+	memset(&wol->sopass, 0, sizeof(wol->sopass));
+
+	if (pwol.wolopts & WAKE_MAGICSECURE)
+		memcpy(&wol->sopass, pwol.sopass, sizeof(wol->sopass));
+
+	if (priv->wol_ports_mask & (1 << port))
+		wol->wolopts = pwol.wolopts;
+	else
+		wol->wolopts = 0;
+}
+
+static int bcm_sf2_sw_set_wol(struct dsa_switch *ds, int port,
+			      struct ethtool_wolinfo *wol)
+{
+	struct net_device *p = ds->dst[ds->index].master_netdev;
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	s8 cpu_port = ds->dst[ds->index].cpu_port;
+	struct ethtool_wolinfo pwol;
+
+	p->ethtool_ops->get_wol(p, &pwol);
+	if (wol->wolopts & ~pwol.supported)
+		return -EINVAL;
+
+	if (wol->wolopts)
+		priv->wol_ports_mask |= (1 << port);
+	else
+		priv->wol_ports_mask &= ~(1 << port);
+
+	/* If we have at least one port enabled, make sure the CPU port
+	 * is also enabled. If the CPU port is the last one enabled, we disable
+	 * it since this configuration does not make sense.
+	 */
+	if (priv->wol_ports_mask && priv->wol_ports_mask != (1 << cpu_port))
+		priv->wol_ports_mask |= (1 << cpu_port);
+	else
+		priv->wol_ports_mask &= ~(1 << cpu_port);
+
+	return p->ethtool_ops->set_wol(p, wol);
+}
+
 static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
 	.priv_size		= sizeof(struct bcm_sf2_priv),
@@ -689,6 +745,8 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.fixed_link_update	= bcm_sf2_sw_fixed_link_update,
 	.suspend		= bcm_sf2_sw_suspend,
 	.resume			= bcm_sf2_sw_resume,
+	.get_wol		= bcm_sf2_sw_get_wol,
+	.set_wol		= bcm_sf2_sw_set_wol,
 };
 
 static int __init bcm_sf2_init(void)
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 260bab313e58..49e52c5d64b4 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -69,6 +69,9 @@ struct bcm_sf2_priv {
 	struct bcm_sf2_hw_params	hw_params;
 
 	struct bcm_sf2_port_status	port_sts[DSA_MAX_PORTS];
+
+	/* Mask of ports enabled for Wake-on-LAN */
+	u32				wol_ports_mask;
 };
 
 struct bcm_sf2_hw_stats {
-- 
1.9.1
