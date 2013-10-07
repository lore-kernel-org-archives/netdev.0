From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH net-next v3 1/3] udp: Only allow busy read/poll on connected sockets
Date: Mon,  7 Oct 2013 11:01:38 -0500
Message-ID: <1381161700-14453-2-git-send-email-shawn.bohrer@gmail.com>
References: <1381161700-14453-1-git-send-email-shawn.bohrer@gmail.com>
Cc: netdev <netdev@vger.kernel.org>, tomk@rgmadvisors.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:42728 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755709Ab3JGQCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 12:02:13 -0400
Received: by mail-oa0-f45.google.com with SMTP id o17so6280857oag.18
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 09:02:12 -0700 (PDT)
In-Reply-To: <1381161700-14453-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>

UDP sockets can receive packets from multiple endpoints and thus may be
received on multiple receive queues.  Since packets packets can arrive
on multiple receive queues we should not mark the napi_id for all
packets.  This makes busy read/poll only work for connected UDP sockets.

This additionally enables busy read/poll for UDP multicast packets as
long as the socket is connected by moving the check into
__udp_queue_rcv_skb().

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp.c |    5 +++--
 net/ipv6/udp.c |    5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c41833e..5950e12 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1405,8 +1405,10 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
 
-	if (inet_sk(sk)->inet_daddr)
+	if (inet_sk(sk)->inet_daddr) {
 		sock_rps_save_rxhash(sk, skb);
+		sk_mark_napi_id(sk, skb);
+	}
 
 	rc = sock_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
@@ -1716,7 +1718,6 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (sk != NULL) {
 		int ret;
 
-		sk_mark_napi_id(sk, skb);
 		ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8119791..3753247 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -549,8 +549,10 @@ static int __udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
 
-	if (!ipv6_addr_any(&inet6_sk(sk)->daddr))
+	if (!ipv6_addr_any(&inet6_sk(sk)->daddr)) {
 		sock_rps_save_rxhash(sk, skb);
+		sk_mark_napi_id(sk, skb);
+	}
 
 	rc = sock_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
@@ -844,7 +846,6 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (sk != NULL) {
 		int ret;
 
-		sk_mark_napi_id(sk, skb);
 		ret = udpv6_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
-- 
1.7.7.6
