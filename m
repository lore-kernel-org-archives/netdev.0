From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: TCP keepalive timer problem
Date: Fri, 28 Aug 2009 09:05:44 +0200
Message-ID: <4A9781C8.5030605@tvk.rwth-aachen.de>
References: <0939B589FC103041945B9F13274963E303B1A9D4@CORPUSMX90A.corp.emc.com>
 <4A93E36C.8070502@gmail.com>
 <0939B589FC103041945B9F13274963E303B1AD89@CORPUSMX90A.corp.emc.com>
 <4A967FCE.3000807@gmail.com> <87skfdl6qt.fsf@basil.nowhere.org>
 <4A969566.3070606@gmail.com> <20090827142927.GA17220@basil.fritz.box>
 <4A969CDC.6060402@gmail.com>
 <0939B589FC103041945B9F13274963E303BA96BB@CORPUSMX90A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: eric.dumazet@gmail.com, andi@firstfloor.org, netdev@vger.kernel.org
To: Li_Xin2@emc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:34693 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751862AbZH1HFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2009 03:05:44 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KP200HWKRPLHY70@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 28 Aug 2009 09:05:45 +0200 (CEST)
In-reply-to: <0939B589FC103041945B9F13274963E303BA96BB@CORPUSMX90A.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li_Xin2@emc.com schrieb:
>  > Yep, so to recap we have two changes :
> 
>> 1) The one I sent (taking into account the time of last ACK we
> received) to compute the
>> timer delays.
> 
>> 2) The one you suggest, avoiding to send a probe if we have packets in
> flight, relying
>> on normal retransmits timers.
> 
> I agree with these two changes, but I think the patch for point 2 given
> by Eric is not correct:
> 
> 
> elapsed = keepalive_time_when(tp);
> 
>  if (tp->packets_out || tcp_send_head(sk))
>  	if (tcp_retries2_time < keepalive_time_when(tp))
>  		goto resched;
>  elapsed = tcp_time_stamp - tp->rcv_tstamp;

Hello,
I didn't follow the conversation in all details, but I submitted a series of
patches recently, in which one of those the time was calculated out of
tcp_retries. It's the post "[PATCH 3/3] Revert Backoff [v3]: Calculate TCP's
connection close threshold as a time value." from Aug 26, 2009 at 12:16 CEST.

This is the code with the calculation procedure:

--
> static inline bool retransmits_timed_out(const struct sock *sk,
> 					 unsigned int boundary)
> {
> 	int limit, K;
> 	if (!inet_csk(sk)->icsk_retransmits)
> 		return false;
> 
> 	K = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
> 
> 	if (boundary <= K)
> 		limit = ((2 << boundary) - 1) * TCP_RTO_MIN;
> 	else
> 		limit = ((2 << K) - 1) * TCP_RTO_MIN +
> 			(boundary - K) * TCP_RTO_MAX;
> 
> 	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= limit;
> }
--

Given some boundary like tcp_retries2, it computes a limit, which should
be your tcp_retries2_time.
If that's not what you meant, then I'm sorry, and you can ignore it. :)

Regards
