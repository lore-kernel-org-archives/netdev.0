From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 17/41: x_tables: add LED trigger target
Date: Tue, 24 Mar 2009 15:03:29 +0100 (MET)
Message-ID: <20090324140325.31401.19778.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34743 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758274AbZCXODd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:33 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 268cb38e1802db560c73167e643f14a3dcb4b07c
Author: Adam Nielsen <a.nielsen@shikadi.net>
Date:   Fri Feb 20 10:55:14 2009 +0100

    netfilter: x_tables: add LED trigger target
    
    Kernel module providing implementation of LED netfilter target.  Each
    instance of the target appears as a led-trigger device, which can be
    associated with one or more LEDs in /sys/class/leds/
    
    Signed-off-by: Adam Nielsen <a.nielsen@shikadi.net>
    Acked-by: Richard Purdie <rpurdie@linux.intel.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/leds/Kconfig b/drivers/leds/Kconfig
index 7427136..556aeca 100644
--- a/drivers/leds/Kconfig
+++ b/drivers/leds/Kconfig
@@ -223,4 +223,7 @@ config LEDS_TRIGGER_DEFAULT_ON
 	  This allows LEDs to be initialised in the ON state.
 	  If unsure, say Y.
 
+comment "iptables trigger is under Netfilter config (LED target)"
+	depends on LEDS_TRIGGERS
+
 endif # NEW_LEDS
diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 5a8af87..deeaee5 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -7,6 +7,7 @@ header-y += xt_CLASSIFY.h
 header-y += xt_CONNMARK.h
 header-y += xt_CONNSECMARK.h
 header-y += xt_DSCP.h
+header-y += xt_LED.h
 header-y += xt_MARK.h
 header-y += xt_NFLOG.h
 header-y += xt_NFQUEUE.h
diff --git a/include/linux/netfilter/xt_LED.h b/include/linux/netfilter/xt_LED.h
new file mode 100644
index 0000000..4c91a0d
--- /dev/null
+++ b/include/linux/netfilter/xt_LED.h
@@ -0,0 +1,13 @@
+#ifndef _XT_LED_H
+#define _XT_LED_H
+
+struct xt_led_info {
+	char id[27];        /* Unique ID for this trigger in the LED class */
+	__u8 always_blink;  /* Blink even if the LED is already on */
+	__u32 delay;        /* Delay until LED is switched off after trigger */
+
+	/* Kernel data used in the module */
+	void *internal_data __attribute__((aligned(8)));
+};
+
+#endif /* _XT_LED_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 0eb98b4..cdbaaff 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -372,6 +372,30 @@ config NETFILTER_XT_TARGET_HL
 	since you can easily create immortal packets that loop
 	forever on the network.
 
