From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] Bonding: fix zero address hole bug in arp_ip_target list
Date: Fri, 10 Apr 2009 23:51:19 -0700
Message-ID: <623.1239432679@death.nxdomain.ibm.com>
References: <bug-13006-10286@http.bugzilla.kernel.org/> <1239417674-8374-1-git-send-email-brian.haley@hp.com>
Cc: steve@astutenetworks.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, akpm@linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:55913 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966AbZDKGvP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2009 02:51:15 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3B6qvVh005979
	for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 02:52:57 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3B6pEW2193558
	for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 02:51:14 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3B6nXD9002189
	for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 02:49:34 -0400
In-reply-to: <1239417674-8374-1-git-send-email-brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote:

>Fix a zero address hole bug in the bonding arp_ip_target list
>that was causing the bond to ignore ARP replies (bugz 13006).
>Instead of just setting the array entry to zero, we now
>copy any additional entries down one slot, putting the
>zero entry at the end.  With this change we can now have
>all the loops that walk the array stop when they hit a zero
>since there will be no addresses after it.
>
>Signed-off-by: Brian Haley <brian.haley@hp.com>

	This all looks reasonable to me.  This patch appears to be an
extension of some code (not as a patch) provided in bugzilla 13006 by
Steve Howard <steve@astutenetworks.com>, so I suspect he should sign off
on this as well, or at the very least be credited in the log; I'd write
that as:

	Changes are based in part on code fragment provided in kernel
bugzilla 13006 by Steve Howard <steve@astutenetworks.com>.

	This can go to -stable, too.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>---
> Documentation/networking/bonding.txt |    2 +-
> drivers/net/bonding/bond_main.c      |    5 ++---
> drivers/net/bonding/bond_sysfs.c     |   14 ++++++++------
> 3 files changed, 11 insertions(+), 10 deletions(-)
>
>diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>index 5ede747..0876275 100644
>--- a/Documentation/networking/bonding.txt
>+++ b/Documentation/networking/bonding.txt
>@@ -1242,7 +1242,7 @@ monitoring is enabled, and vice-versa.
> To add ARP targets:
> # echo +192.168.0.100 > /sys/class/net/bond0/bonding/arp_ip_target
> # echo +192.168.0.101 > /sys/class/net/bond0/bonding/arp_ip_target
>-	NOTE:  up to 10 target addresses may be specified.
>+	NOTE:  up to 16 target addresses may be specified.
>
> To remove an ARP target:
> # echo -192.168.0.100 > /sys/class/net/bond0/bonding/arp_ip_target
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 99610f3..63369b6 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2570,7 +2570,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
>
> 	for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
> 		if (!targets[i])
>-			continue;
>+			break;
> 		pr_debug("basa: target %x\n", targets[i]);
> 		if (list_empty(&bond->vlan_list)) {
> 			pr_debug("basa: empty vlan: arp_send\n");
>@@ -2677,7 +2677,6 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
> 	int i;
> 	__be32 *targets = bond->params.arp_targets;
>
>-	targets = bond->params.arp_targets;
> 	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
> 		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip) %d\n",
> 			&sip, &tip, i, &targets[i], bond_has_this_ip(bond, tip));
>@@ -3303,7 +3302,7 @@ static void bond_info_show_master(struct seq_file *seq)
>
> 		for(i = 0; (i < BOND_MAX_ARP_TARGETS) ;i++) {
> 			if (!bond->params.arp_targets[i])
>-				continue;
>+				break;
> 			if (printed)
> 				seq_printf(seq, ",");
> 			seq_printf(seq, " %pI4", &bond->params.arp_targets[i]);
>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
>index 18cf478..d287315 100644
>--- a/drivers/net/bonding/bond_sysfs.c
>+++ b/drivers/net/bonding/bond_sysfs.c
>@@ -684,17 +684,15 @@ static ssize_t bonding_store_arp_targets(struct device *d,
> 			goto out;
> 		}
> 		/* look for an empty slot to put the target in, and check for dupes */
>-		for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
>+		for (i = 0; (i < BOND_MAX_ARP_TARGETS) && !done; i++) {
> 			if (targets[i] == newtarget) { /* duplicate */
> 				printk(KERN_ERR DRV_NAME
> 				       ": %s: ARP target %pI4 is already present\n",
> 				       bond->dev->name, &newtarget);
>-				if (done)
>-					targets[i] = 0;
> 				ret = -EINVAL;
> 				goto out;
> 			}
>-			if (targets[i] == 0 && !done) {
>+			if (targets[i] == 0) {
> 				printk(KERN_INFO DRV_NAME
> 				       ": %s: adding ARP target %pI4.\n",
> 				       bond->dev->name, &newtarget);
>@@ -720,12 +718,16 @@ static ssize_t bonding_store_arp_targets(struct device *d,
> 			goto out;
> 		}
>
>-		for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
>+		for (i = 0; (i < BOND_MAX_ARP_TARGETS) && !done; i++) {
> 			if (targets[i] == newtarget) {
>+				int j;
> 				printk(KERN_INFO DRV_NAME
> 				       ": %s: removing ARP target %pI4.\n",
> 				       bond->dev->name, &newtarget);
>-				targets[i] = 0;
>+				for (j = i; (j < (BOND_MAX_ARP_TARGETS-1)) && targets[j+1]; j++)
>+					targets[j] = targets[j+1];
>+
>+				targets[j] = 0;
> 				done = 1;
> 			}
> 		}
>-- 
>1.5.4.3
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
