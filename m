From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 3/6] tcp_metrics: Add a field tcpm_net and verify it matches on lookup
Date: Mon, 09 Mar 2015 13:29:14 -0500
Message-ID: <87oao2yqh1.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:37595 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbbCIScy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:32:54 -0400
In-Reply-To: <87h9tu114z.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Mon, 09 Mar 2015 13:22:52 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In preparation for using one tcp metrics hash table for all network
namespaces add a field tcpm_net to struct tcp_metrics_block, and verify
that field on all hash table lookups.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/tcp_metrics.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 70196c3c16a1..4ec02d6cab5b 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -40,6 +40,7 @@ struct tcp_fastopen_metrics {
 
 struct tcp_metrics_block {
 	struct tcp_metrics_block __rcu	*tcpm_next;
+	struct net			*tcpm_net;
 	struct inetpeer_addr		tcpm_saddr;
 	struct inetpeer_addr		tcpm_daddr;
 	unsigned long			tcpm_stamp;
@@ -183,6 +184,7 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 		if (!tm)
 			goto out_unlock;
 	}
+	tm->tcpm_net = net;
 	tm->tcpm_saddr = *saddr;
 	tm->tcpm_daddr = *daddr;
 
@@ -216,7 +218,8 @@ static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *s
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_saddr, saddr) &&
+		if ((tm->tcpm_net == net) &&
+		    addr_same(&tm->tcpm_saddr, saddr) &&
 		    addr_same(&tm->tcpm_daddr, daddr))
 			break;
 		depth++;
@@ -257,7 +260,8 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_saddr, &saddr) &&
+		if ((tm->tcpm_net == net) &&
+		    addr_same(&tm->tcpm_saddr, &saddr) &&
 		    addr_same(&tm->tcpm_daddr, &daddr))
 			break;
 	}
@@ -305,7 +309,8 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_saddr, &saddr) &&
+		if ((tm->tcpm_net == net) &&
+		    addr_same(&tm->tcpm_saddr, &saddr) &&
 		    addr_same(&tm->tcpm_daddr, &daddr))
 			break;
 	}
@@ -912,6 +917,8 @@ static int tcp_metrics_nl_dump(struct sk_buff *skb,
 		rcu_read_lock();
 		for (col = 0, tm = rcu_dereference(hb->chain); tm;
 		     tm = rcu_dereference(tm->tcpm_next), col++) {
+			if (tm->tcpm_net != net)
+				continue;
 			if (col < s_col)
 				continue;
 			if (tcp_metrics_dump_info(skb, cb, tm) < 0) {
@@ -1003,7 +1010,8 @@ static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	rcu_read_lock();
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_daddr, &daddr) &&
+		if ((tm->tcpm_net == net) &&
+		    addr_same(&tm->tcpm_daddr, &daddr) &&
 		    (!src || addr_same(&tm->tcpm_saddr, &saddr))) {
 			ret = tcp_metrics_fill_info(msg, tm);
 			break;
@@ -1080,7 +1088,8 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	pp = &hb->chain;
 	spin_lock_bh(&tcp_metrics_lock);
 	for (tm = deref_locked_genl(*pp); tm; tm = deref_locked_genl(*pp)) {
-		if (addr_same(&tm->tcpm_daddr, &daddr) &&
+		if ((tm->tcpm_net == net) &&
+		    addr_same(&tm->tcpm_daddr, &daddr) &&
 		    (!src || addr_same(&tm->tcpm_saddr, &saddr))) {
 			*pp = tm->tcpm_next;
 			kfree_rcu(tm, rcu_head);
-- 
2.2.1
