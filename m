From: Tom Herbert <therbert@google.com>
Subject: [PATCH 6/7] net: Verify UDP checksum before handoff to encap
Date: Wed, 7 May 2014 16:52:39 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405071644070.1135@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:51428 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbaEGXwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:52:40 -0400
Received: by mail-qc0-f201.google.com with SMTP id l6so271856qcy.2
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 16:52:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moving validation of UDP checksum to be done in UDP not encap layer.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp.c | 4 ++++
 net/ipv6/udp.c | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f2d05d7..54ea0a3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1495,6 +1495,10 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		if (skb->len > sizeof(struct udphdr) && encap_rcv != NULL) {
 			int ret;
 
+			/* Verify checksum before giving to encap */
+			if (udp_lib_checksum_complete(skb))
+				goto csum_error;
+
 			ret = encap_rcv(sk, skb);
 			if (ret <= 0) {
 				UDP_INC_STATS_BH(sock_net(sk),
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fc2be63..7edf096 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -634,6 +634,10 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 		if (skb->len > sizeof(struct udphdr) && encap_rcv != NULL) {
 			int ret;
 
+			/* Verify checksum before giving to encap */
+			if (udp_lib_checksum_complete(skb))
+				goto csum_error;
+
 			ret = encap_rcv(sk, skb);
 			if (ret <= 0) {
 				UDP_INC_STATS_BH(sock_net(sk),
-- 
1.9.1.423.g4596e3a
