From: Kees Cook <keescook@chromium.org>
Subject: Re: tip -ENOBOOT - bisected to locking/refcounts, x86/asm: Implement
 fast refcount overflow protection
Date: Thu, 31 Aug 2017 11:45:17 -0700
Message-ID: <CAGXu5j+RPDAP-dK+dizQV4prmWBhqU_G1PccWpME=924-2985w@mail.gmail.com>
References: <1503996623.8323.20.camel@gmx.de> <CAGXu5jLYHy6Damtg_Pc4=G76OUiMV3fcY9+Ru1-Lmiq6VWEgsw@mail.gmail.com>
 <1504025721.6024.25.camel@gmx.de> <1504030207.6560.0.camel@gmx.de>
 <CAGXu5jKSWiZ8NkgUqO6G8fs5R06bMtdFBmZz9MMX-HAk8nXXNw@mail.gmail.com>
 <1504069332.8352.3.camel@gmx.de> <CAGXu5jJim=r8b+y1qQXtuzm9fPyv1tp9ANebxbCc9ic2c83_Mg@mail.gmail.com>
 <1504113212.5852.6.camel@gmx.de> <CAGXu5jJd80-0PJvB51x9ZDETPSoAtRVQ7dQ6HWwd0DYpKBgPFA@mail.gmail.com>
 <1504115735.5852.11.camel@gmx.de> <CAGXu5j+BLj6_LPfKs-vts-mbyJHu8D--WrmWbiT8Zbt-iD65KA@mail.gmail.com>
 <CAGXu5j+neSYAqb8=r42=jQ0LsJTGjCSdpgc9Hv+ipyAFURbCdw@mail.gmail.com>
 <1504145389.23109.4.camel@gmx.de> <CAGXu5jLKXEDdSpxxVM5oHHUWKbSTozx4FZRn70bQm4tQAhMqUQ@mail.gmail.com>
 <1504149176.23109.9.camel@gmx.de> <CAGXu5j+uNU+wqWoCV+Kpdp+DQer4E3VuwO0mtXiW3Dtw_61QKA@mail.gmail.com>
 <CAGXu5jKYPp5D+YxtqrJXsi48UUbjfeREngsys-dU1eP4RnnL+w@mail.gmail.com>
 <1504187918.27500.16.camel@gmx.de> <CAGXu5jL8Ueuw-DLY+Hz8Jd7NgqgyaaN8OVDicFxmcjBhScebOA@mail.gmail.com>
 <1504199967.666.16.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Peter Zijlstra <peterz@infradead.org>,
        LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Network Development <netdev@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504199967.666.16.camel@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2017 at 10:19 AM, Mike Galbraith <efault@gmx.de> wrote:
> On Thu, 2017-08-31 at 10:00 -0700, Kees Cook wrote:
>>
>> Oh! So it's gcc-version sensitive? That's alarming. Is this mapping correct:
>>
>> 4.8.5: WARN, eventual kernel hang
>> 6.3.1, 7.0.1: WARN, but continues working
>
> Yeah, that's correct.  I find that troubling, simply because this gcc
> version has been through one hell of a lot of kernels with me.  Yeah, I
> know, that doesn't exempt it from having bugs, but color me suspicious.

I still can't hit this with a 4.8.5 build. :(

With _RATELIMIT removed, this should, in theory, report whatever goes
negative first...

diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
index c076f710de4c..d4fc6b91c0e6 100644
--- a/arch/x86/mm/extable.c
+++ b/arch/x86/mm/extable.c
@@ -72,6 +72,10 @@ bool ex_handler_refcount(const struct
exception_table_entry *fixup,
                bool zero = regs->flags & X86_EFLAGS_ZF;

                refcount_error_report(regs, zero ? "hit zero" : "overflow");
+       } else if (regs->flags & X86_EFLAGS_SF) {
+               refcount_error_report(regs, "result was negative");
+       } else {
+               refcount_error_report(regs, "unknown state");
        }

        return true;
diff --git a/kernel/panic.c b/kernel/panic.c
index bdd18afa19a4..966ade491543 100644
--- a/kernel/panic.c
+++ b/kernel/panic.c
@@ -605,7 +605,7 @@ EXPORT_SYMBOL(__stack_chk_fail);
 #ifdef CONFIG_ARCH_HAS_REFCOUNT
 void refcount_error_report(struct pt_regs *regs, const char *err)
 {
-       WARN_RATELIMIT(1, "refcount_t %s at %pB in %s[%d], uid/euid: %u/%u\n",
+       WARN(1, "refcount_t %s at %pB in %s[%d], uid/euid: %u/%u\n",
                err, (void *)instruction_pointer(regs),
                current->comm, task_pid_nr(current),
                from_kuid_munged(&init_user_ns, current_uid()),

And if it is still a refcount_inc(), and only on gcc 4.8.5, then I
think we need to study the resulting assembly...

-Kees

-- 
Kees Cook
Pixel Security
