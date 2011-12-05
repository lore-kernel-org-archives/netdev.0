From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v7 10/10] Disable task moving when using kernel memory
 accounting
Date: Mon, 5 Dec 2011 11:18:35 +0900
Message-ID: <20111205111835.b1432603.kamezawa.hiroyu@jp.fujitsu.com>
References: <1322611021-1730-1-git-send-email-glommer@parallels.com>
	<1322611021-1730-11-git-send-email-glommer@parallels.com>
	<20111130112210.1d979512.kamezawa.hiroyu@jp.fujitsu.com>
	<4ED914EC.6020500@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>,
	<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>, <avagin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ED914EC.6020500-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Dec 2011 16:11:56 -0200
Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> On 11/30/2011 12:22 AM, KAMEZAWA Hiroyuki wrote:
> > On Tue, 29 Nov 2011 21:57:01 -0200
> > Glauber Costa<glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>  wrote:
> >
> >> Since this code is still experimental, we are leaving the exact
> >> details of how to move tasks between cgroups when kernel memory
> >> accounting is used as future work.
> >>
> >> For now, we simply disallow movement if there are any pending
> >> accounted memory.
> >>
> >> Signed-off-by: Glauber Costa<glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> >> CC: Hiroyouki Kamezawa<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> >> ---
> >>   mm/memcontrol.c |   23 ++++++++++++++++++++++-
> >>   1 files changed, 22 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index a31a278..dd9a6d9 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -5453,10 +5453,19 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> >>   {
> >>   	int ret = 0;
> >>   	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
> >> +	struct mem_cgroup *from = mem_cgroup_from_task(p);
> >> +
> >> +#if defined(CONFIG_CGROUP_MEM_RES_CTLR_KMEM)&&  defined(CONFIG_INET)
> >> +	if (from != memcg&&  !mem_cgroup_is_root(from)&&
> >> +	    res_counter_read_u64(&from->tcp_mem.tcp_memory_allocated, RES_USAGE)) {
> >> +		printk(KERN_WARNING "Can't move tasks between cgroups: "
> >> +			"Kernel memory held.\n");
> >> +		return 1;
> >> +	}
> >> +#endif
> >
> > I wonder....reading all codes again, this is incorrect check.
> >
> > Hm, let me cralify. IIUC, in old code, "prevent moving" is because you hold
> > reference count of cgroup, which can cause trouble at rmdir() as leaking refcnt.
> right.
> 
> > BTW, because socket is a shared resource between cgroup, changes in mm->owner
> > may cause task cgroup moving implicitly. So, if you allow leak of resource
> > here, I guess... you can take mem_cgroup_get() refcnt which is memcg-local and
> > allow rmdir(). Then, this limitation may disappear.
> 
> Sorry, I didn't fully understand. Can you clarify further?
> If the task is implicitly moved, it will end up calling can_attach as 
> well, right?
> 
I'm sorry that my explanation is bad.

You can take memory cgroup itself's reference count by mem_cgroup_put/get.
By getting this, memory cgroup object will continue to exist even after
its struct cgroup* is freed by rmdir().

So, assume you do mem_cgroup_get()/put at socket attaching/detatching.

0) A task has a tcp socekts in memcg0.

task(memcg0)
 +- socket0 --> memcg0,usage=4096

1) move this task to memcg1

task(memcg1)
 +- socket0 --> memcg0,usage=4096

2) The task create a new socket.

task(memcg1)
 +- socekt0 --> memcg0,usage=4096 
 +- socket1 --> memcg1,usage=xxxx

Here, the task will hold 4096bytes of usage in memcg0 implicitly.

3) an admin removes memcg0
task(memcg1)
 +- socket0 -->memcg0, usage=4096 <-----(*)
 +- socket1 -->memcg1, usage=xxxx

(*) is invisible to users....but this will not be very big problem.

Thanks,
-Kame











Thanks,
-Kame






--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
