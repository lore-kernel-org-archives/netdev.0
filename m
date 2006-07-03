From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET 00/04]: Increase number of possible routing tables
Date: Mon,  3 Jul 2006 09:52:59 +0200 (MEST)
Message-ID: <20060703075259.6286.67397.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:20432 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750722AbWGCHxB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 03:53:01 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I took on Ben's challenge to increase the number of possible routing tables,
these are the resulting patches.

The table IDs are changed to 32 bit values and are contained in a new netlink
routing attribute. For compatibility rtm_table in struct rtmsg can still be
used to access the first 255 tables and contains the low 8 bit of the table
ID in case of dumps. Unfortunately there are no invalid values for rtm_table,
so the best userspace can do in case of a new iproute version that tries to
access tables > 255 on an old kernel is to use RTM_UNSPEC (0) for rtm_table,
which will make the kernel allocate an empty table instead of silently adding
routes to a more or less random table. The iproute patch will follow shortly.

The hash tables are statically sized since on-the-fly resizing would require
introducing locking in the packet processing path (currently we need none),
if this is a problem we could just directly attach table references to rules,
since tables are never deleted or freed this would be a simple change.

One spot is still missing (nl_fib_lookup), so these patches are purely a RFC
for now. Tested only with IPv4, I mainly converted DECNET as well to keep it
in sync and because iteration over all possible table values, as done in many
spots, has an unacceptable overhead with 32 bit values.


 include/linux/rtnetlink.h |   11 +++
 include/net/dn_fib.h      |    7 +-
 include/net/ip_fib.h      |   39 ++++---------
 net/decnet/dn_fib.c       |   62 ++-------------------
 net/decnet/dn_route.c     |    1 
 net/decnet/dn_rules.c     |   12 ++--
 net/decnet/dn_table.c     |  133 ++++++++++++++++++++++++++++++++--------------
 net/ipv4/fib_frontend.c   |  115 +++++++++++++++++++++++++--------------
 net/ipv4/fib_hash.c       |   30 +++++-----
 net/ipv4/fib_lookup.h     |    4 -
 net/ipv4/fib_rules.c      |   18 +++---
 net/ipv4/fib_semantics.c  |    5 +
 net/ipv4/fib_trie.c       |   32 +++++------
 net/ipv4/route.c          |    1 
 net/ipv6/route.c          |    1 
 15 files changed, 255 insertions(+), 216 deletions(-)

Patrick McHardy:
      [NET]: Use u32 for routing table IDs
      [NET]: Introduce RTA_TABLE routing attribute
      [IPV4]: Increase number of possible routing tables to 2^32
      [DECNET]: Increase number of possible routing tables to 2^32
