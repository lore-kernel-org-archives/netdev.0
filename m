From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: easy removals of HIPQUAD using %pI4 format
Date: Wed, 29 Oct 2008 22:39:40 -0700
Message-ID: <1225345180.5496.16.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:51623 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbYJ3Fjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 01:39:44 -0400
Received: by wf-out-1314.google.com with SMTP id 27so393180wfd.4
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 22:39:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a bonus, removes some unnecessary byteswapping.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/infiniband/hw/nes/nes.c |   11 +++--------
 drivers/isdn/i4l/isdn_net.c     |   34 ++++++++++++++--------------------
 drivers/net/bonding/bond_main.c |    4 +---
 3 files changed, 18 insertions(+), 31 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes.c b/drivers/infiniband/hw/nes/nes.c
index 231ed70..fb7d243 100644
--- a/drivers/infiniband/hw/nes/nes.c
+++ b/drivers/infiniband/hw/nes/nes.c
@@ -138,14 +138,9 @@ static int nes_inetaddr_event(struct notifier_block *notifier,
 	struct nes_device *nesdev;
 	struct net_device *netdev;
 	struct nes_vnic *nesvnic;
-	unsigned int addr;
-	unsigned int mask;
-
-	addr = ntohl(ifa->ifa_address);
-	mask = ntohl(ifa->ifa_mask);
-	nes_debug(NES_DBG_NETDEV, "nes_inetaddr_event: ip address " NIPQUAD_FMT
-		  ", netmask " NIPQUAD_FMT ".\n",
-		  HIPQUAD(addr), HIPQUAD(mask));
+
+	nes_debug(NES_DBG_NETDEV, "nes_inetaddr_event: ip address %pI4, netmask %pI4.\n",
+		  &ifa->ifa_address, &ifa->ifa_mask);
 	list_for_each_entry(nesdev, &nes_dev_list, list) {
 		nes_debug(NES_DBG_NETDEV, "Nesdev list entry = 0x%p. (%s)\n",
 				nesdev, nesdev->netdev[0]->name);
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index bb904a0..60c82d7 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1654,9 +1654,10 @@ isdn_net_ciscohdlck_slarp_in(isdn_net_local *lp, struct sk_buff *skb)
 	unsigned char *p;
 	int period;
 	u32 code;
-	u32 my_seq, addr;
-	u32 your_seq, mask;
-	u32 local;
+	u32 my_seq;
+	u32 your_seq;
+	__be32 local;
+	__be32 *addr, *mask;
 	u16 unused;
 
 	if (skb->len < 14)
@@ -1671,27 +1672,20 @@ isdn_net_ciscohdlck_slarp_in(isdn_net_local *lp, struct sk_buff *skb)
 		isdn_net_ciscohdlck_slarp_send_reply(lp);
 		break;
 	case CISCO_SLARP_REPLY:
-		addr = ntohl(*(u32 *)p);
-		mask = ntohl(*(u32 *)(p+4));
-		if (mask != 0xfffffffc)
+		addr = (__be32 *)p;
+		mask = (__be32 *)(p + 4);
+		if (*mask != cpu_to_be32(0xfffffffc))
 			goto slarp_reply_out;
-		if ((addr & 3) == 0 || (addr & 3) == 3)
+		if ((*addr & cpu_to_be32(3)) == cpu_to_be32(0) ||
+		    (*addr & cpu_to_be32(3)) == cpu_to_be32(3))
 			goto slarp_reply_out;
-		local = addr ^ 3;
-		printk(KERN_INFO "%s: got slarp reply: "
-			"remote ip: %d.%d.%d.%d, "
-			"local ip: %d.%d.%d.%d "
-			"mask: %d.%d.%d.%d\n",
-		       lp->netdev->dev->name,
-		       HIPQUAD(addr),
-		       HIPQUAD(local),
-		       HIPQUAD(mask));
+		local = *addr ^ cpu_to_be32(3);
+		printk(KERN_INFO "%s: got slarp reply: remote ip: %pI4, local ip: %pI4 mask: %pI4\n",
+		       lp->netdev->dev->name, addr, &local, mask);
 		break;
   slarp_reply_out:
-		 printk(KERN_INFO "%s: got invalid slarp "
-				 "reply (%d.%d.%d.%d/%d.%d.%d.%d) "
-				 "- ignored\n", lp->netdev->dev->name,
-				 HIPQUAD(addr), HIPQUAD(mask));
+		printk(KERN_INFO "%s: got invalid slarp reply (%pI4/%pI4) - ignored\n",
+		       lp->netdev->dev->name, addr, mask);
 		break;
 	case CISCO_SLARP_KEEPALIVE:
 		period = (int)((jiffies - lp->cisco_last_slarp_in
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 36e89e3..f2da031 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3221,7 +3221,6 @@ static void bond_info_show_master(struct seq_file *seq)
 	struct bonding *bond = seq->private;
 	struct slave *curr;
 	int i;
-	u32 target;
 
 	read_lock(&bond->curr_slave_lock);
 	curr = bond->curr_active_slave;
@@ -3275,8 +3274,7 @@ static void bond_info_show_master(struct seq_file *seq)
 				continue;
 			if (printed)
 				seq_printf(seq, ",");
-			target = ntohl(bond->params.arp_targets[i]);
-			seq_printf(seq, " %d.%d.%d.%d", HIPQUAD(target));
+			seq_printf(seq, " %pI4", &bond->params.arp_targets[i]);
 			printed = 1;
 		}
 		seq_printf(seq, "\n");
-- 
1.6.0.3.756.gb776d