+config NETFILTER_XT_TARGET_LED
+	tristate '"LED" target support'
+	depends on LEDS_CLASS
+	depends on NETFILTER_ADVANCED
+	help
+	  This option adds a `LED' target, which allows you to blink LEDs in
+	  response to particular packets passing through your machine.
+
+	  This can be used to turn a spare LED into a network activity LED,
+	  which only flashes in response to FTP transfers, for example.  Or
+	  you could have an LED which lights up for a minute or two every time
+	  somebody connects to your machine via SSH.
+
+	  You will need support for the "led" class to make this work.
+
+	  To create an LED trigger for incoming SSH traffic:
+	    iptables -A INPUT -p tcp --dport 22 -j LED --led-trigger-id ssh --led-delay 1000
+
+	  Then attach the new trigger to an LED on your system:
+	    echo netfilter-ssh > /sys/class/leds/<ledname>/trigger
+
+	  For more information on the LEDs available on your system, see
+	  Documentation/leds-class.txt
+
 config NETFILTER_XT_TARGET_MARK
 	tristate '"MARK" target support'
 	default m if NETFILTER_ADVANCED=n
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index da73ed2..7a9b839 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -46,6 +46,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_CONNMARK) += xt_CONNMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_CONNSECMARK) += xt_CONNSECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_DSCP) += xt_DSCP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_HL) += xt_HL.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_LED) += xt_LED.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_MARK) += xt_MARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
new file mode 100644
index 0000000..8ff7843
--- /dev/null
+++ b/net/netfilter/xt_LED.c
@@ -0,0 +1,161 @@
+/*
+ * xt_LED.c - netfilter target to make LEDs blink upon packet matches
+ *
+ * Copyright (C) 2008 Adam Nielsen <a.nielsen@shikadi.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301 USA.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/leds.h>
+#include <linux/mutex.h>
+
+#include <linux/netfilter/xt_LED.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Adam Nielsen <a.nielsen@shikadi.net>");
+MODULE_DESCRIPTION("Xtables: trigger LED devices on packet match");
+
+/*
+ * This is declared in here (the kernel module) only, to avoid having these
+ * dependencies in userspace code.  This is what xt_led_info.internal_data
+ * points to.
+ */
+struct xt_led_info_internal {
+	struct led_trigger netfilter_led_trigger;
+	struct timer_list timer;
+};
+
+static unsigned int
+led_tg(struct sk_buff *skb, const struct xt_target_param *par)
+{
+	const struct xt_led_info *ledinfo = par->targinfo;
+	struct xt_led_info_internal *ledinternal = ledinfo->internal_data;
+
+	/*
+	 * If "always blink" is enabled, and there's still some time until the
+	 * LED will switch off, briefly switch it off now.
+	 */
+	if ((ledinfo->delay > 0) && ledinfo->always_blink &&
+	    timer_pending(&ledinternal->timer))
+		led_trigger_event(&ledinternal->netfilter_led_trigger,LED_OFF);
+
+	led_trigger_event(&ledinternal->netfilter_led_trigger, LED_FULL);
+
+	/* If there's a positive delay, start/update the timer */
+	if (ledinfo->delay > 0) {
+		mod_timer(&ledinternal->timer,
+			  jiffies + msecs_to_jiffies(ledinfo->delay));
+
+	/* Otherwise if there was no delay given, blink as fast as possible */
+	} else if (ledinfo->delay == 0) {
+		led_trigger_event(&ledinternal->netfilter_led_trigger, LED_OFF);
+	}
+
+	/* else the delay is negative, which means switch on and stay on */
+
+	return XT_CONTINUE;
+}
+
+static void led_timeout_callback(unsigned long data)
+{
+	struct xt_led_info *ledinfo = (struct xt_led_info *)data;
+	struct xt_led_info_internal *ledinternal = ledinfo->internal_data;
+
+	led_trigger_event(&ledinternal->netfilter_led_trigger, LED_OFF);
+}
+
+static bool led_tg_check(const struct xt_tgchk_param *par)
+{
+	struct xt_led_info *ledinfo = par->targinfo;
+	struct xt_led_info_internal *ledinternal;
+	int err;
+
+	if (ledinfo->id[0] == '\0') {
+		printk(KERN_ERR KBUILD_MODNAME ": No 'id' parameter given.\n");
+		return false;
+	}
+
+	ledinternal = kzalloc(sizeof(struct xt_led_info_internal), GFP_KERNEL);
+	if (!ledinternal) {
+		printk(KERN_CRIT KBUILD_MODNAME ": out of memory\n");
+		return false;
+	}
+
+	ledinternal->netfilter_led_trigger.name = ledinfo->id;
+
+	err = led_trigger_register(&ledinternal->netfilter_led_trigger);
+	if (err) {
+		printk(KERN_CRIT KBUILD_MODNAME
+			": led_trigger_register() failed\n");
+		if (err == -EEXIST)
+			printk(KERN_ERR KBUILD_MODNAME
+				": Trigger name is already in use.\n");
+		goto exit_alloc;
+	}
+
+	/* See if we need to set up a timer */
+	if (ledinfo->delay > 0)
+		setup_timer(&ledinternal->timer, led_timeout_callback,
+			    (unsigned long)ledinfo);
+
+	ledinfo->internal_data = ledinternal;
+
+	return true;
+
+exit_alloc:
+	kfree(ledinternal);
+
+	return false;
+}
+
+static void led_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	const struct xt_led_info *ledinfo = par->targinfo;
+	struct xt_led_info_internal *ledinternal = ledinfo->internal_data;
+
+	if (ledinfo->delay > 0)
+		del_timer_sync(&ledinternal->timer);
+
+	led_trigger_unregister(&ledinternal->netfilter_led_trigger);
+	kfree(ledinternal);
+}
+
+static struct xt_target led_tg_reg __read_mostly = {
+	.name		= "LED",
+	.revision	= 0,
+	.family		= NFPROTO_UNSPEC,
+	.target		= led_tg,
+	.targetsize	= XT_ALIGN(sizeof(struct xt_led_info)),
+	.checkentry	= led_tg_check,
+	.destroy	= led_tg_destroy,
+	.me		= THIS_MODULE,
+};
+
+static int __init led_tg_init(void)
+{
+	return xt_register_target(&led_tg_reg);
+}
+
+static void __exit led_tg_exit(void)
+{
+	xt_unregister_target(&led_tg_reg);
+}
+
+module_init(led_tg_init);
+module_exit(led_tg_exit);
