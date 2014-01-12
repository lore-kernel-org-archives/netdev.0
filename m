From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: suspicious RCU usage in net/ipv4/ip_tunnel.c:80
Date: Sun, 12 Jan 2014 09:44:57 -0800
Message-ID: <1389548697.31367.184.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7PAyR_cJ9_9nfUBc0U9o-U=gCV+sN_VYbHwgq-QdoEVzQ@mail.gmail.com>
	 <1389403281.31367.171.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7OMM9ndy4hXF4rJBsA_Rb0KZ-MonuvE++wgzO_oMbo+eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:60695 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbaALRo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 12:44:59 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so6400056pbb.28
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 09:44:58 -0800 (PST)
In-Reply-To: <CAHA+R7OMM9ndy4hXF4rJBsA_Rb0KZ-MonuvE++wgzO_oMbo+eQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-11 at 11:15 -0800, Cong Wang wrote:
> On Fri, Jan 10, 2014 at 5:21 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > Nope, the synchronize_rcu() is not needed here.
> 
> OK.
> 
> >
> > Please use following sparse ready patch, thanks :
> >
> > diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> > index d3929a69f008..6eda759b5c4b 100644
> > --- a/net/ipv4/ip_tunnel.c
> > +++ b/net/ipv4/ip_tunnel.c
> > @@ -77,10 +77,11 @@ static inline void __tunnel_dst_set(struct ip_tunnel_dst *idst,
> >                 dst = NULL;
> >
> >         spin_lock_bh(&idst->lock);
> > -       old_dst = rcu_dereference(idst->dst);
> > +       old_dst = rcu_dereference_protected(idst->dst,
> > +                                           lockdep_is_held(&idst->lock));
> >         rcu_assign_pointer(idst->dst, dst);
> > -       dst_release(old_dst);
> >         spin_unlock_bh(&idst->lock);
> > +       dst_release(old_dst);
> 
> Do you really need a rcu_dereference*() here? We don't dereference
> it inside spin_lock protection.

Please read rcu_dereference_protected() documentation in
include/linux/rcupdate.h

Also you can run sparse, with CONFIG_SPARSE_RCU_POINTER=y in
your .config

make C=2 net/ipv4/ip_tunnel.o

And then you'll know the answer to this question.
