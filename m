From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: zero copy for relay server
Date: Tue, 29 Mar 2011 06:23:10 +0200
Message-ID: <1301372590.2506.57.camel@edumazet-laptop>
References: <D69C90565D53114396BF743585AF5A09122E61E9E7@VSHINMSMBX01.vshodc.lntinfotech.com>
	 <1301331138.3182.43.camel@edumazet-laptop>
	 <D69C90565D53114396BF743585AF5A09122E61E9E9@VSHINMSMBX01.vshodc.lntinfotech.com>
	 <1301337257.2506.8.camel@edumazet-laptop>
	 <AANLkTimWf4kyi4HJFToXP=HH==hQgObQsHYyRfrSe0FS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Viral Mehta <Viral.Mehta@lntinfotech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36773 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab1C2EXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 00:23:15 -0400
Received: by wwa36 with SMTP id 36so4613909wwa.1
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2011 21:23:13 -0700 (PDT)
In-Reply-To: <AANLkTimWf4kyi4HJFToXP=HH==hQgObQsHYyRfrSe0FS@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 mars 2011 =C3=A0 10:00 +0800, Changli Gao a =C3=A9crit :
> On Tue, Mar 29, 2011 at 2:34 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:

> I think he concerns the overhead of system calls. In order to omit a
> system call, I think you can implement sth. like this:
>=20
> splice2(infd, outfd, pipefd, ...)
>=20

Yes, but given no numbers are given, and no code yet written, I ask the
question.

Giving 4 file descriptors to a single syscall sounds convoluted.


> What you need do is maintaining pipes by yourself.
>=20
> >> 2. I believe underlying PIPE that we are using will also have some=
 size limit
> >>     (like in user space 4K or 64K, not sure)
> >
> > What kind of socket is able to deliver more than 64K frames ?
>=20
> You can enlarge the size with fcntl(pipefd, F_SETPIPE_SZ,...).
>=20

Not really useful, since splice() internals use automatic arrays sized
with PIPE_DEF_BUFFERS.

You can enlarge the size of pipe, but still we are limited to at most
64K in skb_splice_bits() for example [On x86 and its 4KB pages]

This doesnt matter, since skb are limited to 16 pages anyway (or 64Kb)

=46_SETPIPE_SZ only can increase size of pipe ringbuffer (which should =
be
empty or contain at most one skb), therefore increasing dcache needs.

=20
> >
> > sendfile() is based on top of splice(), but it's faster to use spli=
ce().
> >
> >
>=20
> Why? Thanks.
>=20

The real cost is not syscall overhead, but context switches and cache
misses. Adding a "super syscall" adds kernel text and increases icache
misses on real machine (I am not talking about machine used in micro
benchmarks)

Most likely, GRO can significantly speed this workload, while a syscall
avoidance wont.



