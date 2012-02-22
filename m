From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v10 07/11] signal, x86: add SIGSYS info and make it synchronous.
Date: Wed, 22 Feb 2012 13:48:08 -0600
Message-ID: <CABqD9hY1n9EOAKKT0r9Ev+azhBMnLMAM_FgDNe5we9upVePk_A@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	<1329845435-2313-7-git-send-email-wad@chromium.org>
	<9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	hpa@zytor.com, mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <kernel-hardening-return-912-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <9edbabb2262e3d91a7b8c75dbec03d7f.squirrel@webmail.greenhost.nl>
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2012 at 2:34 AM, Indan Zupancic <indan@nul.nu> wrote:
> On Tue, February 21, 2012 18:30, Will Drewry wrote:
>> This change enables SIGSYS, defines _sigfields._sigsys, and adds
>> x86 (compat) arch support. =A0_sigsys defines fields which allow
>> a signal handler to receive the triggering system call number,
>> the relevant AUDIT_ARCH_* value for that number, and the address
>> of the callsite.
>>
>> To ensure that SIGSYS delivery occurs on return from the triggering
>> system call, SIGSYS is added to the SYNCHRONOUS_MASK macro. =A0I'm
>> this is enough to ensure it will be synchronous or if it is explicitly
>> required to ensure an immediate delivery of the signal upon return from
>> the blocked system call.
>>
>> The first consumer of SIGSYS would be seccomp filter. =A0In particular,
>> a filter program could specify a new return value, SECCOMP_RET_TRAP,
>> which would result in the system call being denied and the calling
>> thread signaled. =A0This also means that implementing arch-specific
>> support can be dependent upon HAVE_ARCH_SECCOMP_FILTER.
>
> I think others said this is useful, but I don't see how. Easier
> debugging compared to checking return values?
>
> I suppose SIGSYS can be blocked, so there is no guarantee the process
> will be killed.

Yeah, this allows for in-process system call emulation, if desired, or
for the process to dump core/etc.  With RET_ERRNO or RET_KILL, there
isn't any feedback to the system about the state of the process.  Kill
populates audit_seccomp and dmesg, but if the application
user/developer isn't the system admin, installing audit bits or
checking system logs seems onerous.

>> v10: - first version based on suggestion
>>
>> Suggested-by: H. Peter Anvin <hpa@zytor.com>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>> ---
>> =A0arch/x86/ia32/ia32_signal.c =A0 | =A0 =A04 ++++
>> =A0arch/x86/include/asm/ia32.h =A0 | =A0 =A06 ++++++
>> =A0include/asm-generic/siginfo.h | =A0 18 ++++++++++++++++++
>> =A0kernel/signal.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
>> =A04 files changed, 29 insertions(+), 1 deletions(-)
>>
>> diff --git a/arch/x86/ia32/ia32_signal.c b/arch/x86/ia32/ia32_signal.c
>> index 6557769..c81d2c7 100644
>> --- a/arch/x86/ia32/ia32_signal.c
>> +++ b/arch/x86/ia32/ia32_signal.c
>> @@ -73,6 +73,10 @@ int copy_siginfo_to_user32(compat_siginfo_t __user *t=
o, siginfo_t
>> *from)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (from->si_code >> 16)=
 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case __SI_FAULT >> 16:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case __SI_SYS >> 16:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_user_ex(fr=
om->si_syscall, &to->si_syscall);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_user_ex(fr=
om->si_arch, &to->si_arch);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case __SI_CHLD >> 16:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_user_ex(=
from->si_utime, &to->si_utime);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_user_ex(=
from->si_stime, &to->si_stime);
>> diff --git a/arch/x86/include/asm/ia32.h b/arch/x86/include/asm/ia32.h
>> index 1f7e625..541485f 100644
>> --- a/arch/x86/include/asm/ia32.h
>> +++ b/arch/x86/include/asm/ia32.h
>> @@ -126,6 +126,12 @@ typedef struct compat_siginfo {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int _band; =A0 =A0 =A0/* POL=
L_IN, POLL_OUT, POLL_MSG */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int _fd;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } _sigpoll;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int _call_addr; /* ca=
lling insn */
>
> Why an int here, but a pointer below?

This is the compat version and it expects to just use an unsigned int
(see the _addr entry in _sigfault earlier in the same file).

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int _syscall; =A0 /* triggerin=
g system call number */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int _arch; =A0 =A0 /*=
 AUDIT_ARCH_* of syscall */
