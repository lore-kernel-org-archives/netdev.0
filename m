From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 01/54] uml/net_kern: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 06:01:12 -0700
Message-ID: <1395752472.12610.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:63086 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbaCYNBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:01:15 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so413703pad.17
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 06:01:15 -0700 (PDT)
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:04 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in uml_net_start_xmit
> as it can be called in hard irq and other contexts.
> 
> dev_consume_skb_any is used as uml_net_start_xmit typically
> consumes (not drops) packets.

Well, this is not exactly true. This driver certainly can drop packets.

Here is an untested/not even compiled patch.

diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 39f186252e02..8d1df7ed759e 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -212,6 +212,7 @@ static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct uml_net_private *lp = netdev_priv(dev);
 	unsigned long flags;
 	int len;
+	enum skb_free_reason reason = SKB_REASON_CONSUMED;
 
 	netif_stop_queue(dev);
 
@@ -228,19 +229,18 @@ static int uml_net_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* this is normally done in the interrupt when tx finishes */
 		netif_wake_queue(dev);
-	}
-	else if (len == 0) {
-		netif_start_queue(dev);
-		dev->stats.tx_dropped++;
-	}
-	else {
+	} else {
+		reason = SKB_REASON_DROPPED;
 		netif_start_queue(dev);
-		printk(KERN_ERR "uml_net_start_xmit: failed(%d)\n", len);
+		if (len == 0)
+			dev->stats.tx_dropped++;
+		else
+			pr_err("uml_net_start_xmit: failed(%d)\n", len);
 	}
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
-	dev_kfree_skb(skb);
+	__dev_kfree_skb_any(skb, reason);
 
 	return NETDEV_TX_OK;
 }
