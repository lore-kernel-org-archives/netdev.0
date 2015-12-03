From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: sctp: add rcu protection around np->opt
Date: Wed, 02 Dec 2015 21:48:14 -0800
Message-ID: <1449121694.6379.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448730683.24696.94.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448731434.24696.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448854677.24696.117.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151202.233821.139368757119113563.davem@davemloft.net>
	 <1449120948.6379.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33328 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbbLCFsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 00:48:16 -0500
Received: by pabfh17 with SMTP id fh17so63246856pab.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 21:48:16 -0800 (PST)
In-Reply-To: <1449120948.6379.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This patch completes the work I did in commit 45f6fad84cc3
("ipv6: add complete rcu protection around np->opt"), as I missed
sctp part.

This simply makes sure np->opt is used with proper RCU locking
and accessors.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sctp/ipv6.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index e917d27328ea..acb45b8c2a9d 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -209,6 +209,7 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 	struct sock *sk = skb->sk;
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flowi6 *fl6 = &transport->fl.u.ip6;
+	int res;
 
 	pr_debug("%s: skb:%p, len:%d, src:%pI6 dst:%pI6\n", __func__, skb,
 		 skb->len, &fl6->saddr, &fl6->daddr);
@@ -220,7 +221,10 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 
 	SCTP_INC_STATS(sock_net(sk), SCTP_MIB_OUTSCTPPACKS);
 
-	return ip6_xmit(sk, skb, fl6, np->opt, np->tclass);
+	rcu_read_lock();
+	res = ip6_xmit(sk, skb, fl6, rcu_dereference(np->opt), np->tclass);
+	rcu_read_unlock();
+	return res;
 }
 
 /* Returns the dst cache entry for the given source and destination ip
@@ -262,7 +266,10 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		pr_debug("src=%pI6 - ", &fl6->saddr);
 	}
 
-	final_p = fl6_update_dst(fl6, np->opt, &final);
+	rcu_read_lock();
+	final_p = fl6_update_dst(fl6, rcu_dereference(np->opt), &final);
+	rcu_read_unlock();
+
 	dst = ip6_dst_lookup_flow(sk, fl6, final_p);
 	if (!asoc || saddr)
 		goto out;
@@ -321,7 +328,7 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	if (baddr) {
 		fl6->saddr = baddr->v6.sin6_addr;
 		fl6->fl6_sport = baddr->v6.sin6_port;
-		final_p = fl6_update_dst(fl6, np->opt, &final);
+		final_p = fl6_update_dst(fl6, rcu_dereference(np->opt), &final);
 		dst = ip6_dst_lookup_flow(sk, fl6, final_p);
 	}
 
