From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Sun, 12 Jun 2011 11:07:12 +0200
Message-ID: <1307869632.2872.106.camel@edumazet-laptop>
References: <20110611215919.5fc29c27@konijn>
	 <1307850224.22348.626.camel@localhost>  <20110612095131.6d924082@konijn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Joris van Rantwijk <joris@jorisvr.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40133 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463Ab1FLJHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 05:07:20 -0400
Received: by wya21 with SMTP id 21so2631297wya.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 02:07:18 -0700 (PDT)
In-Reply-To: <20110612095131.6d924082@konijn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 12 juin 2011 =C3=A0 09:51 +0200, Joris van Rantwijk a =C3=A9=
crit :
> On 2011-06-12, Ben Hutchings <bhutchings@solarflare.com> wrote:
> > LRO implementations (and GRO) are expected to put the actual segmen=
t
> > size in skb_shared_info(skb)->gso_size on the aggregated skb.  TCP
> > will then use that rather than the aggregated payload size when
> > deciding whether to defer an ACK.
>=20
> Thanks. I see that indeed gso_size is being used for MSS calculations
> instead of the total GRO size.
>=20
> However, I'm not sure that this completely answers my question.
> I am not so much concerned about quick ACK vs delayed ACK.
> Instead, I'm looking at the total number of ACKs transmitted.
> The sender depends on the _number_ of ACKs to update its congestion
> window.
>=20


> As far as I can see, current code will send just one ACK per coalesce=
d
> GRO bundle, while the sender expects one ACK per two segments.
>=20

One ACK carries an implicit ack for _all_ previous segments. If sender
only 'counts' ACKs, it is a bit dumb...


10:05:02.755146 IP 192.168.20.110.57736 > 192.168.20.108.53563: SWE 964=
44459:96444459(0) win 14600 <mss 1460,sackOK,timestamp 12174491=20
0,nop,wscale 8>
10:05:02.755242 IP 192.168.20.108.53563 > 192.168.20.110.57736: SE 1849=
523184:1849523184(0) ack 96444460 win 14480 <mss 1460,sackOK,tim
estamp 15334585 12174491,nop,wscale 7>
10:05:02.755310 IP 192.168.20.110.57736 > 192.168.20.108.53563: . ack 1=
 win 58 <nop,nop,timestamp 12174491 15334585>
10:05:02.755369 IP 192.168.20.110.57736 > 192.168.20.108.53563: . 1:144=
9(1448) ack 1 win 58 <nop,nop,timestamp 12174491 15334585>
10:05:02.755417 IP 192.168.20.108.53563 > 192.168.20.110.57736: . ack 1=
449 win 136 <nop,nop,timestamp 15334585 12174491>
10:05:02.755428 IP 192.168.20.110.57736 > 192.168.20.108.53563: P 1449:=
8689(7240) ack 1 win 58 <nop,nop,timestamp 12174491 15334585>
10:05:02.755476 IP 192.168.20.108.53563 > 192.168.20.110.57736: . ack 8=
689 win 159 <nop,nop,timestamp 15334585 12174491>
10:05:02.755482 IP 192.168.20.110.57736 > 192.168.20.108.53563: . 8689:=
13033(4344) ack 1 win 58 <nop,nop,timestamp 12174491 15334585>
10:05:02.755529 IP 192.168.20.108.53563 > 192.168.20.110.57736: . ack 1=
3033 win 181 <nop,nop,timestamp 15334585 12174491>
10:05:02.755535 IP 192.168.20.110.57736 > 192.168.20.108.53563: . 13033=
:14481(1448) ack 1 win 58 <nop,nop,timestamp 12174491 15334585>
10:05:02.755582 IP 192.168.20.108.53563 > 192.168.20.110.57736: . ack 1=
4481 win 204 <nop,nop,timestamp 15334585 12174491>
10:05:02.755588 IP 192.168.20.110.57736 > 192.168.20.108.53563: P 14481=
:16385(1904) ack 1 win 58 <nop,nop,timestamp 12174491 15334585>
10:05:02.755635 IP 192.168.20.108.53563 > 192.168.20.110.57736: . ack 1=
6385 win 227 <nop,nop,timestamp 15334585 12174491>
10:05:02.755641 IP 192.168.20.110.57736 > 192.168.20.108.53563: . 16385=
:23625(7240) ack 1 win 58 <nop,nop,timestamp 12174491 15334585>
10:05:02.755689 IP 192.168.20.108.53563 > 192.168.20.110.57736: . ack 2=
3625 win 249 <nop,nop,timestamp 15334585 12174491>
10:05:02.755695 IP 192.168.20.110.57736 > 192.168.20.108.53563: P 23625=
:26521(2896) ack 1 win 58 <nop,nop,timestamp 12174491 15334585>
10:05:02.755742 IP 192.168.20.108.53563 > 192.168.20.110.57736: . ack 2=
6521 win 272 <nop,nop,timestamp 15334585 12174491>
10:05:02.755750 IP 192.168.20.110.57736 > 192.168.20.108.53563: P 26521=
:33761(7240) ack 1 win 58 <nop,nop,timestamp 12174491 15334585>
10:05:02.755796 IP 192.168.20.108.53563 > 192.168.20.110.57736: . ack 3=
3761 win 295 <nop,nop,timestamp 15334585 12174491>
10:05:02.755802 IP 192.168.20.110.57736 > 192.168.20.108.53563: . 33761=
:39553(5792) ack 1 win 58 <nop,nop,timestamp 12174491 15334585>
10:05:02.755849 IP 192.168.20.108.53563 > 192.168.20.110.57736: . ack 3=
9553 win 259 <nop,nop,timestamp 15334585 12174491>



