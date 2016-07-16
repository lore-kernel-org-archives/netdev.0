From: Jamie Lentin <jm@lentin.co.uk>
Subject: [PATCH v0 00/10] Convert Netgear WNR854T to devicetree
Date: Sat, 16 Jul 2016 15:28:58 +0100
Message-ID: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This is an attempt to resurrect the mainline WNR854T support (I had no
luck getting a non-DT kernel to boot). First 2 patches are trivial,
the next 3 add DT bindings for the SoC, then the old board file is
swapped out for DT. The final 3 patches configure the PHY leds as
Netgear intended.

There's one major flaw; unicast traffic is never received on any port.
Broadcast traffic is received however, and on the correct port. Thus
an external machine can make an ARP request and get a response, for
example. With a manually-entered ARP entry, the router can send pings
out to a remote machine which responds, and the response is lost in the
DSA switch. "ethtool -S" reports pings received on "in_unicast" but
nothing makes it through the switch. This thread[0] seems very similar.
I've run out of ideas here and can't find any switch datasheets to give
me pointers so any suggestions greatly appreciated.

I've not tried to move the PCI support into DT yet. Are there other
branches that tackle this already?

Patch 8 is the least-intrusive patch I could think of to find the PHY
node, but I'm not sure it's the best approach. I tried to get
dsa_slave_phy_connect() to wire up the OF node correctly[1], but doing
this properly would require changes to the mdiobus api, any exposed
methods register all nodes in an MDIO bus node, which doesn't exist in
this case.

Applied against v4.6 mainline, .config:
http://jamie.lentin.co.uk/devices/netgear-wnr854t/wnr854t-support-v0a/kernel-config.txt
Log output:
http://jamie.lentin.co.uk/devices/netgear-wnr854t/wnr854t-support-v0a/u-boot.dmesg.txt

The patchset is also available here:
https://github.com/lentinj/linux/commits/wnr854t-support-v0a

To use the supplied PCI Wifi card see the following patch:
https://github.com/lentinj/linux/commit/d6b7b4695b7dcbf36d0663aea9cb4ecd65a1ada8
...but this is probably a matter for another thread.

Cheers,

[0] http://thread.gmane.org/gmane.linux.network/120616/focus=121320
[1] https://github.com/lentinj/linux/commit/a4bceebb08ecdc25a4d49e23f2abad214868460e

Jamie Lentin (10):
  arm: orion5x: Add required properties for orion-wdt to DT node
  arm: orion5x: Add documentation for SoC and board bindings
  arm: orion5x: Add clk support for mv88f5181
  arm: orion5x: Generalise mv88f5181l pinctrl support for 88f5181
  arm: orion5x: Add DT include for mv88f5181
  arm: orion5x: Add DT-based support for Netgear WNR854T
  arm: orion5x: Remove old non-DT-based WNR854T support
  net: phy: Try looking for a phy-handle property to find the OF node
  net: phy: Re-attempt custom DT configuration after configuration
  arm: orion5x: Configure Netgear WNR854T network port LEDs

 .../bindings/arm/marvell/marvell,orion5x.txt       |  25 +++
 .../devicetree/bindings/clock/mvebu-core-clock.txt |   1 +
 .../bindings/pinctrl/marvell,orion-pinctrl.txt     |   4 +-
 arch/arm/boot/dts/Makefile                         |   1 +
 arch/arm/boot/dts/orion5x-mv88f5181.dtsi           |  35 +++
 arch/arm/boot/dts/orion5x-netgear-wnr854t.dts      | 245 +++++++++++++++++++++
 arch/arm/boot/dts/orion5x.dtsi                     |   3 +-
 arch/arm/mach-orion5x/Kconfig                      |   6 +
 arch/arm/mach-orion5x/Makefile                     |   2 +-
 arch/arm/mach-orion5x/board-wnr854t.c              |  78 +++++++
 arch/arm/mach-orion5x/wnr854t-setup.c              | 185 ----------------
 drivers/clk/mvebu/orion.c                          |  70 ++++++
 drivers/net/phy/marvell.c                          |  26 ++-
 drivers/pinctrl/mvebu/pinctrl-orion.c              |  23 +-
 14 files changed, 498 insertions(+), 206 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
 create mode 100644 arch/arm/boot/dts/orion5x-mv88f5181.dtsi
 create mode 100644 arch/arm/boot/dts/orion5x-netgear-wnr854t.dts
 create mode 100644 arch/arm/mach-orion5x/board-wnr854t.c
 delete mode 100644 arch/arm/mach-orion5x/wnr854t-setup.c

-- 
2.8.1
