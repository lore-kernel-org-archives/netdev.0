From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: add complete rcu protection around np->opt
Date: Tue, 01 Dec 2015 14:13:15 +0100
Message-ID: <1448975595.3345555.454641969.3E702309@webmail.messagingengine.com>
References: <CACT4Y+Y=35aC5DK7MQaDF6eviKcXik2S9caTLw7FAp0L0CXdsg@mail.gmail.com>
 <1448730683.24696.94.camel@edumazet-glaptop2.roam.corp.google.com>
 <1448731434.24696.97.camel@edumazet-glaptop2.roam.corp.google.com>
 <1448854677.24696.117.camel@edumazet-glaptop2.roam.corp.google.com>
 <1448968286.3318880.454548345.76FA2174@webmail.messagingengine.com>
 <1448975100.25582.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	William Dauchy <wdauchy@gmail.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:42017 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755107AbbLANNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:13:16 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 13077209D4
	for <netdev@vger.kernel.org>; Tue,  1 Dec 2015 08:13:16 -0500 (EST)
In-Reply-To: <1448975100.25582.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015, at 14:05, Eric Dumazet wrote:
> On Tue, 2015-12-01 at 12:11 +0100, Hannes Frederic Sowa wrote:
> > Hi Eric,
> > 
> > On Mon, Nov 30, 2015, at 04:37, Eric Dumazet wrote:
> > > -                       opt = xchg(&np->opt, NULL);
> > > -                       if (opt)
> > > -                               sock_kfree_s(sk, opt, opt->tot_len);
> > > +                       opt = xchg((__force struct ipv6_txoptions
> > > **)&np->opt,
> > > +                                  NULL);
> > > +                       if (opt) {
> > > +                               atomic_sub(opt->tot_len,
> > > &sk->sk_omem_alloc);
> > > +                               txopt_put(opt);
> > > +                       }
> > >  			pktopt = xchg(&np->pktoptions, NULL);
> > >  			kfree_skb(pktopt);
> > 
> > Is here something special going on (because of the xchg). I don't see
> > why you cannot simply use a RCU_INIT_POINTER?
> > 
> > Thanks,
> > Hannes
> 
> Yes, I mentioned this earlier, and will be addressed in net-next tree
> later.
> 
> (Same for np->pktoptions)
> 
> The xchg() here does not bring additional protection as we are the last
> user of np.
> 
> Thanks.

Ah, sorry, maybe I missed it. Just reviewed the patches after a longer
weekend here.

The rest looked fine to me:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
