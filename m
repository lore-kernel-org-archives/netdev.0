From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: core: Remove redundant call to 'nf_reset' in
 'dev_forward_skb'
Date: Fri, 29 Mar 2013 12:17:36 -0700
Message-ID: <1364584656.5113.55.camel@edumazet-glaptop>
References: <1364462006-5814-1-git-send-email-shmulik.ladkani@gmail.com>
	 <20130329.151120.296920819953677221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shmulik.ladkani@gmail.com, greearb@candelatech.com,
	netdev@vger.kernel.org, rgohita@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f177.google.com ([209.85.210.177]:52681 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756784Ab3C2TRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:17:39 -0400
Received: by mail-ia0-f177.google.com with SMTP id w33so622444iag.22
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 12:17:38 -0700 (PDT)
In-Reply-To: <20130329.151120.296920819953677221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-29 at 15:11 -0400, David Miller wrote:
> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Date: Thu, 28 Mar 2013 11:13:26 +0200
> 
> > 'nf_reset' is called just prior calling 'netif_rx'.
> > No need to call it twice.
> > 
> > Reported-by: Igor Michailov <rgohita@gmail.com>
> > Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> I do not see this happening in the:
> 
> 	macvlan_start_xmit()
> 
> 		 --> macvlan_queue_xmit()
> 
> code path.
> 
> I'm not applying this patch.  There seems to be no real agreement
> that the caller of dev_forward_skb() takes care of the nf_reset().
> 
> And wouldn't it be better to consolidate the nf_reset() calls
> into one place instead of several, increasing the audit burdon.
> 

Hmm, I believe you misread this patch :

nf_reset() is called _twice_ in dev_forward_skb()

int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
{
        if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
                if (skb_copy_ubufs(skb, GFP_ATOMIC)) {
                        atomic_long_inc(&dev->rx_dropped);
                        kfree_skb(skb);
                        return NET_RX_DROP;
                }
        }

        skb_orphan(skb);
<1>     nf_reset(skb);

        if (unlikely(!is_skb_forwardable(dev, skb))) {
                atomic_long_inc(&dev->rx_dropped);
                kfree_skb(skb);
                return NET_RX_DROP;
        }
        skb->skb_iif = 0;
        skb->dev = dev;
        skb_dst_drop(skb);
        skb->tstamp.tv64 = 0;
        skb->pkt_type = PACKET_HOST;
        skb->protocol = eth_type_trans(skb, dev);
        skb->mark = 0;
        secpath_reset(skb);
<2>     nf_reset(skb);
        return netif_rx(skb);
}
