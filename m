From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 22:26:20 -0600
Message-ID: <CABqD9haiko3xLUKFp_MZcd8G7Hsyif75ABk1HOVKNJ7=NZRRsA@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
	<1329422549-16407-3-git-send-email-wad@chromium.org>
	<4F3D61CB.2000301@zytor.com>
	<CABqD9hb3WxKxLZ2GuUrbDM--koW+a3ser5TU8y6+e0sAhOT9dw@mail.gmail.com>
	<4F3D7250.6040504@zytor.com>
	<CAE6n16kweRehdozft0tKOB1P5LtGFJDCLQP=2EXfm8P0enyH=A@mail.gmail.com>
	<4F3D766E.7040205@zytor.com>
	<CABqD9haWxRLac1w3m9rSmyDvcg8jxYcxdmAAsgB7pEEBMHr=2g@mail.gmail.com>
	<4F3D7DD4.6070103@zytor.com>
	<CABqD9hZd41AWZub+wxGWwxJtGWfk+pVWQhn7DM_0q0tS9r_wDA@mail.gmail.com>
	<1329439809.2337.32.camel@localhost>
	<CABqD9hY06gaA7T8f0Te9PFpip6ix7CcbRShWcXutxbivEZJ2og@mail.gmail.com>
	<4F3DD39C.9090905@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Paris <eparis@redhat.com>,
	Markus Gutschke <markus@chromium.org>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, mingo@redhat.com, oleg@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <4F3DD39C.9090905@zytor.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 10:12 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 02/16/2012 07:53 PM, Will Drewry wrote:
>>
>> An earlier change Roland had prodded me toward was adding a
>> syscall_get_arch() call to asm/syscall.h which returned the
>> appropriate audit arch value for the current calling convention. =A0=
I
>> hate to suggest this, but should I go ahead and wire that up for x86
>> now, make it a dependency for HAVE_ARCH_SECCOMP_FILTER (and official=
ly
>> part of asm/syscall.h) then let it trickle into existence? =A0Maybe
>> something like:
>>
>
> ... and we have been talking about making a regset and export it to
> ptrace and core dumps, too.

Would having an audit_arch returning function be useful for building
those cases too? Or would this just be nearly-duplicated code
everywhere?  (As is, ptrace usually takes shortcuts since it has the
arch-specific knowledge, so maybe it just wouldn't matter.)

>> static inline int syscall_get_arch(struct task_struct *task, struct
>> pt_regs *regs)
>> {
>> #ifdef CONFIG_IA32_EMULATION
>> =A0 if (task_thread_info(task)->status & TS_COMPAT)
>> =A0 =A0 return AUDIT_ARCH_I386;
>> #endif
>> #ifdef CONFIG_64BIT
>> =A0 return AUDIT_ARCH_X86_64;
>> #else
>> =A0 return AUDIT_ARCH_I386;
>> #endif
>> }
>>
>
> In this case it could be is_compat_task().

I wasn't sure if it was fine to add any syscall_* functions that
depended on the caller being current.

>> There would be no other callers, though, because everywhere AUDIT_AR=
CH
>> is used it is hardcoded as appropriate. =A0Then when x32 comes along=
, it
>> can figure out where it belongs using tif status and/or regs.
>
> For x32 you have the option of introducing a new value or relying on =
bit
> 30 in eax (and AUDIT_ARCH_X86_64). =A0The latter is more natural, pro=
bably.

Will that bit be visible as the syscall number or will it be stripped
out before passing the number around?  If it's visible, then it
doesn't seem like there'd need to be a new AUDIT_ARCH, but I suspect
someone like Eric will have an actually useful opinion.

thanks!
will
