From: Dave Jones <davej@redhat.com>
Subject: Re: [1/4 v2] Remove unused zero-copy code from velocity NIC driver.
Date: Thu, 23 Jul 2009 20:44:49 -0400
Message-ID: <20090724004449.GA16422@redhat.com>
References: <20090721.123202.173837534.davem@davemloft.net> <20090721.123227.85658631.davem@davemloft.net> <20090721.123322.118453668.davem@davemloft.net> <20090723.155855.108555685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43758 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493AbZGXAox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2009 20:44:53 -0400
Content-Disposition: inline
In-Reply-To: <20090723.155855.108555685.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 23, 2009 at 03:58:55PM -0700, David Miller wrote:
 > From: David Miller <davem@davemloft.net>
 > Date: Tue, 21 Jul 2009 12:33:22 -0700 (PDT)
 >=20
 > > Ok, all applied to net-next-2.6, thanks.
 >=20
 > Ok, now we have a stinking pile of poo situation when one tries to
 > compile the velocity driver without CONFIG_PM defined.
 >=20
 > First we hit:
 >=20
 > drivers/net/via-velocity.c: In function =E2=80=98velocity_init_modul=
e=E2=80=99:
 > drivers/net/via-velocity.c:3303: error: implicit declaration of func=
tion =E2=80=98velocity_register_notifier=E2=80=99
 > drivers/net/via-velocity.c:3306: error: implicit declaration of func=
tion =E2=80=98velocity_unregister_notifier=E2=80=99
 >=20
 > Because the whole CONFIG_PM + CONFIG_INET ifdeffery around these fun=
ctions
 > was missed up.  Simple enough to fix, but then we get:
 >=20
 > drivers/net/via-velocity.c:2957: warning: =E2=80=98velocity_suspend=E2=
=80=99 defined but not used
 > drivers/net/via-velocity.c:3026: warning: =E2=80=98velocity_resume=E2=
=80=99 defined but not used
 >=20
 > Fine, let's ifdef protect these two functions with CONFIG_PM:
 >=20
 > drivers/net/via-velocity.c:2853: warning: =E2=80=98velocity_set_wol=E2=
=80=99 defined but not used
 > drivers/net/via-velocity.c:2939: warning: =E2=80=98velocity_save_con=
text=E2=80=99 defined but not used
 > drivers/net/via-velocity.c:3001: warning: =E2=80=98velocity_restore_=
context=E2=80=99 defined but not used
 >=20
 > And at this point I really give up Dave.  This whole thing to move
 > functions around to avoid forward decls has created a worse problem
 > than it solved.
 >=20
 > Unless you can fix this, like, immediately.  I want to revert.
 >=20
 > This is keeping me from pulling more work into my net-next-2.6
 > tree.

apologies.. This should fix it..

	Dave

--=20

Previous changes broke compilation with CONFIG_PM disabled.
This widens the ifdefs to cover the functions that only get called
within the suspend/resume routines.

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index b4bd1d3..47be41a 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2805,6 +2805,7 @@ err_free_dev:
 }
=20
=20
+#ifdef CONFIG_PM
 /**
  *	wol_calc_crc		-	WOL CRC
  *	@pattern: data pattern
@@ -2952,7 +2953,6 @@ static void velocity_save_context(struct velocity=
_info *vptr, struct velocity_co
=20
 }
=20
-
 static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev =3D pci_get_drvdata(pdev);
@@ -3056,7 +3056,7 @@ static int velocity_resume(struct pci_dev *pdev)
=20
 	return 0;
 }
-
+#endif
=20
 /*
  *	Definition for our device driver. The PCI layer interface
@@ -3239,7 +3239,6 @@ static const struct ethtool_ops velocity_ethtool_=
ops =3D {
 };
=20
 #ifdef CONFIG_PM
-
 #ifdef CONFIG_INET
 static int velocity_netdev_event(struct notifier_block *nb, unsigned l=
ong notification, void *ptr)
 {
@@ -3263,6 +3262,7 @@ static int velocity_netdev_event(struct notifier_=
block *nb, unsigned long notifi
 	return NOTIFY_DONE;
 }
 #endif	/* CONFIG_INET */
+#endif	/* CONFIG_PM */
=20
 #if defined(CONFIG_PM) && defined(CONFIG_INET)
 static struct notifier_block velocity_inetaddr_notifier =3D {
@@ -3286,8 +3286,6 @@ static void velocity_unregister_notifier(void)
=20
 #endif	/* defined(CONFIG_PM) && defined(CONFIG_INET) */
=20
-#endif	/* CONFIG_PM */
-
 /**
  *	velocity_init_module	-	load time function
  *
