From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 2/3] memcg/tcp: remove static_branch_slow_dec()
 at changing limit
Date: Fri, 30 Mar 2012 08:51:24 +0900
Message-ID: <4F74F57C.4030001@jp.fujitsu.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740A41.6040002@jp.fujitsu.com> <4F744038.1000900@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:59696 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865Ab2C2XxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 19:53:15 -0400
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1C4983EE0B6
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 08:53:14 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F14AB45DE59
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 08:53:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CFAA645DE56
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 08:53:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C24F21DB8052
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 08:53:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78CA31DB804B
	for <netdev@vger.kernel.org>; Fri, 30 Mar 2012 08:53:13 +0900 (JST)
In-Reply-To: <4F744038.1000900@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2012/03/29 19:58), Glauber Costa wrote:

> On 03/29/2012 09:07 AM, KAMEZAWA Hiroyuki wrote:
>> tcp memcontrol uses static_branch to optimize limit=RESOURCE_MAX case.
>> If all cgroup's limit=RESOUCE_MAX, resource usage is not accounted.
>> But it's buggy now.
>>
>> For example, do following
>>   # while sleep 1;do
>>     echo 9223372036854775807>  /cgroup/memory/A/memory.kmem.tcp.limit_in_bytes;
>>     echo 300M>  /cgroup/memory/A/memory.kmem.tcp.limit_in_bytes;
>>     done
>>
>> and run network application under A. tcp's usage is sometimes accounted
>> and sometimes not accounted because of frequent changes of static_branch.
>> Then, finally, you can see broken tcp.usage_in_bytes.
>> WARN_ON() is printed because res_counter->usage goes below 0.
>> ==
>> kernel: ------------[ cut here ]----------
>> kernel: WARNING: at kernel/res_counter.c:96 res_counter_uncharge_locked+0x37/0x40()
>>   <snip>
>> kernel: Pid: 17753, comm: bash Tainted: G  W    3.3.0+ #99
>> kernel: Call Trace:
>> kernel:<IRQ>   [<ffffffff8104cc9f>] warn_slowpath_common+0x7f/0xc0
>> kernel: [<ffffffff810d7e88>] ? rb_reserve__next_event+0x68/0x470
>> kernel: [<ffffffff8104ccfa>] warn_slowpath_null+0x1a/0x20
>> kernel: [<ffffffff810b4e37>] res_counter_uncharge_locked+0x37/0x40
>> ...
>> ==
>>
>> This patch removes static_branch_slow_dec() at changing res_counter's
>> limit to RESOUCE_MAX. By this, once accounting started, the accountting
>> will continue until the tcp cgroup is destroyed.
>>
>> I think this will not be problem in real use.
>>
> 
> So...
> 
> Are the warnings still there if you have your other patch in this series?


I wrote patch 3/3 after 2/3 because I found all case cannot be fixed by this.

So, comparing patch 3/3 this fixes is leaking.
Considering following sequence

	enable accounting
	tcp allocate buffer
	disable accounting
	tcp free buffer

The accounted usage nerver disappear. This is the probelem which cannot be
covered by patch 3/3. Maybe it's better to change order of patches 3/3 -> 2/3
and describe this explicitly.

> Maybe what we should do is, flush the resource counters so they go back
> to 0 besides decrementing the static branch. This way we get a more
> consistent behavior.
> 

set all memcg's usage to be 0 at enable/disable accounting ?
But, there is a problem which static_branch() update is slow. So,
IIUC, we can't catch all cases because of races.


> Another thing to keep in mind, is that the static branch will only be
> inactive if we turn off *all* controllers. You see this happening
> because you are only testing with one.

yes. So, the behavior change by this patch will not affect usual cases.

> So even if we go to the route you're proposing, we could probably try
> doing something on the
> global level, instead of a per-memcg boolean flat.

In global level, static_key's counter handles it.

Thanks,
-Kame
