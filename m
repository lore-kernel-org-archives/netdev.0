From: Maxim Uvarov <maxim.uvarov@oracle.com>
Subject: [PATCH] bond_alb: do not disable BH under netpoll
Date: Tue,  3 Jan 2012 18:20:18 -0800
Message-ID: <1325643618-3051-1-git-send-email-maxim.uvarov@oracle.com>
Cc: Maxim Uvarov <maxim.uvarov@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:62317 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821Ab2ADCW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 21:22:58 -0500
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by acsinet15.oracle.com (Switch-3.4.4/Switch-3.4.4) with ESMTP id q042MuM4011567
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 4 Jan 2012 02:22:57 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id q042MuJg004341
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 4 Jan 2012 02:22:56 GMT
Received: from abhmt102.oracle.com (abhmt102.oracle.com [141.146.116.54])
	by acsmt357.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id q042Mtvi020407
	for <netdev@vger.kernel.org>; Tue, 3 Jan 2012 20:22:55 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not disable BH if interrupts are already disabled
(netpoll case).
Signed-off-by: Maxim Uvarov <maxim.uvarov@oracle.com>
---
 drivers/net/bonding/bond_alb.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index d4fbd2e..69eeb36 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -101,12 +101,18 @@ static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
 
 static inline void _lock_tx_hashtbl(struct bonding *bond)
 {
-	spin_lock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	if (unlikely(irqs_disabled())) /*netpoll case*/
+		spin_lock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	else
+		spin_lock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
 }
 
 static inline void _unlock_tx_hashtbl(struct bonding *bond)
 {
-	spin_unlock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	if (unlikely(irqs_disabled())) /*netpoll case*/
+		spin_unlock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	else
+		spin_unlock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
 }
 
 /* Caller must hold tx_hashtbl lock */
-- 
1.7.4.1
