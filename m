From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 05 Aug 2008 19:00:20 -0700 (PDT)
Message-ID: <20080805.190020.244441681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41616
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752269AbYHFCAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 22:00:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are the pending networking bits.

There was going to be the addition of the ath9k wireless driver but
there was some fallout that is being worked on right now (linux/list.h
changes needed lkml review, ath9k driver triggered some gcc aborts,
all kinds of fun stuff :-) so hopefully it will make it in the next
pass.  I tried to wait an extra day for it to be resolved, but that
was optimistic.

Highlights:

1) Intel driver guys triggered an OOPS when setting MTU during
   a busy transmit stream, which turned out to be a qdisc locking
   error.

   Fix the bug, and in the next commit add some assertions to
   qdisc_root_lock() to make sure it is only used in contexts where
   it is safe (basically, it can only be used when RTNL is held)

2) Neighbour table procfs output can miss entries, fix from
   Chris Larson.

3) When traffic classifier actions in the packet scheduler return
   certain status values, this can end up corrupting root level
   qdisc queue lengths and cause other weirdness.  Based upon some
   collaboration between Patrick McHardy, Jarek Poplawski, and
   myself Jarek composed a patch which uses flag bits (which
   get masked out before anything outside the qdisc layer can see
   them) to indicate exactly which actions should be performed
   on qdiscs leading up to the root.

4) Lennert Buytenhek did some really nice analysis on a network
   device that cannot do TSO offloading in hardware.  He checked
   out what happens if you enable the software TSO mechanism fallback
   we have in the kernel, and it improves CPU utilization tremendously.

   It is safe to do this as long as the device in question can
   support scatter-gather.

   Herbert and I are discussing a way to do this even more efficiently
   with some help from the device (currently the code has to allocate
   extra sk_buff objects as we split up the TSO frame, and then do
   a bunch of extra page ref counting, when all we need is some headers
   and some way to say where the data portion split points are).

   If this causes any problems whatsoever, it's trivial to revert this.

5) Matt Carlson fixed the tg3 driver "sleeping with lock held" problem
   caused by the recent PCI power-management tg3 driver changes that
   came in from the -mm tree.

6) Robert Olsson fixes two bugs in our packet generator, pktgen.

7) Yang Hongyang and herbert Xu resolved some local fragmentation
   issues on the output path, particularly with ipv6.

8) Wireless driver updates and fixes from John Linville and co.

Please pull, thanks a lot!

The following changes since commit 2b12a4c524812fb3f6ee590a02e65b95c8c32229:
  Linus Torvalds (1):
        Merge branch 'release' of git://git.kernel.org/.../aegl/linux-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andrea Merello (1):
      Rtl8187 PATCH add usb ID for asus wireless link

Chris Larson (2):
      net: in the first call to neigh_seq_next, call neigh_get_first, not neigh_get_idx.
      net: fix missing pneigh entries in the neighbor seq_file code

Dan Williams (1):
      libertas: only enable rtap with mesh firmware

Daniel Drake (1):
      mac80211: automatic IBSS channel selection

David S. Miller (6):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      pkt_sched: Use qdisc_lock() on already sampled root qdisc.
      mac80211: Use queue_lock() in ieee80211_ht_agg_queue_remove().
      pkt_sched: Make sure RTNL is held in qdisc_root_lock().
      net: Kill plain NET_XMIT_BYPASS.
      Merge branch 'no-ath9k' of git://git.kernel.org/.../linville/wireless-2.6

Denis V. Lunev (1):
      iwlwifi: RS small compile warnings without CONFIG_IWLWIFI_DEBUG

Dmitry Baryshkov (2):
      RFKILL: allow one to specify led trigger name
      RFKILL: set the status of the leds on activation.

Emmanuel Grumbach (3):
      mac80211: pass dtim_period to low level driver
      iwlwifi: bug fix in AGG flow - cast const to ULL
      iwlwifi: decrement rx skb counter in scan abort handler

Esti Kummer (2):
      iwlwifi: corrects power_level in sysfs
      iwlwifi: set led register in disassociation

Florian Westphal (1):
      ipv6: syncookies: free reqsk on xfrm_lookup error

Gregory Greenman (1):
      iwlwifi: memory allocation optimization

Helmut Schaa (1):
      ath5k: remove obsolete declaration of struct ieee80211_hw_mode

Henrique de Moraes Holschuh (1):
      rfkill: query EV_SW states when rfkill-input (re)?connects to a input device

