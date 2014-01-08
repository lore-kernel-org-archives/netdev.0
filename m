From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next v2 4/5] tcp: metrics: Delete all entries matching a certain destination
Date: Wed,  8 Jan 2014 16:05:58 +0100
Message-ID: <1389193559-16756-5-git-send-email-christoph.paasch@uclouvain.be>
References: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:62783 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756086AbaAHPGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 10:06:20 -0500
Received: by mail-wi0-f181.google.com with SMTP id hq4so2192842wib.8
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 07:06:19 -0800 (PST)
In-Reply-To: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we now can have multiple entries per destination-IP, the "ip
tcp_metrics delete address ADDRESS" command deletes all of them.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_metrics.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 199659f7a871..e150f264c8e2 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -982,7 +982,7 @@ static int tcp_metrics_flush_all(struct net *net)
 static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 {
 	struct tcpm_hash_bucket *hb;
-	struct tcp_metrics_block *tm;
+	struct tcp_metrics_block *tm, *tmlist = NULL;
 	struct tcp_metrics_block __rcu **pp;
 	struct inetpeer_addr daddr;
 	unsigned int hash;
@@ -999,17 +999,22 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	hb = net->ipv4.tcp_metrics_hash + hash;
 	pp = &hb->chain;
 	spin_lock_bh(&tcp_metrics_lock);
-	for (tm = deref_locked_genl(*pp); tm;
-	     pp = &tm->tcpm_next, tm = deref_locked_genl(*pp)) {
+	for (tm = deref_locked_genl(*pp); tm; tm = deref_locked_genl(*pp)) {
 		if (addr_same(&tm->tcpm_daddr, &daddr)) {
 			*pp = tm->tcpm_next;
-			break;
+			tm->tcpm_next = tmlist;
+			tmlist = tm;
+		} else {
+			pp = &tm->tcpm_next;
 		}
 	}
 	spin_unlock_bh(&tcp_metrics_lock);
-	if (!tm)
+	if (!tmlist)
 		return -ESRCH;
-	kfree_rcu(tm, rcu_head);
+	for (tm = tmlist; tm; tm = tmlist) {
+		tmlist = tm->tcpm_next;
+		kfree_rcu(tm, rcu_head);
+	}
 	return 0;
 }
 
-- 
1.8.3.2
