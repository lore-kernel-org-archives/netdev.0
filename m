From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] random: seed random_int_secret at least poorly at
 core_initcall time
Date: Fri, 15 Nov 2013 10:42:28 -0800
Message-ID: <CAGXu5jJJtjvAqROzsekOd9Y5wbiw=G9ToNryOfP8auhQRrYORw@mail.gmail.com>
References: <cover.1384160397.git.dborkman@redhat.com>
	<2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com>
	<20131111134357.GC10104@thunk.org>
	<20131112000307.GB14929@order.stressinduktion.org>
	<20131112115350.GA14077@thunk.org>
	<20131112131627.GD14929@order.stressinduktion.org>
	<20131112134603.GE14929@order.stressinduktion.org>
	<20131114025448.GB31602@thunk.org>
	<20131114041829.GA26901@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "Theodore Ts'o" <tytso@mit.edu>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	shemminger@networkplumber.org, Florian Weimer <fweimer@redhat.com>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-wireless@vger.kernel.org, Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:41045 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427Ab3KOSm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 13:42:29 -0500
Received: by mail-oa0-f47.google.com with SMTP id i7so4346328oag.6
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 10:42:28 -0800 (PST)
In-Reply-To: <20131114041829.GA26901@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 8:18 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Nov 13, 2013 at 09:54:48PM -0500, Theodore Ts'o wrote:
>> On Tue, Nov 12, 2013 at 02:46:03PM +0100, Hannes Frederic Sowa wrote:
>> > > It is needed by fork to set up the stack canary. And this actually gets
>> > > called before the secret is initialized.
>> >
>> > Maybe we could use this for the time being and use the seeding method
>> > of kaslr as soon as it hits the tree?
>>
>> Hmm, from what I can tell even early_initcall() is going to be early
>> enough.  The stack canary is set up by boot_init_stack_canary(), which
>> is run very, very early in start_kerne() --- way before
>> early_initcalls, or even before interrupts are enabled.  So adding
>> random_int_secret_init_early() as a core_initcall is still too late.
>
> Actually I tried to protect the tsk->stack_canary = get_random_int()
> in fork.c. It sets up the per-task canary.

I haven't looked closely yet at how the stack canary gets plumbed, but
what do things outside of process context end up using?

>> I wonder if we need to do something in common with what Kees has been
>> considering for the kaslr code, since it's a similar issue --- we need
>> random number way earlier than we can really afford to initialize
>> /dev/random.
>
> Definiteley. I would also propose hashing the boot arguments, often
> enough there is a filesystem UUID in there, or even hash the multiboot
> information we are given from grub. Maybe compile-time entropy, at least
> a bit.

Yeah, other suggestions were things ACPI tables, memory layouts, etc.
Basically anything that might be different from system to system. Even
just perturbing by the build strings (which has compiler version,
build date, build host, etc etc) gets us a tiny amount of entropy
(which is still better than 0).

>> P.S.  Unless I'm missing something (and I hope I am), it would appear
>> that the stack canary is going to easily predictable by an attacker on
>> non-x86 platforms that don't have RDRAND.  Has someone tested whether
>> or not the stack canary isn't constant across ARM or pre-Sandy Bridge
>> x86 systems?
>
> In case of protection for interrupt stacks and early cmwq threads,
> it looks pretty bad from a first look at the source (at least for the
> first initialized CPU).
>
> I'll try to do some tests tomorrow.
>
> Greetings,
>
>   Hannes
>

-Kees

-- 
Kees Cook
Chrome OS Security
