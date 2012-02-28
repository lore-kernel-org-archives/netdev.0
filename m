From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v11 08/12] signal, x86: add SIGSYS info and make it synchronous.
Date: Tue, 28 Feb 2012 11:06:54 -0600
Message-ID: <CABqD9hbOi7Hk8X3zwewmvU1QTLQ_XDM140oS37XaZNtQajbDsQ@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-8-git-send-email-wad@chromium.org>
	<20120227172208.GC10608@redhat.com>
	<CABqD9hbBj_c1qxD7N0ed3LMy_DXn-163LuNc1E7mSZbGO7oqyw@mail.gmail.com>
	<20120228160257.GB3664@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64332 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039Ab2B1RG5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 12:06:57 -0500
Received: by eekc41 with SMTP id c41so1249225eek.19
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 09:06:55 -0800 (PST)
In-Reply-To: <20120228160257.GB3664@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2012 at 10:02 AM, Oleg Nesterov <oleg@redhat.com> wrote=
:
> On 02/27, Will Drewry wrote:
>>
>> On Mon, Feb 27, 2012 at 11:22 AM, Oleg Nesterov <oleg@redhat.com> wr=
ote:
>> > On 02/24, Will Drewry wrote:
>> >>
>> >> To ensure that SIGSYS delivery occurs on return from the triggeri=
ng
>> >> system call, SIGSYS is added to the SYNCHRONOUS_MASK macro.
>> >
>> > Hmm. Can't understand... please help.
>> >
>> >> =A0#define SYNCHRONOUS_MASK \
>> >> =A0 =A0 =A0 (sigmask(SIGSEGV) | sigmask(SIGBUS) | sigmask(SIGILL)=
 | \
>> >> - =A0 =A0 =A0sigmask(SIGTRAP) | sigmask(SIGFPE))
>> >> + =A0 =A0 =A0sigmask(SIGTRAP) | sigmask(SIGFPE) | sigmask(SIGSYS)=
)
>> >
>> > Why?
>> >
>> > SYNCHRONOUS_MASK just tells dequeue_signal() "pick them first".
>> > This is needed to make sure that the handler for, say SIGSEGV,
>> > can use ucontext->ip as a faulting addr.
>>
>> I think that Roland covered this. =A0(Since the syscall_rollback was
>> called it's nice to let our handler get first go.)
>
> OK, except I do not really understand the "our handler get first go".

Err I meant "gets to go first".

> Suppose SIGSYS "races" with the pending SIGHUP. With this change
> the caller for SIGHUP will be called first. But yes, setup_frame()
> will be called for SIGSYS first. Hopefully this is what you want.

I believe it is.  I just want ucontext_t to be properly populate since
the registers were just rolled back for it.

>> > But seccomp adds info->si_call_addr, this looks unneeded.
>>
>> True enough. =A0I can drop it.
>
> Hmm. I meant, the change in SYNCHRONOUS_MASK looks unneeded. Please
> keep ->si_call_addr, it is much more convenient than ucontext_t in
> userspace.

Sorry for the confusion

>> It'd only be useful if the SIGSYS wasn't
>> being forced and the signal was being handled without ucontext_t
>> access.
>
> No, force_ doesn't make any difference in this sense...

I guess I was thinking about users of signalfd wanting the call site
but force_ avoids it being blockable so that seems largely irrelevant
at present.

> In short, the patch looks fine to me, but if you resend it may be
> you can update the changelog.

Thanks! I will try to clarify the changelog.
will
