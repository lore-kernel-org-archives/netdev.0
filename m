From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 10 Nov 2012 14:46:38 -0500 (EST)
Message-ID: <20121110.144638.541637828816382743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562Ab2KJTqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2012 14:46:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Bug fixes galore, mostly in drivers as is often the case:

1) USB gadget and cdc_eem drivers need adjustments to their frame
   size lengths in order to handle VLANs correctly.  From Ian
   Coolidge.

2) TIPC and several network drivers erroneously call tasklet_disable
   before tasklet_kill, fix from Xiaotian Feng.

3) r8169 driver needs to apply the WOL suspend quirk to more chipsets,
   fix from Cyril Brulebois.

4) Fix multicast filters on RTL_GIGA_MAC_VER_35 r8169 chips, from
   Nathan Walp.

5) FDB netlink dumps should use RTM_NEWNEIGH as the message type,
   not zero.  From John Fastabend.

6) Fix smsc95xx tx checksum offload on big-endian, from Steve
   Glendinning.

7) __inet_diag_dump() needs to repsect and report the error value
   returned from inet_diag_lock_handler() rather than ignore it.
   Otherwise if an inet diag handler is not available for a particular
   protocol, we essentially report success instead of giving an error
   indication.  Fix from Cyrill Gorcunov.

8) When the QFQ packet scheduler sees TSO/GSO packets it does not
   handle things properly, and in fact ends up corrupting it's
   datastructures as well as mis-schedule packets.  Fix from Paolo
   Valente.

9) Fix oopser in skb_loop_sk(), from Eric Leblond.

10) CXGB4 passes partially uninitialized datastructures in to FW
    commands, fix from Vipul Pandya.

11) When we send unsolicited ipv6 neighbour advertisements, we should
    send them to the link-local allnodes multicast address, as per
    RFC4861.  Fix from Hannes Frederic Sowa.

12) There is some kind of bug in the usbnet's kevent deferral mechanism,
    but more immediately when it triggers an uncontrolled stream of
    kernel messages spam the log.  Rate limit the error log message
    triggered when this problem occurs, as sending thousands of error
    messages into the kernel log doesn't help matters at all, and in
    fact makes further diagnosis more difficult.

    From Steve Glendinning.

13) Fix gianfar restore from hibernation, from Wang Dongsheng.

14) The netlink message attribute sizes are wrong in the ipv6 GRE driver,
    it was using the size of ipv4 addresses instead of ipv6 ones :-)  Fix
    from Nicolas Dichtel.

Please pull, thanks a lot!

The following changes since commit 0f89a5733a8d28174c7adeb1fdc20ac11439e766:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-11-02 20:48:41 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to a375413311b39005ef281bfd71ae8f4e3df22e97:

  gre6: fix rtnl dump messages (2012-11-09 17:11:17 -0500)

----------------------------------------------------------------
Cyril Brulebois (1):
      r8169: Fix WoL on RTL8168d/8111d.

Cyrill Gorcunov (1):
      net: inet_diag -- Return error code if protocol handler is missed

Eric Leblond (1):
      af-packet: fix oops when socket is not present

Hannes Frederic Sowa (1):
      ipv6: send unsolicited neighbour advertisements to all-nodes

Ian Coolidge (2):
      usb: gadget: g_ether: fix frame size check for 802.1Q
      net: usb: cdc_eem: Fix rx skb allocation for 802.1Q VLANs

Jacob Keller (1):
      ptp: update adjfreq callback description

John Fastabend (1):
      rtnetlink: Use nlmsg type RTM_NEWNEIGH from dflt fdb dump

Lee Jones (1):
      isdn: Make CONFIG_ISDN depend on CONFIG_NETDEVICES

Masanari Iida (1):
      net: bnx2x: Fix typo in bnx2x driver

Nathan Walp (1):
      r8169: allow multicast packets on sub-8168f chipset.

Nicolas Dichtel (1):
      gre6: fix rtnl dump messages

Paolo Valente (1):
      pkt_sched: enable QFQ to support TSO/GSO

Steve Glendinning (2):
      smsc95xx: fix tx checksum offload for big endian
      usbnet: ratelimit kevent may have been dropped warnings

Vipul Pandya (2):
      cxgb4: Initialize data structures before using.
      cxgb4: Fix initialization of SGE_CONTROL register

Wang Dongsheng (1):
      gianfar: ethernet vanishes after restoring from hibernation

Xiaotian Feng (2):
      tipc: do not use tasklet_disable before tasklet_kill
      drivers/net: use tasklet_kill in device remove/close process

 drivers/isdn/Kconfig                                |   2 +-
 drivers/isdn/i4l/Kconfig                            |   2 +-
 drivers/isdn/i4l/isdn_common.c                      |   4 ---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c    |   4 +--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c          |   6 +++-
 drivers/net/ethernet/freescale/gianfar.c            |   5 ++-
 drivers/net/ethernet/jme.c                          |   8 ++---
 drivers/net/ethernet/marvell/skge.c                 |   2 +-
 drivers/net/ethernet/micrel/ksz884x.c               |   4 +--
 drivers/net/ethernet/realtek/r8169.c                |   5 +++
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c   |   2 +-
 drivers/net/usb/cdc_eem.c                           |   3 +-
 drivers/net/usb/smsc95xx.c                          |   1 +
 drivers/net/usb/usbnet.c                            |   8 +++--
 drivers/net/wireless/b43legacy/pio.c                |   2 +-
 drivers/usb/gadget/u_ether.c                        |   3 +-
 include/linux/ptp_clock_kernel.h                    |   3 +-
 net/core/dev.c                                      |   2 +-
 net/core/rtnetlink.c                                |   3 +-
 net/ipv4/inet_diag.c                                |   5 ++-
 net/ipv6/ip6_gre.c                                  |   8 ++---
 net/ipv6/ndisc.c                                    |   3 +-
 net/sched/sch_qfq.c                                 | 109 +++++++++++++++++++++++++++++++++++++++++----------------
 net/tipc/handler.c                                  |   1 -
 25 files changed, 131 insertions(+), 66 deletions(-)
