From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Make /proc/net a symlink on /proc/self/net
Date: Wed, 05 Mar 2008 16:59:56 -0700
Message-ID: <m1ablc3eo3.fsf@ebiederm.dsl.xmission.com>
References: <47CE8FF7.7000701@openvz.org>
	<20080305191501.GF8728@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Dobriyan <adobriyan@openvz.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760994AbYCFAD3@vger.kernel.org>
In-Reply-To: <20080305191501.GF8728@linux.vnet.ibm.com> (Paul E. McKenney's
	message of "Wed, 5 Mar 2008 11:15:01 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> 
>> +static struct net *get_proc_task_net(struct inode *dir)
>> +{
>> +	struct task_struct *task;
>> +	struct nsproxy *ns;
>> +	struct net *net = NULL;
>> +
>> +	rcu_read_lock();
>> +	task = get_proc_task(dir);
>
> This implies a get_task_struct(), as get_proc_task() invokes get_proc_task()
> which invokes get_pid_task() which invokes get_task_struct().
>
> I don't see the corresponding put_task_struct() -- what am I missing here?

You aren't.  However we can easily make this:
	task = pid_task(proc_pid(dir), PIDTYPE_PID);
And we won't need to increment the count on the task_struct.

Good catch.

>> +	if (task != NULL) {
>> +		ns = task_nsproxy(task);
>> +		if (ns != NULL)
>> +			net = get_net(ns->net_ns);
>> +	}
>> +	rcu_read_unlock();
>> +
>> +	return net;
>> +}
>> +
