From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Connect hangs for a while before returns -1 with ECONNREFUSED
 on 3.2 for loopback
Date: Fri, 03 Feb 2012 15:38:14 +0100
Message-ID: <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F2B7DF1.5050303@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:51851 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756638Ab2BCOiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 09:38:20 -0500
Received: by werb13 with SMTP id b13so2738616wer.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 06:38:18 -0800 (PST)
In-Reply-To: <4F2B7DF1.5050303@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 10:25 +0400, Yurij M. Plotnikov=
 a =C3=A9crit :
> On kernel 3.2.0-0.bpo.1-amd64 I see some strange behaviour of connect=
()=20
> in case of connection via loopback. Lets see the following steps (the=
re=20
> are two processes on the host, and the first one with two threads)
>=20
> Thread1:
> 1. socket(PF_INET, SOCK_STREAM, 0) ->  3
> 2. bind(10.27.10.1:26820) ->  0 /* The address is bound to some inter=
face, eth1 */
> 3. listen(3, 1) ->  0
>=20
> sleep for a while
>=20
> Thread2:
> 4. shutdown(3, SHUT_RD) ->  0
>=20
> sleep for a while
>=20
> Another process:
> 5. socket(PF_INET, SOCK_STREAM, 0) ->  4
> 6. connect(4, 10.27.10.1:26820)
>=20
> connect() returns -1 with ECONNREFUSED but after some time. In case o=
f=20
> two peer hosts connect() returns -1 with ECONNREFUSED almost=20
> immediately, so does for the other kernel versions.
>=20
> In attachment c program to reproduce this problem.

Thanks for the report !

It seems related to IP route management.

Only the first attempt is not OK, and only using an IP different than
127.0.0.1

=46irst attempt :

15:06:02.270278 IP 192.168.20.110.46885 > 192.168.20.110.12346: SWE
1383808520:1383808520(0) win 32792 <mss 16396,sackOK,timestamp 16771896=
3
0,nop,wscale 8>
15:06:03.270877 IP 192.168.20.110.46885 > 192.168.20.110.12346: SWE
1383808520:1383808520(0) win 32792 <mss 16396,sackOK,timestamp 16771996=
4
0,nop,wscale 8>
15:06:05.274875 IP 192.168.20.110.46885 > 192.168.20.110.12346: SWE
1383808520:1383808520(0) win 32792 <mss 16396,sackOK,timestamp 16772196=
8
0,nop,wscale 8>
15:06:09.282875 IP 192.168.20.110.46885 > 192.168.20.110.12346: SWE
1383808520:1383808520(0) win 32792 <mss 16396,sackOK,timestamp 16772597=
6
0,nop,wscale 8>
15:06:17.290878 IP 192.168.20.110.46885 > 192.168.20.110.12346: SWE
1383808520:1383808520(0) win 32792 <mss 16396,sackOK,timestamp 16773398=
4
0,nop,wscale 8>
15:06:17.290883 IP 192.168.20.110.12346 > 192.168.20.110.46885: R 0:0(0=
)
ack 1383808521 win 0


2nd attempt (and following) : it works (RST packet immediately answered=
)

15:06:23.647940 IP 192.168.20.110.46886 > 192.168.20.110.12346: SWE
1784465174:1784465174(0) win 32792 <mss 16396,sackOK,timestamp 16774034=
1
0,nop,wscale 8>
15:06:23.647945 IP 192.168.20.110.12346 > 192.168.20.110.46886: R 0:0(0=
)
ack 1784465175 win 0


If we flush ip route cache "ip ro flush cache", it blocks again.

No hint given in "netstat -s"

Hmmm...
