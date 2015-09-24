From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/4] ila: Use NF_INET_PRE_ROUTING nfhook
Date: Thu, 24 Sep 2015 09:30:20 -0700
Message-ID: <1443112224-574543-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:62555 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752285AbbIXQae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 12:30:34 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t8OGTtEJ003667
	for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 09:30:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1x4ktsr9m5-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 09:30:33 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 9376c37862d911e58ca90002c99293a0-1fdf6240 for <netdev@vger.kernel.org>;	Thu,
 24 Sep 2015 09:30:32 -0700
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
lookup that occurs before early demux. This is done by using a hook
at NF_INET_PRE_ROUTING. For the backend we implement an rhashtable
that contains identifier to locator to mappings. The table also
allows more specific matches that include original locator and
interface.

Note that we are not adding functionality to support nfhook for
output (e.g. NF_INET_POST_ROUTING). This is because netfilter
is done post routing which is prolematic since we need are changing
the destination address in ILA. There is an in/out parameter in
table entries to allow for the future possibility of performing
lookups on the output path.

This patch set:
 - Add an rhashtable function to atomically replace and element.
   This is useful to implement sub-trees from a table entry
   without needing to use a special anchor structure as the
   table entry.
 - Add a start callback for starting a netlink dump.
 - Creates an ila directory under net/ipv6 and moves ila.c to it.
   ila.c is split into ila_common.c and ila_lwt.c.
 - Implement a table to do identifier->locator mapping. This is
   an rhashtable
 - Configuration for the table with netlink
 - Set nfhook for IPv6 NF_INET_PRE_ROUTING.do ILA lookup and
   translation.

Testing:
   Running 200 netperf TCP_RR streams

No ILA, baseline
   85.36% CPU utilization
   1917187 tps
   90/157/327 50/90/99% latencies

ILA before fix (LWT on both input and output)
   82.86% CPU utilization
   1668895 tps (-14% from baseline)
   106/180/336 50/90/99% latencies

ILA after fix (NF hook for input)
   82.69% CPU utilization
   1865113 tps (-2.7% from baseline)
   93/162/331 50/90/99% latencies

Tom Herbert (4):
  rhashtable: add function to replace an element
  netlink: add a start callback for starting a netlink dump
  ila: Create net/ipv6/ila directory
  ila: Add support for netfilter NF_INET_PRE_ROUTING hook

 include/linux/netlink.h    |   2 +
 include/linux/rhashtable.h |  80 ++++++
 include/net/genetlink.h    |   2 +
 include/uapi/linux/ila.h   |  22 ++
 net/ipv6/Makefile          |   2 +-
 net/ipv6/ila.c             | 229 ----------------
 net/ipv6/ila/Makefile      |   7 +
 net/ipv6/ila/ila.h         |  48 ++++
 net/ipv6/ila/ila_common.c  | 102 +++++++
 net/ipv6/ila/ila_lwt.c     | 149 ++++++++++
 net/ipv6/ila/ila_xlat.c    | 665 +++++++++++++++++++++++++++++++++++++++++++++
 net/netlink/af_netlink.c   |   4 +
 net/netlink/genetlink.c    |  16 ++
 13 files changed, 1098 insertions(+), 230 deletions(-)
 delete mode 100644 net/ipv6/ila.c
 create mode 100644 net/ipv6/ila/Makefile
 create mode 100644 net/ipv6/ila/ila.h
 create mode 100644 net/ipv6/ila/ila_common.c
 create mode 100644 net/ipv6/ila/ila_lwt.c
 create mode 100644 net/ipv6/ila/ila_xlat.c

-- 
2.4.6
