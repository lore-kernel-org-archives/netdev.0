From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: TCP IPv4 strange retransmits
Date: Wed, 05 Mar 2008 14:04:39 +0100
Message-ID: <47CE9A67.5010002@nets.rwth-aachen.de>
References: <47CD4808.1050202@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803041507001.5423@kivilampi-30.cs.helsinki.fi>
 <47CD5D43.9020408@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803042243050.15040@kivilampi-30.cs.helsinki.fi>
 <47CDD543.1090607@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803050819020.15712@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:46502 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758506AbYCEND1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 08:03:27 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.3.58])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0JX900373DLPU6D0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 05 Mar 2008 14:03:26 +0100 (CET)
In-reply-to: <Pine.LNX.4.64.0803050819020.15712@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Wed, 5 Mar 2008, Arnd Hannemann wrote:
>=20
>> Ilpo J=E4rvinen wrote:
>>
>>> No, if there's any skb which is more than fackets_out-tp->reorderin=
g from=20
>>> the highest SACKed skb, it will be marked TCPCB_LOST (see=20
>>> tcp_mark_head_lost & it's caller), and all LOST segments are retran=
smitted=20
>>> by the earlier loop (for a while still as I'm going to very likely =
change=20
>>> that in net-2.6.26, commits for consolidating both, nearly identica=
l loops=20
>>> are already in my local git and await some testing).
>>>
>>> Forwardretrans is only incremented when there isn't TCPCB_LOST set =
for a=20
>>> segment and it doesn't apply in this case anyway because you have n=
ew data=20
>>> to send (see the decision making for forward retransmits, it's well=
=20
>>> commented btw).
>> Ah, I see. Thank you for clarifying.
>> However fackets_out is not so well documented ;-)
>=20
> I think I've fixed this for 2.6.25... :-) :
>=20
> ...
> /* Heurestics to calculate number of duplicate ACKs. There's no dupAC=
Ks
>  * counter when SACK is enabled (without SACK, sacked_out is used for
>  * that purpose).
>  *
>  * Instead, with FACK TCP uses fackets_out that includes both SACKed
>  * segments up to the highest received SACK block so far and holes in
>  * between them.
>  *
>  * With reordering, holes may still be in flight, so RFC3517 recovery
>  * uses pure sacked_out (total number of SACKed segments) even though
>  * it violates the RFC that uses duplicate ACKs, often these are equa=
l
>  * but when e.g. out-of-window ACKs or packet duplication occurs,
>  * they differ. Since neither occurs due to loss, TCP should really
>  * ignore them.
>  */
> static inline int tcp_dupack_heurestics(struct tcp_sock *tp)
> ...

Great :-) But shouldn't it read "heuristics" ?

> ...Though some FACK comments seem to be saying something else still.
>=20
>> But it now makes all sense (with dump order):
>> An ACK 19225 arrives with SACK block {27745:29165}, so fackets_out b=
ecomes=20
>> ~6 ((27745-19225)/1450)
>> tp->reordering is 3 at this time so he starts to retransmit.
>> However some SACK ACK comes early enough so he stops at 4 retransmit=
s.
>> Or something like that...
>=20
> Another thing you should consider is reordering detection which hopef=
ully=20
> worked at 13:08:20.667529 through the newly discored SACK block which=
 is=20
> _lower_ than the highestmost SACK block received so far. That results=
 in=20
> FACK -> RFC3517, FACK is built on inorder assumptions and whenever we=
 find=20
> that untrue, e.g., due to SACK/ACK for non-rexmit when something larg=
er=20
> has been confirmed received we disable it. Ah, but this was 2.6.24.y?=
 It=20

Yes, it was 2.6.24.2. Actually you can see reordering detection at work=
 here[3],
the tool[4] we are using to measure TCP throughput samples the tcp_info=
 struct and the
column #reor should reflect tp->reordering.
=46irst it is 3 then it grows up to 16. Off course this is only a hint =
because
tcp_info is only sampled every 50ms in this example, but at least it sh=
ows that some
reordering detection took place...

> doesn't yet do RFC3517 IIRC, but has something remotely resembling=20
> newreno, but only for the first packet because the next cumulative AC=
K may=20
> often trigger timedout loop which basically marks everything lost (I =
don't=20
> remember if the latter was changed to occur only with FACK ages ago o=
r=20
> not).

Not sure if I understood this. Will have to look into this some more.

>=20
>>>> Tcpdump:
>> Sorry, this was just bogus. Just wanted to point out the timestamp=20
>> differences and made a wrong example. Screen full of numbers... ;-)
>=20
> I thought so :-).
>=20
> ...Large, nearly equal numbers in two dimensions, maybe at some day=20
> I wake up and notice I've read them too long noticing that capturing=20
> this kind of things is no longer a problem to me... :-/
>=20

[3] http://www.umic-mesh.net/~hannemann/strange-reorder/flowgrind.outpu=
t
[4] http://www.umic-mesh.net/research/tcp/flowgrind.html
