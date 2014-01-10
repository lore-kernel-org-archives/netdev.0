From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH v2 00/16] net: stmmac: Add Allwinner A20 GMAC
 ethernet controller glue layer
Date: Fri, 10 Jan 2014 15:00:01 +0800
Message-ID: <1389337217-29032-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	Emilio Lopez <emilio-0Z03zUJReD5OxF6Tv1QG9Q@public.gmane.org>,
	Mike Turquette <mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBBNVX2LAKGQEJDFSV7Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

This is v2 of the  Allwinner A20 GMAC glue layer for stmmac.
The clock and DT patches should be applied after my clock
rename[1] series.

  [1] ARM: sunxi: rename DT clock node names to clk@N

The Allwinner A20 SoC integrates an early version of dwmac
IP from Synopsys. On top of that is a hardware glue layer.
This layer needs to be configured before the dwmac can be
used.

Part of the glue layer is a clock mux, which controls the
source and direction of the TX clock used by GMAC. The clock
module driver is added in patch #9.

The remaining glue layer code is in patch #10.

The glue layer is implemented with existing feature flags 
and callbacks found in stmmac driver core. A new stmmac_of_data
structure, which is a subset of the original platform data,
has been added to tie these values with compatible strings.
The purpose of this is to avoid future glue layers assuming
they can pass other data or directly modify values used by
the driver core. This is found in patch #7.

The callbacks have also been extended to pass board specific
data. This is found in patch #4.

This version of dwmac IP requires store and forward DMA mode.
The relevant device tree property was documented, but not
implemented. Patch #6 adds this to stmmac platform driver.

Changes since v1:

  * Added optional reset control to stmmac driver core
  * Added non CONFIG_RESET_CONROLLER routines for the above change
  * Extended callback API, as discussed with Srinivas
  * Used new stmmac_of_data to pass features and callbacks,
    instead of platform data, as discussed
  * Seperated clock module glue layer into clock driver

Comments?

Thanks,

ChenYu


Chen-Yu Tsai (16):
  reset: add non CONFIG_RESET_CONTROLLER routines
  net: stmmac: Enable stmmac main clock when probing hardware
  net: stmmac: Add support for optional reset control
  net: stmmac: Allocate and pass soc/board specific data to callbacks
  blackfin: Update stmmac callback signatures
  net: stmmac: Honor DT parameter to force DMA store and forward mode
  net: stmmac: Use driver data and callbacks tied with compatible
    strings
  net: stmmac: sunxi platform extensions for GMAC in Allwinner A20 SoC's
  clk: sunxi: Add Allwinner A20/A31 GMAC clock unit
  ARM: dts: sun7i: Add GMAC clock node to sun7i DTSI
  ARM: dts: sun7i: Add GMAC controller node to sun7i DTSI
  ARM: dts: sun7i: Add pin muxing options for the GMAC
  ARM: dts: sun7i: cubietruck: Enable the GMAC
  ARM: dts: sun7i: cubieboard2: Enable GMAC instead of EMAC
  ARM: dts: sun7i: olinuxino-micro: Enable GMAC instead of EMAC
  ARM: dts: sun7i: Add ethernet alias for GMAC

 Documentation/devicetree/bindings/clock/sunxi.txt  |  26 ++++
 .../bindings/net/allwinner,sun7i-a20-gmac.txt      |  27 +++++
 Documentation/devicetree/bindings/net/stmmac.txt   |   3 +
 Documentation/networking/stmmac.txt                |  12 +-
 arch/arm/boot/dts/sun7i-a20-cubieboard2.dts        |  27 ++---
 arch/arm/boot/dts/sun7i-a20-cubietruck.dts         |  12 ++
 arch/arm/boot/dts/sun7i-a20-olinuxino-micro.dts    |  27 ++---
 arch/arm/boot/dts/sun7i-a20.dtsi                   |  71 ++++++++++-
 arch/blackfin/mach-bf609/boards/ezkit.c            |   2 +-
 drivers/clk/sunxi/clk-sunxi.c                      |  74 ++++++++++++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  12 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 133 +++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   5 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  45 ++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |   4 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  73 ++++++++---
 include/linux/reset.h                              |  39 ++++++
 include/linux/stmmac.h                             |  24 +++-
 19 files changed, 547 insertions(+), 70 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun7i-a20-gmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c

-- 
1.8.5.2
