From: Kurt Seifried <kseifried-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Linux kernel ping socket / AF_LLC connect()
 sin_family race
Date: Tue, 4 Apr 2017 12:24:57 -0600
Message-ID: <CANO=Ty0EX8Za3c_0EL2oVFmZ1Az6pmDBeX7uJ7YNrJAOzf498g@mail.gmail.com>
References: <20170324202714.GA29241@openwall.com> <CAAeHK+yrE7+BZztHVn-2jKgLqgzgbBEa4VWCO8SL45oD0nRxEw@mail.gmail.com>
 <CANn89iK-7r3KozC4K1rmWpJ1jM-bhBqessUrkg8HoftnjOks5g@mail.gmail.com>
 <20170325001057.GA31046@openwall.com> <20170404152039.GH3687@suse.de>
Reply-To: oss-security-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=f4030435448cac645e054c5b64dd
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrey Konovalov <andreyknvl-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>, Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>,
	Wade Mealing <wmealing-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: oss-security <oss-security-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
Return-path: <oss-security-return-22033-gcsos-oss-security=m.gmane.org-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Post: <mailto:oss-security-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Help: <mailto:oss-security-help-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <mailto:oss-security-unsubscribe-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Subscribe: <mailto:oss-security-subscribe-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
In-Reply-To: <20170404152039.GH3687-l3A5Bk7waGM@public.gmane.org>
List-Id: netdev.vger.kernel.org

--f4030435448cac645e054c5b64dd
Content-Type: text/plain; charset=UTF-8

Assuming MITRE hasn't had a request for this yet, please use CVE-2017-2671
for this issue.

On Tue, Apr 4, 2017 at 9:20 AM, Marcus Meissner <meissner-l3A5Bk7waGM@public.gmane.org> wrote:

> Hi,
>
> did anyone request a CVE yet?
>
> Ciao, Marcus
> On Sat, Mar 25, 2017 at 01:10:57AM +0100, Solar Designer wrote:
> > On Fri, Mar 24, 2017 at 03:21:06PM -0700, Eric Dumazet wrote:
> > > Looks easy enough to fix ?
> >
> > Oh.  Probably.  Thanks.  Need to test, but I guess you already did?
> >
> > > diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> > > index
> > > 2af6244b83e27ae384e96cf071c10c5a89674804..
> ccfbce13a6333a65dab64e4847dd510dfafb1b43
> > > 100644
> > > --- a/net/ipv4/ping.c
> > > +++ b/net/ipv4/ping.c
> > > @@ -156,17 +156,18 @@ int ping_hash(struct sock *sk)
> > >  void ping_unhash(struct sock *sk)
> > >  {
> > >         struct inet_sock *isk = inet_sk(sk);
> > > +
> > >         pr_debug("ping_unhash(isk=%p,isk->num=%u)\n", isk,
> isk->inet_num);
> > > +       write_lock_bh(&ping_table.lock);
> > >         if (sk_hashed(sk)) {
> > > -               write_lock_bh(&ping_table.lock);
> > >                 hlist_nulls_del(&sk->sk_nulls_node);
> > >                 sk_nulls_node_init(&sk->sk_nulls_node);
> > >                 sock_put(sk);
> > >                 isk->inet_num = 0;
> > >                 isk->inet_sport = 0;
> > >                 sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
> > > -               write_unlock_bh(&ping_table.lock);
> > >         }
> > > +       write_unlock_bh(&ping_table.lock);
> > >  }
> > >  EXPORT_SYMBOL_GPL(ping_unhash);
> >
> > FWIW, in Pavel's original implementation for 2.4.32 (unused), this was:
> >
> > static void ping_v4_unhash(struct sock *sk)
> > {
> >       DEBUG(("ping_v4_unhash(sk=%p,sk->num=%u)\n", sk, sk->num));
> >       write_lock_bh(&ping_hash_lock);
> >       if (sk->pprev) {
> >               if (sk->next)
> >                      sk->next->pprev = sk->pprev;
> >               *sk->pprev = sk->next;
> >               sk->pprev = NULL;
> >               sk->num = 0;
> >               sock_prot_dec_use(sk->prot);
> >               __sock_put(sk);
> >       }
> >       write_unlock_bh(&ping_hash_lock);
> > }
> >
> > Looks like the erroneous optimization (not expecting concurrent activity
> > on the same socket?) was introduced during conversion to 2.6's hlists.
> >
> > So far this cursed function had 3 bugs, two of them security (including
> > this one) and one probably benign (or if not, then effectively a subset
> > of this bug as it performed some unneeded / stale debugging work before
> > acquiring the lock), with all 3 introduced in forward-porting.  Maybe
> > the nature of forward-porting activity makes people relatively
> > inattentive ("compiles with the new interfaces and still works? must be
> > correct"), compared to when writing new code.
> >
> > Anyhow, I share some responsibility for this mess, for having advocated
> > this patch being forward-ported and merged back then.  I still like
> > having this functionality and its userspace security benefits... but I
> > don't like the kernel bugs.
> >
> > Alexander
> >
>
> --
> Marcus Meissner,SUSE LINUX GmbH; Maxfeldstrasse 5; D-90409 Nuernberg; Zi.
> 3.1-33,+49-911-740 53-432,,serv=loki,mail=wotan,type=real <
> meissner-l3A5Bk7waGM@public.gmane.org>
>



-- 

Kurt Seifried -- Red Hat -- Product Security -- Cloud
PGP A90B F995 7350 148F 66BF 7554 160D 4553 5E26 7993
Red Hat Product Security contact: secalert-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org

--f4030435448cac645e054c5b64dd--
