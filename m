From: pablo@netfilter.org
Subject: [PATCH 00/25] netfilter updates for net-next (upcoming 3.5)
Date: Tue,  8 May 2012 02:21:54 +0200
Message-ID: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51703 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757622Ab2EHAWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 20:22:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains the Netfilter updates for net-next.
Most notably:

* The new /proc/sys/net/netfilter/nf_conntrack_helper entry that
  allows to disable the automatic conntrack helper assignment from
  Eric Leblond. This patch also spots a warning to inform the user
  that this behaviour will be removed at some point. The automatic
  conntrack helper assignment may allows attackers to open hole in
  the firewall to access the protected network segments (with
  incorrect configurations). More information on this issue at:

  https://home.regit.org/netfilter-en/secure-use-of-helpers/

  In the near future, all conntrack helpers will be explicitly
  attached via the CT target, as we longing discussed during
  the last netfilter workshop.

* One new sysctl to translate the input device to vlan device name
  from Florian Westphal. He required this to get the REDIRECT target
  working with another sysctl vlan-on-top-of-bridge.

* Major improvements in the ip_vs_sync code from Julian Anastasov.
  They aim to improve scalability and to address possible message
  loss due to socket overrun under high rate of synchronization
  messages.

* Several minor memory allocation flags fixes from IPVS people
  contributors.

* Eric Leblond's patch spotted one problem that becomes noticeable
  if a) automatic helper assignment is disabled, and b) if NAT is
  in use, and c) the CT target is used to attach a non-standard
  conntrack helper port. This fix comes from myself.

* One small update to allow updating the expectation timeout from
  Kelvie Wong.

* Finally, remove ip[6]_queue support since they have been marked
  as obsolete since long time ago. Now, we have nfnetlink_queue
  which is way more flexible from myself.

You can pull these changes from:

git://1984.lsi.us.es/net-next master

If time allows, I'd like to send a second batch. There a several patches
that are very close to get into shape still on netfilter-devel.

Thanks!

Eric Dumazet (1):
  netfilter: nf_conntrack: use this_cpu_inc()

Eric Leblond (1):
  netfilter: nf_ct_helper: allow to disable automatic helper assignment

Florian Westphal (1):
  netfilter: bridge: optionally set indev to vlan

H Hartley Sweeten (2):
  ipvs: ip_vs_ftp: local functions should not be exposed globally
  ipvs: ip_vs_proto: local functions should not be exposed globally

Hans Schillstrom (1):
  net: export sysctl_[r|w]mem_max symbols needed by ip_vs_sync

Julian Anastasov (14):
  ipvs: timeout tables do not need GFP_ATOMIC allocation
  ipvs: LBLC scheduler does not need GFP_ATOMIC allocation on init
  ipvs: DH scheduler does not need GFP_ATOMIC allocation
  ipvs: WRR scheduler does not need GFP_ATOMIC allocation
  ipvs: LBLCR scheduler does not need GFP_ATOMIC allocation on init
  ipvs: SH scheduler does not need GFP_ATOMIC allocation
  ipvs: ignore IP_VS_CONN_F_NOOUTPUT in backup server
  ipvs: remove check for IP_VS_CONN_F_SYNC from ip_vs_bind_dest
  ipvs: fix ip_vs_try_bind_dest to rebind app and transmitter
  ipvs: always update some of the flags bits in backup
  ipvs: wakeup master thread
  ipvs: reduce sync rate with time thresholds
  ipvs: add support for sync threads
  ipvs: optimize the use of flags in ip_vs_bind_dest

Kelvie Wong (1):
  netfilter: nf_ct_expect: partially implement ctnetlink_change_expect

Pablo Neira Ayuso (2):
  netfilter: nf_conntrack: fix explicit helper attachment and NAT
  netfilter: remove ip_queue support

Sasha Levin (1):
  ipvs: use GFP_KERNEL allocation where possible

Tony Zelenoff (1):
  netfilter: nf_ct_ecache: refactor notifier registration

 Documentation/ABI/removed/ip_queue            |    9 +
 Documentation/networking/ip-sysctl.txt        |   13 +-
 include/linux/ip_vs.h                         |    5 +
 include/linux/netfilter/nf_conntrack_common.h |    4 +
 include/linux/netfilter_ipv4/Kbuild           |    1 -
 include/linux/netfilter_ipv4/ip_queue.h       |   72 ---
 include/linux/netlink.h                       |    2 +-
 include/net/ip_vs.h                           |   87 +++-
 include/net/netfilter/nf_conntrack.h          |   10 +-
 include/net/netfilter/nf_conntrack_helper.h   |    4 +-
 include/net/netns/conntrack.h                 |    3 +
 net/bridge/br_netfilter.c                     |   26 +-
 net/core/sock.c                               |    2 +
 net/ipv4/netfilter/Makefile                   |    3 -
 net/ipv4/netfilter/ip_queue.c                 |  639 ------------------------
 net/ipv6/netfilter/Kconfig                    |   22 -
 net/ipv6/netfilter/Makefile                   |    1 -
 net/ipv6/netfilter/ip6_queue.c                |  641 ------------------------
 net/netfilter/ipvs/ip_vs_conn.c               |   69 ++-
 net/netfilter/ipvs/ip_vs_core.c               |   30 +-
 net/netfilter/ipvs/ip_vs_ctl.c                |   70 ++-
 net/netfilter/ipvs/ip_vs_dh.c                 |    2 +-
 net/netfilter/ipvs/ip_vs_ftp.c                |    2 +-
 net/netfilter/ipvs/ip_vs_lblc.c               |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c              |    2 +-
 net/netfilter/ipvs/ip_vs_proto.c              |    6 +-
 net/netfilter/ipvs/ip_vs_sh.c                 |    2 +-
 net/netfilter/ipvs/ip_vs_sync.c               |  662 +++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_wrr.c                |    2 +-
 net/netfilter/nf_conntrack_core.c             |   15 +-
 net/netfilter/nf_conntrack_ecache.c           |   10 +-
 net/netfilter/nf_conntrack_helper.c           |  120 ++++-
 net/netfilter/nf_conntrack_netlink.c          |   10 +-
 security/selinux/nlmsgtab.c                   |   13 -
 34 files changed, 853 insertions(+), 1708 deletions(-)
 create mode 100644 Documentation/ABI/removed/ip_queue
 delete mode 100644 include/linux/netfilter_ipv4/ip_queue.h
 delete mode 100644 net/ipv4/netfilter/ip_queue.c
 delete mode 100644 net/ipv6/netfilter/ip6_queue.c

-- 
1.7.9.5
