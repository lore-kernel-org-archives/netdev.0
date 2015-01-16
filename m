From: subashab@codeaurora.org
Subject: [PATCH] net: ipv4: Fix incorrect free in ICMP receive
Date: Fri, 16 Jan 2015 07:48:36 -0000
Message-ID: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:46998 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511AbbAPHsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 02:48:36 -0500
Received: from www.codeaurora.org (pdx-caf-fw-vip.codeaurora.org [198.145.11.226])
	by smtp.codeaurora.org (Postfix) with ESMTP id 7257C140D2D
	for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 07:48:36 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An exception is seen in ICMP ping receive path where the skb
destructor sock_rfree() tries to access a freed socket. This happens
because ping_rcv() releases socket reference with sock_put() and this
internally frees up the socket. Later icmp_rcv() will try to free the
skb and as part of this, skb destructor is called and panics as the
socket is freed already in ping_rcv().

WARN stack trace @       WARN_ON(atomic_read(&sk->sk_rmem_alloc));
dump_backtrace+0x0/0x248
show_stack+0x10/0x1c
dump_stack+0x1c/0x28
warn_slowpath_common+0x74/0x9c
warn_slowpath_null+0x14/0x20
inet_sock_destruct+0x130/0x1a0
__sk_free+0x1c/0x168
sk_free+0x24/0x30
ping_rcv+0xf4/0x124
icmp_rcv+0x224/0x2c4
ip_local_deliver_finish+0x108/0x214
ip_local_deliver+0x88/0xa0
ip_rcv_finish+0x234/0x284
ip_rcv+0x258/0x2e8
__netif_receive_skb_core+0x640/0x6b4
<snip>

-->|exception
-007|sk_mem_uncharge
-007|sock_rfree
-008|skb_release_head_state
-009|skb_release_all
-009|__kfree_skb
-010|kfree_skb
-011|icmp_rcv
-012|ip_local_deliver_finish

Fix this by orphaning the skb's before freeing the socket

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/ipv4/af_inet.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b507a47..0c58f0e5 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -147,6 +147,12 @@ EXPORT_SYMBOL(ipv4_config);
 void inet_sock_destruct(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
+	struct sk_buff *skb;
+
+	skb_queue_walk(&sk->sk_receive_queue, skb)
+		skb_orphan(skb);
+	skb_queue_walk(&sk->sk_error_queue, skb)
+		skb_orphan(skb);

 	__skb_queue_purge(&sk->sk_receive_queue);
 	__skb_queue_purge(&sk->sk_error_queue);
-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project
