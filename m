From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 0/6] net: ILA resolver and generic resolver backend
Date: Fri, 9 Sep 2016 16:19:51 -0700
Message-ID: <1473463197-3076903-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <tgraf@suug.ch>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38531 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754700AbcIIXUO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:20:14 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u89NGvoY025444
        for <netdev@vger.kernel.org>; Fri, 9 Sep 2016 16:20:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 25c60k855j-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 16:20:13 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 f4ac3d3476e311e69c900002c992ebde-e26f9a50 for <netdev@vger.kernel.org>;        Fri,
 09 Sep 2016 16:20:11 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets implements an ILA host side resolver. This uses LWT to
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

Tom Herbert (6):
  spinlock: Add library function to allocate spinlock buckets array
  rhashtable: Call library function alloc_bucket_locks
  ila: Call library function alloc_bucket_locks
  rhashtable: abstract out function to get hash
  net: Generic resolver backend
  ila: Resolver mechanism

 include/linux/rhashtable.h     |  28 +++--
 include/linux/spinlock.h       |   6 +
 include/net/resolver.h         |  58 +++++++++
 include/uapi/linux/lwtunnel.h  |   1 +
 include/uapi/linux/rtnetlink.h |   5 +
 lib/Makefile                   |   2 +-
 lib/bucket_locks.c             |  63 ++++++++++
 lib/rhashtable.c               |  46 +------
 net/Kconfig                    |   4 +
 net/core/Makefile              |   1 +
 net/core/resolver.c            | 267 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/Kconfig               |   1 +
 net/ipv6/ila/Makefile          |   2 +-
 net/ipv6/ila/ila.h             |  16 +++
 net/ipv6/ila/ila_common.c      |   7 ++
 net/ipv6/ila/ila_lwt.c         |   9 ++
 net/ipv6/ila/ila_resolver.c    | 192 +++++++++++++++++++++++++++++
 net/ipv6/ila/ila_xlat.c        |  51 ++------
 18 files changed, 666 insertions(+), 93 deletions(-)
 create mode 100644 include/net/resolver.h
 create mode 100644 lib/bucket_locks.c
 create mode 100644 net/core/resolver.c
 create mode 100644 net/ipv6/ila/ila_resolver.c

-- 
2.8.0.rc2
