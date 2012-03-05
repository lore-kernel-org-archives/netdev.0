From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v12 07/13] seccomp: add SECCOMP_RET_ERRNO
Date: Mon, 5 Mar 2012 15:03:11 -0600
Message-ID: <CABqD9ha8o3JU0v0ZnKcsjqm8osjSiUfCyvc=vrxhDTHHuG_V4A@mail.gmail.com>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
	<1330559620-23543-7-git-send-email-wad@chromium.org>
	<20120302182455.GA11308@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:44610 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750993Ab2CEVDO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 16:03:14 -0500
Received: by lahj13 with SMTP id j13so5116156lah.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 13:03:12 -0800 (PST)
In-Reply-To: <20120302182455.GA11308@mail.hallyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 2, 2012 at 12:24 PM, Serge E. Hallyn <serge@hallyn.com> wro=
te:
> Quoting Will Drewry (wad@chromium.org):
>> This change adds the SECCOMP_RET_ERRNO as a valid return value from =
a
>> seccomp filter. =A0Additionally, it makes the first use of the lower
>> 16-bits for storing a filter-supplied errno. =A016-bits is more than
>> enough for the errno-base.h calls.
>>
>> Returning errors instead of immediately terminating processes that
>> violate seccomp policy allow for broader use of this functionality
>> for kernel attack surface reduction. =A0For example, a linux contain=
er
>> could maintain a whitelist of pre-existing system calls but drop
>> all new ones with errnos. =A0This would keep a logically static atta=
ck
>> surface while providing errnos that may allow for graceful failure
>> without the downside of do_exit() on a bad call.
>>
>> v12: - move to WARN_ON if filter is NULL
>> =A0 =A0 =A0 =A0(oleg@redhat.com, luto@mit.edu, keescook@chromium.org=
)
>> =A0 =A0 =A0- return immediately for filter=3D=3DNULL (keescook@chrom=
ium.org)
>> =A0 =A0 =A0- change evaluation to only compare the ACTION so that la=
yered
>> =A0 =A0 =A0 =A0errnos don't result in the lowest one being returned.
>> =A0 =A0 =A0 =A0(keeschook@chromium.org)
>> v11: - check for NULL filter (keescook@chromium.org)
>> v10: - change loaders to fn
>> =A0v9: - n/a
>> =A0v8: - update Kconfig to note new need for syscall_set_return_valu=
e.
>> =A0 =A0 =A0- reordered such that TRAP behavior follows on later.
>> =A0 =A0 =A0- made the for loop a little less indent-y
>> =A0v7: - introduced
>>
>> Reviewed-by: Kees Cook <keescook@chromium.org>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>
> Clever :)
>
> Thanks, Will.
>
> For patches 1-7,
>
> Acked-by: Serge Hallyn <serge.hallyn@canonical.com>

Thanks!

> The -1 return value from __secure_computing_int() seems like it
> could stand =A0#define, like
>
> #define SECCOMP_DONTRUN -1
> #define SECCOMP_RUN 0
>
> or something Maybe not, but -1 always scares me and I had to look bac=
k
> and forth a few times to make sure it was doing what I would want.

Works for me.  The -1 just matches what syscall emulation, etc does on
x86.  I'll add this to the tweaks for v14.

Thanks!

