From: Marcus Meissner <meissner@suse.de>
Subject: Re: [oss-security] Linux kernel ping socket / AF_LLC connect()
 sin_family race
Date: Tue, 4 Apr 2017 17:20:39 +0200
Message-ID: <20170404152039.GH3687@suse.de>
References: <20170324202714.GA29241@openwall.com>
 <CAAeHK+yrE7+BZztHVn-2jKgLqgzgbBEa4VWCO8SL45oD0nRxEw@mail.gmail.com>
 <CANn89iK-7r3KozC4K1rmWpJ1jM-bhBqessUrkg8HoftnjOks5g@mail.gmail.com>
 <20170325001057.GA31046@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Vasily Kulikov <segoon@openwall.com>
To: oss-security@lists.openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170325001057.GA31046@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

did anyone request a CVE yet?

Ciao, Marcus
On Sat, Mar 25, 2017 at 01:10:57AM +0100, Solar Designer wrote:
> On Fri, Mar 24, 2017 at 03:21:06PM -0700, Eric Dumazet wrote:
> > Looks easy enough to fix ?
> 
> Oh.  Probably.  Thanks.  Need to test, but I guess you already did?
> 
> > diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> > index
> > 2af6244b83e27ae384e96cf071c10c5a89674804..ccfbce13a6333a65dab64e4847dd510dfafb1b43
> > 100644
> > --- a/net/ipv4/ping.c
> > +++ b/net/ipv4/ping.c
> > @@ -156,17 +156,18 @@ int ping_hash(struct sock *sk)
> >  void ping_unhash(struct sock *sk)
> >  {
> >         struct inet_sock *isk = inet_sk(sk);
> > +
> >         pr_debug("ping_unhash(isk=%p,isk->num=%u)\n", isk, isk->inet_num);
> > +       write_lock_bh(&ping_table.lock);
> >         if (sk_hashed(sk)) {
> > -               write_lock_bh(&ping_table.lock);
> >                 hlist_nulls_del(&sk->sk_nulls_node);
> >                 sk_nulls_node_init(&sk->sk_nulls_node);
> >                 sock_put(sk);
> >                 isk->inet_num = 0;
> >                 isk->inet_sport = 0;
> >                 sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
> > -               write_unlock_bh(&ping_table.lock);
> >         }
> > +       write_unlock_bh(&ping_table.lock);
> >  }
> >  EXPORT_SYMBOL_GPL(ping_unhash);
> 
> FWIW, in Pavel's original implementation for 2.4.32 (unused), this was:
> 
> static void ping_v4_unhash(struct sock *sk)
> {
> 	DEBUG(("ping_v4_unhash(sk=%p,sk->num=%u)\n", sk, sk->num));
> 	write_lock_bh(&ping_hash_lock);
> 	if (sk->pprev) {
> 		if (sk->next)
> 		       sk->next->pprev = sk->pprev;
> 		*sk->pprev = sk->next;
> 		sk->pprev = NULL;
> 		sk->num = 0;
> 		sock_prot_dec_use(sk->prot);
> 		__sock_put(sk);
> 	}
> 	write_unlock_bh(&ping_hash_lock);
> }
> 
> Looks like the erroneous optimization (not expecting concurrent activity
> on the same socket?) was introduced during conversion to 2.6's hlists.
> 
> So far this cursed function had 3 bugs, two of them security (including
> this one) and one probably benign (or if not, then effectively a subset
> of this bug as it performed some unneeded / stale debugging work before
> acquiring the lock), with all 3 introduced in forward-porting.  Maybe
> the nature of forward-porting activity makes people relatively
> inattentive ("compiles with the new interfaces and still works? must be
> correct"), compared to when writing new code.
> 
> Anyhow, I share some responsibility for this mess, for having advocated
> this patch being forward-ported and merged back then.  I still like
> having this functionality and its userspace security benefits... but I
> don't like the kernel bugs.
> 
> Alexander
> 

-- 
Marcus Meissner,SUSE LINUX GmbH; Maxfeldstrasse 5; D-90409 Nuernberg; Zi. 3.1-33,+49-911-740 53-432,,serv=loki,mail=wotan,type=real <meissner@suse.de>
