From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: Fix RTNL: assertion failed at
 net/core/rtnetlink.c for 802.3ad mode
Date: Tue, 18 Feb 2014 17:38:12 -0500 (EST)
Message-ID: <20140218.173812.1179657046277970562.davem@davemloft.net>
References: <53034312.1060203@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, vfalico@redhat.com,
	cwang@twopensource.com, thomas@glanzmann.de, jiri@resnulli.us,
	edumazet@google.com, sfeldma@cumulusnetworks.com,
	netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbaBRWiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 17:38:15 -0500
In-Reply-To: <53034312.1060203@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Tue, 18 Feb 2014 19:25:06 +0800

> The problem was introduced by the commit 1d3ee88ae0d
> (bonding: add netlink attributes to slave link dev).
> The bond_set_active_slave() and bond_set_backup_slave()
> will use rtmsg_ifinfo to send slave's states, so these
> two functions should be called in RTNL.
> 
> In 802.3ad mode, acquiring RTNL for the __enable_port and
> __disable_port cases is difficult, as those calls generally
> already hold the state machine lock, and cannot unconditionally
> call rtnl_lock because either they already hold RTNL (for calls
> via bond_3ad_unbind_slave) or due to the potential for deadlock
> with bond_3ad_adapter_speed_changed, bond_3ad_adapter_duplex_changed,
> bond_3ad_link_change, or bond_3ad_update_lacp_rate.  All four of
> those are called with RTNL held, and acquire the state machine lock
> second.  The calling contexts for __enable_port and __disable_port
> already hold the state machine lock, and may or may not need RTNL.
> 
> According to the Jay's opinion, I don't think it is a problem that
> the slave don't send notify message synchronously when the status
> changed, normally the state machine is running every 100 ms, send
> the notify message at the end of the state machine if the slave's
> state changed should be better.
> 
> I fix the problem through these steps:
> 
> 1). add a new function bond_set_slave_state() which could change
>     the slave's state and call rtmsg_ifinfo() according to the input
>     parameters called notify.
> 
> 2). Add a new slave parameter which called should_notify, if the slave's state
>     changed and don't notify yet, the parameter will be set to 1, and then if
>     the slave's state changed again, the param will be set to 0, it indicate that
>     the slave's state has been restored, no need to notify any one.
> 
> 3). the __enable_port and __disable_port should not call rtmsg_ifinfo
>     in the state machine lock, any change in the state of slave could
>     set a flag in the slave, it will indicated that an rtmsg_ifinfo
>     should be called at the end of the state machine.
> 
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Veaceslav Falico <vfalico@redhat.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

This seems more appropriately targetted at 'net' since it's a real
bug fix, do you agree?
