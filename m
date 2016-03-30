From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] sctp: avoid refreshing heartbeat timer too often
Date: Wed, 30 Mar 2016 09:13:18 -0300
Message-ID: <56FBC2DE.3000207@gmail.com>
References: <1459258897-21607-1-git-send-email-marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D54DBFFCD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:33300 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbcC3MN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 08:13:26 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D54DBFFCD@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 30-03-2016 06:37, David Laight escreveu:
> From: Marcelo Ricardo Leitner
>> Sent: 29 March 2016 14:42
>>
>> Currently on high rate SCTP streams the heartbeat timer refresh can
>> consume quite a lot of resources as timer updates are costly and it
>> contains a random factor, which a) is also costly and b) invalidates
>> mod_timer() optimization for not editing a timer to the same value.
>> It may even cause the timer to be slightly advanced, for no good reason.
>
> Interesting thoughts:
> 1) Is it necessary to use a different 'random factor' until the timer actually
>     expires?

I don't understand you fully here, but we have to have a random factor 
on timer expire. As noted by Daniel Borkmann on his commit 8f61059a96c2 
("net: sctp: improve timer slack calculation for transport HBs"):

     RFC4960, section 8.3 says:

       On an idle destination address that is allowed to heartbeat,
       it is recommended that a HEARTBEAT chunk is sent once per RTO
       of that destination address plus the protocol parameter
       'HB.interval', with jittering of +/- 50% of the RTO value,
       and exponential backoff of the RTO if the previous HEARTBEAT
       is unanswered.

Previous to his commit, it was using a random factor based on jiffies.

This patch then assumes that random_A+2 is just as random as random_B as 
long as it is within the allowed range, avoiding the unnecessary updates.

> 2) It might be better to allow the heartbeat timer to expire, on expiry work
>     out the new interval based on when the last 'refresh' was done.

Cool, I thought about this too. It would introduce some extra complexity 
that is not really worth I think, specially because now we may be doing 
more timer updates even with this patch but it's not triggering any wake 
ups and we would need at least 2 wake ups then: one for the first 
timeout event, and then re-schedule the timer for the next updated one, 
and maybe again, and again.. less timer updates but more wake ups, one 
at every heartbeat interval even on a busy transport. Seems it's cheaper 
to just update the timer then.

Thanks,
Marcelo
