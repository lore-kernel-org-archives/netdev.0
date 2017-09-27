From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v6 00/11] net: stmmac: dwmac-sun8i: Handle
 integrated PHY
Date: Wed, 27 Sep 2017 09:34:03 +0200
Message-ID: <20170927073414.17361-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	andrew-g2DYL2Zd6BY@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBANKVXHAKGQEGWYWIGQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Hello

The current way to find if the PHY is internal is to compare DT phy-mode
and emac_variant/internal_phy.
But it will negate a possible future SoC where an external PHY use the
same phy mode than the integrated one.

This patchs series adds a new way to find if the PHY is integrated, via
the phy-is-integrated DT property.

Since it exists both integrated and external ethernet-phy@1, they are merged in
the final DTB and so share all properties.
For avoiding this, and better represent the reality, we use a MDIO mux.

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

The final solution was to represent a mdio-mux and let the MAC handle all things.
Note that phy-is-integrated is still needed (even if we use a MDIO mux) since
some properties apply only on integrated PHY and we need to know the final MDIO
bus in mdio_mux_syscon_switch_fn().

Since DT bits was reverted in 4.13, this patch series include the revert of the revert.
So
- the first four patchs bring back DT/stmmac stuff that was in 4.13 (and reverted)
- fifth patch document how DT MDIO mux is implemented
- patch 6 and 7 modify DT
- patch 8, 9, 10 Modify stmmac according to the new bindings

I have let patch splited for easy review. (for seeing what's new)
But the final serie could have some patch squashed if someone want.
Like squashing patch and 2 and 5 (documentation)

Since DT worked well in 4.13, could it be targeted for 4.14 ?
If necessary I could split this serie in two:
- bring back A64/A83T (patchs 1, 2, 4, 7, 9)
- add MXIO-mux and H3 (patchs 3, 4, 5, 6, 8, 10)

Regards

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

Corentin Labbe (11):
  dt-bindings: net: Restore sun8i dwmac binding
  arm: dts: sunxi: Restore EMAC changes
  arm64: dts: allwinner: Restore EMAC changes
  net: stmmac: sun8i: Restore the compatibles
  dt-bindings: net: dwmac-sun8i: update documentation about integrated
    PHY
  ARM: dts: sunxi: h3/h5: represent the mdio switch used by
    sun8i-h3-emac
  arm64: dts: allwinner: add snps,dwmac-mdio compatible to emac/mdio
  net: stmmac: snps,dwmac-mdio MDIOs are automatically registered
  net: stmmac: dwmac-sun8i: choose internal PHY via phy-is-integrated
  net: stmmac: dwmac-sun8i: Handle integrated/external MDIOs
  of: mdio: Prevent of_mdiobus_register from scanning mdio-mux nodes

 .../devicetree/bindings/net/dwmac-sun8i.txt        | 198 +++++++++++++++++++++
 arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts  |   9 +
 arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts    |  19 ++
 arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts          |   7 +
 arch/arm/boot/dts/sun8i-h3-orangepi-2.dts          |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-one.dts        |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts    |   5 +
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |   8 +
 arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts       |  22 +++
 arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts     |  16 ++
 arch/arm/boot/dts/sunxi-h3-h5.dtsi                 |  45 +++++
 .../boot/dts/allwinner/sun50i-a64-bananapi-m64.dts |  16 ++
 .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts  |  15 ++
 .../arm64/boot/dts/allwinner/sun50i-a64-pine64.dts |  17 ++
 .../dts/allwinner/sun50i-a64-sopine-baseboard.dts  |  16 ++
 arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi      |  21 +++
 .../boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts   |  17 ++
 .../boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts  |  17 ++
 .../dts/allwinner/sun50i-h5-orangepi-prime.dts     |  17 ++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c  | 140 ++++++++++++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   4 -
 drivers/of/of_mdio.c                               |  10 ++
 23 files changed, 611 insertions(+), 25 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dwmac-sun8i.txt

-- 
2.13.5
