From: "Li, ZhenHua" <zhen-hual@hp.com>
Subject: Re: [PATCH 1/1] net: Add rtnl_lock for netif_device_attach/detach
Date: Wed, 16 Apr 2014 16:34:44 +0800
Message-ID: <534E40A4.2050305@hp.com>
References: <1397632082-18453-1-git-send-email-zhen-hual@hp.com> <20140416073803.GB19994@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140416073803.GB19994@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The problem I am trying to fix is: when netif_device_attach/detached is 
called, it get a return value from netif_running, but at this moment, in 
another thread, the stat of this dev changes. But in 
netif_device_attach, it does not know stat changed, and this may cause bugs.


I think you are right, this patch cannot fix race with another thread 
that takes the lock. But that's what is happening now(with out this 
patch).  I do not yet find a way to fix it completely.

And another problem is: we only need a lock for this dev , not full all 
dev. So how about adding a single lock for each net device?

Regards
Zhenhua

On 04/16/2014 03:38 PM, Veaceslav Falico wrote:
> On Wed, Apr 16, 2014 at 03:08:02PM +0800, Li, Zhen-Hua wrote:
>> From: "Li, Zhen-Hua" <zhen-hual@hp.com>
>>
>> As netif_running is called in netif_device_attach/detach. There should be
>> rtnl_lock/unlock called, to avoid dev stat change during
>> netif_device_attach
>> and detach being called.
>> I checked NIC some drivers,  some of them have netif_device_attach/detach
>> called between rtnl_lock/unlock, while some drivers do not.
>
> It can race with any other thread that takes the lock - i.e. suppose you
> have a driver that doesn't take the lock and calls netif_device_attach(),
> while another thread (completely unrelated to the issue) holds rtnl_lock -
> this way the trylock will return false, the thread that took rtnl releases
> it - and you'll see the exact same behaviour as without your patch.
>
> I'm not sure about the issue you're trying to fix here - there might be a
> better approach which I'm not aware of, however with your approach you
> should really either remove the rtnl locking from all drivers that use this
> function (and insert a normal rtnl_lock here) or, vice-versa, add it to all
> drivers and add an ASSERT_RTNL to netif_device_detach/attach.
>
>>
>> This patch is tring to find a generic way to fix this for all NIC
>> drivers.
>>
>> Signed-off-by: Li, Zhen-Hua <zhen-hual@hp.com>
>> ---
>> net/core/dev.c |   18 ++++++++++++++++++
>> 1 file changed, 18 insertions(+)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 5b3042e..795bbc5 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2190,10 +2190,19 @@ EXPORT_SYMBOL(__dev_kfree_skb_any);
>>  */
>> void netif_device_detach(struct net_device *dev)
>> {
>> +    /**
>> +     * As netif_running is called , rtnl_lock and unlock are needed to
>> +     * avoid __LINK_STATE_START bit changes during this function call.
>> +     */
>> +    int need_unlock;
>> +
>> +    need_unlock = rtnl_trylock();
>>     if (test_and_clear_bit(__LINK_STATE_PRESENT, &dev->state) &&
>>         netif_running(dev)) {
>>         netif_tx_stop_all_queues(dev);
>>     }
>> +    if (need_unlock)
>> +        rtnl_unlock();
>> }
>> EXPORT_SYMBOL(netif_device_detach);
>>
>> @@ -2205,11 +2214,20 @@ EXPORT_SYMBOL(netif_device_detach);
>>  */
>> void netif_device_attach(struct net_device *dev)
>> {
>> +    /**
>> +     * As netif_running is called , rtnl_lock and unlock are needed to
>> +     * avoid __LINK_STATE_START bit changes during this function call.
>> +     */
>> +    int need_unlock;
>> +
>> +    need_unlock = rtnl_trylock();
>>     if (!test_and_set_bit(__LINK_STATE_PRESENT, &dev->state) &&
>>         netif_running(dev)) {
>>         netif_tx_wake_all_queues(dev);
>>         __netdev_watchdog_up(dev);
>>     }
>> +    if (need_unlock)
>> +        rtnl_unlock();
>> }
>> EXPORT_SYMBOL(netif_device_attach);
>>
>> --
>> 1.7.10.4
>>
