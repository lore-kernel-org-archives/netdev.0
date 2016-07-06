From: Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC 0/7] netlink: Add allocation flag to netlink_unicast()
Date: Wed,  6 Jul 2016 09:28:29 +0900
Message-ID: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
	dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org, pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Masashi Honma <masashi.honma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Though netlink_broadcast() has allocation flag which can specify
memory allocation type (ex. GFP_KERNEL/GFP_ATOMIC), netlink_unicast()
does not have it. This can cause "BUG: sleeping function called from
invalid context at" with CONFIG_DEBUG_ATOMIC_SLEEP enabled kernel when
calling netlink_unicast() inside RCU read-side section and not in IRQ.

Though currently such a use case was not found, to solve potential
issue we will add an allocation flag to netlink_unicast(). Previously
netlink_unicast() have used gfp_any() as a flag. We replaced it to
GFP_KERNEL or GFP_ATOMIC or etc by guessing based on context. If we
could not determine the value, we remain it gfp_any(). We welcome
comments like "this gfp_any() should be GFP_KERNEL". Of course other
comments are welcome as well.

This series of patches are not tested.
This is a RFC because this does not fix existing issue.

Masashi Honma (7):
  netlink: Add allocation flag to netlink_unicast()
  netfilter: Add allocation flag to nfnetlink_unicast()
  netlink: Add allocation flag to nlmsg_unicast()
  infiniband: Add allocation flag to ibnl_unicast()
  net: Add allocation flag to rtnl_unicast()
  genetlink: Add allocation flag to genlmsg_unicast()
  genetlink: Add allocation flag to genlmsg_reply()

 crypto/crypto_user.c                  |  3 ++-
 drivers/block/drbd/drbd_nl.c          |  2 +-
 drivers/connector/connector.c         |  2 +-
 drivers/infiniband/core/iwpm_msg.c    |  6 ++---
 drivers/infiniband/core/iwpm_util.c   |  5 ++--
 drivers/infiniband/core/iwpm_util.h   |  1 +
 drivers/infiniband/core/netlink.c     |  4 ++--
 drivers/net/gtp.c                     |  3 ++-
 drivers/net/team/team.c               |  5 ++--
 drivers/net/wireless/mac80211_hwsim.c |  4 ++--
 fs/dlm/netlink.c                      |  2 +-
 include/linux/netfilter/nfnetlink.h   |  2 +-
 include/linux/netlink.h               |  3 ++-
 include/linux/rtnetlink.h             |  3 ++-
 include/net/genetlink.h               | 13 +++++++----
 include/net/netlink.h                 |  6 +++--
 include/rdma/rdma_netlink.h           |  3 ++-
 kernel/audit.c                        |  9 ++++----
 kernel/taskstats.c                    |  4 ++--
 net/core/devlink.c                    | 12 +++++-----
 net/core/net_namespace.c              |  2 +-
 net/core/rtnetlink.c                  | 12 ++++++----
 net/dcb/dcbnl.c                       |  2 +-
 net/decnet/dn_route.c                 |  3 ++-
 net/hsr/hsr_netlink.c                 |  6 +++--
 net/ieee802154/ieee802154.h           |  3 ++-
 net/ieee802154/netlink.c              |  5 ++--
 net/ieee802154/nl-mac.c               |  4 ++--
 net/ieee802154/nl-phy.c               |  6 ++---
 net/ieee802154/nl802154.c             |  4 ++--
 net/ipv4/devinet.c                    |  2 +-
 net/ipv4/fib_frontend.c               |  2 +-
 net/ipv4/fou.c                        |  2 +-
 net/ipv4/inet_diag.c                  |  2 +-
 net/ipv4/ipmr.c                       |  6 +++--
 net/ipv4/route.c                      |  2 +-
 net/ipv4/tcp_metrics.c                |  2 +-
 net/ipv4/udp_diag.c                   |  2 +-
 net/ipv6/addrconf.c                   |  4 ++--
 net/ipv6/addrlabel.c                  |  2 +-
 net/ipv6/ila/ila_xlat.c               |  2 +-
 net/ipv6/ip6mr.c                      |  6 +++--
 net/ipv6/route.c                      |  2 +-
 net/irda/irnetlink.c                  |  2 +-
 net/l2tp/l2tp_netlink.c               |  8 ++++---
 net/netfilter/ipset/ip_set_core.c     | 11 +++++----
 net/netfilter/ipvs/ip_vs_ctl.c        |  2 +-
 net/netfilter/nf_conntrack_netlink.c  |  9 +++++---
 net/netfilter/nf_tables_api.c         | 10 ++++----
 net/netfilter/nfnetlink.c             |  4 ++--
 net/netfilter/nfnetlink_acct.c        |  2 +-
 net/netfilter/nfnetlink_cthelper.c    |  2 +-
 net/netfilter/nfnetlink_cttimeout.c   |  5 ++--
 net/netfilter/nfnetlink_log.c         |  4 ++--
 net/netfilter/nfnetlink_queue.c       |  3 ++-
 net/netfilter/nft_compat.c            |  4 ++--
 net/netlabel/netlabel_cipso_v4.c      |  2 +-
 net/netlabel/netlabel_mgmt.c          |  4 ++--
 net/netlabel/netlabel_unlabeled.c     |  2 +-
 net/netlink/af_netlink.c              | 14 +++++++-----
 net/netlink/genetlink.c               |  2 +-
 net/nfc/netlink.c                     |  6 ++---
 net/openvswitch/datapath.c            |  9 ++++----
 net/sched/act_api.c                   |  2 +-
 net/sctp/sctp_diag.c                  |  2 +-
 net/tipc/bearer.c                     |  4 ++--
 net/tipc/netlink_compat.c             |  2 +-
 net/tipc/node.c                       |  2 +-
 net/unix/diag.c                       |  2 +-
 net/wireless/nl80211.c                | 43 ++++++++++++++++++-----------------
 net/xfrm/xfrm_user.c                  | 15 +++++++-----
 samples/connector/cn_test.c           |  2 +-
 72 files changed, 199 insertions(+), 155 deletions(-)

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
