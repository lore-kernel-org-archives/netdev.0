From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Thu,  7 Mar 2013 22:36:40 +0000
Message-ID: <1362695800-8633-2-git-send-email-tparkin@katalix.com>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:35658 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599Ab3CGWgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 17:36:45 -0500
In-Reply-To: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a fragmented IP packet is queued during device teardown, it is possible
for the reassembled packet to hit the UDP rcv path with a NULL dst_entry dev
pointer.  Drop such packets to prevent an oops.
---
 net/ipv4/udp.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0a073a2..c38a4b1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1700,6 +1700,9 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		return __udp4_lib_mcast_deliver(net, skb, uh,
 				saddr, daddr, udptable);
 
+	if (skb_dst(skb)->dev == NULL)
+		goto drop;
+
 	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 
 	if (sk != NULL) {
-- 
1.7.9.5
