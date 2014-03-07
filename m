From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] vlan: Fix lockdep warning when vlan dev handle
 notification
Date: Fri, 7 Mar 2014 09:55:25 +0800
Message-ID: <5319270D.4030602@huawei.com>
References: <5318828D.3090308@huawei.com> <20140306.145126.497070034648321818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <ben@decadent.org.uk>, <john.r.fastabend@intel.com>,
	<kaber@trash.net>, <netdev@vger.kernel.org>, <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:56364 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbaCGBzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 20:55:54 -0500
In-Reply-To: <20140306.145126.497070034648321818.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/7 3:51, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Thu, 6 Mar 2014 22:13:33 +0800
> 
>> When I open the LOCKDEP config and run these steps:
>>
>> modprobe 8021q
>> vconfig add eth2 20
>> vconfig add eth2.20 30
>> ifconfig eth2 xx.xx.xx.xx
>>
>> then the Call Trace happened:
>  ...
>> The reason is that all of the vlan dev have the same class key for dev_lock_list,
>> if we up or down the real dev, the notification will change the state for every
>> vlan dev in the vlan group, then the vlan dev will hold netif_addr_lock and the
>> real dev also hold its own netif_addr_lock together, so the warning happened.
>>
>> The best way to fix the problem is add a new class key for the vlan dev if its
>> real dev is a vlan dev too.
>>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> 
> So what happens when one does:
> 
> vconfig add eth2 20
> vconfig add eth2.20 30
> vconfig add eth2.30 40
> ifconfig eth2 xx.xx.xx.xx
> 
> 

the old vlan list:

eth2---------------------->eth2.20-------------------->eth2.20.30 (xxx_addr_lock_key)
			(xxx_addr_lock_key)|
					    ---------->eth2.20.50 (xxx_addr_lock_key)

after this patch:

eth2---------------------->eth2.20-------------------->eth2.20.30 (xxx_addr_lock_subkey)
			(xxx_addr_lock_key)|
					    ---------->eth2.20.50 (xxx_addr_lock_subkey)


The eth2.20 will only sync mc ddress with eth2.20.30 or eth2.20.50, and
the eth2.20.30 would never sync mc with eth2.20.50, so the xxx_addr_lock_subkey
will not meet each other.

But I think if I vconfig add eth2.20.30 50, the warning would happen again, but till now
I could not find any scene that use 3 vlan id on a virtual device, so I think it is not a 
problem.
