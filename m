From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 16/16] net: netlink support for moving devices between network namespaces.
Date: Mon, 10 Sep 2007 13:30:46 -0600
Message-ID: <m1fy1me2s9.fsf@ebiederm.dsl.xmission.com>
References: <m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl5ovolm.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odgcvoje.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5r0voh4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fy1ovoeo.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bqccvock.fsf_-_@ebiederm.dsl.xmission.com>
	<m17in0vo0d.fsf_-_@ebiederm.dsl.xmission.com>
	<m13axovnyf.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7fgu9ax.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzq4u92n.fsf_-_@ebiederm.dsl.xmission.com>
	<20070910190708.GA6872@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:56544 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932811AbXIJTgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 15:36:55 -0400
In-Reply-To: <20070910190708.GA6872@sergelap.austin.ibm.com> (Serge
	E. Hallyn's message of "Mon, 10 Sep 2007 14:07:08 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:
>> 
>> +static struct net *get_net_ns_by_pid(pid_t pid)
>> +{
>> +	struct task_struct *tsk;
>> +	struct net *net;
>> +
>> +	/* Lookup the network namespace */
>> +	net = ERR_PTR(-ESRCH);
>> +	rcu_read_lock();
>> +	tsk = find_task_by_pid(pid);
>> +	if (tsk) {
>> +		task_lock(tsk);
>> +		if (tsk->nsproxy)
>> +			net = get_net(tsk->nsproxy->net_ns);
>> +		task_unlock(tsk);
>
> Thinking...  Ok, I'm not sure this is 100% safe in the target tree, but
> the long-term correct way probably isn't yet implemented in the net-
> tree.  Eventually you will want to:
>
> 	net_ns = NULL;
> 	rcu_read_lock();
> 	tsk = find_task_by_pid();  /* or _pidns equiv? */
> 	nsproxy = task_nsproxy(tsk);
> 	if (nsproxy)
> 		net_ns = get_net(nsproxy->net_ns);
> 	rcu_read_unlock;
>
> What you have here is probably unsafe if tsk is the last task pointing
> to it's nsproxy and it does an unshare, bc unshare isn't protected by
> task_lock, and you're not rcu_dereferencing tsk->nsproxy (which
> task_nsproxy does).  At one point we floated a patch to reuse the same
> nsproxy in that case which would prevent you having to worry about it,
> but that isn't being done in -mm now so i doubt it's in -net.


That change isn't merged upstream yet, so it isn't in David's
net-2.6.24 tree.  Currently task->nsproxy is protected but
task_lock(current). So the code is fine.

I am aware that removing the task_lock(current) for the setting
of current->nsproxy is currently in the works, and I have planned
to revisit this later when all of these pieces come together.

For now the code is fine.

If need be we can drop this patch to remove the potential merge
conflict.  But I figured it was useful for this part of the user space
interface to be available for review.

Eric
