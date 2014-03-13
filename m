From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 13 Mar 2014 16:36:14 -0400 (EDT)
Message-ID: <20140313.163614.882905795779882494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I know this is a bit more than you want to see, and I've told the
wireless folks under no uncertain terms that they must severely
scale back the extent of the fixes they are submitting this late
in the game.

Anyways:

1) vmxnet3's netpoll doesn't perform the equivalent of an ISR, which is
   the correct implementation, like it should.  Instead it does somethi=
ng
   like a NAPI poll operation.  This  leads to crashes.

   From Neil Horman and Arnd Bergmann.

2) Segmentation of SKBs requires proper socket orphaning of the
   fragments, otherwise we might access stale state released by the
   release callbacks.

   This is a 5 patch fix, but the initial patches are giving variables
   and such significantly clearer names such that the actual fix itself
   at the end looks trivial.

   From Michael S. Tsirkin.

3) TCP control block release can deadlock if invoked from a timer on
   an already "owned" socket.  Fix from Eric Dumazet.

4) In the bridge multicast code, we must validate that the destination
   address of general queries is the link local all-nodes multicast
   address.  From Linus L=FCssing.

5) The x86 BPF JIT support for negative offsets puts the parameter for
   the helper function call in the wrong register.  Fix from Alexei
   Starovoitov.

6) The descriptor type used for RTL_GIGA_MAC_VER_17 chips in the r8169
   driver is incorrect.  Fix from Hayes Wang.

7) The xen-netback driver tests skb_shinfo(skb)->gso_type bits to see
   if a packet is a GSO frame, but that's not the correct test.  It
   should use skb_is_gso(skb) instead.  Fix from Wei Liu.

8) Negative msg->msg_namelen values should generate an error, from
   Matthew Leach.

9) at86rf230 can deadlock because it takes the same lock from it's ISR
   and it's hard_start_xmit method, without disabling interrupts in
   the latter.  Fix from Alexander Aring.

10) The FEC driver's restart doesn't perform operations in the correct
    order, so promiscuous settings can get lost.  Fix from Stefan
    Wahren.

11) Fix SKB leak in SCTP cookie handling, from Daniel Borkmann.

12) Reference count and memory leak fixes in TIPC from Ying Xue
    and Erik Hugne.

13) Forced eviction in inet_frag_evictor() must strictly make sure
    all frags are deleted, otherwise module unload (f.e. 6lowpan)
    can crash.  Fix from Florian Westphal.

14) Remove assumptions in AF_UNIX's use of csum_partial() (which it use=
s
    as a hash function), which breaks on PowerPC.  From Anton Blanchard=
=2E

    The main gist of the issue is that csum_partial() is defined only
    as a value that, once folded (f.e. via csum_fold()) produces a
    correct 16-bit checksum.  It is legitimate, therefore, for
    csum_partial() to produce two different 32-bit values over the
    same data if their respective alignments are different.

15) Fix endiannes bug in MAC address handling of ibmveth driver, also
    from Anton Blanchard.

16) Error checks for ipv6 exthdrs offload registration are reversed, fr=
om
    Anton Nayshtut.

17) Externally triggered ipv6 addrconf routes should count against the
    garbage collection threshold.  Fix from Sabrina Dubroca.

18) The PCI shutdown handler added to the bnx2 driver can wedge the
    chip if it was not brought up earlier already, which in particular
    causes the firmware to shut down the PHY.  Fix from Michael Chan.

19) Adjust the sanity WARN_ON_ONCE() in qdisc_list_add() because as
    currently coded it can and does trigger in legitimate situations.
    From Eric Dumazet.

20) BNA driver fails to build on ARM because of a too large udelay() ca=
ll,
    fix from Ben Hutchings.

21) Fair-Queue qdisc holds locks during GFP_KERNEL allocations, fix fro=
m
    Eric Dumazet.

22) The vlan passthrough ops added in the previous release causes a
    regression in source MAC address setting of outgoing headers in
    some circumstances.  Fix from Peter Bostr=F6m.

Please pull, thanks a lot!

The following changes since commit c3bebc71c4bcdafa24b506adf0c1de3c1f77=
e2e0:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-0=
3-04 08:44:32 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to ecab67015ef6e3f3635551dcc9971cf363cc1cd5=
:

  ipv6: Avoid unnecessary temporary addresses being generated (2014-03-=
13 15:49:14 -0400)

----------------------------------------------------------------
Alexander Aring (1):
      at86rf230: fix lockdep splats

Alexei Starovoitov (1):
      x86: bpf_jit: support negative offsets

Amir Vadai (2):
      net/mlx4_core: Fix memory access error in mlx4_QUERY_DEV_CAP_wrap=
per()
      net/mlx4_core: mlx4_init_slave() shouldn't access comm channel be=
fore PF is ready

