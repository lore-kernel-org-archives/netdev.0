From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it synchronous.
Date: Wed, 22 Feb 2012 18:05:05 -0600
Message-ID: <CABqD9hbC8v-rUBW+4T_-EwDwe1+VDohQZweQ-cxOg2A-iDH5CQ@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	<1329845435-2313-7-git-send-email-wad@chromium.org>
	<9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl>
	<CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com>
	<CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com>
	<CAGXu5jJQrnkCZtcLqK8NEihRgB25C12b0nKp+XWXV_=4QfcVoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lutomirski <luto@mit.edu>, Indan Zupancic <indan@nul.nu>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jJQrnkCZtcLqK8NEihRgB25C12b0nKp+XWXV_=4QfcVoA@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2012 at 5:53 PM, Kees Cook <keescook@chromium.org> wrot=
e:
> On Wed, Feb 22, 2012 at 3:38 PM, Andrew Lutomirski <luto@mit.edu> wro=
te:
>> On Wed, Feb 22, 2012 at 11:48 AM, Will Drewry <wad@chromium.org> wro=
te:
>>> On Wed, Feb 22, 2012 at 2:34 AM, Indan Zupancic <indan@nul.nu> wrot=
e:
>>>> On Tue, February 21, 2012 18:30, Will Drewry wrote:
>>>>> This change enables SIGSYS, defines _sigfields._sigsys, and adds
>>>>> x86 (compat) arch support. =A0_sigsys defines fields which allow
>>>>> a signal handler to receive the triggering system call number,
>>>>> the relevant AUDIT_ARCH_* value for that number, and the address
>>>>> of the callsite.
>>>>>
>>>>> To ensure that SIGSYS delivery occurs on return from the triggeri=
ng
>>>>> system call, SIGSYS is added to the SYNCHRONOUS_MASK macro. =A0I'=
m
>>>>> this is enough to ensure it will be synchronous or if it is expli=
citly
>>>>> required to ensure an immediate delivery of the signal upon retur=
n from
>>>>> the blocked system call.
>>>>>
>>>>> The first consumer of SIGSYS would be seccomp filter. =A0In parti=
cular,
>>>>> a filter program could specify a new return value, SECCOMP_RET_TR=
AP,
>>>>> which would result in the system call being denied and the callin=
g
>>>>> thread signaled. =A0This also means that implementing arch-specif=
ic
>>>>> support can be dependent upon HAVE_ARCH_SECCOMP_FILTER.
>>>>
>>>> I think others said this is useful, but I don't see how. Easier
>>>> debugging compared to checking return values?
>>>>
>>>> I suppose SIGSYS can be blocked, so there is no guarantee the proc=
ess
>>>> will be killed.
>>>
>>> Yeah, this allows for in-process system call emulation, if desired,=
 or
>>> for the process to dump core/etc. =A0With RET_ERRNO or RET_KILL, th=
ere
>>> isn't any feedback to the system about the state of the process. =A0=
Kill
>>> populates audit_seccomp and dmesg, but if the application
>>> user/developer isn't the system admin, installing audit bits or
>>> checking system logs seems onerous.
>>
>> [Warning: this suggestion may be bad for any number of reasons]
>>
>> I wonder if it would be helpful to change the semantics of RET_KILL
>> slightly. =A0Rather than killing via do_exit, what if it killed via =
a
>> forcibly-fatal SIGSYS? =A0That way, the parent's waitid() / SIGCHLD
>> would indicate CLD_KILLED with si_status =3D=3D SIGSYS. =A0The paren=
t could
>> check that and report that the child was probably compromised.
>>
>> --Andy
>
> I'd prefer sticking with do_exit. This provides much less chance of
> things going wrong. A parent seeing a child killed with SIGKILL is
> already pretty distinct, IMO.

Hrm, it might be possible to do_exit(SIGSYS) which would be both. It
looks like tsk->exit_code would be SIGSYS then, but I'll look a little
more closely to see what that'll actually do.
