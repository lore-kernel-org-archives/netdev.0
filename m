From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/2] net: centralize net_device min/max MTU
 checking
Date: Sun, 02 Oct 2016 22:43:22 -0400 (EDT)
Message-ID: <20161002.224322.740109807229746275.davem@davemloft.net>
References: <20160928222053.33697-2-jarod@redhat.com>
        <87intdwwx7.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: jkbs@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87intdwwx7.fsf@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jakub Sitnicki <jkbs@redhat.com>
Date: Fri, 30 Sep 2016 11:37:24 +0200

> On Wed, Sep 28, 2016 at 10:20 PM GMT, Jarod Wilson wrote:
>> While looking into an MTU issue with sfc, I started noticing that almost
>> every NIC driver with an ndo_change_mtu function implemented almost
>> exactly the same range checks, and in many cases, that was the only
>> practical thing their ndo_change_mtu function was doing. Quite a few
>> drivers have either 68, 64, 60 or 46 as their minimum MTU value checked,
>> and then various sizes from 1500 to 65535 for their maximum MTU value. We
>> can remove a whole lot of redundant code here if we simple store min_mtu
>> and max_mtu in net_device, and check against those in net/core/dev.c's
>> dev_set_mtu().
>>
>> In theory, there should be zero functional change with this patch, it just
>> puts the infrastructure in place. Subsequent patches will attempt to start
>> using said infrastructure, with theoretically zero change in
>> functionality.
>>
>> CC: "David S. Miller" <davem@davemloft.net>
>> CC: netdev@vger.kernel.org
>> Signed-off-by: Jarod Wilson <jarod@redhat.com>
>> ---
> 
> [...]
> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index c0c291f..5343799 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -6493,9 +6493,17 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
>>  	if (new_mtu == dev->mtu)
>>  		return 0;
>>  
>> -	/*	MTU must be positive.	 */
>> -	if (new_mtu < 0)
>> +	if (new_mtu < dev->min_mtu) {
> 
> Ouch, integral promotions. Looks like you need to keep the < 0 check.
> Otherwise new_mtu gets promoted to unsigned int and negative values will
> pass the check.

Agreed, the < 0 test must be reintroduced.
