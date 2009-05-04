From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH] Implementation of the sendgroup() system call
Date: Mon, 04 May 2009 09:42:51 +0200
Message-ID: <ca171d917a9c2657184c8fcd0a4b654e@chewa.net>
References: <49FE47A1.7070700@uwaterloo.ca> <87eiv5ibnd.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Elad Lahav <elahav@uwaterloo.ca>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:44952 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753257AbZEDHmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 03:42:52 -0400
In-Reply-To: <87eiv5ibnd.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 04 May 2009 10:13:10 ext Andi Kleen wrote:=0D
> Elad Lahav <elahav@uwaterloo.ca> writes:=0D
> > The attached patch contains an implementation of sendgroup(), a sys=
tem=0D
> > call that allows a UDP packet to be transmitted efficiently to=0D
> > multiple recipients. Use cases for this system call include=0D
> > live-streaming and multi-player online games.=0D
> > The basic idea is that the caller maintains a group - a list of IP=0D
> > addresses and UDP ports - and calls sendgroup() with the group list=
=0D
> > and a common payload. Optionally, the call allows for per-recipient=
=0D
> > data to be prepended or appended to the shared block. The data is=0D
> > copied once in the kernel into an allocated page, and the=0D
> > per-recipient socket buffers point to that page. Savings come from=0D
> > avoiding both the multiple calls and the multiple copies of the dat=
a=0D
> > required with regular socket operations.=0D
>=0D
> My guess it's more the copies than the calls? It sounds like=0D
> you want sendfile() for UDP. I think that would be a cleaner solution=
=0D
> than such a specific hack for your application. It would=0D
> have the advantage of saving the first copy too and be=0D
> truly zero copy on capable NICs.=0D
=0D
Say you have a fragmented skbuff-capable NIC.=0D
=0D
It is already possible to write() to a pipe, then issue a series of N t=
ee()=0D
from the pipe for each of N connected sockets, and finally splice() to=0D
/dev/null. That would be one copy and N+2 system calls. I guess the one=
=0D
copy cannot be removed because UDP payloads are not page-sized, so=0D
vmsplice() won't cut it. As a small optmization, you could replace the =
last=0D
tee() with a splice(), so that's N+1 system calls.=0D
=0D
When using a non-connected socket and multiple destination, then you ne=
ed=0D
one corked sendmsg() to set the destination, followed by one splice() t=
o=0D
push the payload. That's at least 2N+1 system calls.=0D
=0D
UDP payload will typically be small, probably 1400 bytes or less. The=0D
system call overhead might well be higher than the memory copy overhead=
=2E=0D
=0D
On top of that, the splice() trick only works if the NIC can cope with=0D
fragments. The performance might be worse than with normal sendto(). Th=
e=0D
application has no way to check this from the socket. For a reason.=0D
Depending on the routing table, different destinations could use differ=
ent=0D
NICs with different capabilities.=0D
=0D
To sum up, I can see to problems using splice() and friends here, with=0D
regards to the use case:=0D
- no support for destination socket addesses,=0D
- no support for batch tee() operations.=0D
=0D
Whether that justifies a new socket call is not for me to opiniate.=0D
Personally, I would definitely use it in the RTSP broadcast output of t=
he=0D
VLC media player once/if it ever hits glibc.=0D
=0D
> Or perhaps simple send to a local multicast group and let=0D
> some netfilter module turn that into regular UDP.=0D
=0D
Unless netfilter has changed dramatically recentely, it is not usable f=
or=0D
applications. A monolithic system-wide configuration paradigm is not us=
able=0D
for applications, as they cannot know how not to step on another=0D
application's feet.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

