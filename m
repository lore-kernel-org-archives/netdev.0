From: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: regression: tethering fails in 3.5 with iwlwifi
Date: Thu, 20 Sep 2012 14:48:16 +0200
Message-ID: <CANn89iLksBMJ=Ep+VcPSAOPzqst70hk8hR5=mGte2vSx=49zUA@mail.gmail.com>
References: <1347361823.26457.3.camel@sauron.fi.intel.com>
	<1DC40B07CD6EC041A66726C271A73AE6195AE9C8@IRSMSX102.ger.corp.intel.com>
	<1347631355.5263.19.camel@sauron.fi.intel.com>
	<1347640763.5263.24.camel@sauron.fi.intel.com>
	<1347892887.7112.9.camel@sauron.fi.intel.com>
	<1348142775.2388.10.camel@sauron.fi.intel.com>
	<1348144524.4161.26.camel@jlt4.sipsolutions.net>
	<CANn89iJkXrZPB14KU8xA-Dn8_n=H3J4-R60BTZFV+STF9_ASdA@mail.gmail.com>
	<CANn89iKStHAwVZtpgQMzEpByGYG2FKpjSQsJFT-9qQmjw+KJ8g@mail.gmail.com>
	<1348145269.4161.28.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: artem.bityutskiy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1348145269.4161.28.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Or its a buggy protocol ?

IP/UDP/TCP definitely works, but maybe another protocol assumes its
header is in skb->head


On Thu, Sep 20, 2012 at 2:47 PM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Thu, 2012-09-20 at 14:45 +0200, Eric Dumazet wrote:
>> I guess you only need to make sure 14 bytes of ethernet header are
>> available before eth_type_trans(skb, dev);
>>
>> diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
>> index 61c621e..ffe5f84 100644
>> --- a/net/mac80211/rx.c
>> +++ b/net/mac80211/rx.c
>> @@ -1795,9 +1795,13 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
>>
>>                 if (skb) {
>>                         /* deliver to local stack */
>> -                       skb->protocol = eth_type_trans(skb, dev);
>> -                       memset(skb->cb, 0, sizeof(skb->cb));
>> -                       netif_receive_skb(skb);
>> +                       if (pskb_may_pull(skb, sizeof(struct ethhdr))) {
>> +                               skb->protocol = eth_type_trans(skb, dev);
>> +                               memset(skb->cb, 0, sizeof(skb->cb));
>> +                               netif_receive_skb(skb);
>> +                       } else {
>> +                               kfree_skb(skb);
>> +                       }
>>                 }
>>         }
>
> Yeah I was looking at the same code just now. However, we had actually
> inserted the skb_linearize() *after* eth_type_trans(), so I'm confused.
> Maybe it still works, more or less by accident?
>
> johannes
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
