From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCH 1/2] Remove unnecessary locks from rtnetlink
Date: Fri,  1 Feb 2008 17:07:33 +0100
Message-ID: <12018820542721-git-send-email-panther@balabit.hu>
References: <12018820194128-git-send-email-panther@balabit.hu>
Cc: netdev@vger.kernel.org, Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:53328 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753845AbYBAQHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:07:36 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 78D18C1638
	for <netdev@vger.kernel.org>; Fri,  1 Feb 2008 17:07:35 +0100 (CET)
In-Reply-To: <12018820194128-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The do_setlink() function is protected by rtnl, additional locks are unnecessary.
and the set_operstate() function is called from protected parts. Locks removed
from both functions.

The set_operstate() is also called from rtnl_create_link() and from no other places.
In rtnl_create_link() none of the changes is protected by set_lock_bh() except
inside set_operstate(), different locking scheme is not necessary
for the operstate.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 net/core/rtnetlink.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ddbdde8..724e8f5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -565,9 +565,7 @@ static void set_operstate(struct net_device *dev, unsigned char transition)
 	}
 
 	if (dev->operstate != operstate) {
-		write_lock_bh(&dev_base_lock);
 		dev->operstate = operstate;
-		write_unlock_bh(&dev_base_lock);
 		netdev_state_change(dev);
 	}
 }
@@ -882,9 +880,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 
 	if (tb[IFLA_LINKMODE]) {
-		write_lock_bh(&dev_base_lock);
 		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
-		write_unlock_bh(&dev_base_lock);
 	}
 
 	err = 0;
-- 
1.5.2.5

