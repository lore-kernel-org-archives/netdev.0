From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH net-next v2 2/2] xfrm: configure policy hash table
 thresholds by netlink
Date: Tue, 26 Aug 2014 09:27:26 +0200
Message-ID: <CADdy8HoCSDXuC0VjXwaj14b9QHqSqHNdgK0Opnhzn8wwCawBuw@mail.gmail.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
	<1406884348-12423-1-git-send-email-christophe.gouault@6wind.com>
	<1406884348-12423-3-git-send-email-christophe.gouault@6wind.com>
	<20140821060944.GC6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:34074 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391AbaHZH11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 03:27:27 -0400
Received: by mail-ie0-f177.google.com with SMTP id at20so11056230iec.36
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 00:27:27 -0700 (PDT)
In-Reply-To: <20140821060944.GC6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-21 8:09 GMT+02:00 Steffen Klassert <steffen.klassert@secunet.com>:
> On Fri, Aug 01, 2014 at 11:12:28AM +0200, Christophe Gouault wrote:
>> diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
>> index 41902a8..9da7982 100644
>> --- a/include/net/netns/xfrm.h
>> +++ b/include/net/netns/xfrm.h
>> @@ -19,6 +19,15 @@ struct xfrm_policy_hash {
>>       u8                      sbits6;
>>  };
>>
>> +struct xfrm_policy_hthresh {
>> +     struct work_struct      work;
>> +     seqlock_t               lock;
>
> This newly introduced lock is not initialized. It triggers an
> inconsistent lock state warning when acquired for the first time.

oops! I'll fix that.

>> +     pr_info("rebuilding SPD hash table: thresholds (%u,%u)(%u,%u)\n",
>> +             lbits4, rbits4, lbits6, rbits6);
>
> Do we really need to print this?

No, it's not necessary, I will remove it.

>> +             hlist_for_each_entry(pol, chain, bydst) {
>> +                     if (policy->priority >= pol->priority)
>> +                             newpos = &pol->bydst;
>> +                     else
>> +                             break;
>> +             }
>> +             if (newpos)
>> +                     hlist_add_after(newpos, &policy->bydst);
>
> hlist_add_after() does not exist any more, it was replaced by
> hlist_add_behind() recently.

OK, I'll update the code accordingly.

>> +static int xfrm_set_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
>> +                         struct nlattr **attrs)
>> +{
>> +     struct net *net = sock_net(skb->sk);
>> +     struct sk_buff *r_skb;
>> +     u32 *flags = nlmsg_data(nlh);
>> +     u32 sportid = NETLINK_CB(skb).portid;
>> +     u32 seq = nlh->nlmsg_seq;
>> +     struct xfrmu_spdhthresh *thresh4 = NULL;
>> +     struct xfrmu_spdhthresh *thresh6 = NULL;
>> +
>> +     /* selector prefixlen thresholds to hash policies */
>> +     if (attrs[XFRMA_SPD_IPV4_HTHRESH]) {
>> +             struct nlattr *rta = attrs[XFRMA_SPD_IPV4_HTHRESH];
>> +
>> +             if (nla_len(rta) < sizeof(*thresh4))
>> +                     return -EINVAL;
>> +             thresh4 = nla_data(rta);
>> +             if (thresh4->lbits > 32 || thresh4->rbits > 32)
>> +                     return -EINVAL;
>> +     }
>> +     if (attrs[XFRMA_SPD_IPV6_HTHRESH]) {
>> +             struct nlattr *rta = attrs[XFRMA_SPD_IPV6_HTHRESH];
>> +
>> +             if (nla_len(rta) < sizeof(*thresh6))
>> +                     return -EINVAL;
>> +             thresh6 = nla_data(rta);
>> +             if (thresh6->lbits > 128 || thresh6->rbits > 128)
>> +                     return -EINVAL;
>> +     }
>> +
>> +     if (thresh4 || thresh6) {
>> +             write_seqlock(&net->xfrm.policy_hthresh.lock);
>> +             if (thresh4) {
>> +                     net->xfrm.policy_hthresh.lbits4 = thresh4->lbits;
>> +                     net->xfrm.policy_hthresh.rbits4 = thresh4->rbits;
>> +             }
>> +             if (thresh6) {
>> +                     net->xfrm.policy_hthresh.lbits6 = thresh6->lbits;
>> +                     net->xfrm.policy_hthresh.rbits6 = thresh6->rbits;
>> +             }
>> +             write_sequnlock(&net->xfrm.policy_hthresh.lock);
>> +
>> +             xfrm_policy_hash_rebuild(net);
>> +     }
>> +
>> +     r_skb = nlmsg_new(xfrm_spdinfo_msgsize(), GFP_ATOMIC);
>> +     if (r_skb == NULL)
>> +             return -ENOMEM;
>> +
>> +     if (build_spdinfo(r_skb, net, sportid, seq, *flags) < 0)
>> +             BUG();
>> +
>> +     return nlmsg_unicast(net->xfrm.nlsk, r_skb, sportid);
>
> Why do you send these informations to userspace? This is a set
> operation, not get.

You're right, I'll remove this reply message.

> The rest looks quite good, thanks!

Thanks. I'll send an update.

Christophe
