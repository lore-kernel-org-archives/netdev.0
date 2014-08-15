From: Tom Herbert <therbert@google.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Fri, 15 Aug 2014 11:49:02 -0700
Message-ID: <CA+mtBx_aEe6SvWV6tfqzGWcPvVM+FE6kbnyFE5FbECU9HN7EXg@mail.gmail.com>
References: <53ECFDAB.5010701@intel.com>
	<1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
	<53ED4354.9090904@intel.com>
	<20140814.162024.2218312002979492106.davem@davemloft.net>
	<53EE4023.6080902@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:39294 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbaHOStD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 14:49:03 -0400
Received: by mail-ig0-f170.google.com with SMTP id h3so3052188igd.3
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 11:49:03 -0700 (PDT)
In-Reply-To: <53EE4023.6080902@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2014 at 10:15 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> On 08/14/2014 04:20 PM, David Miller wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>> Date: Thu, 14 Aug 2014 16:16:36 -0700
>>
>>> Are you sure about each socket having it's own DST?  Everything I see
>>> seems to indicate it is somehow associated with IP.
>>
>> Right it should be, unless you have exception entries created by path
>> MTU or redirects.
>>
>> WRT prequeue, it does the right thing for dumb apps that block in
>> receive.  But because it causes the packet to cross domains as it
>> does, we can't do a lot of tricks which we normally can do, and that's
>> why the refcounting on the dst is there now.
>>
>> Perhaps we can find a clever way to elide that refcount, who knows.
>
> Actually I would consider the refcount issue just the coffin nail in all
> of this.  It seems like there are multiple issues that have been there
> for some time and they are just getting worse with the refcount change
> in 3.10.
>
> With the prequeue disabled what happens is that the frames are making it
> up and hitting tcp_rcv_established before being pushed into the backlog
> queues and coalesced there.  I believe the lack of coalescing on the
> prequeue path is one of the reasons why it is twice as expensive as the
> non-prequeue path CPU wise even if you eliminate the refcount issue.
>
> I realize most of my data is anecdotal as I only have the ixgbe/igb
> adapters and netperf to work with.  This is one of the reasons why I
> keep asking if someone can tell me what the use case is for this where
> it performs well.  From what I can tell it might have had some value
> back in the day before the introduction of things such as RPS/RFS where
> some of the socket processing would be offloaded to other CPUs for a
> single queue device, but even that use case is now deprecated since
> RPS/RFS are there and function better than this.  What I am basically
> looking for is a way to weight the gain versus the penalties to
> determine if this code is even viable anymore.
>
Alex, I tried to repro your problem running your script (on bnx2x).
Didn't see see the issue and in fact ip_dest_check did not appear in
top perf functions on perf. I assume this is more related to the
steering configuration rather than the device (although flow director
might be a fundamental difference).

> In the meantime I think I will put together a patch to default
> tcp_low_latency to 1 for net and stable, and if we cannot find a good
> reason for keeping it then I can submit a patch to net-next that will
> strip it out since I don't see any benefit to having this code.
>
> Thanks,
>
> Alex
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
