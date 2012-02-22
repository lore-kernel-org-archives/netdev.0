From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it synchronous.
Date: Wed, 22 Feb 2012 15:38:57 -0800
Message-ID: <CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
 <1329845435-2313-7-git-send-email-wad@chromium.org> <9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl>
 <CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Indan Zupancic <indan@nul.nu>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2012 at 11:48 AM, Will Drewry <wad@chromium.org> wrote:
> On Wed, Feb 22, 2012 at 2:34 AM, Indan Zupancic <indan@nul.nu> wrote:
>> On Tue, February 21, 2012 18:30, Will Drewry wrote:
>>> This change enables SIGSYS, defines _sigfields._sigsys, and adds
>>> x86 (compat) arch support. =A0_sigsys defines fields which allow
>>> a signal handler to receive the triggering system call number,
>>> the relevant AUDIT_ARCH_* value for that number, and the address
>>> of the callsite.
>>>
>>> To ensure that SIGSYS delivery occurs on return from the triggering
>>> system call, SIGSYS is added to the SYNCHRONOUS_MASK macro. =A0I'm
>>> this is enough to ensure it will be synchronous or if it is explici=
tly
>>> required to ensure an immediate delivery of the signal upon return =
from
>>> the blocked system call.
>>>
>>> The first consumer of SIGSYS would be seccomp filter. =A0In particu=
lar,
>>> a filter program could specify a new return value, SECCOMP_RET_TRAP=
,
>>> which would result in the system call being denied and the calling
>>> thread signaled. =A0This also means that implementing arch-specific
>>> support can be dependent upon HAVE_ARCH_SECCOMP_FILTER.
>>
>> I think others said this is useful, but I don't see how. Easier
>> debugging compared to checking return values?
>>
>> I suppose SIGSYS can be blocked, so there is no guarantee the proces=
s
>> will be killed.
>
> Yeah, this allows for in-process system call emulation, if desired, o=
r
> for the process to dump core/etc. =A0With RET_ERRNO or RET_KILL, ther=
e
> isn't any feedback to the system about the state of the process. =A0K=
ill
> populates audit_seccomp and dmesg, but if the application
> user/developer isn't the system admin, installing audit bits or
> checking system logs seems onerous.

[Warning: this suggestion may be bad for any number of reasons]

I wonder if it would be helpful to change the semantics of RET_KILL
slightly.  Rather than killing via do_exit, what if it killed via a
forcibly-fatal SIGSYS?  That way, the parent's waitid() / SIGCHLD
would indicate CLD_KILLED with si_status =3D=3D SIGSYS.  The parent cou=
ld
check that and report that the child was probably compromised.

--Andy
