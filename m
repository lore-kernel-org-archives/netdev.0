From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH v3 0/2] ravb: add wake-on-lan support via magic packet
Date: Tue,  1 Aug 2017 12:14:35 +0200
Message-ID: <20170801101437.9020-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WoL is enabled in the suspend callback by setting MagicPacket detection
and disabling all interrupts expect MagicPacket. In the resume path the
driver needs to reset the hardware to rearm the WoL logic, this prevents
the driver from simply restoring the registers and to take advantage of
that ravb was not suspended to reduce resume time. To reset the
hardware the driver closes the device, sets it in reset mode and reopens
the device just like it would do in a normal suspend/resume scenario
without WoL enabled, but it both closes and opens the device in the
resume callback since the device needs to be reset for WoL to work.

One quirk needed for WoL is that the module clock needs to be prevented
from being switched off by Runtime PM. To keep the clock alive the
suspend callback need to call clk_enable() directly to increase the
usage count of the clock. Then when Runtime PM decreases the clock usage
count it won't reach 0 and be switched off.

Changes since v2
- Only do the clock dance to workaround PSCI sleep when resuming if WoL 
  is enabled. This was a bug in v2 which resulted in a WARN if resuming 
  from PSCI sleep with WoL disabled, thanks Sergei for pointing this 
  out!
- Break out clock dance workaround in separate patch to make it easier 
  to revert once a fix is upstream for the clock driver as suggested by 
  Sergei.

Changes since v1
- Fix issue where device would fail to resume from PSCI suspend if WoL
  was enabled, reported by Geert. The fault was that the clock driver
  thinks the clock is on, but PSCI have disabled it, added workaround
  for this in ravb driver which can be removed once the clock driver is
  aware of the PSCI behavior.
- Only try to restore from wol wake up if netif is running, since this
  is a condition to enable wol in the first place this was a bug in v1.

Niklas Söderlund (2):
  ravb: add wake-on-lan support via magic packet
  ravb: add workaround for clock when resuming with WoL enabled

 drivers/net/ethernet/renesas/ravb.h      |   2 +
 drivers/net/ethernet/renesas/ravb_main.c | 131 ++++++++++++++++++++++++++++++-
 2 files changed, 129 insertions(+), 4 deletions(-)

-- 
2.13.3
