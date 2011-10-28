From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Fri, 28 Oct 2011 04:52:56 +0200
Message-ID: <1319770376.23112.58.camel@edumazet-laptop>
References: <1319764761.23112.14.camel@edumazet-laptop>
	 <20111028012521.GF25795@one.firstfloor.org>
	 <CA+55aFy9oJSK99K=brRzSfSnLocO=PuS7yuKkAcw3t5hATJrfw@mail.gmail.com>
	 <1319766293.6759.17.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319766293.6759.17.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 28 octobre 2011 =C3=A0 02:44 +0100, Ben Hutchings a =C3=A9c=
rit :

> Whether or not it needs to provide any ordering guarantee, atomic_rea=
d()
> must never read more than once, and I think that requires the volatil=
e
> qualification.  It might be clearer to use the ACCESS_ONCE macro,
> however.
>=20

Where this requirement comes from ?

Maybe then introduce atomic_read_once() for users really needing it :)

ACCESS_ONCE will force the read/move instruction I try to avoid :(

By the way, removing volatile on my x86_64 defconfig saves a bit of
space :

# size vmlinux vmlinux.old
   text	   data	    bss	    dec	    hex	filename
10907585	2890992	1540096	15338673	 ea0cb1	vmlinux
10912342	2891056	1540096	15343494	 ea1f86	vmlinux.old

booted and everything seems fine, but obviously lightly tested...

Note : There is still one useless access to page-flags,
'fixing' atomic_read() is not enough.


    0,04 :        ffffffff815e4675:       je     ffffffff815e4870 <tcp_=
sendmsg+0xc80>
    0,08 :        ffffffff815e467b:       mov    (%r9),%rax   // useles=
s
    2,08 :        ffffffff815e467e:       lock incl 0x1c(%r9)
    3,58 :        ffffffff815e4683:       mov    (%r9),%rax
    0,04 :        ffffffff815e4686:       test   $0x80,%ah
    0,00 :        ffffffff815e4689:       jne    ffffffff815e48ee <tcp_=
sendmsg+0xcfe>
