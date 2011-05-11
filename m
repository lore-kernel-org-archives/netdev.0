From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/7] ns proc: Add support for the network namespace.
Date: Wed, 11 May 2011 14:34:37 -0700
Message-ID: <m139kkncpe.fsf@fess.ebiederm.org>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<1304735101-1824-1-git-send-email-ebiederm@xmission.com>
	<1304735101-1824-3-git-send-email-ebiederm@xmission.com>
	<1305141705.1236.49.camel@orca.stoopid.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: Nathan Lynch <ntl@pobox.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1305141705.1236.49.camel@orca.stoopid.dyndns.org> (Nathan
	Lynch's message of "Wed, 11 May 2011 14:21:34 -0500")
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nathan Lynch <ntl@pobox.com> writes:

> On Fri, 2011-05-06 at 19:24 -0700, Eric W. Biederman wrote:
>> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>> index 3f86026..bf7707e 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -573,3 +573,34 @@ void unregister_pernet_device(struct pernet_operations *ops)
>>  	mutex_unlock(&net_mutex);
>>  }
>>  EXPORT_SYMBOL_GPL(unregister_pernet_device);
>> +
>> +#ifdef CONFIG_NET_NS
>> +static void *netns_get(struct task_struct *task)
>> +{
>> +	struct net *net;
>> +	rcu_read_lock();
>> +	net = get_net(task->nsproxy->net_ns);
>
> This should use task_nsproxy() and check the result before grabbing the
> net_ns, but I think you fix that in a later patch.
>
> Regardless, it looks as if all the proc_ns_ops->get() implementations
> really just want the nsproxy, so maybe the get() methods should take
> that instead of the task_struct, and proc_ns_instantiate() should do
> something like:
>
> struct nsproxy *nsproxy;
> ...
>
> ei->ns_ops = ns_ops;
> error = -ESRCH;
> rcu_read_lock();
> nsproxy = task_nsproxy(task);
> rcu_read_unlock();
> if (!nsproxy)
> 	got out;
> ei->ns = ns_ops->get(nsproxy);
>
>
> So then the zombie check is consolidated in one place instead of having
> to do it in every get() method.

For the pid namespace at least I want the task not the nsproxy,
so I can use task_active_pid_namespace().

I admit that is a little asymmetrical with the install, but at
least until the details of getting the pid namespace working in
this context are worked out I don't want to reconsider the
current design.

There is also the user namespace that does not even exist in
nsproxy to consider.  I will worry about that namespace when
it happens.

Ultimately nsproxy is an space/time optimization that not all
namespaces use so forcing it in the design is probably not
what we want.

>> +	rcu_read_unlock();
>> +	return net;
>> +}
>> +
>> +static void netns_put(void *ns)
>> +{
>> +	put_net(ns);
>> +}
>> +
>> +static int netns_install(struct nsproxy *nsproxy, void *ns)
>> +{
>> +	put_net(nsproxy->net_ns);
>> +	nsproxy->net_ns = get_net(ns);
>> +	return 0;
>> +}
>
> This introduces a window where, potentially, nsproxy->net_ns is stale
> before it is updated with the namespace which is being attached, no? 
> (Same concern applies to other install methods in the patch set).  It
> seems possible to oops the kernel in this window by looking up
> /proc/$PID/ns/net while $PID is in the midst of setns().

Except the nsproxy being referred to is a brand new nsproxy, with an
extra reference count on every namespace.  current->nsproxy still
contains the reference counts of the current process.

Eric
