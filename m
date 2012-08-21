From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 21 Aug 2012 16:38:23 -0700 (PDT)
Message-ID: <20120821.163823.1448570709635488157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880Ab2HUXiY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 19:38:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A couple weeks of bug fixing in there.  The largest chunk is all the
broken crap Amerigo Wang found in the netpoll layer.

1) netpoll and it's users has several serious bugs:
   a) uses GFP_KERNEL with locks held
   b) interfaces requiring interrupts disabled are called with them
      enabled
   c) and vice versa
   d) VLAN tag demuxing, as per all other RX packet input paths, is
      not applied

   All from Amerigo Wang.

2) Hopefully cure the ipv4 mapped ipv6 address TCP early demux bugs
   for good, from Neal Cardwell.

3) Unlike AF_UNIX, AF_PACKET sockets don't set a default credentials
   when the user doesn't specify one explicitly during sendmsg().
   Instead we attach an empty (zero) SCM credential block which
   is definitely not what we want.  Fix from Eric Dumazet.

4) IPv6 illegally invokes netdevice notifiers with RCU lock held, fix
   from Ben Hutchings.

5) inet_csk_route_child_sock() checks wrong inet options pointer, fix
   from Christoph Paasch.

6) When AF_PACKET is used for transmit, packet loopback doesn't behave
   properly when a socket fanout is enabled, from Eric Leblond.

7) On bluetooth l2cap channel create failure, we leak the socket, from
   Jaganath Kanakkassery.

8) Fix all the netprio file handling bugs found by Al Viro, from John
   Fastabend.

9) Several error return and NULL deref bug fixes in networking drivers
   from Julia Lawall.

10) A large smattering of struct padding et al. kernel memory leaks
    to userspace found of Mathias Krause.

11) Conntrack expections in netfilter can access an uninitialized timer=
,
    fix from Pablo Neira Ayuso.

12) Several netfilter SIP tracker bug fixes from Patrick McHardy.

13) IPSEC ipv6 routes are not initialized correctly all the time,
    resulting in an OOPS in inet_putpeer().  Also from Patrick
    McHardy.

14) Bridging does rcu_dereference() outside of RCU protected area,
    from Stephen Hemminger.

15) Fix routing cache removal performance regression when looking up
    output routes that have a local destination.  From Zheng Yan.

Please pull, thanks a lot!

The following changes since commit ddf343f635fe4440cad528e12f96f28bd50a=
a099:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel=
/git/s390/linux (2012-08-14 07:58:59 +0300)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to e0e3cea46d31d23dc40df0a49a7a2c04fe8edfea=
:

  af_netlink: force credentials passing [CVE-2012-3520] (2012-08-21 14:=
53:01 -0700)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      rndis_wlan: Fix potential memory leak in update_pmkid()

Amerigo Wang (15):
      netpoll: use GFP_ATOMIC in slave_enable_netpoll() and __netpoll_s=
etup()
      netpoll: make __netpoll_cleanup non-block
      netconsole: do not release spin_lock when calling __netpoll_clean=
up
      netpoll: take rcu_read_lock_bh() in netpoll_rx()
      netpoll: use netpoll_rx_on() in netpoll_rx()
      netpoll: take rcu_read_lock_bh() in netpoll_send_skb_on_dev()
      bridge: add some comments for NETDEV_RELEASE
      bridge: use list_for_each_entry() in netpoll functions
      netpoll: check netpoll tx status on the right device
      netpoll: convert several functions to bool
      vlan: clean up some variable names
      vlan: clean up vlan_dev_hard_start_xmit()
      netpoll: handle vlan tags in netpoll tx and rx path
      netpoll: re-enable irq in poll_napi()
      netconsole: remove a redundant netconsole_target_put()

Andrei Emeltchenko (1):
      Bluetooth: smp: Fix possible NULL dereference

Ben Hutchings (4):
      llc2: Fix silent failure of llc_station_init()
      llc2: Call llc_station_exit() on llc2_init() failure path
      llc: Fix races between llc2 handler use and (un)registration
      ipv6: addrconf: Avoid calling netdevice notifiers with RCU read-s=
ide lock

Bj=F8rn Mork (5):
      net: qmi_wwan: use fixed interface number matching
      net: qmi_wwan: add Sierra Wireless devices
      net: qmi_wwan: compress device_id list using macros
      net: sierra_net: replace whitelist with ifnumber match
      net: qmi_wwan: new devices: UML290 and K5006-Z

Bob Copeland (1):
      ath5k: fix spin_lock_irqsave/spin_lock_bh nesting in mesh

Christoph Paasch (1):
      ipv4: Use newinet->inet_opt in inet_csk_route_child_sock()

Dan Carpenter (1):
      wireless: at76c50x: signedness bug in at76_dfu_get_state()

David S. Miller (2):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless
      Merge git://1984.lsi.us.es/nf

Dirk Gouders (1):
      netconsole.txt: revision of examples for the receiver of kernel m=
essages

