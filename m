From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] random: seed random_int_secret at least poorly at core_initcall time
Date: Thu, 14 Nov 2013 05:18:30 +0100
Message-ID: <20131114041829.GA26901@order.stressinduktion.org>
References: <cover.1384160397.git.dborkman@redhat.com> <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com> <20131111134357.GC10104@thunk.org> <20131112000307.GB14929@order.stressinduktion.org> <20131112115350.GA14077@thunk.org> <20131112131627.GD14929@order.stressinduktion.org> <20131112134603.GE14929@order.stressinduktion.org> <20131114025448.GB31602@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	shemminger@networkplumber.org, fweimer@redhat.com,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-wireless@vger.kernel.org, keescook@chromium.org
To: Theodore Ts'o <tytso@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41906 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab3KNESc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 23:18:32 -0500
Content-Disposition: inline
In-Reply-To: <20131114025448.GB31602@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 09:54:48PM -0500, Theodore Ts'o wrote:
> On Tue, Nov 12, 2013 at 02:46:03PM +0100, Hannes Frederic Sowa wrote:
> > > It is needed by fork to set up the stack canary. And this actually gets
> > > called before the secret is initialized.
> > 
> > Maybe we could use this for the time being and use the seeding method
> > of kaslr as soon as it hits the tree?
> 
> Hmm, from what I can tell even early_initcall() is going to be early
> enough.  The stack canary is set up by boot_init_stack_canary(), which
> is run very, very early in start_kerne() --- way before
> early_initcalls, or even before interrupts are enabled.  So adding
> random_int_secret_init_early() as a core_initcall is still too late.

Actually I tried to protect the tsk->stack_canary = get_random_int()
in fork.c. It sets up the per-task canary.

> I wonder if we need to do something in common with what Kees has been
> considering for the kaslr code, since it's a similar issue --- we need
> random number way earlier than we can really afford to initialize
> /dev/random.

Definiteley. I would also propose hashing the boot arguments, often
enough there is a filesystem UUID in there, or even hash the multiboot
information we are given from grub. Maybe compile-time entropy, at least
a bit.

> P.S.  Unless I'm missing something (and I hope I am), it would appear
> that the stack canary is going to easily predictable by an attacker on
> non-x86 platforms that don't have RDRAND.  Has someone tested whether
> or not the stack canary isn't constant across ARM or pre-Sandy Bridge
> x86 systems?

In case of protection for interrupt stacks and early cmwq threads,
it looks pretty bad from a first look at the source (at least for the
first initialized CPU).

I'll try to do some tests tomorrow.

Greetings,

  Hannes
