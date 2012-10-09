From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] netfilter: nf_conntrack: fix rt_gateway checks for h323
Date: Wed, 10 Oct 2012 02:00:47 +0300
Message-ID: <1349823647-2166-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58221 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757122Ab2JIWz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 18:55:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	After the change "Adjust semantics of rt->rt_gateway"
(commit f8126f1d51) we should properly match the nexthop when
destinations are directly connected because rt_gateway can be 0.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	This patch needs a closer look from the Netfilter team.

	It restores the check as it was committed originally,
i.e. to compare nexthops. I'm not sure what is the desired logic,
it can depend on the following:

- two directly connected hosts (rt_gateway=0) can be from different
subnets or not

- one party A is the gateway (rt_gateway=0), another party uses
this gateway (rt_gateway=A)

	May be someone that knows this code better can comment
if the check should be different.

 net/netfilter/nf_conntrack_h323_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

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
1.7.3.4
