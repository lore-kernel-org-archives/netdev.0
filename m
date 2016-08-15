From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH 0/3] ARM64: meson: Meson8b and GXBB DWMAC glue driver
Date: Mon, 15 Aug 2016 18:40:57 +0200
Message-ID: <20160815164100.27766-1-martin.blumenstingl@googlemail.com>
References: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
	will.deacon@arm.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: linux-amlogic@lists.infradead.org, khilman@baylibre.com,
	carlo@caione.org, mturquette@baylibre.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33403 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbcHOQlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 12:41:20 -0400
In-Reply-To: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a DWMAC glue driver for the PRG_ETHERNET registers found in
Meson8b and GXBB SoCs. Based on the "old" meson6b-dwmac glue driver
the register layout is completely different.
Thus I introduced a separate driver.

Changes compared to the RFC version:
- switch from syscon / regmap to assigning the corresponding register
  region directly to the driver (like meson6-dwmac does it)
- dropped "fix_mac_speed" callback since the reference driver does not
  implement it (I could not test if it is required due to lack of
  hardware)
- switch to common clock framework now that we know what bits 5:4
  (mux clock), 6:5 (250MHz divider) and 10 (configurable 5 or 10
  divider) are used for
- Removed dts property "amlogic,mp2-clock" because it is now part of
  the clocks which are registered by the glue driver
- Removed dts properties "amlogic,enable-tx-phy-ref-clk" and
  "amlogic,tx-delay" because it seems we can guess them based on the
  phy-mode (the original Amlogic dts files only supply two different
  values: one value for the internal RMII PHY and another one for the
  external RGMII Gbit PHY).
  If required we can extend the code in the future to make these
  configurable.
- This means that the only Meson8b / GXBB specific part of the binding
  is the clkin0 (FCLK_DIV2) clock, as it's needed for the mux clock.
  Everything else is auto-detected based on the phy-mode (which is
  already mandatory in stmmac).

I have successfully tested this on a Vega S95 Meta clone which comes
with a "broken" bootloader (which programs the ethernet registers to
"Fast Ethernet / RGMII" mode, while the board has a Realtek Gbit PHY).
Before this series stmmac was detected, I got a network interface but
no traffic was flowing.

Due to lack of hardware I could not test this on a device which uses
the internal RMII (Fast Ethernet) PHY.


Martin Blumenstingl (3):
  net: dt-bindings: Document the new Meson8b and GXBB DWMAC bindings
  net: stmmac: add a glue driver for the Amlogic Meson 8b / GXBB DWMAC
  ARM64: dts: meson-gxbb: use the new GXBB DWMAC glue driver

 .../devicetree/bindings/net/meson-dwmac.txt        |  43 ++-
 arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi        |   7 +-
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   2 +-
 .../net/ethernet/stmicro/stmmac/dwmac-meson8b.c    | 327 +++++++++++++++++++++
 4 files changed, 367 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c

-- 
2.9.3
