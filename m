From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT net-2.6.26 0/5] [NET] NETNS: several optimization without
 CONFIG_NET_NS.
Date: Wed, 26 Mar 2008 08:39:48 +0900 (JST)
Message-ID: <20080326.083948.93645750.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, dlezcano@fr.ibm.com, brian.haley@hp.com,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55017 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760397AbYCYXiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:38:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, folks,

Okay, here's the respin.  Changes:
	Add twsk_net(), twsk_net_set().
	Fix missing seq_file_net() conversion in net/ipv4/route.c.
	Add net_eq().
	Add neigh_parms_net() and pneigh_net().

Full diffs will follow.

Changes are also available (on top of net-2.6.26 tree) at
        git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-netns-20080326

Regards,
---

HEADLINES
---------

    [NET] NETNS: Omit net_device->nd_net without CONFIG_NET_NS.
    [NET] NETNS: Omit sock->sk_net without CONFIG_NET_NS.
    [NET] NETNS: Omit seq_net_private->net without CONFIG_NET_NS.
    [NET] NETNS: Omit neigh_parms->net and pneigh_entry->net without CONFIG_NET_NS.
    [NET] NETNS: Omit namespace comparision without CONFIG_NET_NS.

DIFFSTAT
--------

 arch/ia64/hp/sim/simeth.c           |    2 +
 drivers/block/aoe/aoenet.c          |    2 +
 drivers/net/bonding/bond_3ad.c      |    2 +
 drivers/net/bonding/bond_alb.c      |    2 +
 drivers/net/bonding/bond_main.c     |    6 ++--
 drivers/net/hamradio/bpqether.c     |    4 +-
 drivers/net/loopback.c              |    2 +
 drivers/net/macvlan.c               |    2 +
 drivers/net/pppoe.c                 |    6 ++--
 drivers/net/veth.c                  |    2 +
 drivers/net/via-velocity.c          |    2 +
 drivers/net/wan/dlci.c              |    2 +
 drivers/net/wan/hdlc.c              |    4 +-
 drivers/net/wan/lapbether.c         |    4 +-
 drivers/net/wan/syncppp.c           |    2 +
 drivers/s390/net/qeth_l3_main.c     |    2 +
 fs/proc/proc_net.c                  |    6 ++--
 include/linux/inetdevice.h          |    6 ++--
 include/linux/ipv6.h                |    4 +-
 include/linux/netdevice.h           |   25 ++++++++++++++-
 include/linux/seq_file.h            |    7 ++++
 include/net/inet_hashtables.h       |    8 ++---
 include/net/inet_timewait_sock.h    |   18 +++++++++++
 include/net/neighbour.h             |   25 +++++++++++++++
 include/net/net_namespace.h         |   12 +++++++
 include/net/route.h                 |    4 +-
 include/net/sock.h                  |   24 +++++++++++++-
 net/8021q/vlan.c                    |    2 +
 net/8021q/vlan_dev.c                |    2 +
 net/appletalk/aarp.c                |    4 +-
 net/appletalk/ddp.c                 |    6 ++--
 net/atm/clip.c                      |    2 +
 net/atm/mpc.c                       |    2 +
 net/atm/svc.c                       |    2 +
 net/ax25/af_ax25.c                  |    4 +-
 net/ax25/ax25_in.c                  |    2 +
 net/bluetooth/l2cap.c               |    2 +
 net/bluetooth/rfcomm/sock.c         |    2 +
 net/bluetooth/sco.c                 |    2 +
 net/bridge/br_netlink.c             |    4 +-
 net/bridge/br_notify.c              |    2 +
 net/bridge/br_stp_bpdu.c            |    2 +
 net/can/af_can.c                    |    4 +-
 net/can/bcm.c                       |    2 +
 net/can/raw.c                       |    2 +
 net/core/dev.c                      |   22 +++++++------
 net/core/dst.c                      |    2 +
 net/core/fib_rules.c                |    8 ++---
 net/core/neighbour.c                |   56 +++++++++++++++++++---------------
 net/core/pktgen.c                   |    2 +
 net/core/rtnetlink.c                |   16 +++++-----
 net/core/sock.c                     |   10 +++---
 net/decnet/af_decnet.c              |    4 +-
 net/decnet/dn_dev.c                 |    6 ++--
 net/decnet/dn_fib.c                 |    4 +-
 net/decnet/dn_route.c               |    6 ++--
 net/decnet/dn_table.c               |    2 +
 net/econet/af_econet.c              |    4 +-
 net/ipv4/af_inet.c                  |    6 ++--
 net/ipv4/arp.c                      |   14 ++++----
 net/ipv4/devinet.c                  |   16 +++++-----
 net/ipv4/fib_frontend.c             |   20 ++++++------
 net/ipv4/fib_hash.c                 |    5 +--
 net/ipv4/fib_rules.c                |    2 +
 net/ipv4/fib_trie.c                 |   13 ++++----
 net/ipv4/icmp.c                     |    8 ++---
 net/ipv4/igmp.c                     |   30 +++++++++---------
 net/ipv4/inet_connection_sock.c     |    4 +-
 net/ipv4/inet_hashtables.c          |    8 ++---
 net/ipv4/inet_timewait_sock.c       |    2 +
 net/ipv4/ip_fragment.c              |    2 +
 net/ipv4/ip_gre.c                   |    2 +
 net/ipv4/ip_input.c                 |    6 ++--
 net/ipv4/ip_options.c               |    2 +
 net/ipv4/ip_output.c                |    4 +-
 net/ipv4/ip_sockglue.c              |    6 ++--
 net/ipv4/ipconfig.c                 |    4 +-
 net/ipv4/ipmr.c                     |    6 ++--
 net/ipv4/netfilter/arp_tables.c     |   16 +++++-----
 net/ipv4/netfilter/ip_queue.c       |    2 +
 net/ipv4/netfilter/ip_tables.c      |   16 +++++-----
 net/ipv4/netfilter/ipt_MASQUERADE.c |    2 +
 net/ipv4/raw.c                      |   16 +++++-----
 net/ipv4/route.c                    |   57 ++++++++++++++++++----------------
 net/ipv4/tcp_ipv4.c                 |   20 ++++++------
 net/ipv4/udp.c                      |   20 ++++++------
 net/ipv4/xfrm4_policy.c             |    2 +
 net/ipv6/addrconf.c                 |   58 ++++++++++++++++++-----------------
 net/ipv6/addrlabel.c                |    6 ++--
 net/ipv6/af_inet6.c                 |    4 +-
 net/ipv6/fib6_rules.c               |    2 +
 net/ipv6/icmp.c                     |    6 ++--
 net/ipv6/inet6_hashtables.c         |    4 +-
 net/ipv6/ip6_fib.c                  |    2 +
 net/ipv6/ip6_output.c               |    4 +-
 net/ipv6/ipv6_sockglue.c            |    2 +
 net/ipv6/mcast.c                    |   22 +++++++------
 net/ipv6/ndisc.c                    |   24 +++++++-------
 net/ipv6/netfilter/ip6_queue.c      |    2 +
 net/ipv6/netfilter/ip6_tables.c     |   16 +++++-----
 net/ipv6/proc.c                     |    2 +
 net/ipv6/raw.c                      |   10 +++---
 net/ipv6/reassembly.c               |    2 +
 net/ipv6/route.c                    |   44 +++++++++++++--------------
 net/ipv6/tcp_ipv6.c                 |   12 ++++---
 net/ipv6/udp.c                      |    8 ++---
 net/ipv6/xfrm6_policy.c             |    2 +
 net/ipx/af_ipx.c                    |    4 +-
 net/irda/af_irda.c                  |    2 +
 net/irda/irlap_frame.c              |    2 +
 net/llc/llc_conn.c                  |    2 +
 net/llc/llc_input.c                 |    2 +
 net/netfilter/core.c                |    2 +
 net/netfilter/nf_sockopt.c          |    2 +
 net/netfilter/nfnetlink_queue.c     |    2 +
 net/netfilter/x_tables.c            |    4 +-
 net/netlabel/netlabel_unlabeled.c   |    2 +
 net/netlink/af_netlink.c            |   30 +++++++++---------
 net/netrom/af_netrom.c              |    4 +-
 net/packet/af_packet.c              |   30 +++++++++---------
 net/rose/af_rose.c                  |    4 +-
 net/sched/act_api.c                 |    4 +-
 net/sched/cls_api.c                 |    4 +-
 net/sched/sch_api.c                 |   10 +++---
 net/sctp/ipv6.c                     |    2 +
 net/sctp/protocol.c                 |    4 +-
 net/socket.c                        |    4 +-
 net/tipc/eth_media.c                |    4 +-
 net/tipc/socket.c                   |    2 +
 net/unix/af_unix.c                  |   26 ++++++++--------
 net/wireless/wext.c                 |    2 +
 net/x25/af_x25.c                    |    4 +-
 net/x25/x25_dev.c                   |    2 +
 net/xfrm/xfrm_policy.c              |    4 +-
 security/selinux/netif.c            |    2 +
 135 files changed, 597 insertions(+), 487 deletions(-)

--yoshfuji
