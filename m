From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v6 net-next 0/4] ila: Optimization to preserve value of early demux
Date: Tue, 15 Dec 2015 15:41:34 -0800
Message-ID: <1450222898-284030-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36499 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbbLOXlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 18:41:51 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tBFNcTTZ022367
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 15:41:50 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1ytsc5124c-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 15:41:50 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 6937bd78a38511e5833a0002c99331b0-bc1f9210 for <netdev@vger.kernel.org>;	Tue,
 15 Dec 2015 15:41:49 -0800
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
lookup that occurs before early demux. This done by hooking in to
NF_INET_PRE_ROUTING

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
 - Add a hook into NF_INET_PRE_ROUTING to perform ILA translation
   before early demux.

Changes in v2:
 - Use iptables targets instead of a new xfrm function

Changes in v3:
 - Add __rcu to next pointer in struct ila_map

Changes in v4:
 - Use hook for NF_INET_PRE_ROUTING

Changed in v5:
 - Register hooks per namespace using nf_register_net_hooks
 - Only register hooks when first mapping is actually added

Changed in v6:
  - Remove gfp argument in alloc_ila_locks, it is unnecessary
  - Set registered_hooks properly when hooks are registered

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

ILA after fix
   80.62% CPU utilization
   1622985 (-3.4% from baseline)
   110/191/347 50/90/99% latencies


Tom Herbert (4):
  ila: Create net/ipv6/ila directory
  rhashtable: add function to replace an element
  netlink: add a start callback for starting a netlink dump
  ila: Add generic ILA translation facility

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
 net/ipv6/ila/ila_xlat.c    | 681 +++++++++++++++++++++++++++++++++++++++++++++
 net/netlink/af_netlink.c   |   4 +
 net/netlink/genetlink.c    |  16 ++
 14 files changed, 1138 insertions(+), 230 deletions(-)
 create mode 100644 include/net/ila.h
 delete mode 100644 net/ipv6/ila.c
 create mode 100644 net/ipv6/ila/Makefile
 create mode 100644 net/ipv6/ila/ila.h
 create mode 100644 net/ipv6/ila/ila_common.c
 create mode 100644 net/ipv6/ila/ila_lwt.c
 create mode 100644 net/ipv6/ila/ila_xlat.c

-- 
2.4.6
