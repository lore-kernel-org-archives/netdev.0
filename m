From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net v2] packet: fix use after free race in send path when
 dev is released
Date: Thu, 21 Nov 2013 16:28:43 +0100
Message-ID: <528E26AB.8020501@redhat.com>
References: <1385027235-2217-1-git-send-email-dborkman@redhat.com>  <1385044842.10637.41.camel@edumazet-glaptop2.roam.corp.google.com>  <528E2099.90208@redhat.com> <1385047624.10637.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Salam Noureddine <noureddine@aristanetworks.com>,
	Ben Greear <greearb@candelatech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751833Ab3KUP2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 10:28:50 -0500
In-Reply-To: <1385047624.10637.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2013 04:27 PM, Eric Dumazet wrote:
> On Thu, 2013-11-21 at 16:02 +0100, Daniel Borkmann wrote:
>
>>
>> That was also my first thought, but Salam pointed out to me, that in case
>> we have a situation such as ...
>>
>> in packet_cached_dev_get():
>>       rcu_read_lock();
>>       dev = rcu_dereference(po->cached_dev);      in packet_notifier():
>>                                                   ---> CPU1: dev_put(po->prot_hook.dev);
>> ---> CPU0:
>>       if (dev)
>> 	dev_hold(dev);
>>       rcu_read_unlock();
>>
>> ... we could reach a refcount of 0, before we increase it back to 1. Not sure
>> if this can actually happen, maybe in preemptible RCU where read-side critical
>> sections to be preempted? So with this rather paranoid approach we make sure
>> to avoid such a situation as we wait a grace period when readers finished.
>
> There is no need, because we respect a rcu grace period at dismantle
> time already.
>
> Nothing bad can happen inside the rcu_read_lock()/rcu_read_unlock() pair
> in packed_cached_dev_get()
>
> Note that dev_put() does not take any immediate action, it only
> decrements the refcount.
>
> So if CPU1 does the dev_put(po->prot_hook.dev) after
> setting cached_dev to NULL, we should be safe.

Ok, then I'll update the patch and send out v3 with that removed.

Thanks for the input Eric!
