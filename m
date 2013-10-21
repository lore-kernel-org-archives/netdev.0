From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH net] netpoll: linearize skb before accessing its data
Date: Mon, 21 Oct 2013 23:31:20 +0200
Message-ID: <1382391080-1607-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, Antonio Quartulli <antonio@meshcoding.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:24992 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab3JUVcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 17:32:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__netpoll_rx() assumes that the data buffer of the received
skb is linear and then passes it to rx_hook().
However this is not true because the skb has not been
linearized yet.

This can cause rx_hook() to access non allocated memory
while parsing the received data.

Fix __netpoll_rx() by explicitly linearising the skb.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---

I checked linux-3.0 and this bug seems to be already there. Please consider
queueing it for stable.


Regards,



 net/core/netpoll.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index fc75c9e..97cff18 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -814,6 +814,9 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 		if (pskb_trim_rcsum(skb, len))
 			goto out;
 
+		if (skb_linearize(skb))
+			goto out;
+
 		iph = (struct iphdr *)skb->data;
 		if (iph->protocol != IPPROTO_UDP)
 			goto out;
@@ -855,6 +858,8 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 			goto out;
 		if (pskb_trim_rcsum(skb, len + sizeof(struct ipv6hdr)))
 			goto out;
+		if (skb_linearize(skb))
+			goto out;
 		ip6h = ipv6_hdr(skb);
 		if (!pskb_may_pull(skb, sizeof(struct udphdr)))
 			goto out;
-- 
1.8.4