Herbert Xu (1):
      sctp: Drop ipfargok in sctp_xmit function

Ivo van Doorn (7):
      rt2x00: Fix access permissions on debugfs files
      rt2x00: Fix partial antenna configuration
      rt2x00: rt61pci needs another millisecond after firmware upload
      rt2x00: Fix VGC lower bound initialization
      rt2x00: Sequence counter should be protected in irqsave
      rt2x00: Fix compile warning
      rt2x00: Disable link tuning in rt2500usb

Jarek Poplawski (2):
      net_sched: Add qdisc __NET_XMIT_STOLEN flag
      net_sched: Add qdisc __NET_XMIT_BYPASS flag

Jiri Slaby (1):
      Ath5k: mask out unneeded interrupts

Larry Finger (2):
      rtl8187: Fix lockups due to concurrent access to config routine
      p54: Fix potential concurrent access to private data

Lennert Buytenhek (1):
      net: use software GSO for SG+CSUM capable netdevices

Matt Carlson (1):
      tg3: Fix 'scheduling while atomic' errors

Maxim Levitsky (1):
      iwl3945: Fix statistics in monitor mode

Mohamed Abbas (1):
      iwlwifi: add power save to 5000 HW

Nick Kossifidis (9):
      ath5k: Update register list
      ath5k: Restore saved initval after POST
      ath5k: Misc hw_attach fixes
      ath5k: Misc hw_reset updates
      ath5k: Do ADC test during reset
      ath5k: Reorder calibration calls during reset and update hw_set_power
      ath5k: Add RF2425 initial rfgain values
      ath5k: Update channel functions
      ath5k: Update phy calibration functions

Peter Chubb (1):
      rt2500pci: restoring missing line

Ralf Baechle (1):
      AX.25: Fix sysctl registration if !CONFIG_AX25_DAMA_SLAVE

Rami Rosen (2):
      ipv4: remove unused field in struct flowi (include/net/flow.h).
      bridge: fix compile warning in net/bridge/br_netfilter.c

Robert Olsson (2):
      pktgen: random flow
      pktgen: mac count

Stephen Hemminger (2):
      net: eliminate refcounting in backlog queue
      bridge: Eliminate unnecessary forward delay

Sven Wegener (2):
      net: Add missing extra2 parameter for ip_default_ttl sysctl
      iwlwifi: Don't use buffer allocated on the stack for led names

Takashi Iwai (2):
      ipw2200 - Fix bad ipw_write8() macro
      prism54 - Use offsetof()

Tomas Winkler (16):
      mac80211: fix fragmentation kludge
      iwlwifi: don't stop queue in the middle of fragmented packet
      mac80211: make listen_interval be limited by low level driver
      iwlwifi: move iwl4965_mac_ampdu_action to iwl4965-base.c
      iwlwifi: move beacon handling to iwl4965-base.c
      iwlwifi: move iwl4965_set_pwr_src to iwl4965-base.c
      iwlwifi: rename iwl-4695-rs to iwl-agn-rs
      iwlwifi: kill iwl4965_fill_rs_info
      iwlwifi: use dtim_period from association, and set listen_interval
      iwlwifi: rename iwl4965-base.c to iwl-agn.c
      iwlwifi: fix checkpatch.pl errors
      iwlwifi: rename 4965 to AGN
      iwlwifi: HW bug fixes
      iwlwifi: implement iwl5000_calc_rssi
      iwlwifi: fix unhandled interrupt when HW rfkill is on
      iwlwifi: grap nic access before accessing periphery registers

Wei Yongjun (1):
      ipv6: Do not drop packet if skb->local_df is set to true

Yang Hongyang (1):
      ipv6: Fix the return value of Set Hop-by-Hop options header with NULL data pointer

