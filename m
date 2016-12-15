From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/2] inet: Fixes for inet_csk_get_port and soreusport
Date: Wed, 14 Dec 2016 16:54:14 -0800
Message-ID: <20161215005416.1561632-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <jbacik@fb.com>, <eric.dumazet@gmail.com>,
        <raigatgoog@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41650 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932234AbcLOAym (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 19:54:42 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBF0q5Y5001175
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 16:54:29 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 27bdndswcb-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 16:54:29 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 07e65e2ac26111e692450002c991e86a-a5ac0a50 for <netdev@vger.kernel.org>;        Wed,
 14 Dec 2016 16:54:28 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes a couple of issues I noticed while debugging our
softlockup issue in inet_csk_get_port.

- Don't allow jump into port scan in inet_csk_get_port if function
  was called with non-zero port number (looking up explicit port
  number).
- When inet_csk_get_port is called with zero port number (ie. perform
  scan) an reuseport is set on the socket, don't match sockets that
  also have reuseport set. The intent from the user should be
  to get a new port number and then explictly bind other
  sockets to that number using soreuseport.

Tested:

Ran first patch on production workload with no ill effect.

For second patch, ran a little listener application and first
demonstrated that unbound sockets with soreuseport can indeed
be bound to unrelated soreuseport sockets.


Tom Herbert (2):
  inet: Don't go into port scan when looking for specific bind port
  inet: Fix get port to handle zero port number with soreuseport set

 include/net/inet6_connection_sock.h |  3 ++-
 include/net/inet_connection_sock.h  |  6 ++++--
 net/ipv4/inet_connection_sock.c     | 16 ++++++++++------
 net/ipv6/inet6_connection_sock.c    |  7 ++++---
 4 files changed, 20 insertions(+), 12 deletions(-)

-- 
2.9.3
