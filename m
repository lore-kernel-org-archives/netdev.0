From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 0/2] bonding: fix 3ad slave (de)init
Date: Fri, 27 Sep 2013 15:10:56 +0200
Message-ID: <1380287458-3488-1-git-send-email-vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752568Ab3I0NKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 09:10:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After 1f718f0f4f97145f4072d2d72dcf85069ca7226d ("bonding: populate
neighbour's private on enslave") the (de)linking of slaves in
bond_enslave/bond_release_one happens in the correct places - after we've
completely initialized the slave (for bond_enslave) and before we've even
began to de-init the slave (for bond_release_one, respectively).

This was done to prevent any RCU readers to see the half-initialized slave
(because the RCU readers aren't blocked by bond->lock or rtnl_lock
usually).

However, 802.3ad logic, in several places, relied on the fact that the
slave is still linked to the bond.

Fix it by correctly handling these cases - we shouldn't rely that the slave
is linked before fully initialized and, respectively, that the slave is
still linked while it's being removed.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
 drivers/net/bonding/bond_3ad.c  | 4 +++-
 drivers/net/bonding/bond_main.c | 2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)
