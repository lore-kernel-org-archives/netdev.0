From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/6] ila: Optimization to preserve value of early demux
Date: Tue, 29 Sep 2015 15:17:17 -0700
Message-ID: <1443565043-1287886-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60842 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755018AbbI2WRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:17:45 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t8TMGhJF007727
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:17:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1x832y023p-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:17:44 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 e77c047a66f711e59cdb0002c9dfb610-517f4240 for <netdev@vger.kernel.org>;	Tue,
 29 Sep 2015 15:17:43 -0700
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
lookup that occurs before early demux. This is done by creating an
XFRM hook to perform address translation early in the receive path.
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
   an rhashtable.
 - Configuration for the table with netlink.
 - Add XFRM xlat_addr facility. This includes a callback registeration
   function and hook to call registered callbacks.
 - Call xfrm6_xlat_addr from ipv6_rcv before NF_HOOK and routing.

Testing:
   Running 200 netperf TCP_RR streams

No ILA, baseline
   85.72% CPU utilization
   1861945 tps
   93/163/330 50/90/99% latencies

ILA before fix (LWT on both input and output)
   83.47 CPU utilization
   16583186 tps (-11% from baseline)
   107/183/338 50/90/99% latencies

ILA after fix (hook for input)
   84.97% CPU utilization
   1833948 tps (-1.5% from baseline)
   95/164/331 50/90/99% latencies

Hacked DNPT to do ILA
   80.94% CPU utilization
   1683315 tps (-10% from baseline)
   104/179/350 50/90/99% latencies

Tom Herbert (6):
  ila: Create net/ipv6/ila directory
  rhashtable: add function to replace an element
  netlink: add a start callback for starting a netlink dump
  xfrm: Add xfrm6 address translation function
  ipv6: Call xfrm6_xlat_addr from ipv6_rcv
  ila: Add support for xfrm6_xlat_addr

 include/linux/netlink.h    |   2 +
 include/linux/rhashtable.h |  82 ++++++
 include/net/genetlink.h    |   2 +
 include/net/xfrm.h         |  25 ++
 include/uapi/linux/ila.h   |  22 ++
 net/ipv6/Kconfig           |   5 +
 net/ipv6/Makefile          |   3 +-
 net/ipv6/ila.c             | 229 ----------------
 net/ipv6/ila/Makefile      |   7 +
 net/ipv6/ila/ila.h         |  48 ++++
 net/ipv6/ila/ila_common.c  | 103 ++++++++
 net/ipv6/ila/ila_lwt.c     | 152 +++++++++++
 net/ipv6/ila/ila_xlat.c    | 642 +++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_input.c       |   3 +
 net/ipv6/xfrm6_policy.c    |   7 +
 net/ipv6/xfrm6_xlat_addr.c |  66 +++++
 net/netlink/af_netlink.c   |   4 +
 net/netlink/genetlink.c    |  16 ++
 18 files changed, 1188 insertions(+), 230 deletions(-)
 delete mode 100644 net/ipv6/ila.c
 create mode 100644 net/ipv6/ila/Makefile
 create mode 100644 net/ipv6/ila/ila.h
 create mode 100644 net/ipv6/ila/ila_common.c
 create mode 100644 net/ipv6/ila/ila_lwt.c
 create mode 100644 net/ipv6/ila/ila_xlat.c
 create mode 100644 net/ipv6/xfrm6_xlat_addr.c

-- 
2.4.6
