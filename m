From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Mon, 9 Apr 2012 14:59:00 -0500
Message-ID: <CABqD9hYE0S4EL6yH-57SfNs+D8GFKJgWVN21VzXpQmRuh2ow=w@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-9-git-send-email-wad@chromium.org>
	<20120406132330.457a05cf.akpm@linux-foundation.org>
	<67e30a0c8655fc53a92e8138bba9de66.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <67e30a0c8655fc53a92e8138bba9de66.squirrel@webmail.greenhost.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 8, 2012 at 1:22 PM, Indan Zupancic <indan@nul.nu> wrote:
> On Sat, April 7, 2012 06:23, Andrew Morton wrote:
>> hm, I'm surprised that we don't have a zero-returning implementation=
 of
>> is_compat_task() when CONFIG_COMPAT=3Dn. =A0Seems silly. =A0Blames A=
rnd.
>
> It's sneakily hidden at the end of compat.h.
>
>>> +/**
>>> + * get_u32 - returns a u32 offset into data
>>> + * @data: a unsigned 64 bit value
>>> + * @index: 0 or 1 to return the first or second 32-bits
>>> + *
>>> + * This inline exists to hide the length of unsigned long.
>>> + * If a 32-bit unsigned long is passed in, it will be extended
>>> + * and the top 32-bits will be 0. If it is a 64-bit unsigned
>>> + * long, then whatever data is resident will be properly returned.
>>> + */
>>> +static inline u32 get_u32(u64 data, int index)
>>> +{
>>> + =A0 =A0return ((u32 *)&data)[index];
>>> +}
>>
>> This seems utterly broken on big-endian machines. =A0If so: fix. =A0=
If not:
>> add comment explaining why?
>
> It's not a bug, it's intentional.
>
> I tried to convince them to have a stable ABI for all archs, but they
> didn't want to make the ABI endianness independent, because it looks
> uglier. The argument being that system call numbers are arch dependen=
t
> anyway.
>
> So a filter for a little endian arch needs to check a different offse=
t
> than one for a big endian archs.

Awkward, but in practice it doesn't seem to matter either way --
especially since properly written filters should check the @arch which
indicates the calling convention, endianness, etc.

>>> +static u32 seccomp_run_filters(int syscall)
>>> +{
>>> + =A0 =A0struct seccomp_filter *f;
>>> + =A0 =A0u32 ret =3D SECCOMP_RET_KILL;
>>> + =A0 =A0/*
>>> + =A0 =A0 * All filters are evaluated in order of youngest to oldes=
t. The lowest
>>> + =A0 =A0 * BPF return value always takes priority.
>>> + =A0 =A0 */
>>
>> The youngest-first design surprised me. =A0It wasn't mentioned at al=
l in
>> the changelog. =A0Thinking about it, I guess it just doesn't matter.=
 =A0But
>> some description of the reasons for and implications of this decisio=
n
>> for the uninitiated would be welcome.
>
> I think it's less confusing to not mention the order at all, exactly
> because it doesn't matter. It has been like this from the start, so
> that's why it's not mentioned in the changelog I guess.

Good call - I will remove that comment.  The only relevant information
is that the lowest return value wins.  I did add a comment up near
struct seccomp_filter with my attempt at explaining the tree
structure, but I didn't detail evaluation order.  In this case, it
only is relevant because our only link to the tree is via our local
pointer which happens to be the "youngest".

> The reason to check the youngest first is because the filters are sha=
red
> between processes: childs inherit it. If later on additional filters =
are
> added, the only way of adding them without modifying an older filter =
is
> by adding them to the head of the list. This way no locking is needed=
,
> because filters are only added and removed single-threadedly, and nev=
er
> modified when being shared.

I tried a handful of other strategies, but in practice this seemed to
meet the needs with the least complexity/overhead.

>>> +/**
>>> + * seccomp_attach_filter: Attaches a seccomp filter to current.
>>> + * @fprog: BPF program to install
>>> + *
>>> + * Returns 0 on success or an errno on failure.
>>> + */
>>> +static long seccomp_attach_filter(struct sock_fprog *fprog)
>>> +{
>>> + =A0 =A0struct seccomp_filter *filter;
>>> + =A0 =A0unsigned long fp_size =3D fprog->len * sizeof(struct sock_=
filter);
>>> + =A0 =A0unsigned long total_insns =3D fprog->len;
>>> + =A0 =A0long ret;
>>> +
>>> + =A0 =A0if (fprog->len =3D=3D 0 || fprog->len > BPF_MAXINSNS)
>>> + =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>>> +
>>> + =A0 =A0for (filter =3D current->seccomp.filter; filter; filter =3D=
 filter->prev)
>>> + =A0 =A0 =A0 =A0 =A0 =A0total_insns +=3D filter->len + 4; =A0/* in=
clude a 4 instr penalty */
>>
>> So tasks don't share filters? =A0We copy them by value at fork? =A0D=
o we do
>> this at vfork() too?
>
> Yes they do. But shared filters are never modified, except for the re=
fcount.
>
>>
>>> + =A0 =A0if (total_insns > MAX_INSNS_PER_PATH)
>>> + =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>>> +
>>> + =A0 =A0/*
>>> + =A0 =A0 * Installing a seccomp filter requires that the task have
>>> + =A0 =A0 * CAP_SYS_ADMIN in its namespace or be running with no_ne=
w_privs.
>>> + =A0 =A0 * This avoids scenarios where unprivileged tasks can affe=
ct the
>>> + =A0 =A0 * behavior of privileged children.
>>> + =A0 =A0 */
>>> + =A0 =A0if (!current->no_new_privs &&
>>> + =A0 =A0 =A0 =A0security_capable_noaudit(current_cred(), current_u=
ser_ns(),
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 C=
AP_SYS_ADMIN) !=3D 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0return -EACCES;
>>> +
>>> + =A0 =A0/* Allocate a new seccomp_filter */
>>> + =A0 =A0filter =3D kzalloc(sizeof(struct seccomp_filter) + fp_size=
, GFP_KERNEL);
>>
>> I think this gives userspace an easy way of causing page allocation
>> failure warnings, by permitting large kmalloc() attempts. =A0Add
>> __GFP_NOWARN?
>
> Max is 32kb. sk_attach_filter() in net/core/filter.c is worse,
> it allocates up to 512kb before even checking the length.
>
> What about using GFP_USER (and adding __GFP_NOWARN to GFP_USER) inste=
ad?

It looks like GFP_USER|__GFP_NOWARN would make sense here.  I'll change=
 it.

>>> + =A0 =A0/* Check and rewrite the fprog via the skb checker */
>>> + =A0 =A0ret =3D sk_chk_filter(filter->insns, filter->len);
>>> + =A0 =A0if (ret)
>>> + =A0 =A0 =A0 =A0 =A0 =A0goto fail;
>>> +
>>> + =A0 =A0/* Check and rewrite the fprog for seccomp use */
>>> + =A0 =A0ret =3D seccomp_chk_filter(filter->insns, filter->len);
>>
>> "check" is spelled "check"!
>
> Yes, it is and he did spell "check" as "Check".
>
> seccomp_chk_filter() mirrors sk_chk_filter(). So it refers to
> "chk", not "check".

I can change it to be written out or leave it matching the networking
code.  Any preferences?

Thanks!
will
