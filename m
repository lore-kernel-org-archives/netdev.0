From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: RTNL: assertion failed at net/core/dev.c (4494) and RTNL: assertion failed at net/core/rtnetlink.c (940)
Date: Thu, 06 Feb 2014 13:45:04 -0800
Message-ID: <30960.1391723104@death.nxdomain>
References: <20140206205106.GA10488@glanzmann.de>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	vfalico@redhat.com, andy@greyhouse.net, jiri@resnulli.us
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:36487 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbaBFVpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 16:45:42 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 6 Feb 2014 14:45:42 -0700
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DA18419D8045
	for <netdev@vger.kernel.org>; Thu,  6 Feb 2014 14:45:38 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s16LjYV065929470
	for <netdev@vger.kernel.org>; Thu, 6 Feb 2014 22:45:39 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s16LjGSF002629
	for <netdev@vger.kernel.org>; Thu, 6 Feb 2014 14:45:18 -0700
In-reply-to: <20140206205106.GA10488@glanzmann.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Glanzmann <thomas@glanzmann.de> wrote:

>Hello,
>this morning I checked out Linus tip and compiled it after booting my
>dmesg is full of:
>
>[    8.944991] RTNL: assertion failed at net/core/dev.c (4494)
>[    8.950640] CPU: 3 PID: 388 Comm: kworker/u24:4 Not tainted 3.14.0-rc1+ #3
>[    8.950642] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
>[    8.950654] Workqueue: bond0 bond_3ad_state_machine_handler [bonding]
>[    8.950658]  0000000000000000 ffff881020c88000 ffffffff8138e219 ffff881020c88000
>[    8.950664]  ffffffff812d3091 ffff881023961040 ffffffff812e3132 0000000000000246
>[    8.950670]  0000000000000020 ffff881020ab1be8 0000000020ab1ba8 0000000000000000
>[    8.950675] Call Trace:
>[    8.950686]  [<ffffffff8138e219>] ? dump_stack+0x41/0x51
>[    8.950694]  [<ffffffff812d3091>] ? netdev_master_upper_dev_get+0x2a/0x4d
>[    8.950699]  [<ffffffff812e3132>] ? rtnl_fill_ifinfo+0x2c/0xac4
>[    8.950707]  [<ffffffff81072211>] ? print_time.part.5+0x50/0x54
>[    8.950715]  [<ffffffff812caf94>] ? __kmalloc_reserve.isra.42+0x2a/0x6d
>[    8.950721]  [<ffffffff81102040>] ? ksize+0x12/0x1e
>[    8.950726]  [<ffffffff812cb2b7>] ? __alloc_skb+0xb5/0x1a9
>[    8.950731]  [<ffffffff812e4626>] ? rtmsg_ifinfo+0x6c/0xd6
>[    8.950739]  [<ffffffffa035f4f9>] ? __enable_port.isra.17+0x51/0x5a [bonding]
>[    8.950747]  [<ffffffffa0360463>] ? ad_agg_selection_logic+0x3d3/0x3ed [bonding]
>[    8.950754]  [<ffffffffa0360d40>] ? bond_3ad_state_machine_handler+0x555/0x918 [bonding]

	This was apparently introduced by commit:

commit 1d3ee88ae0d605629bf369ab0b868dae8ca62a48
Author: sfeldma@cumulusnetworks.com <sfeldma@cumulusnetworks.com>
Date:   Thu Jan 16 22:57:56 2014 -0800

    bonding: add netlink attributes to slave link dev
    

	which adds an "rtmsg_ifinfo" call to bond_set_active_slave and
bond_set_backup_slave, both of which are invoked in several places in
the 802.3ad code without RTNL held (via __enable_port and
__disable_port).

	Still looking into a fix.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
