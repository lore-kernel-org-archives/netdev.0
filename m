From: =?ISO-8859-2?Q?Krzysztof_Ol=EAdzki?= <ole@ans.pl>
Subject: Re: Problem with tcp (2.6.31) as first, http://bugzilla.kernel.org/show_bug.cgi?id=14580
Date: Fri, 27 Nov 2009 12:43:12 +0100
Message-ID: <4B0FBB50.5080109@ans.pl>
References: <alpine.LNX.1.10.0911251626500.13662@bizon.gios.gov.pl> <4B0D83E8.3000009@gmail.com> <4B0D86BD.4010902@ans.pl> <4B0D8EC6.9050204@gmail.com> <4B0D8FB2.1060606@ans.pl> <4B0E1D1C.30000@gmail.com> <4B0E6D50.1020906@ans.pl> <4B0EAC4F.3080202@gmail.com> <alpine.LNX.1.10.0911261749100.16993@bizon.gios.gov.pl> <4B0EE958.7090607@gmail.com> <4B0EECE5.5050406@ans.pl> <4B0EEF76.1070803@gmail.com> <4B0EF273.4030003@gmail.com> <alpine.DEB.2.00.0911262327130.24189@melkinpaasi.cs.helsinki.fi> <4B0F0466.8080006@gmail.com> <alpine.LNX.1.10.0911271013330.24080@bizon.gios.gov.pl> <alpine.DEB.2.00.0911271246030.2459@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:38871 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbZK0MCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 07:02:34 -0500
In-Reply-To: <alpine.DEB.2.00.0911271246030.2459@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2009-11-27 12:04, Ilpo J=E4rvinen wrote:
> On Fri, 27 Nov 2009, Krzysztof Oledzki wrote:
>=20
>>
>> On Thu, 26 Nov 2009, Eric Dumazet wrote:
>>
>>> Ilpo J=E4rvinen a =E9crit :
>>>> On Thu, 26 Nov 2009, Eric Dumazet wrote:
>>>>
>>>>> Eric Dumazet a =E9crit :
>>>>>> Krzysztof Ol=EAdzki a =E9crit :
>>>>>>> On 2009-11-26 21:47, Eric Dumazet wrote:
>>>>>>>
>>>>>>>> About wscale being not sent, I suppose last kernel is fixed
>>>>>>> Thanks, I'll check it. But it is quite strange, that while reus=
ing
>>>>>>> the
>>>>>>> old connection, Linux uses wscale=3D=3D0.
>>>>>>>
>>>>>> It only 'reuse' sequence of previous connection to compute its I=
SN.
>>>>>>
>>>>>> Its a new socket, a new connection, with possibly different RCVB=
UF
>>>>>> settings -> different window.
>>>>>>
>>>>>> In my tests on net-next-2.6, I always have wscale set, but I am =
using
>>>>>> a program of my own,
>>>>>> not full NFS setup.
>>>>>>
>>>>>>
>>>>> Well, it seems NFS reuses its socket, so maybe we miss some clean=
ing
>>>>> as spotted in this old patch :
>>>> ...Nice, so we have this reuse of socket after all. ...It seems th=
at our
>>>> other bugs might have just been solved (wq purge can then cause st=
ale
>>>> hints if this reusing is indeed true).
>>>>
>>> Indeed, and we can do this in user space too :)
>>>
>>>
>>>        sockaddr.sin_family =3D AF_INET;
>>>        sockaddr.sin_port =3D htons(PORT);
>>>        sockaddr.sin_addr.s_addr =3D inet_addr("192.168.20.112");
>>>        res =3D connect(fd, (struct sockaddr *)&sockaddr, sizeof(soc=
kaddr));
>>> ...
>>>
>>> /*
>>> * following code calls tcp_disconnect()
>>> */
>>>        memset(&sockaddr, 0, sizeof(sockaddr));
>>>        sockaddr.sin_family =3D AF_UNSPEC;
>>>        connect(fd, (struct sockaddr *)&sockaddr, sizeof(sockaddr));
>>>
>>> /* reuse socket and reconnect on same target */
>>>        sockaddr.sin_family =3D AF_INET;
>>>        sockaddr.sin_port =3D htons(PORT);
>>>        sockaddr.sin_addr.s_addr =3D inet_addr("192.168.20.112");
>>>        res =3D connect(fd, (struct sockaddr *)&sockaddr, sizeof(soc=
kaddr));
>>>
>>>
>>> I reproduced the problem (of too small window, wscale =3D 0 instead=
 of 6)
