From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 1/3] ipv6: Avoid creating RTF_CACHE from a rt that is not managed by fib6 tree
Date: Wed, 11 Nov 2015 11:51:06 -0800
Message-ID: <1447271468-3930566-2-git-send-email-kafai@fb.com>
References: <1447271468-3930566-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Chris Siebenmann <cks-rhbugzilla@cs.toronto.edu>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58411 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752613AbbKKTvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 14:51:22 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tABJmqpI030652
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 11:51:21 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 1y439ya53j-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 11:51:21 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 9311d5fe88ad11e589a124be0595f910-16dfc230 for <netdev@vger.kernel.org>;	Wed,
 11 Nov 2015 11:51:18 -0800
In-Reply-To: <1447271468-3930566-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original bug report:
https://bugzilla.redhat.com/show_bug.cgi?id=1272571

The setup has a IPv4 GRE tunnel running in a IPSec.  The bug
happens when ndisc starts sending router solicitation at the gre
interface.  The simplified oops stack is like:

__lock_acquire+0x1b2/0x1c30
lock_acquire+0xb9/0x140
_raw_write_lock_bh+0x3f/0x50
__ip6_ins_rt+0x2e/0x60
ip6_ins_rt+0x49/0x50
~~~~~~~~
__ip6_rt_update_pmtu.part.54+0x145/0x250
ip6_rt_update_pmtu+0x2e/0x40
~~~~~~~~
ip_tunnel_xmit+0x1f1/0xf40
__gre_xmit+0x7a/0x90
ipgre_xmit+0x15a/0x220
dev_hard_start_xmit+0x2bd/0x480
__dev_queue_xmit+0x696/0x730
dev_queue_xmit+0x10/0x20
neigh_direct_output+0x11/0x20
ip6_finish_output2+0x21f/0x770
ip6_finish_output+0xa7/0x1d0
ip6_output+0x56/0x190
~~~~~~~~
ndisc_send_skb+0x1d9/0x400
ndisc_send_rs+0x88/0xc0
~~~~~~~~

The rt passed to ip6_rt_update_pmtu() is created by
icmp6_dst_alloc() and it is not managed by the fib6 tree,
so its rt6i_table == NULL.  When __ip6_rt_update_pmtu() creates
a RTF_CACHE clone, the newly created clone also has rt6i_table == NULL
and it causes the ip6_ins_rt() oops.

During pmtu update, we only want to create a RTF_CACHE clone
from a rt which is currently managed (or owned) by the
fib6 tree.  It means either rt->rt6i_node != NULL or
rt is a RTF_PCPU clone.

It is worth to note that rt6i_table may not be NULL even it is
not (yet) managed by the fib6 tree (e.g. addrconf_dst_alloc()).
Hence, rt6i_node is a better check instead of rt6i_table.

Fixes: 45e4fd26683c ("ipv6: Only create RTF_CACHE routes after encountering pmtu")
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reported-by: Chris Siebenmann <cks-rhbugzilla@cs.toronto.edu>
Cc: Chris Siebenmann <cks-rhbugzilla@cs.toronto.edu>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c8bc9b4..74907c5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1322,6 +1322,12 @@ static void rt6_do_update_pmtu(struct rt6_info *rt, u32 mtu)
 	rt6_update_expires(rt, net->ipv6.sysctl.ip6_rt_mtu_expires);
 }
 
+static bool rt6_cache_allowed_for_pmtu(const struct rt6_info *rt)
+{
+	return !(rt->rt6i_flags & RTF_CACHE) &&
+		(rt->rt6i_flags & RTF_PCPU || rt->rt6i_node);
+}
+
 static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 				 const struct ipv6hdr *iph, u32 mtu)
 {
@@ -1335,7 +1341,7 @@ static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 	if (mtu >= dst_mtu(dst))
 		return;
 
-	if (rt6->rt6i_flags & RTF_CACHE) {
+	if (!rt6_cache_allowed_for_pmtu(rt6)) {
 		rt6_do_update_pmtu(rt6, mtu);
 	} else {
 		const struct in6_addr *daddr, *saddr;
-- 
2.5.1
