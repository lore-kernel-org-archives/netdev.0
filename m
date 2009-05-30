From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 13:45:06 +0200
Message-ID: <20090530114506.GA3166@ami.dom.local>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp> <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp> <1243604796.3966.21.camel@dogo.mojatatu.com> <1243605269.3966.28.camel@dogo.mojatatu.com> <20090529225929.GD2753@ami.dom.local> <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Minoru Usui <usui@mxm.nes.nec.co.jp>,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: Minoru Usui <mi.usui@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:53372 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757808AbZE3Lpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 07:45:39 -0400
Received: by bwz22 with SMTP id 22so6600391bwz.37
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 04:45:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2009 at 08:17:02PM +0900, Minoru Usui wrote:
> Hi Jamal and Jarek
> 
> Thank you for your review and advice.

But there is a bit more...

> 
> 2009/5/30 Jarek Poplawski <jarkao2@gmail.com>
> 
> > On Fri, May 29, 2009 at 09:54:29AM -0400, jamal wrote:
> > > Hi Minoru,
> > >
> > > I hate to do this to you after i made suggestions on how to
> > > make the changes.... (as an adult i hate it when people do it to
> > > me;->)
> > > But sometimes code helps. So what i meant is the attached patch.
> > > I havent even compiled it yet.
> > > If it works, please submit it and add yourself as the author
> > > (and a signed-off from me). Then we can revisit the init()
> > > issue in cls_group..
> > > You should also cc tgraf in your cls_grp config questions.
> > >
> > > cheers,
> > > jamal
> > >
> > > On Fri, 2009-05-29 at 09:46 -0400, jamal wrote:
> > > >
> > > > This is incorrect. tp may already exist and you dont want to destroy
> > > > for failure to change its parameters. You also dont want to reattach
> > > > an existing tp because it succeeded in parameter change.
> > > > So the soln is to check if this is a new tp and then do what you did
> > > > above...
> > > > Did that make sense?
> > > >
> > > > cheers,
> > > > jamal
> >
> > > diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> > > index 0759f32..8760a48 100644
> > > --- a/net/sched/cls_api.c
> > > +++ b/net/sched/cls_api.c
> > > @@ -266,11 +266,6 @@ replay:
> > >                       goto errout;
> > >               }
> > >
> > > -             spin_lock_bh(root_lock);
> > > -             tp->next = *back;
> > > -             *back = tp;
> > > -             spin_unlock_bh(root_lock);
> > > -
> > >       } else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND],
> > tp->ops->kind))
> > >               goto errout;
> > >
> > ...
> >        } else {
> >                switch (n->nlmsg_type) {
> >                case RTM_NEWTFILTER:
> >                        err = -EEXIST;
> >                        if (n->nlmsg_flags & NLM_F_EXCL)
> >                                goto errout;
> >                        break;
> >
> > Probably this case needs tcf_destroy() too.
> 
> 
> > Cheers,
> > Jarek P.
> 
> 
> I'll check and test it next week.
> 
> 
> >
> > > @@ -314,8 +309,21 @@ replay:
> > >       }
> > >
> > >       err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
> > > -     if (err == 0)
> > > +     if (err == 0) {
> > > +             if (n->nlmsg_type == RTM_NEWTFILTER &&
> > > +                 (n->nlmsg_flags&NLM_F_CREATE)) {

Since "tc filter replace" uses this type and flag too without creating
tp, this check is not enough. I guess we could simply use a variable
like tp_created etc. Anyway, changing this place looks tricky to me,
so maybe it would be safer to do a separate cls_cgroup fix just for
-stable, and this one patch for -next only?

Jarek P.

> > > +                     spin_lock_bh(root_lock);
> > > +                     tp->next = *back;
> > > +                     *back = tp;
> > > +                     spin_unlock_bh(root_lock);
> > > +             }
> > >               tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
> > > +     } else {
> > > +             if (n->nlmsg_type == RTM_NEWTFILTER &&
> > > +                 (n->nlmsg_flags&NLM_F_CREATE)) {
> > > +                     tcf_destroy(tp);
> > > +             }
> > > +     }
> > >
> > >  errout:
> > >       if (cl)
> >
