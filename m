From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH v2 net-next v2 0/4] net: dsa: mv88e6xxx: rework reset and PPU code
Date: Mon,  5 Dec 2016 11:26:59 -0500
Message-ID: <20161205162703.22567-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Stefan Eichenberger <eichest@gmail.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33486 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751451AbcLEQ1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 11:27:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Old Marvell chips (like 88E6060) don't have a PHY Polling Unit (PPU).

Next chips (like 88E6185) have a PPU, which has exclusive access to the
PHY registers, thus must be disabled before access.

Newer chips (like 88E6352) have an indirect mechanism to access the PHY
registers whenever, thus loose control over the PPU (always enabled).

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
PPU, and execute software reset. With these new ops in place, rework the
switch reset code and finally get rid of the MV88E6XXX_FLAG_PPU* flags.

Changes in v2:
  - wait in ppu/reset ops so that ppu_polling is not needed anymore.

Vivien Didelot (4):
  net: dsa: mv88e6xxx: add helper to disable ports
  net: dsa: mv88e6xxx: add helper to hardware reset
  net: dsa: mv88e6xxx: add a soft reset operation
  net: dsa: mv88e6xxx: add PPU operations

 drivers/net/dsa/mv88e6xxx/chip.c      | 178 +++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx/global1.c   | 178 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |   7 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  34 +++----
 4 files changed, 278 insertions(+), 119 deletions(-)

-- 
2.10.2
