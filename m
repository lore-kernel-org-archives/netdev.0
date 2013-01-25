From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 2/2] v2 GRE: Add segmentation offload for GRE
Date: Thu, 24 Jan 2013 16:14:43 -0800
Message-ID: <CALnjE+rbqCgRwxr1TtFH92vKSJoTRhBP50f+jQmgWB9LanQhYw@mail.gmail.com>
References: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
	<1359070199.12374.2557.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:35723 "HELO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752277Ab3AYAOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 19:14:45 -0500
Received: by mail-qa0-f72.google.com with SMTP id dx4so982760qab.3
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 16:14:43 -0800 (PST)
In-Reply-To: <1359070199.12374.2557.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 3:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-01-24 at 14:16 -0800, Pravin B Shelar wrote:
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>> Fixed according to comments from Jesse and Eric.
>>  - Factored a MAC layer handler out of skb_gso_segment().
>>  - Eliminated copy operation from gre_gso_segment().
>>  - Refresh header pointer after pskb_may_pull().
>
> Seems nice !
>
>> +     if (skb_is_gso(skb)) {
>> +             err = skb_unclone(skb, GFP_ATOMIC);
>> +             if (unlikely(err))
>> +                     goto error;
>> +             skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
>> +             return skb;
>> +     } else if (skb->ip_summed == CHECKSUM_PARTIAL) {
>> +             /* Pages aren't locked and could change at any time.
>> +              * If this happens after we compute the checksum, the
>> +              * checksum will be wrong.  We linearize now to avoid
>> +              * this problem.
>> +              */
>> +             if (skb_is_nonlinear(skb)) {
>> +                     err = __skb_linearize(skb);
>> +                     if (unlikely(err))
>> +                             goto error;
>> +             }
>> +
>> +             err = skb_checksum_help(skb);
>> +             if (unlikely(err))
>> +                     goto error;
>> +     }
>> +
>
> I really don't understand why you put chunk this in this patch.
>
> Packet being GSO or not, the underlying problem still remains.
>
> This must be addressed separately and at a different layer.
>
> (in skb_checksum_help() most probably)
>
> If the packet is GSO and we compute checksum in software,
> then we also have to copy all frags that could potentially
> be overwritten.
>

I think this patch does fix csum issue without causing any performance
regression. So this patch shld be enough to solve GRE-GSO issue. Once
you have fix, this code can be optimized even more.

>
>> +     skb->ip_summed = CHECKSUM_NONE;
>> +
>> +     return skb;
>> +
>> +error:
>> +     kfree_skb(skb);
>> +     return ERR_PTR(err);
>> +}
>> +
>>  static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>>  {
>>       struct ip_tunnel *tunnel = netdev_priv(dev);
>> @@ -751,10 +787,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>>       __be32 dst;
>>       int    mtu;
>>       u8     ttl;
>> -
>> -     if (skb->ip_summed == CHECKSUM_PARTIAL &&
>> -         skb_checksum_help(skb))
>> -             goto tx_error;
>> +     int pkt_len;
>> +     struct pcpu_tstats *tstats;
>> +     int err;
>>
>>       if (dev->type == ARPHRD_ETHER)
>>               IPCB(skb)->flags = 0;
>> @@ -852,13 +887,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>>
>>       if (skb->protocol == htons(ETH_P_IP)) {
>>               df |= (old_iph->frag_off&htons(IP_DF));
>> -
>> -             if ((old_iph->frag_off&htons(IP_DF)) &&
>> -                 mtu < ntohs(old_iph->tot_len)) {
>> -                     icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
>> -                     ip_rt_put(rt);
>> -                     goto tx_error;
>> -             }
>
> Not clear why this chunk can be safely removed, even for non GSO
> packet ?
>
This actually does not work specially for TAP devices since ICMP
response won't work because the tunnel endpoint is not part of that IP
network.
This was discussed in VXLAN patch thread.
(http://markmail.org/message/xmqmvdh4noljfq2n).

But I agree we shld keep it for for non tap GRE and non-gso packets.
