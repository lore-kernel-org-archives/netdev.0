From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 7/7] net: FIX bonding sysfs rtnl_lock deadlock
Date: Wed, 13 May 2009 20:02:50 -0700
Message-ID: <m1zldgpesl.fsf@fess.ebiederm.org>
References: <m13ab8s8cr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47690 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762260AbZENDCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 23:02:52 -0400
In-Reply-To: <m13ab8s8cr.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Wed\, 13 May 2009 19\:53\:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sysfs files for a network device can not unconditionally take the
rtnl_lock as the bonding sysfs files do.  If someone accesses those
sysfs files while the network device is being unregistered with the
rtnl_lock held we will deadlock.

So use trylock and restart_syscall to avoid this problem.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/bonding/bond_sysfs.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index d287315..3a1b7b0 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -251,7 +251,8 @@ static ssize_t bonding_store_slaves(struct device *d,
 
 	/* Note:  We can't hold bond->lock here, as bond_create grabs it. */
 
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return restart_syscall();
 	down_write(&(bonding_rwsem));
 
 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
@@ -1171,7 +1172,8 @@ static ssize_t bonding_store_primary(struct device *d,
 	struct slave *slave;
 	struct bonding *bond = to_bond(d);
 
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return restart_syscall();
 	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
 
@@ -1288,7 +1290,8 @@ static ssize_t bonding_store_active_slave(struct device *d,
         struct slave *new_active = NULL;
 	struct bonding *bond = to_bond(d);
 
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return restart_syscall();
 	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
 
-- 
1.6.0.6

