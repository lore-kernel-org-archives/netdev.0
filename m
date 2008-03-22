From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/4] bonding: Fix locking in 802.3ad mode
Date: Fri, 21 Mar 2008 22:29:33 -0700
Message-ID: <1206163777364-git-send-email-fubar@us.ibm.com>
References: <12061637763004-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:42265 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493AbYCVF3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 01:29:44 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2M5SHT4009243
	for <netdev@vger.kernel.org>; Sat, 22 Mar 2008 01:28:17 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2M5TcLS186964
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 23:29:38 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2M5TbVH030448
	for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 23:29:38 -0600
In-Reply-To: <12061637763004-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	The 802.3ad state machine lock can be acquired in both softirq and
not softirq context, but was not held at _bh to prevent a deadlock (which
could occur if a LACPDU arrived and was processed while the lock was
held).

	Corrected this, now hold the state machine lock at _bh to prevent
deadlock.

	Bug reported by Todd Fleisher <todd@fleish.org>.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_3ad.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index cb3c6fa..d16e0e1 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -310,7 +310,7 @@ static inline int __check_agg_selection_timer(struct port *port)
  */
 static inline void __get_rx_machine_lock(struct port *port)
 {
-	spin_lock(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
+	spin_lock_bh(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
 }
 
 /**
@@ -320,7 +320,7 @@ static inline void __get_rx_machine_lock(struct port *port)
  */
 static inline void __release_rx_machine_lock(struct port *port)
 {
-	spin_unlock(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
+	spin_unlock_bh(&(SLAVE_AD_INFO(port->slave).rx_machine_lock));
 }
 
 /**
-- 
1.5.2.4

