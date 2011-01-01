From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] tg3: fix warnings
Date: Sat, 01 Jan 2011 16:22:46 +0100
Message-ID: <1293895366.2535.43.camel@edumazet-laptop>
References: <201012252356.23424.rjw@sisk.pl>
	 <20101231.111440.28810446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rjw@sisk.pl, netdev@vger.kernel.org, mcarlson@broadcom.com,
	mchan@broadcom.com, linux-pm@lists.linux-foundation.org,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46995 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693Ab1AAPWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 10:22:53 -0500
Received: by wwa36 with SMTP id 36so13076958wwa.1
        for <netdev@vger.kernel.org>; Sat, 01 Jan 2011 07:22:51 -0800 (PST)
In-Reply-To: <20101231.111440.28810446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 31 d=C3=A9cembre 2010 =C3=A0 11:14 -0800, David Miller a =C3=
=A9crit :
> From: "Rafael J. Wysocki" <rjw@sisk.pl>
> Date: Sat, 25 Dec 2010 23:56:23 +0100
>=20
> > From: Rafael J. Wysocki <rjw@sisk.pl>
> >=20
> > The tg3 driver uses the legacy PCI power management, so it has to d=
o
> > some PCI-specific things in its ->suspend() and ->resume() callback=
s,
> > which isn't necessary and should better be done by the PCI
> > sybsystem-level power management code.
> >=20
> > Convert tg3 to the new PCI power management framework and make it
> > let the PCI subsystem take care of all the PCI-specific aspects of
> > device handling during system power transitions.
> >=20
> > Tested on HP nx6325 with a NetXtreme BCM5788 adapter.
> >=20
> > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
>=20
> Applied.

Happy new year everybody ;)

Here is a followup to avoid some warnings if CONFIG_PM_SLEEP=3Dn

Now I have to understand why vlan/bonding doesnt work anymore with tg3
on current net-next-2.6 :(=20

Is anybody already on this problem ?
(Cc Jesse Gross)

Thanks

[PATCH net-next-2.6] tg3: fix warnings

In case CONFIG_PM_SLEEP is disabled, we dont need tg3_suspend() and
tg3_resume().

drivers/net/tg3.c:15056: warning: =E2=80=98tg3_suspend=E2=80=99 defined=
 but not used
drivers/net/tg3.c:15110: warning: =E2=80=98tg3_resume=E2=80=99 defined =
but not used

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: Michael Chan <mchan@broadcom.com>
Cc: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6137869..e3d80c9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -15052,6 +15052,7 @@ static void __devexit tg3_remove_one(struct pci=
_dev *pdev)
 	}
 }
=20
+#ifdef CONFIG_PM_SLEEP
 static int tg3_suspend(struct device *device)
 {
 	struct pci_dev *pdev =3D to_pci_dev(device);
@@ -15140,13 +15141,20 @@ out:
 }
=20
 static SIMPLE_DEV_PM_OPS(tg3_pm_ops, tg3_suspend, tg3_resume);
+#define TG3_PM_OPS (&tg3_pm_ops)
+
+#else
+
+#define TG3_PM_OPS NULL
+
+#endif /* CONFIG_PM_SLEEP */
=20
 static struct pci_driver tg3_driver =3D {
 	.name		=3D DRV_MODULE_NAME,
 	.id_table	=3D tg3_pci_tbl,
 	.probe		=3D tg3_init_one,
 	.remove		=3D __devexit_p(tg3_remove_one),
-	.driver.pm	=3D &tg3_pm_ops,
+	.driver.pm	=3D TG3_PM_OPS,
 };
=20
 static int __init tg3_init(void)


