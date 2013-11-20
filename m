From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFC v1 0/7] net: phy: Ethernet PHY powerdown optimization
Date: Wed, 20 Nov 2013 21:21:46 +0100
Message-ID: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ethernet PHYs consume a significant amount of power when link is detected.
Especially, for embedded systems it can be easily 20-40% of total system
power. Now, currently most likely all ethernet drivers leave PHYs powered
on, even if the device is taken down. Also, some stupid boot loaders power
on all PHYs available.

This RFC deals with saving power consumed by ethernet PHYs, that have no
corresponding ethernet device driver or are attached to ethernet devices
which are taken down by user request, i.e. ifconfig ethN down. Ports with
no link, i.e. cable removed, are already quite good at power saving due to
PHY internal link detection.

I did some power measurements for 4 different boards with 3 different
drivers (all ARM) and reduction in power dissipation is usually ~500mW
per port. Guruplug savings are a bit high, but while re-testing v3.12
it just crashed because of heat issues - a known problem with this board
so don't take the absolute values too serious.

Now, the reason why I send this as a RFC and not a real patch set is,
that I started with mv643xx_eth which is an "evolutionary piece of code"
and phy support isn't that well done. When touching mvneta/cpsw, I saw
that phy_suspend/resume should possibly better be hidden in phy_start
and phy_stop, respectively. Also, suspending unused PHYs has the potential
to break stuff and I only had some ARM boards available to test.

Anyway, it would be great to get some general feed-back for the current
approach and possible improvements.

The individual patches can be summarized as follows:
Patch 1 adds genphy suspend/resume callbacks to Marvell PHYs.
Patch 2 introduces phy_resume and phy_suspend helpers to ease calling
the corresponding PHY driver callbacks, if available.
Patch 3 calls above helpers to automatically resume PHYs on
phy_attach and suspend them on phy_detach.
Patch 4 adds a late_initcall to suspend unused PHYs that have not been
taken by any driver. This is what we already have for unused clocks in
the common clock framework.
Patch 5, 6, and 7 add phy_resume/suspend to the three individual drivers
on their open/stop callbacks. This suspends the PHY as soon as the ethernet
device is taken down by ifconfig ethN down.

Below are the results of recent linux/master against this RFC. All links
are 1Gbps except Beaglebone Black wich is 100Mbps only.

A branch with the RFC applied can also be found at:
https://github.com/shesselba/linux-dove.git topic/ethphy-power-rfc-v1

Sebastian

(a) SolidRun CuBox, Marvell Dove, Marvell 88E1310, mv643xx_eth
                          v3.12     +RFC diff/abs diff/rel
1 port, link, up        2115 mW  2116 mW  +  1 mW   + 0.0%
1 port, link, down      2104 mW  1572 mW  -532 mW   -25.3%
1 port, no link, up     1600 mW  1614 mW  + 14 mW   + 0.9%
1 port, no link, down   1604 mW  1577 mW  - 27 mW   - 1.7%

(b) Beaglebone Black, TI AM3359, SMSC LAN8710/8720, cpsw (100Mbps)
                          v3.12     +RFC diff/abs diff/rel
1 port, link, up        1247 mW  1248 mW  +  1 mW   + 0.1%
1 port, link, down      1247 mW   808 mW  -439 mW   -35.2%
1 port, no link, up      817 mW   817 mW  +  0 mW   + 0.0%
1 port, no link, down    808 mW   809 mW  +  1 mW   + 0.1%

(c) Globalscale Guruplug, Marvell Kirkwood, Marvell 88E1121, mv643xx_eth
                          v3.12     +RFC diff/abs diff/rel
2 ports, link, up       6611 mW  6587 mW -  24 mW   - 0.4%
2 ports, link, down     6625 mW  3881 mW -2744 mW   -41.4%
2 ports, no link, up    4072 mW  4002 mW -  70 mW   - 1.7%
2 ports, no link, down  4085 mW  3875 mW - 210 mW   - 5.1%
1 port, link, up
1 port, link, down      6622 mW  5193 mW -1429 mW   -21.6%
1 port, link, up
1 port, no link, down   5276 mW  5193 mW -  83 mW   - 1.6%
1 port, no link, up
1 port, no link, down   4029 mW  3941 mW -  88 mW   - 2.2%

(d) Globalscale Mirabox, Marvell Armada 370, Marvell 88E1510, mvneta
                          v3.12     +RFC diff/abs diff/rel
2 ports, link, up       5218 mW  5177 mW  - 41 mW   - 0.8%
2 ports, link, down     5216 mW  4225 mW  -991 mW   -19.0%
2 ports, no link, up    4352 mW  4320 mW  - 32 mW   - 0.7%
2 ports, no link, down  4352 mW  4228 mW  -124 mW   - 2.8%
1 port, link, up
1 port, link, down      5218 mW  4718 mW  -500 mW   - 9.6%
1 port, link, up
1 port, no link, down   4842 mW  4722 mW  -120 mW   - 2.5%
1 port, no link, up
1 port, no link, down   4356 mW  4290 mW  - 66 mW   - 1.5%

Sebastian Hesselbarth (7):
  net: phy: marvell: provide genphy suspend/resume
  net: phy: provide phy_resume/phy_suspend helpers
  net: phy: resume/suspend PHYs on attach/detach
  net: phy: suspend unused PHYs on mdio_bus in late_initcall
  net: mv643xx_eth: resume/suspend PHY on port start/stop
  net: mvneta: resume/suspend PHY on port start/stop
  net: cpsw: resume/suspend PHY on port start/stop

 drivers/net/ethernet/marvell/mv643xx_eth.c |    7 +++++++
 drivers/net/ethernet/marvell/mvneta.c      |    2 ++
 drivers/net/ethernet/ti/cpsw.c             |    2 ++
 drivers/net/phy/marvell.c                  |   22 ++++++++++++++++++++++
 drivers/net/phy/mdio_bus.c                 |   27 +++++++++++++++++++++++++++
 drivers/net/phy/phy_device.c               |   22 ++++++++++++++++++++++
 include/linux/phy.h                        |    2 ++
 7 files changed, 84 insertions(+), 0 deletions(-)

---
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
-- 
1.7.2.5
