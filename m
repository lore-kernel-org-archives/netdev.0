From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: use TOS marks from sockets for routing decision
Date: Sat, 11 Jun 2016 20:08:19 +0200
Message-ID: <1465668499-11740-1-git-send-email-hannes@stressinduktion.org>
Cc: liam.mcbirnie@boeing.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:33744 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751328AbcFKSIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 14:08:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In IPv6 the ToS values are part of the flowlabel in flowi6 and get
extracted during fib rule lookup, but we forgot to correctly initialize
the flowlabel before the routing lookup.

Reported-by: <liam.mcbirnie@boeing.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/icmp.c     | 4 +++-
 net/ipv6/ping.c     | 4 +++-
 net/ipv6/raw.c      | 8 +++++---
 net/ipv6/route.c    | 2 ++
 net/ipv6/udp.c      | 8 +++++---
 net/l2tp/l2tp_ip6.c | 8 +++++---
 6 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 4527285fcaa2c2..40454bfb534ed0 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -502,12 +502,14 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	else if (!fl6.flowi6_oif)
 		fl6.flowi6_oif = np->ucast_oif;
 
+	ipc6.tclass = np->tclass;
+	fl6.flowlabel = ip6_make_flowinfo(ipc6.tclass, fl6.flowlabel);
+
 	dst = icmpv6_route_lookup(net, skb, sk, &fl6);
 	if (IS_ERR(dst))
 		goto out;
 
 	ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
-	ipc6.tclass = np->tclass;
 	ipc6.dontfrag = np->dontfrag;
 	ipc6.opt = NULL;
 
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 3ee3e444a66bef..fed40d1ec29b1f 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -116,6 +116,9 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	else if (!fl6.flowi6_oif)
 		fl6.flowi6_oif = np->ucast_oif;
 
+	ipc6.tclass = np->tclass;
+	fl6.flowlabel = ip6_make_flowinfo(ipc6.tclass, fl6.flowlabel);
+
 	dst = ip6_sk_dst_lookup_flow(sk, &fl6,  daddr);
 	if (IS_ERR(dst))
 		return PTR_ERR(dst);
@@ -140,7 +143,6 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	pfh.family = AF_INET6;
 
 	ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
-	ipc6.tclass = np->tclass;
 	ipc6.dontfrag = np->dontfrag;
 	ipc6.opt = NULL;
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 896350df642361..590dd1f7746fca 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -878,6 +878,11 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (inet->hdrincl)
 		fl6.flowi6_flags |= FLOWI_FLAG_KNOWN_NH;
 
+	if (ipc6.tclass < 0)
+		ipc6.tclass = np->tclass;
+
+	fl6.flowlabel = ip6_make_flowinfo(ipc6.tclass, fl6.flowlabel);
+
 	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
@@ -886,9 +891,6 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (ipc6.hlimit < 0)
 		ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
-	if (ipc6.tclass < 0)
-		ipc6.tclass = np->tclass;
-
 	if (ipc6.dontfrag < 0)
 		ipc6.dontfrag = np->dontfrag;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 969913da494fdf..c6ae6f9b5fe31c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3306,6 +3306,8 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 
 	err = -EINVAL;
 	memset(&fl6, 0, sizeof(fl6));
+	rtm = nlmsg_data(nlh);
+	fl6.flowlabel = ip6_make_flowinfo(rtm->rtm_tos, 0);
 
 	if (tb[RTA_SRC]) {
 		if (nla_len(tb[RTA_SRC]) < sizeof(struct in6_addr))
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f421c9f23c5bef..4bb5c13777f1ba 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1246,6 +1246,11 @@ do_udp_sendmsg:
 
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
+	if (ipc6.tclass < 0)
+		ipc6.tclass = np->tclass;
+
+	fl6.flowlabel = ip6_make_flowinfo(ipc6.tclass, fl6.flowlabel);
+
 	dst = ip6_sk_dst_lookup_flow(sk, &fl6, final_p);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
@@ -1256,9 +1261,6 @@ do_udp_sendmsg:
 	if (ipc6.hlimit < 0)
 		ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
-	if (ipc6.tclass < 0)
-		ipc6.tclass = np->tclass;
-
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
 back_from_confirm:
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 6c54e03fe9c175..ea2ae6664cc8d6 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -611,6 +611,11 @@ static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
+	if (ipc6.tclass < 0)
+		ipc6.tclass = np->tclass;
+
+	fl6.flowlabel = ip6_make_flowinfo(ipc6.tclass, fl6.flowlabel);
+
 	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
@@ -620,9 +625,6 @@ static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (ipc6.hlimit < 0)
 		ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
-	if (ipc6.tclass < 0)
-		ipc6.tclass = np->tclass;
-
 	if (ipc6.dontfrag < 0)
 		ipc6.dontfrag = np->dontfrag;
 
-- 
2.5.5
