From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Thu, 12 Jun 2014 22:21:22 +0800
Message-ID: <5399B762.5090002@gmail.com>
References: <539319F6.2090907@cogentembedded.com>	<1402151680-11434-1-git-send-email-per.hurtig@kau.se>	<1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>	<539413BA.7060903@kau.se> <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?QW5uYSBCcnVuc3Ryw7Zt?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	sergei.shtylyov@cogentembedded.com
To: Nandita Dukkipati <nanditad@google.com>,
	Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:38604 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755910AbaFLOVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 10:21:48 -0400
Received: by mail-pb0-f44.google.com with SMTP id md12so213713pbc.3
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 07:21:48 -0700 (PDT)
In-Reply-To: <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 06/09/2014 03:02 PM, Nandita Dukkipati wrote:
> On Sun, Jun 8, 2014 at 12:41 AM, Per Hurtig <per.hurtig@kau.se> wrote=
:
>>
>> On s=C3=B6n  8 jun 2014 04:58:25, Eric Dumazet wrote:
>>> On Sat, 2014-06-07 at 16:34 +0200, Per Hurtig wrote:
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
>> Obviously, but I don't think that FINs are the only segments
>> who are targeted by this condition (or targeted at all given
>> the implications of this statement). Furthermore, the comment above
>> the if statement would probably have mentioned FINs explicity
>> and not zero sized segments in general if this were the case.
>>
>>
>>
>>> Nandita, why FIN packet wont trigger fast retransnmits ?
>>>
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
> I understand the tail loss case you want to solve - essentially when =
a
> tail loss occurs that involves data segments as well as that of an
> empty FIN. However, have you verified that re-sending an empty FIN
> triggers fast recovery? I would be surprised if it did, because I
> think the sender needs to receive a SACK of at least 1-byte of data
> before sender can trigger FACK based fast recovery.
When we queue an out of order pure FIN packet, we do not check whether=20
it has data or not.
tcp_rcv_established
-->tcp_data_queue
---->tcp_data_queue_ofo

Then the pure FIN packet can generate SACK, which will trigger fast=20
recovery or early retransmit on the sender.
>
> If you have verified that a pure FIN does indeed trigger recovery, ca=
n
> you tell me what part of the code makes that happen?
Here is the patch I use, I think the original if statement is useless,=20
so I delete it.

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 12d6016..4b301e9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2077,9 +2077,7 @@ void tcp_send_loss_probe(struct sock *sk)
         if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
                 goto rearm_timer;

-       /* Probe with zero data doesn't trigger fast recovery. */
-       if (skb->len > 0)
-               err =3D __tcp_retransmit_skb(sk, skb);
+       err =3D __tcp_retransmit_skb(sk, skb);

         /* Record snd_nxt for loss detection. */
         if (likely(!err))


I find that pure FIN can trigger fast recovery or early retransmit,=20
depending on the value of fackets_out.
I write two packetdrill scripts,
fin_fack.pkt can show that pure FIN can trigger fast recovery,
fin_er.pkt can show that pure FIN can trigger early retransmit.

# cat fin_fack.pkt
// Establish a connection.
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
0.000 bind(3, ..., ...) =3D 0
0.000 listen(3, 1) =3D 0

// RTT =3D 100ms
0.100 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 7>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) =3D 4

// Send 8 MSS.
// tcp_min_tso_segs is 2
0.200 write(4, ..., 8000) =3D 8000
+.000 > . 1:2001(2000) ack 1
+.000 > . 2001:4001(2000) ack 1
+.000 > . 4001:6001(2000) ack 1
+.000 > P. 6001:8001(2000) ack 1
+.000   close(4) =3D 0
+.000 > F. 8001:8001(0) ack 1

// Receiver ACKs 4 packets, the fifth to eighth packets are lost
0.300 < . 1:1(0) ack 4001 win 257

// PTO =3D 2RTT, TLP is triggered
0.500 > F. 8001:8001(0) ack 1 win 229
0.600 < . 1:1(0) ack 4001 win 257 <sack 8001:8002,nop,nop>

// got SACK, FACK triggers fast recovery and fast retransmit
0.600 > . 4001:5001(1000) ack 1 win 229
0.600 > . 5001:6001(1000) ack 1 win 229
0.700 < . 1:1(0) ack 6001 win 257 <sack 8001:8002,nop,nop>

