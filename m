From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 2/2] l2tp: correctly handle ancilliary data for ip6 recv
Date: Mon, 28 Jan 2013 10:48:54 +0000
Message-ID: <1359370134-29875-3-git-send-email-tparkin@katalix.com>
References: <1359370134-29875-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:49842 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754174Ab3A1KtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 05:49:11 -0500
In-Reply-To: <1359370134-29875-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_ip6 was using the IPv4 recv handler function for ancilliary data.  This
patch changes it over to use the IPv6 handler, which allows l2tp_ip6 sockets to
correctly pass ancilliary data to userspace via. recvmsg().

Ref:  net/ipv6/udp.c, udpv6_recvmsg

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: Chris Elston <celston@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_ip6.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 9275471..6824223 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -647,6 +647,7 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 			    int flags, int *addr_len)
 {
 	struct inet_sock *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sockaddr_l2tpip6 *lsa = (struct sockaddr_l2tpip6 *)msg->msg_name;
 	size_t copied = 0;
 	int err = -EOPNOTSUPP;
@@ -688,8 +689,8 @@ static int l2tp_ip6_recvmsg(struct kiocb *iocb, struct sock *sk,
 			lsa->l2tp_scope_id = IP6CB(skb)->iif;
 	}
 
-	if (inet->cmsg_flags)
-		ip_cmsg_recv(msg, skb);
+	if (np->rxopt.all)
+		datagram_recv_ctl(sk, msg, skb);
 
 	if (flags & MSG_TRUNC)
 		copied = skb->len;
-- 
1.7.9.5
