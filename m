From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/21] Netfilter updates for net-next
Date: Mon, 13 Apr 2015 21:29:39 +0200
Message-ID: <1428953401-4838-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39642 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223AbbDMTZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 15:25:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

A final pull request, I know it's very late but this time I think it's worth a
bit of rush.

The following patchset contains Netfilter/nf_tables updates for net-next, more
specifically concatenation support and dynamic stateful expression
instantiation.

This also comes with a couple of small patches. One to fix the ebtables.h
userspace header and another to get rid of an obsolete example file in tree
that describes a nf_tables expression.

This time, I decided to paste the original descriptions. This will result in a
rather large commit description, but I think these bytes to keep.

Patrick McHardy says:

====================
netfilter: nf_tables: concatenation support

The following patches add support for concatenations, which allow multi
dimensional exact matches in O(1).

The basic idea is to split the data registers, currently consisting of
4 registers of 16 bytes each, into smaller units, 16 registers of 4
bytes each, and making sure each register store always leaves the
full 32 bit in a well defined state, meaning smaller stores will
zero the remaining bits.

Based on that, we can load multiple adjacent registers with different
values, thereby building a concatenated bigger value, and use that
value for set lookups.

Sets are changed to use variable sized extensions for their key and
data values, removing the fixed limit of 16 bytes while saving memory
if less space is needed.

As a side effect, these patches will allow some nice optimizations in
the future, like using jhash2 in nft_hash, removing the masking in
nft_cmp_fast, optimized data comparison using 32 bit word size etc.
These are not done so far however.

The patches are split up as follows:

 * the first five patches add length validation to register loads and
   stores to make sure we stay within bounds and prepare the validation
   functions for the new addressing mode

 * the next patches prepare for changing to 32 bit addressing by
   introducing a struct nft_regs, which holds the verdict register as
   well as the data registers. The verdict members are moved to a new
   struct nft_verdict to allow to pull struct nft_data out of the stack.

 * the next patches contain preparatory conversions of expressions and
   sets to use 32 bit addressing

 * the next patch introduces so far unused register conversion helpers
   for parsing and dumping register numbers over netlink

 * following is the real conversion to 32 bit addressing, consisting of
   replacing struct nft_data in struct nft_regs by an array of u32s and
   actually translating and validating the new register numbers.

 * the final two patches add support for variable sized data items and
   variable sized keys / data in set elements

The patches have been verified to work correctly with nft binaries using
both old and new addressing.
====================

Patrick McHardy says:

====================
netfilter: nf_tables: dynamic stateful expression instantiation

The following patches are the grand finale of my nf_tables set work,
using all the building blocks put in place by the previous patches
to support something like iptables hashlimit, but a lot more powerful.

Sets are extended to allow attaching expressions to set elements.
The dynset expression dynamically instantiates these expressions
based on a template when creating new set elements and evaluates
them for all new or updated set members.

In combination with concatenations this effectively creates state
tables for arbitrary combinations of keys, using the existing
expression types to maintain that state. Regular set GC takes care
of purging expired states.

We currently support two different stateful expressions, counter
and limit. Using limit as a template we can express the functionality
of hashlimit, but completely unrestricted in the combination of keys.
Using counter we can perform accounting for arbitrary flows.

The following examples from patch 5/5 show some possibilities.
Userspace syntax is still WIP, especially the listing of state
tables will most likely be seperated from normal set listings
and use a more structured format:

1. Limit the rate of new SSH connections per host, similar to iptables
   hashlimit:

# nft filter input tcp dport ssh ct state new \
        flow ip saddr timeout 60s \
        limit 10/second \
        accept

2. Account network traffic between each set of /24 networks:

# nft filter forward \
        flow ip saddr & 255.255.255.0 . ip daddr & 255.255.255.0 \
        counter

3. Account traffic to each host per user:

# nft filter output \
        flow skuid . ip daddr \
        counter

4. Account traffic for each combination of source address and TCP flags:

# nft filter input \
        flow ip saddr . tcp flags \
        counter

The resulting set content after a Xmas-scan look like this:

{
        192.168.122.1 . fin | psh | urg : counter packets 1001 bytes 40040,
        192.168.122.1 . ack : counter packets 74 bytes 3848,
        192.168.122.1 . psh | ack : counter packets 35 bytes 3144
}

In the future the "expressions attached to elements" will be extended
to also support user created non-stateful expressions to allow to
efficiently select beween a set of parameter sets, f.i. a set of log
statements with different prefixes based on the interface, which currently
require one rule each. This will most likely have to wait until the next
kernel version though.
====================

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

