From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 22:00:53 +0200
Message-ID: <1285617653.2512.67.camel@edumazet-laptop>
References: <20100926232530.GK12373@1wt.eu>
	 <20100926.181202.28824153.davem@davemloft.net>
	 <20100927053901.GL12373@1wt.eu>
	 <20100926.234202.241938788.davem@davemloft.net>
	 <20100927073443.GR12373@1wt.eu>
	 <alpine.LFD.2.00.1009271159070.2191@u.domain.uli>
	 <20100927192450.GU12373@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65067 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760139Ab0I0UBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 16:01:05 -0400
Received: by wyb28 with SMTP id 28so4256152wyb.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 13:01:04 -0700 (PDT)
In-Reply-To: <20100927192450.GU12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 27 septembre 2010 =C3=A0 21:24 +0200, Willy Tarreau a =C3=A9cr=
it :
> Hi Julian
>=20
> [removed Davem from the CC upon his request, not to pollute him]
>=20
> On Mon, Sep 27, 2010 at 12:12:24PM +0300, Julian Anastasov wrote:
> > 	If it is not already mentioned, the application can
> > know if sent data is acked. I think, ioctl SIOCOUTQ is for
> > this purpose. May be the application that wants to send
> > reliably HTTP error response before closing should do something
> > like:
> >=20
> > - add this FD in some list for monitoring instead of keeping
> > large connection state
> > - use shutdown SHUT_WR to add FIN after response
> > - use setsockopt SO_RCVBUF with some low value to close the
> > RX window, we do not want the body
> > - wait for POLLHUP (FIN), not for POLLIN because we want to
> > ignore data, not to read it. Still, data can be read and
> > dropped if needed to release the socket memory
> > - use timer to limit the time we wait our data to be acked
> > - use SIOCOUTQ to know if everything is received in peer and
> > then close the fd
>=20
> Thanks very much for this suggestion. I was looking for something
> like this and even looked at the tcp_info struct, but it did not
> look very easy to use.
>=20
> Still, I think that polling on POLLIN and checking with SIOCOUTQ
> on every read to see if the out queue is now empty would do the
> trick, without forcing to read huge amounts of unnecessary data.
>=20
> I'll simply enclose that inside a #ifdef LINUX and that should be
> OK. It kinda sucks to be able to workaround low level issues at the
> application level but at least this workaround is acceptable.

Just a point :

RFC1122 :

	A host MAY implement a "half-duplex" TCP close sequence, so
        that an application that has called CLOSE cannot continue to
        read data from the connection.  If such a host issues a
        CLOSE call while received data is still pending in TCP, or
        if new data is received after CLOSE is called, its TCP
        SHOULD send a RST to show that data was lost.


Maybe only linux respects the RFC ? ;)



