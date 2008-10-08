From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 07 Oct 2008 20:17:05 -0700 (PDT)
Message-ID: <20081007.201705.149744421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43724
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754009AbYJHDRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 23:17:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I realize that you want to get a final 2.6.27 out potentially on
Wednesday.  However, the promiscuous count corruption and the
device unregister deadlock have easy triggers and well tested fixes.

The rest are one and two liners and fix issues users have reported
(and in some cases even analyzed :-).

If this is too much, I can rebuild a tree with a smaller set of these
fixes.  Just let me know.  In such a case I'd probably choose changes
#2, #4, and #6 in the list below.

1) If we do receive copy offload (CONFIG_NET_DMA), TCP can send two
   ACKs for the same data packet.

   This fix is very self contained, the new logic only kicks in specifically
   in the CONFIG_NET_DMA case, and it is easily proven that we have in fact sent
   an appropriate ACK out already for the code paths with the new logic.

   Fix by Ali Saidi.

2) Benjamin Thery hit and tracked down a deadlock in device unregister.  It
   probably accounts for numerous still triggering cases of the famous:

    unregister_netdevice: waiting for %s to become free. Usage count = %d

   log messages and wedges.

   The problem is parallel invocations of netdev_run_todo, where one needs
   to run to release the reference the other is waiting for.

   Herbert Xu fixes this by extending the coverage of the RTNL mutex
   a little bit, and then once we have the element on a local list to
   destroy from, we drop the RTNL mutex and don't take any other locks.

   This fix has been verified by Benjamin.

3) The Hybla TCP congestion control algorithm can get into a state where
   the congestion window stops growing entirely.  This is a side effect
   of rounding.  Fix from Daniele Lacamera.  It's pretty safe because
   when this situation is detected the code mimicks new reno behavior.

4) Jesper Dangaard Brouer reports a corruption of the promiscous count
   on a device which is configured to a VLAN when bringing such a device
   down.

   The problem is that, in the VLAN paths, we invoke the ->change_rx_flags()
   method multiple times.  It is done even after the device is marked down,
   and this is what messes up the promiscuous count.

   The fix from Patrick McHardy is to guard ->change_rx_flags() invocation
   with IFF_UP tests.

   Fix tested and verified by Jesper.

5) Debugging some AX25 problems showed that netrom sockets get orphaned
   far too late, which allows them to be seen unorphaned in sk_free().
   This can cause serious problems.

   Fix from Jarek Poplawski.

6) Bernard (f6bvp) reports crashes in AX25, these are caused by a commit
   of mine meant to fix a problem involving the leak of unaccepted sockets
   when a listening socket is closed.

   So, revert my broken fix, and add the more focused cure proposed by
   Tihomir Heidelberg (9a4gl).

   Bernard tested and validated these changes.

7) Bluetooth bug fixes:

   a) btusb and bpa10x drivers double free buffers on error paths.
   b) reset quirks needed for some more dongles (A-Link BlueUSB21,
      Tragus, and Belkin)

Please pull, thanks a lot!

The following changes since commit 0523820482dcb42784572ffd2296c2f08c275a2b:
  Timo Teras (1):
        af_key: Free dumping state on socket close

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ali Saidi (1):
      tcp: Fix possible double-ack w/ user dma

Daniele Lacamera (1):
      tcp: Fix tcp_hybla zero congestion window growth with small rho and large cwnd.

David S. Miller (3):
      Revert "ax25: Fix std timer socket destroy handling."
      ax25: Quick fix for making sure unaccepted sockets get destroyed.
      Merge branch 'master' of git://git.kernel.org/.../holtmann/bluetooth-2.6

Herbert Xu (1):
      net: Fix netdev_run_todo dead-lock

Jarek Poplawski (1):
      netrom: Fix sock_orphan() use in nr_release

Marcel Holtmann (3):
      [Bluetooth] Fix double frees on error paths of btusb and bpa10x drivers
      [Bluetooth] Add reset quirk for new Targus and Belkin dongles
      [Bluetooth] Add reset quirk for A-Link BlueUSB21 dongle

Patrick McHardy (1):
      net: only invoke dev->change_rx_flags when device is UP

 drivers/bluetooth/bpa10x.c |    2 --
 drivers/bluetooth/btusb.c  |    8 +++++---
 net/ax25/af_ax25.c         |    3 +++
 net/ax25/ax25_std_timer.c  |    8 +++++---
 net/core/dev.c             |   43 ++++++++++++++++---------------------------
 net/core/rtnetlink.c       |    2 +-
 net/ipv4/tcp_hybla.c       |    6 +++++-
 net/ipv4/tcp_input.c       |    3 ++-
 net/netrom/af_netrom.c     |    2 +-
 9 files changed, 38 insertions(+), 39 deletions(-)
