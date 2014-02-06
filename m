From: Cong Wang <cwang@twopensource.com>
Subject: Re: RTNL: assertion failed at net/core/dev.c (4494) and RTNL:
 assertion failed at net/core/rtnetlink.c (940)
Date: Thu, 6 Feb 2014 13:40:27 -0800
Message-ID: <CAHA+R7OGS_KG1un36KBixbgs7LTPWGRYdJ+Vsn2iM0FzNV5FzA@mail.gmail.com>
References: <20140206205106.GA10488@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, fubar@us.ibm.com,
	Veaceslav Falico <vfalico@redhat.com>, andy@greyhouse.net,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:43395 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbaBFVk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 16:40:29 -0500
Received: by mail-la0-f47.google.com with SMTP id hr17so1943047lab.20
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 13:40:27 -0800 (PST)
In-Reply-To: <20140206205106.GA10488@glanzmann.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 6, 2014 at 12:51 PM, Thomas Glanzmann <thomas@glanzmann.de> wrote:
> Hello,
> this morning I checked out Linus tip and compiled it after booting my
> dmesg is full of:
>
> [    8.944991] RTNL: assertion failed at net/core/dev.c (4494)
> [    8.950640] CPU: 3 PID: 388 Comm: kworker/u24:4 Not tainted 3.14.0-rc1+ #3
> [    8.950642] Hardware name: Supermicro X9SRD-F/X9SRD-F, BIOS 1.0a 10/15/2012
> [    8.950654] Workqueue: bond0 bond_3ad_state_machine_handler [bonding]
> [    8.950658]  0000000000000000 ffff881020c88000 ffffffff8138e219 ffff881020c88000
> [    8.950664]  ffffffff812d3091 ffff881023961040 ffffffff812e3132 0000000000000246
> [    8.950670]  0000000000000020 ffff881020ab1be8 0000000020ab1ba8 0000000000000000
> [    8.950675] Call Trace:
> [    8.950686]  [<ffffffff8138e219>] ? dump_stack+0x41/0x51
> [    8.950694]  [<ffffffff812d3091>] ? netdev_master_upper_dev_get+0x2a/0x4d
> [    8.950699]  [<ffffffff812e3132>] ? rtnl_fill_ifinfo+0x2c/0xac4
> [    8.950707]  [<ffffffff81072211>] ? print_time.part.5+0x50/0x54
> [    8.950715]  [<ffffffff812caf94>] ? __kmalloc_reserve.isra.42+0x2a/0x6d
> [    8.950721]  [<ffffffff81102040>] ? ksize+0x12/0x1e
> [    8.950726]  [<ffffffff812cb2b7>] ? __alloc_skb+0xb5/0x1a9
> [    8.950731]  [<ffffffff812e4626>] ? rtmsg_ifinfo+0x6c/0xd6
> [    8.950739]  [<ffffffffa035f4f9>] ? __enable_port.isra.17+0x51/0x5a [bonding]
> [    8.950747]  [<ffffffffa0360463>] ? ad_agg_selection_logic+0x3d3/0x3ed [bonding]
> [    8.950754]  [<ffffffffa0360d40>] ? bond_3ad_state_machine_handler+0x555/0x918 [bonding]
> [    8.950761]  [<ffffffff8104db2d>] ? process_one_work+0x191/0x293
> [    8.950766]  [<ffffffff8104dfde>] ? worker_thread+0x121/0x1e7
> [    8.950770]  [<ffffffff8104debd>] ? rescuer_thread+0x269/0x269
> [    8.950777]  [<ffffffff810527b6>] ? kthread+0x99/0xa1
> [    8.950782]  [<ffffffff8105271d>] ? __kthread_parkme+0x59/0x59
> [    8.950789]  [<ffffffff8139733c>] ? ret_from_fork+0x7c/0xb0
> [    8.950794]  [<ffffffff8105271d>] ? __kthread_parkme+0x59/0x59


Hmm, rtmsg_ifinfo() should be called with rtnl lock, but
__enable_port() is called
with rcu_read_lock() which means we can't block inside it, therefore we probably
should take rtnl lock outside:

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index cce1f1b..3c09ffa 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2065,6 +2065,7 @@ void bond_3ad_state_machine_handler(struct
work_struct *work)
        struct slave *slave;
        struct port *port;

+       rtnl_lock();
        read_lock(&bond->lock);
        rcu_read_lock();

@@ -2123,6 +2124,7 @@ void bond_3ad_state_machine_handler(struct
work_struct *work)
 re_arm:
        rcu_read_unlock();
        read_unlock(&bond->lock);
+       rtnl_unlock();
        queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
 }
