From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Tue, 10 Apr 2012 15:15:50 -0500
Message-ID: <CABqD9ha5bEEAQKw9w6EwPfmEYPQJ9khtqon8pKu1VedDWyAsZg@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-9-git-send-email-wad@chromium.org>
	<20120406132330.457a05cf.akpm@linux-foundation.org>
	<67e30a0c8655fc53a92e8138bba9de66.squirrel@webmail.greenhost.nl>
	<20120410125443.3ab1a277.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Indan Zupancic <indan@nul.nu>, linux-kernel@vger.kernel.org,
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
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20120410125443.3ab1a277.akpm@linux-foundation.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 2:54 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 9 Apr 2012 04:22:40 +1000
> "Indan Zupancic" <indan@nul.nu> wrote:
>
>> On Sat, April 7, 2012 06:23, Andrew Morton wrote:
>> > hm, I'm surprised that we don't have a zero-returning implementati=
on of
>> > is_compat_task() when CONFIG_COMPAT=3Dn. =A0Seems silly. =A0Blames=
 Arnd.
>>
>> It's sneakily hidden at the end of compat.h.
>>
>> >> +/**
>> >> + * get_u32 - returns a u32 offset into data
>> >> + * @data: a unsigned 64 bit value
>> >> + * @index: 0 or 1 to return the first or second 32-bits
>> >> + *
>> >> + * This inline exists to hide the length of unsigned long.
>> >> + * If a 32-bit unsigned long is passed in, it will be extended
>> >> + * and the top 32-bits will be 0. If it is a 64-bit unsigned
>> >> + * long, then whatever data is resident will be properly returne=
d.
>> >> + */
>> >> +static inline u32 get_u32(u64 data, int index)
>> >> +{
>> >> + =A0return ((u32 *)&data)[index];
>> >> +}
>> >
>> > This seems utterly broken on big-endian machines. =A0If so: fix. =A0=
If not:
>> > add comment explaining why?
>>
>> It's not a bug, it's intentional.
>
> Well it looks like a bug, which is why I suggest that it be clearly
> commented.

I've added a comment indicating it is intentionally ugly.

>> >
>> >> + =A0if (total_insns > MAX_INSNS_PER_PATH)
>> >> + =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>> >> +
>> >> + =A0/*
>> >> + =A0 * Installing a seccomp filter requires that the task have
>> >> + =A0 * CAP_SYS_ADMIN in its namespace or be running with no_new_=
privs.
>> >> + =A0 * This avoids scenarios where unprivileged tasks can affect=
 the
>> >> + =A0 * behavior of privileged children.
>> >> + =A0 */
>> >> + =A0if (!current->no_new_privs &&
>> >> + =A0 =A0 =A0security_capable_noaudit(current_cred(), current_use=
r_ns(),
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CAP=
_SYS_ADMIN) !=3D 0)
>> >> + =A0 =A0 =A0 =A0 =A0return -EACCES;
>> >> +
>> >> + =A0/* Allocate a new seccomp_filter */
>> >> + =A0filter =3D kzalloc(sizeof(struct seccomp_filter) + fp_size, =
GFP_KERNEL);
>> >
>> > I think this gives userspace an easy way of causing page allocatio=
n
>> > failure warnings, by permitting large kmalloc() attempts. =A0Add
>> > __GFP_NOWARN?
>>
>> Max is 32kb. sk_attach_filter() in net/core/filter.c is worse,
>> it allocates up to 512kb before even checking the length.
>
> An order-3 allocation attempt is pretty fragile. =A0This will sometim=
es
> fail.
>
>> What about using GFP_USER (and adding __GFP_NOWARN to GFP_USER) inst=
ead?
>
> Let's be conventional and use the open-coded __GFP_NOWARN.
> __GFP_NOWARN says "this is a big allocation which will sometimes fail
> and I have carefully reviewed the failure paths and runtime tested
> them".
>
> Please carefully review the failure paths and runtime test them ;)

Thankfully the failure path is simple in this case.  Additional
runtime testing in progress :)

>> >> + =A0/* Check and rewrite the fprog via the skb checker */
>> >> + =A0ret =3D sk_chk_filter(filter->insns, filter->len);
>> >> + =A0if (ret)
>> >> + =A0 =A0 =A0 =A0 =A0goto fail;
>> >> +
>> >> + =A0/* Check and rewrite the fprog for seccomp use */
>> >> + =A0ret =3D seccomp_chk_filter(filter->insns, filter->len);
>> >
>> > "check" is spelled "check"!
>>
>> Yes, it is and he did spell "check" as "Check".
>>
>> seccomp_chk_filter() mirrors sk_chk_filter(). So it refers to
>> "chk", not "check".
>
> bah. =A0Two poor identifiers isn't better than one. =A0Whatever.

As per James's comment, reducing it to one poor identifier.

thanks!
