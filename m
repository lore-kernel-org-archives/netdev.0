From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: ingress filter message limit
Date: Sat, 31 Jul 2010 12:13:16 -0700
Message-ID: <20100731121316.1adb52c0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52329 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792Ab0GaTNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 15:13:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If user misconfigures ingress and causes a redirection loop, don't
overwhelm the log.  This is also a error case so make it unlikely.
Found by inspection, luckily not in real system.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/dev.c	2010-07-31 12:08:00.808476717 -0700
+++ b/net/core/dev.c	2010-07-31 12:09:32.488882593 -0700
@@ -2646,10 +2646,10 @@ static int ing_filter(struct sk_buff *sk
 	int result = TC_ACT_OK;
 	struct Qdisc *q;
 
-	if (MAX_RED_LOOP < ttl++) {
-		printk(KERN_WARNING
-		       "Redir loop detected Dropping packet (%d->%d)\n",
-		       skb->skb_iif, dev->ifindex);
+	if (unlikely(MAX_RED_LOOP < ttl++)) {
+		if (net_ratelimit())
+			pr_warning( "Redir loop detected Dropping packet (%d->%d)\n",
+			       skb->skb_iif, dev->ifindex);
 		return TC_ACT_SHOT;
 	}
 
