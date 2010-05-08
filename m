From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH][v4] tcp: fix ICMP-RTO war
Date: Sat, 08 May 2010 10:30:52 +0200
Message-ID: <4BE5213C.1030300@tvk.rwth-aachen.de>
References: <4B7303C2.5000703@tvk.rwth-aachen.de>
 <alpine.DEB.2.00.1002151535030.7063@wel-95.cs.helsinki.fi>
 <20100221.181029.71107197.davem@davemloft.net>
 <o2z349f35ee1005071622z38fcd66ek398402d7512542ae@mail.gmail.com>
 <n2gd1c2719f1005071625nd3df3d72t9655a1f64f2fd825@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:56585 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752528Ab0EHJAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 May 2010 05:00:53 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L2300DTREBG04E0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Sat, 08 May 2010 10:30:52 +0200 (CEST)
In-reply-to: <n2gd1c2719f1005071625nd3df3d72t9655a1f64f2fd825@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm working on a patch that tries to measure and use the RTT for the =
passive
> open side when the TS option is NOT enabled. My code conflicts with y=
our
> recently added "tcp_ack_update_rtt(sk, 0, 0);" Could you tell me why =
do you
> force this call for the no-TS case when obviously "0" is not a measur=
ed RTT?
> If you try to force icsk_rto to be initialized correctly, it is
> already initialized to
> TCP_TIMEOUT_INIT by tcp_create_openreq_child(). What am I missing?

Hi,
the backoff reversion code uses __tcp_set_rto() to recalculate icsk_rto=
,
which itself relies on tp->srtt and rttvar.
srtt is explicitly set to 0 in tcp_create_openreq_child(), so I didn't =
change it.
Initializing it with TCP_TIMEOUT_INIT should also fix that specific bug=
,
but I don't know if there are other impacts.

Regards
 Damian

> Thanks,
>=20
> Jerry
>=20
>> From: David Miller <davem@davemloft.net>
>>
>> Date: Sun, Feb 21, 2010 at 7:10 PM
>> Subject: Re: [PATCH][v4] tcp: fix ICMP-RTO war
>> To: ilpo.jarvinen@helsinki.fi
>> Cc: damian@tvk.rwth-aachen.de, netdev@vger.kernel.org
>>
>>
>> From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
>> Date: Tue, 16 Feb 2010 14:45:25 +0200 (EET)
>>
>>> On Wed, 10 Feb 2010, Damian Lukowski wrote:
>>>
>>>> @@ -5783,12 +5783,10 @@ int tcp_rcv_state_process(struct sock *sk,=
 struct sk_buff *skb,
>>>>
>>>>                              /* tcp_ack considers this ACK as dupl=
icate
>>>>                               * and does not calculate rtt.
>>>> -                             * Fix it at least with timestamps.
>>>> +                             * Force it here.
>>>>                               */
>>>> -                            if (tp->rx_opt.saw_tstamp &&
>>>> -                                tp->rx_opt.rcv_tsecr && !tp->srtt=
)
>>>> -                                    tcp_ack_saw_tstamp(sk, 0);
>>>> -
>>>> +                            tcp_ack_update_rtt(sk, 0, 0);
>>>> +
>>>
>>> ...Here a zero seq_rtt is given to RTT estimator (it will be effect=
ive
>>> only in the case w/o timestamps, TS case recalculates it from the s=
tored
>>> timestamps). Maybe we could use some field (timestamp related one c=
omes to
>>> my mind) in request sock to get a real RTT estimate for non-timesta=
mp case
>>> too. ...It seems possible to me, though tricky because the request_=
sock is
>>> no longer that easily available here so some parameter passing woul=
d be
>>> needed.
>>
>> Agreed.
>>
>> But even more simply I think we should make even the current
>> tcp_ack_update_rtt() call here conditional on at least
>> tp->srtt being zero.
>>
>> Damian do you at least agree with that?
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

