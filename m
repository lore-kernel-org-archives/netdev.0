From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH 2/5 net-next] inet: kill smallest_size and smallest_port
Date: Wed, 21 Dec 2016 14:32:33 -0500
Message-ID: <1482348753.24490.14@smtp.office365.com>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
        <1482264424-15439-3-git-send-email-jbacik@fb.com>
        <20161221.133003.1401543777326711002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: <hannes@stressinduktion.org>, <kraigatgoog@gmail.com>,
        <eric.dumazet@gmail.com>, <tom@herbertland.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50971 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751316AbcLUTcu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 14:32:50 -0500
In-Reply-To: <20161221.133003.1401543777326711002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 1:30 PM, David Miller <davem@davemloft.net> 
wrote:
> From: Josef Bacik <jbacik@fb.com>
> Date: Tue, 20 Dec 2016 15:07:01 -0500
> 
>>  In inet_csk_get_port we seem to be using smallest_port to figure 
>> out where the
>>  best place to look for a SO_REUSEPORT sk that matches with an 
>> existing set of
>>  SO_REUSEPORT's.  However if we get to the logic
>> 
>>  if (smallest_size != -1) {
>>  	port = smallest_port;
>>  	goto have_port;
>>  }
>> 
>>  we will do a useless search, because we would have already done the
>>  inet_csk_bind_conflict for that port and it would have returned 1, 
>> otherwise we
>>  would have gone to found_tb and succeeded.  Since this logic makes 
>> us do yet
>>  another trip through inet_csk_bind_conflict for a port we know 
>> won't work just
>>  delete this code and save us the time.
>> 
>>  Signed-off-by: Josef Bacik <jbacik@fb.com>
> 
> So the "all else being equal, use 'tb' with smallest socket count" 
> logic
> wasn't being used at all?
> 
> Instead of removing it why don't we make it work properly again?  
> Something
> obviously broke it somewhere along the line, because I am pretty sure 
> this
> heuristic worked at some point in the past.

Yeah as soon as we would find a tb with no bind conflicts we'd 
immediately jump to found_tb: and subsequently exit, so if we did 
manage to get to the point of checking smallest_size it would be 
redundant as we would have had to hit a bind conflict for that port to 
even reach that code.

How do you want me to add it back?  The logic only kicked in if we were 
SO_REUSEPORT with snum == 0, but Tom tells me that is basically 
useless, so we've disallowed that behavior.  Should we call a 
bind_conflict() for every port and then go back and pick the one with 
the smallest tb?  That's a lot of scanning.  Can you tell me what 
behavior you desire and I'll add another patch to reintroduce it?  
Thanks,

Josef
