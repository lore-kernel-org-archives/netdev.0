From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Tue, 7 Jan 2014 22:21:55 +0200
Message-ID: <CAJZOPZKecwB9S_+goH2SvcXS+03rYk=73eVNBUoEMz=M5484RA@mail.gmail.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	<1389108594-665-2-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx_UDWVP2KEB04d-kS4fB1DyYX4m-sC8YOZDy-Wty3cmtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32934 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbaAGUWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:22:00 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so852700pab.19
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 12:21:59 -0800 (PST)
In-Reply-To: <CA+mtBx_UDWVP2KEB04d-kS4fB1DyYX4m-sC8YOZDy-Wty3cmtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 7, 2014 at 8:44 PM, Tom Herbert <therbert@google.com> wrote:
> Or, thanks for posting the patches!
>
> We should also support the case where direct encapsulation is being
> done, that is there is no encapsulation header after UDP and the
> protocol of the encapsulated packet is inferred by the port number
> (e.g. GRE/UDP, TCP/UDP, SCTP/UDP, etc.). This is probably an
> additional field in net_offload struct for next protocol, a little
> more API, and pretty trivial handlers in UDP code.

The way I have set that follows your guideline under which the
encapsulating method is derived from the udp destination port in the
sense that the encapsulating protocol can do what they want in the
gro_receive/complete handlers entry they plant per that udp port,
isn't that generic enough?


>
>
> On Tue, Jan 7, 2014 at 7:29 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> Add GRO handlers for protocols that do UDP encapsulation, with the intent of
>> being able to coalesce packets which encapsulate packets belonging to
>> the same TCP session.
>>
>> For GRO purposes, the destination UDP port takes the role of the ether type
>> field in the ethernet header or the next protocol in the IP header.
>>
>> The UDP GRO handler will only attempt to coalesce packets whose destination
>> port is registered to have gro handler.
>>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> ---
>>  include/net/protocol.h |    6 ++++
>>  net/ipv4/protocol.c    |   21 ++++++++++++++
>>  net/ipv4/udp_offload.c |   69 ++++++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 96 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/net/protocol.h b/include/net/protocol.h
>> index fbf7676..d776c08 100644
>> --- a/include/net/protocol.h
>> +++ b/include/net/protocol.h
>> @@ -92,6 +92,10 @@ extern const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS];
>>  extern const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS];
>>  extern const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS];
>>
>> +
>> +#define MAX_UDP_PORT (1 << 16)
>> +extern const struct net_offload __rcu *udp_offloads[MAX_UDP_PORT];
>> +
>>  #if IS_ENABLED(CONFIG_IPV6)
>>  extern const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
>>  #endif
>> @@ -102,6 +106,8 @@ int inet_add_offload(const struct net_offload *prot, unsigned char num);
>>  int inet_del_offload(const struct net_offload *prot, unsigned char num);
>>  void inet_register_protosw(struct inet_protosw *p);
>>  void inet_unregister_protosw(struct inet_protosw *p);
>> +int udp_add_offload(const struct net_offload *prot, __be16 port);
>> +int udp_del_offload(const struct net_offload *prot, __be16 port);
>>
>>  #if IS_ENABLED(CONFIG_IPV6)
>>  int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
>> diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
>> index 46d6a1c..426eae5 100644
>> --- a/net/ipv4/protocol.c
>> +++ b/net/ipv4/protocol.c
>> @@ -30,6 +30,7 @@
>>
>>  const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostly;
>>  const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_mostly;
>> +const struct net_offload __rcu *udp_offloads[MAX_UDP_PORT] __read_mostly;
>>
>>  int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
>>  {
>> @@ -51,6 +52,13 @@ int inet_add_offload(const struct net_offload *prot, unsigned char protocol)
>>  }
>>  EXPORT_SYMBOL(inet_add_offload);
>>
>> +int udp_add_offload(const struct net_offload *prot, __be16 port)
>> +{
>> +       return !cmpxchg((const struct net_offload **)&udp_offloads[port],
>> +                       NULL, prot) ? 0 : -1;
>> +}
>> +EXPORT_SYMBOL(udp_add_offload);
>> +
>>  int inet_del_protocol(const struct net_protocol *prot, unsigned char protocol)
>>  {
>>         int ret;
>> @@ -76,3 +84,16 @@ int inet_del_offload(const struct net_offload *prot, unsigned char protocol)
>>         return ret;
>>  }
>>  EXPORT_SYMBOL(inet_del_offload);
>> +
>> +int udp_del_offload(const struct net_offload *prot, __be16 port)
>> +{
>> +       int ret;
>> +
>> +       ret = (cmpxchg((const struct net_offload **)&udp_offloads[port],
>> +                      prot, NULL) == prot) ? 0 : -1;
>> +
>> +       synchronize_net();
>> +
>> +       return ret;
>> +}
>> +EXPORT_SYMBOL(udp_del_offload);
>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>> index 79c62bd..0a8fdd6 100644
>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>> @@ -89,10 +89,79 @@ out:
>>         return segs;
>>  }
>>
>> +
>> +static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>> +{
>> +       const struct net_offload *ops;
>> +       struct sk_buff *p, **pp = NULL;
>> +       struct udphdr *uh, *uh2;
>> +       unsigned int hlen, off;
>> +       int flush = 1;
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
>> +       ops = rcu_dereference(udp_offloads[uh->dest]);
>> +       if (!ops || !ops->callbacks.gro_receive)
>> +               goto out_unlock;
>> +
>> +       flush = 0;
>> +
>> +       for (p = *head; p; p = p->next) {
>> +               if (!NAPI_GRO_CB(p)->same_flow)
>> +                       continue;
>> +
>> +               uh2 = (struct udphdr   *)(p->data + off);
>> +               if ((*(u32 *)&uh->source ^ *(u32 *)&uh2->source)) {
>> +                       NAPI_GRO_CB(p)->same_flow = 0;
>> +                       continue;
>> +               }
>> +               goto found;
>> +       }
>> +
>> +found:
>> +       skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
>> +       pp = ops->callbacks.gro_receive(head, skb);
>> +
>> +out_unlock:
>> +       rcu_read_unlock();
>> +out:
>> +       NAPI_GRO_CB(skb)->flush |= flush;
>> +
>> +       return pp;
>> +}
>> +
>> +static int udp_gro_complete(struct sk_buff *skb, int nhoff)
>> +{
>> +       const struct net_offload *ops;
>> +       __be16 newlen = htons(skb->len - nhoff);
>> +       struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
>> +       int err = -ENOSYS;
>> +
>> +       uh->len = newlen;
>> +
>> +       rcu_read_lock();
>> +       ops = rcu_dereference(udp_offloads[uh->dest]);
>> +       if (ops && ops->callbacks.gro_complete)
>> +               err = ops->callbacks.gro_complete(skb, nhoff + sizeof(struct udphdr));
>> +
>> +       rcu_read_unlock();
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
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
