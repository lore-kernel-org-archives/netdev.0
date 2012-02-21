From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v10 06/11] seccomp: add SECCOMP_RET_ERRNO
Date: Tue, 21 Feb 2012 16:48:05 -0600
Message-ID: <CABqD9hburo_4Yz+figsSOExun3ckft3UrZpOZTw+aywmCKy-rg@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	<1329845435-2313-6-git-send-email-wad@chromium.org>
	<20120221224128.GJ3990@outflux.net>
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
In-Reply-To: <20120221224128.GJ3990@outflux.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 21, 2012 at 4:41 PM, Kees Cook <keescook@chromium.org> wrot=
e:
> On Tue, Feb 21, 2012 at 11:30:30AM -0600, Will Drewry wrote:
>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index 0043b7e..23f1844 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> @@ -136,22 +136,18 @@ static void *bpf_load(const void *nr, int off,=
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
>> -
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* All filters are evaluated in order of youngest to o=
ldest. The lowest
>> =A0 =A0 =A0 =A0* BPF return value always takes priority.
>> =A0 =A0 =A0 =A0*/
>> - =A0 =A0 for (f =3D current->seccomp.filter; f; f =3D f->prev) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 ret =3D bpf_run_filter(sc_ptr, f->insns, &=
fns);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (ret !=3D SECCOMP_RET_ALLOW)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> - =A0 =A0 }
>> + =A0 =A0 for (f =3D current->seccomp.filter; f; f =3D f->prev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D min_t(u32, ret, bpf_run_filter(sc_=
ptr, f->insns, &fns));
>> =A0 =A0 =A0 return ret;
>> =A0}
>
> I'd like to see this fail closed in the (theoretically impossible, bu=
t
> why risk it) case of there being no filters at all. Could do somethin=
g
> like this:
>
> =A0 =A0 =A0 =A0u32 ret =3D current->seccomp.filter ? SECCOMP_RET_ALLO=
W : SECCOMP_RET_KILL;
>
> Or, just this, to catch the misbehavior:
>
> =A0 =A0 =A0 =A0if (unlikely(current->seccomp.filter =3D=3D NULL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return SECCOMP_RET_KILL;

I think the last one makes the most sense to me.  I'll add it and rev t=
he patch.

thanks!
