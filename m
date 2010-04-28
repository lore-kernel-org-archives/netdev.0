From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 3/5] sctp: per_cpu variables should be in bh_disabled section
Date: Wed, 28 Apr 2010 14:47:20 -0400
Message-ID: <1272480442-32673-4-git-send-email-vladislav.yasevich@hp.com>
References: <1272480442-32673-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:15854 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756474Ab0D1Sr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 14:47:27 -0400
In-Reply-To: <1272480442-32673-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the change of the atomics to percpu variables, we now
have to disable BH in process context when touching percpu variables.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index efa2bc3..44a1ab0 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3719,12 +3719,12 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 	sp->hmac = NULL;
 
 	SCTP_DBG_OBJCNT_INC(sock);
-	percpu_counter_inc(&sctp_sockets_allocated);
 
 	/* Set socket backlog limit. */
 	sk->sk_backlog.limit = sysctl_sctp_rmem[1];
 
 	local_bh_disable();
+	percpu_counter_inc(&sctp_sockets_allocated);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 	local_bh_enable();
 
@@ -3741,8 +3741,8 @@ SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
 	/* Release our hold on the endpoint. */
 	ep = sctp_sk(sk)->ep;
 	sctp_endpoint_free(ep);
-	percpu_counter_dec(&sctp_sockets_allocated);
 	local_bh_disable();
+	percpu_counter_dec(&sctp_sockets_allocated);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	local_bh_enable();
 }
-- 
1.6.0.4

