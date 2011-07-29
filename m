From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 39372] New: Problems with HFSC Scheduler
Date: Fri, 29 Jul 2011 16:11:19 +0200
Message-ID: <4E32BF87.6010909@trash.net>
References: <bug-39372-10286@https.bugzilla.kernel.org/>	 <20110714151425.844b7738.akpm@linux-foundation.org>	 <4E32A796.8060104@ziu.info>	 <1311946060.2843.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1311948052.2843.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Soltys <soltys@ziu.info>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>, lucas.bocchi@gmail.com,
	631945@bugs.debian.org, 00bormoj@gmail.com,
	fdelawarde@wirelessmundi.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56086 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290Ab1G2OLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 10:11:25 -0400
In-Reply-To: <1311948052.2843.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.07.2011 16:00, Eric Dumazet wrote:
> Le vendredi 29 juillet 2011 =E0 15:27 +0200, Eric Dumazet a =E9crit :
>> Le vendredi 29 juillet 2011 =E0 14:29 +0200, Michal Soltys a =E9crit=
 :
>>> On 11-07-15 00:14, Andrew Morton wrote:
>>>>
>>>> (switched to email.  Please respond via emailed reply-to-all, not =
via
>>>> the bugzilla web interface).
>>>>
>>>>
>>>> Here: WARN_ON(next_time =3D=3D 0);
>>>>
>>>
>>> From the other thread on netfilter-devel:
>>>
>>>> On 11-07-22 11:58, Michal Pokrywka wrote: After bisecting 2.6.39.1=
 it
>>>> turned out that the bug is caused independently by two patches:
>>>>
>>>> commit b262a5da755cc6ed0cb4fba230cd9bf4037e1096 sch_sfq: fix peek(=
)
>>>> implementation
>>>>
>>>> and
>>>>
>>>> commit 9df49f2bfe862573911a080c75a6d81113c5c81d sch_sfq: avoid giv=
ing
>>>> spurious NET_XMIT_CN signals
>>>>
>>>> Reverting these patches makes HFSC work again.
>>>>
>>>
>>> This one (upstream 8efa885406359af300d46910642b50ca82c0fe47) seems =
to be
>>> the culprit (does reverting only that one cures the problem ?)
>>>
>>> It allows SFQ to return success on enqueuing, when the packet reall=
y
>>> replaced some other packet in some other flow. This confuses outer =
qdisc
>>> (in this particular case HFSC) which thinks new packet was actually
>>> added each time such situation happes.
>>>
>>
>> Technically speaking, _this_ packet was successfuly enqueued.
>>
>> Returning NET_XMIT_CN or NET_XMIT_SUCCESS should not trigger a bug i=
n
>> caller.
>>
>>> This in turn causes additional dequeues and ends with attempt
>>> to schedule non-existent packets, and triggers the warning.
>>>
>>
>> Then its probably a bug in HFSC : It doesnt understand SFQ lost a
>> packet.
>>
>> I'll take a look, thanks for the report.
>>
>>
>=20
> Oh well, it seems one qdisc_tree_decrease_qlen(sch, 1) is missing
>=20
> Maybe following patch would help...
>=20
>=20
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 4536ee6..2a2d287 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -410,7 +410,12 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *s=
ch)
>  	/* Return Congestion Notification only if we dropped a packet
>  	 * from this flow.
>  	 */
> -	return (qlen !=3D slot->qlen) ? NET_XMIT_CN : NET_XMIT_SUCCESS;
> +	if (qlen !=3D slot->qlen)
> +		return NET_XMIT_CN;
> +
> +	/* as we dropped a packet, better let upper stack know this */
> +	qdisc_tree_decrease_qlen(sch, 1);
> +	return NET_XMIT_SUCCESS;
>  }
> =20

Yeah, that seems to be the correct fix, thanks for looking into this.
