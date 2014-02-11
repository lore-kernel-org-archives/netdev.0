From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/3] net: UDP gro_receive accept csum=0
Date: Tue, 11 Feb 2014 09:43:48 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1402110928070.7090@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ogerlitz@mellanox.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:48035 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaBKRnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 12:43:49 -0500
Received: by mail-ob0-f201.google.com with SMTP id gq1so1723242obb.2
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 09:43:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code to validate checksum in UDP gro_receive explictly checks
against driver having set CHECKSUM_COMPLETE. This does not perform
GRO on UDP packets with a checksum of zero (no checksum needed).
This patch adds the condition to allow UDP checksum to be zero.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp_offload.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 25f5cee..4db7796 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -156,13 +156,9 @@ static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *s
 	unsigned int hlen, off;
 	int flush = 1;
 
-	if (NAPI_GRO_CB(skb)->udp_mark ||
-	    (!skb->encapsulation && skb->ip_summed != CHECKSUM_COMPLETE))
+	if (NAPI_GRO_CB(skb)->udp_mark)
 		goto out;
 
-	/* mark that this skb passed once through the udp gro layer */
-	NAPI_GRO_CB(skb)->udp_mark = 1;
-
 	off  = skb_gro_offset(skb);
 	hlen = off + sizeof(*uh);
 	uh   = skb_gro_header_fast(skb, off);
@@ -172,6 +168,13 @@ static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *s
 			goto out;
 	}
 
+	if (!skb->encapsulation &&
+	    skb->ip_summed != CHECKSUM_COMPLETE && uh->check != 0)
+		goto out;
+
+	/* mark that this skb passed once through the udp gro layer */
+	NAPI_GRO_CB(skb)->udp_mark = 1;
+
 	rcu_read_lock();
 	uo_priv = rcu_dereference(udp_offload_base);
 	for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
-- 
1.9.0.rc1.175.g0b1dcb5
