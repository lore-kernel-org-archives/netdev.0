From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: phy: Relax error checking on sysfs_create_link()
Date: Sat, 27 May 2017 08:40:54 -0700
Message-ID: <021D486A-A81D-45F6-BB66-8FF075B03F70@gmail.com>
References: <20170527033418.3583-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, andrew@lunn.ch, Woojung.Huh@microchip.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35040 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750952AbdE0PlA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 11:41:00 -0400
Received: by mail-oi0-f68.google.com with SMTP id v80so5931307oie.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 08:41:00 -0700 (PDT)
In-Reply-To: <20170527033418.3583-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 26, 2017 8:34:18 PM PDT, Florian Fainelli <f=2Efainelli@gmail=2Ecom>=
 wrote:
>Some Ethernet drivers will attach/connect to a PHY device before
>calling
>register_netdevice() which is responsible for calling
>netdev_register_kobject()
>which would do the network device's kobject initialization=2E In such a
>case,
>sysfs_create_link() would return -ENOENT because the network device's
>kobject
>is not ready yet, and we would fail to connect to the PHY device=2E
>
>In order to keep things simple and symetrical, we just take the success
>path as
>indicative of the ability to access the network device's kobject, and
>create
>the second link if that's the case=2E
>
>Fixes: 5568363f0cb3 ("net: phy: Create sysfs reciprocal links for
>attached_dev/phydev")
>Reported-by: Woojung Hung <Woojung=2EHuh@microchip=2Ecom>
>Signed-off-by: Florian Fainelli <f=2Efainelli@gmail=2Ecom>
>---
> drivers/net/phy/phy_device=2Ec | 28 ++++++++++++++++++++--------
> include/linux/phy=2Eh          |  2 ++
> 2 files changed, 22 insertions(+), 8 deletions(-)
>
>diff --git a/drivers/net/phy/phy_device=2Ec
>b/drivers/net/phy/phy_device=2Ec
>index f84414b8f2ee=2E=2E523366bd705a 100644
>--- a/drivers/net/phy/phy_device=2Ec
>+++ b/drivers/net/phy/phy_device=2Ec
>@@ -960,15 +960,25 @@ int phy_attach_direct(struct net_device *dev,
>struct phy_device *phydev,
>=20
> 	phydev->attached_dev =3D dev;
> 	dev->phydev =3D phydev;
>+
>+	/* Some Ethernet drivers try to connect to a PHY device before
>+	 * calling register_netdevice() -> netdev_register_kobject() and
>+	 * does the dev->dev=2Ekobj initialization=2E Here we only check for
>+	 * success which indicates that the network device kobject is
>+	 * ready=2E Once we do that we still need to keep track of whether
>+	 * links were successfully set up or not for phy_detach() to
>+	 * remove them accordingly=2E
>+	 */
> 	err =3D sysfs_create_link(&phydev->mdio=2Edev=2Ekobj, &dev->dev=2Ekobj,
> 				"attached_dev");
>-	if (err)
>-		goto error;
>+	if (!err) {
>+		err =3D sysfs_create_link(&dev->dev=2Ekobj, &phydev->mdio=2Edev=2Ekobj=
,
>+					"phydev");
>+		if (err)
>+			goto error;
>=20
>-	err =3D sysfs_create_link(&dev->dev=2Ekobj, &phydev->mdio=2Edev=2Ekobj,
>-				"phydev");
>-	if (err)
>-		goto error;
>+		phydev->sysfs_links =3D true;
>+	}
>=20

We should not assume that this Boolean will be true or false if we enter t=
his function a second time, v2 coming=2E

--=20
Florian
