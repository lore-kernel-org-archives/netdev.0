From: pablo@netfilter.org
Subject: [PATCH 0/7] [RFC] new user-space connection tracking helper infrastructure
Date: Mon,  4 Jun 2012 14:21:18 +0200
Message-ID: <1338812485-4232-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45894 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758284Ab2FDMWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 08:22:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi!

This is a new try to provide a full user-space connection tracking helper
infrastructure. Some of you, that check my tree, already know that I've been
working on this since time ago.

Previous approaches had important limitations and the integration with iptables
was not precisely nice.

The initial patches prepare the field for the introduction of the
cthelper infrastructure:

1) allocate fixed area for helper name, as a side effect, the initialization
   code of the kernel-space helpers looks better IMO.

2) allow variable length conntrack extensions.

3) add support for variable length helper extensions.

4) improve integration between nfnetlink_queue and ctnetlink. Now, you don't
   have to open two handlers listen to packets via nfqueue and receive
   events via ctnetlink. Instead, you can enable one flag to get the conntrack
   data together with the packet via nfqueue.

5) improve integration of packet mangling and nf_conntrack. This has been
   a long standing issue. If you mangle one TCP packet in user-space and
   connection tracking is enabled, nf_ct_tcp reports sequence tracking errors.
   This patch aims to resolve this issue.

6) Add CTA_HELP_INFO attribute. This is used to store the private helper
   data. Thus, we don't need to keep a redundant cache of conntrack entries
   in user-space. The private helper information is stored.

7) finally, the netlink cthelper infrastructure.

Of course, this patch makes no sense without the user-space changes, they are:

* updates in the conntrack-tools (see cthelper11 branch):
http://git.netfilter.org/cgi-bin/gitweb.cgi?p=conntrack-tools.git;a=shortlog;h=refs/heads/cthelper11

It includes the FTP user-space helper, one RPC helper (for NFSv3) and one TNS
helper (for Oracle).

* libnetfilter_cthelper
http://git.netfilter.org/cgi-bin/gitweb.cgi?p=libnetfilter_cthelper.git;a=summary

* libnetfilter_conntrack (new libmnl API)
http://git.netfilter.org/cgi-bin/gitweb.cgi?p=libnetfilter_conntrack.git;a=summary

* libnetfilter_queue
http://git.netfilter.org/cgi-bin/gitweb.cgi?p=libnetfilter_queue.git;a=shortlog;h=refs/heads/cthelper2

WARNING: Changes may occur in the user-space side until all those cthelper
branches are merged into master. Mind that this is work-in-progress.

Pablo Neira Ayuso (7):
  netfilter: nf_ct_helper: allocate 16 bytes for the helper and policy names
  netfilter: nf_ct_ext: support variable length extensions
  netfilter: nf_ct_helper: implement variable length helper private data
  netfilter: add glue code to integrate nfnetlink_queue and ctnetlink
  netfilter: nfnl_queue: support NAT TCP sequence adjustment if packet mangled
  netfilter: ctnetlink: add CTA_HELP_INFO attribute
  netfilter: add user-space connection tracking helper infrastructure

 include/linux/netfilter.h                      |   10 +
 include/linux/netfilter/Kbuild                 |    1 +
 include/linux/netfilter/nf_conntrack_sip.h     |    1 +
 include/linux/netfilter/nfnetlink.h            |    3 +-
 include/linux/netfilter/nfnetlink_conntrack.h  |    1 +
 include/linux/netfilter/nfnetlink_cthelper.h   |   55 ++
 include/linux/netfilter/nfnetlink_queue.h      |    7 +
 include/linux/netfilter_ipv4.h                 |    1 +
 include/linux/netfilter_ipv6.h                 |    1 +
 include/net/netfilter/nf_conntrack.h           |   35 +-
 include/net/netfilter/nf_conntrack_expect.h    |    4 +-
 include/net/netfilter/nf_conntrack_extend.h    |    7 +-
 include/net/netfilter/nf_conntrack_helper.h    |   29 +-
 include/net/netfilter/nf_nat_helper.h          |    7 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   56 +-
 net/ipv4/netfilter/nf_nat_amanda.c             |    4 +-
 net/ipv4/netfilter/nf_nat_h323.c               |    8 +-
 net/ipv4/netfilter/nf_nat_helper.c             |   13 +
 net/ipv4/netfilter/nf_nat_pptp.c               |    6 +-
 net/ipv4/netfilter/nf_nat_sip.c                |   14 +-
 net/ipv4/netfilter/nf_nat_tftp.c               |    4 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   56 +-
 net/netfilter/Kconfig                          |    8 +
 net/netfilter/Makefile                         |    1 +
 net/netfilter/core.c                           |    4 +
 net/netfilter/nf_conntrack_core.c              |    3 +-
 net/netfilter/nf_conntrack_extend.c            |   16 +-
 net/netfilter/nf_conntrack_ftp.c               |   11 +-
 net/netfilter/nf_conntrack_h323_main.c         |   16 +-
 net/netfilter/nf_conntrack_helper.c            |   35 +-
 net/netfilter/nf_conntrack_irc.c               |    8 +-
 net/netfilter/nf_conntrack_netlink.c           |  190 ++++++-
 net/netfilter/nf_conntrack_pptp.c              |   17 +-
 net/netfilter/nf_conntrack_proto_gre.c         |   16 +-
 net/netfilter/nf_conntrack_sane.c              |   12 +-
 net/netfilter/nf_conntrack_sip.c               |   36 +-
 net/netfilter/nf_conntrack_tftp.c              |    8 +-
 net/netfilter/nfnetlink_cthelper.c             |  668 ++++++++++++++++++++++++
 net/netfilter/nfnetlink_queue.c                |   84 ++-
 net/netfilter/xt_CT.c                          |   44 +-
 40 files changed, 1309 insertions(+), 191 deletions(-)
 create mode 100644 include/linux/netfilter/nfnetlink_cthelper.h
 create mode 100644 net/netfilter/nfnetlink_cthelper.c

-- 
1.7.10
