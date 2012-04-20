From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 0/3] Fix problem with static_key decrement
Date: Fri, 20 Apr 2012 12:01:50 -0300
Message-ID: <4F917A5E.7040803@parallels.com>
References: <1334875758-20939-1-git-send-email-glommer@parallels.com> <20120419225441.GD10553@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120419225441.GD10553-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/19/2012 07:54 PM, Tejun Heo wrote:
> On Thu, Apr 19, 2012 at 07:49:15PM -0300, Glauber Costa wrote:
>> Hi,
>>
>> This is my proposed fix for the sock memcg static_key
>> problem raised by Kamezawa. It works for me, but I would
>> Kame, please confirm.
>
> Please detail the problem.  I don't follow what's the purpose here.
>

Ok.

1) Kame found the following bug: we were decrementing the jump label 
when the socket limit was set back to unlimited. The problem is that the 
sockets outlive the memcg, so we can only do that when the last 
reference count is dropped. It is worth mentioning that kmem controller 
for memcg will have the exact same problem - I am actually updating my 
series with all the results of this discussion here.

2) If, however, there are no sockets in flight, mem_cgroup_put() during
->destroy() will be the last one, and the decrementing will happen there.

3) static_key updates cannot happen with the cgroup_mutex held. This is
because cpusets hold it from within the cpu_hotplug.lock - that 
static_keys take through get_online_cpus() in its cpu hotplug handler.

4) Looking at the cpusets code, it really seems necessary, at least by now.

5) Deferring all this to worker threads as you suggested in the cpu 
thread - that has a similar problem - can solve this problem, but in 
general, will create tons of others, like windows of inconsistent 
information.

That's basically it.
