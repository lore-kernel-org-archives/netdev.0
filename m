From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: [net-next 1/3] udp: Only allow busy read/poll on connected sockets
Date: Tue,  1 Oct 2013 14:33:43 -0500
Message-ID: <1380656025-8847-2-git-send-email-sbohrer@rgmadvisors.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:46013 "EHLO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751601Ab3JATeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 15:34:25 -0400
Received: by mail-oa0-f44.google.com with SMTP id l10so5363855oag.3
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 12:34:24 -0700 (PDT)
In-Reply-To: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP sockets can receive packets from multiple endpoints and thus may be
received on multiple receive queues.  Since packets packets can arrive
on multiple receive queues we should not mark the napi_id for all
packets.  This makes busy read/poll only work for connected UDP sockets.

This additionally enables busy read/poll for UDP multicast packets as
long as the socket is connected by moving the check into
__udp_queue_rcv_skb().

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
 net/ipv4/udp.c |    5 +++--
 net/ipv6/udp.c |    5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 728ce95..1982a03 100644
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
index f405815..84e18ab 100644
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


-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