// fast retransmit
0.700 > . 6001:7001(1000) ack 1 win 229
0.700 > P. 7001:8001(1000) ack 1 win 229
0.700 < . 1:1(0) ack 8002 win 257

// peer close
0.800 < F. 1:1(0) ack 8002 win 229
0.800 > . 8002:8002(0) ack 2


# cat fin_er.pkt
// Establish a connection.
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
0.000 bind(3, ..., ...) =3D 0
0.000 listen(3, 1) =3D 0

// RTT =3D 100ms
0.100 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 7>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) =3D 4

// Send 8 MSS.
// tcp_min_tso_segs is 2
0.200 write(4, ..., 8000) =3D 8000
+.000 > . 1:2001(2000) ack 1
+.000 > . 2001:4001(2000) ack 1
+.000 > . 4001:6001(2000) ack 1
+.000 > P. 6001:8001(2000) ack 1
+.000   close(4) =3D 0
+.000 > F. 8001:8001(0) ack 1

// Receiver ACKs 7 packets, the eighth packet is lost
0.300 < . 1:1(0) ack 7001 win 257

// PTO =3D 2RTT, TLP is triggered
0.500 > F. 8001:8001(0) ack 1 win 229
0.600 < . 1:1(0) ack 7001 win 257 <sack 8001:8002,nop,nop>

// got SACK, trigger early retransmit in RTT/4
0.625 > P. 7001:8001(1000) ack 1 win 229
0.725 < . 1:1(0) ack 8002 win 257

// peer close
0.800 < F. 1:1(0) ack 8002 win 229
0.800 > . 8002:8002(0) ack 2

Test results:
before the patch:

# ./packetdrill -v fin_fack.pkt
inbound injected packet:  0.100009 S 0:0(0) win 32792 <mss=20
1000,sackOK,nop,nop,nop,wscale 7>
outbound sniffed packet:  0.100182 S. 3040039935:3040039935(0) ack 1 wi=
n=20
29200 <mss 1460,nop,nop,sackOK,nop,wscale 7>
inbound injected packet:  0.200005 . 1:1(0) ack 3040039936 win 257
outbound sniffed packet:  0.200108 . 3040039936:3040041936(2000) ack 1=20
win 229
outbound sniffed packet:  0.200117 . 3040041936:3040043936(2000) ack 1=20
win 229
outbound sniffed packet:  0.200123 . 3040043936:3040045936(2000) ack 1=20
win 229
outbound sniffed packet:  0.200130 P. 3040045936:3040047936(2000) ack 1=
=20
win 229
outbound sniffed packet:  0.200328 F. 3040047936:3040047936(0) ack 1 wi=
n=20
229
inbound injected packet:  0.300004 . 1:1(0) ack 3040043936 win 257
outbound sniffed packet:  0.800768 . 3040043936:3040044936(1000) ack 1=20
win 229
fin_fack.pkt:27: error handling packet: live packet field=20
ipv4_total_length: expected: 40 (0x28) vs actual: 1040 (0x410)
script packet:  0.500000 F. 8001:8001(0) ack 1 win 229
actual packet:  0.800768 . 4001:5001(1000) ack 1 win 229

# ./packetdrill -v fin_er.pkt
inbound injected packet:  0.100009 S 0:0(0) win 32792 <mss=20
1000,sackOK,nop,nop,nop,wscale 7>
outbound sniffed packet:  0.100172 S. 1475097861:1475097861(0) ack 1 wi=
n=20
29200 <mss 1460,nop,nop,sackOK,nop,wscale 7>
inbound injected packet:  0.200005 . 1:1(0) ack 1475097862 win 257
outbound sniffed packet:  0.200113 . 1475097862:1475099862(2000) ack 1=20
win 229
outbound sniffed packet:  0.200121 . 1475099862:1475101862(2000) ack 1=20
win 229
outbound sniffed packet:  0.200128 . 1475101862:1475103862(2000) ack 1=20
win 229
outbound sniffed packet:  0.200134 P. 1475103862:1475105862(2000) ack 1=
=20
win 229
outbound sniffed packet:  0.200305 F. 1475105862:1475105862(0) ack 1 wi=
n=20
229
inbound injected packet:  0.300004 . 1:1(0) ack 1475104862 win 257
outbound sniffed packet:  0.800764 P. 1475104862:1475105862(1000) ack 1=
=20
win 229
fin_er.pkt:27: error handling packet: live packet field=20
ipv4_total_length: expected: 40 (0x28) vs actual: 1040 (0x410)
script packet:  0.500000 F. 8001:8001(0) ack 1 win 229
actual packet:  0.800764 P. 7001:8001(1000) ack 1 win 229