> (I've only quickly looked at the following ones. =A0 I had no
> objection, but didn't seriously review them.)
>
>> ---
>> =A0arch/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A06 ++++--
>> =A0include/linux/seccomp.h | =A0 15 +++++++++++----
>> =A0kernel/seccomp.c =A0 =A0 =A0 =A0| =A0 43 ++++++++++++++++++++++++=
++++++++++---------
>> =A03 files changed, 49 insertions(+), 15 deletions(-)
>>
>> diff --git a/arch/Kconfig b/arch/Kconfig
>> index 7a696a9..1350d07 100644
>> --- a/arch/Kconfig
>> +++ b/arch/Kconfig
>> @@ -237,8 +237,10 @@ config HAVE_ARCH_SECCOMP_FILTER
>> =A0 =A0 =A0 bool
>> =A0 =A0 =A0 help
>> =A0 =A0 =A0 =A0 This symbol should be selected by an architecure if =
it provides
>> - =A0 =A0 =A0 asm/syscall.h, specifically syscall_get_arguments() an=
d
>> - =A0 =A0 =A0 syscall_get_arch().
>> + =A0 =A0 =A0 asm/syscall.h, specifically syscall_get_arguments(),
>> + =A0 =A0 =A0 syscall_get_arch(), and syscall_set_return_value(). =A0=
Additionally,
>> + =A0 =A0 =A0 its system call entry path must respect a return value=
 of -1 from
>> + =A0 =A0 =A0 __secure_computing_int() and/or secure_computing().
>>
>> =A0config SECCOMP_FILTER
>> =A0 =A0 =A0 def_bool y
>> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
>> index 6ef133c..a81fccd 100644
>> --- a/include/linux/seccomp.h
>> +++ b/include/linux/seccomp.h
>> @@ -12,13 +12,14 @@
>>
>> =A0/*
>> =A0 * All BPF programs must return a 32-bit value.
>> - * The bottom 16-bits are reserved for future use.
>> + * The bottom 16-bits are for optional return data.
>> =A0 * The upper 16-bits are ordered from least permissive values to =
most.
>> =A0 *
>> =A0 * The ordering ensures that a min_t() over composed return value=
s always
>> =A0 * selects the least permissive choice.
>> =A0 */
>> =A0#define SECCOMP_RET_KILL =A0 =A0 0x00000000U /* kill the task imm=
ediately */
>> +#define SECCOMP_RET_ERRNO =A0 =A00x00030000U /* returns an errno */
>> =A0#define SECCOMP_RET_ALLOW =A0 =A00x7fff0000U /* allow */
>>
>> =A0/* Masks for the return value sections. */
>> @@ -64,11 +65,17 @@ struct seccomp {
>> =A0 =A0 =A0 struct seccomp_filter *filter;
>> =A0};
>>
>> -extern void __secure_computing(int);
>> -static inline void secure_computing(int this_syscall)
>> +/*
>> + * Direct callers to __secure_computing should be updated as
>> + * CONFIG_HAVE_ARCH_SECCOMP_FILTER propagates.
>> + */
>> +extern void __secure_computing(int) __deprecated;
>> +extern int __secure_computing_int(int);
>> +static inline int secure_computing(int this_syscall)
>> =A0{
>> =A0 =A0 =A0 if (unlikely(test_thread_flag(TIF_SECCOMP)))
>> - =A0 =A0 =A0 =A0 =A0 =A0 __secure_computing(this_syscall);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return =A0__secure_computing_int(this_sysc=
all);
>> + =A0 =A0 return 0;
>> =A0}
>>
>> =A0extern long prctl_get_seccomp(void);
>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index 71df324..88dd568 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> @@ -137,21 +137,25 @@ static void *bpf_load(const void *nr, int off,=
 unsigned int size, void *buf)
>> =A0static u32 seccomp_run_filters(int syscall)
>> =A0{
>> =A0 =A0 =A0 struct seccomp_filter *f;
>> - =A0 =A0 u32 ret =3D SECCOMP_RET_KILL;
>> =A0 =A0 =A0 static const struct bpf_load_fn fns =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 bpf_load,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct seccomp_data),
>> =A0 =A0 =A0 };
>> + =A0 =A0 u32 ret =3D SECCOMP_RET_ALLOW;
>> =A0 =A0 =A0 const void *sc_ptr =3D (const void *)(uintptr_t)syscall;
>>
>> + =A0 =A0 /* Ensure unexpected behavior doesn't result in failing op=
en. */
>> + =A0 =A0 if (WARN_ON(current->seccomp.filter =3D=3D NULL))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return SECCOMP_RET_KILL;
>> +
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* All filters are evaluated in order of youngest to o=
ldest. The lowest
>> - =A0 =A0 =A0* BPF return value always takes priority.
>> + =A0 =A0 =A0* BPF return value (ignoring the DATA) always takes pri=
ority.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 for (f =3D current->seccomp.filter; f; f =3D f->prev) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 ret =3D bpf_run_filter(sc_ptr, f->insns, &=
fns);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (ret !=3D SECCOMP_RET_ALLOW)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 u32 cur_ret =3D bpf_run_filter(sc_ptr, f->=
insns, &fns);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if ((cur_ret & SECCOMP_RET_ACTION) < (ret =
& SECCOMP_RET_ACTION))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D cur_ret;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 return ret;
>> =A0}
>> @@ -289,6 +293,13 @@ static int mode1_syscalls_32[] =3D {
>>
>> =A0void __secure_computing(int this_syscall)
>> =A0{
>> + =A0 =A0 /* Filter calls should never use this function. */
>> + =A0 =A0 BUG_ON(current->seccomp.mode =3D=3D SECCOMP_MODE_FILTER);
>> + =A0 =A0 __secure_computing_int(this_syscall);
>> +}
>> +
>> +int __secure_computing_int(int this_syscall)
>> +{
>> =A0 =A0 =A0 int mode =3D current->seccomp.mode;
>> =A0 =A0 =A0 int exit_code =3D SIGKILL;
>> =A0 =A0 =A0 int *syscall;
>> @@ -302,16 +313,29 @@ void __secure_computing(int this_syscall)
>> =A0#endif
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (*syscall =3D=3D this=
_syscall)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (*++syscall);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0#ifdef CONFIG_SECCOMP_FILTER
>> - =A0 =A0 case SECCOMP_MODE_FILTER:
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (seccomp_run_filters(this_syscall) =3D=3D=
 SECCOMP_RET_ALLOW)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 case SECCOMP_MODE_FILTER: {
>> + =A0 =A0 =A0 =A0 =A0 =A0 u32 action =3D seccomp_run_filters(this_sy=
scall);
>> + =A0 =A0 =A0 =A0 =A0 =A0 switch (action & SECCOMP_RET_ACTION) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_ERRNO:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Set the low-order 16-bi=
ts as a errno. */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 syscall_set_return_value(c=
urrent, task_pt_regs(current),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0-(action & SECCOMP_RET_DATA),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A00);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_ALLOW:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_KILL:
>> + =A0 =A0 =A0 =A0 =A0 =A0 default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 seccomp_filter_log_failure(this_syscall)=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 exit_code =3D SIGSYS;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 }
>> =A0#endif
>> =A0 =A0 =A0 default:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
>> @@ -322,6 +346,7 @@ void __secure_computing(int this_syscall)
>> =A0#endif
>> =A0 =A0 =A0 audit_seccomp(this_syscall);
>> =A0 =A0 =A0 do_exit(exit_code);
>> + =A0 =A0 return -1; =A0 =A0 =A0/* never reached */
>> =A0}
>>
>> =A0long prctl_get_seccomp(void)
>> --
>> 1.7.5.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kern=
el" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
