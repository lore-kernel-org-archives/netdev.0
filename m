From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: tcp: ip_send_unicast_reply() is not BH safe
Date: Fri, 06 May 2016 09:46:18 -0700
Message-ID: <1462553178.13075.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andres Lagar-Cavilla <andreslc@google.com>, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36496 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758171AbcEFQqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 12:46:21 -0400
Received: by mail-pf0-f174.google.com with SMTP id c189so53133231pfb.3
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 09:46:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I forgot that ip_send_unicast_reply() is not BH safe (yet).

Disabling preemption before calling it was not a good move.

Fixes: c10d9310edf5 ("tcp: do not assume TCP code is non preemptible")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andres Lagar-Cavilla  <andreslc@google.com>
---
 net/ipv4/tcp_ipv4.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a7ab9472d64560d86ea24ac1b6e1a7800f89989d..8219d0d8dc8370d0d3e6fc4cd17b4925617968ab 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -692,7 +692,7 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 		     offsetof(struct inet_timewait_sock, tw_bound_dev_if));
 
 	arg.tos = ip_hdr(skb)->tos;
-	preempt_disable();
+	local_bh_disable();
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
 			      skb, &TCP_SKB_CB(skb)->header.h4.opt,
 			      ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
@@ -700,7 +700,7 @@ static void tcp_v4_send_reset(const struct sock *sk, struct sk_buff *skb)
 
 	__TCP_INC_STATS(net, TCP_MIB_OUTSEGS);
 	__TCP_INC_STATS(net, TCP_MIB_OUTRSTS);
-	preempt_enable();
+	local_bh_enable();
 
 #ifdef CONFIG_TCP_MD5SIG
 out:
@@ -776,14 +776,14 @@ static void tcp_v4_send_ack(struct net *net,
 	if (oif)
 		arg.bound_dev_if = oif;
 	arg.tos = tos;
-	preempt_disable();
+	local_bh_disable();
 	ip_send_unicast_reply(*this_cpu_ptr(net->ipv4.tcp_sk),
 			      skb, &TCP_SKB_CB(skb)->header.h4.opt,
 			      ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
 			      &arg, arg.iov[0].iov_len);
 
 	__TCP_INC_STATS(net, TCP_MIB_OUTSEGS);
-	preempt_enable();
+	local_bh_enable();
 }
 
 static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
