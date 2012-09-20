From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 15:22:02 +0200
Message-ID: <1348147322.31352.69.camel@edumazet-glaptop>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	 <1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	 <1347631355.5263.19.camel@sauron.fi.intel.com>
	 <1347640763.5263.24.camel@sauron.fi.intel.com>
	 <1347892887.7112.9.camel@sauron.fi.intel.com>
	 <1348142775.2388.10.camel@sauron.fi.intel.com>
	 <1348144524.4161.26.camel@jlt4.sipsolutions.net>
	 <CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA@mail.gmail.com>
	 <CANn89iKStHAwVZtpgQMzEpByGYG2FKpjSQsJFT-9qQmjw+KJ8g@mail.gmail.com>
	 <1348145936.2388.18.camel@sauron.fi.intel.com>
	 <CANn89i+9Th=xVgDgoy7tHwKtLNpOC8rgJkA09nQ1Yf0zvqBw6w@mail.gmail.com>
	 <1348147353.2388.19.camel@sauron.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: artem.bityutskiy@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62400 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533Ab2ITNWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 09:22:08 -0400
In-Reply-To: <1348147353.2388.19.camel@sauron.fi.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 16:22 +0300, Artem Bityutskiy wrote:

> 
> OK, I've tried almost this (see below) and it solves my issue:
> 
> diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
> index 965e6ec..7f079d0 100644
> --- a/net/mac80211/rx.c
> +++ b/net/mac80211/rx.c
> @@ -1798,9 +1798,13 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
>  
>                 if (skb) {
>                         /* deliver to local stack */
> -                       skb->protocol = eth_type_trans(skb, dev);
> -                       memset(skb->cb, 0, sizeof(skb->cb));
> -                       netif_receive_skb(skb);
> +                       if (pskb_may_pull(skb, 40)) {
> +                               skb->protocol = eth_type_trans(skb, dev);
> +                               memset(skb->cb, 0, sizeof(skb->cb));
> +                               netif_receive_skb(skb);
> +                       } else {
> +                               kfree_skb(skb);
> +                       }
>                 }
>         }
> 

OK but you cant do that, or small frames will be dropped.

Anyway its a hack, we should find the buggy layer.

You could use dropwatch (drop_monitor) to check where frame is dropped.

modprobe drop_monitor
dropwatch -l kas
