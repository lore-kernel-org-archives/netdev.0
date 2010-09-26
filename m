From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 23:46:14 +0200
Message-ID: <20100926214614.GD12373@1wt.eu>
References: <20100926131717.GA13046@1wt.eu> <1285520567.2530.8.camel@edumazet-laptop> <20100926174014.GA12373@1wt.eu> <1285526115.2530.12.camel@edumazet-laptop> <20100926184914.GC12373@1wt.eu> <1285534871.2357.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:45698 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757639Ab0IZVqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Sep 2010 17:46:17 -0400
Content-Disposition: inline
In-Reply-To: <1285534871.2357.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 26, 2010 at 11:01:11PM +0200, Eric Dumazet wrote:
> Le dimanche 26 septembre 2010 =E0 20:49 +0200, Willy Tarreau a =E9cri=
t :
> > On Sun, Sep 26, 2010 at 08:35:15PM +0200, Eric Dumazet wrote:
> > > I was referring to this code. It works well for me.
> > >=20
> > > shutdown(fd, SHUT_RDWR);
> > > while (recv(fd, buff, sizeof(buff), 0) > 0)
> > > 	;
> > > close(fd);
> >=20
> > Ah this one yes, but it's overkill. We're actively pumping data fro=
m the
> > other side to drop it on the floor until it finally closes while we=
 only
> > need to know when it has ACKed the FIN. In practice, doing that on =
a POST
> > request which causes a 302 or 401 will result in the whole amount o=
f data
> > being transferred twice. Not only this is bad for the bandwidth, th=
is is
> > also bad for the user, as we're causing him to experience a complet=
e upload
> > twice, just to be sure it has received the FIN, while it's pretty o=
bvious
> > that it's not necessary in 99.9% of the cases.
> >=20
>=20
> I dont understand how recv() could transfert data twice.

That's not what I said, I said the client would have to retransfer. Her=
e's
what typically happens, for instance with an authentication requirement=
 :

Client                                Server
           SYN ----------->
               <----------- SYN/ACK
           ACK ----------->

POST /some_url HTTP/1.1
Host: xxx
Content-length: 10 meg
             ------ headers are sent ---->
xxxxxxxxxxxxx
xxxxxxxxxxxxx ----- data are being sent ->  HTTP/1.1 401 forbidden
xxxxxxxxxxxxx                               WWW-Authenticate: basic rea=
lm=3D"xxx"
=2E..                                         Connection: close
             <----------------------------
xxxxxxxxxxxxx
             <---------------------------- FIN
xxxxxxxxxxxxx
=2E..
10 megs of data being sent and drained by the server
xxxxxxxxxxxxx
             FIN --------------->
                 <--------------  ACK


second attempt with credentials this time

           SYN ----------->
               <----------- SYN/ACK
           ACK ----------->

POST /some_url HTTP/1.1
Host: x
authorization: basic xyz
Content-length: 10 meg
             ------ headers are sent ---->
xxxxxxxxxxxxx
xxxxxxxxxxxxx
xxxxxxxxxxxxx
etc...


So in this case the data is effectively transmitted twice. With an
RST once the client acks the FIN, the first transfer aborts very
early instead, saving half of the bandwidth.

> You only read from the socket receive queue to null buffer, and in mo=
st
> cases a single recv() call will be enough to drain the queue.

Indeed, in *most* cases, and just as right now in most cases there is n=
o
problem. As I said, that's the first reported issue in 10 years and hun=
dreds
of billions of connections cumulated on various sites. But instead of r=
eally
fixing the issue, it just reduces its occurrences. Also, it does only w=
ork
for low bandwidth clients (most common case too). That's what I'm going=
 to
implement anyway, but this is an unreliable workaround. All I know is t=
hat
it will probably divide by 10 the number of times this problem is encou=
ntered
but it will not fix it.

> > Since this method is the least efficient one and clearly not accept=
able
> > for practical cases, I wanted to dig at the root, where the informa=
tion
> > is known. And the TCP recv code is precisely the place where we kno=
w
> > exactly when it's safe to reset.
> >=20
>=20
> And its safe to reset exactly when application just does close(), if
> unread data was not drained. Not only its safe, but required. A new R=
=46C
> might be needed ?

I'm not requesting a new RFC, but I'm just trying to make a correct use
of orphans as implemented in the Linux stack, and I'm realizing that
since RFC2525 was implemented, orphans cannot be relied on at all anymo=
re.
We can simply delete all the orphans code and emit an RST immediately u=
pon
close(), there is no safe use of them now. And that's my concern. In my
opinion, the code is there and was written precisely for that usage. Si=
nce
I'm seeing that it can't be used for what it's designed for, I'm natura=
lly
interested in trying to get it usable again. And in fact, when I really
want an RST, I can already have one by disabling lingering before the
close(). This too shows that the default close() by default protects
orphaned data.

> > Also there's another issue in doing this. It requires polling of th=
e
> > receive side for all requests, which adds one epoll_ctl() syscall a=
nd
> > one recv() call, which have a much noticeable negative performance
> > impact at high rates (at 100000 connections per second, every sysca=
ll
> > counts). For now I could very well consider that I do this only for
> > POST requests, which currently are the ones exhibiting the issue th=
e
> > most, but since HTTP browsers will try to enable pipelining again
> > soon, the problem will generalize to all types of requests. Hence m=
y
> > attempts to do it the optimal way.
>=20
> This might be overkill but is a portable way of doing this, on all
> versions of linux.

I'm not discussing the portability at all. You see, right now, Linux is
by some margin the fastest platform to run haproxy, and the one I alway=
s
recommend for that. Some people experience good performance on FreeBSD
too, but the fine-grained control we have on Linux helps maintaining a
high level of performance by avoiding many unnecessary steps when we
can trust the OS to do some things correctly. Having workarounds for
some versions that we know don't work as expected is not an issue, and
it's even a good reason to sometimes make people upgrade. But having to
cut performance in half under Linux on some workloads because the user
land can't know something obvious that the OS knows is a bit of a waste=
=2E

> Sure, you could patch kernel to add a new system call
>=20
> close_proper(fd);

That would just be the normal close() (the one with lingering enabled)
in theory.

> As shutdown() only uses two bits, you can eventually add another bit =
to
> flush receive queue as well (to avoid the copy of it)

This is a good idea, but it will still leave some incorrectly handled
cases where the other side has the time to send a few packets between
the shutdown() and the close().

> Another question, is : why the server closes the socket, if you belie=
ve
> more pipelining is coming soon ?

There are quite a bunch of situations in HTTP where you have no other
solution than closing. All responses that don't advertise a length must
terminated by a close. Haproxy is a reverse-proxy, so it sits between
the client and the server. When a server sends such responses, haproxy
must forward the close to the client, regardless of what's in the reque=
st
buffer. Also, some response codes require a close. The 400 bad request
for instance, implies a mandatory close (as well as many 4xx or 5xx).
All redirects (301/302/303/307) should lead to a close if the target is
another site.

Eventhough we optimize for the most common cases, that doesn't save us
from having to support the legacy cases.

Regards,
Willy

