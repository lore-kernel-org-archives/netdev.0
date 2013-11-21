From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v2] packet: fix use after free race in send path when
 dev is released
Date: Thu, 21 Nov 2013 16:02:49 +0100
Message-ID: <528E2099.90208@redhat.com>
References: <1385027235-2217-1-git-send-email-dborkman@redhat.com> <1385044842.10637.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Salam Noureddine <noureddine@aristanetworks.com>,
	Ben Greear <greearb@candelatech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827Ab3KUPC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 10:02:56 -0500
In-Reply-To: <1385044842.10637.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2013 03:40 PM, Eric Dumazet wrote:
> On Thu, 2013-11-21 at 10:47 +0100, Daniel Borkmann wrote:
>
>> +static void packet_dev_put_deferred(struct rcu_head *head)
>> +{
>> +	struct packet_sock *po = container_of(head, struct packet_sock, rcu);
>> +	struct sock *sk = &po->sk;
>> +
>> +	spin_lock(&po->bind_lock);
>> +	po->ifindex = -1;
>> +
>> +	if (po->prot_hook.dev) {
>> +		dev_put(po->prot_hook.dev);
>> +		po->prot_hook.dev = NULL;
>> +	}
>> +
>> +	spin_unlock(&po->bind_lock);
>> +	sock_put(sk);
>> +}
>
> I dont think this is needed.
>
>>
>>   static int packet_notifier(struct notifier_block *this,
>>   			   unsigned long msg, void *ptr)
>> @@ -3325,13 +3354,13 @@ static int packet_notifier(struct notifier_block *this,
>>   					if (!sock_flag(sk, SOCK_DEAD))
>>   						sk->sk_error_report(sk);
>>   				}
>> +				spin_unlock(&po->bind_lock);
>> +
>>   				if (msg == NETDEV_UNREGISTER) {
>> -					po->ifindex = -1;
>> -					if (po->prot_hook.dev)
>> -						dev_put(po->prot_hook.dev);
>> -					po->prot_hook.dev = NULL;
>> +					sock_hold(sk);
>> +					call_rcu(&po->rcu,
>> +						 packet_dev_put_deferred);
>>   				}
>> -				spin_unlock(&po->bind_lock);
>>   			}
>
> Its not needed because you now take a reference on dev
> in packet_cached_dev_get()

That was also my first thought, but Salam pointed out to me, that in case
we have a situation such as ...

in packet_cached_dev_get():
     rcu_read_lock();
     dev = rcu_dereference(po->cached_dev);      in packet_notifier():
                                                 ---> CPU1: dev_put(po->prot_hook.dev);
---> CPU0:
     if (dev)
	dev_hold(dev);
     rcu_read_unlock();

... we could reach a refcount of 0, before we increase it back to 1. Not sure
if this can actually happen, maybe in preemptible RCU where read-side critical
sections to be preempted? So with this rather paranoid approach we make sure
to avoid such a situation as we wait a grace period when readers finished.

> Otherwise, patch looks good !

Thanks!
