From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] ipip: do not use 'err' variable for setting return value
Date: Tue, 15 Jan 2013 01:14:10 -0700
Message-ID: <1358237650-15953-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:41124 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753644Ab3AOIOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 03:14:46 -0500
Received: by mail-da0-f42.google.com with SMTP id z17so2190215dal.1
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 00:14:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a bit confusing to set 'err' variable inside and outside of the
block for the return value of ipip_err(). We don't even need this
variable, so clean it all up to spare declaration as well as bunch of
unnecessary initializations and jumps.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/ipv4/ipip.c |   20 +++++++-------------
 1 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 191fc24..d604824 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -343,7 +343,6 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct ip_tunnel *t;
-	int err;
 
 	switch (type) {
 	default:
@@ -372,40 +371,35 @@ static int ipip_err(struct sk_buff *skb, u32 info)
 		break;
 	}
 
-	err = -ENOENT;
 	t = ipip_tunnel_lookup(dev_net(skb->dev), iph->daddr, iph->saddr);
 	if (t == NULL)
-		goto out;
+		return -ENOENT;
 
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
 		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
 				 t->dev->ifindex, 0, IPPROTO_IPIP, 0);
-		err = 0;
-		goto out;
+		return 0;
 	}
 
 	if (type == ICMP_REDIRECT) {
 		ipv4_redirect(skb, dev_net(skb->dev), t->dev->ifindex, 0,
 			      IPPROTO_IPIP, 0);
-		err = 0;
-		goto out;
+		return 0;
 	}
 
 	if (t->parms.iph.daddr == 0)
-		goto out;
+		return -ENOENT;
 
-	err = 0;
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
-		goto out;
+		return 0;
 
 	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
 	else
 		t->err_count = 1;
-	t->err_time = jiffies;
-out:
 
-	return err;
+	t->err_time = jiffies;
+	return 0;
 }
 
 static int ipip_rcv(struct sk_buff *skb)