Zhu Yi (1):
      iwl3945: fix merge mistake for packet injection

 drivers/net/tg3.c                                  |   20 +-
 drivers/net/wireless/Kconfig                       |    1 +
 drivers/net/wireless/ath5k/ath5k.h                 |    8 +-
 drivers/net/wireless/ath5k/base.c                  |    1 +
 drivers/net/wireless/ath5k/debug.c                 |    2 +-
 drivers/net/wireless/ath5k/debug.h                 |    1 -
 drivers/net/wireless/ath5k/hw.c                    |  239 ++++--
 drivers/net/wireless/ath5k/initvals.c              |    4 +-
 drivers/net/wireless/ath5k/phy.c                   |  185 ++++-
 drivers/net/wireless/ath5k/reg.h                   |  934 +++++++++++++++-----
 drivers/net/wireless/ipw2200.c                     |    5 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   98 ++-
 drivers/net/wireless/iwlwifi/Makefile              |   13 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.c        |   33 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.h        |    1 +
 drivers/net/wireless/iwlwifi/iwl-3945.c            |   17 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |  156 +---
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   71 ++-
 .../iwlwifi/{iwl-4965-rs.c => iwl-agn-rs.c}        |  327 +++-----
 .../iwlwifi/{iwl-4965-rs.h => iwl-agn-rs.h}        |   23 +-
 .../wireless/iwlwifi/{iwl4965-base.c => iwl-agn.c} |  232 +++--
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   44 +-
 drivers/net/wireless/iwlwifi/iwl-core.c            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    3 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   10 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   11 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   22 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |    3 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |   69 +-
 drivers/net/wireless/iwlwifi/iwl-led.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-power.c           |   45 +-
 drivers/net/wireless/iwlwifi/iwl-power.h           |   33 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   12 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c              |   59 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    1 +
 drivers/net/wireless/iwlwifi/iwl-sta.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c              |   86 ++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |   58 +-
 drivers/net/wireless/libertas/main.c               |   15 +-
 drivers/net/wireless/p54/p54.h                     |    1 +
 drivers/net/wireless/p54/p54common.c               |    6 +
 drivers/net/wireless/prism54/isl_ioctl.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |    1 +
 drivers/net/wireless/rt2x00/rt2500usb.c            |   20 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |    6 +
 drivers/net/wireless/rt2x00/rt2x00config.c         |    4 +
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   17 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    1 +
 drivers/net/wireless/rt2x00/rt2x00queue.c          |    5 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |    5 +
 drivers/net/wireless/rtl8187.h                     |    4 +
 drivers/net/wireless/rtl8187_dev.c                 |   17 +-
 include/linux/ieee80211.h                          |   13 +
 include/linux/netdevice.h                          |    4 +-
 include/net/dst.h                                  |   12 +-
 include/net/flow.h                                 |    1 -
 include/net/mac80211.h                             |   13 +-
 include/net/sch_generic.h                          |   26 +-
 include/net/sctp/structs.h                         |    3 +-
 net/ax25/sysctl_net_ax25.c                         |   14 +-
 net/bridge/br_netfilter.c                          |    2 +-
 net/bridge/br_stp.c                                |   25 +-
 net/core/dev.c                                     |   32 +-
 net/core/neighbour.c                               |   13 +-
 net/core/pktgen.c                                  |   10 +-
 net/ipv4/sysctl_net_ipv4.c                         |    1 +
 net/ipv6/ip6_output.c                              |    2 +-
 net/ipv6/ipv6_sockglue.c                           |    2 +
 net/ipv6/syncookies.c                              |   22 +-
 net/mac80211/ieee80211_i.h                         |    2 +
 net/mac80211/main.c                                |    5 +
 net/mac80211/mlme.c                                |   39 +-
 net/mac80211/tx.c                                  |   17 +-
 net/mac80211/util.c                                |    1 +
 net/mac80211/wme.c                                 |    6 +-
 net/rfkill/rfkill-input.c                          |   54 +-
 net/rfkill/rfkill.c                                |   15 +-
 net/sched/sch_atm.c                                |   14 +-
 net/sched/sch_cbq.c                                |   27 +-
 net/sched/sch_dsmark.c                             |   10 +-
 net/sched/sch_generic.c                            |   12 +-
 net/sched/sch_hfsc.c                               |   12 +-
 net/sched/sch_htb.c                                |   24 +-
 net/sched/sch_netem.c                              |    5 +-
 net/sched/sch_prio.c                               |   14 +-
 net/sched/sch_red.c                                |    2 +-
 net/sched/sch_sfq.c                                |    8 +-
 net/sched/sch_tbf.c                                |    3 +-
 net/sctp/ipv6.c                                    |    8 +-
 net/sctp/output.c                                  |    6 +-
 net/sctp/protocol.c                                |    9 +-
 95 files changed, 2159 insertions(+), 1284 deletions(-)
 rename drivers/net/wireless/iwlwifi/{iwl-4965-rs.c => iwl-agn-rs.c} (89%)
 rename drivers/net/wireless/iwlwifi/{iwl-4965-rs.h => iwl-agn-rs.h} (93%)
 rename drivers/net/wireless/iwlwifi/{iwl4965-base.c => iwl-agn.c} (96%)
