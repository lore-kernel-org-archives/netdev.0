From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 4/6] of: add API for changing parameters of fixed link
Date: Mon, 30 Mar 2015 17:39:13 +0300
Message-ID: <55196011.7080502@list.ru>
References: <55155AFC.4050800@list.ru> <55155D35.1070703@list.ru> <CAGVrzcau0mUne8uXsTs_9=e4JtQt5w5L+hwtLmKo+UfjSEwC+w@mail.gmail.com> <5515803F.3020600@list.ru> <CAGVrzcaLfQcTAx8OR=sE=7FLrp0gGvfX8_YfxK_CU+x26JHymw@mail.gmail.com> <551587D1.5070408@list.ru> <5515904A.1060600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.mail.ru ([94.100.176.156]:36790 "EHLO smtp19.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752779AbbC3OjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 10:39:25 -0400
In-Reply-To: <5515904A.1060600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

27.03.2015 20:15, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> I think your concerns are valid, but I don't think there is going to =
be
> any problem with the approach I suggested because there is a contract
> that the fixed PHYs and regular PHYs need to
Hello Florian.

As promised, today I tried to resurrect my first implementation
and do things as you suggested: install the link_update callback
for mvneta privately.
I feel SGMII setup is very common and deserves the separate API,
not the per-driver handling, but in any case, I'd like to show
the implementation first, then discuss.

Unfortunately, it didn't work quite right.
The problem is that mvneta calls phy_disconnect() on .ndo_stop
callback. After that, phy->attached_dev becomes NULL, and so the
link_update callback gets called with net_dev=3D=3DNULL! And crashs.
Of course I can easily work around that, but IMHO its a bug -
the one that actually gets fixed by the patches I posted previously.
They were changing the callback to receive phy_device instead of
net_device, and so NULL will never be passed.
I am attaching the new patch so that you can take a look and decide.
If you still think its fine, even despite the NULL passing w/a, then
I'll mail it with the proper boilerplate. But if you agree that
passing NULL to link_update is a bug, then maybe you'll decide to
get the whole surgery thing. :)


-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D# Don't remove this line #=3D-=3D-=3D=
-=3D-=3D-=3D-=3D-=3D-=3D-
When MDIO bus is unavailable (common setup for SGMII), the in-band
signaling must be used to correctly track link state.
This patch enables the in-band status delivery for links state changes,=
 namely:
- link up/down
- link speed
- duplex full/half
fixed_phy link_update() callback is used to update status.

Note: SGMII setup is so common that I think it deserves a separate API
rather than the per-driver handling. There is an alternative implementa=
tion
that adds such API:
https://lkml.org/lkml/2015/3/27/346

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: Florian Fainelli <f.fainelli@gmail.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c |   97 +++++++++++++++++++++++++=
++++----
 1 file changed, 86 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethern=
et/marvell/mvneta.c
index 96208f1..5b9cc0a 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -100,6 +100,8 @@
 #define MVNETA_TXQ_CMD                           0x2448
 #define      MVNETA_TXQ_DISABLE_SHIFT            8
 #define      MVNETA_TXQ_ENABLE_MASK              0x000000ff
+#define MVNETA_GMAC_CLOCK_DIVIDER                0x24f4
+#define      MVNETA_GMAC_1MS_CLOCK_ENABLE        BIT(31)
 #define MVNETA_ACC_MODE                          0x2500
 #define MVNETA_CPU_MAP(cpu)                      (0x2540 + ((cpu) << 2=
))
 #define      MVNETA_CPU_RXQ_ACCESS_ALL_MASK      0x000000ff
@@ -122,6 +124,7 @@
 #define      MVNETA_TX_INTR_MASK_ALL             (0xff << 0)
 #define      MVNETA_RX_INTR_MASK(nr_rxqs)        (((1 << nr_rxqs) - 1)=
 << 8)
 #define      MVNETA_RX_INTR_MASK_ALL             (0xff << 8)
+#define      MVNETA_MISCINTR_INTR_MASK           BIT(31)

 #define MVNETA_INTR_OLD_CAUSE                    0x25a8
 #define MVNETA_INTR_OLD_MASK                     0x25ac
@@ -165,6 +168,7 @@
 #define      MVNETA_GMAC_MAX_RX_SIZE_MASK        0x7ffc
 #define      MVNETA_GMAC0_PORT_ENABLE            BIT(0)
 #define MVNETA_GMAC_CTRL_2                       0x2c08
+#define      MVNETA_GMAC2_INBAND_AN_ENABLE       BIT(0)
 #define      MVNETA_GMAC2_PCS_ENABLE             BIT(3)
 #define      MVNETA_GMAC2_PORT_RGMII             BIT(4)
 #define      MVNETA_GMAC2_PORT_RESET             BIT(6)
