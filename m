From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v17 10/15] seccomp: add SECCOMP_RET_ERRNO
Date: Mon, 9 Apr 2012 14:19:08 -0500
Message-ID: <CABqD9haqDr+b6rJa1=rSB6M_3mZuStFf6o3-Ar511-93bgrvHw@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-11-git-send-email-wad@chromium.org>
	<20120406141936.25d68860.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20120406141936.25d68860.akpm@linux-foundation.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 6, 2012 at 4:19 PM, Andrew Morton <akpm@linux-foundation.or=
g> wrote:
> On Thu, 29 Mar 2012 15:01:55 -0500
> Will Drewry <wad@chromium.org> wrote:
>
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
>>
>> ...
>>
>> @@ -64,11 +65,17 @@ struct seccomp {
>> =A0 =A0 =A0 struct seccomp_filter *filter;
>> =A0};
>>
>> -extern void __secure_computing(int);
>> -static inline void secure_computing(int this_syscall)
>> +/*
>> + * Direct callers to __secure_computing should be updated as
>> + * CONFIG_HAVE_ARCH_SECCOMP_FILTER propagates.
>
> Are there any such callers? =A0There's one I see in arm, but it's cal=
led
> from assembly code.

I think just arm, but I was trying to limit the patch growth as much
as I could, practically.  ARM support is relevant to my interests, and
I need to have patches out for review quite soon (once this series
settles :).

I hesitate to ask, but should I add a patch to this series for arm?

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
>> ...
>>
>> =A0void __secure_computing(int this_syscall)
>> =A0{
>> + =A0 =A0 /* Filter calls should never use this function. */
>> + =A0 =A0 BUG_ON(current->seccomp.mode =3D=3D SECCOMP_MODE_FILTER);
>> + =A0 =A0 __secure_computing_int(this_syscall);
>> +}
>> +
>> +int __secure_computing_int(int this_syscall)
>
> What the heck does "_int" mean here? =A0I read it as "integer" but
> perhaps it's shorthand for "internal". =A0Give us a better name, plea=
se.
> Or a code comment.

It meant "returns an int", but its unclear.  I definitely will add a
comment, but I'm open to better naming.  Perhaps it'd make sense to
bring it inline with the other hook call styles:
  /* <proper comment here> */
  __secure_computing_enter(int this_syscall)

I can keep the other call as 'deprecated', and then remove it once all
the callers are updated.

I'll reply to the rest of the mails shortly - thanks!
will