>> + =A0 =A0 =A0 =A0 =A0 =A0 } _sigsys;
>> =A0 =A0 =A0 } _sifields;
>> =A0} compat_siginfo_t;
>>
>> diff --git a/include/asm-generic/siginfo.h b/include/asm-generic/siginfo=
.h
>> index 0dd4e87..a83b478 100644
>> --- a/include/asm-generic/siginfo.h
>> +++ b/include/asm-generic/siginfo.h
>> @@ -90,6 +90,13 @@ typedef struct siginfo {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __ARCH_SI_BAND_T _band; /* P=
OLL_IN, POLL_OUT, POLL_MSG */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int _fd;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } _sigpoll;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* SIGSYS */
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void __user *_call_addr; /* ca=
lling insn */
>
> Is this a user instruction pointer or a filter instruction?

User instruction pointer, I'll clarify.

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int _syscall; =A0 /* triggerin=
g system call number */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int _arch; =A0 =A0 /*=
 AUDIT_ARCH_* of syscall */
>> + =A0 =A0 =A0 =A0 =A0 =A0 } _sigsys;
>> =A0 =A0 =A0 } _sifields;
>> =A0} siginfo_t;
>>
>> @@ -116,6 +123,9 @@ typedef struct siginfo {
>> =A0#define si_addr_lsb =A0_sifields._sigfault._addr_lsb
>> =A0#define si_band =A0 =A0 =A0 =A0 =A0 =A0 =A0_sifields._sigpoll._band
>> =A0#define si_fd =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0_sifields._sigpoll._fd
>> +#define si_call_addr _sifields._sigsys._call_addr
>> +#define si_syscall =A0 _sifields._sigsys._syscall
>> +#define si_arch =A0 =A0 =A0 =A0 =A0 =A0 =A0_sifields._sigsys._arch
>>
>> =A0#ifdef __KERNEL__
>> =A0#define __SI_MASK =A0 =A00xffff0000u
>> @@ -126,6 +136,7 @@ typedef struct siginfo {
>> =A0#define __SI_CHLD =A0 =A0(4 << 16)
>> =A0#define __SI_RT =A0 =A0 =A0 =A0 =A0 =A0 =A0(5 << 16)
>> =A0#define __SI_MESGQ =A0 (6 << 16)
>> +#define __SI_SYS =A0 =A0 (7 << 16)
>> =A0#define __SI_CODE(T,N) =A0 =A0 =A0 ((T) | ((N) & 0xffff))
>> =A0#else
>> =A0#define __SI_KILL =A0 =A00
>> @@ -135,6 +146,7 @@ typedef struct siginfo {
>> =A0#define __SI_CHLD =A0 =A00
>> =A0#define __SI_RT =A0 =A0 =A0 =A0 =A0 =A0 =A00
>> =A0#define __SI_MESGQ =A0 0
>> +#define __SI_SYS =A0 =A0 0
>> =A0#define __SI_CODE(T,N) =A0 =A0 =A0 (N)
>> =A0#endif
>>
>> @@ -232,6 +244,12 @@ typedef struct siginfo {
>> =A0#define NSIGPOLL =A0 =A0 6
>>
>> =A0/*
>> + * SIGSYS si_codes
>> + */
>> +#define SYS_SECCOMP =A0 =A0 =A0 =A0 =A0(__SI_SYS|1) =A0 =A0/* seccomp t=
riggered */
>> +#define NSIGSYS =A0 =A0 =A01
>> +
>> +/*
>> =A0 * sigevent definitions
>> =A0 *
>> =A0 * It seems likely that SIGEV_THREAD will have to be handled from
>> diff --git a/kernel/signal.c b/kernel/signal.c
>> index c73c428..7573819 100644
>> --- a/kernel/signal.c
>> +++ b/kernel/signal.c
>> @@ -160,7 +160,7 @@ void recalc_sigpending(void)
>>
>> =A0#define SYNCHRONOUS_MASK \
>> =A0 =A0 =A0 (sigmask(SIGSEGV) | sigmask(SIGBUS) | sigmask(SIGILL) | \
>> - =A0 =A0 =A0sigmask(SIGTRAP) | sigmask(SIGFPE))
>> + =A0 =A0 =A0sigmask(SIGTRAP) | sigmask(SIGFPE) | sigmask(SIGSYS))
>>
>> =A0int next_signal(struct sigpending *pending, sigset_t *mask)
>> =A0{
>> --

thanks!
will
