From: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
Subject: [PATCH] PLIP driver: convert killed_timer_sem to completion
Date: Sat, 8 Dec 2007 17:23:13 +0100
Message-ID: <20071208162313.GA15658@traven>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755548AbXLHQX1@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PLIP driver: convert the semaphore killed_timer_sem to
a completion

Signed-off-by: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>

--

diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 57c9866..fee3d7b 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -106,6 +106,7 @@ static const char version[] =3D "NET3 PLIP version =
2.4-parport gniibe@mri.co.jp\n"
 #include <linux/if_plip.h>
 #include <linux/workqueue.h>
 #include <linux/spinlock.h>
+#include <linux/completion.h>
 #include <linux/parport.h>
 #include <linux/bitops.h>
=20
@@ -114,7 +115,6 @@ static const char version[] =3D "NET3 PLIP version =
2.4-parport gniibe@mri.co.jp\n"
 #include <asm/system.h>
 #include <asm/irq.h>
 #include <asm/byteorder.h>
-#include <asm/semaphore.h>
=20
 /* Maximum number of devices to support. */
 #define PLIP_MAX  8
@@ -221,7 +221,7 @@ struct net_local {
 	int should_relinquish;
 	spinlock_t lock;
 	atomic_t kill_timer;
-	struct semaphore killed_timer_sem;
+	struct completion killed_timer_cmp;
 };
=20
 static inline void enable_parport_interrupts (struct net_device *dev)
@@ -385,7 +385,7 @@ plip_timer_bh(struct work_struct *work)
 		schedule_delayed_work(&nl->timer, 1);
 	}
 	else {
-		up (&nl->killed_timer_sem);
+		complete(&nl->killed_timer_cmp);
 	}
 }
=20
@@ -1112,9 +1112,9 @@ plip_close(struct net_device *dev)
=20
 	if (dev->irq =3D=3D -1)
 	{
-		init_MUTEX_LOCKED (&nl->killed_timer_sem);
+		init_completion(&nl->killed_timer_cmp);
 		atomic_set (&nl->kill_timer, 1);
-		down (&nl->killed_timer_sem);
+		wait_for_completion(&nl->killed_timer_cmp);
 	}
=20
 #ifdef NOTDEF

--=20
Matthias Kaehlcke
Linux System Developer
Barcelona

     La libertad es como la ma=F1ana. Hay quienes esperan dormidos a qu=
e
   llegue, pero hay quienes desvelan y caminan la noche para alcanzarla
                        (Subcomandante Marcos)
                                                                 .''`.
    using free software / Debian GNU/Linux | http://debian.org  : :'  :
                                                                `. `'`
gpg --keyserver pgp.mit.edu --recv-keys 47D8E5D4                  `-
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
