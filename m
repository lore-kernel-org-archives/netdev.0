From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 00/15] drivers: net: cpsw: improve runtime pm
Date: Wed, 15 Jun 2016 14:55:48 +0300
Message-ID: <20160615115603.4897-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series intended to improve runtime PM and allow CPSW to be
RPM suspended when all ethX netdevices are down.

To achieve above goal it is required to relax runtime PM constraints for
Davinci MDIO which blocks CPSW runtime PM now, because Davinci MDIO is always
powered on during probe and powered off only when it's going to be removed.
- Patches 6-11 implement PM runtime autosuspend for Davinci MDIO, but keep it
disabled by default, because Davinci MDIO is integrated in big set of TI devices
and not all of them verified to work correctly with RPM autosuspend enabled:
 expected to work on SoCs where MDIO is defined as part of CPSW in DT
 (cpsw.c DRA7/am57x, am437x, am335x)
The CPSW need to be fixed before RPM suspended can be allowed:
 - Patches 1-5 ensure that CPSW will not cause L3 errors while it is in RPM
   suspended state.

Davinci MDIO RPM autosuspend can be enabled through sysfs:
 echo 100 > /sys/devices/../48484000.ethernet/48485000.mdio/power/autosuspend_delay_ms

Patches 12 - 15: introduce new compatible string "ti,cpsw-mdio" which is used
then to enable RPM for am335x/am437x/dra7 SoCs.

Tested on am335x, am437x, am572x and k2g (on k2g with RPM disabled for Davinci MDIO)
These changes should not affect on errata i877 implementation on DRA7.

Power measurement on am335x GP EVM:
 Without this series:  547.60 mW total SoC power
 With this series + "ifconfig eth0 down": 477.32 mW Total Soc Power 

Grygorii Strashko (15):
  drivers: net: cpsw: fix suspend when all ethX devices are down
  drivers: net: cpsw: check return code from pm runtime calls
  drivers: net: cpsw: remove pm runtime calls from suspend callbacks
  drivers: net: cpsw: ethtool: fix accessing to suspended device
  drivers: net: cpsw: ndev: fix accessing to suspended device
  drivers: net: davinci_mdio: do pm runtime initialization later in
    probe
  drivers: net: davinci_mdio: remove pm runtime calls from suspend
    callbacks
  drivers: net: davinci_mdio: drop suspended and lock fields from
    mdio_data
  drivers: net: davinci_mdio: split reset function on init_clk and
    enable
  drivers: net: davinci_mdio: add pm runtime callbacks
  drivers: net: davinci_mdio: implement pm runtime auto mode
  net: davinci_mdio: document missed "ti,am4372-mdio" compat string
  net: davinci_mdio: introduce "ti,cpsw-mdio" compat string
  drivers: net: davinci_mdio: enable pm runtime auto for ti cpsw-mdio
  ARM: dts: am335x/am437x/dra7: use new "ti,cpsw-mdio" compat string

 .../devicetree/bindings/net/davinci-mdio.txt       |   3 +-
 arch/arm/boot/dts/am33xx.dtsi                      |   2 +-
 arch/arm/boot/dts/am4372.dtsi                      |   2 +-
 arch/arm/boot/dts/dra7.dtsi                        |   2 +-
 drivers/net/ethernet/ti/cpsw.c                     |  88 +++++++++--
 drivers/net/ethernet/ti/davinci_mdio.c             | 169 +++++++++++++--------
 6 files changed, 189 insertions(+), 77 deletions(-)

-- 
2.8.4
