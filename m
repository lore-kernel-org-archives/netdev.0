From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 6/6] tcp_metrics: Use a single hash table for all network namespaces.
Date: Mon, 09 Mar 2015 13:31:26 -0500
Message-ID: <8761aayqdd.fsf_-_@x220.int.ebiederm.org>
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
Received: from out03.mta.xmission.com ([166.70.13.233]:49847 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbbCISfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:35:07 -0400
In-Reply-To: <87h9tu114z.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Mon, 09 Mar 2015 13:22:52 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Now that all of the operations are safe on a single hash table
accross network namespaces, allocate a single global hash table
and update the code to use it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/netns/ipv4.h |  2 --
 net/ipv4/tcp_metrics.c   | 63 ++++++++++++++++++++++++++++--------------------
 2 files changed, 37 insertions(+), 28 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 8f3a1a1a5a94..614a49be68a9 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -54,8 +54,6 @@ struct netns_ipv4 {
 	struct sock		*mc_autojoin_sk;
 
 	struct inet_peer_base	*peers;
-	struct tcpm_hash_bucket	*tcp_metrics_hash;
-	unsigned int		tcp_metrics_hash_log;
 	struct sock  * __percpu	*tcp_sk;
 	struct netns_frags	frags;
 #ifdef CONFIG_NETFILTER
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index b85e0c79895f..785c4ab51fe9 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -92,6 +92,9 @@ struct tcpm_hash_bucket {
 	struct tcp_metrics_block __rcu	*chain;
 };
 
+static struct tcpm_hash_bucket	*tcp_metrics_hash;
+static unsigned int		tcp_metrics_hash_log;
+
 static DEFINE_SPINLOCK(tcp_metrics_lock);
 
 static void tcpm_suck_dst(struct tcp_metrics_block *tm,
@@ -172,7 +175,7 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 	if (unlikely(reclaim)) {
 		struct tcp_metrics_block *oldest;
 
-		oldest = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain);
+		oldest = rcu_dereference(tcp_metrics_hash[hash].chain);
 		for (tm = rcu_dereference(oldest->tcpm_next); tm;
 		     tm = rcu_dereference(tm->tcpm_next)) {
 			if (time_before(tm->tcpm_stamp, oldest->tcpm_stamp))
@@ -191,8 +194,8 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 	tcpm_suck_dst(tm, dst, true);
 
 	if (likely(!reclaim)) {
-		tm->tcpm_next = net->ipv4.tcp_metrics_hash[hash].chain;
-		rcu_assign_pointer(net->ipv4.tcp_metrics_hash[hash].chain, tm);
+		tm->tcpm_next = tcp_metrics_hash[hash].chain;
+		rcu_assign_pointer(tcp_metrics_hash[hash].chain, tm);
 	}
 
 out_unlock:
@@ -216,7 +219,7 @@ static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *s
 	struct tcp_metrics_block *tm;
 	int depth = 0;
 
-	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
+	for (tm = rcu_dereference(tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
 		if ((tm->tcpm_net == net) &&
 		    addr_same(&tm->tcpm_saddr, saddr) &&
@@ -256,9 +259,9 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 
 	net = dev_net(dst->dev);
 	hash ^= net_hash_mix(net);
-	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
+	hash = hash_32(hash, tcp_metrics_hash_log);
 
-	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
+	for (tm = rcu_dereference(tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
 		if ((tm->tcpm_net == net) &&
 		    addr_same(&tm->tcpm_saddr, &saddr) &&
@@ -305,9 +308,9 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 
 	net = twsk_net(tw);
 	hash ^= net_hash_mix(net);
-	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
+	hash = hash_32(hash, tcp_metrics_hash_log);
 
-	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
+	for (tm = rcu_dereference(tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
 		if ((tm->tcpm_net == net) &&
 		    addr_same(&tm->tcpm_saddr, &saddr) &&
@@ -355,7 +358,7 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 
 	net = dev_net(dst->dev);
 	hash ^= net_hash_mix(net);
-	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
+	hash = hash_32(hash, tcp_metrics_hash_log);
 
 	tm = __tcp_get_metrics(&saddr, &daddr, net, hash);
 	if (tm == TCP_METRICS_RECLAIM_PTR)
@@ -906,13 +909,13 @@ static int tcp_metrics_nl_dump(struct sk_buff *skb,
 			       struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-	unsigned int max_rows = 1U << net->ipv4.tcp_metrics_hash_log;
+	unsigned int max_rows = 1U << tcp_metrics_hash_log;
 	unsigned int row, s_row = cb->args[0];
 	int s_col = cb->args[1], col = s_col;
 
 	for (row = s_row; row < max_rows; row++, s_col = 0) {
 		struct tcp_metrics_block *tm;
-		struct tcpm_hash_bucket *hb = net->ipv4.tcp_metrics_hash + row;
+		struct tcpm_hash_bucket *hb = tcp_metrics_hash + row;
 
 		rcu_read_lock();
 		for (col = 0, tm = rcu_dereference(hb->chain); tm;
@@ -1005,10 +1008,10 @@ static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto nla_put_failure;
 
 	hash ^= net_hash_mix(net);
-	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
+	hash = hash_32(hash, tcp_metrics_hash_log);
 	ret = -ESRCH;
 	rcu_read_lock();
-	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
+	for (tm = rcu_dereference(tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
 		if ((tm->tcpm_net == net) &&
 		    addr_same(&tm->tcpm_daddr, &daddr) &&
@@ -1040,8 +1043,8 @@ out_free:
 
 static void tcp_metrics_flush_all(struct net *net)
 {
-	unsigned int max_rows = 1U << net->ipv4.tcp_metrics_hash_log;
-	struct tcpm_hash_bucket *hb = net->ipv4.tcp_metrics_hash;
+	unsigned int max_rows = 1U << tcp_metrics_hash_log;
+	struct tcpm_hash_bucket *hb = tcp_metrics_hash;
 	struct tcp_metrics_block *tm;
 	unsigned int row;
 
@@ -1085,8 +1088,8 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		src = false;
 
 	hash ^= net_hash_mix(net);
-	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
-	hb = net->ipv4.tcp_metrics_hash + hash;
+	hash = hash_32(hash, tcp_metrics_hash_log);
+	hb = tcp_metrics_hash + hash;
 	pp = &hb->chain;
 	spin_lock_bh(&tcp_metrics_lock);
 	for (tm = deref_locked_genl(*pp); tm; tm = deref_locked_genl(*pp)) {
@@ -1142,6 +1145,9 @@ static int __net_init tcp_net_metrics_init(struct net *net)
 	size_t size;
 	unsigned int slots;
 
+	if (net != &init_net)
+		return 0;
+
 	slots = tcpmhash_entries;
 	if (!slots) {
 		if (totalram_pages >= 128 * 1024)
@@ -1150,14 +1156,14 @@ static int __net_init tcp_net_metrics_init(struct net *net)
 			slots = 8 * 1024;
 	}
 
-	net->ipv4.tcp_metrics_hash_log = order_base_2(slots);
-	size = sizeof(struct tcpm_hash_bucket) << net->ipv4.tcp_metrics_hash_log;
+	tcp_metrics_hash_log = order_base_2(slots);
+	size = sizeof(struct tcpm_hash_bucket) << tcp_metrics_hash_log;
 
-	net->ipv4.tcp_metrics_hash = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
-	if (!net->ipv4.tcp_metrics_hash)
-		net->ipv4.tcp_metrics_hash = vzalloc(size);
+	tcp_metrics_hash = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
+	if (!tcp_metrics_hash)
+		tcp_metrics_hash = vzalloc(size);
 
-	if (!net->ipv4.tcp_metrics_hash)
+	if (!tcp_metrics_hash)
 		return -ENOMEM;
 
 	return 0;
@@ -1167,17 +1173,22 @@ static void __net_exit tcp_net_metrics_exit(struct net *net)
 {
 	unsigned int i;
 
-	for (i = 0; i < (1U << net->ipv4.tcp_metrics_hash_log) ; i++) {
+	if (net != &init_net) {
+		tcp_metrics_flush_all(net);
+		return;
+	}
+
+	for (i = 0; i < (1U << tcp_metrics_hash_log) ; i++) {
 		struct tcp_metrics_block *tm, *next;
 
-		tm = rcu_dereference_protected(net->ipv4.tcp_metrics_hash[i].chain, 1);
+		tm = rcu_dereference_protected(tcp_metrics_hash[i].chain, 1);
 		while (tm) {
 			next = rcu_dereference_protected(tm->tcpm_next, 1);
 			kfree(tm);
 			tm = next;
 		}
 	}
-	kvfree(net->ipv4.tcp_metrics_hash);
+	kvfree(tcp_metrics_hash);
 }
 
 static __net_initdata struct pernet_operations tcp_net_metrics_ops = {
-- 
2.2.1
