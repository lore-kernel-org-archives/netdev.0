From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Fri, 08 Jun 2012 08:47:20 +0200
Message-ID: <1339138040.6001.39.camel@edumazet-glaptop>
References: <1339135057.6001.20.camel@edumazet-glaptop>
	 <20120607.230216.2014005732863772019.davem@davemloft.net>
	 <1339135881.6001.25.camel@edumazet-glaptop>
	 <20120607.231501.463746858434969001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:36956 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299Ab2FHGr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 02:47:27 -0400
Received: by eaak11 with SMTP id k11so792655eaa.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 23:47:26 -0700 (PDT)
In-Reply-To: <20120607.231501.463746858434969001.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-07 at 23:15 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 08 Jun 2012 08:11:21 +0200
> 
> > On Thu, 2012-06-07 at 23:02 -0700, David Miller wrote:
> >> Hmmm, isn't that what qdisc_skb_cb is for?  And even private data is
> >> explicitly allocated:
> >> 
> >> >  	unsigned char		data[24];
> >> 
> >> there. :-)
> >> 
> > 
> > Yes, but some other layers can use the same trick so it might collide.
> > 
> > Inserting the bond field in qdisc_skb_cb (level0) is safer.
> 
> Do you suggest that Infiniband does the same thing? :-)

I wonder if another way to solve this is not letting ndo_select_queue()
method the responsibility to call skb_set_queue_mapping() itself ?

(ie removing skb_set_queue_mapping() done in dev_pick_tx())

bonding would not have to save/restore skb queue mapping ?

Partial patch : (we have to audit all ndo_select_queue()

diff --git a/net/core/dev.c b/net/core/dev.c
index cd09819..c6c92d5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2368,6 +2368,7 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 
 	if (dev->real_num_tx_queues == 1)
 		queue_index = 0;
+		skb_set_queue_mapping(skb, queue_index);
 	else if (ops->ndo_select_queue) {
 		queue_index = ops->ndo_select_queue(dev, skb);
 		queue_index = dev_cap_txqueue(dev, queue_index);
@@ -2391,9 +2392,9 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					sk_tx_queue_set(sk, queue_index);
 			}
 		}
+		skb_set_queue_mapping(skb, queue_index);
 	}
 
-	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);
 }
 
