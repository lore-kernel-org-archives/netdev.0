From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/7] ns: Introduce the setns syscall
Date: Wed, 11 May 2011 13:33:48 -0700
Message-ID: <m1fwolnfir.fsf@fess.ebiederm.org>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<1304735101-1824-1-git-send-email-ebiederm@xmission.com>
	<1304735101-1824-2-git-send-email-ebiederm@xmission.com>
	<1305141681.1236.48.camel@orca.stoopid.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	linux-fsdevel@vger.kernel.org
To: Nathan Lynch <ntl@pobox.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1305141681.1236.48.camel@orca.stoopid.dyndns.org> (Nathan
	Lynch's message of "Wed, 11 May 2011 14:21:14 -0500")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nathan Lynch <ntl@pobox.com> writes:

> Hi Eric,
>
> On Fri, 2011-05-06 at 19:24 -0700, Eric W. Biederman wrote:
>> With the networking stack today there is demand to handle
>> multiple network stacks at a time.  Not in the context
>> of containers but in the context of people doing interesting
>> things with routing.
>> 
>> There is also demand in the context of containers to have
>> an efficient way to execute some code in the container itself.
>> If nothing else it is very useful ad a debugging technique.
>> 
>> Both problems can be solved by starting some form of login
>> daemon in the namespaces people want access to, or you
>> can play games by ptracing a process and getting the
>> traced process to do things you want it to do. However
>> it turns out that a login daemon or a ptrace puppet
>> controller are more code, they are more prone to
>> failure, and generally they are less efficient than
>> simply changing the namespace of a process to a
>> specified one.
>> 
>> Pieces of this puzzle can also be solved by instead of
>> coming up with a general purpose system call coming up
>> with targed system calls perhaps socketat that solve
>> a subset of the larger problem.  Overall that appears
>> to be more work for less reward.
>> 
>> int setns(int fd, int nstype);
>> 
>> The fd argument is a file descriptor referring to a proc
>> file of the namespace you want to switch the process to.
>> 
>> In the setns system call the nstype is 0 or specifies
>> an clone flag of the namespace you intend to change
>> to prevent changing a namespace unintentionally.
>
> I don't understand exactly what the nstype argument buys us - why would
> correct code ever need to specify a value other than 0?  And reusing the
> CLONE_NEW* values in this interface is kind of ugly when setns is
> precisely _not_ creating new namespaces.

No but it is setting a new namespace.  I do agree it is a bit ugly.  But
the worst case at this point is I introduce a new set of beautiful
defines with the same values.

> Is there some fundamental reason it couldn't be
>
> int setns(int fd);
>
> or is there a use case I'm missing?

When someone else opens the file descriptor and passes it to us
and we don't completely trust them.  Or equally when someone
else does the bind mount into the filesystem namespace and we
don't completely trust them.

Plus having a flags field is useful in general.

>> +SYSCALL_DEFINE2(setns, int, fd, int, nstype)
>> +{
>> +	const struct proc_ns_operations *ops;
>> +	struct task_struct *tsk = current;
>> +	struct nsproxy *new_nsproxy;
>> +	struct proc_inode *ei;
>> +	struct file *file;
>> +	int err;
>> +
>> +	if (!capable(CAP_SYS_ADMIN))
>> +		return -EPERM;
>> +
>> +	file = proc_ns_fget(fd);
>> +	if (IS_ERR(file))
>> +		return PTR_ERR(file);
>> +
>> +	err = -EINVAL;
>> +	ei = PROC_I(file->f_dentry->d_inode);
>> +	ops = ei->ns_ops;
>> +	if (nstype && (ops->type != nstype))
>> +		goto out;
>> +
>> +	new_nsproxy = create_new_namespaces(0, tsk, tsk->fs);
>
> create_new_namespaces() can fail; shouldn't this be checked?

Yes.  This was pointed out a little earlier and has been fixed
in my tree.


>> +	err = ops->install(new_nsproxy, ei->ns);
>> +	if (err) {
>> +		free_nsproxy(new_nsproxy);
>> +		goto out;
>> +	}
>> +	switch_task_namespaces(tsk, new_nsproxy);
>> +out:
>> +	fput(file);
>> +	return err;
>> +}
>> +

Eric
