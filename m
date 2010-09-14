From: Cyril Chemparathy <cyril-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v4 00/10] split out emac cpdma and mdio for reuse
Date: Tue, 14 Sep 2010 17:10:02 -0400
Message-ID: <1284498612-25294-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
        linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

Davinci's EMAC device has an in-built MDIO controller and a CPDMA engine.
These hardware modules are not restricted to EMAC device alone.  For example,
CPSW3G (3-port gigabit ethernet switch) hardware uses these very same modules
internally.  This patch series separates out EMAC's MDIO and CPDMA
functionality, allowing these individual pieces to be reused across TI
hardware.  

This patch series has been broadly organized as follows:

MDIO:
  - Add new functionality
      netdev: separate out davinci mdio controller code
  - Hookup new functionality
      davinci: add mdio platform devices
      omap: add mdio platform devices
      netdev: switch davinci emac to new mdio driver
  - Cleanup left over cruft
      davinci: cleanup unused davinci mdio arch code
      omap: cleanup unused davinci mdio arch code
      netdev: cleanup unused davinci mdio emac code

CPDMA:
  - Add new functionality
     netdev: separate out davinci cpdma controller code
  - Hookup new functionality
     netdev: switch davinci emac to new cpdma layer
  - Cleanup left over cruft
     netdev: cleanup unused davinci emac cpdma code

This series has been tested on dm365 and tnetv107x (with additional cpsw
patches) hardware.  Although am3517 (omap) board support code has been updated
as needed, emac does not work on this platform.

Changes from v1:
  1. Fixed memory leak in cpdma_chan_create() failure case
  2. Included new omap patches for am3517, avoids build breakage

Changes from v2:
  1. Updated series to include mityomapl138 board
  2. Minor white-space fixes

Changes from v3 (rolled in "post cpdma/mdio refactoring fixes" series):
  1. allow forced 100/full mode instead of phy auto-detect
  2. specify phy_id on boards that had a phy_mask defined earlier
  3. requeue cpdma descriptors when EOQ at submit
  4. use calculated mdio bus access times instead of hardcoded delays
  5. work around emac soft-reset impact on mdio controller state
  6. extend register dumps to include cpdma registers


Cyril Chemparathy (10):
  net: davinci_emac: separate out davinci mdio
  davinci: add mdio platform devices
  omap: add mdio platform devices
  net: davinci_emac: switch to new mdio
  davinci: cleanup mdio arch code and switch to phy_id
  omap: cleanup unused davinci mdio arch code
  net: davinci_emac: cleanup unused mdio emac code
  net: davinci_emac: separate out cpdma code
  net: davinci_emac: switch to new cpdma layer
  net: davinci_emac: cleanup unused cpdma code

 arch/arm/mach-davinci/board-da830-evm.c     |    7 +-
 arch/arm/mach-davinci/board-da850-evm.c     |    7 +-
 arch/arm/mach-davinci/board-dm365-evm.c     |    7 +-
 arch/arm/mach-davinci/board-dm644x-evm.c    |    8 +-
 arch/arm/mach-davinci/board-dm646x-evm.c    |    7 +-
 arch/arm/mach-davinci/board-mityomapl138.c  |    8 +-
 arch/arm/mach-davinci/board-neuros-osd2.c   |    7 +-
 arch/arm/mach-davinci/board-sffsdr.c        |    7 +-
 arch/arm/mach-davinci/devices-da8xx.c       |   31 +-
 arch/arm/mach-davinci/dm365.c               |   23 +-
 arch/arm/mach-davinci/dm644x.c              |   23 +-
 arch/arm/mach-davinci/dm646x.c              |   22 +-
 arch/arm/mach-davinci/include/mach/dm365.h  |    2 +-
 arch/arm/mach-davinci/include/mach/dm644x.h |    2 +-
 arch/arm/mach-davinci/include/mach/dm646x.h |    2 +-
 arch/arm/mach-omap2/board-am3517evm.c       |   31 +-
 drivers/net/Kconfig                         |   21 +
 drivers/net/Makefile                        |    2 +
 drivers/net/davinci_cpdma.c                 |  965 +++++++++++++++++++
 drivers/net/davinci_cpdma.h                 |  108 +++
 drivers/net/davinci_emac.c                  | 1338 ++++-----------------------
 drivers/net/davinci_mdio.c                  |  475 ++++++++++
 include/linux/davinci_emac.h                |   16 +-
 23 files changed, 1894 insertions(+), 1225 deletions(-)
 create mode 100644 drivers/net/davinci_cpdma.c
 create mode 100644 drivers/net/davinci_cpdma.h
 create mode 100644 drivers/net/davinci_mdio.c
