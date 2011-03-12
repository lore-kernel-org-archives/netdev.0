From: David Miller <davem@davemloft.net>
Subject: [PATCH 17/25] netfilter: Use flowi4 and flowi6 in
 nf_conntrack_h323_main
Date: Sat, 12 Mar 2011 15:29:12 -0800 (PST)
Message-ID: <20110312.152912.15239459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755582Ab1CLX2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:28:34 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B1A9124C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:29:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nf_conntrack_h323_main.c |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index b969025..533a183 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -714,7 +714,6 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 				 u_int8_t family)
 {
 	const struct nf_afinfo *afinfo;
-	struct flowi fl1, fl2;
 	int ret = 0;
 
 	/* rcu_read_lock()ed by nf_hook_slow() */
@@ -722,17 +721,20 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 	if (!afinfo)
 		return 0;
 
-	memset(&fl1, 0, sizeof(fl1));
-	memset(&fl2, 0, sizeof(fl2));
-
 	switch (family) {
 	case AF_INET: {
+		struct flowi4 fl1, fl2;
 		struct rtable *rt1, *rt2;
 
-		fl1.fl4_dst = src->ip;
-		fl2.fl4_dst = dst->ip;
-		if (!afinfo->route((struct dst_entry **)&rt1, &fl1)) {
-			if (!afinfo->route((struct dst_entry **)&rt2, &fl2)) {
+		memset(&fl1, 0, sizeof(fl1));
+		fl1.daddr = src->ip;
+
+		memset(&fl2, 0, sizeof(fl2));
+		fl2.daddr = dst->ip;
+		if (!afinfo->route((struct dst_entry **)&rt1,
+				   flowi4_to_flowi(&fl1))) {
+			if (!afinfo->route((struct dst_entry **)&rt2,
+					   flowi4_to_flowi(&fl2))) {
 				if (rt1->rt_gateway == rt2->rt_gateway &&
 				    rt1->dst.dev  == rt2->dst.dev)
 					ret = 1;
@@ -745,12 +747,18 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 #if defined(CONFIG_NF_CONNTRACK_IPV6) || \
     defined(CONFIG_NF_CONNTRACK_IPV6_MODULE)
 	case AF_INET6: {
+		struct flowi6 fl1, fl2;
 		struct rt6_info *rt1, *rt2;
 
-		memcpy(&fl1.fl6_dst, src, sizeof(fl1.fl6_dst));
-		memcpy(&fl2.fl6_dst, dst, sizeof(fl2.fl6_dst));
-		if (!afinfo->route((struct dst_entry **)&rt1, &fl1)) {
-			if (!afinfo->route((struct dst_entry **)&rt2, &fl2)) {
+		memset(&fl1, 0, sizeof(fl1));
+		ipv6_addr_copy(&fl1.daddr, &src->in6);
+
+		memset(&fl2, 0, sizeof(fl2));
+		ipv6_addr_copy(&fl2.daddr, &dst->in6);
+		if (!afinfo->route((struct dst_entry **)&rt1,
+				   flowi6_to_flowi(&fl1))) {
+			if (!afinfo->route((struct dst_entry **)&rt2,
+					   flowi6_to_flowi(&fl2))) {
 				if (!memcmp(&rt1->rt6i_gateway, &rt2->rt6i_gateway,
 					    sizeof(rt1->rt6i_gateway)) &&
 				    rt1->dst.dev == rt2->dst.dev)
-- 
1.7.4.1

