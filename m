From: Minoru Usui <mi.usui-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 20:17:02 +0900
Message-ID: <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	<1243604796.3966.21.camel@dogo.mojatatu.com>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>,
        containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090529225929.GD2753-dUp/P3zyUuaNj9Bq2fkWzw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jamal and Jarek

Thank you for your review and advice.

2009/5/30 Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> On Fri, May 29, 2009 at 09:54:29AM -0400, jamal wrote:
> > Hi Minoru,
> >
> > I hate to do this to you after i made suggestions on how to
> > make the changes.... (as an adult i hate it when people do it to
> > me;->)
> > But sometimes code helps. So what i meant is the attached patch.
> > I havent even compiled it yet.
> > If it works, please submit it and add yourself as the author
> > (and a signed-off from me). Then we can revisit the init()
> > issue in cls_group..
> > You should also cc tgraf in your cls_grp config questions.
> >
> > cheers,
> > jamal
> >
> > On Fri, 2009-05-29 at 09:46 -0400, jamal wrote:
> > >
> > > This is incorrect. tp may already exist and you dont want to destroy
> > > for failure to change its parameters. You also dont want to reattach
> > > an existing tp because it succeeded in parameter change.
> > > So the soln is to check if this is a new tp and then do what you did
> > > above...
> > > Did that make sense?
> > >
> > > cheers,
> > > jamal
>
> > diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> > index 0759f32..8760a48 100644
> > --- a/net/sched/cls_api.c
> > +++ b/net/sched/cls_api.c
> > @@ -266,11 +266,6 @@ replay:
> >                       goto errout;
> >               }
> >
> > -             spin_lock_bh(root_lock);
> > -             tp->next = *back;
> > -             *back = tp;
> > -             spin_unlock_bh(root_lock);
> > -
> >       } else if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND],
> tp->ops->kind))
> >               goto errout;
> >
> ...
>        } else {
>                switch (n->nlmsg_type) {
>                case RTM_NEWTFILTER:
>                        err = -EEXIST;
>                        if (n->nlmsg_flags & NLM_F_EXCL)
>                                goto errout;
>                        break;
>
> Probably this case needs tcf_destroy() too.


> Cheers,
> Jarek P.


I'll check and test it next week.


>
> > @@ -314,8 +309,21 @@ replay:
> >       }
> >
> >       err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
> > -     if (err == 0)
> > +     if (err == 0) {
> > +             if (n->nlmsg_type == RTM_NEWTFILTER &&
> > +                 (n->nlmsg_flags&NLM_F_CREATE)) {
> > +                     spin_lock_bh(root_lock);
> > +                     tp->next = *back;
> > +                     *back = tp;
> > +                     spin_unlock_bh(root_lock);
> > +             }
> >               tfilter_notify(skb, n, tp, fh, RTM_NEWTFILTER);
> > +     } else {
> > +             if (n->nlmsg_type == RTM_NEWTFILTER &&
> > +                 (n->nlmsg_flags&NLM_F_CREATE)) {
> > +                     tcf_destroy(tp);
> > +             }
> > +     }
> >
> >  errout:
> >       if (cl)
>
