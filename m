From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH 2/3] Prevent from passing NULL pointer to tcp_v4_md5_do_lookup()
Date: Tue, 05 Aug 2008 17:23:20 +0800
Message-ID: <48981C08.3050501@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64546 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1761038AbYHEJ07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 05:26:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If skb->sk == NULL when calling tcp_v4_md5_do_lookup(), kernel
will panic. Don't let this thing happen.

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
 net/ipv4/tcp_ipv4.c      |    4 ++--
 net/ipv4/tcp_minisocks.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 91a8cfd..44c1e93 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -687,14 +687,14 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	inet_twsk_put(tw);
 }
 
-static void tcp_v4_reqsk_send_ack(struct sk_buff *skb,
+static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
 	tcp_v4_send_ack(skb, tcp_rsk(req)->snt_isn + 1,
 			tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd,
 			req->ts_recent,
 			0,
-			tcp_v4_md5_do_lookup(skb->sk, ip_hdr(skb)->daddr));
+			tcp_v4_md5_do_lookup(sk, ip_hdr(skb)->daddr));
 }
 
 /*
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 204c421..6d286f5 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -609,7 +609,7 @@ struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
 					  tcp_rsk(req)->rcv_isn + 1, tcp_rsk(req)->rcv_isn + 1 + req->rcv_wnd)) {
 		/* Out of window: send ACK and drop. */
 		if (!(flg & TCP_FLAG_RST))
-			req->rsk_ops->send_ack(skb, req);
+			req->rsk_ops->send_ack(sk, skb, req);
 		if (paws_reject)
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
 		return NULL;
-- 
1.5.3




