From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net v4] bonding: add ip checks when store ip target
Date: Fri, 15 Nov 2013 09:58:58 +0800
Message-ID: <52857FE2.5060400@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:46000 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756039Ab3KOCAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 21:00:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 513509eecdee98d72668219aead9784d56dbad0f Mon Sep 17 00:00:00 2001
From: Wang Weidong <wangweidong1@huawei.com>
Date: Fri, 15 Nov 2013 10:34:30 -0500
Subject: [PATCH] bonding: add ip checks when store ip target

I met a Bug when I add ip target with the wrong ip address:

echo +500.500.500.500 > /sys/class/net/bond0/bonding/arp_ip_target

the wrong ip address will transfor to 245.245.245.244 and add
to the ip target success, it is uncorrect, so I add checks to avoid
adding wrong address.

The in4_pton() will set wrong ip address to 0.0.0.0, it will return by
the next check and will not add to ip target.

v2
According Veaceslav's opinion, simplify the code.

v3
According Veaceslav's opinion, add broadcast check and make a micro
definition to package it.

v4
Solve the problem of the format which David point out.

Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 19 ++++++-------------
 drivers/net/bonding/bonding.h    |  3 +++
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 47749c9..21dd2a5 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -611,15 +611,14 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 		return restart_syscall();
 
 	targets = bond->params.arp_targets;
-	newtarget = in_aton(buf + 1);
+	if (!in4_pton(buf + 1, -1, (u8 *)&newtarget, -1, NULL) ||
+	    IS_IP_TARGET_UNUSABLE_ADDRESS(newtarget)) {
+		pr_err("%s: invalid ARP target %pI4 specified for addition\n",
+		       bond->dev->name, &newtarget);
+		goto out;
+	}
 	/* look for adds */
 	if (buf[0] == '+') {
-		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			pr_err("%s: invalid ARP target %pI4 specified for addition\n",
-			       bond->dev->name, &newtarget);
-			goto out;
-		}
-
 		if (bond_get_targets_ip(targets, newtarget) != -1) { /* dup */
 			pr_err("%s: ARP target %pI4 is already present\n",
 			       bond->dev->name, &newtarget);
@@ -642,12 +641,6 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 		targets[ind] = newtarget;
 		write_unlock_bh(&bond->lock);
 	} else if (buf[0] == '-')	{
-		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			pr_err("%s: invalid ARP target %pI4 specified for removal\n",
-			       bond->dev->name, &newtarget);
-			goto out;
-		}
-
 		ind = bond_get_targets_ip(targets, newtarget);
 		if (ind == -1) {
 			pr_err("%s: unable to remove nonexistent ARP target %pI4.\n",
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 046a605..253d5da 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -63,6 +63,9 @@
 		(((mode) == BOND_MODE_TLB) ||	\
 		 ((mode) == BOND_MODE_ALB))
 
+#define IS_IP_TARGET_UNUSABLE_ADDRESS(a)	\
+	((htonl(INADDR_BROADCAST) == a) ||	\
+	 ipv4_is_zeronet(a))
 /*
  * Less bad way to call ioctl from within the kernel; this needs to be
  * done some other way to get the call out of interrupt context.
-- 
1.7.12
