From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] tcp: Remove use of inet6_sk and add IPv6 checks to tracepoint
Date: Wed, 18 Oct 2017 08:17:29 -0700
Message-ID: <1508339849-19527-1-git-send-email-dsahern@gmail.com>
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        songliubraving@fb.com, davem@davemloft.net,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:52127 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750748AbdJRPRg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:17:36 -0400
Received: by mail-pg0-f66.google.com with SMTP id p9so4517939pgc.8
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 08:17:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

386fd5da401d ("tcp: Check daddr_cache before use in tracepoint") was the
second version of the tracepoint fixup patch. This patch is the delta
between v2 and v3.  Specifically, remove the use of inet6_sk and check
sk_family as requested by Eric and add IS_ENABLED(CONFIG_IPV6) around
the use of sk_v6_rcv_saddr and sk_v6_daddr as done in sock_common (noted
by Cong).

Signed-off-by: David Ahern <dsahern@gmail.com>
---
Eric/Congi/Song: I did not keep your Acked/Reviewed/Tested-by since it is
a different patch. End result is the exact same as v3 patch sent yesterday.

 include/trace/events/tcp.h | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
index f51c130f1e0f..c3220d914475 100644
--- a/include/trace/events/tcp.h
+++ b/include/trace/events/tcp.h
@@ -43,13 +43,15 @@ TRACE_EVENT(tcp_retransmit_skb,
 		p32 = (__be32 *) __entry->daddr;
 		*p32 =  inet->inet_daddr;
 
-		/* IPv6 socket ? */
-		if (inet6_sk(sk)) {
+#if IS_ENABLED(CONFIG_IPV6)
+		if (sk->sk_family == AF_INET6) {
 			pin6 = (struct in6_addr *)__entry->saddr_v6;
 			*pin6 = sk->sk_v6_rcv_saddr;
 			pin6 = (struct in6_addr *)__entry->daddr_v6;
 			*pin6 = sk->sk_v6_daddr;
-		} else {
+		} else
+#endif
+		{
 			pin6 = (struct in6_addr *)__entry->saddr_v6;
 			ipv6_addr_set_v4mapped(inet->inet_saddr, pin6);
 			pin6 = (struct in6_addr *)__entry->daddr_v6;
-- 
2.1.4