Amitkumar Karwar (2):
      mwifiex: copy AP's HT capability info correctly
      mwifiex: save and copy AP's VHT capability info correctly

Andrew Lutomirski (1):
      net: Improve SO_TIMESTAMPING documentation and fix a minor code b=
ug

Annie Li (1):
      Xen-netback: Fix issue caused by using gso_type wrongly

Anton Blanchard (2):
      net: unix socket code abuses csum_partial
      ibmveth: Fix endian issues with MAC addresses

Anton Nayshtut (1):
      ipv6: Fix exthdrs offload registration.

Arnd Bergmann (1):
      vmxnet3: fix building without CONFIG_PCI_MSI

Ben Hutchings (1):
      bna: Replace large udelay() with mdelay()

Bjorn Helgaas (1):
      phy: fix compiler array bounds warning on settings[]

Daniel Borkmann (2):
      net: sctp: fix skb leakage in COOKIE ECHO path of chunk->auth_chu=
nk
      MAINTAINERS: add networking selftests to NETWORKING

David S. Miller (5):
      Merge branch 'tipc'
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge branch 'stmmac'
      Merge branch 'skb_frags'
      Merge branch 'mlx4'

Eliad Peller (1):
      mac80211: consider virtual mon when calculating min_def

Emmanuel Grumbach (1):
      iwlwifi: mvm: don't WARN when statistics are handled late

Eric Dumazet (3):
      pkt_sched: move the sanity test in qdisc_list_add()
      pkt_sched: fq: do not hold qdisc lock while allocating memory
      tcp: tcp_release_cb() should release socket ownership

Erik Hugne (3):
      tipc: drop subscriber connection id invalidation
      tipc: fix memory leak during module removal
      tipc: don't log disabled tasklet handler errors

=46lorian Westphal (1):
      inet: frag: make sure forced eviction removes all frags

Gavin Shan (1):
      net/mlx4: Support shutdown() interface

Geert Uytterhoeven (1):
      packet: doc: Spelling s/than/that/

Giuseppe CAVALLARO (4):
      stmmac: disable at run-time the EEE if not supported
      stmmac: fix and better tune the default buffer sizes
      stmmac: fix chained mode
      stmmac: dwmac-sti: fix broken STiD127 compatibility

Guillaume Nault (2):
      l2tp: fix manual sequencing (de)activation in L2TPv2
      l2tp: fix userspace reception on plain L2TP sockets

Haiyang Zhang (1):
      hyperv: Move state setting for link query

Heiner Kallweit (1):
      ipv6: Avoid unnecessary temporary addresses being generated

Ivaylo Dimitrov (1):
      wl1251: use skb_trim to make skb shorter

Johannes Berg (2):
      cfg80211: remove racy beacon_interval assignment
      mac80211: clear sequence/fragment number in QoS-null frames

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Linus L=FCssing (3):
      bridge: multicast: add sanity check for query source addresses
      bridge: multicast: add sanity check for general query destination
      bridge: multicast: enable snooping on general queries only

Markos Chandras (1):
      tools/net/Makefile: Define PACKAGE to fix build problems

Matthew Leach (1):
      net: socket: error on a negative msg_namelen

Michael Chan (1):
      bnx2: Fix shutdown sequence

Michael S. Tsirkin (5):
      skbuff: skb_segment: s/frag/nskb_frag/
      skbuff: skb_segment: s/skb_frag/frag/
      skbuff: skb_segment: s/skb/head_skb/
      skbuff: skb_segment: s/fskb/list_skb/
      skbuff: skb_segment: orphan frags before copying

Neil Horman (1):
      vmxnet3: fix netpoll race condition

Nikolay Aleksandrov (1):
      net: fix for a race condition in the inet frag code

Or Gerlitz (4):
      net/mlx4_core: Fix wrong dump of the vxlan offloads device capabi=
lity
      net/mlx4_en: Handle vxlan steering rules for mac address changes
      net/mlx4_core: Load the IB driver when the device supports IBoE
      net/mlx4_en: Deregister multicast vxlan steering rules when going=
 down

Oren Givon (1):
      iwlwifi: fix and add 7265 series HW IDs

Peter Bostr=F6m (1):
      vlan: Set correct source MAC address with TX VLAN offload enabled

Sabrina Dubroca (1):
      ipv6: don't set DST_NOCOUNT for remotely added routes

Sasha Levin (1):
      bonding: correctly handle out of range parameters for lp_interval

Soren Brinkmann (2):
      net: macb: Check DMA mappings for error
      net: macb: DMA-unmap full rx-buffer

Stefan Wahren (1):
      eth: fec: Fix lost promiscuous mode after reconnecting cable

Tobias Klauser (1):
      MAINTAINERS: Add tools/net to NETWORKING [GENERAL]

Wei Liu (1):
      xen-netback: use skb_is_gso in xenvif_start_xmit

