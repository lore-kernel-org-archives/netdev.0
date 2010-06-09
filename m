From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 09 Jun 2010 12:35:30 -0700 (PDT)
Message-ID: <20100609.123530.226782042.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) hostap irq handler commit revert, breaks bringup of certain
   cards.  From John W. Linville.

2) mac80211 does "if (foo->ops->x) foo->ops->y();", fix to
   "if (foo->opx->y) foo->ops->y();" :-)  From Holger Schurig

3) Fix lockdep warning wrt. sysfs_create_group and requesting firmware
   in iwlwifi.  Otherwise ABBA deadlock is possible due to the mutex
   grab ordering these two code paths need.  From Emmanuel Grumbach.

4) rtl8139_init_board() leaves 'i' past end of table index, then
   indexes into the table using 'i'.  Fix from Denis Kirjanov.

5) We erroneously can process blockack frames before association
   responses, this causes the connection to get into a state where
   no traffic can pass.  This problem tends to eminate with iwlagn
   chipsets.

   A more complicated and complete fix is possible, but here we
   make a smaller fix wherein we process aggregation action frames
   from the managed interface skb queue which provides the proper
   serialization with association responses.

   Fix from Johannes Berg.

6) ath5k needs PM_SLEEP dependencies, from Tobias Doerffel.

7) We have several backtraces (forward to us by Andrew Morton) in the
   ipv6 multicast code due to unecessary high-order allocations
   happening when the MTU is set to handle jumbo frames or similar on
   a device and we try to send out ipv6 multicast reports.

   We don't need such a huge SKB here, the code knows how to chop up a
   report into multiple frames if the number of entries to report is
   larger than we can fit in a single frame, so keep the allocation
   PAGE_SIZE or smaller to make these allocations more reliable.  Fix
   from Eric Dumazet.

8) iwl3945 devices can suffer from stuck command queues just like other
   chip revisions, so hook up the iwl_bg_monitor_recover handler for
   them too.  From Reinette Chatre.

9) iwl3945 needs a special handler for short scans, fixes bug
   http://bugzilla.intellinuxwireless.org/show_bug.cgi?id=3D2208,
   from Abhijeet Kolekar.

10) ip6mr_for_each_table() macro has a typo in one of it's variable
    names.  Fix from Eric Dumazet.

11) Many users report that the R8169 PHY doesn't come up cleanly.  It
    was tracked down to a recent commit adding full initialization of
    the PHY for 8169scd chips.  But the actual problem is more
    general in nature and not related to that commit.

    Timo Ter=E4s did some excellent debugging and found that MDIO write=
s
    were often failing in these new PHY init routines.

    Comparing the vendor driver with our's he found that the vendor
    driver makes extra delays after MDIO writes complete.

    The hardware engineers have confirmed the necessity of these
    extra delays and they fix the problems for everyone.

    Fix from Timo Ter=E4s, and there may be some small tweaks in the
    future here as the hardware designers indicate that reads
    probably need this treatment too.

12) ASIX USB network device doesn't handle VLAN packets properly due
    to a mis-coded RX packet size verification check.  Fix from Jussi
    Kivilinna.

13) IPMR table lists get corrupted because we free list members before
    unlinking.  Fix from Eric Dumazet, and this fixes the regression
    list entry that was under discussion in the past day.

14) wl1251_sdio_probe() leaks memory in error path, from Grazvydas
    Ignotas.

15) New device ID in p54usb for Dell chip, from Jason Dravet.

16) Some MAINTAINER list tweaks for Intel wireless drivers.

17) Missing RCU locking in iwlagn_tx_status(), which is required
    for calling ieee80211_find_sta().  Fix from Johannes Berg.

Please pull, thanks a lot!

The following changes since commit 3975d16760d4be7402d1067c548c30c42797=
1331:
  Linus Torvalds (1):
        Merge git://git.infradead.org/~dwmw2/mtd-2.6.35

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Abhijeet Kolekar (1):
      iwl3945: fix internal scan

Bob Copeland (1):
      ath5k: retain promiscuous setting

Bruno Randolf (1):
      ath5k: fix NULL pointer in antenna configuration

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6

Denis Kirjanov (1):
      8139too: fix buffer overrun in rtl8139_init_board

Emmanuel Grumbach (1):
      iwlwifi: move sysfs_create_group to post request firmware

Eric Dumazet (3):
      ipv6: avoid high order allocations
      ip6mr: fix a typo in ip6mr_for_each_table()
      ipmr: dont corrupt lists

Grazvydas Ignotas (1):
      wl1251: fix a memory leak in probe

Holger Schurig (1):
      mac80211: fix function pointer check

Jason Dravet (1):
      p54usb: Add device ID for Dell WLA3310 USB

Johannes Berg (3):
      mac80211: process station blockack action frames from work
      iwlwifi: add missing rcu_read_lock
      mac80211: fix deauth before assoc

John W. Linville (1):
      Revert "wireless: hostap, fix oops due to early probing interrupt=
"

Jussi Kivilinna (1):
      asix: check packet size against mtu+ETH_HLEN instead of ETH_FRAME=
_LEN

Reinette Chatre (1):
      iwl3945: enable stuck queue detection on 3945

Timo Ter=E4s (1):
      r8169: fix random mdio_write failures

Tobias Doerffel (1):
      ath5k: depend on CONFIG_PM_SLEEP for suspend/resume functions

Wey-Yi Guy (1):
      iwlwifi: add name to Maintainers list

Zhu Yi (1):
      wireless: remove my name from the maintainer list

 MAINTAINERS                                 |    5 +-
 drivers/net/8139too.c                       |    1 +
 drivers/net/r8169.c                         |    5 +
 drivers/net/usb/asix.c                      |    2 +-
 drivers/net/wireless/ath/ath5k/base.c       |   12 +-
 drivers/net/wireless/ath/ath5k/phy.c        |    7 +
 drivers/net/wireless/hostap/hostap_hw.c     |    9 -
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c  |   30 +---
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c   |    2 +
 drivers/net/wireless/iwlwifi/iwl-agn.c      |  318 +++++++++++++------=
-------
 drivers/net/wireless/iwlwifi/iwl-core.c     |   39 ++++
 drivers/net/wireless/iwlwifi/iwl-core.h     |    2 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   56 +++++-
 drivers/net/wireless/p54/p54usb.c           |    1 +
 drivers/net/wireless/wl12xx/wl1251_sdio.c   |    1 +
 net/ipv4/ipmr.c                             |    4 +-
 net/ipv6/ip6mr.c                            |    6 +-
 net/ipv6/mcast.c                            |    5 +-
 net/mac80211/driver-ops.h                   |    2 +-
 net/mac80211/mlme.c                         |   92 +++++++-
 net/mac80211/rx.c                           |    3 +
 22 files changed, 380 insertions(+), 223 deletions(-)
