From: Solar Designer <solar-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: Re: Linux kernel ping socket / AF_LLC connect() sin_family race
Date: Sat, 25 Mar 2017 01:10:57 +0100
Message-ID: <20170325001057.GA31046@openwall.com>
References: <20170324202714.GA29241@openwall.com> <CAAeHK+yrE7+BZztHVn-2jKgLqgzgbBEa4VWCO8SL45oD0nRxEw@mail.gmail.com> <CANn89iK-7r3KozC4K1rmWpJ1jM-bhBqessUrkg8HoftnjOks5g@mail.gmail.com>
Reply-To: oss-security-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Andrey Konovalov <andreyknvl-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
To: oss-security-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org
Return-path: <oss-security-return-21993-gcsos-oss-security=m.gmane.org-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Post: <mailto:oss-security-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Help: <mailto:oss-security-help-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <mailto:oss-security-unsubscribe-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
List-Subscribe: <mailto:oss-security-subscribe-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANn89iK-7r3KozC4K1rmWpJ1jM-bhBqessUrkg8HoftnjOks5g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Fri, Mar 24, 2017 at 03:21:06PM -0700, Eric Dumazet wrote:
> Looks easy enough to fix ?

Oh.  Probably.  Thanks.  Need to test, but I guess you already did?

> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index
> 2af6244b83e27ae384e96cf071c10c5a89674804..ccfbce13a6333a65dab64e4847dd510dfafb1b43
> 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -156,17 +156,18 @@ int ping_hash(struct sock *sk)
>  void ping_unhash(struct sock *sk)
>  {
>         struct inet_sock *isk = inet_sk(sk);
> +
>         pr_debug("ping_unhash(isk=%p,isk->num=%u)\n", isk, isk->inet_num);
> +       write_lock_bh(&ping_table.lock);
>         if (sk_hashed(sk)) {
> -               write_lock_bh(&ping_table.lock);
>                 hlist_nulls_del(&sk->sk_nulls_node);
>                 sk_nulls_node_init(&sk->sk_nulls_node);
>                 sock_put(sk);
>                 isk->inet_num = 0;
>                 isk->inet_sport = 0;
>                 sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
> -               write_unlock_bh(&ping_table.lock);
>         }
> +       write_unlock_bh(&ping_table.lock);
>  }
>  EXPORT_SYMBOL_GPL(ping_unhash);

FWIW, in Pavel's original implementation for 2.4.32 (unused), this was:

static void ping_v4_unhash(struct sock *sk)
{
	DEBUG(("ping_v4_unhash(sk=%p,sk->num=%u)\n", sk, sk->num));
	write_lock_bh(&ping_hash_lock);
	if (sk->pprev) {
		if (sk->next)
		       sk->next->pprev = sk->pprev;
		*sk->pprev = sk->next;
		sk->pprev = NULL;
		sk->num = 0;
		sock_prot_dec_use(sk->prot);
		__sock_put(sk);
	}
	write_unlock_bh(&ping_hash_lock);
}

Looks like the erroneous optimization (not expecting concurrent activity
on the same socket?) was introduced during conversion to 2.6's hlists.

So far this cursed function had 3 bugs, two of them security (including
this one) and one probably benign (or if not, then effectively a subset
of this bug as it performed some unneeded / stale debugging work before
acquiring the lock), with all 3 introduced in forward-porting.  Maybe
the nature of forward-porting activity makes people relatively
inattentive ("compiles with the new interfaces and still works? must be
correct"), compared to when writing new code.

Anyhow, I share some responsibility for this mess, for having advocated
this patch being forward-ported and merged back then.  I still like
having this functionality and its userspace security benefits... but I
don't like the kernel bugs.

Alexander
