From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/23] Netfilter updates for net-next
Date: Fri, 22 Apr 2016 15:39:31 +0200
Message-ID: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45188 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752369AbcDVNkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:40:05 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id BF544842C
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A8F33FAB46
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 735C19D11C
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:39:59 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter updates for your net-next
tree, mostly from Florian Westphal to sort out the lack of sufficient
validation in x_tables and connlabel preparation patches to add
nf_tables support. They are:

1) Ensure we don't go over the ruleset blob boundaries in
   mark_source_chains().

2) Validate that target jumps land on an existing xt_entry. This extra
   sanitization comes with a performance penalty when loading the ruleset.

3) Introduce xt_check_entry_offsets() and use it from {arp,ip,ip6}tables.

4) Get rid of the smallish check_entry() functions in {arp,ip,ip6}tables.

5) Make sure the minimal possible target size in x_tables.

6) Similar to #3, add xt_compat_check_entry_offsets() for compat code.

7) Check that standard target size is valid.

8) More sanitization to ensure that the target_offset field is correct.

9) Add xt_check_entry_match() to validate that matches are well-formed.

10-12) Three patch to reduce the number of parameters in
    translate_compat_table() for {arp,ip,ip6}tables by using a container
    structure.

13) No need to return value from xt_compat_match_from_user(), so make
    it void.

14) Consolidate translate_table() so it can be used by compat code too.

15) Remove obsolete check for compat code, so we keep consistent with
    what was already removed in the native layout code (back in 2007).

16) Get rid of target jump validation from mark_source_chains(),
    obsoleted by #2.

17) Introduce xt_copy_counters_from_user() to consolidate counter
    copying, and use it from {arp,ip,ip6}tables.

18,22) Get rid of unnecessary explicit inlining in ctnetlink for dump
    functions.

19) Move nf_connlabel_match() to xt_connlabel.

20) Skip event notification if connlabel did not change.

21) Update of nf_connlabels_get() to make the upcoming nft connlabel
    support easier.

23) Remove spinlock to read protocol state field in conntrack.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 7d45a04cbc2683f9552572850f1c711d9b96dd26:

  tipc: remove remnants of old broadcast code (2016-04-13 17:49:11 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git HEAD

for you to fetch changes up to a163f2cb393d9d71cad57bfe6a8c7f452a478fb4:

  netfilter: conntrack: don't acquire lock during seq_printf (2016-04-19 20:26:25 +0200)

----------------------------------------------------------------
Florian Westphal (21):
      netfilter: x_tables: don't move to non-existent next rule
      netfilter: x_tables: validate targets of jumps
      netfilter: x_tables: add and use xt_check_entry_offsets
      netfilter: x_tables: kill check_entry helper
      netfilter: x_tables: assert minimum target size
      netfilter: x_tables: add compat version of xt_check_entry_offsets
      netfilter: x_tables: check standard target size too
      netfilter: x_tables: check for bogus target offset
      netfilter: x_tables: validate all offsets and sizes in a rule
      netfilter: ip_tables: simplify translate_compat_table args
      netfilter: ip6_tables: simplify translate_compat_table args
      netfilter: arp_tables: simplify translate_compat_table args
      netfilter: x_tables: xt_compat_match_from_user doesn't need a retval
      netfilter: x_tables: do compat validation via translate_table
      netfilter: x_tables: remove obsolete overflow check for compat case too
      netfilter: x_tables: remove obsolete check
      netfilter: x_tables: introduce and use xt_copy_counters_from_user
      netfilter: connlabels: move helpers to xt_connlabel
      netfilter: labels: don't emit ct event if labels were not changed
      netfilter: connlabels: change nf_connlabels_get bit arg to 'highest used'
      netfilter: conntrack: don't acquire lock during seq_printf

Pablo Neira Ayuso (2):
      netfilter: ctnetlink: remove unnecessary inlining
      netfilter: ctnetlink: restore inlining for netlink message size calculation

 include/linux/netfilter/x_tables.h          |  12 +-
 include/net/netfilter/nf_conntrack_labels.h |   5 +-
 net/ipv4/netfilter/arp_tables.c             | 303 ++++++++------------------
 net/ipv4/netfilter/ip_tables.c              | 327 ++++++++--------------------
 net/ipv6/netfilter/ip6_tables.c             | 320 +++++++--------------------
 net/netfilter/nf_conntrack_labels.c         |  44 ++--
 net/netfilter/nf_conntrack_netlink.c        | 119 +++++-----
 net/netfilter/nf_conntrack_proto_sctp.c     |   8 +-
 net/netfilter/nf_conntrack_proto_tcp.c      |   8 +-
 net/netfilter/nft_ct.c                      |   2 +
 net/netfilter/x_tables.c                    | 245 ++++++++++++++++++++-
 net/netfilter/xt_connlabel.c                |  14 +-
 net/openvswitch/conntrack.c                 |   2 +-
 13 files changed, 591 insertions(+), 818 deletions(-)
