From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 0/4] Teach phylib hard-resetting devices
Date: Fri, 20 Oct 2017 10:14:17 +0200
Message-ID: <1508487261-18524-1-git-send-email-geert+renesas@glider.be>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Ferre <nicolas.ferre@microchip.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi David, Andrew, Florian, Simon, Magnus,

This patch series adds optional PHY reset support to phylib.

The first two patches are destined for David's net-next tree. They add
core PHY reset code, and update a driver that currently uses its own
reset code.  Note that these patches depend on "[PATCH v2] of_mdio: Fix
broken PHY IRQ in case of probe deferral"
(https://www.spinics.net/lists/linux-renesas-soc/msg19442.html), as v3
needs to propagate errors from of_mdiobus_register_phy() and
of_mdiobus_register_device() [1].

The last two patches are new (sort of, see [2]), and destined for
Simon's renesas tree.  They add properties to describe the EthernetAVB
PHY reset topology to the common Salvator-X/XS and ULCB DTS files, which
solves two issues:
  1. On Salvator-XS, the enable pin of the regulator providing PHY power
     is connected to PRESETn, and PSCI powers down the SoC during system
     suspend.  Hence a PHY reset is needed to restore network functionality
     after resume.
  2. Linux should not rely on the boot loader having reset the PHY, but
     should reset the PHY during driver probe.

Changes compared to v2, as sent by Sergei Shtylyov:
  - Fix fwnode_get_named_gpiod() call due to added parameters (which
    allowed to eliminate the gpiod_direction_output() call),
  - Rebased, refreshed, reworded,
  - Take over from Sergei,
  - Add Acked-by,
  - Remove unneeded gpiod check, as gpiod_set_value() handles NULL fine,
  - Handle fwnode_get_named_gpiod() errors correctly:
      - -ENOENT is ignored (the GPIO is optional), and turned into NULL,
	which allowed to remove all later !IS_ERR() checks,
      - Other errors (incl. -EPROBE_DEFER) are propagated [1],
  - Extract DTS patches from series "[PATCH 0/4] ravb: Add PHY reset
    support" (https://www.spinics.net/lists/netdev/msg457308.html), and
    incorporate in this series, after moving reset-gpios from the
    ethernet to the ethernet-phy node [2].

Thanks for your comments!

Geert Uytterhoeven (2):
  arm64: dts: renesas: salvator-common: Add EthernetAVB PHY reset
  arm64: dts: renesas: ulcb: Add EthernetAVB PHY reset

Sergei Shtylyov (2):
  phylib: Add device reset GPIO support
  macb: Kill PHY reset code

 Documentation/devicetree/bindings/net/phy.txt    |  2 ++
 arch/arm64/boot/dts/renesas/salvator-common.dtsi |  1 +
 arch/arm64/boot/dts/renesas/ulcb.dtsi            |  1 +
 drivers/net/ethernet/cadence/macb.h              |  1 -
 drivers/net/ethernet/cadence/macb_main.c         | 21 ---------------
 drivers/net/phy/at803x.c                         | 18 +++----------
 drivers/net/phy/mdio_bus.c                       |  4 +++
 drivers/net/phy/mdio_device.c                    | 26 +++++++++++++++++--
 drivers/net/phy/phy_device.c                     | 33 ++++++++++++++++++++++--
 drivers/of/of_mdio.c                             | 23 +++++++++++++++++
 include/linux/mdio.h                             |  3 +++
 include/linux/phy.h                              |  5 ++++
 12 files changed, 97 insertions(+), 41 deletions(-)

-- 
2.7.4

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
