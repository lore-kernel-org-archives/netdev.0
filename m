From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] NET_SCHED: restore HZ value to /proc/net/psched
Date: Tue, 24 Jun 2008 02:15:53 +0200
Message-ID: <48603CB9.60509@trash.net>
References: <20080623111320.7ddb72b9@extreme>	<485FFB28.7070503@trash.net> <20080623134551.24246494@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33221 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238AbYFXAQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 20:16:00 -0400
In-Reply-To: <20080623134551.24246494@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 23 Jun 2008 21:36:08 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> Stephen Hemminger wrote:
>>> Some changes back in  2.6.22 broke a number of
>>> other places where the iproute2 utilities depended on kernel HZ
>>> value. The use of HZ was a bad original ABI design choice; the
>>> question is how to fix the impacts.
>>>
>>> During 2.6.22 development, the psched clock was converted over
>>> to use high resolution timers, and one of the changes was to the
>>> return value of /proc/net/psched. This file is used by utilities
>>> to determine conversion between time and jiffies.
>>> It would be better to go back to the original format
>>> output where the fourth field was the kernel HZ.
>>>
>>> The motivation for the change was to make the HTB burst size
>>> default smaller because the kernel clock resolution was better.  
>>> But the change broke the use of jiffies by dst_metrics.
>>>
>>> With this revert all the metric RTT values will work again.
>>> The only use of hz in htb is to set the buffer and ceiling buffer default,
>>> and having the old value would cause a slightly larger value. Note: the comment
>>> in q_htb is incorrect, the value calculated is the default not the
>>> minimum.  As an example if HTB rate is 1mbit, then the default buffer
>>> would be come 11500 (with 100 HZ) vs 1500 (with 2.6.25).
>>>
>>> This effectively reverts commit 4361cb17f0df5491fe6e2c3ae1defc98e9a64a79
>>> I am not 100% convinced this is the best or only solution.
>> Me neither. As you've mentioned yourself, the fact that
>> the interfaces use kernel HZ as unit is a bug, and the use
>> of /proc/net/psched is another bug (one that isn't present
>> for *that* long I should add, the iproute git history
>> unfortunately only contains one huge patch which includes
>> this change).
>>
>> IMO qdiscs shouldn't be punished for bugs in other code
>> and the main problem would still remain. Two alternative
>> approaches:
>>
>> - just fix the interface (something we've done multiple
>>    times, even after 2.6 was released).
> 
> It is easy if the only thing to worry about is the current kernel
> and current iproute2 utilities. But if you want to deal with 3rd
> party applications that use the API's already, then the problem
> is much harder. I fixed the places where get_hz was used and user hz already.

Thats true, and in the case of rtmetrics it might actually matter.
But since the bug is a combination of using kernel units *and*
using /proc/net/psched to convert them, I wonder if its actually
present in more applications. Are you aware of any applications
using these rt metrics and /proc/net/psched? I would expect if
there are any at all, they are simply interpreting the values
as USER_HZ as was valid in 2.4 days. All the affected metrics
belong in the "rarely used" category.

> Do I have to get down to:
> 
> static unsigned long kernel_version(void)
> {
> 	struct utsname uts;
> 	unsigned a, b, c;
> 
> 	
> 	uname(&uts);
> 	sscanf(uts.release, "%u.%u.%u", &a, &b, &c);
> 	return KERNEL_VERSION(a, b, c);
> }
> 		
> static unsigned long kernel_hz(void)
> {
> 	unsigned long version = kernel_version();
> 
> 	if (version <= KERNEL_VERSION(2,6,21))
> 		return __get_hz();
> 	else if (version <= KERNEL_VERSION(2,6,27)) {
> 		fprintf(stderr, "Your kernel is screwed up and I can't find correct HZ\n");
> 		exit(1);
> 	}
> 	else
> 		return get_user_hz();	/* interface is now in correct units */
> }
> 
> 
> Even HTB shouldn't really care what the kernel clock resolution is.

Its not only HTB, its also used for rtabs, which are used by
CBQ, HTB, TBF and policing. They really need to know about
the packet scheduler clock resolution and that has at least
historical justification. The interface is using these units on
purpose to allow cheaps computations in the kernel. It might have
been better to convert within the kernel and use ns from the
beginning, but thats unfortunately much harder to change.

>> - add a new proc file to get the value of kernel HZ (the
>>    fix needs a kernel change anyway, this would additionally
>>    require a new iproute version).
> 
> Don't like this might encourage new bad ABI's.

Me neither, it was just an ugly alternative to the API
change, but on second though I'm even more convinced
that the metrics should be fixed.



