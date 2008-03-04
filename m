From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: TCP IPv4 strange retransmits
Date: Wed, 05 Mar 2008 00:03:31 +0100
Message-ID: <47CDD543.1090607@nets.rwth-aachen.de>
References: <47CD4808.1050202@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803041507001.5423@kivilampi-30.cs.helsinki.fi>
 <47CD5D43.9020408@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803042243050.15040@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:43444 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934107AbYCDXCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:02:24 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.3.58])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0JX8007HNANY9M80@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 05 Mar 2008 00:02:22 +0100 (CET)
In-reply-to: <Pine.LNX.4.64.0803042243050.15040@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Tue, 4 Mar 2008, Arnd Hannemann wrote:
>=20
>> Hi,
>>
>> Ilpo J=E4rvinen wrote:
>>> On Tue, 4 Mar 2008, Arnd Hannemann wrote:
>>>
>>>> I'm observing some retransmits with kernel 2.6.24.2, which I don't=
=20
>>>> understand. For instance in this cutout[1] of a sequence diagram w=
hich=20
>>>> was captured[2] on the TCP sender, 4 retransmits are made.
>>> They don't correspond to each other?
>> Hmm, they should.
>=20
> Yeah, they probably do, I was just too hasty and failed to notice tho=
se=20
> small negative offsets.
>=20
>>>> According to netstat -st output[3][4] all those 4 retransmits were=
 "fast=20
>>>> retransmit".
>>>> But there are no three DUPACKs which I expected would be needed fo=
r fast=20
>>>> retransmit?
>>> With FACK it's enough that you have fackets_out > tp->reordering=20
>>> (=3DdupThresh).
>> If it is FACK shouldn't it be accounted for LINUX_MIB_TCPFORWARDRETR=
ANS
>> instead of LINUX_MIB_TCPFASTRETRANS?
>=20
> No, if there's any skb which is more than fackets_out-tp->reordering =
from=20
> the highest SACKed skb, it will be marked TCPCB_LOST (see=20
> tcp_mark_head_lost & it's caller), and all LOST segments are retransm=
itted=20
> by the earlier loop (for a while still as I'm going to very likely ch=
ange=20
> that in net-2.6.26, commits for consolidating both, nearly identical =
loops=20
> are already in my local git and await some testing).
>=20
> Forwardretrans is only incremented when there isn't TCPCB_LOST set fo=
r a=20
> segment and it doesn't apply in this case anyway because you have new=
 data=20
> to send (see the decision making for forward retransmits, it's well=20
> commented btw).

Ah, I see. Thank you for clarifying.
However fackets_out is not so well documented ;-)
But it now makes all sense (with dump order):
An ACK 19225 arrives with SACK block {27745:29165}, so fackets_out beco=
mes ~6 ((27745-19225)/1450)
tp->reordering is 3 at this time so he starts to retransmit.
However some SACK ACK comes early enough so he stops at 4 retransmits.
Or something like that...

>=20
>>>> Also interesting all retransmits happen _after_ those segments wer=
e
>>>> already acked and sacked, internal queuing or latency issues?
>>> I think your viewer is doing something wrong, sender.dump is not gi=
ving=20
>>> such information (or you draw that from wrong end?). Or it just dra=
ws
>>> DSACK like that?
>> Viewer is tcptrace and xplot. So nothing special at all.
>> You see it also in wireshark, if you draw a sequence diagram.
>=20
> Ah, now I noticed those small timeleaps, very small enough to not
> catch my eye earlier as the amount of numbers in such screen is just
> overhelming... :-)

Very small indeed. Probably the time a packets travels in kernel throug=
h the layer
is higher than the difference between ACK and retransmit.

>=20
>> You also see it in wireshark if you sort by capture timestamp. I alw=
ays=20
>> thought that capture timestamp order is correct and not dump order, =
but=20
>> maybe I'm wrong?
>=20
> I'm not sure, in the other order they make very much sense. In additi=
on,=20
> the ACKs are processed in order and their effects are immediate even =
if=20
> there's more information awaiting to be processed.

>=20
>> Tcpdump:
>>
>> 12:08:20.667538 IP 192.168.0.7.33824 > 192.168.0.5.50139: . ack 2348=
5 win 22720 <nop,nop,timestamp 969759 972885,nop,nop,sack 2 {24905:2632=
5}{27745:29165}>
>> ^^^^^ got acked at .667538
>=20
> Did you paste wrong timestamp as 667538 =3D=3D 667538? ...It just mak=
es no=20
> sense for me, what are you trying to say here?
>=20
>> 12:08:20.646749 IP 192.168.0.5.50139 > 192.168.0.7.33824: . 22065:23=
485(1420) ack 1 win 2864 <nop,nop,timestamp 972885 969754>
>> ^^^^^ got retransmitted at .646749
>=20
> What's the problem here? At .646749 something was retransmitted, but =
only=20
> after .667538 it was acked? Again, this makes very little sense for m=
e...
> Why did you copy them wrong way around from the tcpdump log? Or are t=
hese=20
> two lines related at all?

Sorry, this was just bogus. Just wanted to point out the timestamp diff=
erences and made a
wrong example. Screen full of numbers... ;-)

Thanks for your help.

Best regards,
Arnd


