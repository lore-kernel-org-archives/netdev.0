From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V4 1/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Tue, 14 Jan 2014 23:51:04 +0200
Message-ID: <CAJZOPZ+1JrMiuh3csp8P56NJ5LphszneO_zwmShut3KxFuxaTQ@mail.gmail.com>
References: <1389715212-14504-1-git-send-email-ogerlitz@mellanox.com>
	<1389715212-14504-2-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx_R+J3UMtdOkfQQjdBN+JMLzrbY6q3r+VaHxJEDrSzt1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:49197 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857AbaANVvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 16:51:04 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so214478pde.0
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 13:51:04 -0800 (PST)
In-Reply-To: <CA+mtBx_R+J3UMtdOkfQQjdBN+JMLzrbY6q3r+VaHxJEDrSzt1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 7:51 PM, Tom Herbert <therbert@google.com> wrote:
> On Tue, Jan 14, 2014 at 8:00 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> +static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>> +{
>> +       struct udp_offload_priv *uo_priv;
>> +       struct sk_buff *p, **pp = NULL;
>> +       struct udphdr *uh, *uh2;
>> +       unsigned int hlen, off;
>> +       int flush = 1;
>> +
>> +       if (NAPI_GRO_CB(skb)->udp_mark ||
>> +           (!skb->encapsulation && skb->ip_summed != CHECKSUM_COMPLETE))
>> +               goto out;
>> +
>> +       /* mark that this skb passed once through the udp gro layer */
>> +       NAPI_GRO_CB(skb)->udp_mark = 1;
>> +
>> +       off  = skb_gro_offset(skb);
>> +       hlen = off + sizeof(*uh);
>> +       uh   = skb_gro_header_fast(skb, off);
>> +       if (skb_gro_header_hard(skb, hlen)) {
>> +               uh = skb_gro_header_slow(skb, hlen, off);
>> +               if (unlikely(!uh))
>> +                       goto out;
>> +       }
>> +
>> +       rcu_read_lock();
>> +       uo_priv = rcu_dereference(udp_offload_base);
>> +       for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
>> +               if (uo_priv->offload->port == uh->dest &&
>> +                   uo_priv->offload->callbacks.gro_receive) {
>> +                       atomic_inc(&uo_priv->refcount);
>> +                       goto unflush;
>> +               }
>> +       }
>> +       rcu_read_unlock();
>> +       goto out;
>> +
>> +unflush:
>> +       rcu_read_unlock();
>> +       flush = cd
>> +
>> +       for (p = *head; p; p = p->next) {
>> +               if (!NAPI_GRO_CB(p)->same_flow)
>> +                       continue;
>> +
>> +               uh2 = (struct udphdr   *)(p->data + off);
>> +               if ((*(u32 *)&uh->source != *(u32 *)&uh2->source)) {
>> +                       NAPI_GRO_CB(p)->same_flow = 0;
>> +                       continue;
>> +               }
>> +       }
>> +
>> +       skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
>> +       pp = uo_priv->offload->callbacks.gro_receive(head, skb);
>> +       udp_offload_put(uo_priv);
>> +
>> +out:
>> +       NAPI_GRO_CB(skb)->flush |= flush;
>> +       return pp;
>> +}
>> +
>> +static int udp_gro_complete(struct sk_buff *skb, int nhoff)
>> +{
>> +       struct udp_offload_priv *uo_priv;
>> +       __be16 newlen = htons(skb->len - nhoff);
>> +       struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
>> +       int err = -ENOSYS;
>> +
>> +       uh->len = newlen;
>> +
>> +       rcu_read_lock();
>> +
>> +       uo_priv = rcu_dereference(udp_offload_base);
>> +       for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
>> +               if (uo_priv->offload->port == uh->dest &&
>> +                   uo_priv->offload->callbacks.gro_complete)
>> +                       goto found;
>> +       }
>> +
>> +       rcu_read_unlock();
>> +       return err;
>> +
>> +found:
>> +       atomic_inc(&uo_priv->refcount);
>
> This is an expensive operation in the critical path.

I know, but I don't see how to get away without having the ref/unref
wrapping, ideas welcome

> Can uo_priv be protected by rcu also?

uo_priv is the actual element which is rcu protected, not sure to
follow on your question.



>
>> +       rcu_read_unlock();
>> +       err = uo_priv->offload->callbacks.gro_complete(skb, nhoff + sizeof(struct udphdr));
>> +       udp_offload_put(uo_priv);
>> +       return err;
>> +}
>> +
>>  static const struct net_offload udpv4_offload = {
>>         .callbacks = {
>>                 .gso_send_check = udp4_ufo_send_check,
>>                 .gso_segment = udp4_ufo_fragment,
>> +               .gro_receive  = udp_gro_receive,
>> +               .gro_complete = udp_gro_complete,
>>         },
>>  };
>>
>> --
>> 1.7.1
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
