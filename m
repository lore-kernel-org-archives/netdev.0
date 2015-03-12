From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Wed, 11 Mar 2015 17:00:27 -0700
Message-ID: <1426118427.11398.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
	 <CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
	 <1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7Pa6ypGoUr5jJfbayzwjLA-C78NOa1iPmsbmx+wXP56AA@mail.gmail.com>
	 <1426104582.11398.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M8EFF=y7LOqsiHMsT+Q1e+3wxAE93njkSk3p9nYc2gTA@mail.gmail.com>
	 <1426110450.11398.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7N88DFPpfPeN5cqru7oODfew1ZUdT80R0fj1QkQsx-siw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33485 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbbCLAAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 20:00:34 -0400
Received: by iecvj10 with SMTP id vj10so3203773iec.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 17:00:33 -0700 (PDT)
In-Reply-To: <CAHA+R7N88DFPpfPeN5cqru7oODfew1ZUdT80R0fj1QkQsx-siw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 15:12 -0700, Cong Wang wrote:

> I knew we can modify skb->priority in a few ways, for example skbedit.
> 
> That is not my concern, all what I am thinking is there is some
> way in application layer to bypass our tc filters, which is not expected
> to happen for me. Given our specific case, I want to propose to clear
> skb->priority after moving out of a netns:
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 962ee9d..2301f01 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1694,6 +1694,7 @@ int __dev_forward_skb(struct net_device *dev,
> struct sk_buff *skb)
>         }
> 
>         skb_scrub_packet(skb, true);
> +       skb->priority = 0;
>         skb->protocol = eth_type_trans(skb, dev);
>         skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);

This looks more reasonable than your prior change to fq_codel, sfq, and
others.

If you use mavclan or ipvlan, not all paths will use __dev_forward_skb()

So I am guessing you use veth maybe. Who knows.

Note that you could instead use :

 skb->priority = skb->priority & TC_PRIO_MAX;

This way, TC_PRIO_CONTROL legitimate traffic would not be downgraded to
TC_PRIO_BESTEFFORT.

This all looks like a policy decision, and we probably should not hard
code it in the kernel : Some users have trusted applications running in
containers.
