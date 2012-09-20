From: Eric Dumazet <edumazet@google.com>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 14:46:52 +0200
Message-ID: <CANn89iLnv2kWLd_hTpMXjMJ=r+hOvb2q2Oy6L-s5+6SzqxYvjA@mail.gmail.com>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	<1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	<1347631355.5263.19.camel@sauron.fi.intel.com>
	<1347640763.5263.24.camel@sauron.fi.intel.com>
	<1347892887.7112.9.camel@sauron.fi.intel.com>
	<1348142775.2388.10.camel@sauron.fi.intel.com>
	<1348144524.4161.26.camel@jlt4.sipsolutions.net>
	<CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA@mail.gmail.com>
	<CANn89iKStHAwVZtpgQMzEpByGYG2FKpjSQsJFT-9qQmjw+KJ8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: artem.bityutskiy@linux.intel.com, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38418 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754676Ab2ITMqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 08:46:53 -0400
Received: by pbbrr4 with SMTP id rr4so132614pbb.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 05:46:52 -0700 (PDT)
In-Reply-To: <CANn89iKStHAwVZtpgQMzEpByGYG2FKpjSQsJFT-9qQmjw+KJ8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or its the lines with CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS ?

What arch is it ?


On Thu, Sep 20, 2012 at 2:45 PM, Eric Dumazet <edumazet@google.com> wrote:
> I guess you only need to make sure 14 bytes of ethernet header are
> available before eth_type_trans(skb, dev);
>
> diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
> index 61c621e..ffe5f84 100644
> --- a/net/mac80211/rx.c
> +++ b/net/mac80211/rx.c
> @@ -1795,9 +1795,13 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
>
>                 if (skb) {
>                         /* deliver to local stack */
> -                       skb->protocol = eth_type_trans(skb, dev);
> -                       memset(skb->cb, 0, sizeof(skb->cb));
> -                       netif_receive_skb(skb);
> +                       if (pskb_may_pull(skb, sizeof(struct ethhdr))) {
> +                               skb->protocol = eth_type_trans(skb, dev);
> +                               memset(skb->cb, 0, sizeof(skb->cb));
> +                               netif_receive_skb(skb);
> +                       } else {
> +                               kfree_skb(skb);
> +                       }
>                 }
>         }
>
>
> On Thu, Sep 20, 2012 at 2:40 PM, Eric Dumazet <edumazet@google.com> wrote:
>> OK, but which netif_receive_skb(), as I count 5 occurrences in
>> net/mac80211/rx.c ?
>>
>> Instead of skb_linearize() calls
>>
>> you could try several values of XXX in
>>
>> pskb_may_pull(skb, XXX)
>>
>> So that you make sure XXX bytes are available in skb->head, and not
>> the whole frame.
>>
>> One you know the limit for XXX, it might give a clue where a
>> pskb_may_pull(skb, XXX) is missing.
>>
>> On Thu, Sep 20, 2012 at 2:35 PM, Johannes Berg
>> <johannes@sipsolutions.net> wrote:
>>> Hi,
>>>
>>>> >             56138f5 iwlwifi: dont pull too much payload in skb head
>>>> >             3edaf3e mac80211: manage AP netdev carrier state
>>>>
>>>> The second patch (AP carrier state) actually exposed a connman issue
>>>> which I fixed and submitted a connman patch:
>>>> http://lists.connman.net/pipermail/connman/2012-September/011232.html
>>>>
>>>> However, Eric's patch still causes tethering problems to me.
>>>
>>>
>>> Let me recap a bit. Artem is using connman, which sets up the wifi
>>> interface as part of a bridge. It runs wpa_supplicant to create an AP
>>> (only AP and mesh mode interfaces can be bridged anyway).
>>>
>>>
>>> Eric, you said:
>>>
>>>> I would say some part of the stack assumes a header (I dont know wich
>>>> one ?) is pulled in skb->head/data, and thats a bug.
>>>>
>>>> Always use pskb_may_pull(skb, XXX) to make sure you can access XXX
>>>> bytes in skb->data
>>>
>>> I thought we'd figure out which part of the stack assumes a header, so I
>>> asked Artem to test a one-line patch which adds "skb_linearize()" before
>>> "netif_receive_skb()" in mac80211. This makes it work, but I'm not sure
>>> where after that the bad assumption might be.
>>>
>>> johannes
>>>
