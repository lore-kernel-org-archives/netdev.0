From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/10] Netfilter fixes for net
Date: Wed, 11 Nov 2015 18:33:33 +0100
Message-ID: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48373 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152AbbKKRdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 12:33:52 -0500
Received: from antivirus1-rhel7.int (antivirus1.int [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 22C811392AD
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:51 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 0F1655DC
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:51 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id F1E705DC
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:48 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree. This
large batch that includes fixes for ipset, netfilter ingress, nf_tables
dynamic set instantiation and a longstanding Kconfig dependency problem.
More specifically, they are:

1) Add missing check for empty hook list at the ingress hook, from
   Florian Westphal.

2) Input and output interface are swapped at the ingress hook,
   reported by Patrick McHardy.

3) Resolve ipset extension alignment issues on ARM, patch from Jozsef
   Kadlecsik.

4) Fix bit check on bitmap in ipset hash type, also from Jozsef.

5) Release buckets when all entries have expired in ipset hash type,
   again from Jozsef.

6) Oneliner to initialize conntrack tuple object in the PPTP helper,
   otherwise the conntrack lookup may fail due to random bits in the
   structure holes, patch from Anthony Lineham.

7) Silence a bogus gcc warning in nfnetlink_log, from Arnd Bergmann.

8) Fix Kconfig dependency problems with TPROXY, socket and dup, also
   from Arnd.

9) Add __netdev_alloc_pcpu_stats() to allow creating percpu counters
   from atomic context, this is required by the follow up fix for
   nf_tables.

10) Fix crash from the dynamic set expression, we have to add new clone
    operation that should be defined when a simple memcpy is not enough.
    This resolves a crash when using per-cpu counters with new Patrick
    McHardy's flow table nft support.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 212cd0895330b775f2db49451f046a5ca4e5704b:

  selinux: fix random read in selinux_ip_postroute_compat() (2015-11-05 16:45:51 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 086f332167d64b645d37405854f049b9ad7371ab:

  netfilter: nf_tables: add clone interface to expression operations (2015-11-10 23:47:32 +0100)

----------------------------------------------------------------
Anthony Lineham (1):
      netfilter: Fix removal of GRE expectation entries created by PPTP

Arnd Bergmann (2):
      netfilter: nfnetlink_log: work around uninitialized variable warning
      netfilter: fix xt_TEE and xt_TPROXY dependencies

Florian Westphal (1):
      netfilter: ingress: don't use nf_hook_list_active

Jozsef Kadlecsik (3):
      netfilter: ipset: Fix extension alignment
      netfilter: ipset: Fix hash:* type expiration
      netfilter: ipset: Fix hash type expire: release empty hash bucket block

Pablo Neira Ayuso (4):
      netfilter: ingress: fix wrong input interface on hook
      Merge branch 'master' of git://blackhole.kfki.hu/nf
      net: add __netdev_alloc_pcpu_stats() to indicate gfp flags
      netfilter: nf_tables: add clone interface to expression operations

 include/linux/netdevice.h                 | 27 +++++++------
 include/linux/netfilter/ipset/ip_set.h    |  2 +-
 include/linux/netfilter_ingress.h         | 13 ++++---
 include/net/netfilter/nf_tables.h         | 16 +++++++-
 net/ipv4/netfilter/nf_nat_pptp.c          |  2 +-
 net/netfilter/Kconfig                     |  6 +--
 net/netfilter/ipset/ip_set_bitmap_gen.h   | 17 +++-----
 net/netfilter/ipset/ip_set_bitmap_ip.c    | 14 ++-----
 net/netfilter/ipset/ip_set_bitmap_ipmac.c | 64 ++++++++++++++-----------------
 net/netfilter/ipset/ip_set_bitmap_port.c  | 18 ++++-----
 net/netfilter/ipset/ip_set_core.c         | 14 ++++---
 net/netfilter/ipset/ip_set_hash_gen.h     | 26 ++++++++-----
 net/netfilter/ipset/ip_set_list_set.c     |  5 ++-
 net/netfilter/nfnetlink_log.c             |  2 +-
 net/netfilter/nft_counter.c               | 49 +++++++++++++++++++----
 net/netfilter/nft_dynset.c                |  5 ++-
 16 files changed, 161 insertions(+), 119 deletions(-)
