From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: avoid two atomic ops in ip_rcv_options()
Date: Mon, 07 Jun 2010 15:54:46 +0200
Message-ID: <1275918886.2545.87.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47323 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab0FGNyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 09:54:50 -0400
Received: by wyi11 with SMTP id 11so2377634wyi.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 06:54:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in_dev_get() -> __in_dev_get_rcu() in a rcu protected function.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_input.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d52c9da..27b5a09 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -298,18 +298,16 @@ static inline int ip_rcv_options(struct sk_buff *skb)
 	}
 
 	if (unlikely(opt->srr)) {
-		struct in_device *in_dev = in_dev_get(dev);
+		struct in_device *in_dev = __in_dev_get_rcu(dev);
+
 		if (in_dev) {
 			if (!IN_DEV_SOURCE_ROUTE(in_dev)) {
 				if (IN_DEV_LOG_MARTIANS(in_dev) &&
 				    net_ratelimit())
 					printk(KERN_INFO "source route option %pI4 -> %pI4\n",
 					       &iph->saddr, &iph->daddr);
-				in_dev_put(in_dev);
 				goto drop;
 			}
-
-			in_dev_put(in_dev);
 		}
 
 		if (ip_options_rcv_srr(skb))


