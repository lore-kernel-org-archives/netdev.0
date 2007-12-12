From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c (1055)
Date: Wed, 12 Dec 2007 09:46:55 -0800
Message-ID: <28503.1197481615@death>
References: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au>
Cc: akpm@linux-foundation.org (Andrew Morton), olel@ans.pl,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, andy@greyhouse.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:50221 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047AbXLLRrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 12:47:03 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBCHl0br024429
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 12:47:00 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBCHl0JB493650
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 12:47:00 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBCHkxYC024719
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 12:47:00 -0500
In-reply-to: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:

>> diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-fix drivers/net/bonding/bond_sysfs.c
>> --- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
>> +++ a/drivers/net/bonding/bond_sysfs.c
>> @@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
>> out:
>>        write_unlock_bh(&bond->lock);
>> 
>> -       rtnl_unlock();
>> -
>
>Looking at the changeset that added this perhaps the intention
>is to hold the lock? If so we should add an rtnl_lock to the start
>of the function.

	Yes, this function needs to hold locks, and more than just
what's there now.  I believe the following should be correct; I haven't
tested it, though (I'm supposedly on vacation right now).

	The following change should be correct for the
bonding_store_primary case discussed in this thread, and also corrects
the bonding_store_active case which performs similar functions.

	The bond_change_active_slave and bond_select_active_slave
functions both require rtnl, bond->lock for read and curr_slave_lock for
write_bh, and no other locks.  This is so that the lower level
mode-specific functions can release locks down to just rtnl in order to
call, e.g., dev_set_mac_address with the locks it expects (rtnl only).

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 11b76b3..28a2d80 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1075,7 +1075,10 @@ static ssize_t bonding_store_primary(struct device *d,
 	struct slave *slave;
 	struct bonding *bond = to_bond(d);
 
-	write_lock_bh(&bond->lock);
+	rtnl_lock();
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
 		       ": %s: Unable to set primary slave; %s is in mode %d\n",
@@ -1109,8 +1112,8 @@ static ssize_t bonding_store_primary(struct device *d,
 		}
 	}
 out:
-	write_unlock_bh(&bond->lock);
-
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
 	rtnl_unlock();
 
 	return count;
@@ -1190,7 +1193,8 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	rtnl_lock();
-	write_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
 
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
@@ -1247,7 +1251,8 @@ static ssize_t bonding_store_active_slave(struct device *d,
 		}
 	}
 out:
-	write_unlock_bh(&bond->lock);
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
 	rtnl_unlock();
 
 	return count;

