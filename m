From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 00/22] net: phy: refactoring and Micrel features
Date: Tue, 11 Nov 2014 18:37:18 +0100
Message-ID: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>,
	Bruno Thomsen <bth@kamstrup.dk>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fixes a couple of minor issues, refactors phy-driver
registration, adds device and device-type abstractions to the micrel
driver, and adds support for broadcast disable, led-mode and
RMII-reference clock selection for KSZ8081 and KSZ8091 devices.

While adding support for more features for the Micrel PHYs mentioned
above, it became apparent that the configuration space is much too large
and that adding type-specific callbacks will simply not scale. Instead I
added a driver_data field to struct phy_device, which can be used to
store static device type data that can be parsed and acted on in
generic driver callbacks instead. This allows a lot of duplicated code
to be removed, and should make it much easier to add new features or
deal with device-type quirks in the future.

This series has been tested on a dual KSZ8081 setup (which wasn't
supported until now). Further testing on other Micrel PHYs would be much
appreciated.

Note that the final patch effectively reverts the recent commit
a95a18afe4c8 ("phy/micrel: KSZ8031RNL RMII clock reconfiguration bug"),
which claims that some KSZ8031 PHY  become unresponsive if the broadcast
disable flag is set before configuring the clock mode, even though
disabling the broadcast address is generally the first thing you want to
do (e.g. to avoid unnecessary reconfigurations).

Hopefully, the author of that commit (on CC) can confirm whether this is
indeed the case, and if so the final patch can be dropped unless it can
be worked around in a different way (which I suspect).

Thanks,
Johan


Johan Hovold (22):
  dt/bindings: fix documentation of ethernet-phy compatible property
  net: phy: add module_phy_driver macro
  net: phy: replace phy_driver_register calls
  net: phy: replace phy_drivers_register calls
  net: phy: micrel: fix config_intr error handling
  net: phy: micrel: use BIT macro
  net: phy: micrel: refactor broadcast disable
  net: phy: micrel: disable broadcast for KSZ8081/KSZ8091
  net: phy: micrel: add led-mode sanity check
  net: phy: micrel: refactor led-mode error handling
  net: phy: micrel: clean up led-mode setup
  net: phy: micrel: enable led-mode for KSZ8081/KSZ8091
  net: phy: add static data field to struct phy_driver
  net: phy: micrel: add device-type abstraction
  net: phy: micrel: parse of nodes at probe
  net: phy: micrel: add has-broadcast-disable flag to type data
  net: phy: micrel: add generic rmii-ref-clk-sel support
  net: phy: micrel: add support for rmii_ref_clk_sel to KSZ8081/KSZ8091
  dt/bindings: add micrel,rmii_ref_clk_sel_25_mhz to eth-phy binding
  net: phy: micrel: refactor interrupt config
  net: phy: micrel: add copyright entry
  net: phy: micrel: use generic config_init for KSZ8021/KSZ8031

 Documentation/devicetree/bindings/net/micrel.txt |  11 +-
 Documentation/devicetree/bindings/net/phy.txt    |   3 +-
 drivers/net/phy/amd-xgbe-phy.c                   |  15 +-
 drivers/net/phy/amd.c                            |  17 +-
 drivers/net/phy/at803x.c                         |  14 +-
 drivers/net/phy/bcm63xx.c                        |  15 +-
 drivers/net/phy/bcm7xxx.c                        |  15 +-
 drivers/net/phy/bcm87xx.c                        |  14 +-
 drivers/net/phy/broadcom.c                       |  15 +-
 drivers/net/phy/cicada.c                         |  15 +-
 drivers/net/phy/davicom.c                        |  15 +-
 drivers/net/phy/et1011c.c                        |  17 +-
 drivers/net/phy/icplus.c                         |  15 +-
 drivers/net/phy/lxt.c                            |  15 +-
 drivers/net/phy/marvell.c                        |  15 +-
 drivers/net/phy/micrel.c                         | 346 ++++++++++++++---------
 drivers/net/phy/national.c                       |  17 +-
 drivers/net/phy/qsemi.c                          |  17 +-
 drivers/net/phy/realtek.c                        |  13 +-
 drivers/net/phy/smsc.c                           |  14 +-
 drivers/net/phy/ste10Xp.c                        |  15 +-
 drivers/net/phy/vitesse.c                        |  14 +-
 include/linux/micrel_phy.h                       |   1 -
 include/linux/phy.h                              |  26 ++
 24 files changed, 278 insertions(+), 396 deletions(-)

-- 
2.0.4
