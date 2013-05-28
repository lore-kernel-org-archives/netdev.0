From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Tue, 28 May 2013 09:19:27 -0700
Message-ID: <51A4D90F.2020304@candelatech.com>
References: <1369601101-23057-1-git-send-email-atomlin@redhat.com> <20130527224149.GA4384@electric-eye.fr.zoreil.com> <51A4D4AD.2010507@candelatech.com> <20130528161518.GC11614@optiplex.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, atomlin@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	pshelar@nicira.com, mst@redhat.com, alexander.h.duyck@intel.com,
	riel@redhat.com, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org
To: Rafael Aquini <aquini@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58212 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934660Ab3E1QTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 12:19:36 -0400
In-Reply-To: <20130528161518.GC11614@optiplex.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2013 09:15 AM, Rafael Aquini wrote:
> On Tue, May 28, 2013 at 09:00:45AM -0700, Ben Greear wrote:
>> On 05/27/2013 03:41 PM, Francois Romieu wrote:
>>> atomlin@redhat.com <atomlin@redhat.com> :
>>> [...]
>>>> Failed GFP_ATOMIC allocations by the network stack result in dropped
>>>> packets, which will be received on a subsequent retransmit, and an
>>>> unnecessary, noisy warning with a kernel backtrace.
>>>>
>>>> These warnings are harmless, but they still cause users to panic and
>>>> file bug reports over dropped packets. It would be better to hide the
>>>> failed allocation warnings and backtraces, and let retransmits handle
>>>> dropped packets quietly.
>>>
>>> Linux VM may be perfect but device drivers do stupid things.
>>>
>>> Please don't paper over it just because some shit ends in your backyard.
>>
>> We should rate-limit these messages at least.  When a system is low on memory
>> the logs can quickly fill up with useless OOM messages, further slowing
>> the system...
>>
>
> The real problem seems to be that more and more the network stack (drivers, perhaps)
> is relying on chunks of contiguous page-blocks without a fallback mechanism to
> order-0 page allocations. When memory gets fragmented, these alloc failures
> start to pop up more often and they scare ordinary sysadmins out of their paints.
>
> The big point of this change was to attempt to relief some of these warnings
> which we believed as being useless, since the net stack would recover from it
> by re-transmissions.
> We might have misjudged the scenario, though. Perhaps a better approach would be
> making the warning less verbose for all page-alloc failures. We could, perhaps,
> only print a stack-dump out, if some debug flag is passed along, either as
> reference, or by some CONFIG_DEBUG_ preprocessor directive.

I have seen the logs spam with 0rder-0 allocation errors.  Maybe the system had
legitimate issues, but continuously spamming made it even harder to figure out
the problem, and constantly trying to write that much text to the serial console
has a big performance impact, further slowing the system when it should instead
be clearing it's packet backlog or whatever.

Maybe print the first OOM message with lots of details, and then use
some rate-limiting stuff to print out summary details at most every 5 seconds
or so after that.  Could reset the verbose timer after some period of no
OOM messages.

Ben

>
> Rafael
>
>> Ben
>>
>>>
>>
>>
>> --
>> Ben Greear <greearb@candelatech.com>
>> Candela Technologies Inc  http://www.candelatech.com
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
