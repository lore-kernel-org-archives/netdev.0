From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 16/16] net: netlink support for moving devices between
	network namespaces.
Date: Mon, 10 Sep 2007 19:54:04 -0500
Message-ID: <20070911005404.GA19808@sergelap.austin.ibm.com>
References: <m1odgcvoje.fsf_-_@ebiederm.dsl.xmission.com> <m1k5r0voh4.fsf_-_@ebiederm.dsl.xmission.com> <m1fy1ovoeo.fsf_-_@ebiederm.dsl.xmission.com> <m1bqccvock.fsf_-_@ebiederm.dsl.xmission.com> <m17in0vo0d.fsf_-_@ebiederm.dsl.xmission.com> <m13axovnyf.fsf_-_@ebiederm.dsl.xmission.com> <m1y7fgu9ax.fsf_-_@ebiederm.dsl.xmission.com> <m1tzq4u92n.fsf_-_@ebiederm.dsl.xmission.com> <20070910190708.GA6872@sergelap.austin.ibm.com> <m1fy1me2s9.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:36103 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754312AbXIKAyD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 20:54:03 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8B0tSU4007738
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 20:55:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8B0s25l542606
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 20:54:02 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8B0s2fk023763
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 20:54:02 -0400
Content-Disposition: inline
In-Reply-To: <m1fy1me2s9.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> "Serge E. Hallyn" <serue@us.ibm.com> writes:
> >> 
> >> +static struct net *get_net_ns_by_pid(pid_t pid)
> >> +{
> >> +	struct task_struct *tsk;
> >> +	struct net *net;
> >> +
> >> +	/* Lookup the network namespace */
> >> +	net = ERR_PTR(-ESRCH);
> >> +	rcu_read_lock();
> >> +	tsk = find_task_by_pid(pid);
> >> +	if (tsk) {
> >> +		task_lock(tsk);
> >> +		if (tsk->nsproxy)
> >> +			net = get_net(tsk->nsproxy->net_ns);
> >> +		task_unlock(tsk);
> >
> > Thinking...  Ok, I'm not sure this is 100% safe in the target tree, but
> > the long-term correct way probably isn't yet implemented in the net-
> > tree.  Eventually you will want to:
> >
> > 	net_ns = NULL;
> > 	rcu_read_lock();
> > 	tsk = find_task_by_pid();  /* or _pidns equiv? */
> > 	nsproxy = task_nsproxy(tsk);
> > 	if (nsproxy)
> > 		net_ns = get_net(nsproxy->net_ns);
> > 	rcu_read_unlock;
> >
> > What you have here is probably unsafe if tsk is the last task pointing
> > to it's nsproxy and it does an unshare, bc unshare isn't protected by
> > task_lock, and you're not rcu_dereferencing tsk->nsproxy (which
> > task_nsproxy does).  At one point we floated a patch to reuse the same
> > nsproxy in that case which would prevent you having to worry about it,
> > but that isn't being done in -mm now so i doubt it's in -net.
> 
> 
> That change isn't merged upstream yet, so it isn't in David's
> net-2.6.24 tree.  Currently task->nsproxy is protected but
> task_lock(current). So the code is fine.
> 
> I am aware that removing the task_lock(current) for the setting
> of current->nsproxy is currently in the works, and I have planned
> to revisit this later when all of these pieces come together.
> 
> For now the code is fine.
> 
> If need be we can drop this patch to remove the potential merge
> conflict.

No, no.  Like you say it's correct at the moment.  Just something we
need to watch out for when it does get merged with the newer changes.

> But I figured it was useful

Absolutely.

> for this part of the user space
> interface to be available for review.

Agreed.  And the rest of the patchset looks good to me.

Thanks.

-serge
