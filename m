From: David Miller <davem@davemloft.net>
Subject: (unknown)
Date: Fri, 14 Apr 2017 15:14:33 -0400 (EDT)
Message-ID: <20170414.151433.1112358014056352044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48648 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755681AbdDNTOh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 15:14:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Things seem to be settling down as far as networking is concerned,
let's hope this trend continues...

1) Add iov_iter_revert() and use it to fix the behavior of
   skb_copy_datagram_msg() et al., from Al Viro.

2) Fix the protocol used in the synthetic SKB we cons up for the
   purposes of doing a simulated route lookup for RTM_GETROUTE
   requests.  From Florian Larysch.

3) Don't add noop_qdisc to the per-device qdisc hashes, from Cong
   Wang.

4) Don't call netdev_change_features with the team lock held, from Xin
   Long.

5) Revert TCP F-RTO extension to catch more spurious timeouts because it
   interacts very badly with some middle-boxes.  From Yuchung Cheng.

6) Fix the loss of error values in l2tp {s,g}etsockopt calls, from
   Guillaume Nault.

7) ctnetlink uses bit positions where it should be using bit masks,
   fix from Liping Zhang.

8) Missing RCU locking in netfilter helper code, from Gao Feng.

9) Avoid double frees and use-after-frees in tcp_disconnect(), from
   Eric Dumazet.

10) Don't do a changelink before we register the netdevice in bridging,
    from Ido Schimmel.

11) Lock the ipv6 device address list properly, from Rabin Vincent.

Please pull, thanks a lot!

The following changes since commit ea6b1720ce25f92f7a17b2e0c2b653d20773d10a:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-04-05 20:17:38 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to f4c13c8ec56e70eeff3e365e0c5fcdad16845b32:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf (2017-04-14 10:47:13 -0400)

----------------------------------------------------------------
Al Viro (2):
      [iov_iter] new privimitive: iov_iter_revert()
      make skb_copy_datagram_msg() et.al. preserve ->msg_iter on error

Daniele Palmas (1):
      drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR for Telit PID 0x1201

David S. Miller (5):
      Merge branch 'for-davem' of git://git.kernel.org/.../viro/vfs
      Merge branch 'l2tp-sockopt-errors'
      Merge tag 'linux-can-fixes-for-4.12-20170404' of git://git.kernel.org/.../mkl/linux-can
      Merge branch 'bridge-register-netdev-before-changelink'
      Merge git://git.kernel.org/.../pablo/nf

Eric Dumazet (2):
      netfilter: xt_TCPMSS: add more sanity tests on tcph->doff
      tcp: clear saved_syn in tcp_disconnect()

Florian Larysch (1):
      net: ipv4: fix multipath RTM_GETROUTE behavior when iif is given

Gao Feng (3):
      net: tcp: Increase TCP_MIB_OUTRSTS even though fail to alloc skb
      netfilter: helper: Add the rcu lock when call __nf_conntrack_helper_find
      netfilter: ipt_CLUSTERIP: Fix wrong conntrack netns refcnt usage

Geert Uytterhoeven (1):
      can: rcar_can: Do not print virtual addresses

Guillaume Nault (2):
      l2tp: don't mask errors in pppol2tp_setsockopt()
      l2tp: don't mask errors in pppol2tp_getsockopt()

Ido Schimmel (2):
      bridge: implement missing ndo_uninit()
      bridge: netlink: register netdevice before executing changelink

Johannes Berg (2):
      bpf: reference may_access_skb() from __bpf_prog_run()
      net: xdp: don't export dev_change_xdp_fd()

Liping Zhang (6):
      netfilter: ctnetlink: using bit to represent the ct event
      netfilter: ctnetlink: make it safer when checking the ct helper name
      netfilter: make it safer during the inet6_dev->addr_list traversal
      netfilter: ctnetlink: skip dumping expect when nfct_help(ct) is NULL
      netfilter: nf_ct_expect: use proper RCU list traversal/update APIs
      netfilter: nft_hash: do not dump the auto generated seed

Markus Marb (1):
      can: ifi: use correct register to read rx status

Oliver Neukum (1):
      usbnet: make sure no NULL pointer is passed through

Rabin Vincent (1):
      ipv6: Fix idev->addr_list corruption

WANG Cong (1):
      net_sched: check noop_qdisc before qdisc_hash_add()

Xin Long (2):
      sctp: listen on the sock only when it's state is listening or closed
      team: call netdev_change_features out of team lock

Yuchung Cheng (1):
      tcp: restrict F-RTO to work-around broken middle-boxes

 drivers/net/can/ifi_canfd/ifi_canfd.c |  2 +-
 drivers/net/can/rcar/rcar_can.c       |  3 +--
 drivers/net/team/team.c               | 19 +++++++++++--------
 drivers/net/usb/qmi_wwan.c            |  2 +-
 drivers/net/usb/usbnet.c              | 19 +++++++++++++++----
 include/linux/uio.h                   |  6 +++++-
 kernel/bpf/core.c                     | 12 ++++++------
 lib/iov_iter.c                        | 63 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_device.c                | 20 +++++++++++---------
 net/bridge/br_if.c                    |  1 -
 net/bridge/br_multicast.c             |  7 +++++--
 net/bridge/br_netlink.c               |  7 +++++--
 net/bridge/br_private.h               |  5 +++++
 net/core/datagram.c                   | 23 ++++++++++++++---------
 net/core/dev.c                        |  1 -
 net/ipv4/netfilter/ipt_CLUSTERIP.c    |  2 +-
 net/ipv4/route.c                      |  2 +-
 net/ipv4/tcp.c                        |  1 +
 net/ipv4/tcp_input.c                  | 20 ++++++++++++--------
 net/ipv4/tcp_output.c                 |  4 ++--
 net/ipv6/addrconf.c                   | 11 +++++++----
 net/l2tp/l2tp_ppp.c                   |  9 ++++++---
 net/netfilter/nf_conntrack_expect.c   |  4 ++--
 net/netfilter/nf_conntrack_helper.c   | 17 ++++++++++++-----
 net/netfilter/nf_conntrack_netlink.c  | 41 +++++++++++++++++++++++++++++------------
 net/netfilter/nf_nat_redirect.c       |  2 ++
 net/netfilter/nft_hash.c              | 10 +++++++---
 net/netfilter/xt_TCPMSS.c             |  6 +++++-
 net/netfilter/xt_TPROXY.c             |  5 ++++-
 net/sched/sch_generic.c               |  2 +-
 net/sctp/socket.c                     |  3 +++
 31 files changed, 238 insertions(+), 91 deletions(-)
