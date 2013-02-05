From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Disallow non-namespace aware protocols to register.
Date: Tue, 05 Feb 2013 14:43:02 -0500 (EST)
Message-ID: <20130205.144302.2065386693901345213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755421Ab3BETnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 14:43:03 -0500
Received: from localhost (cpe-66-108-118-205.nyc.res.rr.com [66.108.118.205])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id B1E9D58102B
	for <netdev@vger.kernel.org>; Tue,  5 Feb 2013 11:43:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All in-tree ipv4 protocol implementations are now namespace
aware.  Therefore all the run-time checks are superfluous.

Reject registry of any non-namespace aware ipv4 protocol.
Eventually we'll remove prot->netns_ok and this registry
time check as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/af_inet.c  | 19 -------------------
 net/ipv4/ip_input.c |  7 -------
 net/ipv4/protocol.c |  6 ++++++
 3 files changed, 6 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 49ddca3..1aec92b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -263,21 +263,6 @@ void build_ehash_secret(void)
 }
 EXPORT_SYMBOL(build_ehash_secret);
 
-static inline int inet_netns_ok(struct net *net, __u8 protocol)
-{
-	const struct net_protocol *ipprot;
-
-	if (net_eq(net, &init_net))
-		return 1;
-
-	ipprot = rcu_dereference(inet_protos[protocol]);
-	if (ipprot == NULL) {
-		/* raw IP is OK */
-		return 1;
-	}
-	return ipprot->netns_ok;
-}
-
 /*
  *	Create an inet socket.
  */
@@ -350,10 +335,6 @@ lookup_protocol:
 	    !ns_capable(net->user_ns, CAP_NET_RAW))
 		goto out_rcu_unlock;
 
-	err = -EAFNOSUPPORT;
-	if (!inet_netns_ok(net, protocol))
-		goto out_rcu_unlock;
-
 	sock->ops = answer->ops;
 	answer_prot = answer->prot;
 	answer_no_check = answer->no_check;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index f1395a6..87abd3e 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -208,13 +208,6 @@ static int ip_local_deliver_finish(struct sk_buff *skb)
 		if (ipprot != NULL) {
 			int ret;
 
-			if (!net_eq(net, &init_net) && !ipprot->netns_ok) {
-				net_info_ratelimited("%s: proto %d isn't netns-ready\n",
-						     __func__, protocol);
-				kfree_skb(skb);
-				goto out;
-			}
-
 			if (!ipprot->no_policy) {
 				if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 					kfree_skb(skb);
diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 0f9d09f..ce84846 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -37,6 +37,12 @@ const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_mostly;
 
 int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
+	if (!prot->netns_ok) {
+		pr_err("Protocol %u is not namespace aware, cannot register.\n",
+			protocol);
+		return -EINVAL;
+	}
+
 	return !cmpxchg((const struct net_protocol **)&inet_protos[protocol],
 			NULL, prot) ? 0 : -1;
 }
-- 
1.7.11.7