after the patch:
# ./packetdrill -v fin_fack.pkt
inbound injected packet:  0.100026 S 0:0(0) win 32792 <mss=20
1000,sackOK,nop,nop,nop,wscale 7>
outbound sniffed packet:  0.100198 S. 3395593992:3395593992(0) ack 1 wi=
n=20
29200 <mss 1460,nop,nop,sackOK,nop,wscale 7>
inbound injected packet:  0.200013 . 1:1(0) ack 3395593993 win 257
outbound sniffed packet:  0.200115 . 3395593993:3395595993(2000) ack 1=20
win 229
outbound sniffed packet:  0.200131 . 3395595993:3395597993(2000) ack 1=20
win 229
outbound sniffed packet:  0.200138 . 3395597993:3395599993(2000) ack 1=20
win 229
outbound sniffed packet:  0.200145 P. 3395599993:3395601993(2000) ack 1=
=20
win 229
outbound sniffed packet:  0.200345 F. 3395601993:3395601993(0) ack 1 wi=
n=20
229
inbound injected packet:  0.300016 . 1:1(0) ack 3395597993 win 257
outbound sniffed packet:  0.499792 F. 3395601993:3395601993(0) ack 1 wi=
n=20
229
inbound injected packet:  0.600024 . 1:1(0) ack 3395597993 win 257 <sac=
k=20
3395601993:3395601994,nop,nop>
outbound sniffed packet:  0.600074 . 3395597993:3395598993(1000) ack 1=20
win 229
outbound sniffed packet:  0.600080 . 3395598993:3395599993(1000) ack 1=20
win 229
inbound injected packet:  0.700016 . 1:1(0) ack 3395599993 win 257 <sac=
k=20
3395601993:3395601994,nop,nop>
outbound sniffed packet:  0.700062 . 3395599993:3395600993(1000) ack 1=20
win 229
outbound sniffed packet:  0.700066 P. 3395600993:3395601993(1000) ack 1=
=20
win 229
inbound injected packet:  0.700164 . 1:1(0) ack 3395601994 win 257
inbound injected packet:  0.800016 F. 1:1(0) ack 3395601994 win 229
outbound sniffed packet:  0.800062 . 3395601994:3395601994(0) ack 2 win=
 229

# ./packetdrill -v fin_er.pkt
inbound injected packet:  0.100009 S 0:0(0) win 32792 <mss=20
1000,sackOK,nop,nop,nop,wscale 7>
outbound sniffed packet:  0.100180 S. 3074568182:3074568182(0) ack 1 wi=
n=20
29200 <mss 1460,nop,nop,sackOK,nop,wscale 7>
inbound injected packet:  0.200005 . 1:1(0) ack 3074568183 win 257
outbound sniffed packet:  0.200106 . 3074568183:3074570183(2000) ack 1=20
win 229
outbound sniffed packet:  0.200115 . 3074570183:3074572183(2000) ack 1=20
win 229
outbound sniffed packet:  0.200122 . 3074572183:3074574183(2000) ack 1=20
win 229
outbound sniffed packet:  0.200128 P. 3074574183:3074576183(2000) ack 1=
=20
win 229
outbound sniffed packet:  0.200326 F. 3074576183:3074576183(0) ack 1 wi=
n=20
229
inbound injected packet:  0.300003 . 1:1(0) ack 3074575183 win 257
outbound sniffed packet:  0.499765 F. 3074576183:3074576183(0) ack 1 wi=
n=20
229
inbound injected packet:  0.600006 . 1:1(0) ack 3074575183 win 257 <sac=
k=20
3074576183:3074576184,nop,nop>
outbound sniffed packet:  0.624764 P. 3074575183:3074576183(1000) ack 1=
=20
win 229
inbound injected packet:  0.725004 . 1:1(0) ack 3074576184 win 257
inbound injected packet:  0.800003 F. 1:1(0) ack 3074576184 win 229
outbound sniffed packet:  0.800047 . 3074576184:3074576184(0) ack 2 win=
 229


thanks
Weiping Pan
>
> Nandita
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
