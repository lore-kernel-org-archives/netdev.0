From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v10 11/11] Documentation: prctl/seccomp_filter
Date: Tue, 21 Feb 2012 19:41:49 -0800
Message-ID: <CABqD9hZkE5BUDAoM8FZSjYZ8nbygm5eW+kkkay6kLshBvf74tg@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	<1329845435-2313-11-git-send-email-wad@chromium.org>
	<20120221231230.GK3990@outflux.net>
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
	markus@chromium.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20120221231230.GK3990@outflux.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 21, 2012 at 3:12 PM, Kees Cook <keescook@chromium.org> wrot=
e:
> Hi,
>
> I've collected the initial no-new-privs patches, and this whole serie=
s
> and pushed it here so I could more easily review it:
> http://git.kernel.org/?p=3Dlinux/kernel/git/kees/linux.git;a=3Dshortl=
og;h=3Drefs/heads/seccomp
>
> Some minor tweaks below...
>
> On Tue, Feb 21, 2012 at 11:30:35AM -0600, Will Drewry wrote:
>> Documents how system call filtering using Berkeley Packet
>> Filter programs works and how it may be used.
>> Includes an example for x86 (32-bit) and a semi-generic
>> example using a macro-based code generator.
>>
>> v10: - update for SIGSYS
>> =A0 =A0 =A0- update for new seccomp_data layout
>> =A0 =A0 =A0- update for ptrace option use
>> v9: - updated bpf-direct.c for SIGILL
>> v8: - add PR_SET_NO_NEW_PRIVS to the samples.
>> v7: - updated for all the new stuff in v7: TRAP, TRACE
>> =A0 =A0 - only talk about PR_SET_SECCOMP now
>> =A0 =A0 - fixed bad JLE32 check (coreyb@linux.vnet.ibm.com)
>> =A0 =A0 - adds dropper.c: a simple system call disabler
>> v6: - tweak the language to note the requirement of
>> =A0 =A0 =A0 PR_SET_NO_NEW_PRIVS being called prior to use. (luto@mit=
=2Eedu)
>> v5: - update sample to use system call arguments
>> =A0 =A0 - adds a "fancy" example using a macro-based generator
>> =A0 =A0 - cleaned up bpf in the sample
>> =A0 =A0 - update docs to mention arguments
>> =A0 =A0 - fix prctl value (eparis@redhat.com)
>> =A0 =A0 - language cleanup (rdunlap@xenotime.net)
>> v4: - update for no_new_privs use
>> =A0 =A0 - minor tweaks
>> v3: - call out BPF <-> Berkeley Packet Filter (rdunlap@xenotime.net)
>> =A0 =A0 - document use of tentative always-unprivileged
>> =A0 =A0 - guard sample compilation for i386 and x86_64
>> v2: - move code to samples (corbet@lwn.net)
>>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>> ---
>> =A0Documentation/prctl/seccomp_filter.txt | =A0157 +++++++++++++++++=
++++
>> =A0samples/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A02 +-
>> =A0samples/seccomp/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 31 +++=
+
>> =A0samples/seccomp/bpf-direct.c =A0 =A0 =A0 =A0 =A0 | =A0150 +++++++=
+++++++++++++
>> =A0samples/seccomp/bpf-fancy.c =A0 =A0 =A0 =A0 =A0 =A0| =A0102 +++++=
+++++++++
>> =A0samples/seccomp/bpf-helper.c =A0 =A0 =A0 =A0 =A0 | =A0 89 +++++++=
+++++
>> =A0samples/seccomp/bpf-helper.h =A0 =A0 =A0 =A0 =A0 | =A0236 +++++++=
+++++++++++++++++++++++++
>> =A0samples/seccomp/dropper.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 68 +++=
++++++
>> =A08 files changed, 834 insertions(+), 1 deletions(-)
>> =A0create mode 100644 Documentation/prctl/seccomp_filter.txt
>> =A0create mode 100644 samples/seccomp/Makefile
>> =A0create mode 100644 samples/seccomp/bpf-direct.c
>> =A0create mode 100644 samples/seccomp/bpf-fancy.c
>> =A0create mode 100644 samples/seccomp/bpf-helper.c
>> =A0create mode 100644 samples/seccomp/bpf-helper.h
>> =A0create mode 100644 samples/seccomp/dropper.c
>>
>> diff --git a/Documentation/prctl/seccomp_filter.txt b/Documentation/=
prctl/seccomp_filter.txt
>> new file mode 100644
>> index 0000000..7de865b
>> --- /dev/null
>> +++ b/Documentation/prctl/seccomp_filter.txt
>> @@ -0,0 +1,157 @@
>> + =A0 =A0 =A0 =A0 =A0 =A0 SECure COMPuting with filters
>> + =A0 =A0 =A0 =A0 =A0 =A0 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +
>> +Introduction
>> +------------
>> +
>> +A large number of system calls are exposed to every userland proces=
s
>> +with many of them going unused for the entire lifetime of the proce=
ss.
>> +As system calls change and mature, bugs are found and eradicated. =A0=
A
>> +certain subset of userland applications benefit by having a reduced=
 set
