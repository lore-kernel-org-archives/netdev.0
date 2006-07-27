From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len space
Date: Thu, 27 Jul 2006 19:28:03 +0200
Message-ID: <m3ac6vx8ik.fsf@defiant.localdomain>
References: <m3zmevqhgn.fsf@defiant.localdomain>
	<20060727164334.GA2779@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:63389 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1751873AbWG0R2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 13:28:06 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060727164334.GA2779@ms2.inr.ac.ru> (Alexey Kuznetsov's message of "Thu, 27 Jul 2006 20:43:34 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> writes:

> ip_output() worries about the space, which it needs.

Well, I wrote ip_output() to give idea about the place but the
actual function, as shown in the patch, is ip_finish_output2().

It currently reads:
        int hh_len = LL_RESERVED_SPACE(dev);

        /* Be paranoid, rather than too clever. */
        if (unlikely(skb_headroom(skb) < hh_len && dev->hard_header)) {
                struct sk_buff *skb2;

                skb2 = skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
                if (skb2 == NULL) {
                        kfree_skb(skb);
                        return -ENOMEM;
                }
                if (skb->sk)
                        skb_set_owner_w(skb2, skb->sk);
                kfree_skb(skb);
                skb = skb2;
        }

while

#define LL_RESERVED_SPACE(dev) \
        (((dev)->hard_header_len&~(HH_DATA_MOD - 1)) + HH_DATA_MOD)

so IMHO the above code fragment deals with device needs.

> If some place needs more, it is its problem to check.
> To the moment where it is used, hard_header_len can even change.
>
> It can be applied, but it does not change the fact, that those
> placed which fail now must check the condition as well.

Are you sure about that? It would mean almost devices, including
Ethernet, are at risk:

void ether_setup(struct net_device *dev)
{
        dev->change_mtu         = eth_change_mtu;
        dev->hard_header        = eth_header;
...

int eth_header(struct sk_buff *skb, struct net_device *dev, unsigned short type,
           void *daddr, void *saddr, unsigned len)
{
        struct ethhdr *eth = (struct ethhdr *)skb_push(skb,ETH_HLEN);


>> A similar problem may be present in psched_mtu().
>
> Nothing similar. The result psched_mtu() is compared with skb->len,
> how it is seen by qdiscs. If hard_header is NULL, it sees skbs
> without header.

Right, by "similar problem" I meant ignoring hard_header_len and not
kernel panic.
-- 
Krzysztof Halasa
