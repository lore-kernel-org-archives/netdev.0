From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
Date: Tue, 24 May 2011 16:00:47 -0400
Message-ID: <20110524200047.GI21309@gospo.rdu.redhat.com>
References: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <daevm@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36976 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757472Ab1EXUA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 16:00:59 -0400
Content-Disposition: inline
In-Reply-To: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 03:36:05PM -0400, Neil Horman wrote:
> This soft lockup was recently reported:
> 
> [root@dell-per715-01 ~]# echo +bond5 > /sys/class/net/bonding_masters
> [root@dell-per715-01 ~]# echo +eth1 > /sys/class/net/bond5/bonding/slaves
> bonding: bond5: doing slave updates when interface is down.
> bonding bond5: master_dev is not up in bond_enslave
> [root@dell-per715-01 ~]# echo -eth1 > /sys/class/net/bond5/bonding/slaves
> bonding: bond5: doing slave updates when interface is down.
> 
> BUG: soft lockup - CPU#12 stuck for 60s! [bash:6444]
> CPU 12:
> Modules linked in: bonding autofs4 hidp rfcomm l2cap bluetooth lockd sunrpc
> be2d
> Pid: 6444, comm: bash Not tainted 2.6.18-262.el5 #1
> RIP: 0010:[<ffffffff80064bf0>]  [<ffffffff80064bf0>]
> .text.lock.spinlock+0x26/00
> RSP: 0018:ffff810113167da8  EFLAGS: 00000286
> RAX: ffff810113167fd8 RBX: ffff810123a47800 RCX: 0000000000ff1025
> RDX: 0000000000000000 RSI: ffff810123a47800 RDI: ffff81021b57f6f8
> RBP: ffff81021b57f500 R08: 0000000000000000 R09: 000000000000000c
> R10: 00000000ffffffff R11: ffff81011d41c000 R12: ffff81021b57f000
> R13: 0000000000000000 R14: 0000000000000282 R15: 0000000000000282
> FS:  00002b3b41ef3f50(0000) GS:ffff810123b27940(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00002b3b456dd000 CR3: 000000031fc60000 CR4: 00000000000006e0
> 
> Call Trace:
>  [<ffffffff80064af9>] _spin_lock_bh+0x9/0x14
>  [<ffffffff886937d7>] :bonding:tlb_clear_slave+0x22/0xa1
>  [<ffffffff8869423c>] :bonding:bond_alb_deinit_slave+0xba/0xf0
>  [<ffffffff8868dda6>] :bonding:bond_release+0x1b4/0x450
>  [<ffffffff8006457b>] __down_write_nested+0x12/0x92
>  [<ffffffff88696ae4>] :bonding:bonding_store_slaves+0x25c/0x2f7
>  [<ffffffff801106f7>] sysfs_write_file+0xb9/0xe8
>  [<ffffffff80016b87>] vfs_write+0xce/0x174
>  [<ffffffff80017450>] sys_write+0x45/0x6e
>  [<ffffffff8005d28d>] tracesys+0xd5/0xe0
> 
> It occurs because we are able to change the slave configuarion of a bond while
> the bond interface is down.  The bonding driver initializes some data structures
> only after its ndo_open routine is called.  Among them is the initalization of
> the alb tx and rx hash locks.  So if we add or remove a slave without first
> opening the bond master device, we run the risk of trying to lock/unlock a
> spinlock that has garbage for data in it, which results in our above softlock.
> 
> We could fix it by moving the spin lock initalization to the device creation
> path, but it seems that since we're warning people about not doing this, we
> should probably just disallow them from doing it, so fix it by adding an EINVAL
> return if we're not up yet.  Tested by the reporter and confirmed to fix the
> problem.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

> Reported-by: jtluka@redhat.com
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: "David S. Miller" <daevm@davemloft.net>
> ---
>  drivers/net/bonding/bond_sysfs.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
> index 4059bfc..206c543 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -231,6 +231,7 @@ static ssize_t bonding_store_slaves(struct device *d,
>  	if (!(bond->dev->flags & IFF_UP)) {
>  		pr_warning("%s: doing slave updates when interface is down.\n",
>  			   bond->dev->name);
> +		return -EINVAL;
>  	}
>  
>  	if (!rtnl_trylock())
> -- 
> 1.7.5.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
