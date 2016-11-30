From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/6] net: dsa: mv88e6xxx: rework reset and PPU code
Date: Wed, 30 Nov 2016 17:59:24 -0500
Message-ID: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Old Marvell chips (like 88E6060) don't have a PHY Polling Unit (PPU).

Next chips (like 88E6185) have a PPU, which has exclusive access to the
PHY registers, thus must be disabled before access.

Newer chips (like 88E6352) have an indirect mechanism to access the PHY
registers whenever, thus loose control over the PPU (alway enabled).

Here's a summary:

Model | PPU? | Has PPU ctrl?  | PPU state readable? | PHY access
----- | ---- | -------------- | ------------------- | ----------
 6060 | no   | no             | no                  | direct
 6185 | yes  | yes, PPUEn bit | yes, PPUState 2-bit | direct w/ PPU dis.
 6352 | yes  | no             | yes, PPUState 1-bit | indirect
 6390 | yes  | no             | yes, InitState bit  | indirect

Depending on the PPU control, a switch may have to restart the PPU when
resetting the switch. Once the switch is reset, we must wait for the PPU
state to be active polling again before accessing the registers.

For that purpose, add new operations to the chips to enable/disable the
PPU and check its polling state, and execute software reset. With these
new ops in place, rework the switch reset code and finally get rid of
the MV88E6XXX_FLAG_PPU* flags.

Vivien Didelot (6):
  net: dsa: mv88e6xxx: add helper to disable ports
  net: dsa: mv88e6xxx: add helper to hardware reset
  net: dsa: mv88e6xxx: add a software reset op
  net: dsa: mv88e6xxx: add a PPU polling op
  net: dsa: mv88e6xxx: add helper for switch ready
  net: dsa: mv88e6xxx: add PPU enable/disable ops

 drivers/net/dsa/mv88e6xxx/chip.c      | 241 ++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx/global1.c   | 111 ++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |  10 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  35 ++---
 4 files changed, 292 insertions(+), 105 deletions(-)

-- 
2.10.2
