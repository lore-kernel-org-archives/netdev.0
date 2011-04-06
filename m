From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets (v2)
Date: Wed,  6 Apr 2011 15:37:27 -0400
Message-ID: <1302118647-7931-1-git-send-email-nhorman@tuxdriver.com>
References: <1302112465-6842-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53829 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab1DFTmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 15:42:02 -0400
In-Reply-To: <1302112465-6842-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

properly record sk_rxhash in ipv6 sockets (v2)

Noticed while working on another project that flows to sockets which I had open
on a test systems weren't getting steered properly when I had RFS enabled.
Looking more closely I found that:

1) The affected sockets were all ipv6
2) They weren't getting steered because sk->sk_rxhash was never set from the
incomming skbs on that socket.

This was occuring because there are several points in the IPv4 tcp and udp code
which save the rxhash value when a new connection is established.  Those calls
to sock_rps_save_rxhash were never added to the corresponding ipv6 code paths.
This patch adds those calls.  Tested by myself to properly enable RFS
functionalty on ipv6.

Change notes:
v2:
	Filtered UDP to only arm RFS on bound sockets (Eric Dumazet)

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
CC: James Morris <jmorris@namei.org>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
CC: Tom Herbert <therbert@google.com>
---
 net/ipv6/tcp_ipv6.c |    4 +++-
 net/ipv6/udp.c      |    3 +++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2b0c186..97917bb 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1621,6 +1621,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		opt_skb = skb_clone(skb, GFP_ATOMIC);
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
+		sock_rps_save_rxhash(sk, skb->rxhash);
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len))
 			goto reset;
 		if (opt_skb)
@@ -1648,7 +1649,8 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 				__kfree_skb(opt_skb);
 			return 0;
 		}
-	}
+	} else
+		sock_rps_save_rxhash(sk, skb->rxhash);
 
 	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len))
 		goto reset;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d7037c0..15c3774 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -505,6 +505,9 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 	int rc;
 	int is_udplite = IS_UDPLITE(sk);
 
+	if (!ipv6_addr_any(&inet6_sk(sk)->daddr))
+		sock_rps_save_rxhash(sk, skb->rxhash);
+
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
 
-- 
1.7.4

