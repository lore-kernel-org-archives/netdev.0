From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 3/3] ipv6: obsolete cached dst when removing
 them from fib tree
Date: Tue, 17 Oct 2017 14:52:34 -0700
Message-ID: <20171017215234.fnmkdro7wnbdnpfu@kafai-mbp.dhcp.thefacebook.com>
References: <cover.1508261949.git.pabeni@redhat.com>
 <59304478d82e52c817c92d183ef2105f35c17266.1508261949.git.pabeni@redhat.com>
 <CAEA6p_CMZu-ooO4sKXD3=wg8_wcAB+oZbTujJ4hEDQnjPZRNwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Wang <weiwan@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36878 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753015AbdJQVwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 17:52:46 -0400
Content-Disposition: inline
In-Reply-To: <CAEA6p_CMZu-ooO4sKXD3=wg8_wcAB+oZbTujJ4hEDQnjPZRNwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 06:58:23PM +0000, Wei Wang wrote:
> On Tue, Oct 17, 2017 at 10:40 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > The commit 2b760fcf5cfb ("ipv6: hook up exception table to store
> > dst cache") partially reverted 1e2ea8ad37be ("ipv6: set
> > dst.obsolete when a cached route has expired").
> >
> > This change brings back the dst obsoleting and push it a step
> > farther: cached dst are always obsoleted when removed from the
> > fib tree, and removal by time expiration is now performed
> > regardless of dst->__refcnt, to be consistent with what we
> > already do for RTF_GATEWAY dst.
> >
> > Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > ---
> >  net/ipv6/route.c | 13 +++++++++++--
> >  1 file changed, 11 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index 8b25a31b6b03..fce740049e3e 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -1147,6 +1147,12 @@ static void rt6_remove_exception(struct rt6_exception_bucket *bucket,
> >         if (!bucket || !rt6_ex)
> >                 return;
> >
> > +       /* sockets, flow cache, etc. can hold a refence to this dst, be sure
> > +        * they will drop it.
> > +        */
> > +       if (rt6_ex->rt6i)
> > +               rt6_ex->rt6i->dst.obsolete = DST_OBSOLETE_FORCE_CHK;
> > +
> 
> Hmm... I don't really think it is needed. rt6 is created with
> rt6->dst.obsolete set to DST_OBSOLETE_FORCE_CHK. And by the time the
> above function is called, it should still be that value.
> Furthermore, the later call rt6_release() calls dst_dev_put() which
> sets rt6->dst.obsolete to DST_OBSOLETE_DEAD to indicate this route has
> been removed from the tree.
> 
> >         net = dev_net(rt6_ex->rt6i->dst.dev);
> >         rt6_ex->rt6i->rt6i_node = NULL;
> >         hlist_del_rcu(&rt6_ex->hlist);
> > @@ -1575,8 +1581,11 @@ static void rt6_age_examine_exception(struct rt6_exception_bucket *bucket,
> >  {
> >         struct rt6_info *rt = rt6_ex->rt6i;
> >
> > -       if (atomic_read(&rt->dst.__refcnt) == 1 &&
> > -           time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
> > +       /* we are pruning and obsoleting the exception route even if others
> > +        * have still reference to it, so that on next dst_check() such
> > +        * reference can be dropped
> > +        */
> > +       if (time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
> 
> Why do we want to change this behavior? Before my patch series, cached
> routes were only deleted from the tree in fib6_age() when
> rt->dst.__refcnt == 1, isn't it?
In the commit 1e2ea8ad37be ("ipv6: set dst.obsolete when a cached route has expired"),
if obsolete is set to DST_OBSOLETE_KILL, why it is not removed from
the tree together?

> 
> >                 RT6_TRACE("aging clone %p\n", rt);
> >                 rt6_remove_exception(bucket, rt6_ex);
> >                 return;
> > --
> > 2.13.6
> >
