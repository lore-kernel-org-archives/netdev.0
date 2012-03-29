From: Glauber Costa <glommer@parallels.com>
Subject: Re: [BUGFIX][PATCH 2/3] memcg/tcp: remove static_branch_slow_dec()
 at changing limit
Date: Thu, 29 Mar 2012 12:58:00 +0200
Message-ID: <4F744038.1000900@parallels.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F740A41.6040002@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:35931 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757058Ab2C2K6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 06:58:14 -0400
In-Reply-To: <4F740A41.6040002@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2012 09:07 AM, KAMEZAWA Hiroyuki wrote:
> tcp memcontrol uses static_branch to optimize limit=RESOURCE_MAX case.
> If all cgroup's limit=RESOUCE_MAX, resource usage is not accounted.
> But it's buggy now.
> 
> For example, do following
>   # while sleep 1;do
>     echo 9223372036854775807>  /cgroup/memory/A/memory.kmem.tcp.limit_in_bytes;
>     echo 300M>  /cgroup/memory/A/memory.kmem.tcp.limit_in_bytes;
>     done
> 
> and run network application under A. tcp's usage is sometimes accounted
> and sometimes not accounted because of frequent changes of static_branch.
> Then, finally, you can see broken tcp.usage_in_bytes.
> WARN_ON() is printed because res_counter->usage goes below 0.
> ==
> kernel: ------------[ cut here ]----------
> kernel: WARNING: at kernel/res_counter.c:96 res_counter_uncharge_locked+0x37/0x40()
>   <snip>
> kernel: Pid: 17753, comm: bash Tainted: G  W    3.3.0+ #99
> kernel: Call Trace:
> kernel:<IRQ>   [<ffffffff8104cc9f>] warn_slowpath_common+0x7f/0xc0
> kernel: [<ffffffff810d7e88>] ? rb_reserve__next_event+0x68/0x470
> kernel: [<ffffffff8104ccfa>] warn_slowpath_null+0x1a/0x20
> kernel: [<ffffffff810b4e37>] res_counter_uncharge_locked+0x37/0x40
> ...
> ==
> 
> This patch removes static_branch_slow_dec() at changing res_counter's
> limit to RESOUCE_MAX. By this, once accounting started, the accountting
> will continue until the tcp cgroup is destroyed.
> 
> I think this will not be problem in real use.
> 

So...

Are the warnings still there if you have your other patch in this series?
Maybe what we should do is, flush the resource counters so they go back
to 0 besides decrementing the static branch. This way we get a more
consistent behavior.

Another thing to keep in mind, is that the static branch will only be
inactive if we turn off *all* controllers. You see this happening
because you are only testing with one.
So even if we go to the route you're proposing, we could probably try
doing something on the
global level, instead of a per-memcg boolean flat.
