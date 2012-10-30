From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] sctp: support per-association stats via a new
 SCTP_GET_ASSOC_STATS call
Date: Tue, 30 Oct 2012 10:21:10 -0400
Message-ID: <508FE256.9010205@gmail.com>
References: <1351258973-17227-1-git-send-email-michele@acksyn.org> <20121026143704.GC25087@hmsreliant.think-freely.org> <20121029084143.GA17442@casper.infradead.org> <20121029113700.GA9332@hmsreliant.think-freely.org> <508EE586.9060907@gmail.com> <20121030111546.GA14013@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Michele Baldessari <michele@acksyn.org>,
	linux-sctp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:56967 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab2J3OVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 10:21:14 -0400
In-Reply-To: <20121030111546.GA14013@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2012 07:15 AM, Neil Horman wrote:
> On Mon, Oct 29, 2012 at 04:22:30PM -0400, Vlad Yasevich wrote:
>> On 10/29/2012 07:37 AM, Neil Horman wrote:
>>> On Mon, Oct 29, 2012 at 08:41:43AM +0000, Thomas Graf wrote:
>>>> On 10/26/12 at 10:37am, Neil Horman wrote:
>>>>> We already have files in /proc/net/sctp to count snmp system-wide totals,
>>>>> per-endpoint totals, and per association totals.  Why do these stats differently
>>>>> instead of just adding them the per-association file?  I get that solaris does
>>>>> this, but its not codified in any of the RFC's or other standards.  I would
>>>>> really rather see something like this go into the interfaces we have, rather
>>>>> than creating a new one.
>>>>
>>>> I really dislike to grow the procfs interface. I would favour a
>>>> netlink inteface but we already export all the statistics via
>>>> the socket interface so this is the most consistent choice.
>>>>
>>> I'm not sure what statistics you are referring to here.  The only stats I see
>>> exported (save for association setting exported via SCTP_STATUS on the socket
>>> interface), are done via proc.  I agree that proc stinks out loud, but my first
>>> though when seeing stats exported via an interface in which you need to provide
>>> process specific data (in this case the socket and association id), is that the
>>> very next thing that someone will ask for is the ability for these stats to be
>>> visible from outside the process, so an external tool can monitor them.  I guess
>>> I'm ok with this approach, since its more efficient than polling proc (as per
>>> your needs below), but maybe its time to start looking at implementing a
>>> NETLINK_STATS interface so that we can have the best of both worlds.
>>>
>>
>> Yep.  That's been on the TODO list for a while, just always at a
>> lower priority then other things...
>>
> I'll start trying to look at it...when I get a spare moment :)
>
>>>
>>>>> And the max observed rto stat is just odd.  Each
>>>>> transport has an rto value, not each association, and you cal already see the
>>>>> individual transport rto values in /proc/net/sctp/remaddr.
>>>>
>>>> It's true that this is not found in any RFC and the request seems to
>>>> be based on the fact that Solaris provides this information already.
>>>> Recording the largest observed RTO is critical for latency sensitive
>>>> use cases. Looking at RTO in remaddr doesn't really help to figure out
>>>> the MAX(RTO) even with a very high polling frequency, something you
>>>> don't want to do on a procfs file.
>>>>
>>> Hm, ok, looking for the maximum rto seen is definately more efficient that a
>>> high polling rate on the remaddr file.  Still can't say I really like it as a
>>> statistic though.  While it helps in diagnosing a very specific type of problem
>>> (applications that have a maximum allowable latency), its really not useful, and
>>> potentially misleading, in the general case.  Specificaly it may show a very
>>> large RTO even if that RTO was an erroneous spike in behavior earlier in the
>>> lifetime of a given transport, even if that RTO is not representative of the
>>> current behavior of the association.  It seems to me like this stat might be
>>> better collected using a stap script or by adding a trace point to
>>> sctp_transport_update_rto.  If the application needs to know this information
>>> internally during its operation to take corrective action, you can already get
>>> it via the SCTP_GET_PEER_ADDR_INFO socket option on a per transport basis just
>>> as efficiently.
>>>
>>
>> The max_rto is reset after each getsockopt(), so in effect, the
>> application sets its own polling interval and gets the max rto
>> achieved during it.  If the rto hasn't changed, then the last value
>> is returned.  Not sure how much I like that.  I would rather get max
>> rto achieved per polling period and upon reset, max_rto is
>> accumulated again (easy way to do that is set to rto_min on reset).
>> This way an monitoring thread can truly represent the max rto
>> reported by association.  It should normally remain steady, but this
>> will show spikes, if any.
>>
> Agreed, that would be a better way to determine the maximum rto the association
> has seen.  My thought above was to, on every receive, to use the sndrcvinfo cmsg
> to detect the transport that a message arrived on, and then use
> SCTP_GET_PEER_ADDR_INFO to determine the current rto on that transport.  It
> should still show spikes, while avoiding unneeded polls, as you would only have
> to check the stat for every packet (or set of packets) received.

What if the message arrived across multiple transports?

Also, you can always see current rto, but that means that the 
application has to still poll for it with PEER_ADDR_INFO.  I think the 
idea, as Thomas pointed out, is to easily see what the max rto was.  I 
like that, but I don't like the fact that it's per association.   With 
that stat we really don't know which transport spiked.  So, it gives us 
a some useful information, but not really enough.

It might be a little more useful to keep track of the which transport 
has experienced the spike and then return info about it.    Granted, we 
may be too late and the spike corrected itself already, but at least it 
will give the management application a little more information and allow 
admin to have a little more info to determine why the spike occurred.

-vlad
