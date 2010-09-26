From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Sun, 26 Sep 2010 20:35:15 +0200
Message-ID: <1285526115.2530.12.camel@edumazet-laptop>
References: <20100926131717.GA13046@1wt.eu>
	 <1285520567.2530.8.camel@edumazet-laptop>  <20100926174014.GA12373@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38159 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027Ab0IZSf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 14:35:26 -0400
Received: by wyb28 with SMTP id 28so3260053wyb.19
        for <netdev@vger.kernel.org>; Sun, 26 Sep 2010 11:35:24 -0700 (PDT)
In-Reply-To: <20100926174014.GA12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 26 septembre 2010 =C3=A0 19:40 +0200, Willy Tarreau a =C3=A9=
crit :
> Hi Eric,
>=20
> On Sun, Sep 26, 2010 at 07:02:47PM +0200, Eric Dumazet wrote:
> > How could we delay the close() ? We must either send a FIN or RST.
>=20
> I don't mean to delay the close(), but I'm aware that my description
> was not very clear.
>=20
> Here's what I would find normal :
>=20
> 1) upon close(), we send a FIN, whether there are incoming pending
>    data or not (after all, the only difference is only a timing
>    issue, as the data in the rx buffer might very well come just
>    after the FIN, as it almost always does, BTW). The connection
>    then becomes FIN_WAIT1 just as now.
>=20
> 2) mark the socket as orphaned
>=20
> 3) when an ACK comes from the other side, either it's below our last
>    seq, and we simply ignore it, just as if we were in TIME_WAIT, or
>    it is equal to the last seq and indicates that it's now safe to
>    reset ; we would then just send the RST to notify the other side
>    that the data it sent were not read. The connection can then eithe=
r
>    be destroyed or put in TIME_WAIT. It's the point where the connect=
ion
>    normally switches from FIN_WAIT1 to FIN_WAIT2, since the FIN has b=
een
>    acked. The only difference is that we don't need a FIN_WAIT2 state
>    for an orphan.
>=20
> > I would say, fix the program, so that RST is avoided ?
>=20
> Not that easy, see below.
>=20
> > The program does :
> >=20
> > recv() // read the request
> > send() // queue the answer
> > close() // could work if world was perfect...
> >=20
> > Change it to
> >=20
> > recv()
> > send()
> > shutdown()
> > recv() // read & flush in excess data
>=20
> New data arrives now, close() below will cause an RST again.
>=20
> > close()
> >=20
> > This for sure will send FIN after all queued data is sent.
> > I am not sure the final rcv() is even needed, its Sunday after all =
;)
>=20
> Currently the real code (ie: not the poc I posted) does :
>=20
>    recv()
>    send()
>    shutdown()
>    close()
>=20
> The extra CRLF almost always happens between the recv() and send(). W=
hat
> I intend to do as a workaround is exactly what you described above, b=
ut
> I'm well aware it's not enough. It will only reduce the rate at which=
 this
> case happens. Well, in fact, in 10 years of production at many sites,=
 it's
> the first time such an issue is reported and it could be tracked down=
 to
> these two extra bytes. But the workaround will not prevent the two ex=
tra
> bytes from coming after the last recv().
>=20
> Also, the issue remains when processing large POST requests. Let's su=
ppose
> the application is receiving a massive POST (eg: 10 MB) but the reque=
st is
> not authenticated, so the application returns an HTTP 401 response to
> require the client to authenticate. There's no way for the applicatio=
n to
> be notified that the small response was completely read by the client=
 and
> that it's safe to close().
>=20
> For these reasons, I concluded that the application can't get everyth=
ing
> right and needs help from the kernel (said differently, I think that =
the
> RFC2525 fix is causing harm in addition to goods). In my opinion, thi=
s
> section in the RFC was added based on a few observations of trivial c=
ases
> but was but its impact was not completely explored.
>=20
> I'm willing to experiment, but I'm not much familiar with the code it=
self
> and sometimes I'm not sure about what I'm doing, probably that some h=
elp
> would be welcome. What I'd like to do is to implement the step 3 abov=
e,
> which is to only send the RST upon receipt of an ACK on an orphan tha=
t
> would switch a normal socket from FIN_WAIT1 to FIN_WAIT2.
>=20
> Also, I'm not sure about what other OSes are doing. For instance, I t=
ried
> on Solaris and did not observe the issue at all, though I think that
> Solaris simply does not implement the RFC2525 recommendation.
>=20
> Have a nice sunday evening ;-)
> Willy
>=20

I was referring to this code. It works well for me.

shutdown(fd, SHUT_RDWR);
while (recv(fd, buff, sizeof(buff), 0) > 0)
	;
close(fd);



