From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2] ip_tunnels: Use skb-len to PMTU check.
Date: Mon, 1 Jul 2013 00:06:22 -0700
Message-ID: <CALnjE+qW2P031bwOaTkC-kP2LOvOydBQ0YzBAhd71D66Wugfig@mail.gmail.com>
References: <1372660232-12174-1-git-send-email-pshelar@nicira.com>
	<20130701094132.3019afb4@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:44541 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751880Ab3GAHGX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 03:06:23 -0400
Received: by mail-qe0-f50.google.com with SMTP id f6so1527985qej.9
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 00:06:22 -0700 (PDT)
In-Reply-To: <20130701094132.3019afb4@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 30, 2013 at 11:41 PM, Timo Teras <timo.teras@iki.fi> wrote:
> On Sun, 30 Jun 2013 23:30:32 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>> In path mtu check, ip header total length works for gre device
>> but not for gre-tap device.  Use skb len which is consistent
>> for all tunneling types.  This is old bug in gre.
>> This also fixes mtu calculation bug introduced by
>> commit c54419321455631079c7d (GRE: Refactor GRE tunneling code).
>>
>> Reported-by: Timo Teras <timo.teras@iki.fi>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>> v1-v2:
>>  - Fix pmtu set.
>>  - This patch also restructures code which help couple of
>>    improvements I have.
>
> Looks good to me. One additional comment below.
>
>> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
>> index 7fa8f08..ae5b78c 100644
>> --- a/net/ipv4/ip_tunnel.c
>> +++ b/net/ipv4/ip_tunnel.c
>> @@ -486,6 +486,53 @@ drop:
>>  }
>>  EXPORT_SYMBOL_GPL(ip_tunnel_rcv);
>>
>> +static int tnl_update_pmtu(struct net_device *dev, struct sk_buff
>> *skb,
>> +                         struct rtable *rt, __be16 df)
>> +{
>> +     struct ip_tunnel *tunnel = netdev_priv(dev);
>> +     int pkt_size = skb->len - tunnel->hlen;
>> +     int mtu;
>> +
>> +     if (df)
>> +             mtu = dst_mtu(&rt->dst) - dev->hard_header_len
>> +                                     - sizeof(struct iphdr) -
>> tunnel->hlen;
>> +     else
>> +             mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) :
>> dev->mtu; +
>> +     if (skb_dst(skb))
>> +             skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL,
>> skb, mtu); +
>
> Since mtu can change for skb_dst() only if df is set, would it make
> sense to move the whole update_pmtu call inside if (df) {} block?
>
I am not sure abt that. Other events can change mtu.
anyways I think it would be better to have separate patch for that if
required. This patch already fixes two (related) issues.


> - Timo
