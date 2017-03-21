From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: [PATCH net-next 0/7] Clean up PHY MMD accessors
Date: Tue, 21 Mar 2017 16:35:55 +0000
Message-ID: <20170321163555.GA21222@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Woojung Huh <woojung.huh@microchip.com>,
 Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
 linux-usb@vger.kernel.org,
 Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
 linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
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

This series cleans up phylib's MMD accessors, so that we have a common
way of accessing the Clause 45 register set.

The current situation is far from ideal - we have phy_(read|write)_mmd()
which accesses Clause 45 registers over Clause 45 accesses, and we have
phy_(read|write)_mmd_indirect(), which accesses Clause 45 registers via
Clause 22 register 13/14.

Generic code uses the indirect methods to access standard Clause 45
features, and when we come to add Clause 45 PHY support to phylib, we
would need to make these conditional upon the PHY type, or duplicate
these functions.

An alternative solution is to merge these accessors together, and select
the appropriate access method depending upon the 802.3 clause that the
PHY conforms with.  The result is that we have a single set of
phy_(read|write)_mmd() accessors.

For cases which require special handling, we still allow PHY drivers to
override all MMD accesses - except rather than just overriding the
indirect accesses.  This keeps existing overrides working.

Combining the two also has another beneficial side effect - we get rid
of similar functions that take arguments in different orders.  The
old direct accessors took the phy structure, devad and register number,
whereas the indirect accessors took the phy structure, register number
and devad in that order.  Care must be taken when updating future
drivers that the argument order is correct, and the function name is
not merely replaced.

This patch set is against net-next.

 drivers/net/phy/Makefile      |   2 +-
 drivers/net/phy/bcm-phy-lib.c |  12 ++---
 drivers/net/phy/dp83867.c     |  25 +++++-----
 drivers/net/phy/intel-xway.c  |  26 +++++-----
 drivers/net/phy/micrel.c      |  13 +++--
 drivers/net/phy/microchip.c   |   5 +-
 drivers/net/phy/phy-core.c    | 101 ++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/phy.c         | 110 ++++--------------------------------------
 drivers/net/phy/phy_device.c  |   4 +-
 drivers/net/usb/lan78xx.c     |  10 ++--
 include/linux/phy.h           |  80 +++++++++---------------------
 11 files changed, 178 insertions(+), 210 deletions(-)

RFC->v1:
- minor update patch 2 to resolve a build error that the 0-day builder
  discovered.
- reviewed-by / acked-bys added

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
