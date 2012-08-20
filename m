From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v1 3/5] cgroup: Protect access to task_cls_classid() when
 built as module
Date: Mon, 20 Aug 2012 13:03:42 -0400
Message-ID: <20120820170342.GC1734@hmsreliant.think-freely.org>
References: <1345215494-9181-1-git-send-email-wagi@monom.org>
 <1345215494-9181-4-git-send-email-wagi@monom.org>
 <20120817182855.GA11607@hmsreliant.think-freely.org>
 <20120820112938.GA22415@candlejack.bmw-carit.intra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120820112938.GA22415-rjQKm2AMs/APuY3F5OKgMy7zKzJi9e1+kcYEyfhdaNw@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 20, 2012 at 01:29:38PM +0200, Daniel Wagner wrote:
> On Fri, Aug 17, 2012 at 02:28:55PM -0400, Neil Horman wrote:
> > On Fri, Aug 17, 2012 at 04:58:12PM +0200, Daniel Wagner wrote:
> > > From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> > > 
> > > The module version of task_cls_classid() checks if net_cls_sbusys_id
> > > is valid to indentify when it is okay to access the controller.
> > > 
> > > Instead relying on the subusys_id to be set, make it explicit
> > > with a jump label.
> > > 
> > > Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> > > Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > > Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> > > Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
> > > Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > > Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> > > Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> > > Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > > Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > > Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > > ---
> > >  include/net/cls_cgroup.h | 5 ++++-
> > >  net/core/sock.c          | 5 +++++
> > >  net/sched/cls_cgroup.c   | 9 +++++++++
> > >  3 files changed, 18 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
> > > index 401672c..bbbd957 100644
> > > --- a/include/net/cls_cgroup.h
> > > +++ b/include/net/cls_cgroup.h
> > > @@ -16,6 +16,7 @@
> > >  #include <linux/cgroup.h>
> > >  #include <linux/hardirq.h>
> > >  #include <linux/rcupdate.h>
> > > +#include <linux/jump_label.h>
> > >  
> > >  #ifdef CONFIG_CGROUPS
> > >  struct cgroup_cls_state
> > > @@ -44,6 +45,8 @@ static inline u32 task_cls_classid(struct task_struct *p)
> > >  }
> > >  
> > >  #elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
> > > +extern struct static_key cgroup_cls_enabled;
> > > +#define clscg_enabled static_key_false(&cgroup_cls_enabled)
> > >  
> > >  extern int net_cls_subsys_id;
> > >  
> > > @@ -52,7 +55,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
> > >  	int id;
> > >  	u32 classid = 0;
> > >  
> > > -	if (in_interrupt())
> > > +	if (!clscg_enabled || in_interrupt())
> > >  		return 0;
> > >  
> > >  	rcu_read_lock();
> > > diff --git a/net/core/sock.c b/net/core/sock.c
> > > index 8f67ced..8106e77 100644
> > > --- a/net/core/sock.c
> > > +++ b/net/core/sock.c
> > > @@ -327,6 +327,11 @@ int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
> > >  EXPORT_SYMBOL(__sk_backlog_rcv);
> > >  
> > >  #if defined(CONFIG_CGROUPS)
> > > +#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
> > > +struct static_key cgroup_cls_enabled = STATIC_KEY_INIT_FALSE;
> > > +EXPORT_SYMBOL_GPL(cgroup_cls_enabled);
> > > +#endif
> > > +
> > >  #if !defined(CONFIG_NET_CLS_CGROUP)
> > >  int net_cls_subsys_id = -1;
> > >  EXPORT_SYMBOL_GPL(net_cls_subsys_id);
> > > diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> > > index 7743ea8..0635894 100644
> > > --- a/net/sched/cls_cgroup.c
> > > +++ b/net/sched/cls_cgroup.c
> > > @@ -44,12 +44,21 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
> > >  
> > >  	if (cgrp->parent)
> > >  		cs->classid = cgrp_cls_state(cgrp->parent)->classid;
> > > +#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
> > > +	else if (!clscg_enabled)
> > > +                static_key_slow_inc(&cgroup_cls_enabled);
> > This is racy I think.  The read of the static key is atomic with other reads,
> > but the entire conditional is not atomic.  If two cpus were creating cgroups in
> > parallel, it would be possible for both to read the static key as being zero
> > (the second cpu would read the key before the first cpu could increment it).
> 
> D'oh, That is racy.
> 
> > > +#endif
> > >  
> > >  	return &cs->css;
> > >  }
> > >  
> > >  static void cgrp_destroy(struct cgroup *cgrp)
> > >  {
> > > +#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
> > > +	if (!cgrp->parent && clscg_enabled)
> > > +                static_key_slow_dec(&cgroup_cls_enabled);
> > Ditto here with the race above.  I think what you want is one of:
> > 
> > 1) Use static_key_slow_[inc|dec] unconditionally 
> 
> While the static_key_slow_inc() case will work, I am not so sure about
> the static_key_slow_dec(), e.g. we could still access inside
> task_cls_classid() a destroyed container.
> 
Possibly, yes, I think.

> > 2) Keep a separate internal counter to track the number of cgroup instances
> > so that you only inc the static key on the first create and dec it on the last
> > delete.
> 
> If I got you right, than this would not be different then direclty using
> static_key_slow_[inc|dec].
> 
As long as a cgroup subsystems ->destroy method is only called when the
subsystem is being removed, then I think thats correct.  I'm not 100% sure thats
the case though.

> > I would think (1) would be sufficent.  It looks like static_key_slow_inc uses
> > atomic_inc_not_zero to just do an inc anyway in the event that multiple inc
> > events are made.
> 
> Would something like this work?
> 
I think so yes, assuming that you also make the slow_inc|dec changes

> static inline u32 task_cls_classid(struct task_struct *p)
> {
> 	u32 classid;
> 	struct cgroup_cls_state *css;
> 
> 	if (!clscg_enabled || in_interrupt())
> 		return 0;
> 
> 	rcu_read_lock();
> 	css = container_of(task_subsys_state(p, net_cls_subsys_id),
> 			   struct cgroup_cls_state, css);
> 	if (!css)
> 		classid = css->classid;
> 	else
> 		classid = 0;
> 	rcu_read_unlock();
> 
> 	return classid;
> }
> 
> Daniel
> 
