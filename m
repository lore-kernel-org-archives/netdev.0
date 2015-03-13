From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 2/6] tcp_metrics: Mix the network namespace into the hash function.
Date: Fri, 13 Mar 2015 00:05:24 -0500
Message-ID: <87oanxxzaj.fsf_-_@x220.int.ebiederm.org>
References: <871tlxtbhd.fsf_-_@x220.int.ebiederm.org>
	<CANn89iJ2auNoChr3FuFh-AGaPaw5_wwqfjZrtup1+xu6reVHMA@mail.gmail.com>
	<87d25hrv9m.fsf@x220.int.ebiederm.org>
	<20150219.144929.1003473344851168804.davem@davemloft.net>
	<87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
	<87y4n1xzco.fsf_-_@x220.int.ebiederm.org>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:38571 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbbCMFJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 01:09:06 -0400
In-Reply-To: <87y4n1xzco.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 13 Mar 2015 00:04:07 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In preparation for using one hash table for all network namespaces
mix the network namespace into the hash value.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/tcp_metrics.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 4206b14d956d..fbb42f44501e 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -252,6 +252,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 	}
 
 	net = dev_net(dst->dev);
+	hash ^= net_hash_mix(net);
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
@@ -299,6 +300,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 		return NULL;
 
 	net = twsk_net(tw);
+	hash ^= net_hash_mix(net);
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
@@ -347,6 +349,7 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 		return NULL;
 
 	net = dev_net(dst->dev);
+	hash ^= net_hash_mix(net);
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 
 	tm = __tcp_get_metrics(&saddr, &daddr, net, hash);
@@ -994,6 +997,7 @@ static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	if (!reply)
 		goto nla_put_failure;
 
+	hash ^= net_hash_mix(net);
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 	ret = -ESRCH;
 	rcu_read_lock();
@@ -1070,6 +1074,7 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	if (ret < 0)
 		src = false;
 
+	hash ^= net_hash_mix(net);
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 	hb = net->ipv4.tcp_metrics_hash + hash;
 	pp = &hb->chain;
-- 
2.2.1
