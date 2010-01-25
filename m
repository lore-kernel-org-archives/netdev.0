From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Mon, 25 Jan 2010 13:12:43 +0100
Message-ID: <4B5D8ABB.8030906@tvk.rwth-aachen.de>
References: <200912261703.49067.denys@visp.net.lb>
 <201001191309.03927.denys@visp.net.lb>
 <alpine.DEB.2.00.1001191308490.14108@wel-95.cs.helsinki.fi>
 <201001232337.19122.denys@visp.net.lb>
 <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:50049 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751976Ab0AYMMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 07:12:44 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KWS00EL4XX76W90@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 25 Jan 2010 13:12:43 +0100 (CET)
In-reply-to: <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
considering Denys' latest tests, I think we should bound
at TCP_RTO_MIN inside __tcp_set_rto().
Look at the following piece:
> [  604.193389] rto: 200 (0 >> 3 + 0, 32) time: 304193 sent: 304091 pen: 1 307291 rem: 98                                                                                         
> [  604.193518] lower bound violation: 0 code 1 sk_state 1                                                                                                                        
> [  604.193589] rto: 200 (0 >> 3 + 0, 31) time: 304193 sent: 304091 pen: 1 304291 rem: 98                                                                                         
> [  604.193706] lower bound violation: 0 code 1 sk_state 1                                                                                                                        
> [  604.193776] rto: 200 (0 >> 3 + 0, 30) time: 304193 sent: 304091 pen: 1 304291 rem: 98                                                                                         
> [  607.341327] lower bound violation: 0 code 1 sk_state 1                                                                                                                        
> [  607.341412] rto: 200 (0 >> 3 + 0, 33) time: 307341 sent: 307091 pen: 1 310291 rem: 0  

We have a burst of three incoming ICMPs, not triggering retransmissions because
of rem > 0. Nevertheless, there is an increase of icsk_backoff by four
within 3100ms, with no ICMPs in between.
For me, this is explainable by the broken mdev/rtt issue together with
bursty ICMP replies.

- At t=0, RTT is at 0.2 seconds when connectivity breaks
- At t=3, TCP has emitted 4 eponentially backed-off retransmits,
  and icsk_rto is at 3.2s.
- At t=3+eps, three of four ICMPs arrive in one burst.
- Due to broken mdev, rto is reset to 0.2s inside tcp_v4_err(),
  independent of icsk_backoff.

Damian

> Restored Damian cc, please keep them.
> 
> On Sat, 23 Jan 2010, Denys Fedoryshchenko wrote:
>> On Tuesday 19 January 2010 13:17:51 you wrote:
>>> On Tue, 19 Jan 2010, Denys Fedoryshchenko wrote:
>>>> On Tuesday 19 January 2010 11:10:12 you wrote:
>>>>> Hi,
>>>>> thank you for testing. So srtt and rttvar is zero in any of those
>>>>> cases. Ilpo, it is a bug in tcp_rtt_estimator then, I suppose?
>>>>>
>>>>> There is also a code comment in tcp_input.c, saying:
>>>>>> * NOTE: clamping at TCP_RTO_MIN is not required, current algo
>>>>>> * guarantees that rto is higher.
>>>>> So we either fix tcp_rtt_estimator or simply clamp at TCP_RTO_MIN?
>>>>>
>>>>> Damian
>>>>>
>>>>>> On Monday 11 January 2010 15:02:34 you wrote:
>>>>>>> On Sat, 26 Dec 2009, Denys Fedoryshchenko wrote:
>>>>>>>> Few more dumps. I notice:
>>>>>>>> 1)Ack always equal 1
>>>>>>>> 2)It is usually first segment of data sent (?)
>>>>>>>>
>>>>>>>> Maybe some value not initialised properly?
>>>>>>> Can you see if the RTO lower bound is violated (I added some
>>>>>>> printing of vars there too already now if it turns out to be
>>>>>>> something):
>>>>>>>
>>>>>>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>>>>>>> index 65b8ebf..d84469f 100644
>>>>>>> --- a/net/ipv4/tcp_ipv4.c
>>>>>>> +++ b/net/ipv4/tcp_ipv4.c
>>>> As i see in code it is rounding RTO to minimum value.
>>>> It fixes my problem seems.
>>>>
>>>> Btw just a bit about my environment - wireless networks (sometimes
>>>> lossy!) with low speed (128-512Kbps) customers working over pppoe. Maybe
>>>> it will give a tip why rtt value is too low.
>>> What I find most strange in it is the fact that when it triggers for the
>>> first time, the srtt and mdev are zero, not some value in between 0 and
>>> 200ms. Therefore I suspect that this case might be something that we've
>>> overlooked where srtt/mdev are not valid at all.
>>>
>>> Maybe the patch below helps...
>>>
>> Seems after this patch (and debug patch with warnings) my dmesg is clean.
> 
> Cool, thanks for testing.
> 
> Dave, please send into stable too (besides net-2.6). If we want less strict 
> state check we can continue playing with that in net-next, IMHO.
> 

