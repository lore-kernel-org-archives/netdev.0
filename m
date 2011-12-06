From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 7/11] inet_diag: Switch the _get_exact to work with new header
Date: Tue, 06 Dec 2011 21:58:39 +0400
Message-ID: <4EDE57CF.2080503@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:34158 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442Ab1LFR6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:58:45 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make inet_diag_get_exact work with given header instead of calculating
one from the nl message.

The SOCK_DIAG_BY_FAMILY just passes skb's one through, the compat code
converts the old header to new one.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/inet_diag.c |   29 ++++++++++++++++++++++-------
 1 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 9a6a6de..6b34071 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -261,16 +261,16 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 }
 
 static int inet_diag_get_exact(struct sk_buff *in_skb,
-			       const struct nlmsghdr *nlh)
+			       const struct nlmsghdr *nlh,
+			       struct inet_diag_req *req)
 {
 	int err;
 	struct sock *sk;
-	struct inet_diag_req_compat *req = NLMSG_DATA(nlh);
 	struct sk_buff *rep;
 	struct inet_hashinfo *hashinfo;
 	const struct inet_diag_handler *handler;
 
-	handler = inet_diag_lock_handler(inet_diag_type2proto(nlh->nlmsg_type));
+	handler = inet_diag_lock_handler(req->sdiag_protocol);
 	if (IS_ERR(handler)) {
 		err = PTR_ERR(handler);
 		goto unlock;
@@ -279,13 +279,13 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 	hashinfo = handler->idiag_hashinfo;
 	err = -EINVAL;
 
-	if (req->idiag_family == AF_INET) {
+	if (req->sdiag_family == AF_INET) {
 		sk = inet_lookup(&init_net, hashinfo, req->id.idiag_dst[0],
 				 req->id.idiag_dport, req->id.idiag_src[0],
 				 req->id.idiag_sport, req->id.idiag_if);
 	}
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-	else if (req->idiag_family == AF_INET6) {
+	else if (req->sdiag_family == AF_INET6) {
 		sk = inet6_lookup(&init_net, hashinfo,
 				  (struct in6_addr *)req->id.idiag_dst,
 				  req->id.idiag_dport,
@@ -861,6 +861,21 @@ unlock:
 	return skb->len;
 }
 
+static int inet_diag_get_exact_compat(struct sk_buff *in_skb,
+			       const struct nlmsghdr *nlh)
+{
+	struct inet_diag_req_compat *rc = NLMSG_DATA(nlh);
+	struct inet_diag_req req;
+
+	req.sdiag_family = rc->idiag_family;
+	req.sdiag_protocol = inet_diag_type2proto(nlh->nlmsg_type);
+	req.idiag_ext = rc->idiag_ext;
+	req.idiag_states = rc->idiag_states;
+	req.id = rc->id;
+
+	return inet_diag_get_exact(in_skb, nlh, &req);
+}
+
 static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int hdrlen = sizeof(struct inet_diag_req_compat);
@@ -885,7 +900,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 					  inet_diag_dump, NULL, 0);
 	}
 
-	return inet_diag_get_exact(skb, nlh);
+	return inet_diag_get_exact_compat(skb, nlh);
 }
 
 static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
@@ -899,7 +914,7 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		return -EAFNOSUPPORT;
 	}
 
-	return -EAFNOSUPPORT;
+	return inet_diag_get_exact(skb, h, (struct inet_diag_req *)NLMSG_DATA(h));
 }
 
 static struct sock_diag_handler inet_diag_handler = {
-- 
1.5.5.6
