From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Mon, 09 Jun 2014 15:13:32 +0200
Message-ID: <5395B2FC.3070205@kau.se>
References: <539319F6.2090907@cogentembedded.com>	<1402151680-11434-1-git-send-email-per.hurtig@kau.se>	<1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>	<539413BA.7060903@kau.se> <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?QW5uYSBCcnVuc3Ryw7Zt?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.39]:41948 "EHLO nasse.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754752AbaFINVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 09:21:43 -0400
In-Reply-To: <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

See inline,

On 2014-06-09 09:02, Nandita Dukkipati wrote:
> On Sun, Jun 8, 2014 at 12:41 AM, Per Hurtig <per.hurtig@kau.se> wrote=
:
>>
>>
>> On s=C3=B6n  8 jun 2014 04:58:25, Eric Dumazet wrote:
>>>
>>> On Sat, 2014-06-07 at 16:34 +0200, Per Hurtig wrote:
>>>>
>>>> Fix to a problem observed when losing a FIN segment that does not
>>>> contain data.  In such situations, TLP is unable to recover from
>>>> *any* tail loss and instead adds at least PTO ms to the
>>>> retransmission process, i.e., RTO =3D RTO + PTO.
>>>>
>>>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>>>> ---
>>>>    net/ipv4/tcp_output.c | 6 ++++--
>>>>    1 file changed, 4 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>>>> index d463c35..6573765 100644
>>>> --- a/net/ipv4/tcp_output.c
>>>> +++ b/net/ipv4/tcp_output.c
>>>> @@ -2130,8 +2130,10 @@ void tcp_send_loss_probe(struct sock *sk)
>>>>          if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
>>>>                  goto rearm_timer;
>>>>
>>>> -       /* Probe with zero data doesn't trigger fast recovery. */
>>>> -       if (skb->len > 0)
>>>> +       /* Probe with zero data doesn't trigger fast recovery, if =
=46IN
>>>> +        * flag is not set.
>>>> +        */
>>>> +       if ((skb->len > 0) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR=
_FIN))
>>>>                  err =3D __tcp_retransmit_skb(sk, skb);
>>>>
>>>>          /* Record snd_nxt for loss detection. */
>>>
>>>
>>>
>>> You know, I believe the test was exactly to avoid sending data less=
 FIN
>>> packets.
>>>
>>> If you write :
>>>
>>>       if (A  || !A)
>>>
>>> Better remove the condition, completely ;)
>>>

After looking more closely, I see that we only enter this part when the=
=20
=46IN flag is set on an otherwise empty segment. I guess I was distract=
ed=20
by the comment that suggested a more general scenario than the actual=20
one, a bit confusing ;)

>> Obviously, but I don't think that FINs are the only segments
>> who are targeted by this condition (or targeted at all given
>> the implications of this statement). Furthermore, the comment above
>> the if statement would probably have mentioned FINs explicity
>> and not zero sized segments in general if this were the case.
>>
>>
>>
>>>
>>> Nandita, why FIN packet wont trigger fast retransnmits ?
>>>
>>
>> They do, that's the whole thing with this patch.
>>
>>
>>> It sounds like if the timer is the issue you want to fix, you might
>>> simply rearm a timer with RTO-PTO instead of RTO ?
>>>
>>>
>> No I want to enable TLP for tail loss where an empty FIN is involved=
,
>> this does not work now.
>
> I understand the tail loss case you want to solve - essentially when =
a
> tail loss occurs that involves data segments as well as that of an
> empty FIN. However, have you verified that re-sending an empty FIN
> triggers fast recovery? I would be surprised if it did, because I
> think the sender needs to receive a SACK of at least 1-byte of data
> before sender can trigger FACK based fast recovery.
>
Yes, it needs a SACK that covers one "sequence number", which a FIN
does. I don't see why it shouldn't generate a SACK? See below for some=20
packet dumps.

> If you have verified that a pure FIN does indeed trigger recovery, ca=
n
> you tell me what part of the code makes that happen?
>

Scenario:
Eleven segments are sent back-to-back (ten data and one empty FIN), the=
=20
last three segments (the FIN + two others) are dropped.

Other relevant info: RTT of 20ms.