@@ -180,9 +184,11 @@
 #define MVNETA_GMAC_AUTONEG_CONFIG               0x2c0c
 #define      MVNETA_GMAC_FORCE_LINK_DOWN         BIT(0)
 #define      MVNETA_GMAC_FORCE_LINK_PASS         BIT(1)
+#define      MVNETA_GMAC_INBAND_AN_ENABLE        BIT(2)
 #define      MVNETA_GMAC_CONFIG_MII_SPEED        BIT(5)
 #define      MVNETA_GMAC_CONFIG_GMII_SPEED       BIT(6)
 #define      MVNETA_GMAC_AN_SPEED_EN             BIT(7)
+#define      MVNETA_GMAC_AN_FLOW_CTRL_EN         BIT(11)
 #define      MVNETA_GMAC_CONFIG_FULL_DUPLEX      BIT(12)
 #define      MVNETA_GMAC_AN_DUPLEX_EN            BIT(13)
 #define MVNETA_MIB_COUNTERS_BASE                 0x3080
@@ -304,6 +310,7 @@ struct mvneta_port {
 	unsigned int link;
 	unsigned int duplex;
 	unsigned int speed;
+	int inband_status;
 };

 /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
@@ -994,6 +1001,20 @@ static void mvneta_defaults_set(struct mvneta_por=
t *pp)
 	val &=3D ~MVNETA_PHY_POLLING_ENABLE;
 	mvreg_write(pp, MVNETA_UNIT_CONTROL, val);

+	if (pp->inband_status) {
+		val =3D mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
+		val &=3D ~(MVNETA_GMAC_FORCE_LINK_PASS |
+			 MVNETA_GMAC_FORCE_LINK_DOWN |
+			 MVNETA_GMAC_AN_FLOW_CTRL_EN);
+		val |=3D MVNETA_GMAC_INBAND_AN_ENABLE |
+		       MVNETA_GMAC_AN_SPEED_EN |
+		       MVNETA_GMAC_AN_DUPLEX_EN;
+		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
+		val =3D mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
+		val |=3D MVNETA_GMAC_1MS_CLOCK_ENABLE;
+		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
+	}
+
 	mvneta_set_ucast_table(pp, -1);
 	mvneta_set_special_mcast_table(pp, -1);
 	mvneta_set_other_mcast_table(pp, -1);
@@ -2043,6 +2064,29 @@ static irqreturn_t mvneta_isr(int irq, void *dev=
_id)
 	return IRQ_HANDLED;
 }

+static int mvneta_fixed_link_update(struct net_device *dev,
+				  struct fixed_phy_status *status)
+{
+	struct mvneta_port *pp;
+	u32 gmac_stat;
+
+	if (!dev) {
+		/* we have a bug here */
+		return -EINVAL;
+	}
+	pp =3D netdev_priv(dev);
+	gmac_stat =3D mvreg_read(pp, MVNETA_GMAC_STATUS);
+	status->link =3D !!(gmac_stat & MVNETA_GMAC_LINK_UP);
+	if (gmac_stat & MVNETA_GMAC_SPEED_1000)
+		status->speed =3D SPEED_1000;
+	else if (gmac_stat & MVNETA_GMAC_SPEED_100)
+		status->speed =3D SPEED_100;
+	else
+		status->speed =3D SPEED_10;
+	status->duplex =3D !!(gmac_stat & MVNETA_GMAC_FULL_DUPLEX);
+	return 0;
+}
+
 /* NAPI handler
  * Bits 0 - 7 of the causeRxTx register indicate that are transmitted
  * packets on the corresponding TXQ (Bit 0 is for TX queue 1).
@@ -2063,8 +2107,12 @@ static int mvneta_poll(struct napi_struct *napi,=
 int budget)
 	}

 	/* Read cause register */
-	cause_rx_tx =3D mvreg_read(pp, MVNETA_INTR_NEW_CAUSE) &
-		(MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
+	cause_rx_tx =3D mvreg_read(pp, MVNETA_INTR_NEW_CAUSE);
+	if (cause_rx_tx & MVNETA_MISCINTR_INTR_MASK) {
+		/* since phylib uses polling, not much to do here...
+		 * Any way to tell phylib to do the poll NOW? */
+		mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
+	}

 	/* Release Tx descriptors */
 	if (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL) {
@@ -2109,7 +2157,9 @@ static int mvneta_poll(struct napi_struct *napi, =
int budget)
 		napi_complete(napi);
 		local_irq_save(flags);
 		mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-			    MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_numbe=
r));
+			    MVNETA_RX_INTR_MASK(rxq_number) |
+			    MVNETA_TX_INTR_MASK(txq_number) |
+			    MVNETA_MISCINTR_INTR_MASK);
 		local_irq_restore(flags);
 	}

