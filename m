From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] net: dev: fix the incorrect hold of net namespace's lo
 device
Date: Wed, 22 Aug 2012 19:00:11 +0800
Message-ID: <5034BBBB.6080307@cn.fujitsu.com>
References: <1345624262-6554-1-git-send-email-gaofeng@cn.fujitsu.com> <1345624786.5158.759.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:37965 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752911Ab2HVK77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 06:59:59 -0400
In-Reply-To: <1345624786.5158.759.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-22 at 16:39 +0800, Eric Dumazet wrote:
> On Wed, 2012-08-22 at 16:31 +0800, Gao feng wrote:
>> in dst_dev_event,we get the still referenced dst entries
>> from dst_garbage list,and call dst_ifdown to change these
>> dst entries' device to the net namesapce's lo device.
>>
>> when we moving a net device(A) to another net namespace,
>> because free_fib_info_rcu is called after a grace period,
>> we may call dst_dev_event before free_fib_info_rcu putting
>> dst_entry into the dst_garbage list.
>>
>> so in dst_dev_event, we can't see these dst entries through
>> dst_garbage list, and without changing their device to the
>> old net namespace's lo device. after a grace period, these
>> dst entries which dst->dev is device A will in the dst_garbage
>> list, and the device A will belong to the new net namespcae.
>>
>> then we exit from this new net namespace, the dst_dev_event
>> is called again,it will get these dst entries from dst_garbage
>> list,and call dst_ifdown to hold the new net namespace's lo
>> device incorrectly and put the device A.
>>
>> so it will tigger the emg message in netdev_wait_allrefs like
>> below.
>> unregister_netdevice: waiting for lo to become free. Usage count = 1
>>
>> fix this problem by adding rcu_barrier() in dst_dev_event
>> when event is NETDEV_UNREGISTER.
>> with this,dst_ifdown will be called after the dst_garbage list
>> beeing updated.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/core/dst.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/core/dst.c b/net/core/dst.c
>> index 56d6361..38c2199 100644
>> --- a/net/core/dst.c
>> +++ b/net/core/dst.c
>> @@ -375,6 +375,7 @@ static int dst_dev_event(struct notifier_block *this, unsigned long event,
>>  
>>  	switch (event) {
>>  	case NETDEV_UNREGISTER:
>> +		rcu_barrier();
>>  	case NETDEV_DOWN:
>>  		mutex_lock(&dst_gc_mutex);
>>  		for (dst = dst_busy_list; dst; dst = dst->next) {
> 
> 
> Did you miss http://patchwork.ozlabs.org/patch/176517/  or is this patch
> an alternative ?
> 

Hi Eric

I saw your patch and think this patch is clear and doesn't change too much logic.

I test your patch, it not fix this problem.

In my test case,when moving a net device to another net namespace,
Because you patch delete NETDEV_UNREGISTER event from dst_dev_event,
we will just put dst entries into the dst garbage list in event
NETDEV_DOWN,without call dst_ifdown to change these dst entries' device
to the lo device,and now this net device belongs to the new net namespace.

After the net device beeing moved to another net namespace, I rmmod this
net device's driver,this will trigger the new added event NETDEV_UNREGISTER_FINISH,
so in dst_dev_event,we will change these dst entries's device to the new net
namespace's lo device,and this will make the referenct count of the new net namespace's
lo device incorrect. when we exit the new net namespace,this emg message is still exist.

Message from syslogd@Donkey at Aug 22 18:50:13 ...
 kernel:[ 1161.979036] unregister_netdevice: waiting for lo to become free. Usage count = 1

And because net_mutex is locked here,so we can't create new net namespace.

> rcu_barrier() at this place will kill some workloads.
> 

I think this will only add some workloads when unregister a net device.
Do I miss something?
