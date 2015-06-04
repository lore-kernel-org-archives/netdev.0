From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: remove redundant checks
Date: Wed, 03 Jun 2015 23:49:21 -0700
Message-ID: <1433400561.1895.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33497 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbbFDGtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 02:49:24 -0400
Received: by iebgx4 with SMTP id gx4so29891109ieb.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 23:49:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet  <edumazet@google.com>

tcp_v4_rcv() checks the following before calling tcp_v4_do_rcv():

if (th->doff < sizeof(struct tcphdr) / 4)
    goto bad_packet;
if (!pskb_may_pull(skb, th->doff * 4))
    goto discard_it;

So following check in tcp_v4_do_rcv() is redundant
and "goto csum_err;" is wrong anyway.

if (skb->len < tcp_hdrlen(skb) || ...)
	goto csum_err;

A second check can be removed after no_tcp_socket label for same reason.

Same tests can be removed in tcp_v6_do_rcv()

Note : short tcp frames are not properly accounted in tcpInErrs MIB,
because pskb_may_pull() failure simply drops incoming skb, we might
fix this in a separate patch.

Signed-off-by: Eric Dumazet  <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |    4 ++--
 net/ipv6/tcp_ipv6.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index feb875769b8d57dcdb85e12b782f3f5e0fb6193a..3130c42240c86545f1037648635a9e7de0876095 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1400,7 +1400,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
-	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
+	if (tcp_checksum_complete(skb))
 		goto csum_err;
 
 	if (sk->sk_state == TCP_LISTEN) {
@@ -1647,7 +1647,7 @@ no_tcp_socket:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto discard_it;
 
-	if (skb->len < (th->doff << 2) || tcp_checksum_complete(skb)) {
+	if (tcp_checksum_complete(skb)) {
 csum_error:
 		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
 bad_packet:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7be3d858cbf0a4f5b7f4ecce8788aa8e4136d6fa..b72e1ffc6bb40f486764874e6a167b72d899605b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1250,7 +1250,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
-	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
+	if (tcp_checksum_complete(skb))
 		goto csum_err;
 
 	if (sk->sk_state == TCP_LISTEN) {
@@ -1442,7 +1442,7 @@ no_tcp_socket:
 
 	tcp_v6_fill_cb(skb, hdr, th);
 
-	if (skb->len < (th->doff<<2) || tcp_checksum_complete(skb)) {
+	if (tcp_checksum_complete(skb)) {
 csum_error:
 		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
 bad_packet:
