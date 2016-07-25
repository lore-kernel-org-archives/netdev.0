From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] udp: use sk_filter_trim_cap for udp{,6}_queue_rcv_skb
Date: Mon, 25 Jul 2016 18:06:12 +0200
Message-ID: <0a5ec5a7e99c314f5f5f56f37380b70f8a5bc4ad.1469462373.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, willemdebruijn.kernel@gmail.com,
	alexei.starovoitov@gmail.com,
	Daniel Borkmann <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42660 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbcGYQGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 12:06:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After a612769774a3 ("udp: prevent bugcheck if filter truncates packet
too much"), there followed various other fixes for similar cases such
as f4979fcea7fd ("rose: limit sk_filter trim to payload").

Latter introduced a new helper sk_filter_trim_cap(), where we can pass
the trim limit directly to the socket filter handling. Make use of it
here as well with sizeof(struct udphdr) as lower cap limit and drop the
extra skb->len test in UDP's input path.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/udp.c | 4 +---
 net/ipv6/udp.c | 4 +---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4aed8fc..e61f7cd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1581,9 +1581,7 @@ int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	    udp_lib_checksum_complete(skb))
 			goto csum_error;
 
-	if (sk_filter(sk, skb))
-		goto drop;
-	if (unlikely(skb->len < sizeof(struct udphdr)))
+	if (sk_filter_trim_cap(sk, skb, sizeof(struct udphdr)))
 		goto drop;
 
 	udp_csum_pull_header(skb);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index ad5292b..81e2f98 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -618,9 +618,7 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	    udp_lib_checksum_complete(skb))
 		goto csum_error;
 
-	if (sk_filter(sk, skb))
-		goto drop;
-	if (unlikely(skb->len < sizeof(struct udphdr)))
+	if (sk_filter_trim_cap(sk, skb, sizeof(struct udphdr)))
 		goto drop;
 
 	udp_csum_pull_header(skb);
-- 
1.9.3
