From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next] bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c
 for 802.3ad mode
Date: Tue, 18 Feb 2014 20:16:49 +0800
Message-ID: <53034F31.2090005@huawei.com>
References: <53034312.1060203@huawei.com> <20140218121417.GB30299@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Cong Wang <cwang@twopensource.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:8889 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440AbaBRMRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 07:17:22 -0500
In-Reply-To: <20140218121417.GB30299@glanzmann.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/18 20:14, Thomas Glanzmann wrote:
> Hello Ding,
> 
> * Ding Tianhong <dingtianhong@huawei.com> [2014-02-18 12:25]:
>> The problem was introduced by the commit 1d3ee88ae0d
>> (bonding: add netlink attributes to slave link dev).
>> The bond_set_active_slave() and bond_set_backup_slave()
>> will use rtmsg_ifinfo to send slave's states, so these
>> two functions should be called in RTNL.
> 
>> In 802.3ad mode, acquiring RTNL for the __enable_port and
>> __disable_port cases is difficult, as those calls generally
>> already hold the state machine lock, and cannot unconditionally
>> call rtnl_lock because either they already hold RTNL (for calls
>> via bond_3ad_unbind_slave) or due to the potential for deadlock
>> with bond_3ad_adapter_speed_changed, bond_3ad_adapter_duplex_changed,
>> bond_3ad_link_change, or bond_3ad_update_lacp_rate.  All four of
>> those are called with RTNL held, and acquire the state machine lock
>> second.  The calling contexts for __enable_port and __disable_port
>> already hold the state machine lock, and may or may not need RTNL.
> 
>> According to the Jay's opinion, I don't think it is a problem that
>> the slave don't send notify message synchronously when the status
>> changed, normally the state machine is running every 100 ms, send
>> the notify message at the end of the state machine if the slave's
>> state changed should be better.
> 
>> I fix the problem through these steps:
> 
>> 1). add a new function bond_set_slave_state() which could change
>>     the slave's state and call rtmsg_ifinfo() according to the input
>>     parameters called notify.
> 
>> 2). Add a new slave parameter which called should_notify, if the slave's state
>>     changed and don't notify yet, the parameter will be set to 1, and then if
>>     the slave's state changed again, the param will be set to 0, it indicate that
>>     the slave's state has been restored, no need to notify any one.
> 
>> 3). the __enable_port and __disable_port should not call rtmsg_ifinfo
>>     in the state machine lock, any change in the state of slave could
>>     set a flag in the slave, it will indicated that an rtmsg_ifinfo
>>     should be called at the end of the state machine.
> 
> I applied the same on top of Linus Tip and tested:
> 
> (node-62) [~] dmesg | pbot
> http://pbot.rmdir.de/tlM017PXoi9PsV3j32z4gA
> (node-62) [~] pbot /proc/net/bonding/bond0
> http://pbot.rmdir.de/zNSSqmjSI0o1Qvt6DrSEQw
> (node-62) [~] pbot /proc/net/bonding/bond1
> http://pbot.rmdir.de/CoI00Rguie2P-kOQytOM9w
> 
> Looks good to me.
> 
> Tested-by: Thomas Glanzmann <thomas@glanzmann.de>
> 
> Cheers,
>         Thomas
> 
> .

Thanks for testing this patch again.

Regards
Ding
> 
