From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH v3 3/3] l2tp: correctly handle ancillary data in the ip6 recv path
Date: Thu, 31 Jan 2013 11:02:26 +0000
Message-ID: <1359630146-8305-4-git-send-email-tparkin@katalix.com>
References: <1359630146-8305-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:41549 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695Ab3AaLCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 06:02:53 -0500
In-Reply-To: <1359630146-8305-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_ip6 is incorrectly using the IPv4-specific ip_cmsg_recv to handle
ancillary data.  This means that socket options such as IPV6_RECVPKTINFO are
not honoured in userspace.

Convert l2tp_ip6 to use the IPv6-specific handler.

Ref: net/ipv6/udp.c

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
Signed-off-by: Chris Elston <celston@katalix.com>
---
 net/l2tp/l2tp_ip6.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 2316947..8ee4a86 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -646,7 +646,7 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 			    struct msghdr *msg, size_t len, int noblock,
 			    int flags, int *addr_len)
 {
-	struct inet_sock *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_l2tpip6 *lsa = (struct sockaddr_l2tpip6 *)msg->msg_name;
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
@@ -688,8 +688,8 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 			lsa->l2tp_scope_id = IP6CB(skb)->iif;
 	}
 
-	if (inet->cmsg_flags)
-		ip_cmsg_recv(msg, skb);
+	if (np->rxopt.all)
+		ip6_datagram_recv_ctl(sk, msg, skb);
 
 	if (flags & MSG_TRUNC)
 		copied = skb->len;
-- 
1.7.9.5
