From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] via-velocity: Remove private device list
Date: Sun, 25 Oct 2009 20:08:49 +0000
Message-ID: <1256501329.3136.109.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-TFauGXZfSfmJrTzr8iS6"
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42130 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753978AbZJYUIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 16:08:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TFauGXZfSfmJrTzr8iS6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

via-velocity maintains a list of its devices in order to determine
whether a netdev notification applies to one of them.  That can be
determined simply by checking the netdev_ops pointer, so the list can
be removed.

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/via-velocity.c |   37 +++----------------------------------
 drivers/net/via-velocity.h |    2 --
 2 files changed, 3 insertions(+), 36 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index e2a7725..0342d18 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -406,9 +406,6 @@ static int velocity_set_media_mode(struct velocity_info=
 *vptr, u32 mii_status);
 static int velocity_suspend(struct pci_dev *pdev, pm_message_t state);
 static int velocity_resume(struct pci_dev *pdev);
=20
-static DEFINE_SPINLOCK(velocity_dev_list_lock);
-static LIST_HEAD(velocity_dev_list);
-
 #endif
=20
 #if defined(CONFIG_PM) && defined(CONFIG_INET)
@@ -488,14 +485,6 @@ static void __devexit velocity_remove1(struct pci_dev =
*pdev)
 	struct net_device *dev =3D pci_get_drvdata(pdev);
 	struct velocity_info *vptr =3D netdev_priv(dev);
=20
-#ifdef CONFIG_PM
-	unsigned long flags;
-
-	spin_lock_irqsave(&velocity_dev_list_lock, flags);
-	if (!list_empty(&velocity_dev_list))
-		list_del(&vptr->list);
-	spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
-#endif
 	unregister_netdev(dev);
 	iounmap(vptr->mac_regs);
 	pci_release_regions(pdev);
@@ -998,15 +987,6 @@ static int __devinit velocity_found1(struct pci_dev *p=
dev, const struct pci_devi
 	/* and leave the chip powered down */
=20
 	pci_set_power_state(pdev, PCI_D3hot);
-#ifdef CONFIG_PM
-	{
-		unsigned long flags;
-
-		spin_lock_irqsave(&velocity_dev_list_lock, flags);
-		list_add(&vptr->list, &velocity_dev_list);
-		spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
-	}
-#endif
 	velocity_nics++;
 out:
 	return ret;
@@ -1062,7 +1042,6 @@ static void __devinit velocity_init_info(struct pci_d=
ev *pdev,
 	vptr->tx.numq =3D info->txqueue;
 	vptr->multicast_limit =3D MCAM_SIZE;
 	spin_lock_init(&vptr->lock);
-	INIT_LIST_HEAD(&vptr->list);
 }
=20
 /**
@@ -3470,20 +3449,10 @@ static int velocity_netdev_event(struct notifier_bl=
ock *nb, unsigned long notifi
 {
 	struct in_ifaddr *ifa =3D (struct in_ifaddr *) ptr;
 	struct net_device *dev =3D ifa->ifa_dev->dev;
-	struct velocity_info *vptr;
-	unsigned long flags;
=20
-	if (dev_net(dev) !=3D &init_net)
-		return NOTIFY_DONE;
-
-	spin_lock_irqsave(&velocity_dev_list_lock, flags);
-	list_for_each_entry(vptr, &velocity_dev_list, list) {
-		if (vptr->dev =3D=3D dev) {
-			velocity_get_ip(vptr);
-			break;
-		}
-	}
-	spin_unlock_irqrestore(&velocity_dev_list_lock, flags);
+	if (dev_net(dev) =3D=3D &init_net &&
+	    dev->netdev_ops =3D=3D &velocity_netdev_ops)
+		velocity_get_ip(netdev_priv(dev));
=20
 	return NOTIFY_DONE;
 }
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 4cd3f6c..6289241 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1499,8 +1499,6 @@ struct velocity_opt {
 #define GET_RD_BY_IDX(vptr, idx)   (vptr->rd_ring[idx])
=20
 struct velocity_info {
-	struct list_head list;
-
 	struct pci_dev *pdev;
 	struct net_device *dev;
=20
--=20
1.6.4.3



--=-TFauGXZfSfmJrTzr8iS6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASuSwTOe/yOyVhhEJAQKoOQ/+JrjYjtI9HFnVjLObjkgOtRLulXQZaRCV
Y+D9IGEvW6gEjuBu8cp8kvU/1OjQoBMAPj92Gm1lJbIlEMxPDLgRnbND8DVzI+QC
uatLCkGaCeXkPHDlFcNbu4snzIQde7AgVVOVKyWvyfMw/D8Fi7DcCIeqxwafDDkH
sVs+O7KiKYR01SdAtTGKSOUX3G6cYcRcks+9hdwl+CjV4CCzkLJ7DupFedGAKTW2
FB274oYRtfxLorQhB49RSfO9usmX/jMp8MiQe0Vw3q8G3Eyuz2mQVnfnBD/USaqy
wGkGVObIiJnaK2o7RK0TQp9fzTSB0RCd0FHL2h4VARaMTOqUHZSWQOk0EVbrBTXN
hwOBsXGukgc1feERX5NAeZf3gNJ+2Aec1bGU8dxLeiN7jVXGjHvJI4MTkHy445v7
iny+7k7iihc0NxVPaG3n1FFnn0QHKte2rN1L4HJbDkQ44UuFQzyGnhEJ2Qt7UwgK
0LPbDwQfL9wT+xaNy9mSiWArLurGnr+r26gzFyz3/Opu/j3TfqtvHFB1Qp1XgYWO
aYMI8LYFMHAceK1R1aOeVT1mzmLhvXXHmnGQ26OyA0bM+nrVuDE9R8i/H0k8HT8l
KNVJjrjAqpAbcSV4O1XWw58+txbTEKoo3Fn4MDZwmevIrK/Hn4mLLJ7MflThfs5+
bsmLYty8lSU=
=E+Lb
-----END PGP SIGNATURE-----

--=-TFauGXZfSfmJrTzr8iS6--
