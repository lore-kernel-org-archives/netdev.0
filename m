From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: mv643xx_eth pull request for 2.6.28
Date: Mon, 22 Sep 2008 05:19:31 +0200
Message-ID: <20080922031931.GA7678@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@cam.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Dale Farnsworth <dale@farnsworth.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48998 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbYIVDTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 23:19:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

This is the set of mv643xx_eth patches intended for 2.6.28.  It has
most of the patches posted to the list in the last couple of weeks,
plus three more fixes:
- Unless we tell the hardware to include the pseudo-header when
  checksumming, all packets will be received with the hardware
  indicating a bad checksum, causing the driver to set CHECKSUM_NONE
  on all packets, i.e. hardware receive checksum offload won't be
  used at all.  We need to set the bit that tells the hardware to
  include the pseudo-header when checksumming.
- The driver would corrupt the packet on transmit if the L3 header
  didn't start 14, 18, 22 or 26 bytes into the packet.  Now it'll
  just call skb_checksum_help() to do checksumming in software if
  this happens.
- Due to a hardware bug, the 64 bit hardware byte counters are
  effectively only 32 bit, which necessitates polling them at least
  once every ~30 seconds to prevent them from overflowing.

I've also included the mv643xx_eth phylib conversion, as Andy Fleming
ACKed it.  The skb recycling bits aren't included (need more discussion),
and neither are the Pegasos SRAM bits, since I didn't receive any tester
feedback on them.

I've tested this series extensively on all mv643xx_eth hardware I have
available, and it all looks good.  Please pull.


thanks,
Lennert



The following changes since commit 24342c34a022ee90839873d91396045e12ef1090:
  Linus Torvalds (1):
        Linux 2.6.27-rc5

are available in the git repository at:

  git://git.marvell.com/mv643xx_eth.git for-2.6.28
  http://git.marvell.com/?p=mv643xx_eth.git;a=shortlog;h=for-2.6.28

Lennert Buytenhek (28):
      mv643xx_eth: fix 'netdev_priv(dev) == dev->priv' assumption
      mv643xx_eth: fix receive buffer DMA unmapping
      mv643xx_eth: get rid of IRQF_SAMPLE_RANDOM
      mv643xx_eth: get rid of modulo operations
      mv643xx_eth: switch ->phy_lock from a spinlock to a mutex
      mv643xx_eth: use the SMI done interrupt to wait for SMI access completion
      mv643xx_eth: make napi unconditional
      mv643xx_eth: get rid of receive-side locking
      mv643xx_eth: get rid of compile-time configurable transmit checksumming
      mv643xx_eth: require contiguous receive and transmit queue numbering
      mv643xx_eth: smi sharing is a per-unit property, not a per-port one
      mv643xx_eth: remove force_phy_addr field
      mv643xx_eth: get rid of netif_{stop,wake}_queue() calls on link down/up
      mv643xx_eth: delete unused and uninteresting interrupt source mask bits
      mv643xx_eth: transmit multiqueue support
      mv643xx_eth: move all work to the napi poll handler
      mv643xx_eth: switch to netif tx queue lock, get rid of private spinlock
      mv643xx_eth: avoid dropping tx lock during transmit reclaim
      mv643xx_eth: replace array of skbs awaiting transmit completion with a queue
      mv643xx_eth: shrink default receive and transmit queue sizes
      mv643xx_eth: avoid reading ->byte_cnt twice during receive processing
      mv643xx_eth: add support for chips without transmit bandwidth control
      mv643xx_eth: fix receive checksumming
      mv643xx_eth: deal with unexpected ethernet header sizes
      mv643xx_eth: enforce frequent hardware statistics polling
      phylib: allow incremental scanning of an mii bus
      mv643xx_eth: convert to phylib
      mv643xx_eth: bump version to 1.4

 arch/arm/mach-kirkwood/db88f6281-bp-setup.c  |    2 +-
 arch/arm/mach-kirkwood/rd88f6192-nas-setup.c |    2 +-
 arch/arm/mach-kirkwood/rd88f6281-setup.c     |    2 +-
 arch/arm/mach-loki/lb88rc8480-setup.c        |    2 +-
 arch/arm/mach-mv78xx0/common.c               |    6 +-
 arch/arm/mach-mv78xx0/db78x00-bp-setup.c     |    8 +-
 arch/arm/mach-orion5x/db88f5281-setup.c      |    2 +-
 arch/arm/mach-orion5x/dns323-setup.c         |    2 +-
 arch/arm/mach-orion5x/kurobox_pro-setup.c    |    2 +-
 arch/arm/mach-orion5x/mss2-setup.c           |    2 +-
 arch/arm/mach-orion5x/mv2120-setup.c         |    2 +-
 arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c |    2 +-
 arch/arm/mach-orion5x/rd88f5181l-ge-setup.c  |    2 +-
 arch/arm/mach-orion5x/rd88f5182-setup.c      |    2 +-
 arch/arm/mach-orion5x/ts78xx-setup.c         |    3 +-
 arch/arm/mach-orion5x/tsx09-common.c         |    2 +-
 arch/arm/mach-orion5x/wnr854t-setup.c        |    2 +-
 arch/arm/mach-orion5x/wrt350n-v2-setup.c     |    2 +-
 arch/powerpc/sysdev/mv64x60_dev.c            |    6 +-
 drivers/net/Kconfig                          |    2 +-
 drivers/net/mv643xx_eth.c                    | 1438 +++++++++++++-------------
 drivers/net/phy/mdio_bus.c                   |   89 +-
 include/linux/mv643xx_eth.h                  |   13 +-
 include/linux/phy.h                          |    2 +
 24 files changed, 820 insertions(+), 777 deletions(-)
