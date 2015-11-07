From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: Regression in bonding driver - devices without set_mac
Date: Fri, 06 Nov 2015 18:31:30 -0800
Message-ID: <10340.1446863490@famine>
References: <CABEgq95FYdt86-KEgkarUr-9g_mHoesV6B7OtrFut4pBR0UGcQ@mail.gmail.com> <6968.1446849960@famine> <CABEgq96o2dXi06rLh6xmLGYVzh0-fVPs0rpjv8X3NTsk_=8+JQ@mail.gmail.com>
Cc: netdev@vger.kernel.org, Veaceslav Falico <vfalico@gmail.com>
To: Toby Corkindale <tjc@wintrmute.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:41516 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbbKGCbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 21:31:34 -0500
In-reply-to: <CABEgq96o2dXi06rLh6xmLGYVzh0-fVPs0rpjv8X3NTsk_=8+JQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Toby Corkindale <tjc@wintrmute.net> wrote:
[...]
>The thing is, I've been running PPP devices in balance-rr mode for
>quite a while. It worked fine, and I'd like to continue having that
>functionality.  These changes to the kernel have broken that
>functionality, by requiring the MAC address support unconditionally.
>
>I guess using PPP devices is a special case, but it would be great if
>that special case could continue to be supported.

	Could you describe your configuration / use case a bit more?

	The nominal reason for the MAC change in balance-rr or
balance-xor modes is that those modes are designed to interoperate with
Etherchannel (static link aggregation) type of systems, which expect all
ports participating in the aggregation to use the same MAC address.

	Relaxing the restriction is likely a matter of causing
fail_over_mac to be obeyed in addtional modes other than active-backup,
which is actually what's catching the ppp case right now.  The check for
the set_mac function passes, but later, the test for "should the slave's
MAC be changed" is

        if (!bond->params.fail_over_mac ||
            BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
		[ change the slave MAC ]
	}

	so this block is entered for anything other than active-backup
mode with fail_over_mac enabled.  This block was changed for

commit 00503b6f702eaf23e7257d6287da72805d7d014c
Author: dingtianhong <dingtianhong@huawei.com>
Date:   Sat Jan 25 13:00:29 2014 +0800

    bonding: fail_over_mac should only affect AB mode at enslave and removal pro
cessing

	So that's probably when you saw the behavior change.

	Are you able to test a patch?  I believe the following would
change the behavior, although some of the release logic may not be
correct (I've not tested this).

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b4351caf8e01..5f3632544d52 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1451,8 +1451,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 */
 	ether_addr_copy(new_slave->perm_hwaddr, slave_dev->dev_addr);
 
-	if (!bond->params.fail_over_mac ||
-	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
+	if (!bond->params.fail_over_mac) {
 		/* Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
 		 */
@@ -1725,8 +1724,7 @@ err_close:
 	dev_close(slave_dev);
 
 err_restore_mac:
-	if (!bond->params.fail_over_mac ||
-	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
+	if (!bond->params.fail_over_mac) {
 		/* XXX TODO - fom follow mode needs to change master's
 		 * MAC if this slave's MAC is in use by the bond, or at
 		 * least print a warning.
@@ -1823,8 +1821,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	RCU_INIT_POINTER(bond->current_arp_slave, NULL);
 
-	if (!all && (!bond->params.fail_over_mac ||
-		     BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP)) {
+	if (!all && (!bond->params.fail_over_mac)) {
 		if (ether_addr_equal_64bits(bond_dev->dev_addr, slave->perm_hwaddr) &&
 		    bond_has_slaves(bond))
 			netdev_warn(bond_dev, "the permanent HWaddr of %s - %pM - is still in use by %s - set the HWaddr of %s to a different address to avoid conflicts\n",
@@ -1905,8 +1902,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);
 
-	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE ||
-	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
+	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
 		/* restore original ("permanent") mac address */
 		ether_addr_copy(addr.sa_data, slave->perm_hwaddr);
 		addr.sa_family = slave_dev->type;


	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
