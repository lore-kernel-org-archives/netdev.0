From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v4 0/5] net: stmmac: Detect PHY location with phy-is-integrated
Date: Sat, 26 Aug 2017 09:33:06 +0200
Message-ID: <20170826073311.25612-1-clabbe.montjoie@gmail.com>
Cc: icenowy-h8G6r0blFSE@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

The final solution was to represent a mdio-mux but let the MAC handle all things.
The only hack that comes with this solution is that we add a patch
"net: stmmac: Register parent MDIO in case of fake mdio-mux"
because we have ino other way to know which MDIO node to register.

Note that sun8i-v3s-emac have also an integrated PHY, but since it lacks
any external PHY support it is not necessary to add MDIO mux to it.

All patchs should go via the net tree with exception of DT patchs which should
go via the sunxi tree
Note that this serie will need backporting the patch
"Documentation: net: phy: Add phy-is-integrated binding" which is in net-next

Regards

Changes since v3:
- Added a patch for handling fixed-link
- Updated documentation

Changes since v2:
- Add a MDIO mux for creating distinction between integrated and external MDIO.
- phy-is-integrated is not set in dtsi.

Changes since v1:
- Dropped phy-is-integrated documentation patch since another same patch was already merged
- Moved phy-is-integrated from SoC dtsi to final board DT.

Corentin Labbe (5):
  net: stmmac: Handle possible fixed-link with need_mdio_ids
  ARM: dts: sunxi: h3/h5: represent the mdio switch used by
    sun8i-h3-emac
  dt-bindings: net: dwmac-sun8i: update documentation about integrated
    PHY
  net: stmmac: dwmac-sun8i: choose internal PHY via phy-is-integrated
  net: stmmac: Register parent MDIO in case of fake mdio-mux

 .../devicetree/bindings/net/dwmac-sun8i.txt        | 117 ++++++++++++++++++++-
 arch/arm/boot/dts/sunxi-h3-h5.dtsi                 |  22 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c  |  16 +--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  13 ++-
 4 files changed, 152 insertions(+), 16 deletions(-)

-- 
2.13.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
