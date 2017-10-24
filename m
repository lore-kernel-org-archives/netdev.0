From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v9 00/10] net: stmmac: dwmac-sun8i: Handle integrated PHY
Date: Tue, 24 Oct 2017 19:57:04 +0200
Message-ID: <20171024175714.15840-1-clabbe.montjoie@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello

The current way to find if the PHY is internal is to compare DT phy-mode
and emac_variant/internal_phy.
But it will negate a possible future SoC where an external PHY use the
same phy mode than the integrated one.

This patchs series adds a new way to handle this problem via a mdio-mux.

The first try was to create a new MDIO mux "mdio-mux-syscon".
mdio-mux-syscon working the same way than mdio-mux-mmioreg with the exception
that the register is used via syscon/regmap.
But this solution does not work for two reason:
- changing the MDIO selection need the reset of MAC which cannot be done by the
        mdio-mux-syscon driver
- There were driver loading order problem:
        - mdio-mux-syscon needing that stmmac register the parent MDIO
        - stmmac needing that child MDIO was registered just after registering parent MDIO

So we cannot use any external MDIO-mux.

The final solution was to represent the mdio-mux in MAC node and let the MAC handle all things.

Since DT bits was reverted in 4.13, this patch series include the revert of the revert.

I have let patch splited for easy review. (for seeing what's new)
But the final serie could have some patch squashed if someone want.
Like squashing patch and 1 and 2 (documentation)

The first 7 patch should go via the sunxi tree, the last three via the net tree.

Regards

Changes since v8:
- added reference to mdio-mux.txt in documentation
- removed compatible mdio-mux
- added mdio-parent-bus

Changes since v7:
- moved mdio-mux ouf of mdio as asked by Andrew Lunn
- reordered patchs order

Changes since v6:
- renamed external mdio to "external_mdio"
- added compatible to mdio-mux and internal-mdio
- removed usage of phy-is-integrated
- renamed do_not_scan to compatible_muxes (patch 10)
- patch 8 9 of v6 are squashed

Changes since v5:
- reordered patch 1 and 2
- mdio-mux node is now a mdio's child
- added patch 11 for removing unnecessary scan of mdio-mux

Changes since v4:
- Update documentation for new bindings
- Added 4 patchs for bring back reverted stuff of 4.13
- dwmac-sun8i now handle mdio-mux
- MDIO use now compatible = "snps,dwmac-mdio";

Changes since v3:
- Added a patch for handling fixed-link
- Updated documentation

Changes since v2:
- Add a MDIO mux for creating distinction between integrated and external MDIO.
- phy-is-integrated is not set in dtsi.

Changes since v1:
- Dropped phy-is-integrated documentation patch since another same patch was already merged
- Moved phy-is-integrated from SoC dtsi to final board DT.

Acked-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Corentin Labbe (10):
  dt-bindings: net: Restore sun8i dwmac binding
  dt-bindings: net: dwmac-sun8i: update documentation about integrated
    PHY
  arm: dts: sunxi: h3/h5: Restore EMAC changes
  arm: dts: sunxi: h3/h5: represent the mdio switch used by
    sun8i-h3-emac
  arm: dts: sunxi: Restore EMAC changes (boards)
  arm64: dts: allwinner: Restore EMAC changes
  arm64: dts: allwinner: add snps,dwmac-mdio compatible to emac/mdio
  net: stmmac: snps,dwmac-mdio MDIOs are automatically registered
  net: stmmac: dwmac-sun8i: Handle integrated/external MDIOs
  net: stmmac: sun8i: Restore the compatibles

 .../devicetree/bindings/net/dwmac-sun8i.txt        | 205 ++++++++++++
 arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts  |   9 +
 arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts    |  19 ++
 arch/arm/boot/dts/sun8i-h3-nanopi-m1-plus.dts      |  19 ++
 arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts          |   7 +
 arch/arm/boot/dts/sun8i-h3-orangepi-2.dts          |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-one.dts        |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts    |   5 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts       |  22 ++
 arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts     |  16 +
 arch/arm/boot/dts/sunxi-h3-h5.dtsi                 |  48 +++
 .../boot/dts/allwinner/sun50i-a64-bananapi-m64.dts |  16 +
 .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts  |  15 +
 .../arm64/boot/dts/allwinner/sun50i-a64-pine64.dts |  17 +
 .../dts/allwinner/sun50i-a64-sopine-baseboard.dts  |  16 +
 arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi      |  21 ++
 .../boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts   |  17 +
 .../boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts  |  17 +
 .../dts/allwinner/sun50i-h5-orangepi-prime.dts     |  17 +
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c  | 361 +++++++++++++--------
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   4 -
 23 files changed, 742 insertions(+), 134 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dwmac-sun8i.txt

-- 
2.13.6

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
