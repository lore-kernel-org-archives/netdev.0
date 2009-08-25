From: <Li_Xin2@emc.com>
Subject: RE: TCP keepalive timer problem
Date: Tue, 25 Aug 2009 10:05:52 -0400
Message-ID: <0939B589FC103041945B9F13274963E303B1AD89@CORPUSMX90A.corp.emc.com>
References: <0939B589FC103041945B9F13274963E303B1A9D4@CORPUSMX90A.corp.emc.com> <4A93E36C.8070502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755029AbZHYOGK@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4A93E36C.8070502@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=20
Thanks for your quick reply, let me explain my problem in detail.

Suppose the client side of communication sets the keep alive socket opt=
ion, connects to server, then we pulls out the network cable of server =
box. After the connection is idle for TCP_KEEPIDLE seconds, the first k=
eepalive probe packet is sent, and of course no reply is received. Just=
 after the first probe packet, the client sends some data. No response =
is received, and as you said, the normal retransmission takes place and=
 no further keepalive probe will be sent.=20

	The problem is: application that tries the keepalive mechanism expects=
 communication peer crash detection within TCP_KEEPIDLE + TCP_KEEPCNT *=
 TCP_KEEPINTVL seconds. Application may set relative smaller TCP_KEEPID=
LE, TCP_KEEPCNT and TCP_KEEPINTVL value so that peer crash can be detec=
ted quickly, for example, 60 seconds. But if the keepalive is intervene=
d with retransmission, the latter takes higher priority, so that peer c=
rash will be detected after 13 to 30 minutes, which may not be acceptab=
le for some applications.

We tried TCP implementation on Windows XP SP3, the keepalive and retran=
smission don't intervene.

Regards,
Xin Li
EMC Shanghai R&D Centre
Email: Li_Xin2@emc.com
Tel: 86 21 6095 1100 x 2257

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
Sent: 2009=C4=EA8=D4=C225=C8=D5 21:13
To: Li, Xin
Cc: linux-kernel@vger.kernel.org; Linux Netdev List
Subject: Re: TCP keepalive timer problem

Li_Xin2@emc.com a =A8=A6crit :
> Greetings,
>=20
> I found one problem in Linux TCP keepalive timer processing, after
> searching on google, I found Daniel Stempel reported the same problem=
 in
> 2007 (http://lkml.indiana.edu/hypermail/linux/kernel/0702.2/1136.html=
),
> but got no answer. So I have to reraise it.
>=20
> Can anyone help answer this two-years long question?
>=20
>

You should explain your problem in detail, since Daniel one was probabl=
y different.

He mentioned "(timeout is set to e.g. 30 seconds)" which is kind of nas=
ty, given normal one is 7200

If some packets are in flight, keepalive is not fired at all, since nor=
mal
retransmits should take place (check tcp_retries2 sysctl).

TCP Keepalive is only fired when no trafic occurred for a long time, on=
ly if=20
SO_KEEPALIVE socket option was enabled by application.

tcp_retries2 (integer; default: 15)
    The maximum number of times a TCP packet is retransmitted in establ=
ished state
before giving up. The default value is 15, which corresponds to a durat=
ion of
approximately between 13 to 30 minutes, depending on the retransmission=
 timeout.
The RFC 1122 specified minimum limit of 100 seconds is typically deemed=
 too short.=20