>> +of available system calls. =A0The resulting set reduces the total k=
ernel
>> +surface exposed to the application. =A0System call filtering is mea=
nt for
>> +use with those applications.
>> +
>> +Seccomp filtering provides a means for a process to specify a filte=
r for
>> +incoming system calls. =A0The filter is expressed as a Berkeley Pac=
ket
>> +Filter (BPF) program, as with socket filters, except that the data
>> +operated on is related to the system call being made: system call
>> +number and the system call arguments. =A0This allows for expressive
>> +filtering of system calls using a filter program language with a lo=
ng
>> +history of being exposed to userland and a straightforward data set=
=2E
>> +
>> +Additionally, BPF makes it impossible for users of seccomp to fall =
prey
>> +to time-of-check-time-of-use (TOCTOU) attacks that are common in sy=
stem
>> +call interposition frameworks. =A0BPF programs may not dereference
>> +pointers which constrains all filters to solely evaluating the syst=
em
>> +call arguments directly.
>> +
>> +What it isn't
>> +-------------
>> +
>> +System call filtering isn't a sandbox. =A0It provides a clearly def=
ined
>> +mechanism for minimizing the exposed kernel surface. =A0It is meant=
 to be
>> +a tool for sandbox developers to use. =A0Beyond that, policy for lo=
gical
>> +behavior and information flow should be managed with a combination =
of
>> +other system hardening techniques and, potentially, an LSM of your
>> +choosing. =A0Expressive, dynamic filters provide further options do=
wn this
>> +path (avoiding pathological sizes or selecting which of the multipl=
exed
>> +system calls in socketcall() is allowed, for instance) which could =
be
>> +construed, incorrectly, as a more complete sandboxing solution.
>> +
>> +Usage
>> +-----
>> +
>> +An additional seccomp mode is added and is enabled using the same
>> +prctl(2) call as the strict seccomp. =A0If the architecture has
>> +CONFIG_HAVE_ARCH_SECCOMP_FILTER, then filters may be added as below=
:
>> +
>> +PR_SET_SECCOMP:
>> + =A0 =A0 Now takes an additional argument which specifies a new fil=
ter
>> + =A0 =A0 using a BPF program.
>> + =A0 =A0 The BPF program will be executed over struct seccomp_data
>> + =A0 =A0 reflecting the system call number, arguments, and other
>> + =A0 =A0 metadata. =A0The BPF program must then return one of the
>> + =A0 =A0 acceptable values to inform the kernel which action should=
 be
>> + =A0 =A0 taken.
>> +
>> + =A0 =A0 Usage:
>> + =A0 =A0 =A0 =A0 =A0 =A0 prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER,=
 prog);
>> +
>> + =A0 =A0 The 'prog' argument is a pointer to a struct sock_fprog wh=
ich
>> + =A0 =A0 will contain the filter program. =A0If the program is inva=
lid, the
>> + =A0 =A0 call will return -1 and set errno to EINVAL.
>> +
>> + =A0 =A0 Note, is_compat_task is also tracked for the @prog. =A0Thi=
s means
>> + =A0 =A0 that once set the calling task will have all of its system=
 calls
