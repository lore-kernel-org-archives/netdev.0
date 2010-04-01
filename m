From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Undefined behaviour of connect(fd, NULL, 0);
Date: Thu, 1 Apr 2010 12:16:43 +0800
Message-ID: <x2j412e6f7f1003312116rd3b3ba96t31267545efe7660f@mail.gmail.com>
References: <20100331223637.31f5f6ed@notabene.brown> <20100331114936.3549ca90@s6510>
	<20100401072412.032aa8e6@notabene.brown> <20100331.141732.225997212.davem@davemloft.net>
	<20100401090756.69bfb57d@notabene.brown> <n2w412e6f7f1003312000o3a69802j120acd3946458517@mail.gmail.com>
	<20100401143805.1f83a161@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f202.google.com ([209.85.223.202]:55157 "EHLO
	mail-iw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab0DAERG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 00:17:06 -0400
Received: by iwn40 with SMTP id 40so623500iwn.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 21:17:03 -0700 (PDT)
In-Reply-To: <20100401143805.1f83a161@notabene.brown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 1, 2010 at 11:38 AM, Neil Brown <neilb@suse.de> wrote:
> I'm not sure I'd say that I "want" any particular patch.
> I just want to know what "connect(fd, NULL, 0)" is supposed to do, an=
d to
> have the kernel be consistent in its behaviour. =C2=A0I'm not really =
fussed what
> the behaviour is.
>
> I suspect the customer wants that patch you have supplied as it would=
 mean
> they don't need to change their code. =C2=A0But I only want it if it =
is "right".
>
> The patch you have provided does what I had assumed Stephen's patch d=
id
> before I actually read it properly.
>
> My feeling is that this patch might be more useful than Stephen's as =
having
> connect(fd, NULL, 0) do what the customer expects seems useful, where=
 as
> having it do the same as setting AF_UNSPEC doesn't add anything.
>
> I've googled around a bit but cannot find any evidence of anyone pass=
ing NULL
> to connect like this, and what documentation I can find doesn't reall=
y
> address the issue at all.
>

I found this from man page for connect(2)

       Generally, connection-based protocol sockets may successfully co=
nnect()
       only once; connectionless protocol sockets may use  connect()  m=
ultiple
       times to change their association.  Connectionless sockets may d=
issolve
       the association by connecting to an address with the  sa_family =
 member
       of sockaddr set to AF_UNSPEC (supported on Linux since kernel 2.=
2).

It only said the meaning of AF_UNSPEC for connectionless sockets, but
not connection sockets like TCP. It means that the behavior of
disconnecting the socket when AF_UNSEPC family address is met is also
undocumented.

The connect() API is a little different. If you try to call connect()
in non-blocking mode, and the API can't connect instantly, it will
return the error code for 'Operation In Progress'. When you call
connect() again, later, it may tell you 'Operation Already In
Progress' to let you know that it's still trying to connect, or it may
give you a successful return code, telling you that the connect has
been made.
from: http://www.scottklement.com/rpg/socktut/nonblocking.html

Someone may use connect() to check if the connection is established or
not. But there is no spec about the addr and addr_len value when
connect(2) is used  this way. Since there is no limit of addr and
addr_len, and we supports addr is NULL to check the status of socket
(Although it is buggy). I think we should treat it like a feature, and
the problem Neil reported is a bug.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
