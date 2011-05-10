From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 10 May 2011 15:46:32 -0700 (PDT)
Message-ID: <20110510.154632.104076893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There's several OOPS'ers and reverts in here.

I think we now have all of the worst ones fixed from the regression
list, and I would recommend doing just one more -rc to get this all
sorted out and tested properly.  But of course that is completely up
to you.

1) ipheth regressed because it had a hard dependency upon NET_IP_ALIGN
   being defined always as 2, get rid of that assumption.  From Ben
   Hutchings.

2) IPV6 REJECT module puts random values in TOS field, fix from
   Fernando Luis Vazquez Cao.

3) When an ipv4 fragmentation entry expires via a timer, we have to
   revalidate the route otherwise we can crash.  Fix from Eric
   Dumazet.

4) In usbnet, usbnet_bh can be scheduled too early during resume
   resulting in flood of RX frames but no reclaim, and this leads to
   running out of atomic memory.  Don't allow usbnet_bh to schedule
   until the device is brought completely up.  Fix from Ming Lei.

5) TCP cubic can divide by zero in some extreme cases, fix from
   Stephen Hemminger.

6) SLIP and SLCAN devices return incorrect values from their ldisc
   open method, from Matvejchikov Ilya and Oliver Hartkopp.

7) VLAN GVRP state is undone at the wrong moment, causing crashes during
   batched device delete.  From Eric Dumazet.

8) dev_close() mistakenly had it's IFF_UP check removed, this has to be
   put back otherwise we can crash during batched device teardown, in
   particular with bonding.  Fix from Eric DUmazet.

9) PCH_GBE "checksum correct" logic on RX is reversed (hardware sets
   the status bit on checksum failure, clears it on success), from
   Toshiharu Okada.

10) vmxnet3 does not take ->cmd_lock consistently with interrupts disabled,
    as is warned by lockdep.  Fix from Roland Dreier.

11) DCCP feature options length needs to be validated properly,
    otherwise we can end up working with negative lengths, fix from
    Dan Rosenberg.

13) Fix regressions in ebtables compat support, from Eric Dumazet and
    Florian Westphal.

14) IPVS namespace support can leave objects referenced indefinitely until
    reboot.  Fixes from Hans Schillstrom.

15) DSCP netfilter code forgets to invert mask, from Fernando Luis
    Vazquez Cao.

16) Revert a buggy xt_conntrack change that broke handling of locally
    generated packets.  From Florian Westphal and Jan Engelhardt.

17) Inter-family packet output was busted in IPSEC, we need to split
    the operation into two parts, ->output() and ->output_finish(), to
    make sure we work in the context of the correct protocol (ipv4 vs
    ipv6) at each step.  Fix from Steffen Klassert.

18) We cannot allow ESN handling when anti-reply detection is disabled,
    also from Steffen Klassert.

Please pull, thanks a lot!

The following changes since commit 54b333529df25b21da462c7dcc16c7dc779d9f26:

  Merge branch 'upstream' of git://git.linux-mips.org/pub/scm/upstream-linus (2011-05-10 12:00:53 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ben Hutchings (1):
      ipheth: Properly distinguish length and alignment in URBs and skbs

Dan Rosenberg (1):
      dccp: handle invalid feature options length

Dan Williams (1):
      net/usb: mark LG VL600 LTE modem ethernet interface as WWAN

David S. Miller (1):
      Merge branch 'pablo/nf-2.6-updates' of git://1984.lsi.us.es/net-2.6

Eric Dumazet (4):
      net: ip_expire() must revalidate route
      netfilter: fix ebtables compat support
      vlan: fix GVRP at dismantle time
      net: dev_close() should check IFF_UP

Fernando Luis Vazquez Cao (2):
      netfilter: IPv6: initialize TOS field in REJECT target module
      netfilter: IPv6: fix DSCP mangle code

Florian Westphal (1):
      netfilter: ebtables: only call xt_compat_add_offset once per rule

Hans Schillstrom (2):
      IPVS: Change of socket usage to enable name space exit.
      IPVS: init and cleanup restructuring

