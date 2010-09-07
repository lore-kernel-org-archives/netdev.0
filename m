From: =?UTF-8?Q?=E3=83=84_Leandro_Melo_de_Sales?= <leandroal@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 7 Sep 2010 04:16:21 -0300
Message-ID: <AANLkTi=haxW2SVqes-7HYtQjSx052WUNNWV-BOaqQpHY@mail.gmail.com>
References: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>
 <20100906.221644.123986391.davem@davemloft.net> <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>
 <20100906.223010.173858342.davem@davemloft.net> <AANLkTi=x4+YqyuOvpnUXd2PjMHifMPXEgEA=0=+wfPk7@mail.gmail.com>
 <1283839769.2585.572.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Thiago Luiz <thiagolcpeixoto@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41905 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab0IGHQm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 03:16:42 -0400
Received: by fxm13 with SMTP id 13so2819874fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 00:16:41 -0700 (PDT)
In-Reply-To: <1283839769.2585.572.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 7, 2010 at 3:09 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 07 septembre 2010 =C3=A0 03:02 -0300, =E3=83=84 Leandro Melo=
 de Sales a
> =C3=A9crit :
>> >
>>
>> David,
>> =C2=A0 =C2=A0Yes, 78 bytes is the size of each command. I have concl=
uded the
>> same as you. In this case, to deal with this type of situation, how
>> about changing TCP implementation on Linux to send the whole packet
>> when it is too small such in this case or when TCP notice that there
>> is no change in the advertised rcwd or when advertised win is equal =
to
>> advertised MSS, since the receiver is saying "I can receive packets =
in
>> the same size of my cwd"?
>>
>> =C2=A0 I'm sorry if I'm suggesting something that does not make sens=
e, but
>> since receiver advertises that are able to receive packets in that
>> size which is equal to the congwin size, splitting the packet in thi=
s
>> case only [unnecessarily] increased the flow completion time or avoi=
d
>> data to be delivered to the application as soon as possible since it
>> arrived splitted. As we could notice from the tcpdump report, TCP
>> implementation under Linux does not wait for any ACK of the first 48
>> bytes sent out, it just sent the other 30 bytes in a consecutive
>> delivery, which is the same as sending 78 bytes at once, since no
>> decision is taken to send or not the other last 30 bytes.
>>
>> =C2=A0 =C2=A0Regardless this discussion, can you at least suggest an=
y workaround
>> that I can do in the application layer to make TCP send the whole
>> packet at once? As I said, I tried to use TCP_CORK suggested by
>> Arnaldo (acme), but it does not work for me in this case.
>>
>
> Is it a critical problem for you ?
>
> If you give us at least some minutes or hours or even days to think
> about this corner case, I am sure we can find a solution :)
>
> They are two factors here : MSS=3D78 and WIN=3D78
>
> Thanks

My short answer is: this is not a critical problem for me, at all. I
just thought that this could be easily fixed by finding the source of
the problem, as David and I shared it is due to small and fixed cwd
advertised by the receiver.

But...  This just make me think about why it works under windows, but
not under linux. When I begin to think about the relation between Win
and MSS, in my point of view it is feasible to think like I said: if
the receiver is telling me that it is able to receive a packet that is
in the same size of the cwd and cwd is sufficiently small in respect
to congestion control mechanism and MTU size, why postpone the flow
completion time if I can do this at once, ... avoid make two
consecutive TCP-PSH without any sending decision between them? For our
discussion MSS =3D=3D Win, while they are very small if compared to MTU=
,
almost 20 times, at least in ethernet. I know that "very", "small",
"big", "tall", "short" etc are very vague works, and everything will
depend on the point of view, but maybe we can consider Win a very
small size (at lease when it is equal to MSS) when TCP is in the Slow
Start phase until ssthresh, don't know...

    From one perspective I agree with David that the receiver device
of my case provided a kind of foolish and/or baroque implementation,
but in another perspective they where very smart to announce MSS =3D=3D
cwd, this way they avoiding sender to send more than it (receiver) can
handle, does not use too much resource since it does not increase the
cwd, in addition to telling to the sender: "send me your complete
'sk_write_queue' at once (talking about Linux TCP implementation)".
But Linux did not, instead it sent two consecutive packets without any
decision taken between them, why? In this case, how much resource we
spend when we allocate a new packet and add it in the double-linked
queue? how much computation we wasting when we have to process one
more packet (in this case for each tcp.send())? Well, if this is not
the case here or if wasting resources is computational cheaper than
make some checks and send the packet at once, let's try another
approach...

   Well, I don't know if what I mentioned above are real arguments to
promote a change in the TCP implementation, just want to solve my
problem, at the same time I have decided to share with you guys my
problem, since maybe it can be a problem faced by someone else when
using Linux, or already occurred in the past.

   Finally, one other (at least for my project) consideration is that
I wouldn't like to deploy my application only under windows (since
there my app works) and tell to my customer: well, we have done a
multi-platform solution, but due to **this** issue we won't be able to
deploy the system under linux because it simply does not work (at
least considering all tests using alternatives and workaround that I
have mentioned in my previous e-mail).

Leandro.
