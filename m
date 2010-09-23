From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/8] ns proc: Add support for the network namespace.
Date: Thu, 23 Sep 2010 09:00:31 -0700
Message-ID: <m1pqw4h2lc.fsf@fess.ebiederm.org>
References: <m1ocborgq7.fsf@fess.ebiederm.org>
	<m17hicrglt.fsf@fess.ebiederm.org>
	<20100923112739.GD2211@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Ulrich Drepper <drepper@gmail.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Ben Greear <greearb@candelatech.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Patrick McHardy <kaber@trash.net>
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100923112739.GD2211@hawkmoon.kerlabs.com> (Louis Rilling's
	message of "Thu, 23 Sep 2010 13:27:39 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Louis Rilling <Louis.Rilling@kerlabs.com> writes:

> On 23/09/10  1:47 -0700, Eric W. Biederman wrote:
>> 
>> Implementing file descriptors for the network namespace is simple and
>> straight forward.
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
> [...]
>
>> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>> index c988e68..581a088 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -571,3 +571,33 @@ void unregister_pernet_device(struct pernet_operations *ops)
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
> task could be exiting, so task->nsproxy could be NULL, right?
> Maybe make proc_ns_instantiate() rcu_dereference task->nsproxy, check for it
> being not NULL, and pass task->nsproxy to ns_ops->get()?

Ugh.  Thanks. fixed.

Somehow I forgot /proc shows zombies which means nsproxy
will definitely be NULL in those cases.  It is easy enough to handle
once my brain gets out of park.

I don't hold any locks at that point so I don't think I want to do
anything in proc_ns_instantiate() except handle a NULL return when
the ns_ops->get() fails.

> That could be an issue for the user namespace since it is not in nsproxy, but
> maybe no reasonable usage of ns_ops with user namespaces is
> envisioned.

It is also a issue for the pid namespace.  

> Otherwise, checking that task is alive with RCU locked in proc_ns_instantiate() should be enough to be
> rely on task->cred when calling ns_ops->get().

That sounds about right.  I keep conveniently forgetting the user
namespace.  It doesn't support unshare right now so there isn't anything
I can reasonably do with it at the moment.  It wouldn't surprise me if I
don't wind up handling the user namespace like the pid namespace, where
unsharing it changes the properties for the children and not the parent.
Bleh.

Eric
