From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next] sctp: sctp_transport_dst_check should check if transport pmtu is dst mtu
Date: Fri, 17 Feb 2017 16:41:45 +0800
Message-ID: <7cbbbf479fddc8b516f87bc6258e775634e84dd6.1487320905.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34011 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754805AbdBQIlw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 03:41:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when sending a packet, sctp_transport_dst_check will check if dst
is obsolete by calling ipv4/ip6_dst_check. But they return obsolete
only when adding a new cache, after that when the cache's pmtu is
updated again, it will not trigger transport->dst/pmtu's update.

It can be reproduced by reducing route's pmtu twice. At the 1st time
client will add a new cache, and transport->pathmtu gets updated as
sctp_transport_dst_check finds it's obsolete. But at the 2nd time,
cache's mtu is updated, sctp client will never send out any packet,
because transport->pmtu has no chance to update.

This patch is to fix this by also checking if transport pmtu is dst
mtu in sctp_transport_dst_check, so that transport->pmtu can be
updated on time.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 6dfc553..1f71ee5 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -596,7 +596,9 @@ static inline void sctp_v4_map_v6(union sctp_addr *addr)
  */
 static inline struct dst_entry *sctp_transport_dst_check(struct sctp_transport *t)
 {
-	if (t->dst && !dst_check(t->dst, t->dst_cookie))
+	if (t->dst && (!dst_check(t->dst, t->dst_cookie) ||
+		       t->pathmtu != max_t(size_t, SCTP_TRUNC4(dst_mtu(t->dst)),
+					   SCTP_DEFAULT_MINSEGMENT)))
 		sctp_transport_dst_release(t);
 
 	return t->dst;
-- 
2.1.0
