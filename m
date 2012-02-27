From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Mon, 27 Feb 2012 13:54:00 -0600
Message-ID: <CABqD9hbtFDU_vgBOajG2jJxQoHubcwYWJuHPLjgZkZyjGkQ2uQ@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-6-git-send-email-wad@chromium.org>
	<20120227170922.GA10608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:34983 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754218Ab2B0TyD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Feb 2012 14:54:03 -0500
Received: by lahj13 with SMTP id j13so1255744lah.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 11:54:01 -0800 (PST)
In-Reply-To: <20120227170922.GA10608@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2012 at 11:09 AM, Oleg Nesterov <oleg@redhat.com> wrote=
:
> Hello Will.
>
> I missed the previous discussions, and I don't think I can read
> all these emails now. So I apologize in advance if this was already
> discussed.

No worries - any review is appreciated :)

> On 02/24, Will Drewry wrote:
>>
>> =A0struct seccomp {
>> =A0 =A0 =A0 int mode;
>> + =A0 =A0 struct seccomp_filter *filter;
>> =A0};
>
> Minor nit, it seems that the new member can be "ifdef CONFIG_SECCOMP_=
=46ILTER"

Good call - I'll add that.

>> +static long seccomp_attach_filter(struct sock_fprog *fprog)
>> +{
>> + =A0 =A0 struct seccomp_filter *filter;
>> + =A0 =A0 unsigned long fp_size =3D fprog->len * sizeof(struct sock_=
filter);
>> + =A0 =A0 long ret;
>> +
>> + =A0 =A0 if (fprog->len =3D=3D 0 || fprog->len > BPF_MAXINSNS)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>
> OK, this limits the memory PR_SET_SECCOMP can use.
>
> But,
>
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* If there is an existing filter, make it the prev and =
don't drop its
>> + =A0 =A0 =A0* task reference.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 filter->prev =3D current->seccomp.filter;
>> + =A0 =A0 current->seccomp.filter =3D filter;
>> + =A0 =A0 return 0;
>
> this doesn't limit the number of filters, looks like a DoS.
>
> What if the application simply does prctl(PR_SET_SECCOMP, dummy_filte=
r)
> in an endless loop?

It consumes a massive amount of kernel memory and, maybe, the OOM
killer gives it a boot :)

I wasn't sure what the normal convention was for avoiding memory
consumption by user processes. Should I just add a sysctl and a
per-task counter for the max number of filters?

I'm fine doing whatever makes sense here.

>
>
>> +static struct seccomp_filter *get_seccomp_filter(struct seccomp_fil=
ter *orig)
>> +{
>> + =A0 =A0 if (!orig)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 /* Reference count is bounded by the number of total proce=
sses. */
>> + =A0 =A0 atomic_inc(&orig->usage);
>> + =A0 =A0 return orig;
>> +}
>> ...
>> +void copy_seccomp(struct seccomp *child, const struct seccomp *pare=
nt)
>> +{
>> + =A0 =A0 /* Other fields are handled by dup_task_struct. */
>> + =A0 =A0 child->filter =3D get_seccomp_filter(parent->filter);
>> +}
>
> This is purely cosmetic, but imho looks a bit confusing.
>
> We do not copy seccomp->mode and this is correct, it was already copi=
ed
> implicitely. So why do we copy ->filter? This is not "symmetrical", a=
faics
> you can simply do
>
> =A0 =A0 =A0 =A0void copy_seccomp(struct seccomp *child)
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (child->filter)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_inc(child->filt=
er->usage);
>
> But once again, this is cosmetic, feel free to ignore.

Right now get_seccomp_filter does the NULL check, so really this could
be reduced to adding an external get_seccomp_filter(p->seccomp.filter)
in place of copy_seccomp().

As to removing the extra arg, that should be fine since the parent
can't drop its refcount when copy_seccomp is called.  At the very
least, I can make that change so it reads more cleanly.

thanks!
will
