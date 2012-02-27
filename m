From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it
 synchronous.
Date: Mon, 27 Feb 2012 13:32:01 +0100
Message-ID: <0333e182d9dad75b4c58315d54b4a16d.squirrel@webmail.greenhost.nl>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
    <1329845435-2313-7-git-send-email-wad@chromium.org>
    <9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl>
    <CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com>
    <CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com>
    <CAGXu5jJQrnkCZtcLqK8NEihRgB25C12b0nKp+XWXV_=4QfcVoA@mail.gmail.com>
    <CABqD9hbC8v-rUBW+4T_-EwDwe1+VDohQZweQ-cxOg2A-iDH5CQ@mail.gmail.com>
    <CAGXu5j+fQqkrrKSm3kmCkCcZJKo-VZjL6kkrOD81LZYBY7tf2g@mail.gmail.com>
    <4F45887A.5010809@zytor.com>
    <CAB=4xhq1sm_ewZ_8Kerf2aN7nGx+DEENse7Lqg5N0wuvqtzUAw@mail.gmail.com>
    <4F459109.1060205@zytor.com>
    <CAB=4xhqndEw3tMPaUcdZh_jcjQcoK_=7GwOc5gVhnz5o_4eWzQ@mail.gmail.com>
    <CABqD9hbsZTtkFzM_8rHqAWjZhiV0iWb6s1eMF9LriH-NybrorA@mail.gmail.com>
    <fe2d4b97d84c1e8053c397a20eec7ac8.squirrel@webmail.greenhost.nl>
    <CAE6n16kusCN9LxwqB1D2Dsm50mtc-6zkRje69D=QDdxxzWFTKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Will Drewry" <wad@chromium.org>,
	"Roland McGrath" <mcgrathr@google.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"Kees Cook" <keescook@chromium.org>,
	"Andrew Lutomirski" <luto@mit.edu>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, tglx@linutronix.de, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com
To: "Markus Gutschke" <markus@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAE6n16kusCN9LxwqB1D2Dsm50mtc-6zkRje69D=QDdxxzWFTKw@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, February 23, 2012 23:33, Markus Gutschke wrote:
> On Thu, Feb 23, 2012 at 14:15, Indan Zupancic <indan@nul.nu> wrote:
>> What about making SECCOMP_RET_TRAP dump core/send SIGSYS if there is
>> no tracer with PTRACE_O_SECCOMP set?
>
> Please don't make things dependent on having a tracer. There are
> applications that don't really need a tracer; in fact, these are
> typically the exact same applications that can benefit from receiving
> SIGSYS and then handling it internally.

My proposal was to send the SIGSYS only when there is no seccomp aware
tracer. If there is no such tracer, the process will receive a SIGSYS
that it can handle internally. So having a tracer isn't required.

I'm curious how you would like to handle SIGSYSs internally, because I
don't see how you could gracefully recover from such failed system call,
so I don't really see the added value compared to fail the syscall with
some ERRNO or to just kill the task. Is it just for notification purposes?

>
> If a tracer was required to set this up, it would make it difficult to
> use gdb, strace, or any other common debugging tools.

gdb and strace and such won't set the PTRACE_O_SECCOMP option, so it
will behave the same whether it's being debugged or not.

The main objective was to reduce the amount of policy in filters,
I thought it could be done by having only one return value which
delegates to user space. But that may be too confusing, and the
interaction between a seccomp aware tracer and SIGSYS aware code
is fuzzy, so I'm not sure if it's a good idea.

>
>> Sending SIGSYS is useful, but it's quite a bit less useful if user
>> space can't handle it in a signal handler, so I don't think it's
>> worth it to make a unblockable version.
>
> Maybe, I am not parsing your e-mail correctly. But don't we already
> get the desired behavior, if SIGSYS is treated the same as any other
> synchronous signal? If it is unblocked and has a handler, the
> application can decide to handle it. If neither one of these
> conditions is true, it terminates the program. Ulimits and
> PR_SET_DUMPABLE determine whether a core file is generated.

The proposal I was replying to wanted to make SIGSYS always kill the
process (with a core dump), so you wouldn't be able to set a handler
any more. I think that is a bad idea. Or did I misunderstood?

Enforcing task termination when there is no handler doesn't make
conceptual sense, because an empty signal handler is effectively
the same as blocking a signal. Though I guess it's simpler to check
for just sigaction in the BPF filters, so perhaps that was the idea.

Greetings,

Indan


