From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Patch net-next v2 2/2] netpoll: use the net namespace of current process instead of init_net
Date: Mon, 28 Jan 2013 16:18:30 -0800
Message-ID: <878v7clu3t.fsf@xmission.com>
References: <1359338121-10897-1-git-send-email-amwang@redhat.com>
	<1359338121-10897-2-git-send-email-amwang@redhat.com>
	<20130128.183338.211219305250941993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:43311 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab3A2ASj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 19:18:39 -0500
In-Reply-To: <20130128.183338.211219305250941993.davem@davemloft.net> (David
	Miller's message of "Mon, 28 Jan 2013 18:33:38 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Cong Wang <amwang@redhat.com>
> Date: Mon, 28 Jan 2013 09:55:21 +0800
>
>> From: Cong Wang <amwang@redhat.com>
>> 
>> This will allow us to setup netconsole in a different namespace
>> rather than where init_net is.
>> 
>> Cc: Eric W. Biederman <ebiederm@xmission.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <amwang@redhat.com>
>
> Applied but:
>
>> +	if (np->dev_name) {
>> +		struct net *net = current->nsproxy->net_ns;
>> +		ndev = __dev_get_by_name(net, np->dev_name);
>> +	}
>
> I wonder if you should be using task_nsproxy() here.

At a practical level using nsproxy straight is what we want here,
as nsproxy can not be changed by anything other than the current
process.  So we have an implicit lock just by being the current
process.

Now there might be some set of rules for error checking that
I am not up to speed on that says because some paths that do
the rcu dance:

	rcu_read_lock();
	nsproxy =  rcu_dereference(tsk->nsproxy);
        net = get_net(nsproxy->net_ns);
        rcu_read_lock();

That all paths have to do a companion rcu dance to say this is a
place where we don't need rcu protection because this is the
current process and we don't need an rcu_lock here.

If there is such a set of rules we have at least 24 other places
in the kernel that need to be fixed.

Eric