Ying Xue (3):
      tipc: allow connection shutdown callback to be invoked in advance
      tipc: fix connection refcount leak
      tipc: avoid to unnecessary process switch under non-block mode

dingtianhong (1):
      bonding: set correct vlan id for alb xmit path

hayeswang (2):
      r8152: disable the ECM mode
      r8169: fix the incorrect tx descriptor version

 Documentation/networking/packet_mmap.txt              |   2 +-
 Documentation/networking/timestamping.txt             |  52 ++++++++++=
------
 MAINTAINERS                                           |   2 +
 arch/x86/net/bpf_jit.S                                |   2 +-
 drivers/net/bonding/bond_alb.c                        |   2 +-
 drivers/net/bonding/bond_options.c                    |   1 +
 drivers/net/ethernet/broadcom/bnx2.c                  |  37 +++++++++-=
-
 drivers/net/ethernet/broadcom/bnx2.h                  |   5 ++
 drivers/net/ethernet/brocade/bna/bfa_ioc.c            |   2 +-
 drivers/net/ethernet/cadence/macb.c                   |  16 ++++-
 drivers/net/ethernet/freescale/fec_main.c             |  14 ++---
 drivers/net/ethernet/ibm/ibmveth.c                    |  25 +++++---
 drivers/net/ethernet/ibm/ibmveth.h                    |   1 -
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  10 +++
 drivers/net/ethernet/mellanox/mlx4/fw.c               |  11 ++--
 drivers/net/ethernet/mellanox/mlx4/main.c             |  14 ++++-
 drivers/net/ethernet/realtek/r8169.c                  |   2 +-
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c      |   2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h          |  20 ++----
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c       |   9 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |  91 ++++++++++=
++++-------------
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |   2 +-
 drivers/net/hyperv/netvsc_drv.c                       |   4 ++
 drivers/net/hyperv/rndis_filter.c                     |  21 ++++++-
 drivers/net/ieee802154/at86rf230.c                    |  11 ++--
 drivers/net/phy/phy.c                                 |  11 ++--
 drivers/net/usb/Makefile                              |   2 +-
 drivers/net/usb/cdc_ether.c                           |   7 +++
 drivers/net/usb/r8152.c                               |  15 +++--
 drivers/net/usb/r815x.c                               | 248 ----------=
---------------------------------------------------------------
 drivers/net/vmxnet3/vmxnet3_drv.c                     |  19 ++++--
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c            |   7 ++-
 drivers/net/wireless/iwlwifi/pcie/drv.c               |   5 +-
 drivers/net/wireless/mwifiex/11ac.c                   |   3 +-
 drivers/net/wireless/mwifiex/11n.c                    |   3 +-
 drivers/net/wireless/mwifiex/scan.c                   |   8 +--
 drivers/net/wireless/ti/wl1251/rx.c                   |   2 +-
 drivers/net/xen-netback/interface.c                   |   3 +-
 drivers/net/xen-netback/netback.c                     |  39 ++++++----=
--
 include/net/sock.h                                    |   6 +-
 net/8021q/vlan_dev.c                                  |   3 +
 net/bridge/br_multicast.c                             |  33 +++++++++-
 net/core/skbuff.c                                     | 100 ++++++++++=
++++++--------------
 net/core/sock.c                                       |   5 +-
 net/ipv4/inet_fragment.c                              |   5 +-
 net/ipv4/tcp_output.c                                 |  11 ++++
 net/ipv6/addrconf.c                                   |   5 +-
 net/ipv6/exthdrs_offload.c                            |   4 +-
 net/ipv6/route.c                                      |   2 +-
 net/l2tp/l2tp_core.c                                  |   4 +-
 net/l2tp/l2tp_core.h                                  |   1 +
 net/l2tp/l2tp_netlink.c                               |   4 +-
 net/l2tp/l2tp_ppp.c                                   |  13 ++--
 net/mac80211/chan.c                                   |   6 ++
 net/mac80211/mesh_ps.c                                |   1 +
 net/mac80211/sta_info.c                               |   1 +
 net/sched/sch_api.c                                   |   7 ++-
 net/sched/sch_fq.c                                    |  21 +++++--
 net/sctp/sm_make_chunk.c                              |   4 +-
 net/sctp/sm_statefuns.c                               |   5 --
 net/socket.c                                          |   4 ++
 net/tipc/config.c                                     |   9 +--
 net/tipc/handler.c                                    |   1 -
 net/tipc/name_table.c                                 |  37 ++++++++++=
-
 net/tipc/server.c                                     |  14 ++---
 net/tipc/socket.c                                     |   4 +-
 net/tipc/subscr.c                                     |  19 +-----
 net/unix/af_unix.c                                    |   3 +-
 net/wireless/core.c                                   |   2 -
 tools/net/Makefile                                    |   2 +-
 70 files changed, 516 insertions(+), 550 deletions(-)
 delete mode 100644 drivers/net/usb/r815x.c
