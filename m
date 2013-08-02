From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] sctp: Don't lookup dst if transport dst is still valid
Date: Fri, 2 Aug 2013 10:45:13 +0800
Message-ID: <1375411513-12551-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54592 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355Ab3HBCnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 22:43:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sctp sits on IPv6, sctp_transport_dst_check pass cookie as ZERO,
as a result ip6_dst_check always fail out. This behaviour makes
transport->dst useless, because every sctp_packet_transmit must look
for valid dst.

Add a dst_cookie into sctp_transport, and set the cookie whenever we
get new dst for sctp_transport. So dst validness could be checked
against it.

Since I have split genid for IPv4 and IPv6, also delete/add IPv6 address
will also bump IPv6 genid. So issues we discussed in:
http://marc.info/?l=linux-netdev&m=137404469219410&w=4
have all been sloved for this patch.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/sctp/sctp.h    |    2 +-
 include/net/sctp/structs.h |    1 +
 net/sctp/ipv6.c            |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 554cf88..cb28df9 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -613,7 +613,7 @@ static inline void sctp_v4_map_v6(union sctp_addr *addr)
  */
 static inline struct dst_entry *sctp_transport_dst_check(struct sctp_transport *t)
 {
-	if (t->dst && !dst_check(t->dst, 0)) {
+	if (t->dst && !dst_check(t->dst, t->dst_cookie)) {
 		dst_release(t->dst);
 		t->dst = NULL;
 	}
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 75c4c16..c0f4e29 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -946,6 +946,7 @@ struct sctp_transport {
 	__u64 hb_nonce;
 
 	struct rcu_head rcu;
+	u32 dst_cookie;
 };
 
 struct sctp_transport *sctp_transport_new(struct net *, const union sctp_addr *,
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 85d688f..5a9402e 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -351,7 +351,7 @@ out:
 
 		rt = (struct rt6_info *)dst;
 		t->dst = dst;
-
+		t->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
 		pr_debug("rt6_dst:%pI6 rt6_src:%pI6\n", &rt->rt6i_dst.addr,
 			 &fl6->saddr);
 	} else {
-- 
1.7.1