@@ -2373,7 +2423,13 @@ static void mvneta_start_dev(struct mvneta_port =
*pp)

 	/* Unmask interrupts */
 	mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-		    MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number=
));
+		    MVNETA_RX_INTR_MASK(rxq_number) |
+		    MVNETA_TX_INTR_MASK(txq_number) |
+		    MVNETA_MISCINTR_INTR_MASK);
+	mvreg_write(pp, MVNETA_INTR_MISC_MASK,
+		    MVNETA_CAUSE_PHY_STATUS_CHANGE |
+		    MVNETA_CAUSE_LINK_CHANGE |
+		    MVNETA_CAUSE_PSC_SYNC_CHANGE);

 	phy_start(pp->phy_dev);
 	netif_tx_start_all_queues(pp->dev);
@@ -2523,9 +2579,7 @@ static void mvneta_adjust_link(struct net_device =
*ndev)
 			val =3D mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
 			val &=3D ~(MVNETA_GMAC_CONFIG_MII_SPEED |
 				 MVNETA_GMAC_CONFIG_GMII_SPEED |
-				 MVNETA_GMAC_CONFIG_FULL_DUPLEX |
-				 MVNETA_GMAC_AN_SPEED_EN |
-				 MVNETA_GMAC_AN_DUPLEX_EN);
+				 MVNETA_GMAC_CONFIG_FULL_DUPLEX);

 			if (phydev->duplex)
 				val |=3D MVNETA_GMAC_CONFIG_FULL_DUPLEX;
@@ -2554,12 +2608,24 @@ static void mvneta_adjust_link(struct net_devic=
e *ndev)

 	if (status_change) {
 		if (phydev->link) {
-			u32 val =3D mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
-			val |=3D (MVNETA_GMAC_FORCE_LINK_PASS |
-				MVNETA_GMAC_FORCE_LINK_DOWN);
-			mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
+			if (!pp->inband_status) {
+				u32 val =3D mvreg_read(pp,
+						  MVNETA_GMAC_AUTONEG_CONFIG);
+				val &=3D ~MVNETA_GMAC_FORCE_LINK_DOWN;
+				val |=3D MVNETA_GMAC_FORCE_LINK_PASS;
+				mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG,
+					    val);
+			}
 			mvneta_port_up(pp);
 		} else {
+			if (!pp->inband_status) {
+				u32 val =3D mvreg_read(pp,
+						  MVNETA_GMAC_AUTONEG_CONFIG);
+				val &=3D ~MVNETA_GMAC_FORCE_LINK_PASS;
+				val |=3D MVNETA_GMAC_FORCE_LINK_DOWN;
+				mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG,
+					    val);
+			}
 			mvneta_port_down(pp);
 		}
 		phy_print_status(phydev);
@@ -2910,6 +2976,9 @@ static int mvneta_port_power_up(struct mvneta_por=
t *pp, int phy_mode)
 		return -EINVAL;
 	}

+	if (pp->inband_status)
+		ctrl |=3D MVNETA_GMAC2_INBAND_AN_ENABLE;
+
 	/* Cancel Port Reset */
 	ctrl &=3D ~MVNETA_GMAC2_PORT_RESET;
 	mvreg_write(pp, MVNETA_GMAC_CTRL_2, ctrl);
@@ -2934,6 +3003,7 @@ static int mvneta_probe(struct platform_device *p=
dev)
 	char hw_mac_addr[ETH_ALEN];
 	const char *mac_from;
 	int phy_mode;
+	int fixed_phy =3D 0;
 	int err;

 	/* Our multiqueue support is not complete, so for now, only
@@ -2956,6 +3026,7 @@ static int mvneta_probe(struct platform_device *p=
dev)

 	phy_node =3D of_parse_phandle(dn, "phy", 0);
 	if (!phy_node) {
+		struct phy_device *phy;
 		if (!of_phy_is_fixed_link(dn)) {
 			dev_err(&pdev->dev, "no PHY specified\n");
 			err =3D -ENODEV;
@@ -2967,11 +3038,14 @@ static int mvneta_probe(struct platform_device =
*pdev)
 			dev_err(&pdev->dev, "cannot register fixed PHY\n");
 			goto err_free_irq;
 		}
+		fixed_phy =3D 1;

 		/* In the case of a fixed PHY, the DT node associated
 		 * to the PHY is the Ethernet MAC DT node.
 		 */
 		phy_node =3D of_node_get(dn);
+		phy =3D of_phy_find_device(dn);
+		fixed_phy_set_link_update(phy, mvneta_fixed_link_update);
 	}

 	phy_mode =3D of_get_phy_mode(dn);
@@ -2990,6 +3064,7 @@ static int mvneta_probe(struct platform_device *p=
dev)
 	pp =3D netdev_priv(dev);
 	pp->phy_node =3D phy_node;
 	pp->phy_interface =3D phy_mode;
+	pp->inband_status =3D (phy_mode =3D=3D PHY_INTERFACE_MODE_SGMII) && f=
ixed_phy;

 	pp->clk =3D devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pp->clk)) {
--=20
1.7.9.5
