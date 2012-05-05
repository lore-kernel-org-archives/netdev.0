From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 0/3] First pass of cleanups for pskb_expand_head
Date: Fri, 04 May 2012 23:51:33 -0700
Message-ID: <4FA4CDF5.3070208@gmail.com>
References: <20120505001059.21292.31647.stgit@gitlad.jf.intel.com> <1336196671.3752.490.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59051 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab2EEGvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2012 02:51:43 -0400
Received: by yenm10 with SMTP id m10so2887468yen.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 23:51:42 -0700 (PDT)
In-Reply-To: <1336196671.3752.490.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/2012 10:44 PM, Eric Dumazet wrote:
> On Fri, 2012-05-04 at 17:26 -0700, Alexander Duyck wrote:
>> pull the actual value.
>>
>> There are a few more items that I will try to get to next week.  The big one
>> is the fact that pskb_expand_head can mess up the truesize since it can
>> allocate a new head but never updates the truesize.  I plan on adding a helper
>> function for the cases where we are just using it unshare the head so I can
>> identify the places where we are actually modifying the size.
> In the old days, truesize adjustements were done after
> pskb_expand_head() calls. (Mabye because some contexts didnt care of
> truesize for ephemeral skbs, not charged to a socket)
>
> So it will be a nice cleanup for sure.

I suspect the reason for no truesize adjustment is because this function 
gets called in the transmit path, and we probably should be adjusting 
truesize while there is still a desctructor in place that will turn 
around and subtract the truesize from the socket memory.  I'm still 
thinking about what would be the best solution to that, but in the 
meantime I figure I can at least add a helper function to handle all the 
pskb_expand_head(skb, 0, 0, GFP_ATOMIC) cases and just replace them with 
something like skb_unshare_head(skb).  That way I will have a better 
idea of the few cases where we might actually impact truesize.
