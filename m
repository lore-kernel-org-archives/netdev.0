From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH] net: skbuff: Fix length validation in skb_vlan_pop()
Date: Mon, 19 Sep 2016 09:15:38 +0300
Message-ID: <20160919091538.56defd2b@pixies>
References: <1474193358-20133-1-git-send-email-shmulik.ladkani@gmail.com>
        <CAOrHB_D2ytTK9WjfCPL87E1QomeXg+2GfAvo8N8xCcJULhAC=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33402 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750809AbcISGPx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 02:15:53 -0400
Received: by mail-wm0-f68.google.com with SMTP id w84so5971038wmg.0
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 23:15:53 -0700 (PDT)
In-Reply-To: <CAOrHB_D2ytTK9WjfCPL87E1QomeXg+2GfAvo8N8xCcJULhAC=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, 18 Sep 2016 13:26:30 -0700, pshelar@ovn.org wrote:
> On Sun, Sep 18, 2016 at 3:09 AM, Shmulik Ladkani
> <shmulik.ladkani@gmail.com> wrote:
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 1e329d4112..cc2c004838 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -4537,7 +4537,7 @@ int skb_vlan_pop(struct sk_buff *skb)
> >         } else {
> >                 if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
> >                               skb->protocol != htons(ETH_P_8021AD)) ||
> > -                            skb->len < VLAN_ETH_HLEN))
> > +                            skb->mac_len < VLAN_ETH_HLEN))
> 
> There is already check in __skb_vlan_pop() to validate skb for a vlan
> header. So it is safe to drop this check entirely.

Seems validation in '__skb_vlan_pop' has slightly different semantics:

	unsigned int offset = skb->data - skb_mac_header(skb);

	__skb_push(skb, offset);
	err = skb_ensure_writable(skb, VLAN_ETH_HLEN);

this pushes 'data' back to mac_header, then makes sure there's sufficient
place in skb to _store_ VLAN_ETH_HLEN bytes (by pulling into linear part
if needed, or erroring if skb is too small).

There's no guarantee the original mac header was sized VLAN_ETH_HLEN.

Interpretation of the following 

		if (unlikely((skb->protocol != htons(ETH_P_8021Q) &&
			      skb->protocol != htons(ETH_P_8021AD)) ||
			     skb->len < VLAN_ETH_HLEN))
			return 0;

in 'skb_vlan_pop' might be read as:
"there's no tag, or protocol says its a tag but it's insufficient to pop,
 so lets do nothing".

Is it superflous?

Thanks,
Shmulik
