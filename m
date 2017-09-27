From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next] ipv6: do lazy dst->__use update when per cpu
 dst is available
Date: Wed, 27 Sep 2017 12:01:20 -0700
Message-ID: <20170927190120.nxxywv6y2at5ywhx@kafai-mbp>
References: <9d32116e61596b0de6a584b6cf05cae3ce7abb56.1506532145.git.pabeni@redhat.com>
 <CAEA6p_DZxGesjymubWoWx7hQjaZ7Vdchh=cdOW9tAr4F7QvzXg@mail.gmail.com>
 <CANn89iJ0t8Vpukak3WEOA1x4M4hk-Z9hDkcSqG9+7qLsbuJQZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Wang <weiwan@google.com>, Paolo Abeni <pabeni@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51398 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750739AbdI0TBf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 15:01:35 -0400
Content-Disposition: inline
In-Reply-To: <CANn89iJ0t8Vpukak3WEOA1x4M4hk-Z9hDkcSqG9+7qLsbuJQZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 06:03:33PM +0000, Eric Dumazet wrote:
> >> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> 
> >
> > Hi Paolo,
> >
> > Eric and I discussed about this issue recently as well :).
> >
> > What about the following change:
> >
> > diff --git a/include/net/dst.h b/include/net/dst.h
> > index 93568bd0a352..33e1d86bcef6 100644
> > --- a/include/net/dst.h
> > +++ b/include/net/dst.h
> > @@ -258,14 +258,18 @@ static inline void dst_hold(struct dst_entry *dst)
> >  static inline void dst_use(struct dst_entry *dst, unsigned long time)
> >  {
> >         dst_hold(dst);
> > -       dst->__use++;
> > -       dst->lastuse = time;
> > +       if (dst->lastuse != time) {
> > +               dst->__use++;
> > +               dst->lastuse = time;
> > +       }
> >  }
> >
> >  static inline void dst_use_noref(struct dst_entry *dst, unsigned long time)
> >  {
> > -       dst->__use++;
> > -       dst->lastuse = time;
> > +       if (dst->lastuse != time) {
> > +               dst->__use++;
> > +               dst->lastuse = time;
> > +       }
> >  }
> >
> >  static inline struct dst_entry *dst_clone(struct dst_entry *dst)
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index 26cc9f483b6d..e195f093add3 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -1170,8 +1170,7 @@ struct rt6_info *ip6_pol_route(struct net *net,
> > struct fib6_table *table,
> >
> >                 struct rt6_info *pcpu_rt;
> >
> > -               rt->dst.lastuse = jiffies;
> > -               rt->dst.__use++;
> > +               dst_use_noref(rt, jiffies);
> >                 pcpu_rt = rt6_get_pcpu_route(rt);
> >
> >                 if (pcpu_rt) {
> >
> >
> > This way we always only update dst->__use and dst->lastuse at most
> > once per jiffy. And we don't really need to update pcpu and then do
> > the copy over from pcpu_rt to rt operation.
> >
> > Another thing is that I don't really see any places making use of
> > dst->__use. So maybe we can also get rid of this dst->__use field?
> >
> > Thanks.
> > Wei
> 
> Paolo, given we are very close to send Wei awesome work about IPv6
> routing cache,
> could we ask you to wait few days before doing the same work from your side ?
> 
> Main issue is the rwlock, and we are converting it to full RCU.
+1

We can get a better picture of other optimizations once
the rwlock is removed.

> 
> You are sending patches that are making our job very difficult IMO.
> 
> We chose to mimic the change done in neighbour code years ago
> ( 0ed8ddf4045fcfcac36bad753dc4046118c603ec )
> 
> Thanks.
