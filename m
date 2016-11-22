From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH] net: ipv6: avoid errors due to per-cpu atomic alloc
Date: Tue, 22 Nov 2016 10:34:00 +0000
Message-ID: <1479810840-19122-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:60181 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932521AbcKVLCX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 06:02:23 -0500
Received: from pps.filterd (m0048192.ppops.net [127.0.0.1])
        by mx0b-000f0801.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAMAQWQv002382
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 02:34:59 -0800
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
        by mx0b-000f0801.pphosted.com with ESMTP id 26tpw9mvw2-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 02:34:59 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bursts of failures may occur when adding IPv6 routes via Netlink to the
kernel when testing under scale (e.g. 500 routes lost out of 1M). The
reason is that percpu.c:pcpu_balance_workfn() is not guaranteed to have
extended the area map in time for the atomic allocation using percpu.c:
pcpu_alloc() to succeed. This results in route additions failing with
an -ENOMEM error.

While the sender of the Netlink msg to add this route could check for
an ACK and retransmit in the case of an -ENOMEM error, the latter
should not occur in the first place if there is plenty of memory. The
solution is to use non-atomic alloc for rt6_info instead. While the
client may now be blocked for longer depending on the state of the
chunk being added to, this work has to be incurred at some point.

The alternative solution would be to provide configurable parameters
e.g. via sysctl in percpu.c for default map size, low/high empty pages
and map margins. For this solution, the map margin sizes need to be
stored per chunk, as large margins cannot be used if the dynamic early
slots map size is in use. This is not a preferred solution though, as
it requires tuning of these parameters to provide sufficient margins to
avoid -ENOMEM errors depending on system requirements.

Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/ipv6/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1b57e11..0e9bb76 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -347,7 +347,7 @@ struct rt6_info *ip6_dst_alloc(struct net *net,
 	struct rt6_info *rt = __ip6_dst_alloc(net, dev, flags);
 
 	if (rt) {
-		rt->rt6i_pcpu = alloc_percpu_gfp(struct rt6_info *, GFP_ATOMIC);
+		rt->rt6i_pcpu = alloc_percpu_gfp(struct rt6_info *, GFP_KERNEL);
 		if (rt->rt6i_pcpu) {
 			int cpu;
 
-- 
1.7.10.4
