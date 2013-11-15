From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] random: seed random_int_secret at least poorly at
 core_initcall time
Date: Fri, 15 Nov 2013 10:33:04 -0800
Message-ID: <CAGXu5j+ySEdQBXKkspYC=svfekBja2Z_2tcWSAOEbvyiMLf=aA@mail.gmail.com>
References: <cover.1384160397.git.dborkman@redhat.com>
	<2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com>
	<20131111134357.GC10104@thunk.org>
	<20131112000307.GB14929@order.stressinduktion.org>
	<20131112115350.GA14077@thunk.org>
	<20131112131627.GD14929@order.stressinduktion.org>
	<20131112134603.GE14929@order.stressinduktion.org>
	<20131114025448.GB31602@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	shemminger-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, Florian Weimer <fweimer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Theodore Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20131114025448.GB31602-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 13, 2013 at 6:54 PM, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org> wrote:
> On Tue, Nov 12, 2013 at 02:46:03PM +0100, Hannes Frederic Sowa wrote:
>> > It is needed by fork to set up the stack canary. And this actually gets
>> > called before the secret is initialized.
>>
>> Maybe we could use this for the time being and use the seeding method
>> of kaslr as soon as it hits the tree?
>
> Hmm, from what I can tell even early_initcall() is going to be early
> enough.  The stack canary is set up by boot_init_stack_canary(), which
> is run very, very early in start_kerne() --- way before
> early_initcalls, or even before interrupts are enabled.  So adding
> random_int_secret_init_early() as a core_initcall is still too late.
>
> I wonder if we need to do something in common with what Kees has been
> considering for the kaslr code, since it's a similar issue --- we need
> random number way earlier than we can really afford to initialize
> /dev/random.

Right now I've only been looking at x86. As things currently stand,
we'll make use of RDRAND and RDTSC if they're available, and if
neither are then go to the i8254 timer. Ingo wanted even more
unpredictability, in the face of total failure from these more dynamic
sources, so x86 also "seeds" itself with the build string and the
boot_params. These last two are hardly high entropy, but they should
at least make 2 different systems not have _identical_ entropy at the
start. It's far from cryptographically secure, but it's something, I
hope.

> P.S.  Unless I'm missing something (and I hope I am), it would appear
> that the stack canary is going to easily predictable by an attacker on
> non-x86 platforms that don't have RDRAND.  Has someone tested whether
> or not the stack canary isn't constant across ARM or pre-Sandy Bridge
> x86 systems?

When the static stack canary was mentioned during the ARM summit, I
dug around a little bit and saw that at very early boot, yes, it was
always the same, but after boot finished, it was different from boot
to boot. I didn't get far enough to figure out what was changing it
later on.

-Kees

-- 
Kees Cook
Chrome OS Security
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
