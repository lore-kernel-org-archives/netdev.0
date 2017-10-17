From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net-next 3/3] ipv6: obsolete cached dst when removing them
 from fib tree
Date: Tue, 17 Oct 2017 13:48:06 -0700
Message-ID: <CAEA6p_AS9c6pOym4t6FGW-bWfU=YmmL96Fc4vMcnDMCc8ywVqg@mail.gmail.com>
References: <cover.1508261949.git.pabeni@redhat.com> <59304478d82e52c817c92d183ef2105f35c17266.1508261949.git.pabeni@redhat.com>
 <CAEA6p_CMZu-ooO4sKXD3=wg8_wcAB+oZbTujJ4hEDQnjPZRNwg@mail.gmail.com> <1508270578.2548.22.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:43263 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756601AbdJQUsI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:48:08 -0400
Received: by mail-vk0-f45.google.com with SMTP id t203so1999723vke.0
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:48:08 -0700 (PDT)
In-Reply-To: <1508270578.2548.22.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 1:02 PM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Tue, 2017-10-17 at 11:58 -0700, Wei Wang wrote:
>> On Tue, Oct 17, 2017 at 10:40 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>> > The commit 2b760fcf5cfb ("ipv6: hook up exception table to store
>> > dst cache") partially reverted 1e2ea8ad37be ("ipv6: set
>> > dst.obsolete when a cached route has expired").
>> >
>> > This change brings back the dst obsoleting and push it a step
>> > farther: cached dst are always obsoleted when removed from the
>> > fib tree, and removal by time expiration is now performed
>> > regardless of dst->__refcnt, to be consistent with what we
>> > already do for RTF_GATEWAY dst.
>> >
>> > Fixes: 2b760fcf5cfb ("ipv6: hook up exception table to store dst cache")
>> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>> > ---
>> >  net/ipv6/route.c | 13 +++++++++++--
>> >  1 file changed, 11 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> > index 8b25a31b6b03..fce740049e3e 100644
>> > --- a/net/ipv6/route.c
>> > +++ b/net/ipv6/route.c
>> > @@ -1147,6 +1147,12 @@ static void rt6_remove_exception(struct rt6_exception_bucket *bucket,
>> >         if (!bucket || !rt6_ex)
>> >                 return;
>> >
>> > +       /* sockets, flow cache, etc. can hold a refence to this dst, be sure
>> > +        * they will drop it.
>> > +        */
>> > +       if (rt6_ex->rt6i)
>> > +               rt6_ex->rt6i->dst.obsolete = DST_OBSOLETE_FORCE_CHK;
>> > +
>>
>> Hmm... I don't really think it is needed. rt6 is created with
>> rt6->dst.obsolete set to DST_OBSOLETE_FORCE_CHK. And by the time the
>> above function is called, it should still be that value.
>> Furthermore, the later call rt6_release() calls dst_dev_put() which
>> sets rt6->dst.obsolete to DST_OBSOLETE_DEAD to indicate this route has
>> been removed from the tree.
>
> You are right, this looks as not needed, if we keep the chunck below.
>
>> >         net = dev_net(rt6_ex->rt6i->dst.dev);
>> >         rt6_ex->rt6i->rt6i_node = NULL;
>> >         hlist_del_rcu(&rt6_ex->hlist);
>> > @@ -1575,8 +1581,11 @@ static void rt6_age_examine_exception(struct rt6_exception_bucket *bucket,
>> >  {
>> >         struct rt6_info *rt = rt6_ex->rt6i;
>> >
>> > -       if (atomic_read(&rt->dst.__refcnt) == 1 &&
>> > -           time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
>> > +       /* we are pruning and obsoleting the exception route even if others
>> > +        * have still reference to it, so that on next dst_check() such
>> > +        * reference can be dropped
>> > +        */
>> > +       if (time_after_eq(now, rt->dst.lastuse + gc_args->timeout)) {
>>
>> Why do we want to change this behavior? Before my patch series, cached
>> routes were only deleted from the tree in fib6_age() when
>> rt->dst.__refcnt == 1, isn't it?
>
> yes, but that really looks like a relic from ancient past more than
> something really needed. We already remove from the dst from fib tree
> regardless of the refcnt if the gateway validation fails - a few lines
> below in the same function.
>
> Waiting for __refcnt going down will let the kernel keep the exception
> entry around for much longer - potentially forever, if e.g. we have a
> reference in a socket dst cache and the application stops processing
> packets.
>

True. If the socket is idle and doesn't send/receive packets,
dst_check() won't get triggered and the socket will keep holding
refcnt on the obsolete dst.

> Meanwhile others sockets may grab more references to (and use) the same
> aged-out dst.
>
I don't think other sockets could grab more reference to this dst
because this dst should already be removed from the fib6 tree.

> The commit 1e2ea8ad37be ("ipv6: set dst.obsolete when a cached route
> has expired") was the solution to the above issue prior to the recent
> refactor.
>

I don't really understand how this commit is solving the above issue.
This commit still only ages out cached route if &rt->dst.__refcnt ==
1. So if socket is holding refcnt to this dst and dst_check() is not
getting called,  this cached route still won't get deleted.

> Cheers,
>
> Paolo
