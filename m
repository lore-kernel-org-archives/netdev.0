From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] xennet_start_xmit assumptions
Date: Wed, 25 Jan 2017 15:06:53 +0000
Message-ID: <fa531e2ed014488baa10556c724e176c@AMSPEX02CL03.citrite.net>
References: <20170118153132.GB9258@oracle.com>
 <20170118192528.GA6847@char.us.oracle.com>
 <de0d7a7db4c24b46838aee7623d5d2a3@AMSPEX02CL03.citrite.net>
 <20170119111426.GA22018@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Wei Liu <wei.liu2@citrix.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:32793 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750723AbdAYPHc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 10:07:32 -0500
In-Reply-To: <20170119111426.GA22018@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sowmini Varadhan [mailto:sowmini.varadhan@oracle.com]
> Sent: 19 January 2017 11:14
> To: Paul Durrant <Paul.Durrant@citrix.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>; Wei Liu
> <wei.liu2@citrix.com>; netdev@vger.kernel.org; xen-
> devel@lists.xenproject.org
> Subject: Re: [Xen-devel] xennet_start_xmit assumptions
> 
> On (01/19/17 09:36), Paul Durrant wrote:
> >
> > Hi Sowmini,
> >
> >   Sounds like a straightforward bug to me... netfront should be able
> > to handle an empty skb and clearly, if it's relying on skb_headlen()
> > being non-zero, that's not the case.
> >
> >   Paul
> 
> I see. Seems like there are 2 things broken here: recovering
> from skb->len = 0, and recovering from  the more complex
> case of (skb->len > 0 && skb_headlen(skb) == 0)
> 
> Do you folks want to take a shot at fixing this,
> since you know the code better? If you are interested,
> I can share my test program to help you reproduce the
> simpler skb->len == 0 case, but it's the fully non-linear
> skbs that may be more interesting to reproduce/fix.
> 
> I'll probably work on fixing packet_snd to return -EINVAL
> or similar when the len is zero this week.
> 

Sowmini,

  I knocked together the following patch, which seems to work for me:

---8<---
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 40f26b6..a957c89 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -567,6 +567,10 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
        u16 queue_index;
        struct sk_buff *nskb;

+       /* Drop packets that are not at least ETH_HLEN in length */
+       if (skb->len < ETH_HLEN)
+               goto drop;
+
        /* Drop the packet if no queues are set up */
        if (num_queues < 1)
                goto drop;
@@ -609,6 +613,8 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
        }

        len = skb_headlen(skb);
+       if ((len < ETH_HLEN) && !__pskb_pull_tail(skb, ETH_HLEN))
+               goto drop;

        spin_lock_irqsave(&queue->tx_lock, flags);

---8<---

  Making netfront cope with a fully non-linear skb looks like it would be quite intrusive and probably not worth it so I opted for just doing the ETH_HLEN pull-tail if necessary. Can you check it works for you?

  Paul