Eric Dumazet (3):
      tcp: fix possible socket refcount problem
      ipv4: fix ip header ident selection in __ip_make_skb()
      af_netlink: force credentials passing [CVE-2012-3520]

Eric Leblond (1):
      af_packet: don't emit packet on orig fanout group

=46elix Fietkau (1):
      ath9k: fix interrupt storms on queued hardware reset

Gustavo Padovan (1):
      Bluetooth: Fix possible deadlock in SCO code

Igor Maravic (1):
      net: ipv6: proc: Fix error handling

Jaganath Kanakkassery (1):
      Bluetooth: Fix socket not getting freed if l2cap channel create f=
ails

Jason Wang (1):
      act_mirred: do not drop packets when fails to mirror it

Jesper Juhl (1):
      caif: Do not dereference NULL in chnl_recv_cb()

John Fastabend (3):
      net: netprio: fix files lock and remove useless d_path bits
      net: netprio: fd passed in SCM_RIGHTS datagram not set correctly
      net: netprio: fix cgrp create and write priomap race

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluet=
ooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Julia Lawall (6):
      drivers/net/ethernet/ti/davinci_cpdma.c: Remove potential NULL de=
reference
      drivers/net/ethernet/freescale/fs_enet: fix error return code
      drivers/net/ethernet/mellanox/mlx4/mcg.c: fix error return code
      drivers/net/wimax/i2400m/fw.c: fix error return code
      drivers/net/wan/dscc4.c: fix error return code
      drivers/net/irda: fix error return code

Kelvin Cheung (1):
      net/stmmac: fix issue of clk_get for Loongson1B.

Lorenzo Bianconi (1):
      ath9k: fix decrypt_error initialization in ath_rx_tasklet()

Manoj Iyer (1):
      Bluetooth: btusb: Add vendor specific ID (0a5c:21f4) BCM20702A0

Mathias Krause (14):
      atm: fix info leak in getsockopt(SO_ATMPVC)
      atm: fix info leak via getsockname()
      Bluetooth: HCI - Fix info leak in getsockopt(HCI_FILTER)
      Bluetooth: HCI - Fix info leak via getsockname()
      Bluetooth: RFCOMM - Fix info leak in getsockopt(BT_SECURITY)
      Bluetooth: RFCOMM - Fix info leak in ioctl(RFCOMMGETDEVLIST)
      Bluetooth: RFCOMM - Fix info leak via getsockname()
      Bluetooth: L2CAP - Fix info leak via getsockname()
      l2tp: fix info leak via getsockname()
      llc: fix info leak via getsockname()
      dccp: check ccid before dereferencing
      dccp: fix info leak via getsockopt(DCCP_SOCKOPT_CCID_TX_INFO)
      ipvs: fix info leak in getsockopt(IP_VS_SO_GET_TIMEOUT)
      net: fix info leak in compat dev_ifconf()

Neal Cardwell (1):
      net: tcp: move sk_rx_dst_set call after tcp_create_openreq_child(=
)

Pablo Neira Ayuso (2):
      netfilter: ctnetlink: fix missing locking while changing conntrac=
k from nfqueue
      netfilter: nf_ct_expect: fix possible access to uninitialized tim=
er

Patrick McHardy (4):
      netfilter: nf_ct_sip: fix helper name
      netfilter: nf_ct_sip: fix IPv6 address parsing
      netfilter: nf_nat_sip: fix via header translation with multiple p=
arameters
      net: ipv6: fix oops in inet_putpeer()

Peng Chen (1):
      Bluetooth: add support for atheros 0489:e057

Phil Edworthy (1):
      net: sh_eth: Add eth support for R8A7779 device

Rajkumar Manoharan (1):
      ath9k: stop btcoex on device suspend

Ram Malovany (3):
      Bluetooth: Fix using NULL inquiry entry
      Bluetooth: Fix using a NULL inquiry cache entry
      Bluetooth: Set name_state to unknown when entry name is empty

Randy Dunlap (1):
      net/core/dev.c: fix kernel-doc warning

Stephen Hemminger (1):
      bridge: fix rcu dereference outside of rcu_read_lock

Steve Glendinning (1):
      smsc75xx: add missing entry to MAINTAINERS

Steve Hodgson (1):
      vmxnet3: Fix race between dev_open() and register_netdev()

Szymon Janc (1):
      Bluetooth: Fix legacy pairing with some devices

Timur Tabi (2):
      dt: introduce for_each_available_child_of_node, of_get_next_avail=
able_child
      netdev/phy: skip disabled mdio-mux nodes

Yan, Zheng (1):
      ipv4: Cache local output routes

 Documentation/networking/netconsole.txt              |  19 +++-
 MAINTAINERS                                          |   6 ++
 drivers/bluetooth/ath3k.c                            |   2 +
 drivers/bluetooth/btusb.c                            |   2 +
 drivers/net/bonding/bond_main.c                      |  12 ++-
 drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c |   4 +-
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c     |   8 +-
 drivers/net/ethernet/mellanox/mlx4/mcg.c             |   4 +-
 drivers/net/ethernet/renesas/Kconfig                 |   4 +-
 drivers/net/ethernet/renesas/sh_eth.c                |  11 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |   2 +-
 drivers/net/ethernet/ti/davinci_cpdma.c              |   3 +-
 drivers/net/irda/ks959-sir.c                         |   1 +
 drivers/net/irda/ksdazzle-sir.c                      |   1 +
 drivers/net/netconsole.c                             |   6 --
 drivers/net/phy/mdio-mux.c                           |   2 +-
 drivers/net/team/team.c                              |  16 ++--
 drivers/net/usb/qmi_wwan.c                           | 251 +++++++++--=
