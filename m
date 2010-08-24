From: Anton Vorontsov <avorontsov@mvista.com>
Subject: [PATCH] phylib: Fix race between returning phydev and calling
 adjust_link
Date: Tue, 24 Aug 2010 23:34:12 +0400
Message-ID: <20100824193412.GA1887@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is possible that phylib will call adjust_link before returning
from {,of_}phy_connect(), which may cause the following [very rare,
though] oops upon reopening the device:

  Unable to handle kernel paging request for data at address 0x0000024c
  Oops: Kernel access of bad area, sig: 11 [#1]
  PREEMPT SMP NR_CPUS=2 LTT NESTING LEVEL : 0
  P1021 RDB
  Modules linked in:
  NIP: c0345dac LR: c0345dac CTR: c0345d84
  TASK = dffab6b0[30] 'events/0' THREAD: c0d24000 CPU: 0
  [...]
  NIP [c0345dac] adjust_link+0x28/0x19c
  LR [c0345dac] adjust_link+0x28/0x19c
  Call Trace:
  [c0d25f00] [000045e1] 0x45e1 (unreliable)
  [c0d25f30] [c036c158] phy_state_machine+0x3ac/0x554
  [...]

Here is why. Drivers store phydev in their private structures, e.g.
gianfar driver:

static int init_phy(struct net_device *dev)
{
	...
	priv->phydev = of_phy_connect(...);
	...
}

So that adjust_link could retrieve it back:

static void adjust_link(struct net_device *dev)
{
	...
	struct phy_device *phydev = priv->phydev;
	...
}

If the device has been opened before, then phydev->state is set to
PHY_HALTED (or undefined if the driver didn't call phy_stop()).

Now, phy_connect starts the PHY state machine before returning phydev to
the driver:

	phy_start_machine(phydev, NULL);

	if (phydev->irq > 0)
		phy_start_interrupts(phydev);

	return phydev;

The time between 'phy_start_machine()' and 'return phydev' is undefined.
The start machine routine delays execution for 1 second, which is enough
for most cases. But under heavy load, or if you're unlucky, it is quite
possible that PHY state machine will execute before phy_connect()
returns, and so adjust_link callback will try to dereference phydev,
which is not yet ready.

To fix the issue, simply initialize the PHY's state to PHY_READY during
phy_attach(). This will ensure that phylib won't call adjust_link before
phy_start().

Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>
---
 drivers/net/phy/phy_device.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index c076119..16ddc77 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -466,6 +466,8 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 
 	phydev->interface = interface;
 
+	phydev->state = PHY_READY;
+
 	/* Do initial configuration here, now that
 	 * we have certain key parameters
 	 * (dev_flags and interface) */
-- 
1.7.0.5
