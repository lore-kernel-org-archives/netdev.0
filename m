From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH net-next v6 3/3] ipv6: tcp_ipv6 policy route issue
Date: Sat, 29 Mar 2014 09:27:31 +0800
Message-ID: <1396056451-5600-4-git-send-email-wangyufen@huawei.com>
References: <1396056451-5600-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kuznet@ms2.inr.ac.ru>, Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:33605 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbaC2B1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 21:27:49 -0400
In-Reply-To: <1396056451-5600-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>

The issue raises when adding policy route, specify a particular
NIC as oif, the policy route did not take effect. The reason is
that fl6.oif is not set and route map failed. From the 
tcp_v6_send_response function, if the binding address is linklocal,
fl6.oif is set, but not for global address.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 net/ipv6/tcp_ipv6.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 10b7c04..5ca56ce 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -726,7 +726,7 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 #endif
 
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
-				 u32 tsval, u32 tsecr,
+				 u32 tsval, u32 tsecr, int oif,
 				 struct tcp_md5sig_key *key, int rst, u8 tclass,
 				 u32 label)
 {
@@ -798,8 +798,10 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	__tcp_v6_send_check(buff, &fl6.saddr, &fl6.daddr);
 
 	fl6.flowi6_proto = IPPROTO_TCP;
-	if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
+	if (rt6_need_strict(&fl6.daddr) || !oif)
 		fl6.flowi6_oif = inet6_iif(skb);
+	else
+		fl6.flowi6_oif = oif;
 	fl6.fl6_dport = t1->dest;
 	fl6.fl6_sport = t1->source;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
@@ -833,6 +835,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	int genhash;
 	struct sock *sk1 = NULL;
 #endif
+	int oif;
 
 	if (th->rst)
 		return;
@@ -876,7 +879,8 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		ack_seq = ntohl(th->seq) + th->syn + th->fin + skb->len -
 			  (th->doff << 2);
 
-	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, 0, key, 1, 0, 0);
+	oif = sk ? sk->sk_bound_dev_if : 0;
+	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, 0, oif, key, 1, 0, 0);
 
 #ifdef CONFIG_TCP_MD5SIG
 release_sk1:
@@ -888,11 +892,11 @@ release_sk1:
 }
 
 static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
-			    u32 win, u32 tsval, u32 tsecr,
+			    u32 win, u32 tsval, u32 tsecr, int oif,
 			    struct tcp_md5sig_key *key, u8 tclass,
 			    u32 label)
 {
-	tcp_v6_send_response(skb, seq, ack, win, tsval, tsecr, key, 0, tclass,
+	tcp_v6_send_response(skb, seq, ack, win, tsval, tsecr, oif, key, 0, tclass,
 			     label);
 }
 
@@ -904,7 +908,7 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	tcp_v6_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcp_time_stamp + tcptw->tw_ts_offset,
-			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw),
+			tcptw->tw_ts_recent, tw->tw_bound_dev_if, tcp_twsk_md5_key(tcptw),
 			tw->tw_tclass, (tw->tw_flowlabel << 12));
 
 	inet_twsk_put(tw);
@@ -914,7 +918,7 @@ static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
 	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1,
-			req->rcv_wnd, tcp_time_stamp, req->ts_recent,
+			req->rcv_wnd, tcp_time_stamp, req->ts_recent, sk->sk_bound_dev_if,
 			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr),
 			0, 0);
 }
-- 
1.7.12
