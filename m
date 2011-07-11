From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 00/46] Clean up RX copybreak and DMA handling
Date: Mon, 11 Jul 2011 02:52:46 +0200 (CEST)
Message-ID: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43647 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab1GKAwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quick rx_copybreak cleaning turned out to rise more dust around...

Most drivers use dma_sync_single_to_device() for buffers that are
written only by device. That's probably because of bad example in
current Documentation/DMA-API-HOWTO.txt. Why is it bad? It unnecessaril=
y
flushes cachelines and CPU write buffers for memory that is not used
by the hardware. Documentation/DMA-API.txt (part Id) describes exactly
when streaming DMA buffers should be synced and in which direction.
Syncing DMA_FROM_DEVICE mappings for device is not among them.

A lot of drivers drop packets already DMA'd in on memory pressure. This
is suboptimal:
  1. under packet storm and memory pressure NIC keeps generating interr=
upts
     (if non-NAPI) and indicating new buffers because it always has fre=
e
     RX buffers --- this only wastes CPU and bus bandwidth transferring
     data that is going to be immediately discarded;
  2. for users of swap over network (NBD, NFS - assumming those get
     fixed, or maybe FCoE?) this can cause deadlock if the packets
     (acks maybe?) are needed to reclaim memory.

It unlikely that you'll ever hit the dark scenarios above, but if you d=
o
you'll have a hard time debugging.

Menu:
 1..2:
	wrap code commonly used in drivers into generic functions
 3..4:
	remove dma_sync_to_device(DMA_FROM_DEVICE) from drivers not
	converted to common rx handling functions
 5..10:
	fix various DMA API usage bugs in rx handling code
 11..14:
	clean up rx buffer allocation in sun* drivers
 15:
	b43: use kfree_skb() if the skb is known not to have been used
 16:
	cxgb3: remove code dropping packets on memory pressure in driver
 46:
	mark some drivers that drop packets from rx queue head when under
	memory pressure

Left out for later:
 17..34:
	convert multiple drivers to common rx_copybreak handling
 35..45:
	convert multiple drivers to common rx_copybreak handling; those
	drivers drop rxed packets when under memory pressure

Patches 17..45 are more-or-less templated and in the same spirit as
the earlier version.
[davem: I plan send them after/if you agree to take patch 2. Or earlier=
,
if you want them all at once anyway.]

Best Regards,
Micha=C5=82 Miros=C5=82aw

---

