From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6] ipv6: NULL pointer dereferrence in tcp_v6_send_ack
Date: Wed,  1 Oct 2008 13:11:57 +0400
Message-ID: <1222852317-7177-1-git-send-email-den@openvz.org>
References: <20081001.020359.48616451.davem@davemloft.net>
Cc: xemul@openvz.org, vgusev@openvz.org, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3546 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753261AbYJAJLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 05:11:51 -0400
In-Reply-To: <20081001.020359.48616451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following actions are possible:
tcp_v6_rcv
  skb->dev = NULL;
  tcp_v6_do_rcv
    tcp_v6_hnd_req
      tcp_check_req
        req->rsk_ops->send_ack == tcp_v6_send_ack

So, skb->dev can be NULL in tcp_v6_send_ack. We must obtain namespace
from dst entry.

Thanks to Vitaliy Gusev <vgusev@openvz.org> for initial problem finding
in IPv4 code.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/tcp_ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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