Kleber Sacilotto de Souza (1):
      ehea: fix wrongly reported speed and port

Kurt Van Dijck (1):
      can: fix SJA1000 dlc for RTR packets

Matvejchikov Ilya (1):
      NET: slip, fix ldisc->open retval

Ming Lei (1):
      usbnet: runtime pm: fix out of memory

Oliver Hartkopp (1):
      slcan: fix ldisc->open retval

Pablo Neira Ayuso (2):
      netfilter: ctnetlink: fix timestamp support for new conntracks
      netfilter: revert a2361c8735e07322023aedc36e4938b35af31eb0

Roland Dreier (1):
      vmxnet3: Consistently disable irqs when taking adapter->cmd_lock

Somnath Kotur (1):
      be2net: Fixed bugs related to PVID.

Steffen Klassert (2):
      xfrm: Assign the inner mode output function to the dst entry
      xfrm: Don't allow esn with disabled anti replay detection

Tomoya (1):
      pch_gbe: support ML7223 IOH

Toshiharu Okada (2):
      PCH_GbE : Fixed the issue of collision detection
      PCH_GbE : Fixed the issue of checksum judgment

stephen hemminger (1):
      tcp_cubic: limit delayed_ack ratio to prevent divide error

 drivers/net/Kconfig                  |    8 ++-
 drivers/net/benet/be.h               |    2 +-
 drivers/net/benet/be_cmds.c          |    2 +-
 drivers/net/benet/be_main.c          |   18 ++++--
 drivers/net/can/sja1000/sja1000.c    |    2 +-
 drivers/net/can/slcan.c              |    4 +-
 drivers/net/ehea/ehea_ethtool.c      |   21 ++++--
 drivers/net/pch_gbe/pch_gbe_main.c   |   23 +++++--
 drivers/net/slip.c                   |    4 +-
 drivers/net/usb/cdc_ether.c          |    2 +-
 drivers/net/usb/ipheth.c             |   14 +++--
 drivers/net/usb/usbnet.c             |   10 ++-
 drivers/net/vmxnet3/vmxnet3_drv.c    |   10 ++-
 include/net/ip_vs.h                  |   17 +++++
 include/net/xfrm.h                   |    3 +
 net/8021q/vlan.c                     |    3 +
 net/8021q/vlan_dev.c                 |    3 -
 net/bridge/netfilter/ebtables.c      |   64 +++---------------
 net/core/dev.c                       |   10 ++-
 net/dccp/options.c                   |    2 +
 net/ipv4/ip_fragment.c               |   33 +++++-----
 net/ipv4/tcp_cubic.c                 |    9 ++-
 net/ipv4/xfrm4_output.c              |    8 ++-
 net/ipv4/xfrm4_state.c               |    1 +
 net/ipv6/netfilter/ip6t_REJECT.c     |    4 +-
 net/ipv6/xfrm6_output.c              |    6 +-
 net/ipv6/xfrm6_state.c               |    1 +
 net/netfilter/ipvs/ip_vs_app.c       |   15 +----
 net/netfilter/ipvs/ip_vs_conn.c      |   12 +---
 net/netfilter/ipvs/ip_vs_core.c      |  103 ++++++++++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_ctl.c       |  120 ++++++++++++++++++++++++++++-----
 net/netfilter/ipvs/ip_vs_est.c       |   14 +---
 net/netfilter/ipvs/ip_vs_proto.c     |   11 +---
 net/netfilter/ipvs/ip_vs_sync.c      |   65 ++++++++++--------
 net/netfilter/nf_conntrack_netlink.c |    4 +
 net/netfilter/x_tables.c             |    4 +-
 net/netfilter/xt_DSCP.c              |    2 +-
 net/netfilter/xt_conntrack.c         |    5 --
 net/xfrm/xfrm_policy.c               |   14 ++++-
 net/xfrm/xfrm_replay.c               |    3 +
 40 files changed, 423 insertions(+), 233 deletions(-)
