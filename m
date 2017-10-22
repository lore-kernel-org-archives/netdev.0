From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp/dccp: fix lockdep splat in inet_csk_route_req()
Date: Sun, 22 Oct 2017 12:33:57 -0700
Message-ID: <1508700837.30291.63.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:53404 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932128AbdJVTeA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 15:34:00 -0400
Received: by mail-pg0-f67.google.com with SMTP id s2so10163219pge.10
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 12:34:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This patch fixes the following lockdep splat in inet_csk_route_req()

  lockdep_rcu_suspicious
  inet_csk_route_req
  tcp_v4_send_synack
  tcp_rtx_synack
  inet_rtx_syn_ack
  tcp_fastopen_synack_time
  tcp_retransmit_timer
  tcp_write_timer_handler
  tcp_write_timer
  call_timer_fn

Thread running inet_csk_route_req() owns a reference on the request
socket, so we have the guarantee ireq->ireq_opt wont be changed or
freed.

lockdep can enforce this invariant for us.

Fixes: c92e8c02fe66 ("tcp/dccp: fix ireq->opt races")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_connection_sock.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 5ec9136a7c36933cb36e5cd50058eb6cf189a7c3..18cd2eae758ff1a9d8a736e143417c7007b99067 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -543,7 +543,8 @@ struct dst_entry *inet_csk_route_req(const struct sock *sk,
 	struct ip_options_rcu *opt;
 	struct rtable *rt;
 
-	opt = rcu_dereference(ireq->ireq_opt);
+	opt = rcu_dereference_protected(ireq->ireq_opt,
+					refcount_read(&req->rsk_refcnt) > 0);
 	flowi4_init_output(fl4, ireq->ir_iif, ireq->ir_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE,
 			   sk->sk_protocol, inet_sk_flowi_flags(sk),
