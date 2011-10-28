From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Fri, 28 Oct 2011 14:09:41 +0200
Message-ID: <1319803781.23112.113.camel@edumazet-laptop>
References: <1319764761.23112.14.camel@edumazet-laptop>
	 <20111028012521.GF25795@one.firstfloor.org>
	 <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
	 <1319766293.6759.17.camel@deadeye>
	 <1319770376.23112.58.camel@edumazet-laptop>
	 <1319772566.6759.27.camel@deadeye>
	 <1319777025.23112.67.camel@edumazet-laptop>
	 <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 28 octobre 2011 =C3=A0 04:37 -0700, Linus Torvalds a =C3=A9=
crit :
> On Thu, Oct 27, 2011 at 9:43 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > The only requirement of atomic_read() is that it must return value
> > before or after an atomic_write(), not a garbled value.
>=20
> The problem is that gcc *can* return a garbled value.
>=20
> > In fact, if a compiler is stupid enough to issue two reads on follo=
wing
> > code :
>=20
> The compiler really *can* be that "stupid". Except the code tends to
> look like this:
>=20
>    int value =3D atomic_read(&atomic_var);
>    if (value > 10)
>      return;
>    .. do something with value ..
>=20
> and gcc may decide - under register pressure, and in the absense of a
> 'volatile' - to read 'value' first once for that "> 10" check, and
> then it drops the registers and instead of saving it on the stack
> frame, it can decide to re-load it from atomic_var.
>=20
> IOW, "value" could be two or more different values: one value when
> testing, and *another* value in "do something with value".
>=20
> This is why we have "ACCESS_ONCE()".
>=20
> Whether atomics guarantee ACCESS_ONCE() semantics or not is not
> entirely clear. But afaik, there is no way to tell gcc "access at
> *most* once, and never ever reload".
>=20

What you describe is true for non atomic variables as well, its not par=
t
of the atomic_ops documented semantic.

And we do use ACCESS_ONCE() on the rare cases we need to make sure no
reload is done.

RCU use makes this implied (ACCESS_ONCE() being done in
rcu_dereference()), so we dont have many raw ACCESS_ONCE() in our code.

int value =3D ACCESS_ONCE(atomic_read(&atomic_var));
if (value > 10)
     return;
=2E. do something with value ..

One of such rare use is explained in commit f1987257
(tcp: protect sysctl_tcp_cookie_size reads)

Since its a bit ugly, I suggested :

int value =3D atomic_read_once(&atomic_var);
if (value > 10)
     return;
    .. do something with value ..

I dont know, it seems the right way, but yes it might break things.

We can take the otherway and patch thousand atomic_read() to
atomic_read_stable(), its safer but very boring :)
