From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
Date: Wed, 16 May 2012 10:03:08 +0400
Message-ID: <4FB3431C.3050402@parallels.com>
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <4FB058D8.6060707@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4FB058D8.6060707-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/14/2012 04:59 AM, KAMEZAWA Hiroyuki wrote:
> (2012/05/12 5:11), Glauber Costa wrote:
> 
>> We call the destroy function when a cgroup starts to be removed,
>> such as by a rmdir event.
>>
>> However, because of our reference counters, some objects are still
>> inflight. Right now, we are decrementing the static_keys at destroy()
>> time, meaning that if we get rid of the last static_key reference,
>> some objects will still have charges, but the code to properly
>> uncharge them won't be run.
>>
>> This becomes a problem specially if it is ever enabled again, because
>> now new charges will be added to the staled charges making keeping
>> it pretty much impossible.
>>
>> We just need to be careful with the static branch activation:
>> since there is no particular preferred order of their activation,
>> we need to make sure that we only start using it after all
>> call sites are active. This is achieved by having a per-memcg
>> flag that is only updated after static_key_slow_inc() returns.
>> At this time, we are sure all sites are active.
>>
>> This is made per-memcg, not global, for a reason:
>> it also has the effect of making socket accounting more
>> consistent. The first memcg to be limited will trigger static_key()
>> activation, therefore, accounting. But all the others will then be
>> accounted no matter what. After this patch, only limited memcgs
>> will have its sockets accounted.
>>
>> [v2: changed a tcp limited flag for a generic proto limited flag ]
>> [v3: update the current active flag only after the static_key update ]
>> [v4: disarm_static_keys() inside free_work ]
>> [v5: got rid of tcp_limit_mutex, now in the static_key interface ]
>>
>> Signed-off-by: Glauber Costa<glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>> CC: Tejun Heo<tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> CC: Li Zefan<lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> CC: Kamezawa Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
>> CC: Johannes Weiner<hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
>> CC: Michal Hocko<mhocko-AlSwsSmVLrQ@public.gmane.org>
> 
> 
> Thank you for your patient works.
> 
> Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> 
> BTW, what is the relationship between 1/2 and 2/2  ?

Can't do jump label patching inside an interrupt handler. They need to
happen when we free the structure, and I was about to add a worker
myself when I found out we already have one: just we don't always use it.

Before we merge it, let me just make sure the issue with config Li
pointed out don't exist. I did test it, but since I've reposted this
many times with multiple tiny changes - the type that will usually get
us killed, I'd be more comfortable with an extra round of testing if
someone spotted a possibility.

Who is merging this fix, btw ?
I find it to be entirely memcg related, even though it touches a file in
net (but a file with only memcg code in it)
