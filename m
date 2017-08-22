From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 0/2] net: Fix crashes due to activity during suspend
Date: Tue, 22 Aug 2017 20:37:24 +0200
Message-ID: <1503427046-17618-1-git-send-email-geert+renesas@glider.be>
Cc: Lukas Wunner <lukas@wunner.de>,
        "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
        netdev@vger.kernel.org, linux-pm@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from michel.telenet-ops.be ([195.130.137.88]:42234 "EHLO
        michel.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752202AbdHVShg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:37:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hi all,

If an Ethernet device is used while the device is suspended, the system may
crash.

E.g. on sh73a0/kzm9g and r8a73a4/ape6evm, the external Ethernet chip is
driven by a PM controlled clock.  If the Ethernet registers are accessed
while the clock is not running, the system will crash with an imprecise
external abort.

This patch series fixes two of such crashes:
  1. The first patch prevents the PHY polling state machine from accessing
     PHY registers while a device is suspended,
  2. The second patch prevents the net core from trying to transmit packets
     when an smsc911x device is suspended.

Both crashes can be reproduced on sh73a0/kzm9g and r8a73a4/ape6evm during
s2ram (rarely), or by using pm_test (more likely to trigger):

    # echo 0 > /sys/module/printk/parameters/console_suspend
    # echo platform > /sys/power/pm_test
    # echo mem > /sys/power/state

With this series applied, my test systems survive a loop of 100 test
suspends.

Thanks for your comments!

Geert Uytterhoeven (2):
  net: phy: Freeze PHY polling before suspending devices
  net: smsc911x: Quiten netif during suspend

 drivers/net/ethernet/smsc/smsc911x.c | 15 ++++++++++++++-
 drivers/net/phy/phy.c                | 12 +++++++-----
 2 files changed, 21 insertions(+), 6 deletions(-)

-- 
2.7.4

Gr{oetje,eeting}s,

						Geert