>>>
>>>
>>>
>>> 23:14:53.608106 IP client.3434 > 192.168.20.112.333: S
>>> 392872616:392872616(0) win 5840 <mss 1460,nop,nop,timestamp 8251657=
8
>>> 0,nop,wscale 6>
>>> 23:14:53.608199 IP 192.168.20.112.333 > client.3434: S
>>> 2753948468:2753948468(0) ack 392872617 win 5792 <mss 1460,nop,nop,t=
imestamp
>>> 1660900486 82516578,nop,wscale 6>
>>> 23:14:53.608218 IP client.3434 > 192.168.20.112.333: . ack 1 win 92
>>> <nop,nop,timestamp 82516578 1660900486>
>>> 23:14:53.608232 IP client.3434 > 192.168.20.112.333: P 1:7(6) ack 1=
 win 92
>>> <nop,nop,timestamp 82516578 1660900486>
>>> 23:14:53.608320 IP 192.168.20.112.333 > client.3434: . ack 7 win 91
>>> <nop,nop,timestamp 1660900486 82516578>
>>> 23:14:53.608328 IP 192.168.20.112.333 > client.3434: P 1:7(6) ack 7=
 win 91
>>> <nop,nop,timestamp 1660900486 82516578>
>>> 23:14:53.608331 IP 192.168.20.112.333 > client.3434: F 7:7(0) ack 7=
 win 91
>>> <nop,nop,timestamp 1660900486 82516578>
>>> 23:14:53.608341 IP client.3434 > 192.168.20.112.333: . ack 7 win 92
>>> <nop,nop,timestamp 82516578 1660900486>
>>> 23:14:53.647202 IP client.3434 > 192.168.20.112.333: . ack 8 win 92
>>> <nop,nop,timestamp 82516618 1660900486>
>>> 23:14:56.614341 IP client.3434 > 192.168.20.112.333: F 7:7(0) ack 8=
 win 92
>>> <nop,nop,timestamp 82519584 1660900486>
>>> 23:14:56.614439 IP 192.168.20.112.333 > client.3434: . ack 8 win 91
>>> <nop,nop,timestamp 1660903493 82519584>
>>> 23:14:56.614461 IP client.3434 > 192.168.20.112.333: R
>>> 392872624:392872624(0) win 0
>>>
>>> <<HERE : win =3D 5840 wscale =3D 0>>
>>> 23:14:56.616260 IP client.3434 > 192.168.20.112.333: S
>>> 392878450:392878450(0) win 5840 <mss 1460,nop,nop,timestamp 8251958=
6
>>> 0,nop,wscale 0>
>>>
>>> 23:14:56.616352 IP 192.168.20.112.333 > client.3434: S
>>> 2800950724:2800950724(0) ack 392878451 win 5792 <mss 1460,nop,nop,t=
imestamp
>>> 1660903494 82519586,nop,wscale 6>
>>>
>>>
>>>
>>> Following patch solves this problem, but maybe we need a flag
>>> (a la sk->sk_userlocks |=3D SOCK_WINCLAMP_LOCK;)
>>> in case user set window_clamp.
>>> Or just document the clearing after a tcp disconnect ?
>>>
>>> [PATCH] tcp: tcp_disconnect() should clear window_clamp
>>>
>>> Or reuse of socket possibly selects a small window, wscale =3D 0 fo=
r next
>>> connection.
>>>
>>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>>> index 524f976..7d4648f 100644
>>> --- a/net/ipv4/tcp.c
>>> +++ b/net/ipv4/tcp.c
>>> @@ -2059,6 +2059,7 @@ int tcp_disconnect(struct sock *sk, int flags=
)
>>> 	tp->snd_ssthresh =3D TCP_INFINITE_SSTHRESH;
>>> 	tp->snd_cwnd_cnt =3D 0;
>>> 	tp->bytes_acked =3D 0;
>>> +	tp->window_clamp =3D 0;
>>> 	tcp_set_ca_state(sk, TCP_CA_Open);
>>> 	tcp_clear_retrans(tp);
>>> 	inet_csk_delack_init(sk);
>>>
>> Thanks!
>>
>> 10:07:31.429627 IP 192.168.152.205.44678 > 192.168.152.20.2049: Flag=
s [S], seq
>> 2012792102, win 5840, options [mss 1460,sackOK,TS val 4294877898 ecr
>> 0,nop,wscale 7], length 0
>> 10:07:31.429736 IP 192.168.152.20.2049 > 192.168.152.205.44678: Flag=
s [S.],
>> seq 1548680033, ack 2012792103, win 5792, options [mss 1460,sackOK,T=
S val
>> 68439846 ecr 4294877898,nop,wscale 7], length 0
>> (switching servers)
>> 10:08:05.186989 IP 192.168.152.20.2049 > 192.168.152.205.44678: Flag=
s [R], seq
>> 1548680550, win 0, length 0
>> 10:08:11.187117 IP 192.168.152.205.44678 > 192.168.152.20.2049: Flag=
s [S], seq
>> 2012804321, win 5840, options [mss 1460,sackOK,TS val 4294917656 ecr
>> 0,nop,wscale 7], length 0
>> 10:08:11.187276 IP 192.168.152.20.2049 > 192.168.152.205.44678: Flag=
s [S.],
>> seq 2176044714, ack 2012804322, win 5792, options [mss 1460,sackOK,T=
S val
>> 68482560 ecr 4294917656,nop,wscale 7], length 0
>>
>> This indeed fixes the problem with missing/zero wscale, however the =
original
>> problem (tcp loop flood) still remains. I wonder why the client is n=
ot able to
>> handle it, especially that seq numbers received from both servers ar=
e
>> distanced by much, much more than the current window size: 627364681=
 is much