Transfer time of the entire flow (from the receiver's point of view):
TCP w TLP: 324ms
TCP w modified TLP: 122ms


Detailed TLP behavior:
The entire transfer including retransmissions takes approx 324ms. The=20
retransmissions are conducted in frames 23 and 25.

Sender-side packet trace:
1   0.000000     10.0.1.1 -> 10.0.2.1     TCP 74 36713 > search-agent=20
[SYN] Seq=3D0 Win=3D29200 Len=3D0 MSS=3D1460 SACK_PERM=3D1 TSval=3D1171=
292524=20
TSecr=3D0 WS=3D128
2   0.000020     10.0.2.1 -> 10.0.1.1     TCP 74 search-agent > 36713=20
[SYN, ACK] Seq=3D0 Ack=3D1 Win=3D28960 Len=3D0 MSS=3D1460 SACK_PERM=3D1=
=20
TSval=3D1171296150 TSecr=3D1171292524 WS=3D128
3   0.019818     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[ACK] Seq=3D1 Ack=3D1 Win=3D29312 Len=3D0 TSval=3D1171292529 TSecr=3D11=
71296150
4   0.019854     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 36713=
=20
[PSH, ACK] Seq=3D1 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D1171296155=20
TSecr=3D1171292529[Packet size limited during capture]
5   0.019864     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 36713=
=20
[PSH, ACK] Seq=3D1449 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D1171296155=
=20
TSecr=3D1171292529[Packet size limited during capture]
6   0.019868     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 36713=
=20
[PSH, ACK] Seq=3D2897 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D1171296155=
=20
TSecr=3D1171292529[Packet size limited during capture]
7   0.019871     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 36713=
=20
[PSH, ACK] Seq=3D4345 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D1171296155=
=20
TSecr=3D1171292529[Packet size limited during capture]
8   0.019875     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 36713=
=20
[PSH, ACK] Seq=3D5793 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D1171296155=
=20
TSecr=3D1171292529[Packet size limited during capture]
9   0.019878     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 36713=
=20
[PSH, ACK] Seq=3D7241 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D1171296155=
=20
TSecr=3D1171292529[Packet size limited during capture]
10   0.019881     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 3671=
3=20
[PSH, ACK] Seq=3D8689 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D1171296155=
=20
TSecr=3D1171292529[Packet size limited during capture]
11   0.019922     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 3671=
3=20
[PSH, ACK] Seq=3D10137 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D117129615=
5=20
TSecr=3D1171292529[Packet size limited during capture]
12   0.019929     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 3671=
3=20
[PSH, ACK] Seq=3D11585 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D117129615=
5=20
TSecr=3D1171292529[Packet size limited during capture]
13   0.019930     10.0.2.1 -> 10.0.1.1     TCP 1513 search-agent > 3671=
3=20
[PSH, ACK] Seq=3D13033 Ack=3D1 Win=3D29056 Len=3D1447 TSval=3D117129615=
5=20
TSecr=3D1171292529[Packet size limited during capture]
14   0.019971     10.0.2.1 -> 10.0.1.1     TCP 66 search-agent > 36713=20
[FIN, ACK] Seq=3D14480 Ack=3D1 Win=3D29056 Len=3D0 TSval=3D1171296155 T=
Secr=3D1171292529
15   0.039635     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[ACK] Seq=3D1 Ack=3D1449 Win=3D32128 Len=3D0 TSval=3D1171292534 TSecr=3D=
1171296155
16   0.039643     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[ACK] Seq=3D1 Ack=3D2897 Win=3D35072 Len=3D0 TSval=3D1171292534 TSecr=3D=
1171296155
17   0.039646     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[ACK] Seq=3D1 Ack=3D4345 Win=3D37888 Len=3D0 TSval=3D1171292534 TSecr=3D=
1171296155
18   0.039650     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[ACK] Seq=3D1 Ack=3D5793 Win=3D40832 Len=3D0 TSval=3D1171292534 TSecr=3D=
1171296155
19   0.039653     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[ACK] Seq=3D1 Ack=3D7241 Win=3D43520 Len=3D0 TSval=3D1171292534 TSecr=3D=
1171296155
20   0.039655     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[ACK] Seq=3D1 Ack=3D8689 Win=3D43520 Len=3D0 TSval=3D1171292534 TSecr=3D=
1171296155
21   0.039657     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[ACK] Seq=3D1 Ack=3D10137 Win=3D43520 Len=3D0 TSval=3D1171292534 TSecr=3D=
1171296155
22   0.039660     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[ACK] Seq=3D1 Ack=3D11585 Win=3D43520 Len=3D0 TSval=3D1171292534 TSecr=3D=
1171296155
23   0.283780     10.0.2.1 -> 10.0.1.1     TCP 1514 [TCP Retransmission=
]=20
search-agent > 36713 [PSH, ACK] Seq=3D11585 Ack=3D1 Win=3D29056 Len=3D1=
448=20
TSval=3D1171296221 TSecr=3D1171292534[Packet size limited during captur=
e]
24   0.303267     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[ACK] Seq=3D1 Ack=3D13033 Win=3D43520 Len=3D0 TSval=3D1171292600 TSecr=3D=
1171296221
25   0.303276     10.0.2.1 -> 10.0.1.1     TCP 1513 [TCP Retransmission=
]=20
search-agent > 36713 [FIN, PSH, ACK] Seq=3D13033 Ack=3D1 Win=3D29056 Le=
n=3D1447=20
TSval=3D1171296225 TSecr=3D1171292600[Packet size limited during captur=
e]
26   0.324085     10.0.1.1 -> 10.0.2.1     TCP 66 36713 > search-agent=20
[FIN, ACK] Seq=3D1 Ack=3D14481 Win=3D43520 Len=3D0 TSval=3D1171292605 T=
Secr=3D1171296225
27   0.324093     10.0.2.1 -> 10.0.1.1     TCP 66 search-agent > 36713=20
[ACK] Seq=3D14481 Ack=3D2 Win=3D29056 Len=3D0 TSval=3D1171296231 TSecr=3D=
1171292605

----

Modified TLP behavior:
The entire transfer including retransmissions takes approx 122ms.

The TLP probe is sent in frame 23 below, and you can see in frame 24=20
below that a SACK covering one sequence number is returned from the=20
receiver and used to trigger retransmissions of the other lost segments=
=2E

Sender-side packet trace:
1   0.000000     10.0.1.1 -> 10.0.2.1     TCP 74 37730 > search-agent=20
[SYN] Seq=3D0 Win=3D29200 Len=3D0 MSS=3D1460 SACK_PERM=3D1 TSval=3D1194=
757582=20
TSecr=3D0 WS=3D128
2   0.000021     10.0.2.1 -> 10.0.1.1     TCP 74 search-agent > 37730=20
[SYN, ACK] Seq=3D0 Ack=3D1 Win=3D28960 Len=3D0 MSS=3D1460 SACK_PERM=3D1=
 TSval=3D222654=20
TSecr=3D1194757582 WS=3D128
3   0.020765     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D1 Win=3D29312 Len=3D0 TSval=3D1194757587 TSecr=3D22=
2654
4   0.020800     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 37730=
=20
[PSH, ACK] Seq=3D1 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D222659=20
TSecr=3D1194757587[Packet size limited during capture]
5   0.020810     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 37730=
=20
[PSH, ACK] Seq=3D1449 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D222659=20
TSecr=3D1194757587[Packet size limited during capture]
6   0.020814     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 37730=
=20
[PSH, ACK] Seq=3D2897 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D222659=20
TSecr=3D1194757587[Packet size limited during capture]
7   0.020818     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 37730=
=20
[PSH, ACK] Seq=3D4345 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D222659=20
TSecr=3D1194757587[Packet size limited during capture]
8   0.020821     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 37730=
=20
[PSH, ACK] Seq=3D5793 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D222659=20
TSecr=3D1194757587[Packet size limited during capture]
9   0.020824     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 37730=
=20
[PSH, ACK] Seq=3D7241 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D222659=20
TSecr=3D1194757587[Packet size limited during capture]
10   0.020827     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 3773=
0=20
[PSH, ACK] Seq=3D8689 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D222659=20
TSecr=3D1194757587[Packet size limited during capture]
11   0.020870     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 3773=
0=20
[PSH, ACK] Seq=3D10137 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D222659=20
TSecr=3D1194757587[Packet size limited during capture]
12   0.020877     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 3773=
0=20
[PSH, ACK] Seq=3D11585 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D222659=20
TSecr=3D1194757587[Packet size limited during capture]
13   0.020879     10.0.2.1 -> 10.0.1.1     TCP 1514 search-agent > 3773=
0=20
[PSH, ACK] Seq=3D13033 Ack=3D1 Win=3D29056 Len=3D1448 TSval=3D222659=20
TSecr=3D1194757587[Packet size limited during capture]
14   0.020918     10.0.2.1 -> 10.0.1.1     TCP 66 search-agent > 37730=20
[FIN, ACK] Seq=3D14481 Ack=3D1 Win=3D29056 Len=3D0 TSval=3D222659 TSecr=
=3D1194757587
15   0.040583     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D1449 Win=3D32128 Len=3D0 TSval=3D1194757593 TSecr=3D=
222659
16   0.040591     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D2897 Win=3D35072 Len=3D0 TSval=3D1194757593 TSecr=3D=
222659
17   0.040594     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D4345 Win=3D37888 Len=3D0 TSval=3D1194757593 TSecr=3D=
222659
18   0.040597     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D5793 Win=3D40832 Len=3D0 TSval=3D1194757593 TSecr=3D=
222659
19   0.040599     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D7241 Win=3D43520 Len=3D0 TSval=3D1194757593 TSecr=3D=
222659
20   0.040601     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D8689 Win=3D43520 Len=3D0 TSval=3D1194757593 TSecr=3D=
222659
21   0.040604     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D10137 Win=3D43520 Len=3D0 TSval=3D1194757593 TSecr=3D=
222659
22   0.040606     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D11585 Win=3D43520 Len=3D0 TSval=3D1194757593 TSecr=3D=
222659
23   0.078751     10.0.2.1 -> 10.0.1.1     TCP 66 [TCP Retransmission]=20
search-agent > 37730 [FIN, ACK] Seq=3D14481 Ack=3D1 Win=3D29056 Len=3D0=
=20
TSval=3D222674 TSecr=3D1194757593
24   0.098093     10.0.1.1 -> 10.0.2.1     TCP 78 [TCP Dup ACK 22#1]=20
37730 > search-agent [ACK] Seq=3D1 Ack=3D11585 Win=3D43520 Len=3D0=20
TSval=3D1194757607 TSecr=3D222659 SLE=3D14481 SRE=3D14482
25   0.102752     10.0.2.1 -> 10.0.1.1     TCP 1514 [TCP Retransmission=
]=20
search-agent > 37730 [PSH, ACK] Seq=3D11585 Ack=3D1 Win=3D29056 Len=3D1=
448=20
TSval=3D222680 TSecr=3D1194757607[Packet size limited during capture]
26   0.102757     10.0.2.1 -> 10.0.1.1     TCP 1514 [TCP Retransmission=
]=20
search-agent > 37730 [PSH, ACK] Seq=3D13033 Ack=3D1 Win=3D29056 Len=3D1=
448=20
TSval=3D222680 TSecr=3D1194757607[Packet size limited during capture]
27   0.121854     10.0.1.1 -> 10.0.2.1     TCP 78 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D13033 Win=3D43520 Len=3D0 TSval=3D1194757613 TSecr=3D=
222680=20
SLE=3D14481 SRE=3D14482
28   0.121862     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[ACK] Seq=3D1 Ack=3D14482 Win=3D43520 Len=3D0 TSval=3D1194757613 TSecr=3D=
222680
29   0.121868     10.0.1.1 -> 10.0.2.1     TCP 66 37730 > search-agent=20
[FIN, ACK] Seq=3D1 Ack=3D14482 Win=3D43520 Len=3D0 TSval=3D1194757613 T=
Secr=3D222680
30   0.121875     10.0.2.1 -> 10.0.1.1     TCP 66 search-agent > 37730=20
[ACK] Seq=3D14482 Ack=3D2 Win=3D29056 Len=3D0 TSval=3D222684 TSecr=3D11=
94757613

----

Thanks,
Per

> Nandita
>
