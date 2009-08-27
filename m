From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP keepalive timer problem
Date: Thu, 27 Aug 2009 14:45:02 +0200
Message-ID: <4A967FCE.3000807@gmail.com>
References: <0939B589FC103041945B9F13274963E303B1A9D4@CORPUSMX90A.corp.emc.com> <4A93E36C.8070502@gmail.com> <0939B589FC103041945B9F13274963E303B1AD89@CORPUSMX90A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Li_Xin2@emc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752536AbZH0MpG@vger.kernel.org>
In-Reply-To: <0939B589FC103041945B9F13274963E303B1AD89@CORPUSMX90A.corp.emc.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please dont top post on these lists, find my answers below

Li_Xin2@emc.com a =A8=A6crit :
> =20
> Thanks for your quick reply, let me explain my problem in detail.
>=20
> Suppose the client side of communication sets the keep alive socket o=
ption, connects to
> server, then > we pulls out the network cable of server box. After th=
e connection is idle for TCP_KEEPIDLE=20

seconds, the first keepalive probe packet is sent, and of course no rep=
ly is received.=20

Just after the first probe packet, the client sends some data. No respo=
nse is received, and=20

as you said, the normal retransmission takes place and no further keepa=
live probe will be sent.=20
>=20
> 	The problem is: application that tries the keepalive mechanism expec=
ts communication peer=20

crash detection within TCP_KEEPIDLE + TCP_KEEPCNT * TCP_KEEPINTVL secon=
ds. Application may set

 relative smaller TCP_KEEPIDLE, TCP_KEEPCNT and TCP_KEEPINTVL value so =
that peer crash can be

 detected quickly, for example, 60 seconds. But if the keepalive is int=
ervened with=20

retransmission, the latter takes higher priority, so that peer crash wi=
ll be detected after

 13 to 30 minutes, which may not be acceptable for some applications.
>=20
> We tried TCP implementation on Windows XP SP3, the keepalive and retr=
ansmission don't intervene.
>=20


> Regards,
> Xin Li
> EMC Shanghai R&D Centre
> Email: Li_Xin2@emc.com
> Tel: 86 21 6095 1100 x 2257
>=20
> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> Sent: 2009=C4=EA8=D4=C225=C8=D5 21:13
> To: Li, Xin
> Cc: linux-kernel@vger.kernel.org; Linux Netdev List
> Subject: Re: TCP keepalive timer problem
>=20
> Li_Xin2@emc.com a =A8=A6crit :
>> Greetings,
>>
>> I found one problem in Linux TCP keepalive timer processing, after
>> searching on google, I found Daniel Stempel reported the same proble=
m in
>> 2007 (http://lkml.indiana.edu/hypermail/linux/kernel/0702.2/1136.htm=
l),
>> but got no answer. So I have to reraise it.
>>
>> Can anyone help answer this two-years long question?
>>
>>
>=20
> You should explain your problem in detail, since Daniel one was proba=
bly different.
>=20
> He mentioned "(timeout is set to e.g. 30 seconds)" which is kind of n=
asty, given normal one is 7200
>=20
> If some packets are in flight, keepalive is not fired at all, since n=
ormal
> retransmits should take place (check tcp_retries2 sysctl).
>=20
> TCP Keepalive is only fired when no trafic occurred for a long time, =
only if=20
> SO_KEEPALIVE socket option was enabled by application.
>=20
> tcp_retries2 (integer; default: 15)
>     The maximum number of times a TCP packet is retransmitted in esta=
blished state
> before giving up. The default value is 15, which corresponds to a dur=
ation of
> approximately between 13 to 30 minutes, depending on the retransmissi=
on timeout.
> The RFC 1122 specified minimum limit of 100 seconds is typically deem=
ed too short.=20
>=20

RFC1122 , section 4.2.3.6 tells :

Keep-alive packets MUST only be sent when no data or acknowledgement pa=
ckets have
 been received for the connection within an interval. This interval MUS=
T be=20
configurable and MUST default to no less than two hours.=20

So :

Normal tcp_retries2 settings should make sure connection is reset if pa=
ckets in flight are not acknowledged way before TCP_KEEPIDLE (>=3D 7200=
 seconds)


Now, 7200 seconds might be inappropriate for special needs, and conside=
ring
there is no way to change tcp_retries2 for a given socket (only choice =
being the global
tcp_retries2 setting), I would vote for a change in our stack, to *rela=
x* RFC,
and get smaller keepalive timers if possible.

So when keepalive_timer fires, we should not care of outgoing packets,
only care on tp->rcv_tstamp, timestamp of last received ACK.


diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b144a26..719f198 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -484,18 +484,13 @@ static void tcp_keepalive_timer (unsigned long da=
ta)
 			}
 		}
 		tcp_send_active_reset(sk, GFP_ATOMIC);
-		goto death;
+		tcp_done(sk);
+		goto out;
 	}
=20
 	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state =3D=3D TCP_CLOSE)
 		goto out;
=20
-	elapsed =3D keepalive_time_when(tp);
-
-	/* It is alive without keepalive 8) */
-	if (tp->packets_out || tcp_send_head(sk))
-		goto resched;
-
 	elapsed =3D tcp_time_stamp - tp->rcv_tstamp;
=20
 	if (elapsed >=3D keepalive_time_when(tp)) {
@@ -522,13 +517,7 @@ static void tcp_keepalive_timer (unsigned long dat=
a)
 	TCP_CHECK_TIMER(sk);
 	sk_mem_reclaim(sk);
=20
-resched:
 	inet_csk_reset_keepalive_timer (sk, elapsed);
-	goto out;
-
-death:
-	tcp_done(sk);
-
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
