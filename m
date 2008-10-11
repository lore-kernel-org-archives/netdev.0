From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH] [stable 2.6.27.y] don't take the mdio_lock in atl1e_probe
Date: Sat, 11 Oct 2008 10:05:01 -0500
Message-ID: <20081011100501.7ff818ce@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <willy@linux.intel.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	Chris Snook <csnook@redhat.com>,
	Jie Yang <jie.yang@atheros.com>, netdev@vger.kernel.org,
	Jay Cliburn <jcliburn@gmail.com>, nm127@freemail.hu,
	Andrew Morton <akpm@linux-foundation.org>
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([207.115.11.53]:50664 "EHLO
	fmailhost03.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbYJKPFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 11:05:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Wilcox <matthew@wil.cx>

Upstream commit: f382a0a8e9403c6d7f8b2cfa21e41fefb5d0c9bd

This fixes bug 11736.

http://marc.info/?l=linux-netdev&m=122367387219316&w=2

Lockdep warns about the mdio_lock taken with interrupts enabled then
later taken from interrupt context.  Initially, I considered changing
these to spin_lock_irq/spin_unlock_irq, but then I looked at
atl1e_phy_init() and saw that it calls msleep().  Sleeping while
holding a spinlock is not allowed either.

In the probe path, we haven't registered the interrupt handler, so
it can't poke at this card yet.  It's before we call register_netdev(),
so I don't think any other threads can reach this card either.  If I'm
right, we don't need a spinlock at all.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---

Resending with correct -stable email address.

 drivers/net/atl1e/atl1e_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_main.c
b/drivers/net/atl1e/atl1e_main.c index 7685b99..9b60352 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2390,9 +2390,7 @@ static int __devinit atl1e_probe(struct pci_dev
*pdev, }

        /* Init GPHY as early as possible due to power saving issue  */
-       spin_lock(&adapter->mdio_lock);
        atl1e_phy_init(&adapter->hw);
-       spin_unlock(&adapter->mdio_lock);
        /* reset the controller to
         * put the device in a known good starting state */
        err = atl1e_reset_hw(&adapter->hw);
--
1.5.5.1
