From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 3/5] change number_of_cpusets to an atomic
Date: Tue, 24 Apr 2012 13:30:05 -0300
Message-ID: <4F96D50D.4020804@parallels.com>
References: <1335209867-1831-1-git-send-email-glommer@parallels.com> <1335209867-1831-4-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1204241001050.26005@router.home> <4F96D1A8.6040604@parallels.com> <alpine.DEB.2.00.1204241120130.26005@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1204241120130.26005-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/24/2012 01:24 PM, Christoph Lameter wrote:
> On Tue, 24 Apr 2012, Glauber Costa wrote:
>
>>> Would this not also be a good case to introduce static branching?
>>>
>>> number_of_cpusets is used to avoid going through unnecessary processing
>>> should there be no cpusets in use.
>>
>> static branches comes with a set of problems themselves, so I usually prefer
>> to use them only in places where we don't want to pay even a cache miss if we
>> can avoid, or a function call, or anything like that - like the slub cache
>> alloc as you may have seen in my kmem memcg series.
>>
>> It doesn't seem to be the case here.
>
> How did you figure that? number_of_cpusets was introduced exactly because
> the functions are used in places where we do not pay the cost of calling
> __cpuset_node_allowed_soft/hardwall. Have a look at these. They may take
> locks etc etc in critical allocation paths
I am not arguing that.

You want to avoid the cost of processing a function, that's fair.
(Note that by "function call cost" I don't mean the cost of processing a 
function, but the cost of a (potentially empty) function call.)
The real question is: Are you okay with the cost of a branch + a global 
variable (which is almost read only) fetch?

The test of a global variable can - and do as of right now - avoid all 
the expensive operations like locking, sleeping, etc, and if you don't 
need to squeeze every nanosecond you can, they are often simpler - and 
therefore better - than static branching.

Just to mention one point I am coming across these days - that initiated 
all this: static patching holds the cpu_hotplug.lock. So it can't be 
called if you hold any lock that has been already held under the 
cpu_hotplug.lock. This will probably mean any lock the cpuset cgroup 
needs to take, because it is called - and to do a lot of things - from 
the cpu hotplug handler, that holds the cpu_hotplug.lock.

So if if were a case of simple static branch usage, I am not opposed to 
it. But I foresee it getting so complicated, that a global variable 
seems to do the job we need just fine.