>> + =A0 =A0 blocked if it switches its system call ABI.
>> +
>> + =A0 =A0 If fork/clone and execve are allowed by @prog, any child
>> + =A0 =A0 processes will be constrained to the same filters and syst=
em
>> + =A0 =A0 call ABI as the parent.
>> +
>> + =A0 =A0 Prior to use, the task must call prctl(PR_SET_NO_NEW_PRIVS=
, 1) or
>> + =A0 =A0 run with CAP_SYS_ADMIN privileges in its namespace. =A0If =
these are not
>> + =A0 =A0 true, -EACCES will be returned. =A0This requirement ensure=
s that filter
>> + =A0 =A0 programs cannot be applied to child processes with greater=
 privileges
>> + =A0 =A0 than the task that installed them.
>> +
>> + =A0 =A0 Additionally, if prctl(2) is allowed by the attached filte=
r,
>> + =A0 =A0 additional filters may be layered on which will increase e=
valuation
>> + =A0 =A0 time, but allow for further decreasing the attack surface =
during
>> + =A0 =A0 execution of a process.
>> +
>> +The above call returns 0 on success and non-zero on error.
>> +
>> +Return values
>> +-------------
>> +
>> +A seccomp filter may return any of the following values:
>> + =A0 =A0 SECCOMP_RET_ALLOW, SECCOMP_RET_KILL, SECCOMP_RET_TRAP,
>> + =A0 =A0 SECCOMP_RET_ERRNO, or SECCOMP_RET_TRACE.
>> +
>> +SECCOMP_RET_ALLOW:
>> + =A0 =A0 If all filters for a given task return this value then
>> + =A0 =A0 the system call will proceed normally.
>> +
>> +SECCOMP_RET_KILL:
>> + =A0 =A0 If any filters for a given take return this value then
>> + =A0 =A0 the task will exit immediately without executing the syste=
m
>> + =A0 =A0 call.
>> +
>> +SECCOMP_RET_TRAP:
>> + =A0 =A0 If any filters specify SECCOMP_RET_TRAP and none of them
>> + =A0 =A0 specify SECCOMP_RET_KILL, then the kernel will send a SIGT=
RAP
>> + =A0 =A0 signal to the task and not execute the system call. =A0The=
 kernel
>> + =A0 =A0 will rollback the register state to just before system cal=
l
>> + =A0 =A0 entry such that a signal handler in the process will be ab=
le
>> + =A0 =A0 to inspect the ucontext_t->uc_mcontext registers and emula=
te
>> + =A0 =A0 system call success or failure upon return from the signal
>> + =A0 =A0 handler.
>> +
>> + =A0 =A0 The SIGTRAP is differentiated by other SIGTRAPS by a si_co=
de
>> + =A0 =A0 of TRAP_SECCOMP.
>
> This should reflect the SIGTRAP->SIGSYS change (and SYS_SECCOMP si_co=
de
> change).

Oops - yup.

>> +
>> +SECCOMP_RET_ERRNO:
>> + =A0 =A0 If returned, the value provided in the lower 16-bits is
>> + =A0 =A0 returned to userland as the errno and the system call is
>> + =A0 =A0 not executed.
>
> The other sections each say "If any" or "If all" to clarify their
> behavior with multiple filters. The same should be done here, but mor=
e
> comments below. Additionally, it should clarify that on multiple
> uses of RET_ERRNO, the lower of the errnos will be returned.

I might drop all of the written out precedence verbiage since your
layout is more intuitive without it I think.

>> +
>> +SECCOMP_RET_TRACE:
>> + =A0 =A0 If any filters return this value and the others return
>> + =A0 =A0 SECCOMP_RET_ALLOW, then the kernel will attempt to notify
>> + =A0 =A0 a ptrace()-based tracer prior to executing the system call=
=2E
>> +
>> + =A0 =A0 A tracer will be notified if it requests PTRACE_O_TRACESEC=
COMP
>> + =A0 =A0 via PTRACE_SETOPTIONS. =A0Otherwise, the system call will
>> + =A0 =A0 not execute and -ENOSYS will be returned to userspace.
>> +
>> + =A0 =A0 If the tracer ignores notification, then the system call w=
ill
>> + =A0 =A0 proceed normally. =A0Changes to the registers will functio=
n
>> + =A0 =A0 similarly to PTRACE_SYSCALL. =A0Additionally, if the trace=
r
>> + =A0 =A0 detaches during notification or just after, the task may b=
e
>> + =A0 =A0 terminated as precautionary measure.
>> +
>> +Please note that the order of precedence is as follows:
>> +SECCOMP_RET_KILL, SECCOMP_RET_ERRNO, SECCOMP_RET_TRAP,
>> +SECCOMP_RET_TRACE, SECCOMP_RET_ALLOW.
>> +
>> +If multiple filters exist, the return value for the evaluation of a=
 given
