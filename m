From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v1 3/5] cgroup: Protect access to task_cls_classid() when
 built as module
Date: Thu, 23 Aug 2012 11:12:28 +0200
Message-ID: <5035F3FC.202@monom.org>
References: <1345215494-9181-1-git-send-email-wagi@monom.org> <1345215494-9181-4-git-send-email-wagi@monom.org> <20120817182855.GA11607@hmsreliant.think-freely.org> <20120820112938.GA22415@candlejack.bmw-carit.intra> <20120820170342.GC1734@hmsreliant.think-freely.org> <50335101.5030109@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50335101.5030109-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 21.08.2012 11:12, Glauber Costa wrote:
> On 08/20/2012 09:03 PM, Neil Horman wrote:
>>>> 2) Keep a separate internal counter to track the number of cgroup instances
>>>>>> so that you only inc the static key on the first create and dec it on the last
>>>>>> delete.
>>>>
>>>> If I got you right, than this would not be different then direclty using
>>>> static_key_slow_[inc|dec].
>>>>
>> As long as a cgroup subsystems ->destroy method is only called when the
>> subsystem is being removed, then I think thats correct.  I'm not 100% sure thats
>> the case though.
>>
> THAT is correct, but not the call itself. ->destroy() is called with the
> cgroup_lock held, and there is a lockdep dependency created by cpuset
> that prevents the cpu_hotplug lock, taken by static branch updates, to
> be taken inside cgroup_lock.
>
> So unless cpuset is fixed - which is a major work, we can't do
> static_branch updates while holding the cgroup_lock.

Thanks a lot for the info on this problem. I have spend the last days 
trying to figure out how you have solved this in memcg. It looks like 
complex and fragile. So I rather avoid enabling/disabling the static 
branch in cgrp_create()/cgroup_destroy() and do it on module init/exit 
as it is done currently with the id assigment.

Initially I wanted to optimize the task_cls_classid() path, so that only
when a cgroup really exists we spent time in there. Though as soon the 
controller is registered to the cgroup core, the code path is enabled. 
That means when cls is builtin it is used all the time (even though no 
one is using it). In the module case, it is the same. task_cls_classid() 
path is used right after module init.

So there is no need to move the enabling/disabling of the static branch 
at this point to create/destroy.
