From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] netxen_nic: Bugfix for wrong RUNNING status of NX3031
 NICs with no link
Date: Thu, 02 Jan 2014 03:24:23 -0500 (EST)
Message-ID: <20140102.032423.2130522873875479421.davem@davemloft.net>
References: <OFFF20C6AD.9ACCA9A7-ON48257C54.00238C88-48257C54.0023F52A@zte.com.cn>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	li.fengmao@zte.com.cn
To: jiang.biao2@zte.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbaABIY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 03:24:29 -0500
In-Reply-To: <OFFF20C6AD.9ACCA9A7-ON48257C54.00238C88-48257C54.0023F52A@zte.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jiang.biao2@zte.com.cn
Date: Thu, 2 Jan 2014 14:32:32 +0800

> From: Li Fengmao <li.fengmao@zte.com.cn>
> 
> Ifconfig command displays RUNNING status when there is no link on
> NX3031 NICs. The problem is caused by the wrong calling order of
> netif_carrier_off() and register_netdev() in netxen_setup_netdev(),
> dev->reg_state is initialized to NETREG_UNINITIALIZED before
> registering network device, so the linkwatch_fire_event() will not
> be called to notify the link change event in netif_carrier_off(),
> and the operational status of network device will be set to
> IF_OPER_UNKNOWN. In that case, the IFF_RUNNING flags will be set,
> which result in the wrong RUNNING status in the result of ifconfig
> command.
> 
> It can be solved by calling netif_carrier_off() after
> register_netdev() in netxen_setup_netdev() to ensure the
> notification of the link change event. And then the operational
> status of device will be set to IF_OPER_DOWN correctly.
> 
> Steps to reproduce the bug:
> 1. Prepare a NX3031 NIC with no network cable on it.
> 2. Reboot the system. (e.g exec reboot command)
> 3. Activate the interface. (e.g ifconfig eth0 up)
> 4. The operstatus of the NX3031 NIC will be RUNNING in the result of
> ifconfig command.
> 
> Signed-off-by: Li Fengmao <li.fengmao@zte.com.cn>
> Reviewed-by: Long Chun <long.chun@zte.com.cn>
> Reviewed-by: Wang Liang <wang.liang82@zte.com.cn>
> Reviewed-by: Cai Qu <cai.qu@zte.com.cn>
> Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>

You cannot do this, because at the very exact moment you call
register_netdevice() the device can be brought up and once the
device is up the link can be brought up.

Therefore if you invoke netif_carrier_off() right after
register_netdevice(), it can cancel out a legitimate
netif_carrier_on() call.
