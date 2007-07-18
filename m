From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH] Add a network activity LED trigger
Date: Wed, 18 Jul 2007 15:27:38 +0200
Message-ID: <200707181527.38895.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1232323.dra81XfyCQ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, rpurdie@rpsys.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-ext.int-evry.fr ([157.159.11.17]:59772 "EHLO
	smtp-ext.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757099AbXGRN1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 09:27:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1232323.dra81XfyCQ
Content-Type: multipart/mixed;
  boundary="Boundary-01=_KVhnGnO9r+Tug/Q"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_KVhnGnO9r+Tug/Q
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi all,

This patch adds a new LED trigger, based on network activity. It gathers=20
activity from net/core/dev.c and can be used as a LED trigger by=20
specifying "network-activity". Further version should allow the user to=20
specify the network interface to bind a LED to. This trigger is a "simple"=
=20
trigger as defined by the LED subsystem.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
=2D-=20

--Boundary-01=_KVhnGnO9r+Tug/Q
Content-Type: text/plain;
  charset="us-ascii";
  name="ledtrig_network_activity.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="ledtrig_network_activity.patch"

diff --git a/drivers/leds/Kconfig b/drivers/leds/Kconfig
index 87d2046..fdc5a8a 100644
=2D-- a/drivers/leds/Kconfig
+++ b/drivers/leds/Kconfig
@@ -128,5 +128,12 @@ config LEDS_TRIGGER_HEARTBEAT
 	  load average.
 	  If unsure, say Y.
=20
+config LEDS_TRIGGER_NETWORK_ACT
+	tristate "LED Network Activity Trigger"
+	depends on LEDS_TRIGGERS && NET
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
index 0000000..5c2e051
=2D-- /dev/null
+++ b/drivers/leds/ledtrig-network-activity.c
@@ -0,0 +1,63 @@
+/*
+ * LED Network Activity Trigger
+ *
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
+static int network_activity;
+static int network_lastactivity;
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
diff --git a/net/core/dev.c b/net/core/dev.c
index ee051bb..a3a4115 100644
=2D-- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -117,6 +117,7 @@
 #include <linux/err.h>
 #include <linux/ctype.h>
 #include <linux/if_arp.h>
+#include <linux/leds.h>
=20
 /*
  *	The list of packet types we will receive (as opposed to discard)
@@ -1523,6 +1524,7 @@ gso:
 	 * stops preemption for RCU.
 	 */
 	rcu_read_lock_bh();
+	ledtrig_network_activity();
=20
 	/* Updates of qdisc are serialized by queue_lock.
 	 * The struct Qdisc which is pointed to by qdisc is now a

--Boundary-01=_KVhnGnO9r+Tug/Q--

--nextPart1232323.dra81XfyCQ
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.5 (GNU/Linux)

iD8DBQBGnhVKmx9n1G/316sRAg4WAJ93TEvcvi4ZadDoa7rkMaMY9HRJ3wCfQDri
2yUpJRVO69lDs6HnD3qfs7M=
=hfO8
-----END PGP SIGNATURE-----

--nextPart1232323.dra81XfyCQ--
