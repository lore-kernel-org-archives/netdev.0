From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v8 1/8] sk_run_filter: add support for custom
 load_pointer
Date: Fri, 17 Feb 2012 06:05:03 +0100
Message-ID: <16a5b39e58f3e0bf112918ca032dc4c0.squirrel@webmail.greenhost.nl>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
    <a5e0a6a86bb8a20919b9ae80fd510e46.squirrel@webmail.greenhost.nl>
    <CABqD9hYBs6fnmnDKwkkJCnbfji8NU06_Z6m+am=aJQDbYEJr_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.org,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: "Will Drewry" <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CABqD9hYBs6fnmnDKwkkJCnbfji8NU06_Z6m+am=aJQDbYEJr_Q@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, February 17, 2012 05:13, Will Drewry wrote:
> On Thu, Feb 16, 2012 at 9:04 PM, Indan Zupancic <indan@nul.nu> wrote:
>>> Hello,
>>>
>>> On Thu, February 16, 2012 21:02, Will Drewry wrote:
>>>> This change allows CONFIG_SECCOMP to make use of BPF programs for
>>>> user-controlled system call filtering (as shown in this patch seri=
es).
>>>>
>>>> To minimize the impact on existing BPF evaluation, function pointe=
r
>>>> use must be declared at sk_chk_filter-time. =C2=A0This allows anci=
llary
>>>> load instructions to be generated that use the function pointer ra=
ther
>>>> than adding _any_ code to the existing LD_* instruction paths.
>>>>
>>>> Crude performance numbers using udpflood -l 10000000 against dummy=
0.
>>>> 3 trials for baseline, 3 for with tcpdump. Averaged then differenc=
ed.
>>>> Hard to believe trials were repeated at least a couple more times.
>>>>
>>>> * x86 32-bit (Atom N570 @ 1.66 GHz 2 core HT) [stackprot]:
>>>> - Without: =C2=A094.05s - 76.36s =3D 17.68s
>>>> - With: =C2=A0 =C2=A0 86.22s - 73.30s =3D 12.92s
>>>> - Slowdown per call: -476 nanoseconds
>>>>
>>>> * x86 32-bit (Atom N570 @ 1.66 GHz 2 core HT) [no stackprot]:
>>>> - Without: =C2=A092.06s - 77.81s =3D 14.25s
>>>> - With: =C2=A0 =C2=A0 91.77s - 76.91s =3D 14.86s
>>>> - Slowdown per call: +61 nanoseconds
>>>>
>>>> * x86 64-bit (Atom N570 @ 1.66 GHz 2 core HT) [stackprot]:
>>>> - Without: 122.58s - 99.54s =3D 23.04s
>>>> - With: =C2=A0 =C2=A0115.52s - 98.99s =3D 16.53s
>>>> - Slowdown per call: =C2=A0-651 nanoseconds
>>>>
>>>> * x86 64-bit (Atom N570 @ 1.66 GHz 2 core HT) [no stackprot]:
>>>> - Without: 114.95s - 91.92s =3D 23.03s
>>>> - With: =C2=A0 =C2=A0110.47s - 90.79s =3D 19.68s
>>>> - Slowdown per call: -335 nanoseconds
>>>>
>>>> This makes the x86-32-nossp make sense. =C2=A0Added register press=
ure always
>>>> makes x86-32 sad.
>>>
>>> Your 32-bit numbers are better than your 64-bit numbers, so I don't=
 get
>>> this comment.
>
> They are in the absolute.  Relatively, all performance improved with
> my patch except for x86-nossp.

Why is 32-bit sad if it's faster than the 64-bit version?

I'd say the 64-bit numbers are sad considering the extra registers.

>>> Yeah, testing on Atom is a bit silly.
>
> Making things run well on Atom is important for my daily work.  And i=
t
> usually means (barring Atom-specific weirdness) that it then runs eve=
n
> better on bigger processors :)

=46air enough!

>>>> +#define SKB(_data) ((const struct sk_buff *)(_data))
>>>
>>> Urgh!
>>>
>>> If you had done:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct=
 sk_buff *skb =3D data;
>>>
>>> at the top, all those changed wouldn't be needed and it would look =
better too.
>
> That just means I need to disassemble after to make sure the compiler
> does the right thing.  I'll do that and change it if gcc is doing the
> right thing.

You're telling the compiler the same thing, so it better do the right t=
hing!
It just looks better.

>>> These two should either return 0, be networking-only, just return 0=
/-1 or
>>> use a constant length.
>
> I'm changing it to constant length, but I can get rid of it
> altogether. I don't care either way, it just depends on if there is
> anyone else who will want this support.

Right now there is no one else.

>>>> +#define MAYBE_USE_LOAD_FN(CODE) \
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (flags & BPF_CHK_FLAGS_NO_SKB) { \
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 code =3D BPF_S_ANC_##CODE; \
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break; \
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 }
>>>
>>> You can as well hide everything in the macro then, including the ca=
se,
>>> like the ANCILLARY() macro does.
>
> I'm not sure that would make it any more readable though, especially
> since I don't always break; after.

Ah, true. Because there was a break; in the macro, I assumed it would
always break, for some reason. I wish there was a way to make it look
nice though, it's so ugly.

>
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case BPF_S_LD_W_LEN:
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 MAYBE_USE_LOAD_FN(LD_W_LEN);
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 break;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case BPF_S_LDX_W_LEN:
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 MAYBE_USE_LOAD_FN(LDX_W_LEN);
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 break;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case BPF_S_LD_W_IND:
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 MAYBE_USE_LOAD_FN(LD_W_IND);
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 break;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case BPF_S_LD_H_IND:
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 MAYBE_USE_LOAD_FN(LD_H_IND);
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 break;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case BPF_S_LD_B_IND:
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 MAYBE_USE_LOAD_FN(LD_B_IND);
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 break;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case BPF_S_LDX_B_MSH:
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 MAYBE_USE_LOAD_FN(LDX_B_MSH);
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 break;
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case BPF_S_LD_W_A=
BS:
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 MAYBE_USE_LOAD_FN(LD_W_ABS);
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case BPF_S_LD_H_A=
BS:
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 MAYBE_USE_LOAD_FN(LD_H_ABS);
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case BPF_S_LD_B_A=
BS:
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 MAYBE_USE_LOAD_FN(LD_B_ABS);
>>>> =C2=A0#define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE: =C2=
=A0 =C2=A0 \
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 code =3D BPF_S_ANC_##CODE; =C2=A0=
 =C2=A0 =C2=A0 =C2=A0\
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break
>>>> @@ -572,7 +658,7 @@ int sk_chk_filter(struct sock_filter *filter, =
unsigned int flen)
>>>> =C2=A0 =C2=A0 =C2=A0 }
>>>> =C2=A0 =C2=A0 =C2=A0 return -EINVAL;
>>>> =C2=A0}
>>>> -EXPORT_SYMBOL(sk_chk_filter);
>>>> +EXPORT_SYMBOL(bpf_chk_filter);
>>>>
>>>> =C2=A0/**
>>>> =C2=A0 * =C2=A0 sk_filter_release_rcu - Release a socket filter by=
 rcu_head
>>>> --
>>>> 1.7.5.4
>>>>
>>>
>>> Greetings,
>
> Thanks!

You're welcome!

Indan


