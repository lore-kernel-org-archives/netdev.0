From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v1 3/5] cgroup: Protect access to task_cls_classid() when
 built as module
Date: Mon, 20 Aug 2012 07:08:19 -0400
Message-ID: <20120820110819.GA1734@hmsreliant.think-freely.org>
References: <1345215494-9181-1-git-send-email-wagi@monom.org>
 <1345215494-9181-4-git-send-email-wagi@monom.org>
 <20120817182855.GA11607@hmsreliant.think-freely.org>
 <50318BF9.2080803@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50318BF9.2080803-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 20, 2012 at 08:59:37AM +0800, Li Zefan wrote:
> =E4=BA=8E 2012/8/18 2:28, Neil Horman =E5=86=99=E9=81=93:
> > On Fri, Aug 17, 2012 at 04:58:12PM +0200, Daniel Wagner wrote:
> >> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> >>
> >> The module version of task_cls_classid() checks if net_cls_sbusys_=
id
> >> is valid to indentify when it is okay to access the controller.
> >>
> >> Instead relying on the subusys_id to be set, make it explicit
> >> with a jump label.
> >>
> >> Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
> >> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> >> Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> >> Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
> >> Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> >> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >> Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> >> Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> >> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >> Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >> ---
> >>  include/net/cls_cgroup.h | 5 ++++-
> >>  net/core/sock.c          | 5 +++++
> >>  net/sched/cls_cgroup.c   | 9 +++++++++
> >>  3 files changed, 18 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
> >> index 401672c..bbbd957 100644
> >> --- a/include/net/cls_cgroup.h
> >> +++ b/include/net/cls_cgroup.h
> >> @@ -16,6 +16,7 @@
> >>  #include <linux/cgroup.h>
> >>  #include <linux/hardirq.h>
> >>  #include <linux/rcupdate.h>
> >> +#include <linux/jump_label.h>
> >> =20
> >>  #ifdef CONFIG_CGROUPS
> >>  struct cgroup_cls_state
> >> @@ -44,6 +45,8 @@ static inline u32 task_cls_classid(struct task_s=
truct *p)
> >>  }
> >> =20
> >>  #elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
> >> +extern struct static_key cgroup_cls_enabled;
> >> +#define clscg_enabled static_key_false(&cgroup_cls_enabled)
> >> =20
> >>  extern int net_cls_subsys_id;
> >> =20
> >> @@ -52,7 +55,7 @@ static inline u32 task_cls_classid(struct task_s=
truct *p)
> >>  	int id;
> >>  	u32 classid =3D 0;
> >> =20
> >> -	if (in_interrupt())
> >> +	if (!clscg_enabled || in_interrupt())
> >>  		return 0;
> >> =20
> >>  	rcu_read_lock();
> >> diff --git a/net/core/sock.c b/net/core/sock.c
> >> index 8f67ced..8106e77 100644
> >> --- a/net/core/sock.c
> >> +++ b/net/core/sock.c
> >> @@ -327,6 +327,11 @@ int __sk_backlog_rcv(struct sock *sk, struct =
sk_buff *skb)
> >>  EXPORT_SYMBOL(__sk_backlog_rcv);
> >> =20
> >>  #if defined(CONFIG_CGROUPS)
> >> +#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
> >> +struct static_key cgroup_cls_enabled =3D STATIC_KEY_INIT_FALSE;
> >> +EXPORT_SYMBOL_GPL(cgroup_cls_enabled);
> >> +#endif
> >> +
> >>  #if !defined(CONFIG_NET_CLS_CGROUP)
> >>  int net_cls_subsys_id =3D -1;
> >>  EXPORT_SYMBOL_GPL(net_cls_subsys_id);
> >> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> >> index 7743ea8..0635894 100644
> >> --- a/net/sched/cls_cgroup.c
> >> +++ b/net/sched/cls_cgroup.c
> >> @@ -44,12 +44,21 @@ static struct cgroup_subsys_state *cgrp_create=
(struct cgroup *cgrp)
> >> =20
> >>  	if (cgrp->parent)
> >>  		cs->classid =3D cgrp_cls_state(cgrp->parent)->classid;
> >> +#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
> >> +	else if (!clscg_enabled)
> >> +                static_key_slow_inc(&cgroup_cls_enabled);
> > This is racy I think.  The read of the static key is atomic with ot=
her reads,
> > but the entire conditional is not atomic.  If two cpus were creatin=
g cgroups in
> > parallel, it would be possible for both to read the static key as b=
eing zero
> > (the second cpu would read the key before the first cpu could incre=
ment it).
>=20
> static_key_slow_inc() is called only when we're creating the root cgr=
oup, and that's
> module loading.
>=20
> so it's safe.
>=20
What makes you say that?  It appears to me that we call ss->create (and
potential ss->destroy, depending on failure conditions) from cgroup_cre=
ate,
which in turn is called from cgroup_mkdir, which is called for every cg=
roup
instance created, not just the root cgroup.

Neil
