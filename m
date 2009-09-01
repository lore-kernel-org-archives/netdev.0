From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection
 close threshold as a time value.
Date: Tue, 1 Sep 2009 16:41:35 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0909011623520.29341@wel-95.cs.helsinki.fi>
References: <4A950B82.1070807@tvk.rwth-aachen.de> <alpine.DEB.2.00.0908311555230.29341@wel-95.cs.helsinki.fi> <4A9D0554.1010508@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34300 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528AbZIANle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 09:41:34 -0400
In-Reply-To: <4A9D0554.1010508@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2009, Damian Lukowski wrote:

>> I'm fine with this approach as no matter what we would do the previous
>> approach just isn't fitting the new model that breaks the assumptions
>> behind the previous model. I don't expect the change in the timing to be
>> significant for anybody unless one did copy our code exactly somewhere
>> (including rtt calculation). ...but if somebody has some objections in
>> this, please speak up! After all, it will change how the sysctl behaves.
>>
>> Perhaps we should mention this artificial timing change in ip-sysctl.txt
>> too...?
>>
>> It would be worth to do a trivial pull-the-plug testing comparing this
>> and the previous approach in the rto < TCP_RTO_MIN region without any
>> icmps to verify that this didn't change the timing a bit, afaict, it
>> shouldn't (If you didn't do that already). Just to be on very sure grounds.
>
> thanks for reviewing all the patches.
> Which region do you mean exactly? I mean, rto < TCP_RTO_MIN should be
> impossible by definition, shouldn't it?

Right, I was careless in the wording. I meant with a low rtt'ed flow which 
lower bounds rto to TCP_RTO_MIN.

> However, there are differences between new and old timing, which maybe
> should be discussed. The new timeout values can deviate from the old
> approach by up to the value of the last actual RTO. Consider following:
>
> retries2 is set to 15 and MIN_RTO/MAX_RTO are 0.2 and 120 seconds,
> respectively. retrans_timed_out() calculates 924.6 seconds as timeout,
> regardless of the actual RTO.

My point was to take a connection which has rtt below the lower bound and 
this the actual RTO should be at TCP_RTO_MIN.

> Assume, that rtt measurement calculates
> 0.4 seconds as RTO before connectivity breaks.
> An unpatched TCP - as well as patched TCP without ICMPs - will do the
> standard backoff procedure and fire it's 15th retransmission after 924.4
> seconds, i.e. 0.2 seconds before the calculated timeout of 924.6 seconds.
>
> Then, patched TCP will wait for the next RTO, before checking again if the
> timeout expired - and will finally time out 119.8 seconds later
> than calculated. However, unpatched TCP will also wait until the 16th RTO
> (924.4 + 120 seconds) and then time out. So in this case, the effective
> timeouts for unpatched and patched TCP without ICMPs are the same, though
> not intended by retransmits_timed_out().

If RTO value was > MIN_RTO to begin with there will be the obvious 
difference.

> I have made a simple test with a netem delay of 30ms at the sender,
> and retries2 set to 6:
> Unpatched TCP times out after ~29.7 seconds,
> patched TCP without ICMPs also after ~29.7 seconds,

Thanks for your efforts in this, these times I was mostly interested in. 
Seems very good.

> Anyway, what is the procedure for further updates?
>
> As David has applied the current patches, I assume that I should post a 
> new series of two subpatches; one concerning your suggestions and the 
> second concerning the ip-sysctl.txt update?

Your guessed right, once applied no updates to the previous version but 
you take what Dave currently has as base (in net-next) and build on top of 
that.


-- 
  i.
