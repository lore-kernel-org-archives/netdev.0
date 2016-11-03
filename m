From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] dccp: fix out of bound access in dccp_v4_err()
Date: Wed, 02 Nov 2016 19:00:40 -0700
Message-ID: <1478138440.7065.419.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32793 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752011AbcKCCAo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 22:00:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

dccp_v4_err() does not use pskb_may_pull() and might access garbage.

We only need 4 bytes at the beginning of the DCCP header, like TCP,
so the 8 bytes pulled in icmp_socket_deliver() are more than enough.

This patch might allow to process more ICMP messages, as some routers
are still limiting the size of reflected bytes to 28 (RFC 792), instead
of extended lengths (RFC 1812 4.3.2.3)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/ipv4.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 345a3aeb8c7e..32f00ffdbf42 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -235,7 +235,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 {
 	const struct iphdr *iph = (struct iphdr *)skb->data;
 	const u8 offset = iph->ihl << 2;
-	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data + offset);
+	const struct dccp_hdr *dh;
 	struct dccp_sock *dp;
 	struct inet_sock *inet;
 	const int type = icmp_hdr(skb)->type;
@@ -245,11 +245,13 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-	if (skb->len < offset + sizeof(*dh) ||
-	    skb->len < offset + __dccp_basic_hdr_len(dh)) {
-		__ICMP_INC_STATS(net, ICMP_MIB_INERRORS);
-		return;
-	}
+	/* Only need dccph_dport & dccph_sport which are the first
+	 * 4 bytes in dccp header.
+	 * Our caller (icmp_socket_deliver()) already pulled 8 bytes for us.
+	 */
+	BUILD_BUG_ON(offsetofend(struct dccp_hdr, dccph_sport) > 8);
+	BUILD_BUG_ON(offsetofend(struct dccp_hdr, dccph_dport) > 8);
+	dh = (struct dccp_hdr *)(skb->data + offset);
 
 	sk = __inet_lookup_established(net, &dccp_hashinfo,
 				       iph->daddr, dh->dccph_dport,
