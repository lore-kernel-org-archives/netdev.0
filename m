From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 12 Aug 2012 23:06:12 -0700 (PDT)
Message-ID: <20120812.230612.1493537286501121056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Most importantly this should cure the ipv4-mapped ipv6 socket TCP
crashes some people were seeing, otherwise:

1) Fix e1000e autonegotiation handling regression, from Tushar
   Dave.

2) Fix TX data corruption race on e1000e down, also from Tushar
   Dave.

3) Fix bfin_sir IRDA driver build, from Sonic Zhang.

4) AF_PACKET mmap() tests a flag in the TX ring shared between
   userspace and the kernel for an internal consistency check.  It
   really shouldn't do this to validate the kernel's own behavior
   because the user can corrupt it to be any value at all.  From
   Daniel Borkmann.

5) Fix TCP metrics leak on netns dismantle, from Eric Dumazet.

6) Orphan the anonymous TCP socket from the SKB in
   ip_send_unicast_reply() so that the rest of the stack
   needn't see it.  Otherwise we get selinux problems of
   all sorts, from Eric Dumazet.

   This is the best way to fix this since the socket is just a
   place holder for sending packets in a context where we have
   no real socket at all.

7) Fix TUN detach crashes, from Stanislav Kinsbursky.

8) dev_set_alias() leaks memory on krealloc() failure, from Alexey
   Khoroshilov.

9) FIB trie must use call_rcu() not call_rcu_bh(), because this code
   is not universally invoked from software interrupts.  From Eric
   Dumazet.

10) PPTP looks up ipv4 routes with the wrong network namespace, fix from
    Gao Feng.

Please pull, thanks a lot!

The following changes since commit f4ba394c1b02e7fc2179fda8d3941a5b3b65efb6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-08-08 20:06:43 +0300)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to f57b07c0c7ca9e4dde36acfabdf474ee3c478e6d:

  bnx2x: Fix compiler warnings (2012-08-12 13:42:18 -0700)

----------------------------------------------------------------
Alexander Duyck (1):
      igb: Fix register defines for all non-82575 hardware

Alexey Khoroshilov (1):
      net/core: Fix potential memory leak in dev_set_alias()

Arnd Bergmann (1):
      net/stmmac: mark probe function as __devinit

Daniel Drake (1):
      cfg80211: process pending events when unregistering net device

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../ppwaskie/net
      Merge branch 'fixes-for-3.6' of git://gitorious.org/linux-can/linux-can
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wireless

Denis Efremov (1):
      macvtap: rcu_dereference outside read-lock section

Emil Tantilov (3):
      igb: fix panic while dumping packets on Tx hang with IOMMU
      e1000e: fix panic while dumping packets on Tx hang with IOMMU
      ixgbe: add missing braces

Eric Dumazet (7):
      net: fib: fix incorrect call_rcu_bh()
      net: force dst_default_metrics to const section
      tcp: must free metrics at net dismantle
      ipv4: tcp: unicast_sock should not land outside of TCP stack
      net: tcp: ipv6_mapped needs sk_rx_dst_set method
      ipv4: fix ip_send_skb()
      codel: refine one condition to avoid a nul rec_inv_sqrt

Gao feng (1):
      pptp: lookup route with the proper net namespace

Jesper Juhl (2):
      batman-adv: Fix mem leak in the batadv_tt_local_event() function
      cdc-phonet: Don't leak in usbpn_open

Johannes Berg (1):
      iwlwifi: disable greenfield transmissions as a workaround

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

Joren Van Onder (1):
      bnx2x: Fix compiler warnings

Oliver Hartkopp (1):
      canfd: remove redundant CAN FD flag

Paolo Valente (1):
      sched: add missing group change to qfq_change_class

Sonic Zhang (1):
      drivers: net: irda: bfin_sir: fix compile error

Stanislav Kinsbursky (1):
      tun: don't zeroize sock->file on detach

Stanislaw Gruszka (1):
      rt61pci: fix NULL pointer dereference in config_lna_gain

Stefan Assmann (1):
      igb: add delay to allow igb loopback test to succeed on 8086:10c9

Tushar Dave (2):
      e1000e: NIC goes up and immediately goes down
      e1000e: 82571 Tx Data Corruption during Tx hang recovery

Ying Xue (1):
      af_packet: Quiet sparse noise about using plain integer as NULL pointer

Yuval Mintz (2):
      bnx2x: fix unload previous driver flow when flr-capable
      bnx2x: Fix recovery flow cleanup during probe

danborkmann@iogearbox.net (1):
      af_packet: remove BUG statement in tpacket_destruct_skb

stigge@antcom.de (1):
      lpc_eth: remove obsolete ifdefs

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h           |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      | 72 ++++++++++++++++------------------------
 drivers/net/ethernet/intel/e1000e/82571.c             | 10 +++---
 drivers/net/ethernet/intel/e1000e/netdev.c            | 36 ++++++++++++++------
 drivers/net/ethernet/intel/igb/e1000_regs.h           |  8 +++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c          |  3 ++
 drivers/net/ethernet/intel/igb/igb_main.c             | 19 +++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c        |  3 +-
 drivers/net/ethernet/nxp/lpc_eth.c                    | 13 --------
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  2 +-
 drivers/net/irda/bfin_sir.c                           |  8 ++---
 drivers/net/macvtap.c                                 |  3 +-
 drivers/net/ppp/pptp.c                                |  4 +--
 drivers/net/tun.c                                     |  1 -
 drivers/net/usb/cdc-phonet.c                          |  1 +
 drivers/net/wireless/iwlwifi/dvm/rs.c                 | 13 +++++---
 drivers/net/wireless/rt2x00/rt61pci.c                 |  3 +-
 include/linux/can.h                                   | 25 +++++++-------
 include/net/codel.h                                   |  8 +++--
 include/net/dst.h                                     |  2 +-
 include/net/ip.h                                      |  2 +-
 include/net/tcp.h                                     |  1 +
 net/batman-adv/translation-table.c                    |  1 +
 net/core/dev.c                                        |  7 ++--
 net/core/dst.c                                        | 10 +++++-
 net/ipv4/fib_trie.c                                   |  2 +-
 net/ipv4/ip_output.c                                  |  6 ++--
 net/ipv4/tcp_ipv4.c                                   |  3 +-
 net/ipv4/tcp_metrics.c                                | 12 +++++++
 net/ipv4/udp.c                                        |  2 +-
 net/ipv6/tcp_ipv6.c                                   |  1 +
 net/packet/af_packet.c                                |  3 +-
 net/sched/sch_qfq.c                                   | 95 ++++++++++++++++++++++++++++++++++++++---------------
 net/wireless/core.c                                   |  5 +++
 net/wireless/core.h                                   |  1 +
 net/wireless/util.c                                   |  2 +-
 36 files changed, 233 insertions(+), 156 deletions(-)
