From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 20 Nov 2008 04:59:50 -0800 (PST)
Message-ID: <20081120.045950.176437047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41026
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754404AbYKTM7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:59:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Lots of small fixes for bugs that have accumulated over the past few
days.  The largest part of the diffstat are the two gcc-3.4 build
fixes, wherein inline functions are moved above their call sites.

1) The TPROXY folks found two cases where the key for an ipv4 routing
   lookup is not filled in completely, and this breaks things.  Fixes
   from Balazs Scheidler.

2) ixgbe and phonet don't build with gcc-3.4 due to some inlining stupidity.
   Fixes from Alexey Dobriyan.

3) ATL2 requests device IRQ on resume even if the device has not been brought
   up yet, this causes serious problems because the IRQ is only requested
   on interface up.  Fix from Alan Jenkins.

4) /proc/net/snmp6 uses a local 32-byte char buffer for string formatting,
   but it marks this thing static so if two threads grab this file at the
   same time they can see some garbage.  Fix by simply dropping the static
   tag, from Alexey Dobriyan.

5) ip_mr_init() error path release objects wrongly, from Banjamin Thery.
   We already fixed the ipv6 side of this recently.

6) JME and IPG driver endiannes bug fixes from Harvey Harrison.

7) Some ipv6 procfs implementations use seq_open_private() but accidently
   use plain seq_release(), which leaks memory.  Fix by using
   seq_release_private(), from Benjamin Thery.

8) If we try to fire off linkwatch events before a networking device is even
   registered, we can deadlock and do other stupid things.  Just elide the
   linkwatch events in such cases.  This happens when a device driver is simply
   interested in setting the initial carrier state to off.

   Kudos to Jarek P. for doing the initial investigation of the user reports,
   and initial suggested patch.

9) Wireless bug fixes via John Linville, including a fix from
   Johannes Berg for a locking issue that users have been reporting
   for quite some time.

10) qdisc_dump_stab() doesn't check return values, and therefore can OOPS if
    the SKB being filled is full.  From Patrick McHardy.

11) asix cards don't work on 10/100Mb networks because of incorrect bits being
    set in a config register, from Pantelis Koukousoulas.

12) pktgen incorrectly chokes when the device has more queues than there are
    cpus in the system.  Fix from Robert Olsson.

13) phylib's auto-negotiation restart avoidance added recently is too aggressive,
    and breaks with certain chips.  Fix from Trent Piepho.

14) mii_bus interfaces changed and this slightly broke the sh_eth driver.  Fix from
    Nobuhiro Iwamatsu.

15) Two bug fixes for mv643xx_eth from Lennert Buytenhek.  mdiobus release ops
    are done in wrong order, and SKB recycle check uses too small length causing
    RX packet overrun scribbling past the end of the SKB.

Please pull, thanks a lot!

The following changes since commit 7f0f598a0069d1ab072375965a4b69137233169c:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alan Jenkins (1):
      atl2: don't request irq on resume if netif running

Alexey Dobriyan (3):
      ixgbe: fix compilation with gcc-3.4
      phonet: fix compilation with gcc-3.4
      net: fix tiny output corruption of /proc/net/snmp6

Balazs Scheidler (2):
      TPROXY: fill struct flowi->flags in udp_sendmsg()
      TPROXY: supply a struct flowi->flags argument in inet_sk_rebuild_header()

Benjamin Thery (2):
      net: fix ip_mr_init() error path
      ipv6: use seq_release_private for ip6mr.c /proc entries

David S. Miller (2):
      net: Do not fire linkwatch events until the device is registered.
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Harvey Harrison (2):
      net: jme.c rxdesc.flags is __le16, other missing endian swaps
      net: ipg.c fix bracing on endian swapping

Johannes Berg (3):
      libertas_tf: fix skb tail pointer
      mac80211: remove ieee80211_notify_mac
      iwlagn: fix RX skb alignment

Lennert Buytenhek (2):
      mv643xx_eth: fix the order of mdiobus_{unregister, free}() calls
      mv643xx_eth: fix recycle check bound

Nobuhiro Iwamatsu (1):
      sh: sh_eth: Update to change of mii_bus

Pantelis Koukousoulas (1):
      asix: Fix asix-based cards connecting to 10/100Mbs LAN.

Patrick McHardy (1):
      pkt_sched: fix missing check for packet overrun in qdisc_dump_stab()

Paulius Zaleckas (1):
      phylib: fix phy name example in documentation

Robert Olsson (1):
      pktgen: fix multiple queue warning

Trent Piepho (1):
      phylib: Fix auto-negotiation restart avoidance

Vernon Sauder (1):
      smc911x: Fix printf format typo in smc911x driver.

 Documentation/networking/phy.txt            |    2 +-
 drivers/net/atlx/atl2.c                     |    8 ++-
 drivers/net/ipg.c                           |    8 ++--
 drivers/net/ixgbe/ixgbe_main.c              |   58 +++++++++++++--------------
 drivers/net/jme.c                           |   21 +++++-----
 drivers/net/mv643xx_eth.c                   |    5 +-
 drivers/net/phy/phy_device.c                |   34 +++++++++++-----
 drivers/net/sh_eth.c                        |    4 +-
 drivers/net/smc911x.c                       |    2 +-
 drivers/net/usb/asix.c                      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    7 +--
 drivers/net/wireless/iwlwifi/iwl-dev.h      |    3 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c       |   26 ++++++++----
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    1 -
 drivers/net/wireless/libertas_tf/if_usb.c   |    2 +-
 include/net/mac80211.h                      |   20 ---------
 net/core/pktgen.c                           |    9 +---
 net/ipv4/af_inet.c                          |    1 +
 net/ipv4/ipmr.c                             |    9 ++--
 net/ipv4/udp.c                              |    1 +
 net/ipv6/ip6mr.c                            |    4 +-
 net/ipv6/proc.c                             |    6 +-
 net/mac80211/mlme.c                         |   22 ----------
 net/phonet/af_phonet.c                      |   52 +++++++++++-------------
 net/sched/sch_api.c                         |    2 +
 net/sched/sch_generic.c                     |    7 +++-
 26 files changed, 149 insertions(+), 169 deletions(-)
