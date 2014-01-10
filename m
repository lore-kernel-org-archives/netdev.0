From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Fri, 10 Jan 2014 10:54:37 -0800
Message-ID: <1389380077.31367.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	 <1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	 <1389375935.31367.102.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx-8=tiYw=-_TydO0bC_tJXK6MqxjnZQaCXqUtxLSF7xhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:47531 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaAJSyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:54:41 -0500
Received: by mail-qc0-f172.google.com with SMTP id c9so2771260qcz.31
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 10:54:41 -0800 (PST)
In-Reply-To: <CA+mtBx-8=tiYw=-_TydO0bC_tJXK6MqxjnZQaCXqUtxLSF7xhQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 10:15 -0800, Tom Herbert wrote:

> The objective is to compute the rxhash at most once per packet.

Once per GRO packet ( up to 45 MSS) or once per incoming frame ( 1 MSS
) ?

Your patch computes rxhash for every incoming frame.

> 
> > If your patch was doing this, I would have no complain.
> >
> > (No new conditional branch, and skb->rxhash, if provided by the NIC,
> > can give a hint.)
> >
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index ce01847793c0..c9f7a26d7ce7 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3798,7 +3798,8 @@ static void gro_list_prepare(struct napi_struct *napi, struct sk_buff *skb)
> >         for (p = napi->gro_list; p; p = p->next) {
> >                 unsigned long diffs;
> >
> > -               diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
> > +               diffs = p->rxhash ^ skb->rxhash;
> > +               diffs |= (unsigned long)p->dev ^ (unsigned long)skb->dev;
> >                 diffs |= p->vlan_tci ^ skb->vlan_tci;
> >                 if (maclen == ETH_HLEN)
> >                         diffs |= compare_ether_header(skb_mac_header(p),
> >
> As I said in the commit log, the skb->rxhash should be a very strong
> indicator of that flows will match (maybe >99% ?), so putting that
> first potentially short circuits a lot of work even in just this
> function.

Are you speaking of your "goto skip;" ?

compare_ether_header() is done with 10 instructions on x86_64

There is no point trying to avoid it.

Really, 99% of the time gro_list contains zero or one single slot, I
have hard data saying so.

If you want to optimize the case where list is fully populated (because
of yet another synthetic benchmark you use), you really need to build a
temporary list so that all layers do not even have to check
NAPI_GRO_CB(p)->same_flow

Each gro handler would remove non matching flow from this temp list.

-> when we finally reach tcp_gro_receive(), list would contain a single
element.
