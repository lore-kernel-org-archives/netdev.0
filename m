From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: =?UTF-8?Q?=E7=AD=94=E5=A4=8D=3A?= Re: [Patch] netxen_nic:
 Bugfix for wrong RUNNING status of NX3031 NICs with no link
Date: Mon, 6 Jan 2014 20:24:39 +0000
Message-ID: <1389039879.9947.104.camel@bwh-desktop.uk.level5networks.com>
References: <OF9AC42061.4BF09F2E-ON48257C55.00253C5A-48257C55.0027274D@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <li.fengmao@zte.com.cn>,
	<manish.chopra@qlogic.com>, <netdev@vger.kernel.org>,
	<rajesh.borundia@qlogic.com>, <sony.chacko@qlogic.com>,
	<wang.liang82@zte.com.cn>, <cai.qu@zte.com.cn>,
	<long.chun@zte.com.cn>
To: <jiang.biao2@zte.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36161 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbaAFUYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 15:24:44 -0500
In-Reply-To: <OF9AC42061.4BF09F2E-ON48257C55.00253C5A-48257C55.0027274D@zte.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-03 at 15:07 +0800, jiang.biao2@zte.com.cn wrote:
> >>> You cannot do this, because at the very exact moment you call
> >>> register_netdevice() the device can be brought up and once the
> >>> device is up the link can be brought up.
> 
> >>> Therefore if you invoke netif_carrier_off() right after
> >>> register_netdevice(), it can cancel out a legitimate
> >>> netif_carrier_on() call.
> 
> >> register_netdevice() should be call in probe(), at that time, is
> >> it impossible to bring up device because the driver loading has
> >> not finished?
> 
> > So far as the networking core is concerned, when register_netdevice() is
> > called the device is ready to use.  But you can do:
> 
> > rtnl_lock();
> > register_netdevice();
> > netif_carrier_off();
> > rtnl_unlock();
> 
> > However, as I said before, the current order in netxen_nic works and
> > only older kernel versions require you to call netif_carrier_off() after
> > registering the device.
> 
> >> Even that, the netif_carrier_off() will be called before
> >> netif_carrier_on(), and that will not be a problem.
> 
> >> Besides, the other net drivers(e.g igb, e1000, e1000e) I saw all
> >> call netif_carrier_off() after register_netdev(). There is no such
> >> problems in these drivers.
> 
> > It is not easy to hit the race condition but it is real.
> 
> But the problem I depicted really exists in the current netxen_nic driver,
> you can easily reproduce it following the reproduction steps.

'Current' as in Linux 3.12/3.13-rc7?

I don't know where I would find a Netxen card now.  So I can't test
netxen_nic myself, but I can assure you the sfc driver does things in
the same order and it works correctly.

> Can the following modification fix both the problem I faced and the race
> you worried?
> 
> netif_carrier_off();
> netdev->operstate=IF_OPER_DOWN;
> register_netdevice();

register_netdevice() calls linkwatch_init_dev() which sets the operstate
if necessary.  You should not set it directly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
