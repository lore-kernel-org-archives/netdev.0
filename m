From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bridge: fix a possible use after free
Date: Wed, 24 Aug 2011 07:57:05 +0200
Message-ID: <1314165425.4478.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44605 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183Ab1HXF5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 01:57:09 -0400
Received: by wyg24 with SMTP id 24so580687wyg.19
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2011 22:57:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_multicast_ipv6_rcv() can call pskb_trim_rcsum() and therefore skb
head can be reallocated.

Cache icmp6_type field instead of dereferencing twice the struct
icmp6hdr pointer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/bridge/br_multicast.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2d85ca7..5db95fd 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1456,7 +1456,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 {
 	struct sk_buff *skb2;
 	const struct ipv6hdr *ip6h;
-	struct icmp6hdr *icmp6h;
+	u8 icmp6_type;
 	u8 nexthdr;
 	unsigned len;
 	int offset;
@@ -1502,9 +1502,9 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	__skb_pull(skb2, offset);
 	skb_reset_transport_header(skb2);
 
-	icmp6h = icmp6_hdr(skb2);
+	icmp6_type = icmp6_hdr(skb2)->icmp6_type;
 
-	switch (icmp6h->icmp6_type) {
+	switch (icmp6_type) {
 	case ICMPV6_MGM_QUERY:
 	case ICMPV6_MGM_REPORT:
 	case ICMPV6_MGM_REDUCTION:
@@ -1537,7 +1537,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 
 	BR_INPUT_SKB_CB(skb)->igmp = 1;
 
-	switch (icmp6h->icmp6_type) {
+	switch (icmp6_type) {
 	case ICMPV6_MGM_REPORT:
 	    {
 		struct mld_msg *mld;
