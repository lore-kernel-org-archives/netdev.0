From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] net: tcp_probe: kprobes: adapt jtcp_rcv_established signature
Date: Wed, 21 Aug 2013 19:47:59 +0200
Message-ID: <1377107280-31091-3-git-send-email-dborkman@redhat.com>
References: <1377107280-31091-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260Ab3HURsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 13:48:06 -0400
In-Reply-To: <1377107280-31091-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches fixes a rather unproblematic function signature mismatch
as the const specifier was missing for the th variable; and next to
that it adds a build-time assertion so that future function signature
mismatches for kprobes will not end badly, similarly as commit 22222997
("net: sctp: add build check for sctp_sf_eat_sack_6_2/jsctp_sf_eat_sack")
did it for SCTP.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/ipv4/tcp_probe.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index fae788b..a2392f4 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -92,7 +92,7 @@ static inline int tcp_probe_avail(void)
  * Note: arguments must match tcp_rcv_established()!
  */
 static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			       struct tcphdr *th, unsigned int len)
+				const struct tcphdr *th, unsigned int len)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_sock *inet = inet_sk(sk);
@@ -225,6 +225,13 @@ static __init int tcpprobe_init(void)
 {
 	int ret = -ENOMEM;
 
+	/* Warning: if the function signature of tcp_rcv_established,
+	 * has been changed, you also have to change the signature of
+	 * jtcp_rcv_established, otherwise you end up right here!
+	 */
+	BUILD_BUG_ON(__same_type(tcp_rcv_established,
+				 jtcp_rcv_established) == 0);
+
 	init_waitqueue_head(&tcp_probe.wait);
 	spin_lock_init(&tcp_probe.lock);
 
-- 
1.7.1
