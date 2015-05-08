From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while creating kernel sockets
Date: Fri, 08 May 2015 06:07:55 -0500
Message-ID: <87a8xfba44.fsf@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org> <554C78BE.100@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <cwang@twopensource.com>,
	<herbert@gondor.apana.org.au>, <xemul@openvz.org>,
	<davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<maxk@qti.qualcomm.com>, <stephen@networkplumber.org>,
	<tgraf@suug.ch>, <nicolas.dichtel@6wind.com>,
	<tom@herbertland.com>, <jchapman@katalix.com>,
	<erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>,
	<horms@verge.net.au>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:50489 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbbEHLMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 07:12:31 -0400
In-Reply-To: <554C78BE.100@windriver.com> (Ying Xue's message of "Fri, 8 May
	2015 16:50:06 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ying Xue <ying.xue@windriver.com> writes:

> On 05/08/2015 12:14 AM, Eric W. Biederman wrote:
>> I agree that commit 23fe18669e7f ("[NETNS]: Fix race between put_net()
>> and netlink_kernel_create()."  was a hack.
>>
>
> Thanks for the agreement :)
>
>> However it is not appropriate to call get_net on a network namespace
>> whose count might be zero.
>
> I will explain why it's still safe for us in another mail even if we do this.
>
>   I believe all of your patches rely on that
>> currently.
>
> Yes, you are right.
>
>   Instead we need to build something like sk_release_kernel
>> that does not increase the network namespace reference count
>
> Please refer to above comments.
>
>  if you are
>> going to avoid changing the network namespace on a socket (a worthy
>> goal).
>> 
>
> Thanks to the conformation for the effort!
>
>> The following change shows how it is possible to always know that your
>> network namespace has a non-zero reference count in the network
>> namespace initialization methods.  My implementation of
>> lock_network_namespaces is problematic in that it does not sleep
>> while network namespaces are unregistering.  But it is enough to show
>> how the locking and reference counting can be fixed.
>> 
>
> If my understanding for your proposal is right, register_pernet_subsys() will
> return a failed error code to its caller if it's found that there is a net whose
> refcount is zero from net_namespace_list in lock_network_namespaces(), which
> means the per namespace operation is not registered at all in this situation.
> But in practice we should not reject the registration even if there is a dead
> net linked in the global net_namespace_list.

I agree which is why my implementation of lock_network_namespaces below
loops until there are no exiting network namespaces.

Eric

> Regards,
> Ying
>
>> Eric
>> 
>> 
>> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>> index a3abb719221f..81c53ccc5764 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -822,6 +822,49 @@ static void unregister_pernet_operations(struct pernet_operations *ops)
>>  		ida_remove(&net_generic_ids, *ops->id);
>>  }
>>  
>> +static void unlock_network_namespaces(void)
>> +{
>> +	/* Drop the reference count to every network namespace
>> +	 * and then release the net_mutex.
>> +	 */
>> +	struct net *net;
>> +
>> +	for_each_net(net)
>> +		put_net(net);
>> +
>> +	mutex_unlock(&net_mutex);
>> +}
>> +
>> +static void lock_network_namespaces(void)
>> +{
>> +	/* Take the mutex lock ensuring no new network namespaces
>> +	 * and take a reference on all existing network namespaces
>> +	 * allowing network namespace initialization code to take
>> +	 * further references
>> +	 */
>> +	for (;;) {
>> +		struct net *net, *stop;
>> +
>> +		mutex_lock(&net_mutex);
>> +		for_each_net(net) {
>> +			if (!maybe_get_net(net))
>> +				goto undo;
>> +		}
>> +		return;
>> +undo:
>> +		/* Remember the network namespace whose reference
>> +		 * count was not acquired. */
>> +		stop = net;
>> +		for_each_net(net) {
>> +			if (net_eq(net, stop))
>> +				goto undone;
>> +			put_net(net);
>> +		}
>> +undone:
>> +		mutex_unlock(&net_mutex);
>> +	}
>> +}
>> +
>>  /**
>>   *      register_pernet_subsys - register a network namespace subsystem
>>   *	@ops:  pernet operations structure for the subsystem
>> @@ -844,9 +887,9 @@ static void unregister_pernet_operations(struct pernet_operations *ops)
>>  int register_pernet_subsys(struct pernet_operations *ops)
>>  {
>>  	int error;
>> -	mutex_lock(&net_mutex);
>> +	lock_network_namespaces();
>>  	error =  register_pernet_operations(first_device, ops);
>> -	mutex_unlock(&net_mutex);
>> +	unlock_network_namespaces();
>>  	return error;
>>  }
>>  EXPORT_SYMBOL_GPL(register_pernet_subsys);
>> @@ -890,11 +933,11 @@ EXPORT_SYMBOL_GPL(unregister_pernet_subsys);
>>  int register_pernet_device(struct pernet_operations *ops)
>>  {
>>  	int error;
>> -	mutex_lock(&net_mutex);
>> +	lock_network_namespaces();
>>  	error = register_pernet_operations(&pernet_list, ops);
>>  	if (!error && (first_device == &pernet_list))
>>  		first_device = &ops->list;
>> -	mutex_unlock(&net_mutex);
>> +	unlock_network_namespaces();
>>  	return error;
>>  }
>>  EXPORT_SYMBOL_GPL(register_pernet_device);
