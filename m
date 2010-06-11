From: Salvador Fandino <salvador@qindel.com>
Subject: Re: [PATCH] allow to configure tcp_retries1 and tcp_retries2 per
 TCP socket
Date: Fri, 11 Jun 2010 12:43:47 +0200
Message-ID: <4C121363.6080401@qindel.com>
References: <1276186161.2419.10.camel@topo> <87bpbi4ycc.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@firstfloor.org, vger.kernel.org@firstfloor.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.qindel.com ([62.97.67.18]:53231 "EHLO thor.int.qindel.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756167Ab0FKKoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 06:44:05 -0400
In-Reply-To: <87bpbi4ycc.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2010 07:00 PM, Andi Kleen wrote:
> Salvador Fandino<salvador@qindel.com>  writes:
>
>
>    
>> The included patch adds support for setting the tcp_retries1 and
>> tcp_retries2 options in a per socket fashion as it is done for the
>> keepalive options TCP_KEEPIDLE, TCP_KEEPCNT and TCP_KEEPINTVL.
>>
>> The issue I am trying to solve is that when a socket has data queued for
>> delivering, the keepalive logic is not triggered. Instead, the
>> tcp_retries1/2 parameters are used to determine how many delivering
>> attempts should be performed before giving up.
>>      
> And why exactly do you need new tunables to solve this?
>    

How else could it be solved?

I can think of making the retransmission logic to also honor the 
keepalive settings, switching to sending packets every keepintvl seconds 
when the elapsed time goes over keepidle and abort after keepcnt.

Or, make retransmits_timed_out() also consider 
(keepidle+keepcnt*keepintvl) as a ceiling.

But frankly, I don't like any one of them. IMO, leaving alone backward 
compatibility issues, it would make more sense to do it the other way 
and change the keepalive logic to follow the same sending pattern used 
for data retransmissions, using keepidle, retries1 and retries2 as its 
parameters.

Well, another option would be to use keepcnt as retries2 when defined in 
tcp_sock. IMO it would make sense, but could be confusing for the user.


>> The patch is very straight forward and just replicates similar
>> functionality. There is one thing I am not completely sure and is if the
>> new per-socket fields should go into inet_connection_sock instead of
>> into tcp_sock.
>>      
> tcp_sock is already quite big (>2k on 64bit)
>
> IMHO any new fields in there need very good justification.
>    

If this is a problem, there are some room for optimization in the 
inet_connection_sock and tcp_sock structures. For instance, 
keepalive_time and keepalive_intvl are limited to MAX_KEEPALIVE_TIME * 
HZ, that is 32767 * 1000 ==> 25 bits, so they would fit in a u32.

retries1 and retries2 fields also fit in u32 and actually, a per socket 
retries1 field is not absolutely required because the check against 
retries2 is always performed, so the impact of this patch on the 
structure size could be limited to 4 bytes.

- Salva