----------------------------------------------------------------

The following changes since commit e60a9de49c3744aa44128eaaed3aca965911ca2e:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue (2015-04-12 21:36:57 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 97bb43c3e06e9bfdc9e3140a312004df462685b9:

  netfilter: nf_tables: get rid of the expression example code (2015-04-13 20:20:09 +0200)

----------------------------------------------------------------
Pablo Neira Ayuso (2):
      uapi: ebtables: don't include linux/if.h
      netfilter: nf_tables: get rid of the expression example code

Patrick McHardy (19):
      netfilter: nf_tables: validate len in nft_validate_data_load()
      netfilter: nf_tables: rename nft_validate_data_load()
      netfilter: nft_lookup: use nft_validate_register_store() to validate types
      netfilter: nf_tables: kill nft_validate_output_register()
      netfilter: nf_tables: introduce nft_validate_register_load()
      netfilter: nf_tables: get rid of NFT_REG_VERDICT usage
      netfilter: nf_tables: use struct nft_verdict within struct nft_data
      netfilter: nf_tables: convert expressions to u32 register pointers
      netfilter: nf_tables: kill nft_data_cmp()
      netfilter: nf_tables: convert sets to u32 data pointers
      netfilter: nf_tables: add register parsing/dumping helpers
      netfilter: nf_tables: switch registers to 32 bit addressing
      netfilter: nf_tables: support variable sized data in nft_data_init()
      netfilter: nf_tables: variable sized set element keys / data
      netfilter: nf_tables: add helper functions for expression handling
      netfilter: nf_tables: prepare for expressions associated to set elements
      netfilter: nf_tables: mark stateful expressions
      netfilter: nf_tables: add flag to indicate set contains expressions
      netfilter: nft_dynset: dynamic stateful expression instantiation

 include/linux/netfilter_bridge/ebtables.h      |    3 +-
 include/net/netfilter/nf_tables.h              |  103 ++++++---
 include/net/netfilter/nft_meta.h               |    4 +-
 include/uapi/linux/netfilter/nf_tables.h       |   40 +++-
 include/uapi/linux/netfilter_bridge/ebtables.h |    2 -
 net/bridge/netfilter/nft_meta_bridge.c         |   26 +--
 net/bridge/netfilter/nft_reject_bridge.c       |    6 +-
 net/ipv4/netfilter/nft_masq_ipv4.c             |    9 +-
 net/ipv4/netfilter/nft_redir_ipv4.c            |   11 +-
 net/ipv4/netfilter/nft_reject_ipv4.c           |    4 +-
 net/ipv6/netfilter/nft_masq_ipv6.c             |    7 +-
 net/ipv6/netfilter/nft_redir_ipv6.c            |   11 +-
 net/ipv6/netfilter/nft_reject_ipv6.c           |    4 +-
 net/netfilter/nf_tables_api.c                  |  271 +++++++++++++++++-------
 net/netfilter/nf_tables_core.c                 |   41 ++--
 net/netfilter/nft_bitwise.c                    |   37 ++--
 net/netfilter/nft_byteorder.c                  |   40 ++--
 net/netfilter/nft_cmp.c                        |   44 ++--
 net/netfilter/nft_compat.c                     |   26 +--
 net/netfilter/nft_counter.c                    |    3 +-
 net/netfilter/nft_ct.c                         |  110 ++++++----
 net/netfilter/nft_dynset.c                     |   79 +++++--
 net/netfilter/nft_expr_template.c              |   94 --------
 net/netfilter/nft_exthdr.c                     |   23 +-
 net/netfilter/nft_hash.c                       |   19 +-
 net/netfilter/nft_immediate.c                  |   18 +-
 net/netfilter/nft_limit.c                      |    5 +-
 net/netfilter/nft_log.c                        |    2 +-
 net/netfilter/nft_lookup.c                     |   31 ++-
 net/netfilter/nft_meta.c                       |  107 +++++-----
 net/netfilter/nft_nat.c                        |   71 ++++---
 net/netfilter/nft_payload.c                    |   24 +--
 net/netfilter/nft_queue.c                      |    4 +-
 net/netfilter/nft_rbtree.c                     |   15 +-
 net/netfilter/nft_redir.c                      |   19 +-
 net/netfilter/nft_reject_inet.c                |    5 +-
 36 files changed, 739 insertions(+), 579 deletions(-)
 delete mode 100644 net/netfilter/nft_expr_template.c
