From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: 2.6.23-mm1 thread exit_group issue
Date: Sat, 13 Oct 2007 15:48:20 +0400
Message-ID: <20071013114820.GA121@tv-sign.ru>
References: <20071011213126.cf92efb7.akpm@linux-foundation.org> <20071012140328.f82af8e8.kamezawa.hiroyu@jp.fujitsu.com> <20071011234202.2f15bb76.akpm@linux-foundation.org> <20071012064658.GA8181@ftp.linux.org.uk> <20071012001325.ba02a6f0.akpm@linux-foundation.org> <20071012194759.GA31733@Krystal> <20071012180349.b4b4c2c3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	viro@ftp.linux.org.uk, kamezawa.hiroyu@jp.fujitsu.com,
	linux-kernel@vger.kernel.org, sam@ravnborg.org,
	netdev@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
	Sukadev Bhattiprolu <sukadev@us.ibm.com>,
	Paul Menage <menage@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x346.tv-sign.ru ([89.108.83.215]:41611 "EHLO mail.screens.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338AbXJMNDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 09:03:53 -0400
Content-Disposition: inline
In-Reply-To: <20071012180349.b4b4c2c3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12, Andrew Morton wrote:
>
> On Fri, 12 Oct 2007 15:47:59 -0400
> Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
> 
> > Hi Andrew,
> > 
> > I noticed a regression between 2.6.23-rc8-mm2 and 2.6.23-mm1 (with your
> > hotfixes). User space threads seems to receive a ERESTART_RESTARTBLOCK
> > as soon as a thread does a pthread_join on them. The previous behavior
> > was to wait for them to exit by taking a futex.

No, the reason is that pthread_join() succeeds while it shouldn't. The main
thread does exit_group() and kills the sub-thread sleeping in nanosleep.
ERESTART_RESTARTBLOCK is not delivered to the user-space (sub-thread is dying),
it is just reported by gdb.

> > I provide a toy program that shows the problem. On 2.6.23-rc8-mm2, it
> > loops forever (as it should). On 2.6.23-mm1, it exits after 10 seconds.

I bet something like this

	void *threda(void *arg)
	{
		for (;;)
			pause();
		return NULL;
	}

	int main(void)
	{
		pthread_t tid;

		pthread_create(&tid, NULL, thread, NULL);
		pthread_join(tid, NULL);

		return 0;
	}

won't work as well.

> > Any idea on what may cause this problem ?

Because do_fork() doesn't use parent_tidptr. At all! So it is very clear
why 2.6.23-mm1 is broken.

> Bisection shows that this problem is caused by these two patches:
>
> pid-namespaces-allow-cloning-of-new-namespace.patch

This? http://marc.info/?l=linux-mm-commits&m=118712242002039

Pavel, this patch has a subtle difference compared to what we discussed on
containers list. It moves put_user(parent_tidptr) from copy_process() to
do_fork(), so we don't report child's pid if copy_process() failed. I do
not think this is bad, but Eric seems to disagree with such a change.

But I can't understand why Andrew sees the same problem _after_ this patch!

And which patch removed the "put_user(nr, parent_tidptr)" chunk?

Andrew, could I get the kernel source after bisection somehow? (I am not
familiar with guilt, will try to study it later)

Mathieu, could you try the patch below?

Oleg.

--- kernel/fork.c~	2007-10-13 15:41:35.000000000 +0400
+++ kernel/fork.c	2007-10-13 15:41:41.000000000 +0400
@@ -1443,6 +1443,9 @@ long do_fork(unsigned long clone_flags,
 			task_pid_nr_ns(p, current->nsproxy->pid_ns) :
 				task_pid_vnr(p);
 
+		if (clone_flags & CLONE_PARENT_SETTID)
+			put_user(nr, parent_tidptr);
+
 		if (clone_flags & CLONE_VFORK) {
 			p->vfork_done = &vfork;
 			init_completion(&vfork);

