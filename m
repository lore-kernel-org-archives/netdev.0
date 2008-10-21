From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci@ceibo.fiec.espol.edu.ec>
Subject: Re: Regression: Recent networking (qdisc?) patches break irda_get_next_speed()
Date: Tue, 21 Oct 2008 18:37:56 -0500
Message-ID: <48FE67D4.5060200@ceibo.fiec.espol.edu.ec>
References: <48FE1D52.6080903@ceibo.fiec.espol.edu.ec> <48FE2F81.9060801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, Jarek Poplawski <jarkao2@gmail.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-200-93-199-98.telconet.net ([200.93.199.98]:56704 "EHLO
	elastix.palosanto.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751957AbYJUXiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 19:38:18 -0400
In-Reply-To: <48FE2F81.9060801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski escribi=F3:
> Alex Villac=ED=ADs Lasso wrote, On 10/21/2008 08:20 PM:
>
>  =20
>> A regression has been introduced in 2.6.27 in the networking code, w=
hich=20
>> breaks the irda_get_next_speed() function used by some IrDA drivers,=
=20
>> including ks959-sir, written by me. I have filed a bug at:
>>
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D11795
>>
>> to keep track of this. I am still performing bisection to locate the=
=20
>> exact commit that broke the code, but the bug involves an overwritin=
g of=20
>> the beginning of a structure with extraneous data that makes the=20
>> LAP_MAGIC check fail. I have tried searching the netdev archives, bu=
t=20
>> there is no mention at all of regressions caused by this code. Milan=
=20
>> Plzik at irda-users mentions the same problem affecting pxaficp_ir, =
and=20
>> mentions recent qdisc patches as possible culprits.  Vasily Khoruzhi=
ck=20
>> reported this bug at irda-users, and a quick hack (not a proper fix)=
=20
>> proposed by him involves padding "struct irda_skb_cb" with 4 bytes a=
t=20
>> the beginning of the structure to move everything else past the bugg=
y=20
>> scribbling.
>>    =20
>
>
> Looks like the patch below could fit to your description.
>
> Jarek P.
>
> commit 175f9c1bba9b825d22b142d183c9e175488b260c
> Author: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Date:   Sun Jul 20 00:08:47 2008 -0700
>
>     net_sched: Add size table for qdiscs
>
>     Add size table functions for qdiscs and calculate packet size in
>     qdisc_enqueue().
>
>     Based on patch by Patrick McHardy
>      http://marc.info/?l=3Dlinux-netdev&m=3D115201979221729&w=3D2
>
>     Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
>
>  =20
So then, the bug is that the cb field in the struct sk_buff is being=20
interpreted as both a struct qdisc_skb_cb and an struct irda_skb_cb, fo=
r=20
the same instance of struct sk_buff. I have just started to review the=20
suggested patch, but it seems that 'struct qdisc_skb_cb' was meant to b=
e=20
aliased against the data for other layers (as suggested by the presence=
=20
of a 'char data[]' field). If so, how come only IrDA is affected? How=20
come UDP, TCP, etc. not affected by this? On the other hand, if=20
qdisc_skb_cb was not meant to be aliased, then the IrDA case was left=20
out while converting the rest of the layers so that they will skip over=
=20
the member 'pkt_len' of the 'struct qdisc_skb_cb'.

Or maybe all the other layers *are* being overwritten, and IrDA is the=20
only one that has a 'magic' member to check against corruption... As fa=
r=20
as I can see, no other layer has a member with an equivalent function.

--=20
perl -e '$x=3D2.4;print sprintf("%.0f + %.0f =3D %.0f\n",$x,$x,$x+$x);'

