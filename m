From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v11 08/12] signal, x86: add SIGSYS info and make it
	synchronous.
Date: Tue, 28 Feb 2012 17:02:57 +0100
Message-ID: <20120228160257.GB3664@redhat.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org> <1330140111-17201-8-git-send-email-wad@chromium.org> <20120227172208.GC10608@redhat.com> <CABqD9hbBj_c1qxD7N0ed3LMy_DXn-163LuNc1E7mSZbGO7oqyw@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
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
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-993-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <CABqD9hbBj_c1qxD7N0ed3LMy_DXn-163LuNc1E7mSZbGO7oqyw@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On 02/27, Will Drewry wrote:
>
> On Mon, Feb 27, 2012 at 11:22 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> > On 02/24, Will Drewry wrote:
> >>
> >> To ensure that SIGSYS delivery occurs on return from the triggering
> >> system call, SIGSYS is added to the SYNCHRONOUS_MASK macro.
> >
> > Hmm. Can't understand... please help.
> >
> >>  #define SYNCHRONOUS_MASK \
> >>       (sigmask(SIGSEGV) | sigmask(SIGBUS) | sigmask(SIGILL) | \
> >> -      sigmask(SIGTRAP) | sigmask(SIGFPE))
> >> +      sigmask(SIGTRAP) | sigmask(SIGFPE) | sigmask(SIGSYS))
> >
> > Why?
> >
> > SYNCHRONOUS_MASK just tells dequeue_signal() "pick them first".
> > This is needed to make sure that the handler for, say SIGSEGV,
> > can use ucontext->ip as a faulting addr.
>
> I think that Roland covered this.  (Since the syscall_rollback was
> called it's nice to let our handler get first go.)

OK, except I do not really understand the "our handler get first go".

Suppose SIGSYS "races" with the pending SIGHUP. With this change
the caller for SIGHUP will be called first. But yes, setup_frame()
will be called for SIGSYS first. Hopefully this is what you want.

> > But seccomp adds info->si_call_addr, this looks unneeded.
>
> True enough.  I can drop it.

Hmm. I meant, the change in SYNCHRONOUS_MASK looks unneeded. Please
keep ->si_call_addr, it is much more convenient than ucontext_t in
userspace.

> It'd only be useful if the SIGSYS wasn't
> being forced and the signal was being handled without ucontext_t
> access.

No, force_ doesn't make any difference in this sense...

In short, the patch looks fine to me, but if you resend it may be
you can update the changelog.

Oleg.
