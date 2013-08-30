From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 30 Aug 2013 18:14:57 -0400 (EDT)
Message-ID: <20130830.181457.1060912973547046726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) There was a simplification in the ipv6 ndisc packet sending
   attempted here, which avoided using memory accounting on the
   per-netns ndisc socket for sending NDISC packets.  It did fix some
   important issues, but it causes regressions so it gets reverted
   here too.  Specifically, the problem with this change is that the
   IPV6 output path really depends upon there being a valid skb->sk
   attached.

   The reason we want to do this change in some form when we figure
   out how to do it right, is that if a device goes down the ndisc_sk
   socket send queue will fill up and block NDISC packets that we want
   to send to other devices too.  That's really bad behavior.

   Hopefully Thomas can come up with a better version of this change.

2) Fix a severe TCP performance regression by reverting a change made t=
o
   dev_pick_tx() quite some time ago.  From Eric Dumazet.

3) TIPC returns wrongly signed error codes, fix from Erik Hugne.

4) Fix OOPS when doing IPSEC over ipv4 tunnels due to orphaning the skb=
->sk
   too early.  Fix from Li Hongjun.

5) RAW ipv4 sockets can use the wrong routing key during lookup, from
   Chris Clark.

6) Similar to #1 revert an older change that tried to use plain alloc_s=
kb()
   for SYN/ACK TCP packets, this broke the netfilter owner mark which n=
eeds
   to see the skb->sk for such frames.  From Phil Oester.

7) BNX2x driver bug fixes from Ariel Elior and Yuval Mintz, specificall=
y in
   the handling of virtual functions.

8) IPSEC path error propagations to sockets is not done properly when w=
e
   have v4 in v6, and v6 in v4 type rules.  Fix from Hannes Frederic So=
wa.

9) Fix missing channel context release in mac80211, from Johannes Berg.

10) Fix network namespace handing wrt. SCM_RIGHTS, from Andy Lutomirski=
=2E

11) Fix usage of bogus NAPI weight in jme, netxen, and ps3_gelic driver=
s.
    From Michal Schmidt.

12) Hopefully a complete and correct fix for the genetlink dump locking
    and module reference counting.  From Pravin B Shelar.

13) sk_busy_loop() must do a cpu_relax(), from Eliezer Tamir.

14) Fix handling of timestamp offset when restoring a snapshotted TCP s=
ocket.
    From Andrew Vagin.

Please pull, thanks a lot!

The following changes since commit 41a00f7950a6bc0aa956f6d6b423f0fbf34d=
431a:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-0=
8-23 09:54:21 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 0affdf347ffc0c3a4595661c091e8cc5f1346e92=
:

  net: fec: fix time stamping logic after napi conversion (2013-08-30 1=
8:01:19 -0400)

----------------------------------------------------------------
Andrew Vagin (2):
      tcp: initialize rcv_tstamp for restored sockets
      tcp: don't apply tsoffset if rcv_tsecr is zero

Andy Lutomirski (2):
      net: Check the correct namespace when spoofing pid over SCM_RIGHT=
S
      Rename nsproxy.pid_ns to nsproxy.pid_ns_for_children

Ariel Elior (4):
      bnx2x: vf mark stats started
      bnx2x: Fix functionality of configuring vlan list
      bnx2x: Fix VF memory leak unload
      bnx2x: Fix VF stats sync

Byungho An (1):
      net: stmmac: fixed the pbl setting with DT

Chris Clark (1):
      ipv4: sendto/hdrincl: don't use destination address found in head=
er

Dan Carpenter (1):
      mISDN: return -EINVAL on error in dsp_control_req()

Daniel Borkmann (1):
      net: bridge: convert MLDv2 Query MRC into msecs_to_jiffies for ma=
x_delay

David S. Miller (3):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'master' of git://git.kernel.org/.../klassert/ipsec
      Revert "ipv6: Don't depend on per socket memory for neighbour dis=
covery messages"

Eliezer Tamir (1):
      net: add cpu_relax to busy poll loop

Eric Dumazet (1):
      net: revert 8728c544a9c ("net: dev_pick_tx() fix")

Erik Hugne (1):
      tipc: set sk_err correctly when connection fails

=46elix Fietkau (1):
      mac80211: add a flag to indicate CCK support for HT clients

Hannes Frederic Sowa (7):
      xfrm: make local error reporting more robust
      xfrm: introduce helper for safe determination of mtu
      ipv6: wire up skb->encapsulation
      ipv6: xfrm: dereference inner ipv6 header if encapsulated
      xfrm: choose protocol family by skb protocol
      xfrm: revert ipv4 mtu determination to dst_mtu
      ipv6: set skb->protocol on tcp, raw and ip6_append_data genereate=
d skbs

Helmut Schaa (1):
      ath9k_htc: Restore skb headroom when returning skb to mac80211

