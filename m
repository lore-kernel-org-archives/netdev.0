From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 1/5] sctp: add the rhashtable apis for sctp
 global transport hashtable
Date: Mon, 11 Jan 2016 12:20:17 -0500
Message-ID: <5693E451.2000306@gmail.com>
References: <2c413161eb3a2c74453bd8dc11815af7e237515e.1451490447.git.lucien.xin@gmail.com>
 <20160111093012.GA23525@gondor.apana.org.au>
 <20160111160039.GA6061@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Xin Long <lucien.xin@gmail.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, vyasevic@redhat.com,
	daniel@iogearbox.net, davem@davemloft.net
To: mleitner@redhat.com, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34500 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759107AbcAKRfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:35:54 -0500
In-Reply-To: <20160111160039.GA6061@mrl.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2016 11:00 AM, mleitner@redhat.com wrote:
> On Mon, Jan 11, 2016 at 05:30:12PM +0800, Herbert Xu wrote:
>> Xin Long <lucien.xin@gmail.com> wrote:
>>>
>>> +static inline int sctp_hash_cmp(struct rhashtable_compare_arg *arg,
>>> +                               const void *ptr)
>>> +{
>>> +       const struct sctp_hash_cmp_arg *x = arg->key;
>>> +       const struct sctp_transport *t = ptr;
>>> +       struct sctp_association *asoc = t->asoc;
>>> +       const struct net *net = x->net;
>>> +
>>> +       if (x->laddr->v4.sin_port != htons(asoc->base.bind_addr.port))
>>> +               return 1;
>>> +       if (!sctp_cmp_addr_exact(&t->ipaddr, x->paddr))
>>> +               return 1;
>>> +       if (!net_eq(sock_net(asoc->base.sk), net))
>>> +               return 1;
>>> +       if (!sctp_bind_addr_match(&asoc->base.bind_addr,
>>> +                                 x->laddr, sctp_sk(asoc->base.sk)))
>>> +               return 1;
>>> +
>>> +       return 0;
>>> +}
>>> +
>>> +static inline u32 sctp_hash_obj(const void *data, u32 len, u32 seed)
>>> +{
>>> +       const struct sctp_transport *t = data;
>>> +       const union sctp_addr *paddr = &t->ipaddr;
>>> +       const struct net *net = sock_net(t->asoc->base.sk);
>>> +       u16 lport = htons(t->asoc->base.bind_addr.port);
>>> +       u32 addr;
>>> +
>>> +       if (paddr->sa.sa_family == AF_INET6)
>>> +               addr = jhash(&paddr->v6.sin6_addr, 16, seed);
>>> +       else
>>> +               addr = paddr->v4.sin_addr.s_addr;
>>> +
>>> +       return  jhash_3words(addr, ((__u32)paddr->v4.sin_port) << 16 |
>>> +                            (__force __u32)lport, net_hash_mix(net), seed);
>>> +}
>>> +
>>> +static inline u32 sctp_hash_key(const void *data, u32 len, u32 seed)
>>> +{
>>> +       const struct sctp_hash_cmp_arg *x = data;
>>> +       const union sctp_addr *paddr = x->paddr;
>>> +       const struct net *net = x->net;
>>> +       u16 lport = x->laddr->v4.sin_port;
>>> +       u32 addr;
>>> +
>>> +       if (paddr->sa.sa_family == AF_INET6)
>>> +               addr = jhash(&paddr->v6.sin6_addr, 16, seed);
>>> +       else
>>> +               addr = paddr->v4.sin_addr.s_addr;
>>> +
>>> +       return  jhash_3words(addr, ((__u32)paddr->v4.sin_port) << 16 |
>>> +                            (__force __u32)lport, net_hash_mix(net), seed);
>>> +}
>>
>> There's your problem.  You are allowing multiple objects to hash
>> to the same value.  This is unacceptable with rhashtable because
>> we use the hash chain length to determine if we're under attack
>> and need to rehash.  This is the reason why you would see EBUSY
>> during insertion.
> 
> Cool. Then I guess we don't really have an issue here. The case that
> fails is an artificial load test which is virtually impossible to be hit
> in real world, or at least I really hope so. The test, as in Xin's
> attachment, will load more than 1600 IP addresses in one host (2 vCPU
> during the test) and attempt to start an assoc from each of those using
> the very same (lport, daddr, dport)-tuple.
> 
> Doing so is just unreasonable. Note that net is also hashed, so
> even if we consider it could be 1600 containers, it is fine.

I have a hard time excepting this argument.  Just because a given test
scenario may be unreasonable now, doesn't make so in the future.  If
there is a way to solve the problem, then it should be done.  Saying
this isn't really a problem isn't going to make it go away.

-vlad

> 
>> So instead of inserting your objects as is, you should instead hash
>> a list object that then links to all the objects that has the same
>> hash key.
> 
> Now that it is clarified, I'm thinking we should just get ride of that
> loop on EBUSY. No real reason to have extra code only to support an
> artificial test. Agree?
> 
> Thanks,
> Marcelo
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
