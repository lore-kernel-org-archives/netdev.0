From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it synchronous.
Date: Wed, 22 Feb 2012 15:53:08 -0800
Message-ID: <CAGXu5jJQrnkCZtcLqK8NEihRgB25C12b0nKp+XWXV_=4QfcVoA@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	<1329845435-2313-7-git-send-email-wad@chromium.org>
	<9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl>
	<CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com>
	<CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Will Drewry <wad@chromium.org>, Indan Zupancic <indan@nul.nu>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org
To: Andrew Lutomirski <luto@mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:59321 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752596Ab2BVXxK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 18:53:10 -0500
Received: by obcva7 with SMTP id va7so733128obc.19
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 15:53:09 -0800 (PST)
In-Reply-To: <CAObL_7Gc0U2JMBQr_kbcVUJwyJq7LRfgdFr+84LR=ec4kSCwEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2012 at 3:38 PM, Andrew Lutomirski <luto@mit.edu> wrote=
:
> On Wed, Feb 22, 2012 at 11:48 AM, Will Drewry <wad@chromium.org> wrot=
e:
>> On Wed, Feb 22, 2012 at 2:34 AM, Indan Zupancic <indan@nul.nu> wrote=
:
>>> On Tue, February 21, 2012 18:30, Will Drewry wrote:
>>>> This change enables SIGSYS, defines _sigfields._sigsys, and adds
>>>> x86 (compat) arch support. =A0_sigsys defines fields which allow
>>>> a signal handler to receive the triggering system call number,
>>>> the relevant AUDIT_ARCH_* value for that number, and the address
>>>> of the callsite.
>>>>
>>>> To ensure that SIGSYS delivery occurs on return from the triggerin=
g
>>>> system call, SIGSYS is added to the SYNCHRONOUS_MASK macro. =A0I'm
>>>> this is enough to ensure it will be synchronous or if it is explic=
itly
>>>> required to ensure an immediate delivery of the signal upon return=
 from
>>>> the blocked system call.
>>>>
>>>> The first consumer of SIGSYS would be seccomp filter. =A0In partic=
ular,
>>>> a filter program could specify a new return value, SECCOMP_RET_TRA=
P,
>>>> which would result in the system call being denied and the calling
>>>> thread signaled. =A0This also means that implementing arch-specifi=
c
>>>> support can be dependent upon HAVE_ARCH_SECCOMP_FILTER.
>>>
>>> I think others said this is useful, but I don't see how. Easier
>>> debugging compared to checking return values?
>>>
>>> I suppose SIGSYS can be blocked, so there is no guarantee the proce=
ss
>>> will be killed.
>>
>> Yeah, this allows for in-process system call emulation, if desired, =
or
>> for the process to dump core/etc. =A0With RET_ERRNO or RET_KILL, the=
re
>> isn't any feedback to the system about the state of the process. =A0=
Kill
>> populates audit_seccomp and dmesg, but if the application
>> user/developer isn't the system admin, installing audit bits or
>> checking system logs seems onerous.
>
> [Warning: this suggestion may be bad for any number of reasons]
>
> I wonder if it would be helpful to change the semantics of RET_KILL
> slightly. =A0Rather than killing via do_exit, what if it killed via a
> forcibly-fatal SIGSYS? =A0That way, the parent's waitid() / SIGCHLD
> would indicate CLD_KILLED with si_status =3D=3D SIGSYS. =A0The parent=
 could
> check that and report that the child was probably compromised.
>
> --Andy

I'd prefer sticking with do_exit. This provides much less chance of
things going wrong. A parent seeing a child killed with SIGKILL is
already pretty distinct, IMO.

-Kees

--=20
Kees Cook
ChromeOS Security
