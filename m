From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] arp: RCU changes
Date: Thu, 03 Jun 2010 16:09:10 +0200
Message-ID: <1275574150.2456.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42092 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811Ab0FCOJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 10:09:15 -0400
Received: by wyi11 with SMTP id 11so77714wyi.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 07:09:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid two atomic ops in arp_fwd_proxy()

Avoid two atomic ops in arp_process()

Valid optims since arp_rcv() is run under rcu_read_lock()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/arp.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index f094b75..917d2d6 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -545,10 +545,10 @@ static inline int arp_fwd_proxy(struct in_device *in_dev,
 
 	/* place to check for proxy_arp for routes */
 
-	if ((out_dev = in_dev_get(rt->u.dst.dev)) != NULL) {
+	out_dev = __in_dev_get_rcu(rt->u.dst.dev);
+	if (out_dev)
 		omi = IN_DEV_MEDIUM_ID(out_dev);
-		in_dev_put(out_dev);
-	}
+
 	return (omi != imi && omi != -1);
 }
 
@@ -741,7 +741,7 @@ void arp_send(int type, int ptype, __be32 dest_ip,
 static int arp_process(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct in_device *in_dev = in_dev_get(dev);
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
 	struct arphdr *arp;
 	unsigned char *arp_ptr;
 	struct rtable *rt;
@@ -890,7 +890,6 @@ static int arp_process(struct sk_buff *skb)
 					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
 				} else {
 					pneigh_enqueue(&arp_tbl, in_dev->arp_parms, skb);
-					in_dev_put(in_dev);
 					return 0;
 				}
 				goto out;
@@ -936,8 +935,6 @@ static int arp_process(struct sk_buff *skb)
 	}
 
 out:
-	if (in_dev)
-		in_dev_put(in_dev);
 	consume_skb(skb);
 	return 0;
 }


