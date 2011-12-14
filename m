From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet: remove rcu protection on tw_net
Date: Wed, 14 Dec 2011 15:58:33 +0100
Message-ID: <1323874713.2334.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63036 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755155Ab1LNO6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 09:58:38 -0500
Received: by eekc4 with SMTP id c4so879928eek.19
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 06:58:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b099ce2602d806 (net: Batch inet_twsk_purge) added rcu protection
on tw_net for no obvious reason.

struct net are refcounted anyway since timewait sockets escape from rcu
protected sections. tw_net stay valid for the whole timwait lifetime.

This also removes a lot of sparse errors.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/inet_timewait_sock.h |   12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index e8c25b9..ba52c83 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -218,20 +218,12 @@ extern void inet_twsk_purge(struct inet_hashinfo *hashinfo,
 static inline
 struct net *twsk_net(const struct inet_timewait_sock *twsk)
 {
-#ifdef CONFIG_NET_NS
-	return rcu_dereference_raw(twsk->tw_net); /* protected by locking, */
-						  /* reference counting, */
-						  /* initialization, or RCU. */
-#else
-	return &init_net;
-#endif
+	return read_pnet(&twsk->tw_net);
 }
 
 static inline
 void twsk_net_set(struct inet_timewait_sock *twsk, struct net *net)
 {
-#ifdef CONFIG_NET_NS
-	rcu_assign_pointer(twsk->tw_net, net);
-#endif
+	write_pnet(&twsk->tw_net, net);
 }
 #endif	/* _INET_TIMEWAIT_SOCK_ */
