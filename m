From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 1/5] sctp: add the rhashtable apis for sctp
 global transport hashtable
Date: Thu, 7 Jan 2016 01:01:11 +0800
Message-ID: <CADvbK_eu13b9RQ9eMLkBJZyTuQLOwThyuyzgDpwg9RbupXBN5A@mail.gmail.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
	<2c413161eb3a2c74453bd8dc11815af7e237515e.1451490447.git.lucien.xin@gmail.com>
	<568C0DA3.1090604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35624 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbcAFRBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 12:01:12 -0500
In-Reply-To: <568C0DA3.1090604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 6, 2016 at 2:38 AM, Vlad Yasevich <vyasevich@gmail.com> wrote:
> On 12/30/2015 10:50 AM, Xin Long wrote:
>> tranport hashtbale will replace the association hashtable to do the
>> lookup for transport, and then get association by t->assoc, rhashtable
>> apis will be used because of it's resizable, scalable and using rcu.
>>
>> lport + rport + paddr will be the base hashkey to locate the chain,
>> with net to protect one netns from another, then plus the laddr to
>> compare to get the target.
>>
>> this patch will provider the lookup functions:
>> - sctp_epaddr_lookup_transport
>> - sctp_addrs_lookup_transport
>>
>> hash/unhash functions:
>> - sctp_hash_transport
>> - sctp_unhash_transport
>>
>> init/destroy functions:
>> - sctp_transport_hashtable_init
>> - sctp_transport_hashtable_destroy
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>> ---
>>  include/net/sctp/sctp.h    |  11 ++++
>>  include/net/sctp/structs.h |   5 ++
>>  net/sctp/input.c           | 131 +++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 147 insertions(+)
>>
>> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
>> index ce13cf2..7bbdfba 100644
>> --- a/include/net/sctp/sctp.h
>> +++ b/include/net/sctp/sctp.h
>> @@ -143,6 +143,17 @@ void sctp_icmp_proto_unreachable(struct sock *sk,
>>                                struct sctp_transport *t);
>>  void sctp_backlog_migrate(struct sctp_association *assoc,
>>                         struct sock *oldsk, struct sock *newsk);
>> +int sctp_transport_hashtable_init(void);
>> +void sctp_transport_hashtable_destroy(void);
>> +void sctp_hash_transport(struct sctp_transport *t);
>> +void sctp_unhash_transport(struct sctp_transport *t);
>> +struct sctp_transport *sctp_addrs_lookup_transport(
>> +                             struct net *net,
>> +                             const union sctp_addr *laddr,
>> +                             const union sctp_addr *paddr);
>> +struct sctp_transport *sctp_epaddr_lookup_transport(
>> +                             const struct sctp_endpoint *ep,
>> +                             const union sctp_addr *paddr);
>>
>>  /*
>>   * sctp/proc.c
>> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
>> index eea9bde..4ab87d0 100644
>> --- a/include/net/sctp/structs.h
>> +++ b/include/net/sctp/structs.h
>> @@ -48,6 +48,7 @@
>>  #define __sctp_structs_h__
>>
>>  #include <linux/ktime.h>
>> +#include <linux/rhashtable.h>
>>  #include <linux/socket.h>    /* linux/in.h needs this!!    */
>>  #include <linux/in.h>                /* We get struct sockaddr_in. */
>>  #include <linux/in6.h>               /* We get struct in6_addr     */
>> @@ -123,6 +124,8 @@ extern struct sctp_globals {
>>       struct sctp_hashbucket *assoc_hashtable;
>>       /* This is the sctp port control hash.  */
>>       struct sctp_bind_hashbucket *port_hashtable;
>> +     /* This is the hash of all transports. */
>> +     struct rhashtable transport_hashtable;
>>
>>       /* Sizes of above hashtables. */
>>       int ep_hashsize;
>> @@ -147,6 +150,7 @@ extern struct sctp_globals {
>>  #define sctp_assoc_hashtable         (sctp_globals.assoc_hashtable)
>>  #define sctp_port_hashsize           (sctp_globals.port_hashsize)
>>  #define sctp_port_hashtable          (sctp_globals.port_hashtable)
>> +#define sctp_transport_hashtable     (sctp_globals.transport_hashtable)
>>  #define sctp_checksum_disable                (sctp_globals.checksum_disable)
>>
>>  /* SCTP Socket type: UDP or TCP style. */
>> @@ -753,6 +757,7 @@ static inline int sctp_packet_empty(struct sctp_packet *packet)
>>  struct sctp_transport {
>>       /* A list of transports. */
>>       struct list_head transports;
>> +     struct rhash_head node;
>>
>>       /* Reference counting. */
>>       atomic_t refcnt;
>> diff --git a/net/sctp/input.c b/net/sctp/input.c
>> index b6493b3..bac8278 100644
>> --- a/net/sctp/input.c
>> +++ b/net/sctp/input.c
>> @@ -782,6 +782,137 @@ hit:
>>       return ep;
>>  }
>>
>> +/* rhashtable for transport */
>> +struct sctp_hash_cmp_arg {
>> +     const union sctp_addr           *laddr;
>> +     const union sctp_addr           *paddr;
>> +     const struct net                *net;
>> +};
>> +
>> +static inline int sctp_hash_cmp(struct rhashtable_compare_arg *arg,
>> +                             const void *ptr)
>> +{
>> +     const struct sctp_hash_cmp_arg *x = arg->key;
>> +     const struct sctp_transport *t = ptr;
>> +     struct sctp_association *asoc = t->asoc;
>> +     const struct net *net = x->net;
>> +
>> +     if (x->laddr->v4.sin_port != htons(asoc->base.bind_addr.port))
>> +             return 1;
>> +     if (!sctp_cmp_addr_exact(&t->ipaddr, x->paddr))
>> +             return 1;
>> +     if (!net_eq(sock_net(asoc->base.sk), net))
>> +             return 1;
>> +     if (!sctp_bind_addr_match(&asoc->base.bind_addr,
>> +                               x->laddr, sctp_sk(asoc->base.sk)))
>> +             return 1;
>> +
>> +     return 0;
>> +}
>> +
>> +static inline u32 sctp_hash_obj(const void *data, u32 len, u32 seed)
>> +{
>> +     const struct sctp_transport *t = data;
>> +     const union sctp_addr *paddr = &t->ipaddr;
>> +     const struct net *net = sock_net(t->asoc->base.sk);
>> +     u16 lport = htons(t->asoc->base.bind_addr.port);
>> +     u32 addr;
>> +
>> +     if (paddr->sa.sa_family == AF_INET6)
>> +             addr = jhash(&paddr->v6.sin6_addr, 16, seed);
>> +     else
>> +             addr = paddr->v4.sin_addr.s_addr;
>> +
>> +     return  jhash_3words(addr, ((__u32)paddr->v4.sin_port) << 16 |
>> +                          (__force __u32)lport, net_hash_mix(net), seed);
>> +}
>> +
>> +static inline u32 sctp_hash_key(const void *data, u32 len, u32 seed)
>> +{
>> +     const struct sctp_hash_cmp_arg *x = data;
>> +     const union sctp_addr *paddr = x->paddr;
>> +     const struct net *net = x->net;
>> +     u16 lport = x->laddr->v4.sin_port;
>> +     u32 addr;
>> +
>> +     if (paddr->sa.sa_family == AF_INET6)
>> +             addr = jhash(&paddr->v6.sin6_addr, 16, seed);
>> +     else
>> +             addr = paddr->v4.sin_addr.s_addr;
>> +
>> +     return  jhash_3words(addr, ((__u32)paddr->v4.sin_port) << 16 |
>> +                          (__force __u32)lport, net_hash_mix(net), seed);
>> +}
>> +
>> +static const struct rhashtable_params sctp_hash_params = {
>> +     .head_offset            = offsetof(struct sctp_transport, node),
>> +     .hashfn                 = sctp_hash_key,
>> +     .obj_hashfn             = sctp_hash_obj,
>> +     .obj_cmpfn              = sctp_hash_cmp,
>> +     .automatic_shrinking    = true,
>> +};
>> +
>> +int sctp_transport_hashtable_init(void)
>> +{
>> +     return rhashtable_init(&sctp_transport_hashtable, &sctp_hash_params);
>> +}
>> +
>> +void sctp_transport_hashtable_destroy(void)
>> +{
>> +     rhashtable_destroy(&sctp_transport_hashtable);
>> +}
>> +
>> +void sctp_hash_transport(struct sctp_transport *t)
>> +{
>> +     struct sctp_sockaddr_entry *addr;
>> +     struct sctp_hash_cmp_arg arg;
>> +
>> +     addr = list_entry(t->asoc->base.bind_addr.address_list.next,
>> +                       struct sctp_sockaddr_entry, list);
>> +     arg.laddr = &addr->a;
>> +     arg.paddr = &t->ipaddr;
>> +     arg.net   = sock_net(t->asoc->base.sk);
>> +
>> +reinsert:
>> +     if (rhashtable_lookup_insert_key(&sctp_transport_hashtable, &arg,
>> +                                      &t->node, sctp_hash_params) == -EBUSY)
>> +             goto reinsert;
>> +}
>> +
>> +void sctp_unhash_transport(struct sctp_transport *t)
>> +{
>> +     rhashtable_remove_fast(&sctp_transport_hashtable, &t->node,
>> +                            sctp_hash_params);
>> +}
>> +
>> +struct sctp_transport *sctp_addrs_lookup_transport(
>> +                             struct net *net,
>> +                             const union sctp_addr *laddr,
>> +                             const union sctp_addr *paddr)
>> +{
>> +     struct sctp_hash_cmp_arg arg = {
>> +             .laddr = laddr,
>> +             .paddr = paddr,
>> +             .net   = net,
>> +     };
>> +
>> +     return rhashtable_lookup_fast(&sctp_transport_hashtable, &arg,
>> +                                   sctp_hash_params);
>> +}
>> +
>> +struct sctp_transport *sctp_epaddr_lookup_transport(
>> +                             const struct sctp_endpoint *ep,
>> +                             const union sctp_addr *paddr)
>> +{
>> +     struct sctp_sockaddr_entry *addr;
>> +     struct net *net = sock_net(ep->base.sk);
>> +
>> +     addr = list_entry(ep->base.bind_addr.address_list.next,
>> +                       struct sctp_sockaddr_entry, list);
>> +
>> +     return sctp_addrs_lookup_transport(net, &addr->a, paddr);
>> +}
>> +
>
> I don't think that this right, mainly because not all endpoint
> addresses will be copied to association bind_addr list.   As a result,
> you may actually have an association on this endpoint to a given
> peer, but may not be using the first address from the endpoint..
>
> What might work is to pick an endpoint address that would be usable within
> the scope of the peer address.
it's not that easy, does it make sense to you if I change

     if (!sctp_bind_addr_match(&asoc->base.bind_addr,
                               x->laddr, sctp_sk(asoc->base.sk)))

to
     if (!sctp_bind_addr_match(&asoc->ep->base.bind_addr,
                               x->laddr, sctp_sk(asoc->base.sk)))

in sctp_hash_cmp() ?
