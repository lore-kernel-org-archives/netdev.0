From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v15 04/13] arch/x86: add syscall_get_arch to syscall.h
Date: Wed, 11 Apr 2012 10:41:24 -0500
Message-ID: <CABqD9haw2YutkSQHO0Qq19eveqwKCEi=L3fpCYupqvakW3jDMw@mail.gmail.com>
References: <1331781125-15658-1-git-send-email-wad@chromium.org>
	<1331781125-15658-5-git-send-email-wad@chromium.org>
	<4F6F7362.6030402@zytor.com>
	<CABqD9hZgnrKFY_Wei-ysU=Dy7Og2iEemnqPvcQ14M0+vL65gHQ@mail.gmail.com>
	<4F84F895.4080101@zytor.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <kernel-hardening-return-1244-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <4F84F895.4080101@zytor.com>
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 10:20 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 04/10/2012 08:13 PM, Will Drewry wrote:
>> On Sun, Mar 25, 2012 at 2:34 PM, H. Peter Anvin <hpa@zytor.com> wrote:
>>> On 03/14/2012 08:11 PM, Will Drewry wrote:
>>>>
>>>> +static inline int syscall_get_arch(struct task_struct *task,
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struc=
t pt_regs *regs)
>>>> +{
>>>> +#ifdef CONFIG_IA32_EMULATION
>>>> + =A0 =A0 /*
>>>> + =A0 =A0 =A0* TS_COMPAT is set for 32-bit syscall entries and then
>>>> + =A0 =A0 =A0* remains set until we return to user mode.
>>>> + =A0 =A0 =A0*
>>>> + =A0 =A0 =A0* TIF_IA32 tasks should always have TS_COMPAT set at
>>>> + =A0 =A0 =A0* system call time.
>>>> + =A0 =A0 =A0*/
>>>> + =A0 =A0 if (task_thread_info(task)->status & TS_COMPAT)
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 return AUDIT_ARCH_I386;
>>>> +#endif
>>>> + =A0 =A0 return AUDIT_ARCH_X86_64;
>>>> +}
>>>> =A0#endif =A0 =A0 =A0 /* CONFIG_X86_32 */
>>>>
>>>> =A0#endif =A0 =A0 =A0 /* _ASM_X86_SYSCALL_H */
>>>
>>> Just one FYI on this: after the x32 changes are upstream this can be
>>> implemented in terms of is_ia32_task().
>>
>> Now that I've seen is_ia32_task(), it appears to be exactly the same as =
above:
>> (1) =A0If we're x86_32, it's ia32
>> (2) =A0If we're x86_64, ia32 =3D=3D !!(status & TS_COMPAT)
>> (3) =A0Otherwise, it's x86_64, including x32
>>
>> Am I missing something? Should is_ia32_task(void) take a task_struct?
>> Right now, I don't see any reason to change the code, as posted, but
>> maybe I am mis-reading?
>>
>
> Sorry, answered the wrong question. =A0Yes, it is the same as above...
> just wandered if we could centralize this test. =A0It might indeed make
> sense to provide general predicates which take a task pointer.

Makes sense to me. I'm leaving this specific patch alone at present.

That said, a quick grep shows only  a handful of ia32 references:
./arch/x86/include/asm/compat.h:        return is_ia32_task() || is_x32_tas=
k();
./arch/x86/ia32/ia32_signal.c:  bool ia32 =3D is_ia32_task();
./arch/x86/kernel/ptrace.c:     if (!is_ia32_task())

Would it make sense to make a new predicate or just expand the one
added in 3.4 to take a task_struct parameter? I'm not sure if there'd
be much fallout in converting these from directly checking
current_thread_info to task_thread_info.

It's a small patch either way.

cheers!
will
