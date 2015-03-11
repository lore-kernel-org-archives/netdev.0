From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 5/8] tcp_metrics: Add a field tcpm_net and verify it matches on lookup
Date: Wed, 11 Mar 2015 11:40:56 -0500
Message-ID: <87385bfpwn.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com,
	Julian Anastasov <ja@ssi.bg>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42337 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbbCKQoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 12:44:37 -0400
In-Reply-To: <87vbi7fq92.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 11 Mar 2015 11:33:29 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In preparation for using one tcp metrics hash table for all network
namespaces add a field tcpm_net to struct tcp_metrics_block, and
verify that field on all hash table lookups.

Make the field tcpm_net of type possible_net_t so it takes no space
when network namespaces are disabled.

Further add a function tm_net to read that field so we can be
efficient when network namespaces are disabled and concise
the rest of the time.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/tcp_metrics.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index fbb42f44501e..461c3d2e1ca4 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -40,6 +40,7 @@ struct tcp_fastopen_metrics {
 
 struct tcp_metrics_block {
 	struct tcp_metrics_block __rcu	*tcpm_next;
+	possible_net_t			tcpm_net;
 	struct inetpeer_addr		tcpm_saddr;
 	struct inetpeer_addr		tcpm_daddr;
 	unsigned long			tcpm_stamp;
@@ -52,6 +53,11 @@ struct tcp_metrics_block {
 	struct rcu_head			rcu_head;
 };
 
+static inline struct net *tm_net(struct tcp_metrics_block *tm)
+{
+	return read_pnet(&tm->tcpm_net);
+}
+
 static bool tcp_metric_locked(struct tcp_metrics_block *tm,
 			      enum tcp_metric_index idx)
 {
@@ -183,6 +189,7 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 		if (!tm)
 			goto out_unlock;
 	}
+	write_pnet(&tm->tcpm_net, net);
 	tm->tcpm_saddr = *saddr;
 	tm->tcpm_daddr = *daddr;
 
@@ -217,7 +224,8 @@ static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *s
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
 		if (addr_same(&tm->tcpm_saddr, saddr) &&
-		    addr_same(&tm->tcpm_daddr, daddr))
+		    addr_same(&tm->tcpm_daddr, daddr) &&
+		    net_eq(tm_net(tm), net))
 			break;
 		depth++;
 	}
@@ -258,7 +266,8 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
 		if (addr_same(&tm->tcpm_saddr, &saddr) &&
-		    addr_same(&tm->tcpm_daddr, &daddr))
+		    addr_same(&tm->tcpm_daddr, &daddr) &&
+		    net_eq(tm_net(tm), net))
 			break;
 	}
 	tcpm_check_stamp(tm, dst);
@@ -306,7 +315,8 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
 		if (addr_same(&tm->tcpm_saddr, &saddr) &&
-		    addr_same(&tm->tcpm_daddr, &daddr))
+		    addr_same(&tm->tcpm_daddr, &daddr) &&
+		    net_eq(tm_net(tm), net))
 			break;
 	}
 	return tm;
@@ -912,6 +922,8 @@ static int tcp_metrics_nl_dump(struct sk_buff *skb,
 		rcu_read_lock();
 		for (col = 0, tm = rcu_dereference(hb->chain); tm;
 		     tm = rcu_dereference(tm->tcpm_next), col++) {
+			if (!net_eq(tm_net(tm), net))
+				continue;
 			if (col < s_col)
 				continue;
 			if (tcp_metrics_dump_info(skb, cb, tm) < 0) {
@@ -1004,7 +1016,8 @@ static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
 		if (addr_same(&tm->tcpm_daddr, &daddr) &&
-		    (!src || addr_same(&tm->tcpm_saddr, &saddr))) {
+		    (!src || addr_same(&tm->tcpm_saddr, &saddr)) &&
+		    net_eq(tm_net(tm), net)) {
 			ret = tcp_metrics_fill_info(msg, tm);
 			break;
 		}
@@ -1081,7 +1094,8 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	spin_lock_bh(&tcp_metrics_lock);
 	for (tm = deref_locked_genl(*pp); tm; tm = deref_locked_genl(*pp)) {
 		if (addr_same(&tm->tcpm_daddr, &daddr) &&
-		    (!src || addr_same(&tm->tcpm_saddr, &saddr))) {
+		    (!src || addr_same(&tm->tcpm_saddr, &saddr)) &&
+		    net_eq(tm_net(tm), net)) {
 			*pp = tm->tcpm_next;
 			kfree_rcu(tm, rcu_head);
 			found = true;
-- 
2.2.1
