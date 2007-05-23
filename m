From: Florian Fainelli <florian.fainelli@int-evry.fr>
Subject: Network activity LED trigger
Date: Wed, 23 May 2007 23:02:39 +0200
Message-ID: <200705232302.43669.florian.fainelli@int-evry.fr>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart59008958.oDRnUM5WpU";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: hadi@cyberus.ca, Mark Brown <broonie@sirena.org.uk>,
	netdev@vger.kernel.org, Richard Purdie <rpurdie@rpsys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-ext.int-evry.fr ([157.159.11.17]:53585 "EHLO
	smtp-ext.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbXEWVcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 17:32:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart59008958.oDRnUM5WpU
Content-Type: multipart/mixed;
  boundary="Boundary-01=_vvKVGN1WeUupekw"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_vvKVGN1WeUupekw
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Here comes a basic patch that adds a network led activity. It is not=20
configurable yet, but is enough to make a LED configured with=20
the "network-activity" trigger to blink on network activity.

Netdev people can probably comment on the place of ledtrig_network_activity=
(),=20
which is probably not adequate. Also the ledtrig_network_activity can be=20
network device specific for instance.

Signed-off-by: Florian Fainelli <florian.fainelli@int-evry.fr>
=2D-=20

--Boundary-01=_vvKVGN1WeUupekw
Content-Type: text/plain;
  charset="us-ascii";
  name="ledtrig_network.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="ledtrig_network.patch"

diff --git a/drivers/leds/Kconfig b/drivers/leds/Kconfig
index 80acd08..25d2b58 100644
=2D-- a/drivers/leds/Kconfig
+++ b/drivers/leds/Kconfig
@@ -127,5 +127,12 @@ config LEDS_TRIGGER_HEARTBEAT
 	  load average.
 	  If unsure, say Y.
=20
+config LEDS_TRIGGER_NETWORK_ACT
+	tristate "LED Network Activity Trigger"
+	depends on LEDS_TRIGGER && NET
+	help
+	  This allow LEDs to be controlled by network activity at layer-3 network=
ing.
+	  If unsure, say Y.
+
 endmenu
=20
diff --git a/drivers/leds/Makefile b/drivers/leds/Makefile
index aa2c18e..bc899d3 100644
=2D-- a/drivers/leds/Makefile
+++ b/drivers/leds/Makefile
@@ -21,3 +21,4 @@ obj-$(CONFIG_LEDS_COBALT)		+=3D leds-cobalt.o
 obj-$(CONFIG_LEDS_TRIGGER_TIMER)	+=3D ledtrig-timer.o
 obj-$(CONFIG_LEDS_TRIGGER_IDE_DISK)	+=3D ledtrig-ide-disk.o
 obj-$(CONFIG_LEDS_TRIGGER_HEARTBEAT)	+=3D ledtrig-heartbeat.o
+obj-$(CONFIG_LEDS_TRIGGER_NETWORK_ACT)  +=3D ledtrig-network-activity.o
diff --git a/drivers/leds/ledtrig-network-activity.c b/drivers/leds/ledtrig=
=2Dnetwork-activity.c
new file mode 100644
index 0000000..88d17bb
=2D-- /dev/null
+++ b/drivers/leds/ledtrig-network-activity.c
@@ -0,0 +1,61 @@
+/*
+ * LED Network Activity Trigger
+ * based on ledtrig-ide-disk by Richard Purdie
+ *=20
+ * Copyright 2007 Florian Fainelli <florian@openwrt.org>
+ *=20
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *=20
+ */
+
+#include <linux/module.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/timer.h>
+#include <linux/leds.h>
+
+static void ledtrig_network_timerfunc(unsigned long data);
+
+DEFINE_LED_TRIGGER(ledtrig_network);
+static DEFINE_TIMER(ledtrig_network_timer, ledtrig_network_timerfunc, 0, 0=
);
+static int network_activity, network_lastactivity;
+
+void ledtrig_network_activity(void)
+{
+	network_activity++;
+	if (!timer_pending(&ledtrig_network_timer))
+		mod_timer(&ledtrig_network_timer, jiffies + msecs_to_jiffies(10));
+}
+EXPORT_SYMBOL(ledtrig_network_activity);
+
+static void ledtrig_network_timerfunc(unsigned long data)
+{
+	if (network_lastactivity !=3D network_activity) {
+		network_lastactivity =3D network_activity;
+		led_trigger_event(ledtrig_network, LED_FULL);
+		mod_timer(&ledtrig_network_timer, jiffies + msecs_to_jiffies(10));
+	} else {
+		led_trigger_event(ledtrig_network, LED_OFF);
+	}
+}
+
+static int __init ledtrig_network_init(void)
+{
+	led_trigger_register_simple("network-activity", &ledtrig_network);
+	return 0;
+}
+
+static void __exit ledtrig_network_exit(void)
+{
+	led_trigger_unregister_simple(ledtrig_network);
+}
+
+module_init(ledtrig_network_init);
+module_exit(ledtrig_network_exit);
+
+MODULE_AUTHOR("Florian Fainelli <florian@openwrt.org>");
+MODULE_DESCRIPTION("LED Network Activity trigger");
+MODULE_LICENSE("GPL");
diff --git a/include/linux/leds.h b/include/linux/leds.h
index 88afcef..ed3774e 100644
=2D-- a/include/linux/leds.h
+++ b/include/linux/leds.h
@@ -110,4 +110,10 @@ extern void ledtrig_ide_activity(void);
 #define ledtrig_ide_activity() do {} while(0)
 #endif
=20
+#ifdef CONFIG_LEDS_TRIGGER_NETWORK_ACT
+extern void ledtrig_network_activity(void);
+#else
+#define ledtrig_network_activity() do {} while(0)
+#endif
+
 #endif		/* __LINUX_LEDS_H_INCLUDED */
diff --git a/net/core/dev.c b/net/core/dev.c
index 4317c1b..9423b26 100644
=2D-- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -116,6 +116,7 @@
 #include <linux/dmaengine.h>
 #include <linux/err.h>
 #include <linux/ctype.h>
+#include <linux/leds.h>
=20
 /*
  *	The list of packet types we will receive (as opposed to discard)
@@ -1451,6 +1452,8 @@ int dev_queue_xmit(struct sk_buff *skb)
 gso:
 	spin_lock_prefetch(&dev->queue_lock);
=20
+	ledtrig_network_activity();
+
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.
 	 */

--Boundary-01=_vvKVGN1WeUupekw--

--nextPart59008958.oDRnUM5WpU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4 (GNU/Linux)

iD8DBQBGVKvzkwOXMtq9F3IRAieHAKC21OYEBfQxVraeewsN034TFfkhJACffwHv
zgiogiiYJe6QUXZhT+64yIc=
=T/Km
-----END PGP SIGNATURE-----

--nextPart59008958.oDRnUM5WpU--
