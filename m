From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 29 Aug 2016 11:20:17 -0700
Message-ID: <1472494817.14381.267.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
         <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
         <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
         <b117fac2-c73f-2d42-3843-52f9717224d9@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36141 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751314AbcH2SUT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 14:20:19 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so9699753pfg.3
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 11:20:19 -0700 (PDT)
In-Reply-To: <b117fac2-c73f-2d42-3843-52f9717224d9@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-08-29 at 07:35 -0400, Jamal Hadi Salim wrote:
>        flags = READ_ONCE(d->flags);
>         rcu_read_lock();
>         if (flags & SKBMOD_F_DMAC)
>                 ether_addr_copy(eth_hdr(skb)->h_dest, d->eth_dst);
>         if (flags & SKBMOD_F_SMAC)
>                 ether_addr_copy(eth_hdr(skb)->h_source, d->eth_src);
>         if (flags & SKBMOD_F_ETYPE)
>                 eth_hdr(skb)->h_proto = d->eth_type;
>         if (flags & SKBMOD_F_SWAPMAC) {
>                 u8 tmpaddr[ETH_ALEN];
>                 /*XXX: I am sure we can come up with something more
> efficient */
>                 ether_addr_copy(tmpaddr, eth_hdr(skb)->h_dest);
>                 ether_addr_copy(eth_hdr(skb)->h_dest,
> eth_hdr(skb)->h_source);
>                 ether_addr_copy(eth_hdr(skb)->h_source, tmpaddr);
>         }
>         rcu_read_unlock();

You would need to store everything in an object, managed by rcu.

struct my_rcu_safe_struct {
     u32 flags;
     u8   eth_dst[ETH_ALEN];
     u8   eth_src[ETH_ALEN];
     __be16 eth_type;
};

And then allocate a new one when you need to update the infos (from
tcf_skbmod_init(())

RCU : Read Copy Update.

Then in the reader you would use 

rcu_read_lock();
myptr = rcu_dereference(d->ptr);
if (myptr) {
        if (myptr->flags & SKBMOD_F_DMAC)
                 ether_addr_copy(eth_hdr(skb)->h_dest, myptr->eth_dst);
         if (myptr->flags & SKBMOD_F_SMAC)
                 ether_addr_copy(eth_hdr(skb)->h_source, myptr->eth_src);
         if (myptr->flags & SKBMOD_F_ETYPE)
                 eth_hdr(skb)->h_proto = myptr->eth_type;
}
rcu_read_unlock();
