From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH v2 net-2.6] jme: Support WoL after shutdown
Date: Mon, 25 Oct 2010 07:14:22 +0800
Message-ID: <1287962062-30714-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>, "Ctac" <Taoga@yandex.ru>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Hsiu-Che Chao" <hcchao@jmicron.com>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:44670 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788Ab0JXXOe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Oct 2010 19:14:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Guo-Fu Tseng <cooldavid@cooldavid.org>

Adding shutdown function that setup wake if wol is enabled.
Add jme_phy_on in jme_set_100m_half in case it is shutting down
or suspending when interface is down(phy_off by default).

v2 updates:
Removed CONFIG_PM ifdef for jme_set_100m_half and jme_wait_link.
It would be nice if it can be applied to net-2.6 along with other patch=
es
sent few days ago. If it is not appropriate, please ignore the net-2.6
request, and apply it to net-next-2.6 as previous patch. :)

Reported-and-helped-by: =D0=A1tac <Taoga@yandex.ru>
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   45 ++++++++++++++++++++++++++++++---------------
 1 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index d7a975e..d85edf3 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1623,12 +1623,12 @@ err_out:
 	return rc;
 }
=20
-#ifdef CONFIG_PM
 static void
 jme_set_100m_half(struct jme_adapter *jme)
 {
 	u32 bmcr, tmp;
=20
+	jme_phy_on(jme);
 	bmcr =3D jme_mdio_read(jme->dev, jme->mii_if.phy_id, MII_BMCR);
 	tmp =3D bmcr & ~(BMCR_ANENABLE | BMCR_SPEED100 |
 		       BMCR_SPEED1000 | BMCR_FULLDPLX);
@@ -1656,7 +1656,6 @@ jme_wait_link(struct jme_adapter *jme)
 		phylink =3D jme_linkstat_from_phy(jme);
 	}
 }
-#endif
=20
 static inline void
 jme_phy_off(struct jme_adapter *jme)
@@ -1664,6 +1663,21 @@ jme_phy_off(struct jme_adapter *jme)
 	jme_mdio_write(jme->dev, jme->mii_if.phy_id, MII_BMCR, BMCR_PDOWN);
 }
=20
+static void
+jme_powersave_phy(struct jme_adapter *jme)
+{
+	if (jme->reg_pmcs) {
+		jme_set_100m_half(jme);
+
+		if (jme->reg_pmcs & (PMCS_LFEN | PMCS_LREN))
+			jme_wait_link(jme);
+
+		jwrite32(jme, JME_PMCS, jme->reg_pmcs);
+	} else {
+		jme_phy_off(jme);
+	}
+}
+
 static int
 jme_close(struct net_device *netdev)
 {
@@ -2991,6 +3005,16 @@ jme_remove_one(struct pci_dev *pdev)
=20
 }
=20
+static void
+jme_shutdown(struct pci_dev *pdev)
+{
+	struct net_device *netdev =3D pci_get_drvdata(pdev);
+	struct jme_adapter *jme =3D netdev_priv(netdev);
+
+	jme_powersave_phy(jme);
+	pci_pme_active(pdev, true);
+}
+
 #ifdef CONFIG_PM
 static int
 jme_suspend(struct pci_dev *pdev, pm_message_t state)
@@ -3028,19 +3052,9 @@ jme_suspend(struct pci_dev *pdev, pm_message_t s=
tate)
 	tasklet_hi_enable(&jme->rxempty_task);
=20
 	pci_save_state(pdev);
-	if (jme->reg_pmcs) {
-		jme_set_100m_half(jme);
-
-		if (jme->reg_pmcs & (PMCS_LFEN | PMCS_LREN))
-			jme_wait_link(jme);
-
-		jwrite32(jme, JME_PMCS, jme->reg_pmcs);
-
-		pci_enable_wake(pdev, PCI_D3cold, true);
-	} else {
-		jme_phy_off(jme);
-	}
-	pci_set_power_state(pdev, PCI_D3cold);
+	jme_powersave_phy(jme);
+	pci_enable_wake(jme->pdev, PCI_D3hot, true);
+	pci_set_power_state(pdev, PCI_D3hot);
=20
 	return 0;
 }
@@ -3087,6 +3101,7 @@ static struct pci_driver jme_driver =3D {
 	.suspend        =3D jme_suspend,
 	.resume         =3D jme_resume,
 #endif /* CONFIG_PM */
+	.shutdown       =3D jme_shutdown,
 };
=20
 static int __init
--=20
1.7.2.2

