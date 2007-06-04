From: Patrick McHardy <kaber@trash.net>
Subject: Re: [TCP]: Honour sk_bound_dev_if in tcp_v4_send_ack
Date: Mon, 04 Jun 2007 17:15:53 +0200
Message-ID: <46642CA9.8060609@trash.net>
References: <46604104.9080605@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000406090306050802020506"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39674 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759AbXFDPSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 11:18:38 -0400
In-Reply-To: <46604104.9080605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000406090306050802020506
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> [TCP]: Honour sk_bound_dev_if in tcp_v4_send_ack
> 
> A time_wait socket inherits sk_bound_dev_if from the original socket,
> but it is not used when sending ACK packets using ip_send_reply.
> 
> Fix by passing the oif to ip_send_reply in struct ip_reply_arg and
> use it for output routing.


The patch was missing a NULL pointer check in tcp_v4_send_ack for
a different code path where twsk == NULL. Fixed version attached.


--------------000406090306050802020506
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[TCP]: Honour sk_bound_dev_if in tcp_v4_send_ack

A time_wait socket inherits sk_bound_dev_if from the original socket,
but it is not used when sending ACK packets using ip_send_reply.

Fix by passing the oif to ip_send_reply in struct ip_reply_arg and
use it for output routing.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9f66116df33984809a5cc0ea66a358db684d4346
tree a0b163d17181f1d1fafb4b7517726b5bb414b579
parent ea1601c50bf23af25094511e2a9ce1b755ab9669
author Patrick McHardy <kaber@trash.net> Mon, 04 Jun 2007 17:10:41 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 04 Jun 2007 17:13:17 +0200

 include/net/ip.h     |    1 +
 net/ipv4/ip_output.c |    4 +++-
 net/ipv4/tcp_ipv4.c  |    2 ++
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index bb207db..abf2820 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -143,6 +143,7 @@ struct ip_reply_arg {
 	__wsum 	    csum;
 	int	    csumoffset; /* u16 offset of csum in iov[0].iov_base */
 				/* -1 if not needed */ 
+	int	    bound_dev_if;
 }; 
 
 void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *arg,
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d6427d9..34ea454 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1352,7 +1352,8 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 	}
 
 	{
-		struct flowi fl = { .nl_u = { .ip4_u =
+		struct flowi fl = { .oif = arg->bound_dev_if,
+				    .nl_u = { .ip4_u =
 					      { .daddr = daddr,
 						.saddr = rt->rt_spec_dst,
 						.tos = RT_TOS(ip_hdr(skb)->tos) } },
@@ -1376,6 +1377,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 	inet->tos = ip_hdr(skb)->tos;
 	sk->sk_priority = skb->priority;
 	sk->sk_protocol = ip_hdr(skb)->protocol;
+	sk->sk_bound_dev_if = arg->bound_dev_if;
 	ip_append_data(sk, ip_reply_glue_bits, arg->iov->iov_base, len, 0,
 		       &ipc, rt, MSG_DONTWAIT);
 	if ((skb = skb_peek(&sk->sk_write_queue)) != NULL) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 47c6105..97e294e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -705,6 +705,8 @@ static void tcp_v4_send_ack(struct tcp_timewait_sock *twsk,
 				      ip_hdr(skb)->saddr, /* XXX */
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
+	if (twsk)
+		arg.bound_dev_if = twsk->tw_sk.tw_bound_dev_if;
 
 	ip_send_reply(tcp_socket->sk, skb, &arg, arg.iov[0].iov_len);
 

--------------000406090306050802020506--
