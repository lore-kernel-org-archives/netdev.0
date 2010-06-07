From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] igmp: avoid two atomic ops in igmp_rcv()
Date: Mon, 07 Jun 2010 15:17:10 +0200
Message-ID: <1275916630.2545.68.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:38247 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755114Ab0FGNRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 09:17:14 -0400
Received: by wwe15 with SMTP id 15so380265wwe.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 06:17:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in_dev_get() -> __in_dev_get_rcu() in a rcu protected function.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/igmp.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 250cb5e..3294f54 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -916,18 +916,19 @@ static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 	read_unlock(&in_dev->mc_list_lock);
 }
 
+/* called in rcu_read_lock() section */
 int igmp_rcv(struct sk_buff *skb)
 {
 	/* This basically follows the spec line by line -- see RFC1112 */
 	struct igmphdr *ih;
-	struct in_device *in_dev = in_dev_get(skb->dev);
+	struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
 	int len = skb->len;
 
 	if (in_dev == NULL)
 		goto drop;
 
 	if (!pskb_may_pull(skb, sizeof(struct igmphdr)))
-		goto drop_ref;
+		goto drop;
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
@@ -937,7 +938,7 @@ int igmp_rcv(struct sk_buff *skb)
 	case CHECKSUM_NONE:
 		skb->csum = 0;
 		if (__skb_checksum_complete(skb))
-			goto drop_ref;
+			goto drop;
 	}
 
 	ih = igmp_hdr(skb);
@@ -957,7 +958,6 @@ int igmp_rcv(struct sk_buff *skb)
 		break;
 	case IGMP_PIM:
 #ifdef CONFIG_IP_PIMSM_V1
-		in_dev_put(in_dev);
 		return pim_rcv_v1(skb);
 #endif
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
@@ -971,8 +971,6 @@ int igmp_rcv(struct sk_buff *skb)
 		break;
 	}
 
-drop_ref:
-	in_dev_put(in_dev);
 drop:
 	kfree_skb(skb);
 	return 0;