Micha=C5=82 Miros=C5=82aw (46):
  net: introduce __netdev_alloc_skb_aligned()
  net: wrap common patterns of rx handler code
  net drivers: remove unnecessary dma_sync_to_device(DMA_FROM_DEVICE)
  net/wireless: p54: remove useless
    dma_sync_single_for_device(DMA_FROM_DEVICE)
  net: bnx2x: fix DMA sync direction
  net/tokenring: 3c359: fix DMA API usage
  net/wireless: ath9k: fix DMA API usage
  net/wireless: b43: fix DMA direction for RX buffers
  net: octeon_mgmt: fix DMA unmap size
  net: jme: convert to generic DMA API
  net: sungem: cleanup RX skb allocation
  net: sunhme: cleanup RX skb allocation
  net: sunbmac: cleanup RX skb allocation
  net: sunbmac: cleanup magic '34'
  net/wireless: b43: use kfree_skb() for untouched skbs
  net: cxgb3: don't drop packets on memory pressure in driver
  net: 3c59x: use common rx_copybreak handling
  net: epic100: use common rx_copybreak handling
  net: fealnx: use common rx_copybreak handling
  net: hamachi: use common rx_copybreak handling
  net: bcm63xx: use common rx_copybreak handling
  net: chelsio: use common rx_copybreak handling
  net: cxgb3: use common rx_copybreak handling
  net: dl2k: use common rx_copybreak handling
  net: natsemi: use common rx_copybreak handling
  net: sis190: use common rx_copybreak handling
  net: starfire: use common rx_copybreak handling
  net: sundance: use common rx_copybreak handling
  net: tulip/interrupt: use common rx_copybreak handling
  net: tulip/winbond-840: use common rx_copybreak handling
  net: typhoon: use common rx_copybreak handling
  net: via-rhine: use common rx_copybreak handling
  net: via-velocity: use common rx_copybreak handling
  net: yellowfin: use common rx_copybreak handling
  net: lib82596: use common rx_copybreak handling [strict refill!]
  net: pcnet32: use common rx_copybreak handling [strict refill!]
  net: sgiseeq: use common rx_copybreak handling [strict refill!]
  net: tulip/de2104x: use common rx_copybreak handling [strict refill!]
  net: sunhme: use common rx_copybreak handling [strict refill!]
  net: sunbmac: use common rx_copybreak handling [strict refill!]
  net: rrunner: use common rx_copybreak handling [strict refill!]
  net: greth: use common rx_copybreak handling [strict refill!]
  net: sunbmac: use common rx_copybreak handling [strict refill!]
  net: tokenring/3c359: use common rx_copybreak handling [strict
    refill!]
  net/wireless: adm8211: use common rx_copybreak handling [strict
    refill!]
  net: mark drivers that drop packets from rx queue head under memory
    pressure

 drivers/net/3c59x.c                         |   23 +---
 drivers/net/arm/ep93xx_eth.c                |    6 +-
 drivers/net/b44.c                           |    4 -
 drivers/net/bcm63xx_enet.c                  |   28 +----
 drivers/net/bnx2.c                          |    7 +-
 drivers/net/bnx2x/bnx2x_cmn.c               |    5 +-
 drivers/net/bnx2x/bnx2x_cmn.h               |    5 -
 drivers/net/bnx2x/bnx2x_ethtool.c           |    2 +-
 drivers/net/cassini.c                       |   15 +--
 drivers/net/chelsio/sge.c                   |   42 +------
 drivers/net/cxgb3/sge.c                     |   57 ++-------
 drivers/net/dl2k.c                          |   28 +----
 drivers/net/e100.c                          |    3 -
 drivers/net/e1000e/netdev.c                 |    4 +-
 drivers/net/epic100.c                       |   32 ++----
 drivers/net/fealnx.c                        |   40 ++-----
 drivers/net/greth.c                         |   67 ++++-------
 drivers/net/hamachi.c                       |   42 +------
 drivers/net/jme.c                           |   40 +++----
 drivers/net/lib82596.c                      |   70 +++--------
 drivers/net/mlx4/en_rx.c                    |    8 +-
 drivers/net/natsemi.c                       |   37 ++-----
 drivers/net/octeon/octeon_mgmt.c            |    9 +-
 drivers/net/pcnet32.c                       |   53 ++-------
 drivers/net/qlge/qlge_main.c                |   11 --
 drivers/net/r8169.c                         |    4 +-
 drivers/net/rrunner.c                       |   66 +++--------
 drivers/net/s2io.c                          |    6 +-
 drivers/net/sgiseeq.c                       |   42 +++-----
 drivers/net/sis190.c                        |   40 +------
 drivers/net/skge.c                          |    6 +-
 drivers/net/sky2.c                          |    4 +-
 drivers/net/starfire.c                      |   28 ++---
 drivers/net/sunbmac.c                       |   78 +++----------
 drivers/net/sunbmac.h                       |   18 +---
 drivers/net/sundance.c                      |   26 +---
 drivers/net/sungem.c                        |   84 +++----------
 drivers/net/sungem.h                        |    4 +-
 drivers/net/sunhme.c                        |   61 ++--------
 drivers/net/sunhme.h                        |   14 +--
 drivers/net/tg3.c                           |    3 +-
 drivers/net/tokenring/3c359.c               |   74 ++++++------
 drivers/net/tokenring/3c359.h               |    4 +-
 drivers/net/tokenring/olympic.c             |    8 +-
 drivers/net/tulip/de2104x.c                 |   39 ++-----
 drivers/net/tulip/interrupt.c               |   77 +++----------
 drivers/net/tulip/winbond-840.c             |   28 +----
 drivers/net/typhoon.c                       |   26 +---
 drivers/net/via-rhine.c                     |   38 +-----
 drivers/net/via-velocity.c                  |   61 ++--------
 drivers/net/vxge/vxge-main.c                |    6 +-
 drivers/net/wireless/adm8211.c              |   41 +------
 drivers/net/wireless/ath/ath9k/ar9003_mac.c |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.h |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c       |   10 +-
 drivers/net/wireless/b43/dma.c              |   15 ++-
 drivers/net/wireless/b43legacy/dma.c        |   19 ---
 drivers/net/wireless/p54/p54pci.c           |    2 -
 drivers/net/wireless/p54/txrx.c             |   22 ++--
 drivers/net/yellowfin.c                     |   27 +----
 include/linux/skbuff.h                      |  169 +++++++++++++++++++=
++++++++
 61 files changed, 586 insertions(+), 1208 deletions(-)

--=20
1.7.5.4

