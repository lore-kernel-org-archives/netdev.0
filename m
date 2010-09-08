From: =?UTF-8?Q?=E3=83=84_Leandro_Melo_de_Sales?= <leandroal@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Wed, 8 Sep 2010 11:01:50 -0300
Message-ID: <AANLkTingzC1FU-uDVygmFth=qz7yN7mKHcqTt9w_wk4j@mail.gmail.com>
References: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>
 <20100906.221644.123986391.davem@davemloft.net> <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
 <20100906.223010.173858342.davem@davemloft.net> <AANLkTi=x4+YqyuOvpnUXd2PjMHifMPXEgEA=0=+wfPk7@mail.gmail.com>
 <1283839769.2585.572.camel@edumazet-laptop> <AANLkTi=haxW2SVqes-7HYtQjSx052WUNNWV-BOaqQpHY@mail.gmail.com>
 <1283844761.2338.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Thiago Luiz <thiagolcpeixoto@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:58500 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab0IHOCL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 10:02:11 -0400
Received: by gxk23 with SMTP id 23so32080gxk.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 07:02:11 -0700 (PDT)
In-Reply-To: <1283844761.2338.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 7, 2010 at 4:32 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
>
> Le mardi 07 septembre 2010 =C3=A0 04:16 -0300, =E3=83=84 Leandro Melo=
 de Sales a
> =C3=A9crit :
>
> > My short answer is: this is not a critical problem for me, at all. =
I
> > just thought that this could be easily fixed by finding the source =
of
> > the problem, as David and I shared it is due to small and fixed cwd
> > advertised by the receiver.
> >
> > But... =C2=A0This just make me think about why it works under windo=
ws, but
> > not under linux. When I begin to think about the relation between W=
in
> > and MSS, in my point of view it is feasible to think like I said: i=
f
> > the receiver is telling me that it is able to receive a packet that=
 is
> > in the same size of the cwd and cwd is sufficiently small in respec=
t
> > to congestion control mechanism and MTU size, why postpone the flow
> > completion time if I can do this at once, ... avoid make two
> > consecutive TCP-PSH without any sending decision between them? For =
our
> > discussion MSS =3D=3D Win, while they are very small if compared to=
 MTU,
> > almost 20 times, at least in ethernet. I know that "very", "small",
> > "big", "tall", "short" etc are very vague works, and everything wil=
l
> > depend on the point of view, but maybe we can consider Win a very
> > small size (at lease when it is equal to MSS) when TCP is in the Sl=
ow
> > Start phase until ssthresh, don't know...
> >
> > =C2=A0 =C2=A0 From one perspective I agree with David that the rece=
iver device
> > of my case provided a kind of foolish and/or baroque implementation=
,
> > but in another perspective they where very smart to announce MSS =3D=
=3D
> > cwd, this way they avoiding sender to send more than it (receiver) =
can
> > handle, does not use too much resource since it does not increase t=
he
> > cwd, in addition to telling to the sender: "send me your complete
> > 'sk_write_queue' at once (talking about Linux TCP implementation)".
> > But Linux did not, instead it sent two consecutive packets without =
any
> > decision taken between them, why? In this case, how much resource w=
e
> > spend when we allocate a new packet and add it in the double-linked
> > queue? how much computation we wasting when we have to process one
> > more packet (in this case for each tcp.send())? Well, if this is no=
t
> > the case here or if wasting resources is computational cheaper than
> > make some checks and send the packet at once, let's try another
> > approach...
> >
> > =C2=A0 =C2=A0Well, I don't know if what I mentioned above are real =
arguments to
> > promote a change in the TCP implementation, just want to solve my
> > problem, at the same time I have decided to share with you guys my
> > problem, since maybe it can be a problem faced by someone else when
> > using Linux, or already occurred in the past.
> >
> > =C2=A0 =C2=A0Finally, one other (at least for my project) considera=
tion is that
> > I wouldn't like to deploy my application only under windows (since
> > there my app works) and tell to my customer: well, we have done a
> > multi-platform solution, but due to **this** issue we won't be able=
 to
> > deploy the system under linux because it simply does not work (at
> > least considering all tests using alternatives and workaround that =
I
> > have mentioned in my previous e-mail).
>
>
> Really this has nothing to do with congestion.
>
> We send _one_ packet, and this packet has not the optimum size.
>
> This can be fixed, with a 100% probability :)
>
> Quite frankly, if your application depends on _one_ packet being sent
> instead of two, you can do even better under linux, avoiding the thir=
d
> packet (pure ACK) of the tcp session :=3D)
>
> 192.168.0.34 =C2=A0 =C2=A0192.168.0.70 =C2=A0 =C2=A0[SYN] Seq=3D0 Win=
=3D5840 Len=3D0 MSS=3D1460
> 192.168.0.70 =C2=A0 =C2=A0192.168.0.34 =C2=A0 =C2=A0[SYN, ACK] Seq=3D=
0 Ack=3D1 Win=3D78 Len=3D0 MSS=3D78
> 192.168.0.34 =C2=A0 =C2=A0192.168.0.70 =C2=A0 =C2=A0[PSH, ACK] Seq=3D=
1 Ack=3D1 Win=3D5840 Len=3D78
>
> Nice isnt it ?
>
> BTW, what is the version of linux kernel you use ?
>
>
>

Very nice... piggybacking... ;) But this is not the case, I need to
send more packets, it is not just one...

Kernel version: 2.6.32, but I have run this in the later versions too..=
=2E

Leandro.
