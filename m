From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2] neigh: set nud_state to NUD_INCOMPLETE when probing
 router reachability
Date: Tue, 13 May 2014 13:12:29 +0800
Message-ID: <5371A9BD.2020106@cn.fujitsu.com>
References: <53703F52.9060900@cn.fujitsu.com>	<20140512.143720.896863177762079657.davem@davemloft.net>	<53717040.2070102@cn.fujitsu.com> <20140512.232511.1061979369646724590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: <hannes@stressinduktion.org>, <netdev@vger.kernel.org>,
	<jbenc@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:23974 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758289AbaEMFOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 01:14:52 -0400
In-Reply-To: <20140512.232511.1061979369646724590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

于 2014年05月13日 11:25, David Miller 写道:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> Date: Tue, 13 May 2014 09:07:12 +0800
> 
>> 于 2014年05月13日 02:37, David Miller 写道:
>>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>> Date: Mon, 12 May 2014 11:26:10 +0800
>>>
>>>> 于 2014年05月12日 06:04, Hannes Frederic Sowa 写道:
>>>>> On Thu, May 8, 2014, at 22:16, Duan Jiong wrote:
>>>>>>
>>>>>> Since commit 7e98056964("ipv6: router reachability probing"), a router falls
>>>>>> into NUD_FAILED will be probed.
>>>>>>
>>>>>> Now if function rt6_select() selects a router which neighbour state is NUD_FAILED,
>>>>>> and at the same time function rt6_probe() changes the neighbour state to NUD_PROBE,
>>>>>> then function dst_neigh_output() can directly send packets, but actually the
>>>>>> neighbour still is unreachable. If we set nud_state to NUD_INCOMPLETE instead
>>>>>> NUD_PROBE, packets will not be sent out until the neihbour is reachable.
>>>>>>
>>>>>> In addition, because the route should be probes with a single NS, so we must
>>>>>> set neigh->probes to neigh_max_probes(), then the neigh timer timeout and function
>>>>>> neigh_timer_handler() will not send other NS Messages.
>>>>>>
>>>>>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>>>>> ---
>>>>>> Changes from v1:
>>>>>> 	*modify changelog to explain in detail why use neigh_max_probes().
>>>>>>
>>>>>>  net/core/neighbour.c | 4 ++--
>>>>>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>>>>>
>>>>>> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
>>>>>> index 8f8a96e..32d872e 100644
>>>>>> --- a/net/core/neighbour.c
>>>>>> +++ b/net/core/neighbour.c
>>>>>> @@ -1248,8 +1248,8 @@ void __neigh_set_probe_once(struct neighbour *neigh)
>>>>>>  	neigh->updated = jiffies;
>>>>>>  	if (!(neigh->nud_state & NUD_FAILED))
>>>>>>  		return;
>>>>>> -	neigh->nud_state = NUD_PROBE;
>>>>>> -	atomic_set(&neigh->probes, NEIGH_VAR(neigh->parms, UCAST_PROBES));
>>>>>> +	neigh->nud_state = NUD_INCOMPLETE;
>>>>>> +	atomic_set(&neigh->probes, neigh_max_probes(neigh));
>>>>>
>>>>> Wouldn't it be better if we neigh_suspect the neighbour and leaving the state in NUD_PROBE? We call down to ->output in case neighbour is in NUD_PROBE state, so we must just disable connected 'fast-path'.
>>>>>
>>>>
>>>> You can look into neigh_event_send() called in neigh_resolve_output(), and if neigh->nud_state
>>>> still is NUD_PROBE, the neigh_event_send() will return 0, so the packet will still be sent out
>>>> without probe.
>>>>
>>>> So, using neigh_suspect is not a good idea.
>>>
>>> If you set it to NUD_INCOMPLETE however, neigh_event_send() is going to add the packet
>>> to the neigh's ARP queue and return '1'.
>>>
>>> Is that really what you want to happen in this case?
>>
>> Yes, packets should not be sent out until the neihbour is reachable.
> 
> But shouldn't we be using the router in the list which did not enter
> NUD_FAILED in this situation?
> .

In situation of connected router, the router which enter NUD_FAILED will
never be choosed, and we only probe NUD_FAILED router's reachability by sending
a single Neighbor Solicitation to that router's address.  Finally， we 
still send packets out through the connected router.
