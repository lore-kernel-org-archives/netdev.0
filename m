From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net
Date: Wed, 5 Mar 2008 16:22:05 -0800
Message-ID: <20080306002205.GI8728@linux.vnet.ibm.com>
References: <47CE8FF7.7000701@openvz.org> <20080305191501.GF8728@linux.vnet.ibm.com> <m1ablc3eo3.fsf@ebiederm.dsl.xmission.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:48136 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbYCFAWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 19:22:07 -0500
Content-Disposition: inline
In-Reply-To: <m1ablc3eo3.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2008 at 04:59:56PM -0700, Eric W. Biederman wrote:
> >> 
> >> +static struct net *get_proc_task_net(struct inode *dir)
> >> +{
> >> +	struct task_struct *task;
> >> +	struct nsproxy *ns;
> >> +	struct net *net = NULL;
> >> +
> >> +	rcu_read_lock();
> >> +	task = get_proc_task(dir);
> >
> > This implies a get_task_struct(), as get_proc_task() invokes get_proc_task()
> > which invokes get_pid_task() which invokes get_task_struct().
> >
> > I don't see the corresponding put_task_struct() -- what am I missing here?
> 
> You aren't.  However we can easily make this:
> 	task = pid_task(proc_pid(dir), PIDTYPE_PID);
> And we won't need to increment the count on the task_struct.

That looks like it should do the trick!  And the net_get() below
will allow you to safely export the "net" pointer out of an RCU
read-side critical section, so with that change looks good to me!

						Thanx, Paul

> Good catch.
> 
> >> +	if (task != NULL) {
> >> +		ns = task_nsproxy(task);
> >> +		if (ns != NULL)
> >> +			net = get_net(ns->net_ns);
> >> +	}
> >> +	rcu_read_unlock();
> >> +
> >> +	return net;
> >> +}
> >> +