Johannes Berg (1):
      mac80211: add missing channel context release

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Li Hongjun (1):
      ipv4 tunnels: fix an oops when using ipip/sit with IPsec

Libo Chen (1):
      net: xilinx: fix memleak

Linus L=FCssing (1):
      bridge: separate querier and query timer into IGMP/IPv4 and MLD/I=
Pv6 ones

Michal Schmidt (3):
      jme: lower NAPI weight
      netxen: lower NAPI weight
      ps3_gelic: lower NAPI weight

Phil Oester (1):
      tcp: tcp_make_synack() should use sock_wmalloc

Pravin B Shelar (2):
      genl: Fix genl dumpit() locking.
      genl: Hold reference on correct module while netlink-dump.

Richard Cochran (1):
      net: fec: fix time stamping logic after napi conversion

Rob Gardner (1):
      net: usb: Add HP hs2434 device to ZLP exception table

Sarveshwar Bandi (1):
      be2net: Check for POST state in suspend-resume sequence

Simon Wunderlich (1):
      mac80211: ibss: fix ignored channel parameter

Stanislaw Gruszka (1):
      iwl4965: fix rfkill set state regression

Steffen Klassert (1):
      xfrm: Fix potential null pointer dereference in xdst_queue_output

Sujith Manoharan (1):
      ath9k: Enable PLL fix only for AR9340/AR9330

Thomas Graf (1):
      ipv6: Don't depend on per socket memory for neighbour discovery m=
essages

Yuval Mintz (1):
      bnx2x: Fix move FP memory deallocations

 drivers/isdn/mISDN/dsp_core.c                         |   4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c       |   9 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |   9 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c     |  63 ++++++++--=
---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c     |  31 ++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h     |   3 +
 drivers/net/ethernet/emulex/benet/be_main.c           |   4 ++
 drivers/net/ethernet/freescale/fec_main.c             |   3 +-
 drivers/net/ethernet/jme.c                            |   2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h       |   1 -
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c  |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  20 +++---
 drivers/net/ethernet/toshiba/ps3_gelic_net.c          |   3 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.h          |   1 -
 drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c     |   1 +
 drivers/net/usb/cdc_mbim.c                            |   4 ++
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c         |  10 +++
 drivers/net/wireless/ath/ath9k/init.c                 |   3 +-
 drivers/net/wireless/ath/ath9k/main.c                 |   3 +-
 drivers/net/wireless/ath/carl9170/main.c              |   3 +-
 drivers/net/wireless/iwlegacy/4965-mac.c              |   2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c               |   3 +-
 include/linux/nsproxy.h                               |   6 +-
 include/net/busy_poll.h                               |   1 +
 include/net/genetlink.h                               |  20 +++++-
 include/net/mac80211.h                                |   1 +
 include/net/route.h                                   |   8 +++
 include/net/xfrm.h                                    |   6 ++
 kernel/fork.c                                         |   5 +-
 kernel/nsproxy.c                                      |  27 ++++----
 kernel/pid_namespace.c                                |   4 +-
 net/bridge/br_device.c                                |   2 +-
 net/bridge/br_input.c                                 |   2 +-
 net/bridge/br_mdb.c                                   |  14 +++--
 net/bridge/br_multicast.c                             | 261 ++++++++++=
+++++++++++++++++++++++++++++++++++++++++++++-----------------------
 net/bridge/br_private.h                               |  57 ++++++++++=
+++----
 net/core/flow_dissector.c                             |  11 +---
 net/core/scm.c                                        |   2 +-
 net/ipv4/ip_output.c                                  |   8 ---
 net/ipv4/ipip.c                                       |   5 +-
 net/ipv4/raw.c                                        |   3 +-
 net/ipv4/tcp_input.c                                  |   9 ++-
 net/ipv4/tcp_output.c                                 |   4 +-
 net/ipv4/xfrm4_output.c                               |  16 +++--
 net/ipv4/xfrm4_state.c                                |   1 +
 net/ipv6/ip6_gre.c                                    |   5 ++
 net/ipv6/ip6_output.c                                 |   3 +
 net/ipv6/ip6_tunnel.c                                 |   6 ++
 net/ipv6/raw.c                                        |   1 +
 net/ipv6/sit.c                                        |  11 ++--
 net/ipv6/xfrm6_output.c                               |  21 +++++--
 net/ipv6/xfrm6_state.c                                |   1 +
 net/mac80211/ibss.c                                   |  34 +++++++++-=
-
 net/mac80211/rc80211_minstrel_ht.c                    |   3 +
 net/netlink/genetlink.c                               |  67 ++++++++++=
++++++----
 net/tipc/socket.c                                     |   4 +-
 net/xfrm/xfrm_output.c                                |  21 +++++++
 net/xfrm/xfrm_policy.c                                |   9 +--
 net/xfrm/xfrm_state.c                                 |   7 +--
 59 files changed, 590 insertions(+), 260 deletions(-)
