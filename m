From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6] ip: NULL pointer dereferrence in tcp_v(4|6)_send_ack
Date: Tue, 30 Sep 2008 20:29:11 +0400
Message-ID: <1222792151-11861-1-git-send-email-den@openvz.org>
References: <200809302013.30051.vgusev@openvz.org>
Cc: xemul@openvz.org, vgusev@openvz.org, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31777 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752208AbYI3Q3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 12:29:08 -0400
In-Reply-To: <200809302013.30051.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following actions are possible:
tcp_v4_rcv
  skb->dev = NULL;
  tcp_v4_do_rcv
    tcp_v4_hnd_req
      tcp_check_req
        req->rsk_ops->send_ack == tcp_v4_send_ack

So, skb->dev can be NULL in tcp_v4_send_ack. We must obtain namespace
from dst entry. IPv6 codepath is similar.

Thanks to Vitaliy Gusev <vgusev@openvz.org> for initial oops decoding.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 net/ipv6/tcp_ipv6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1b4fee2..011478e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -618,7 +618,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			];
 	} rep;
 	struct ip_reply_arg arg;
-	struct net *net = dev_net(skb->dev);
+	struct net *net = dev_net(skb->dst->dev);
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
 	memset(&arg, 0, sizeof(arg));
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b585c85..10e22fd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1050,7 +1050,7 @@ static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32
 	struct tcphdr *th = tcp_hdr(skb), *t1;
 	struct sk_buff *buff;
 	struct flowi fl;
-	struct net *net = dev_net(skb->dev);
+	struct net *net = dev_net(skb->dst->dev);
 	struct sock *ctl_sk = net->ipv6.tcp_sk;
 	unsigned int tot_len = sizeof(struct tcphdr);
 	__be32 *topt;
-- 
1.5.6.4

