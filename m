From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next] bonding: make slave status notifications
 GFP_ATOMIC
Date: Thu, 6 Mar 2014 14:22:25 +0100
Message-ID: <20140306132225.GC4773@redhat.com>
References: <1394025353-5496-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Thomas Glanzmann <thomas@glanzmann.de>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049AbaCFNWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 08:22:41 -0500
Content-Disposition: inline
In-Reply-To: <1394025353-5496-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 05, 2014 at 02:15:53PM +0100, Veaceslav Falico wrote:
>Currently we're using GFP_KERNEL, however there are some path(s) where we
>can hold some spinlocks, specifically bond->curr_slave_lock:
>
>[    4.722916] BUG: sleeping function called from invalid context at mm/slub.c:965
>[    4.724438] in_atomic(): 1, irqs_disabled(): 0, pid: 940, name: ifup-eth
>[    4.726034] 5 locks held by ifup-eth/940:
>...snip...
>[    4.734646]  #4:  (&bond->curr_slave_lock){+...+.}, at: [<ffffffffa00badc6>] bond_enslave+0xda6/0xdd0 [bonding]
>...snip...
>[    4.759081]  [<ffffffffa00b6f11>] bond_change_active_slave+0x191/0x3b0 [bonding]
>[    4.760917]  [<ffffffffa00b7227>] bond_select_active_slave+0xf7/0x1d0 [bonding]
>[    4.762751]  [<ffffffffa00badce>] bond_enslave+0xdae/0xdd0 [bonding]
>...snip...
>
>As it's out of hot path and is a really rare event - change the gfp_t flags
>to GFP_ATOMIC to avoid sleeping under spinlock.
>
>CC: Thomas Glanzmann <thomas@glanzmann.de>
>CC: Ding Tianhong <dingtianhong@huawei.com>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Self-NAK as the net got synced and there is a conflicting fix from
5e5b0665 ("bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c for
802.3ad mode"), which adds a lot of complexity, postpones the notifications
(and makes them kind of useless cause the state might have been changed
again), and still doesn't fix all the cases.

I'll re-send the patchset.

>---
> drivers/net/bonding/bonding.h | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index 4303628..4cd451d 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -292,7 +292,7 @@ static inline void bond_set_active_slave(struct slave *slave)
> {
> 	if (slave->backup) {
> 		slave->backup = 0;
>-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
>+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
> 	}
> }
>
>@@ -300,7 +300,7 @@ static inline void bond_set_backup_slave(struct slave *slave)
> {
> 	if (!slave->backup) {
> 		slave->backup = 1;
>-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
>+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
> 	}
> }
>
>-- 
>1.8.4
>
