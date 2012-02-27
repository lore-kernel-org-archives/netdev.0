From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Mon, 27 Feb 2012 12:15:38 -0800
Message-ID: <CAGXu5j+TzwCHpX6sGkQj4QDeZTR=MkGGaXawzAYbxCJQoT_9aQ@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-6-git-send-email-wad@chromium.org>
	<20120227170922.GA10608@redhat.com>
	<CABqD9hbtFDU_vgBOajG2jJxQoHubcwYWJuHPLjgZkZyjGkQ2uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com
To: Will Drewry <wad@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:34963 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753735Ab2B0UPk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Feb 2012 15:15:40 -0500
Received: by obcva7 with SMTP id va7so5896584obc.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 12:15:39 -0800 (PST)
In-Reply-To: <CABqD9hbtFDU_vgBOajG2jJxQoHubcwYWJuHPLjgZkZyjGkQ2uQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2012 at 11:54 AM, Will Drewry <wad@chromium.org> wrote:
> On Mon, Feb 27, 2012 at 11:09 AM, Oleg Nesterov <oleg@redhat.com> wro=
te:
>> On 02/24, Will Drewry wrote:
>>> +static struct seccomp_filter *get_seccomp_filter(struct seccomp_fi=
lter *orig)
>>> +{
>>> + =A0 =A0 if (!orig)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>>> + =A0 =A0 /* Reference count is bounded by the number of total proc=
esses. */
>>> + =A0 =A0 atomic_inc(&orig->usage);
>>> + =A0 =A0 return orig;
>>> +}
>>> ...
>>> +void copy_seccomp(struct seccomp *child, const struct seccomp *par=
ent)
>>> +{
>>> + =A0 =A0 /* Other fields are handled by dup_task_struct. */
>>> + =A0 =A0 child->filter =3D get_seccomp_filter(parent->filter);
>>> +}
>>
>> This is purely cosmetic, but imho looks a bit confusing.
>>
>> We do not copy seccomp->mode and this is correct, it was already cop=
ied
>> implicitely. So why do we copy ->filter? This is not "symmetrical", =
afaics
>> you can simply do
>>
>> =A0 =A0 =A0 =A0void copy_seccomp(struct seccomp *child)
>> =A0 =A0 =A0 =A0{
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (child->filter)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_inc(child->fil=
ter->usage);
>>
>> But once again, this is cosmetic, feel free to ignore.
>
> Right now get_seccomp_filter does the NULL check, so really this coul=
d
> be reduced to adding an external get_seccomp_filter(p->seccomp.filter=
)
> in place of copy_seccomp().
>
> As to removing the extra arg, that should be fine since the parent
> can't drop its refcount when copy_seccomp is called. =A0At the very
> least, I can make that change so it reads more cleanly.

I had various conflicting thoughts while looking over the refcounting:

- get_seccomp_filter is defined static, and has a single caller: copy_s=
eccomp()
- put isn't static, and has a single caller: kernel/fork.c:free_task()
- having only get_/put_ touch ->usage seems cleaner to me
- seccomp_attach_filter touches ->usage without get_seccomp_filter
- having the initializing routine use atomic_set(..., 1) is a common pa=
ttern

In a fit of extreme bike-shedding, I can't decide which is more sensibl=
e:

- rename put_seccomp_filter to free_seccomp_filter and inline the
get_seccomp_filter logic into copy_seccomp().

or

- create a wrapper for put_seccomp_filter named free_seccomp_filter so
that get_/put_ can both be static.

-Kees

--=20
Kees Cook
ChromeOS Security
