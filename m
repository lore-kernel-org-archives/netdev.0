From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: rtnl_register in net_ns_init need rtnl_lock
Date: Thu, 22 Sep 2016 15:41:23 +0200
Message-ID: <4c1b9aba-e6e8-babc-1bbe-aef2bc0bca53@stressinduktion.org>
References: <1474542209-28409-1-git-send-email-hannes@stressinduktion.org>
 <1474549384.23058.94.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:47046 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933216AbcIVNlZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 09:41:25 -0400
In-Reply-To: <1474549384.23058.94.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.09.2016 15:03, Eric Dumazet wrote:
> On Thu, 2016-09-22 at 13:03 +0200, Hannes Frederic Sowa wrote:
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>>  net/core/net_namespace.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>> index 2c2eb1b629b11d..a2ace299f28355 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -758,9 +758,11 @@ static int __init net_ns_init(void)
>>  
>>  	register_pernet_subsys(&net_ns_ops);
>>  
>> +	rtnl_lock();
>>  	rtnl_register(PF_UNSPEC, RTM_NEWNSID, rtnl_net_newid, NULL, NULL);
>>  	rtnl_register(PF_UNSPEC, RTM_GETNSID, rtnl_net_getid, rtnl_net_dumpid,
>>  		      NULL);
>> +	rtnl_unlock();
>>  
>>  	return 0;
>>  }
> 
> Hi Hannes
> 
> Why is this needed here, and not in other places ?

I found this during working on the file and actually saw no live issues
(belonged to another series which I just split up).

I don't think it is a big issue but wanted the writes to the
rtnl_msg_handlers array to be strictly serialized. I was working on
adding this to other places, too. Maybe better for net-next even?

Theoretically we would need to add a memory barriers to make sure we
don't publish uninitialized memory into the array if concurrent readers
of the array want to find their function pointers.

> Hint : A changelog always help reviewers and future bug hunting.

I will add that to v2.

Thanks,
Hannes
