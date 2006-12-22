From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Generic PHY lib vs. locking
Date: Fri, 22 Dec 2006 15:07:53 +1100
Message-ID: <1166760473.6673.85.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52058 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754447AbWLVEH5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 23:07:57 -0500
To: Andy Fleming <afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy !

I've been looking at porting various drivers (EMAC, sungem,
spider_net, ...) to the generic PHY stuff. However, I have one
significant problem here.

One of the things I've been trying to do lately with EMAC and that I
plan to do with others, is to have the PHY polling entirely operate at
task level (along with other "slow" parts of the network driver like
timeout handling etc...).

This makes a lot of locking easier, allowing to use mutexes instead of
locks (less latencies), allowing to sleep waiting for MDIO operations to
complete, etc... it's generall all benefit.

It's especially useful in a case like EMAC where several EMACs can share
MDIO lines, so we need exclusive access, and that might involve even a
second layer of exclusion for access to the RGMII or ZMII layer. mutexes
are really the best approach for that sort of non-speed critical
activities.

However, the generic PHY layer defeats that by it's heavy usage of
spin_lock_bh and timer.

One solution would be to change it to use a mutex instead of a lock as
well, though that would change the requirements of where phy_start/stop
can be called, and use a delayed work queue instead of a timer.

I could do all of these changes provided everybody agrees, though I
suppose all existing network drivers using that PHY layer might need to
be adapted. How many do we have nowadays ?

Also, I see your comments about not calling flush_scheduled_work() in
phy_stop() because of rtnl_lock()... What is the problem here ?
dev_close() ?

Ben.


