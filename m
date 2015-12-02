From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v3 0/5] ila: Optimization to preserve value of early demux
Date: Wed, 2 Dec 2015 14:13:23 -0800
Message-ID: <1449094408-2963234-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:32265 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750798AbbLBWNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 17:13:35 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tB2M9bOX015570
	for <netdev@vger.kernel.org>; Wed, 2 Dec 2015 14:13:35 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1yhu1xc3j6-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 14:13:35 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 ed01d13c994111e5bff124be0595f910-121fa230 for <netdev@vger.kernel.org>;	Wed,
 02 Dec 2015 14:13:33 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current implementation of ILA, LWT is used to perform
translation on both the input and output paths. This is functional,
however there is a big performance hit in the receive path. Early
demux occurs before the routing lookup (a hit actually obviates the
route lookup). Therefore the stack currently performs early
demux before translation so that a local connection with ILA
addresses is never matched. Note that this issue is not just
with ILA, but pretty much any translated or encapsulated packet
handled by LWT would miss the opportunity for early demux. Solving
the general problem seems non trivial since we would need to move
the route lookup before early demx thereby mitigating the value.

This patch set addresses the issue for ILA by adding a fast locator
lookup that occurs before early demux. This is done by setting iptables
rule in PREROUTING. Something like:

ip6tables -t mangle -A PREROUTING --dst 2001:0:0:33::/64 -j ILAIN

For the backend we implement an rhashtable that contains identifier
to locator to mappings. The table also allows more specific matches
that include original locator and interface.

This patch set:
 - Add an rhashtable function to atomically replace and element.
   This is useful to implement sub-trees from a table entry
   without needing to use a special anchor structure as the
   table entry.
 - Add a start callback for starting a netlink dump.
 - Creates an ila directory under net/ipv6 and moves ila.c to it.
   ila.c is split into ila_common.c and ila_lwt.c.
 - Implement a table to do identifier->locator mapping. This is
   an rhashtable (in ila_xlat.c).
 - Configuration for the table with netlink.
 - Add ILAIN and ILAOUT targets which call into the ILA module

Changes in v2:
 - Use iptables targets instead of a new xfrm function

Changes in v3:
 - Add __rcu to next pointer in struct ila_map

Testing:
   Running 200 netperf TCP_RR streams

No ILA, baseline
   79.26% CPU utilization
   1678282 tps
   104/189/390 50/90/99% latencies

ILA before fix (LWT on both input and output)
   81.91% CPU utilization
   1464723 tps (-14.5% from baseline)
   121/215/411 50/90/99% latencies

ILA after fix (PREROUTING ILAIN target for input)
   80.41% CPU utilization
   1577483 tps (-6.3% from baseline)
   113/203/393 50/90/99% latencies

Tom Herbert (5):
  ila: Create net/ipv6/ila directory
  rhashtable: add function to replace an element
  netlink: add a start callback for starting a netlink dump
  ila: Add generic ILA translation facility
  net: ILA iptables target

 include/linux/netlink.h    |   2 +
 include/linux/rhashtable.h |  82 ++++++
 include/net/genetlink.h    |   2 +
 include/net/ila.h          |  18 ++
 include/uapi/linux/ila.h   |  22 ++
 net/ipv6/Makefile          |   2 +-
 net/ipv6/ila.c             | 229 ---------------
 net/ipv6/ila/Makefile      |   7 +
 net/ipv6/ila/ila.h         |  48 ++++
 net/ipv6/ila/ila_common.c  | 103 +++++++
 net/ipv6/ila/ila_lwt.c     | 152 ++++++++++
 net/ipv6/ila/ila_xlat.c    | 679 +++++++++++++++++++++++++++++++++++++++++++++
 net/netfilter/Kconfig      |  12 +
 net/netfilter/Makefile     |   1 +
 net/netfilter/xt_ILA.c     |  82 ++++++
 net/netlink/af_netlink.c   |   4 +
 net/netlink/genetlink.c    |  16 ++
 17 files changed, 1231 insertions(+), 230 deletions(-)
 create mode 100644 include/net/ila.h
 delete mode 100644 net/ipv6/ila.c
 create mode 100644 net/ipv6/ila/Makefile
 create mode 100644 net/ipv6/ila/ila.h
 create mode 100644 net/ipv6/ila/ila_common.c
 create mode 100644 net/ipv6/ila/ila_lwt.c
 create mode 100644 net/ipv6/ila/ila_xlat.c
 create mode 100644 net/netfilter/xt_ILA.c

-- 
2.4.6