>> +system call will always use the highest precedent value.
>> +SECCOMP_RET_KILL will always take precedence.
>
> I think this clarification about precedence is good but should be at =
the
> head of the "Return values" section, and the sections ordered from th=
at
> perspective, so that the "highest precedent value" aspect is a little
> bit easier to follow:
>
>
> Return values
> -------------
> A seccomp filter may return any of the following values. If multiple
> filters exist, the return value for the evaluation of a given system
> call will always use the highest precedent value. (For example,
> SECCOMP_RET_KILL will always take precedence.)
>
> In precedence order, they are:
>
> SECCOMP_RET_KILL:
> =A0 =A0 =A0 =A0If any filters for a given take return this value then
> =A0 =A0 =A0 =A0the task will exit immediately without executing the s=
ystem
> =A0 =A0 =A0 =A0call.
>
> SECCOMP_RET_TRAP:
> =A0 =A0 =A0 =A0If any filters specify SECCOMP_RET_TRAP and none of th=
em
> =A0 =A0 =A0 =A0specify SECCOMP_RET_KILL, then the kernel will send a =
SIGSYS
> =A0 =A0 =A0 =A0signal to the task and not execute the system call. Th=
e kernel
> =A0 =A0 =A0 =A0will rollback the register state to just before system=
 call
> =A0 =A0 =A0 =A0entry such that a signal handler in the process will b=
e able
> =A0 =A0 =A0 =A0to inspect the ucontext_t->uc_mcontext registers and e=
mulate
> =A0 =A0 =A0 =A0system call success or failure upon return from the si=
gnal
> =A0 =A0 =A0 =A0handler.
>
> =A0 =A0 =A0 =A0The SIGSYS is differentiated by other SIGSYS signals b=
y a si_code
> =A0 =A0 =A0 =A0of SYS_SECCOMP.
>
> SECCOMP_RET_ERRNO:
> =A0 =A0 =A0 =A0If any filters return this value and none of them spec=
ify a
> =A0 =A0 =A0 =A0higher precedence value, then the lowest of the values=
 provided
> =A0 =A0 =A0 =A0in the lower 16-bits is returned to userland as the er=
rno and
> =A0 =A0 =A0 =A0the system call is not executed.
>
> SECCOMP_RET_TRACE:
> =A0 =A0 =A0 =A0If any filters return this value and none of them spec=
ify a
> =A0 =A0 =A0 =A0higher precedence value, then the kernel will attempt =
to notify
> =A0 =A0 =A0 =A0a ptrace()-based tracer prior to executing the system =
call.
>
> =A0 =A0 =A0 =A0A tracer will be notified if it requests PTRACE_O_TRAC=
ESECCOMP
> =A0 =A0 =A0 =A0via PTRACE_SETOPTIONS. Otherwise, the system call will
> =A0 =A0 =A0 =A0not execute and -ENOSYS will be returned to userspace.
> =A0 =A0 =A0 =A0If the tracer ignores notification, then the system ca=
ll will
> =A0 =A0 =A0 =A0proceed normally. Changes to the registers will functi=
on
> =A0 =A0 =A0 =A0similarly to PTRACE_SYSCALL. Additionally, if the trac=
er
> =A0 =A0 =A0 =A0detaches during notification or just after, the task m=
ay be
> =A0 =A0 =A0 =A0terminated as precautionary measure.
>
> SECCOMP_RET_ALLOW:
> =A0 =A0 =A0 =A0If all filters for a given task return this value then
> =A0 =A0 =A0 =A0the system call will proceed normally.
>

Thanks! I'll integrate all of this and post a full v11 series in the
morning (depending on any feedback trickling later :).

cheers,
will