>> larger than 5840 << 7 (747520).
>=20
> What would you expect to happen? If out-of-window stuff arrives we se=
nd=20
> dupacks. If we would send resets, that would introduce blind rst atta=
cks.
> In theory we might be able to quench the loop by using pingpong thing=
 but=20
> that needs very careful thought in order to not introduce other probl=
ems,
> and even then your connections will not be re-usable until either end=
=20
> times out so the gain is rather limited. We simply cannot rst the=20
> connection, that's not an option.

Right, the idea of sending RST is indeed stupid. But at risk of being=20
silly, why do we need to send anything in response to out-of-window=20
packets? Especially as we are doing it without ratelimiting, even for a=
=20
packet that contains no data, only pure ack. The current situation can=20
be easily abused for a hard to trace DoS - just send a lot of spoofed=20
packed to a port from established connection and such server will=20
response at the same rate, flooding the client.

> I find this problem simply stem from the introduced loss of end-to-en=
d=20
> connectivity. Would you really "lose" that server so that its TCP sta=
te is=20
> not maintained, you'd get resets etc (crash, scheduled reboot or=20
> whatever).

In brain-split situation, when your network is temporary segmented, two=
=20
redundant servers may take the same VIP simultaneously. When such=20
networks restores full functionality, one of the servers loses the IP.=20
It is how I have found this problem.

> Only real solution would be a kill switch for TCP connection=20
> when you break e-2-e connectivity (ie., switch servers so that the sa=
me IP=20
> is reacquired by somebody else). In theory you can "simulate" the kil=
l=20
> switch by setting tcp_retries sysctls to small values to make the=20
> connections to timeout much faster, but still that might not be enoug=
h for=20
> you (and has other implications you might not like).=20

Now I wonder - maybe we can simply kill ESTABLISHED connections=20
containing a addresses being removed?

>> But there is one more thing that still bugs me, please look at one o=
f my
>> previous dump:
>>
>> 17:39:48.339503 IP (tos 0x0, ttl 64, id 31305, offset 0, flags [DF],=
 proto TCP
>> (6), length 56)
>>      192.168.152.205.55329 > 192.168.152.20.2049: Flags [S], cksum 0=
x7d35
>> (correct), seq 3093379972, win 5840, options [mss 1460,sackOK,TS val=
 16845 ecr
>> 0], length 0
>>
>> 17:39:48.339588 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], pro=
to TCP
>> (6), length 56)
>>      192.168.152.20.2049 > 192.168.152.205.55329: Flags [S.], cksum =
0x7930
>> (correct), seq 4250661905, ack 3093379973, win 5792, options [mss
>> 1460,sackOK,TS val 9179690 ecr 16845], length 0
>>
>> OK, now we know that the client is buggy and sends small windows, bu=
t why the
>> response from the server also contains so small window?
>=20
> Perhaps I don't fully understand what you find here to be a problem..=
=2E=20
> Anyway, initially we start with small window and enlarge it while we =
keep=20
> going (receiver window auto-tuning).

Yes, Eric already explained it to me. I was just debating why we had=20
started with such small window here. Normally, with wscale enabled the=20
window is much higher, so without wscale it should be higher too, of=20
course with respect to the 16bit limit. But as windows can grow later,=20
it is not a problem.

Best regards,

				Krzysztof Ol=EAdzki
