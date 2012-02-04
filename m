From: Shawn Lu <shawn.lu@ericsson.com>
Subject: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case
Date: Sat, 4 Feb 2012 13:44:57 -0800
Message-ID: <1328391897-15241-1-git-send-email-shawn.lu@ericsson.com>
References: <RE: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, xiaoclu@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:40260 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944Ab2BDVpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Feb 2012 16:45:15 -0500
In-Reply-To: <RE: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Binding RST packet outgoing interface to incoming interface
for tcp v4 when there is no socket associate with it.
This has few benefits:
1. tcp_v6_send_reset already did that.
2. This helps tcp connect with SO_BINDTODEVICE set. When
connection is lost, we still able to sending out RST using
same interface.
3. we are sending reply, it is most likely to be succeed
if iif is used

Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
---
V3: reformat comments as suggested
 net/ipv4/tcp_ipv4.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 90e4793..4d6f81c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -676,6 +676,11 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
+	/* When socket is gone, all binding information is lost.
+	 * routing might fail in this case. using iif for oif to
+	 * make sure we can deliver it
+	 */
+	arg.bound_dev_if = sk ? sk->sk_bound_dev_if : inet_iif(skb);
 
 	net = dev_net(skb_dst(skb)->dev);
 	arg.tos = ip_hdr(skb)->tos;
-- 
1.7.0.4
