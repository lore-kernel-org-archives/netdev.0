From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/14][NETNS]: Generic per-net pointers.
Date: Fri, 11 Apr 2008 18:29:13 +0400
Message-ID: <47FF75B9.2090508@openvz.org>
References: <47FE2AD4.9080609@openvz.org> <47FE2C78.1030207@openvz.org>
	<47FF6B1B.5090106@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47FF6B1B.5090106-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

[snip]

>> @@ -29,10 +32,21 @@ static __net_init int setup_net(struct net *net)
>>  	/* Must be called with net_mutex held */
>>  	struct pernet_operations *ops;
>>  	int error;
>> +	struct net_generic *ng;
>>
>>  	atomic_set(&net->count, 1);
>>  	atomic_set(&net->use_count, 0);
>>
>> +	error = -ENOMEM;
>> +	ng = kzalloc(sizeof(struct net_generic) +
>> +			INITIAL_NET_GEN_PTRS * sizeof(void *), GFP_KERNEL);
> 
> Why do you need to allocate more than sizeof(struct net_generic) ?

That's just an optimization to avoid many reallocations in the
nearest future. I planned to make similar in net_assign_generic
(allocate a bit more that required), but decided to do it later
to keep net_assign_generic simpler.

Currently I have only 5 users of generic pointers (tun and vlan
you see and I have patches for ipip, ipgre and sit tunnels), so
that's enough for the first time.

[snip]

>> +int net_assign_generic(struct net *net, int id, void *data)
>> +{
>> +	struct net_generic *ng, *old_ng;
>> +
>> +	BUG_ON(!mutex_is_locked(&net_mutex));
>> +	BUG_ON(id == 0);
>> +
>> +	ng = old_ng = net->gen;
> 
> shouldn't it be rcu_dereferenced ?

Nope - nobody can race with us and change this pointer, so it's
safe to get one without rcu_dereference.

Thanks,
Pavel
