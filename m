From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 09 Mar 2009 05:29:41 -0700 (PDT)
Message-ID: <20090309.052941.227857405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751074AbZCIM34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 08:29:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix races between network object removal and sysfs accesses.
   From Stephen Hemminger.

2) netlink_set_err() accidently returns negated error codes, from
   Pablo Neira Ayuso.

3) A bogus change added unreasonable checks to the packet scheduler
   rate estimator config operations, fix from Jarek Poplawski.

4) Tokenring module missing license, from Meelis Roos.

5) tmspci driver does request_irq() before datastructures are fully
   setup, also from Meelis Roos.

6) Tigon3 5906 link handling fix from Matt Carlson.

7) Resolve bonding ipv6 regression, an identical situation wrt. SCTP,
   and all such possible problems in the future.

   If a module wants to do anything non-trivial with ipv6 such as
   access the neighbour discovery cache or similar (this is what
   the bonding ipv6 code needs to do) it has to reference symbols
   in the ipv6 module and thus gets a dependency upon it.

   Note that these aren't the kinds of routines we can export into a
   seperate library module, like we could (and in fact already do) for
   ipv6 header parsing helper functions and stuff like that.  The stuff
   we are talking about here is stateful.

   This situation creates a problem because when people want to
   disable IPV6 for whatever reason, they simply disable the ipv6
   module entirely in their /etc/modules.conf They do this for a
   number of reasons, often it's because of application issues or they
   have a site-wide policy to disable ipv6 on their networks, etc.
   They do it this way because distributions, of course, enable
   everything.  So it's not a matter of "changing a kernel option."

   Therefore, with such ipv6 dependencies, if you disable ipv6 you
   also lose bonding and whatever else has a dependency on ipv6, which
   is undesirable.  Like bonding, SCTP has this problem too.

   So add a 'disable' module option to ipv6 which simply causes it to
   disallow ipv6 socket creation and also makes it not add default
   ipv6 addresses to any interfaces.

   As a result it can be loaded and thus dependencies can be ipv6
   satisfied.

   We discussed alternatives like making a "bonding_ipv6.ko" module
   but there is no way to automatically load it.  It would need to be
   loaded by hand, which is really an awful user experience.

   These changes were from Brian Haley.

8) Network namespace crash fixes from Eric W. Biederman.

9) vlan-in-vlan were broken by some of the netdev_ops changes,
   with help from Patrick McHardy.

10) Some new device support in smc911x, dm9601, and rt2x00 drivers.

11) SCTP bug fixes from Vlad Yasevich and co.

12) Several wireless fixes via John Linville and the wireless folks.

Please pull, thanks a lot!

The following changes since commit 7a203f3b089be4410fe065dd9927027eade94557:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../drzeus/mmc

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Brian Haley (2):
      IPv6: add "disable" module parameter support to ipv6.ko
      SCTP: change sctp_ctl_sock_init() to try IPv4 if IPv6 fails

Christian Lamparter (1):
      p54: fix race condition in memory management

Daniel Lezcano (1):
      netns: fix addrconf_ifdown kernel panic

David S. Miller (3):
      net: Fix missing dev->neigh_setup in register_netdevice().
      vlan: Fix vlan-in-vlan crashes.
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

Eric W. Biederman (3):
      netns: Fix icmp shutdown.
      tcp: Like icmp use register_pernet_subsys
      netns: Remove net_alive

Jarek Poplawski (1):
      pkt_sched: act_police: Fix a rate estimator test.

Matt Carlson (1):
      tg3: Fix 5906 link problems

Meelis Roos (2):
      net: fix tokenring license
      tmspci: fix request_irq race

Pablo Neira Ayuso (1):
      netlink: invert error code in netlink_set_err()

Patrick McHardy (1):
      bonding: Fix device passed into ->ndo_neigh_setup().

Peter Korsgaard (1):
      dm9601: new vendor/product IDs

Reinette Chatre (1):
      iwlwifi: fix error flow in iwl*_pci_probe

Roel Kluin (5):
      net: more timeouts that reach -1
      net pcmcia: worklimit reaches -1
      aoe: error printed 1 too early
      sungem: another error printed one too early
      cfg80211: test before subtraction on unsigned

Russell King (1):
      OMAP: enable smc911x support for LDP platform

Stephen Hemminger (2):
      net: Avoid race between network down and sysfs
      ipv6: Fix sysctl unregistration deadlock

Vlad Yasevich (1):
      sctp: fix crash during module unload

Wei Yongjun (1):
      sctp: fix kernel panic with ERROR chunk containing too many error causes

Xose Vazquez Perez (2):
      rt2x00 : more devices to rt2500usb.c
      rt2x00 : more devices to rt73usb.c

 Documentation/networking/ipv6.txt           |   35 +++++++++++++++
 arch/arm/mach-omap2/board-ldp.c             |    2 +-
 drivers/block/aoe/aoedev.c                  |    2 +-
 drivers/net/arm/ks8695net.c                 |    2 +-
 drivers/net/bonding/bond_main.c             |    2 +-
 drivers/net/jme.c                           |    3 +-
 drivers/net/pcmcia/3c574_cs.c               |    3 +-
 drivers/net/pcmcia/3c589_cs.c               |    3 +-
 drivers/net/smc911x.h                       |   12 +++++
 drivers/net/sungem.c                        |    2 +-
 drivers/net/tg3.c                           |    3 +-
 drivers/net/tokenring/tmspci.c              |   18 ++++----
 drivers/net/ucc_geth_mii.c                  |    4 +-
 drivers/net/usb/dm9601.c                    |    4 ++
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    6 ++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   17 +++----
 drivers/net/wireless/p54/p54common.c        |    9 +++-
 drivers/net/wireless/rt2x00/rt2500usb.c     |    8 ++++
 drivers/net/wireless/rt2x00/rt73usb.c       |   32 ++++++++++++++-
 include/linux/netdevice.h                   |    1 +
 include/net/net_namespace.h                 |   27 +++++++----
 net/802/tr.c                                |    2 +
 net/8021q/vlan_dev.c                        |    3 +-
 net/core/dev.c                              |   61 +++++++++++++++------------
 net/core/net-sysfs.c                        |    4 +-
 net/core/net_namespace.c                    |    3 -
 net/ipv4/icmp.c                             |    2 +-
 net/ipv4/tcp_ipv4.c                         |    2 +-
 net/ipv6/addrconf.c                         |   53 +++++++----------------
 net/ipv6/af_inet6.c                         |   21 +++++++--
 net/netlink/af_netlink.c                    |   10 ++++-
 net/sched/act_police.c                      |   13 +++---
 net/sctp/protocol.c                         |   16 ++++---
 net/sctp/sm_sideeffect.c                    |   60 ++++++++++++++++----------
 net/sctp/sm_statefuns.c                     |   16 +------
 net/wireless/reg.c                          |    3 +-
 36 files changed, 289 insertions(+), 175 deletions(-)
 create mode 100644 Documentation/networking/ipv6.txt
