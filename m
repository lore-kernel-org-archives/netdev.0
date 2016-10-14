From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 0/2] ila: Cache a route in ILA lwt structure
Date: Fri, 14 Oct 2016 11:25:35 -0700
Message-ID: <20161014182537.1713757-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51428 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752376AbcJNS03 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 14:26:29 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u9EILk5r009485
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 11:25:46 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2615d3tnvw-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 11:25:46 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 9e0e74b0923b11e69e9c24be05956610-827f7a50 for <netdev@vger.kernel.org>;        Fri,
 14 Oct 2016 11:25:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a dst_cache to ila_lwt structure. This holds a cached route for the
translated address. In ila_output we now perform a route lookup after
translation and if possible (destination in original route is full 128
bits) we set the dst_cache. Subsequent calls to ila_output can then use
the cache to avoid the route lookup.

This eliminates the need to set the gateway on ILA routes as previously
was being done. Now we can do somthing like:

./ip route add 3333::2000:0:0:2/128 encap ila 2222:0:0:2 \
    csum-mode neutral-map dev eth0  ## No via needed!

Also, add destroy_state to lwt ops. We need this do destroy the
dst_cache.

- v2
  - Fixed comparisons to fc_dst_len to make comparison against number
    of bits in data structure not bytes.
  - Move destroy_state under build_state (requested by Jiri)
  - Other minor cleanup

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
 net/core/lwtunnel.c    | 13 ++++++++
 net/ipv6/ila/ila_lwt.c | 80 ++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 90 insertions(+), 10 deletions(-)

-- 
2.9.3
