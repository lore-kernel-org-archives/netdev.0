From: Marc Dionne <marc.c.dionne@gmail.com>
Subject: Re: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Mon, 27 Jun 2016 11:46:02 -0300
Message-ID: <CAB9dFds=qY=Dk++p7qVX7a8aOOH4wn0rtL3m4poO6HMQPuPrnA@mail.gmail.com>
References: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
 <20160627142238.GA10613@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34246 "EHLO
	mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbcF0OqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 10:46:08 -0400
Received: by mail-vk0-f65.google.com with SMTP id v6so3486207vkb.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 07:46:08 -0700 (PDT)
In-Reply-To: <20160627142238.GA10613@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 11:22 AM, Florian Westphal <fw@strlen.de> wrote:
> Marc Dionne <marc.c.dionne@gmail.com> wrote:
>> Hi,
>>
>> I've been seeing issues with 4.7-rc kernels with some of our
>> multi-thread test cases.  I've bisected it down to this commit:
>>
>>   commit 71d8c47fc653711c41bc3282e5b0e605b3727956
>>   Author: Pablo Neira Ayuso <pablo@netfilter.org>
>>   Date:   Sun May 1 00:28:40 2016 +0200
>>
>>       netfilter: conntrack: introduce clash resolution on insertion race
>>
>>
>> .. and verified that reverting the commit restores the expected behaviour.
>
> Does this change help?
>
> Subject: Restrict clash resolution to original direction
>
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -721,13 +721,18 @@ __nf_conntrack_confirm(struct sk_buff *skb)
>            not in the hash.  If there is, we lost race. */
>         hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[hash], hnnode)
>                 if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
> -                                   zone, net))
> -                       goto out;
> +                                   zone, net)) {
> +                       nf_ct_add_to_dying_list(ct);
> +                       ret = nf_ct_resolve_clash(net, skb, ctinfo, h);
> +                       goto dying;
> +               }
>
>         hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[reply_hash], hnnode)
>                 if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
> -                                   zone, net))
> -                       goto out;
> +                                   zone, net)) {
> +                       nf_ct_add_to_dying_list(ct);
> +                       goto dying;
> +               }
>
>         /* Timer relative to confirmation time, not original
>            setting time, otherwise we'd get timer wrap in
> @@ -763,9 +768,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
>                                  IPCT_RELATED : IPCT_NEW, ct);
>         return NF_ACCEPT;
>
> -out:
> -       nf_ct_add_to_dying_list(ct);
> -       ret = nf_ct_resolve_clash(net, skb, ctinfo, h);
>  dying:
>         nf_conntrack_double_unlock(hash, reply_hash);
>         NF_CT_STAT_INC(net, insert_failed);

No, that doesn't seem to make any noticeable difference.

Marc
