From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp_metrics: fix wrong lockdep annotations
Date: Mon, 16 Mar 2015 06:58:49 -0700
Message-ID: <1426514329.11398.204.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150316113542.GA27127@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Andrew Vagin <avagin@parallels.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34618 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbbCPN6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 09:58:52 -0400
Received: by igbue6 with SMTP id ue6so33054906igb.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 06:58:51 -0700 (PDT)
In-Reply-To: <20150316113542.GA27127@paralelels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Changes in tcp_metric hash table are protected by tcp_metrics_lock
only, not by genl_mutex

Reported-by: Andrew Vagin <avagin@parallels.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 098a697b497e ("tcp_metrics: Use a single hash table for all network namespaces.")
---
 net/ipv4/tcp_metrics.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 366728cbee4a692394696f13e6aacf0331990eed..c7d34db9cfc99d85f6d21cf5bd7e718e80e404e7 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1040,11 +1040,8 @@ out_free:
 	return ret;
 }
 
-#define deref_locked_genl(p)	\
-	rcu_dereference_protected(p, lockdep_genl_is_held() && \
-				     lockdep_is_held(&tcp_metrics_lock))
-
-#define deref_genl(p)	rcu_dereference_protected(p, lockdep_genl_is_held())
+#define deref_locked(p)	\
+	rcu_dereference_protected(p, lockdep_is_held(&tcp_metrics_lock))
 
 static void tcp_metrics_flush_all(struct net *net)
 {
@@ -1057,8 +1054,7 @@ static void tcp_metrics_flush_all(struct net *net)
 		struct tcp_metrics_block __rcu **pp;
 		spin_lock_bh(&tcp_metrics_lock);
 		pp = &hb->chain;
-		for (tm = deref_locked_genl(*pp); tm;
-		     tm = deref_locked_genl(*pp)) {
+		for (tm = deref_locked(*pp); tm; tm = deref_locked(*pp)) {
 			if (net_eq(tm_net(tm), net)) {
 				*pp = tm->tcpm_next;
 				kfree_rcu(tm, rcu_head);
@@ -1097,7 +1093,7 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	hb = tcp_metrics_hash + hash;
 	pp = &hb->chain;
 	spin_lock_bh(&tcp_metrics_lock);
-	for (tm = deref_locked_genl(*pp); tm; tm = deref_locked_genl(*pp)) {
+	for (tm = deref_locked(*pp); tm; tm = deref_locked(*pp)) {
 		if (addr_same(&tm->tcpm_daddr, &daddr) &&
 		    (!src || addr_same(&tm->tcpm_saddr, &saddr)) &&
 		    net_eq(tm_net(tm), net)) {
