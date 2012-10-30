From: pablo@netfilter.org
Subject: [PATCH 1/3] netfilter: nf_conntrack: fix rt_gateway checks for H.323 helper
Date: Tue, 30 Oct 2012 11:19:18 +0100
Message-ID: <1351592360-5686-2-git-send-email-pablo@netfilter.org>
References: <1351592360-5686-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58425 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932602Ab2J3KTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 06:19:38 -0400
In-Reply-To: <1351592360-5686-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

After the change "Adjust semantics of rt->rt_gateway"
(commit f8126f1d51) we should properly match the nexthop when
destinations are directly connected because rt_gateway can be 0.

The rt_gateway checks in H.323 helper try to avoid the creation
of an unnecessary expectation in this call-forwarding case:

http://people.netfilter.org/zhaojingmin/h323_conntrack_nat_helper/#_Toc133598073

However, the existing code fails to avoid that in many cases,
see this thread:

http://marc.info/?l=linux-netdev&m=135043175028620&w=2

It seems it is not trivial to know from the kernel if two hosts
have to go through the firewall to communicate each other, which
is the main point of the call-forwarding filter code to avoid
creating unnecessary expectations.

So this patch just gets things the way they were as before
commit f8126f1d51.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_h323_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 1b30b0d..962795e 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -753,7 +753,8 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 				   flowi4_to_flowi(&fl1), false)) {
 			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
 					   flowi4_to_flowi(&fl2), false)) {
-				if (rt1->rt_gateway == rt2->rt_gateway &&
+				if (rt_nexthop(rt1, fl1.daddr) ==
+				    rt_nexthop(rt2, fl2.daddr) &&
 				    rt1->dst.dev  == rt2->dst.dev)
 					ret = 1;
 				dst_release(&rt2->dst);
-- 
1.7.10.4
