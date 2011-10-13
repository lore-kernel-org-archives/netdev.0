From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: (splice socket -> pipe) + EPOLLET -> epoll_wait does not not
 wake up !
Date: Thu, 13 Oct 2011 17:43:55 +0200
Message-ID: <1318520635.2393.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAEmTpZG5MN8Ha4=ZcCnWC3jJP9x4Bw7ZEC2vQdOGJZiaG4QYkA@mail.gmail.com>
	 <CAEmTpZFt=j-TQjk_8Hx1Yv781SH8MFR_=OrnfH+vke9Q8JZpFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: =?UTF-8?Q?=D0=9C=D0=B0=D1=80=D0=BA_?=
	 =?UTF-8?Q?=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3?=
	<socketpair@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEmTpZFt=j-TQjk_8Hx1Yv781SH8MFR_=OrnfH+vke9Q8JZpFA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 13 octobre 2011 =C3=A0 20:48 +0600, =D0=9C=D0=B0=D1=80=D0=BA =D0=
=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit :
> The problem:
>=20
> man 7 epoll said:
> For  stream-oriented  files  (e.g.,  pipe, FIFO, stream socket), the
> condition that the read/write I/O space is exhausted can also be
> detected by checking the amount of data read from / written to the
> target file descriptor.  For example, if you call read(2) by asking t=
o
> read a certain amount of data and read(2) returns a lower number of
> bytes, you  can  be  sure of having exhausted the read I/O space for
> the file descriptor.
>=20
> I decide to use splice socket -> pipe instead of recv. So I have
> registered socket's fd in epoll with EPOLLIN|EPOLLET.
>=20
> When data appear in socket faster than I splice() it from socket, the
> following sometimes appear:
>=20
> 1. in my code I sure, that pipe is empty.
> 2. my code do splice(socket, pipe, 65536)
> 3. splice return, say, 53248
> 4. my code accordingly to man, decide not to fire splice() again, as
> it thinks that it will return EWOULDBLOCK=3DEAGAIN.
> 5. so, my code go to epoll_wait to wait for EPOLLIN on socket
> 6. epoll hangs.
>=20
> This is not appear if I do just recv(). But it may be because speed i=
s
> lower, and some race condition in effect.
>=20
> The hacked version of strace output is attached.

Your assumptions about splice() are false.

splice() can transfert partial pages.

So you can hit the 16 pages pipe limit, and splice() doesnt necessarly
returns 16*PAGE_SIZE.

With TCP frames, usually 1460 bytes per PAGE are used.

You must call splice() again and again, unless 0 bytes (EAGAIN) are
returned.
