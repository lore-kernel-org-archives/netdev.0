From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: pull request: SCTP updates for net-next
Date: Mon, 07 Dec 2009 10:05:34 -0500
Message-ID: <4B1D19BE.4080903@hp.com>
References: <4B0AF96A.3050709@hp.com>	<20091203210050.d886f229.akpm@linux-foundation.org>	<4B193772.9010109@hp.com> <20091204125233.eea7de39.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux SCTP Dev Mailing list <linux-sctp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrei Pelinescu-Onciul <andrei@iptel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:47134 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932685AbZLGPFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 10:05:31 -0500
In-Reply-To: <20091204125233.eea7de39.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Andrew Morton wrote:
> On Fri, 04 Dec 2009 11:23:14 -0500
> Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
> 
>>> Overall, it would be way simpler and saner to clamp this value to some
>>> explicit time period, IMO.
>>>
>>> <pulls number out of thin air>
>>>
>>> --- a/net/sctp/socket.c~a
>>> +++ a/net/sctp/socket.c
>>> @@ -2086,9 +2086,8 @@ static int sctp_setsockopt_autoclose(str
>>>  		return -EINVAL;
>>>  	if (copy_from_user(&sp->autoclose, optval, optlen))
>>>  		return -EFAULT;
>>> -	/* make sure it won't exceed MAX_SCHEDULE_TIMEOUT */
>>> -	if (sp->autoclose > (MAX_SCHEDULE_TIMEOUT / HZ) )
>>> -		sp->autoclose = MAX_SCHEDULE_TIMEOUT / HZ ;
>>> +	/* make sure it won't exceed one hour */
>>> +	sp->autoclose = min_t(u32, sp->autoclose, 60 * 60);
>>>  
>> But that may not be long enough.  The spec doesn't impose limits
>> and it's really up to the application to decide how long it wants
>> to keep idle connections open.  Thus any limits shorter the maximum
>> supported by kernel are really artificial and may not be sufficient.
> 
> Could make ->autoclose a u64?  That fixes any 32bit-vs-64bit
> inconsistencies and allows for an effectively infinite period.
> 

That's isn't going to help much since the timer intervals are unsigned longs,
and would overflow on 32 bit systems.  We would still need the limiting value to
prevent that overflow, but would be able to drop the cast.  Additionally, the
API provides only for a 32 bit integer, thus we would waste 32 bit of space.

I don't think that's worth it.  The last patch from Andrei fixed the warning
with a cast to u32.  It seems like the simplest solution.

-vlad
