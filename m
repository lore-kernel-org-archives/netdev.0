From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net] tcp: do not grow receive window if skb->len < 128
Date: Fri, 27 Dec 2013 11:20:54 +0800
Message-ID: <2245b9d01fa91d84a8af1e17e1b97f0763f1b792.1388114391.git.panweiping3@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61353 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132Ab3L0DVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Dec 2013 22:21:13 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rBR3LCAQ018677
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 22:21:13 -0500
Received: from localhost.localdomain.com (dhcp-17-97.nay.redhat.com [10.66.17.97])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id rBR3LBCa018755
	for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 22:21:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4e4f1fc22681(tcp: properly increase rcv_ssthresh for ofo packets) can
grow receive window for out of order packets,
but for in order packets, we only call tcp_grow_window() if skb->len >= 128,
I think we should add the same condition for out of order packets.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv4/tcp_input.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c53b7f3..2272774 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -343,6 +343,9 @@ static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	if (skb->len < 128)
+		return;
+
 	/* Check #1 */
 	if (tp->rcv_ssthresh < tp->window_clamp &&
 	    (int)tp->rcv_ssthresh < tcp_space(sk) &&
@@ -654,8 +657,7 @@ static void tcp_event_data_recv(struct sock *sk, struct sk_buff *skb)
 
 	TCP_ECN_check_ce(tp, skb);
 
-	if (skb->len >= 128)
-		tcp_grow_window(sk, skb);
+	tcp_grow_window(sk, skb);
 }
 
 /* Called to compute a smoothed rtt estimate. The data fed to this
-- 
1.7.4
