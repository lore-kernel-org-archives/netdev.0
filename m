From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH v3 net-next 6/9] bonding: make IS_IP_TARGET_UNUSABLE_ADDRESS an inline function
Date: Thu, 15 May 2014 21:39:56 +0200
Message-ID: <1400182799-22737-7-git-send-email-vfalico@gmail.com>
References: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755839AbaEOTon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 15:44:43 -0400
In-Reply-To: <1400182799-22737-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, use standard IP primitives to check the address.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_main.c    | 2 +-
 drivers/net/bonding/bond_options.c | 4 ++--
 drivers/net/bonding/bonding.h      | 8 +++++---
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 744c471..1af2be5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4195,7 +4195,7 @@ static int bond_check_params(struct bond_params *params)
 		   catch mistakes */
 		__be32 ip;
 		if (!in4_pton(arp_ip_target[i], -1, (u8 *)&ip, -1, NULL) ||
-		    IS_IP_TARGET_UNUSABLE_ADDRESS(ip)) {
+		    !bond_is_ip_target_ok(ip)) {
 			pr_warn("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
 				arp_ip_target[i]);
 			arp_interval = 0;
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index dd7292f..0cf4c1a 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -942,7 +942,7 @@ static int _bond_option_arp_ip_target_add(struct bonding *bond, __be32 target)
 	__be32 *targets = bond->params.arp_targets;
 	int ind;
 
-	if (IS_IP_TARGET_UNUSABLE_ADDRESS(target)) {
+	if (!bond_is_ip_target_ok(target)) {
 		pr_err("%s: invalid ARP target %pI4 specified for addition\n",
 		       bond->dev->name, &target);
 		return -EINVAL;
@@ -987,7 +987,7 @@ static int bond_option_arp_ip_target_rem(struct bonding *bond, __be32 target)
 	unsigned long *targets_rx;
 	int ind, i;
 
-	if (IS_IP_TARGET_UNUSABLE_ADDRESS(target)) {
+	if (!bond_is_ip_target_ok(target)) {
 		pr_err("%s: invalid ARP target %pI4 specified for removal\n",
 		       bond->dev->name, &target);
 		return -EINVAL;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index bb663a4..ac75b0f 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -54,9 +54,6 @@
 		     ((slave)->link == BOND_LINK_UP) && \
 		     bond_is_active_slave(slave))
 
-#define IS_IP_TARGET_UNUSABLE_ADDRESS(a)	\
-	((htonl(INADDR_BROADCAST) == a) ||	\
-	 ipv4_is_zeronet(a))
 /*
  * Less bad way to call ioctl from within the kernel; this needs to be
  * done some other way to get the call out of interrupt context.
@@ -406,6 +403,11 @@ static inline int slave_do_arp_validate_only(struct bonding *bond)
 	return bond->params.arp_validate & BOND_ARP_FILTER;
 }
 
+static inline int bond_is_ip_target_ok(__be32 addr)
+{
+	return !ipv4_is_lbcast(addr) && !ipv4_is_zeronet(addr);
+}
+
 /* Get the oldest arp which we've received on this slave for bond's
  * arp_targets.
  */
-- 
1.8.4
