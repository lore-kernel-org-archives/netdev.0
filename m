From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH] random: seed random_int_secret at least poorly at core_initcall time
Date: Thu, 14 Nov 2013 06:05:35 +0100
Message-ID: <20131114050535.GB26901@order.stressinduktion.org>
References: <cover.1384160397.git.dborkman@redhat.com> <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com> <20131111134357.GC10104@thunk.org> <20131112000307.GB14929@order.stressinduktion.org> <20131112115350.GA14077@thunk.org> <20131112131627.GD14929@order.stressinduktion.org> <20131112134603.GE14929@order.stressinduktion.org> <20131114025448.GB31602@thunk.org> <20131114041829.GA26901@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	shemminger-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, fweimer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131114041829.GA26901-5j1vdhnGyZutBveJljeh2VPnkB77EeZ12LY78lusg7I@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 14, 2013 at 05:18:30AM +0100, Hannes Frederic Sowa wrote:
> On Wed, Nov 13, 2013 at 09:54:48PM -0500, Theodore Ts'o wrote:
> > On Tue, Nov 12, 2013 at 02:46:03PM +0100, Hannes Frederic Sowa wrote:
> > > > It is needed by fork to set up the stack canary. And this actually gets
> > > > called before the secret is initialized.
> > > 
> > > Maybe we could use this for the time being and use the seeding method
> > > of kaslr as soon as it hits the tree?
> > 
> > Hmm, from what I can tell even early_initcall() is going to be early
> > enough.  The stack canary is set up by boot_init_stack_canary(), which
> > is run very, very early in start_kerne() --- way before
> > early_initcalls, or even before interrupts are enabled.  So adding
> > random_int_secret_init_early() as a core_initcall is still too late.
> 
> Actually I tried to protect the tsk->stack_canary = get_random_int()
> in fork.c. It sets up the per-task canary.
> 
> > I wonder if we need to do something in common with what Kees has been
> > considering for the kaslr code, since it's a similar issue --- we need
> > random number way earlier than we can really afford to initialize
> > /dev/random.
> 
> Definiteley. I would also propose hashing the boot arguments, often
> enough there is a filesystem UUID in there, or even hash the multiboot
> information we are given from grub. Maybe compile-time entropy, at least
> a bit.
> 
> > P.S.  Unless I'm missing something (and I hope I am), it would appear
> > that the stack canary is going to easily predictable by an attacker on
> > non-x86 platforms that don't have RDRAND.  Has someone tested whether
> > or not the stack canary isn't constant across ARM or pre-Sandy Bridge
> > x86 systems?
> 
> In case of protection for interrupt stacks and early cmwq threads,
> it looks pretty bad from a first look at the source (at least for the
> first initialized CPU).

First output on first cpu of get_random_bytes is always identical on amd64
without rdrand. :/

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
