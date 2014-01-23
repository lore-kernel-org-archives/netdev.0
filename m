From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 0/2] bonding: fix locking in bond_ab_arp_probe
Date: Thu, 23 Jan 2014 12:16:02 +0100
Message-ID: <1390475764-7675-1-git-send-email-vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574AbaAWLUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 06:20:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After the latest patches, on every call of bond_ab_arp_probe() without an
active slave I see the following warning:

[    7.912314] RTNL: assertion failed at net/core/dev.c (4494)
...
[    7.922495]  [<ffffffff817acc6f>] dump_stack+0x51/0x72
[    7.923714]  [<ffffffff8168795e>] netdev_master_upper_dev_get+0x6e/0x70
[    7.924940]  [<ffffffff816a2a66>] rtnl_link_fill+0x116/0x260
[    7.926143]  [<ffffffff817acc6f>] ? dump_stack+0x51/0x72
[    7.927333]  [<ffffffff816a350c>] rtnl_fill_ifinfo+0x95c/0xb90
[    7.928529]  [<ffffffff8167af2b>] ? __kmalloc_reserve+0x3b/0xa0
[    7.929681]  [<ffffffff8167bfcf>] ? __alloc_skb+0x9f/0x1e0
[    7.930827]  [<ffffffff816a3b64>] rtmsg_ifinfo+0x84/0x100
[    7.931960]  [<ffffffffa00bca07>] bond_ab_arp_probe+0x1a7/0x370 [bonding]
[    7.933133]  [<ffffffffa00bcd78>] bond_activebackup_arp_mon+0x1a8/0x2f0 [bonding]
...

It happens because in bond_ab_arp_probe() we change the flags of a slave
without holding the RTNL lock.

To fix this - remove the useless curr_active_lock, RCUify it completely and
lock RTNL while changing the slave's flags.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_main.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)
