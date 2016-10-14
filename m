From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/2] ila: Cache a route in ILA lwt structure
Date: Thu, 13 Oct 2016 17:57:41 -0700
Message-ID: <20161014005743.288956-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54853 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755218AbcJNBAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 21:00:17 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9E0xS0B008210
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 18:00:11 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 262jtv8n83-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 18:00:11 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 8b6febdc91a911e68eb50002c99331b0-c94f5a50 for <netdev@vger.kernel.org>;        Thu,
 13 Oct 2016 18:00:05 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a dst_cache to ila_lwt structure. This holds a cached route for the
translated address. In ila_output we now perform a route lookup after
translation and if possible (destination in original route is full 128
bits) we set the dst_cache. Subsequent calls to ila_output can then use
the cache to avoid the route lookup.

This eliminates the need to set the gateway on ILA routes as previously
was being done. Now we can do something like:

./ip route add 3333::2000:0:0:2/128 encap ila 2222:0:0:2 \
    csum-mode neutral-map dev eth0  ## No via needed!

Also, add destroy_state to lwt ops. We need this do destroy the
dst_cache.

Tested:

Running 200 TCP_RR streams:

  Baseline, no ILA

    1730716 tps
    102/170/313 50/90/99% latencies
    88.11 CPU utilization

  Using ILA in both directions

    1680428 tps
    105/176/325 50/90/99% latencies
    88.16 CPU utilization

Tom Herbert (2):
  lwtunnel: Add destroy state operation
  ila: Cache a route to translated address

 include/net/lwtunnel.h |  7 ++---
 net/core/lwtunnel.c    | 13 +++++++++
 net/ipv6/ila/ila_lwt.c | 76 +++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 88 insertions(+), 8 deletions(-)

-- 
2.9.3