-----------------------------------------
 drivers/net/usb/sierra_net.c                         |  52 +++--------
 drivers/net/vmxnet3/vmxnet3_drv.c                    |   2 +-
 drivers/net/wan/dscc4.c                              |   5 +-
 drivers/net/wimax/i2400m/fw.c                        |   4 +-
 drivers/net/wireless/at76c50x-usb.c                  |   2 +-
 drivers/net/wireless/ath/ath5k/base.c                |   6 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c        |   5 +-
 drivers/net/wireless/ath/ath9k/mac.c                 |  18 ++--
 drivers/net/wireless/ath/ath9k/mac.h                 |   1 +
 drivers/net/wireless/ath/ath9k/main.c                |   4 +-
 drivers/net/wireless/ath/ath9k/pci.c                 |   1 +
 drivers/net/wireless/ath/ath9k/recv.c                |   2 +-
 drivers/net/wireless/rndis_wlan.c                    |   6 +-
 drivers/of/base.c                                    |  27 ++++++
 include/linux/if_team.h                              |  30 +++----
 include/linux/netdevice.h                            |   5 +-
 include/linux/netfilter/nf_conntrack_sip.h           |   2 +-
 include/linux/netpoll.h                              |  42 +++++----
 include/linux/of.h                                   |   7 ++
 include/net/llc.h                                    |   2 +-
 include/net/scm.h                                    |   4 +-
 include/net/xfrm.h                                   |   2 +
 net/8021q/vlan_dev.c                                 |  52 ++++++-----
 net/atm/common.c                                     |   1 +
 net/atm/pvc.c                                        |   1 +
 net/bluetooth/hci_event.c                            |  28 ++++--
 net/bluetooth/hci_sock.c                             |   2 +
 net/bluetooth/l2cap_core.c                           |   1 +
 net/bluetooth/l2cap_sock.c                           |   3 +-
 net/bluetooth/rfcomm/sock.c                          |   2 +
 net/bluetooth/rfcomm/tty.c                           |   2 +-
 net/bluetooth/sco.c                                  |  19 ++--
 net/bluetooth/smp.c                                  |   5 +-
 net/bridge/br_device.c                               |  30 +++----
 net/bridge/br_forward.c                              |   2 +-
 net/bridge/br_if.c                                   |   6 +-
 net/bridge/br_private.h                              |   4 +-
 net/caif/chnl_net.c                                  |   4 +
 net/core/dev.c                                       |  17 +++-
 net/core/netpoll.c                                   | 109 +++++++++++=
+++++-------
 net/core/netprio_cgroup.c                            |  30 ++-----
 net/core/scm.c                                       |   4 +
 net/dccp/ccid.h                                      |   4 +-
 net/dccp/ccids/ccid3.c                               |   1 +
 net/ipv4/inet_connection_sock.c                      |   7 +-
 net/ipv4/ip_output.c                                 |   2 +-
 net/ipv4/netfilter/nf_nat_sip.c                      |   9 +-
 net/ipv4/route.c                                     |   1 -
 net/ipv4/tcp_ipv4.c                                  |   9 +-
 net/ipv4/tcp_minisocks.c                             |   2 -
 net/ipv4/tcp_output.c                                |  14 +--
 net/ipv4/tcp_timer.c                                 |   6 +-
 net/ipv6/addrconf.c                                  |   4 +-
 net/ipv6/proc.c                                      |   4 +-
 net/ipv6/tcp_ipv6.c                                  |  25 +++---
 net/ipv6/xfrm6_policy.c                              |   8 ++
 net/l2tp/l2tp_ip6.c                                  |   1 +
 net/llc/af_llc.c                                     |   8 +-
 net/llc/llc_input.c                                  |  21 ++++-
 net/llc/llc_station.c                                |  23 +----
 net/netfilter/ipvs/ip_vs_ctl.c                       |   1 +
 net/netfilter/nf_conntrack_expect.c                  |  29 ++----
 net/netfilter/nf_conntrack_netlink.c                 |   7 +-
 net/netfilter/nf_conntrack_sip.c                     |  92 +++++++++++=
+++-----
 net/netlink/af_netlink.c                             |   2 +-
 net/packet/af_packet.c                               |   9 ++
 net/sched/act_mirred.c                               |  11 ++-
 net/socket.c                                         |   1 +
 net/unix/af_unix.c                                   |   4 +-
 net/xfrm/xfrm_policy.c                               |   2 +
 88 files changed, 637 insertions(+), 575 deletions(-)
