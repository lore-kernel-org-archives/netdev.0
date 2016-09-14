From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/7] net: ILA resolver and generic resolver backend
Date: Wed, 14 Sep 2016 16:22:49 -0700
Message-ID: <1473895376-347096-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tgraf@suug.ch>, <roopa@cumulusnetworks.com>, <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:48172 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756385AbcINXXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 19:23:30 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8ENLsSL018428
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 16:23:29 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 25f0w2670y-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 16:23:29 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 2f7700887ad211e688190002c9931860-412e1a50 for <netdev@vger.kernel.org>;        Wed,
 14 Sep 2016 16:23:03 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set implements an ILA host side resolver. This uses LWT to
implement the hook to a userspace resolver and tracks pending unresolved
address using the backend net resolver.

This patch set contains:

- An new library function to allocate an array of spinlocks for use
  with locking hash buckets.
- Make hash function in rhashtable directly callable.
- A generic resolver backend infrastructure. This primary does two
  things: track unsesolved addresses and implement a timeout for
  resolution not happening. These mechanisms provides rate limiting
  control over resolution requests (for instance in ILA it use used
  to rate limit requests to userspace to resolve addresses).
- The ILA resolver. This is implements to path from the kernel ILA
  implementation to a userspace daemon that an identifier address
  needs to be resolved.
- Routing messages are used over netlink to indicate resoltion
  requests.

Changes from intial RFC:

 - Added net argument to LWT build_state
 - Made resolve timeout an attribute of the LWT encap route
 - Changed ILA notifications to be regular routing messages of event
   RTM_ADDR_RESOLVE, family RTNL_FAMILY_ILA, and group
   RTNLGRP_ILA_NOTIFY

Tested:
 - Ran a UDP flood to random addresses in a resolver prefix. Observed
   timeout and limits were working (watching "ip monitor").
 - Also ran against an ILA client daemon that runs the resolver
   protocol. Observed that when resolution completes (ILA encap route is
   installed) routing messages are no longer sent.

Tom Herbert (7):
  lwt: Add net to build_state argument
  spinlock: Add library function to allocate spinlock buckets array
  rhashtable: Call library function alloc_bucket_locks
  ila: Call library function alloc_bucket_locks
  rhashtable: abstract out function to get hash
  net: Generic resolver backend
  ila: Resolver mechanism

 include/linux/rhashtable.h     |  28 +++--
 include/linux/spinlock.h       |   6 +
 include/net/lwtunnel.h         |  10 +-
 include/net/resolver.h         |  58 +++++++++
 include/uapi/linux/ila.h       |   9 ++
 include/uapi/linux/lwtunnel.h  |   1 +
 include/uapi/linux/rtnetlink.h |   8 +-
 lib/Makefile                   |   2 +-
 lib/bucket_locks.c             |  63 ++++++++++
 lib/rhashtable.c               |  46 +------
 net/Kconfig                    |   4 +
 net/core/Makefile              |   1 +
 net/core/lwtunnel.c            |  11 +-
 net/core/resolver.c            | 268 +++++++++++++++++++++++++++++++++++++++++
 net/ipv4/fib_semantics.c       |   7 +-
 net/ipv4/ip_tunnel_core.c      |  12 +-
 net/ipv6/Kconfig               |   1 +
 net/ipv6/ila/Makefile          |   2 +-
 net/ipv6/ila/ila.h             |  16 +++
 net/ipv6/ila/ila_common.c      |   7 ++
 net/ipv6/ila/ila_lwt.c         |  15 ++-
 net/ipv6/ila/ila_resolver.c    | 246 +++++++++++++++++++++++++++++++++++++
 net/ipv6/ila/ila_xlat.c        |  51 ++------
 net/ipv6/route.c               |   2 +-
 net/mpls/mpls_iptunnel.c       |   6 +-
 25 files changed, 761 insertions(+), 119 deletions(-)
 create mode 100644 include/net/resolver.h
 create mode 100644 lib/bucket_locks.c
 create mode 100644 net/core/resolver.c
 create mode 100644 net/ipv6/ila/ila_resolver.c

-- 
2.8.0.rc2
