From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v8 3/8] seccomp: add system call filtering using BPF
Date: Thu, 16 Feb 2012 21:53:53 -0600
Message-ID: <CABqD9hY06gaA7T8f0Te9PFpip6ix7CcbRShWcXutxbivEZJ2og@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "H. Peter Anvin" <hpa@zytor.com>,
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
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1329439809.2337.32.camel@localhost>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 6:50 PM, Eric Paris <eparis@redhat.com> wrote:
> On Thu, 2012-02-16 at 17:00 -0600, Will Drewry wrote:
>> On Thu, Feb 16, 2012 at 4:06 PM, H. Peter Anvin <hpa@zytor.com> wrot=
e:
>> > On 02/16/2012 01:51 PM, Will Drewry wrote:
>
>> Then syscall_namespace(current, regs) returns
>> * 0 - SYSCALL_NS_32 (for existing 32 and config_compat)
>> * 1 - SYSCALL_NS_64 (for existing 64 bit)
>> * 2 - SYSCALL_NS_X32 (everything after 2 is arch specific)
>> * ..
>>
>> This patch series is pegged to x86 right now, so it's not a big deal
>> to add a simple syscall_namespace to asm/syscall.h. =A0Of course, th=
e
>> code is always the easy part. =A0Even easier would be to only assign=
 0
>> and 1 in the seccomp_data for 32-bit or 64-bit, then leave the rest =
of
>> the u32 untouched until x32 stabilizes and the TS_COMPAT interaction=
s
>> are sorted.
>
> I don't know if anyone cares, but include/linux/audit.h tries to expo=
se
> this type of information so audit userspace can later piece things ba=
ck
> together. =A0(we get this info from the syscall entry exit code so we=
 know
> which arch it is).
>
> Not sure how x32 is hoping to expose its syscall info, but others are
> going to have the same/similar problem.

An earlier change Roland had prodded me toward was adding a
syscall_get_arch() call to asm/syscall.h which returned the
appropriate audit arch value for the current calling convention.  I
hate to suggest this, but should I go ahead and wire that up for x86
now, make it a dependency for HAVE_ARCH_SECCOMP_FILTER (and officially
part of asm/syscall.h) then let it trickle into existence?  Maybe
something like:

static inline int syscall_get_arch(struct task_struct *task, struct
pt_regs *regs)
{
#ifdef CONFIG_IA32_EMULATION
  if (task_thread_info(task)->status & TS_COMPAT)
    return AUDIT_ARCH_I386;
#endif
#ifdef CONFIG_64BIT
  return AUDIT_ARCH_X86_64;
#else
  return AUDIT_ARCH_I386;
#endif
}

There would be no other callers, though, because everywhere AUDIT_ARCH
is used it is hardcoded as appropriate.  Then when x32 comes along, it
can figure out where it belongs using tif status and/or regs.

I'm not sure what the appropriate way to add things to asm/syscall.h,
but I can certainly do a first cut in the x86 version.

thanks!
