From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [BUG] Bug in netprio_cgroup and netcls_cgroup ?
Date: Tue, 22 Jan 2013 11:09:38 +0100
Message-ID: <20130122100938.GA26820@candlejack.bmw-carit.intra>
References: <50FCDB5C.4050608@huawei.com>
 <50FD0144.1000401@monom.org>
 <50FD0402.6060400@huawei.com>
 <50FD09FD.4010804@monom.org>
 <50FD1113.6010402@huawei.com>
 <50FD786E.4050108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50FD786E.4050108-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 21, 2013 at 09:18:38AM -0800, John Fastabend wrote:
> On 01/21/2013 01:57 AM, Li Zefan wrote:
> > On 2013/1/21 17:27, Daniel Wagner wrote:
> >> On 21.01.2013 10:01, Li Zefan wrote:
> >>> On 2013/1/21 16:50, Daniel Wagner wrote:
> >>>> Hi Li,
> >>>>
> >>>> On 21.01.2013 07:08, Li Zefan wrote:
> >>>>> I'm not a network developer, so correct me if I'm wrong.
> >>>>>
> >>>>> Since commit 7955490f732c2b8
> >>>>> ("net: netprio_cgroup: rework update socket logic"), sock->sk->sk_cgrp_prioidx
> >>>>> is set when the socket is created, and won't be updated unless the task is
> >>>>> moved to another cgroup.
> >>>>>
> >>>>> Now the problem is, a socket can be _shared_ by multiple processes (fork, SCM_RIGHT).
> >>>>> If we place those processes in different cgroups, and each cgroup has
> >>>>> different configs, but all of the processes will send data via this socket
> >>>>> with the same network priority.
> >>>>
> >>>> Wouldn't that be addressed by 48a87cc26c13b68f6cce4e9d769fcb17a6b3e4b8
> >>>>
> >>>>      net: netprio: fd passed in SCM_RIGHTS datagram not set correctly
> >>>>
> >>>>       A socket fd passed in a SCM_RIGHTS datagram was not getting
> >>>>       updated with the new tasks cgrp prioidx. This leaves IO on
> >>>>       the socket tagged with the old tasks priority.
> >>>>
> >>>>       To fix this add a check in the scm recvmsg path to update the
> >>>>       sock cgrp prioidx with the new tasks value.
> >>>>
> >>>> As I read this this should work for net_prio.
> >>>>
> >>>
> >>> But after process A passed the socket fd to B, both A and B can use the
> >>> same socket to send data, right? Then if A and B were placed in different
> >>> cgroups with differnt configs, A's config won't take effect anymore.
> >>>
> >>> Am I missing something?
> >>
> >> I don't know. I guess at one point the socket resources are shared and then
> >> one configuration is taking preference. As you can see I am far away of
> >> being
> >> an expert in this field. Hopefully someone who understands this bits
> >> can chip in.
> >>
> >> BTW, isn't this a similar to what should happen with the block io cgroup?
> >> What is the behavior with a fd writing to a file in the scenario you
> >> describe above?
> >>
> > 
> > It forbids task moving in this case:
> > 
> > /*
> >   * We cannot support shared io contexts, as we have no mean to support
> >   * two tasks with the same ioc in two different groups without major rework
> >   * of the main cic data structures.  For now we allow a task to change
> >   * its cgroup only if it's the only owner of its ioc.
> >   */
> > static int blkcg_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
> > 
> 
> OK, I guess we should do something similar in the netprio, netcls
> cgroups and
> yes document it as you noted in your last comment.

Here is my attempt to add such a check. I really don't know if this is the
correct way to do so. To test this I have written a test program, which
seems to test the right thing. Please have a look and let me know if
it is correct: http://www.monom.org/misc/scm_rights.c

And here a dirty first version of the patch:


>From 49a78d907eaf31c16673025e7e3b4844e419e416 Mon Sep 17 00:00:00 2001
From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Date: Tue, 22 Jan 2013 11:08:22 +0100
Subject: [PATCH] net: net_prio: Block attach if a socket is shared

---
 net/core/netprio_cgroup.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 847c02b..de4e6c5 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -274,9 +274,39 @@ static struct cftype ss_files[] = {
 	{ }	/* terminate */
 };
 
+static int check_cnt(const void *v, struct file *file, unsigned n)
+{
+	unsigned *flag = (unsigned *)v;
+	int err;
+
+	struct socket *sock = sock_from_file(file, &err);
+	if (sock && file_count(file) > 1)
+		*flag = 1;
+
+	return 0;
+}
+
+static int cgrp_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
+{
+	struct task_struct *p;
+	unsigned flag = 0;
+
+	cgroup_taskset_for_each(p, cgrp, tset) {
+		task_lock(p);
+		iterate_fd(p->files, 0, check_cnt, &flag);
+		task_unlock(p);
+	}
+
+	if (flag != 0)
+		return -EINVAL;
+
+	return 0;
+}
+
 struct cgroup_subsys net_prio_subsys = {
 	.name		= "net_prio",
 	.create		= cgrp_create,
+	.can_attach	= cgrp_can_attach,
 	.destroy	= cgrp_destroy,
 	.attach		= net_prio_attach,
 	.subsys_id	= net_prio_subsys_id,
-- 
1.8.0.rc0
