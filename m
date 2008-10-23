From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
	<avillaci-x0m+Mc+nT7uljOmnV8AmnkElSqmLX1BE@public.gmane.org>
Subject: Re: Regression: Recent networking (qdisc?) patches
	break irda_get_next_speed()
Date: Wed, 22 Oct 2008 19:24:24 -0500
Message-ID: <48FFC438.1080505@ceibo.fiec.espol.edu.ec>
References: <48FE1D52.6080903@ceibo.fiec.espol.edu.ec>	<48FE2F81.9060801@gmail.com>	<48FE67D4.5060200@ceibo.fiec.espol.edu.ec>
	<20081021.164121.257737412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20081021.164121.257737412.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller escribi=F3:
> From: Alex Villac=ED=ADs Lasso <avillaci-x0m+Mc+nT7uljOmnV8AmnkElSqmLX1BE@public.gmane.org>
> Date: Tue, 21 Oct 2008 18:37:56 -0500
>
>   =

>> So then, the bug is that the cb field in the struct sk_buff is being
>> interpreted as both a struct qdisc_skb_cb and an struct irda_skb_cb,
>> for the same instance of struct sk_buff. I have just started to
>> review the suggested patch, but it seems that 'struct qdisc_skb_cb'
>> was meant to be aliased against the data for other layers (as
>> suggested by the presence of a 'char data[]' field). If so, how come
>> only IrDA is affected? How come UDP, TCP, etc. not affected by this?
>> On the other hand, if qdisc_skb_cb was not meant to be aliased, then
>> the IrDA case was left out while converting the rest of the layers
>> so that they will skip over the member 'pkt_len' of the 'struct
>> qdisc_skb_cb'.
>>     =

>
> The SKB control block is not aliased.
>
> Once the packet is given to dev_queue_xmit() the packet scheduler
> "owns" the control block of the SKB.
>
> What IRDA is doing is illegal, and breaks in other ways without the
> commit in question.
>
> IRDA cannot depend upon the SKB control block not changing across
> the dev_queue_xmit() call.
>
>   =

Let me see if I understood. So the particular illegal thing the IRDA =

stack is doing is the access of the control block in the middle of the =

driver transmit routine (via irda_get_next_speed() and friends). This =

information should be stored somewhere else. Exactly *where* to store it =

is the main problem to solve.

What is the proper way (if any) to store per-packet parameters (other =

than the payload itself) which are specific to a particular layer (IrDA =

in this case) and which are needed by drivers in order to work =

correctly? The control block gets overwritten by the time the driver =

proc (hard_start_xmit) is called, so this approach is now ruled out. I =

was thinking about storing a copy of the parameters (struct irda_skb_cb) =

as a header within the payload itself (skb->data[]), but I am not sure =

about whether this approach is a good design decision. I am open to =

suggestions on where to place the parameters.

-- =

perl -e '$x=3D2.4;print sprintf("%.0f + %.0f =3D %.0f\n",$x,$x,$x+$x);'


-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great priz=
es
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=3D100&url=3D/
