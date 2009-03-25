From: Subrata Modak <tosubrata@gmail.com>
Subject: [PATCH] Re: Next March 25: net/netfilter/xt_LED build failure.
Date: Wed, 25 Mar 2009 19:27:59 +0530
Message-ID: <20090325135759.4397.53055.sendpatchset@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sachin Sant <sachinp@in.ibm.com>,
	Subrata Modak <tosubrata@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

>Today's next randconfig build on x86 failed with following error.
>
>net/netfilter/xt_LED.c:40: error: field netfilter_led_trigger has inco=
mplete type
>net/netfilter/xt_LED.c: In function led_timeout_callback:
>net/netfilter/xt_LED.c:78: warning: unused variable ledinternal
>net/netfilter/xt_LED.c: In function led_tg_check:
>net/netfilter/xt_LED.c:102: error: implicit declaration of function le=
d_trigger_register
>net/netfilter/xt_LED.c: In function led_tg_destroy:
>net/netfilter/xt_LED.c:135: error: implicit declaration of function le=
d_trigger_unregister
>
>CONFIG_LED_TRIGGER is not set.
>
>complete .config attached.

The following patch will solve the build problem reported by Sachin.
But would leave the following warnings. I hope we can ignore them:

net/netfilter/xt_LED.c: In function =E2=80=98led_timeout_callback=E2=80=
=99:
net/netfilter/xt_LED.c:78: warning: unused variable =E2=80=98ledinterna=
l=E2=80=99
net/netfilter/xt_LED.c: In function =E2=80=98led_tg_check=E2=80=99:
net/netfilter/xt_LED.c:87: warning: unused variable =E2=80=98err=E2=80=99

Signed-Off-By: Subrata Modak<subrata@linux.vnet.ibm.com>
---

--- a/linux-2.6.29/include/linux/leds.h	2009-03-25 18:38:07.000000000 +=
0530
+++ b/linux-2.6.29/include/linux/leds.h	2009-03-25 18:24:55.000000000 +=
0530
@@ -73,9 +73,6 @@ extern void led_classdev_resume(struct l
 /*
  * LED Triggers
  */
-#ifdef CONFIG_LEDS_TRIGGERS
-
-#define TRIG_NAME_MAX 50
=20
 struct led_trigger {
 	/* Trigger Properties */
@@ -91,6 +88,10 @@ struct led_trigger {
 	struct list_head  next_trig;
 };
=20
+#ifdef CONFIG_LEDS_TRIGGERS
+
+#define TRIG_NAME_MAX 50
+
 /* Registration functions for complex triggers */
 extern int led_trigger_register(struct led_trigger *trigger);
 extern void led_trigger_unregister(struct led_trigger *trigger);
--- a/linux-2.6.29/net/netfilter/xt_LED.c	2009-03-25 18:38:08.000000000=
 +0530
+++ b/linux-2.6.29/net/netfilter/xt_LED.c	2009-03-25 18:26:55.000000000=
 +0530
@@ -99,6 +99,7 @@ static bool led_tg_check(const struct xt
=20
 	ledinternal->netfilter_led_trigger.name =3D ledinfo->id;
=20
+#ifdef CONFIG_LEDS_TRIGGERS
 	err =3D led_trigger_register(&ledinternal->netfilter_led_trigger);
 	if (err) {
 		printk(KERN_CRIT KBUILD_MODNAME
@@ -108,7 +109,7 @@ static bool led_tg_check(const struct xt
 				": Trigger name is already in use.\n");
 		goto exit_alloc;
 	}
-
+#endif
 	/* See if we need to set up a timer */
 	if (ledinfo->delay > 0)
 		setup_timer(&ledinternal->timer, led_timeout_callback,
@@ -118,8 +119,10 @@ static bool led_tg_check(const struct xt
=20
 	return true;
=20
+#ifdef CONFIG_LEDS_TRIGGERS
 exit_alloc:
 	kfree(ledinternal);
+#endif
=20
 	return false;
 }
@@ -132,7 +135,9 @@ static void led_tg_destroy(const struct=20
 	if (ledinfo->delay > 0)
 		del_timer_sync(&ledinternal->timer);
=20
+#ifdef CONFIG_LEDS_TRIGGERS
 	led_trigger_unregister(&ledinternal->netfilter_led_trigger);
+#endif
 	kfree(ledinternal);
 }

--
Regards--
Subrata
=20
