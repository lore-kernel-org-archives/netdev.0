From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 3/4] bonding: arp_ip_count and arp_targets can be wrong
Date: Wed, 15 May 2013 14:32:41 +0200
Message-ID: <1368621162-6807-4-git-send-email-nikolay@redhat.com>
References: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12650 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758868Ab3EOMgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 08:36:18 -0400
In-Reply-To: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When getting arp_ip_targets if we encounter a bad IP, arp_ip_count still
gets increased and all the targets after the wrong one will not be probed
if arp_interval is enabled after that (unless a new IP target is added
through sysfs) because of the zero entry, in this case reading
arp_ip_target through sysfs will show valid targets even if there's a
zero entry.
Example: 1.2.3.4,4.5.6.7,blah,5.6.7.8
When retrieving the list from arp_ip_target the output would be:
1.2.3.4,4.5.6.7,5.6.7.8
but there will be a 0 entry between 4.5.6.7 and 5.6.7.8. If arp_interval
is enabled after that 5.6.7.8 will never be checked because of that.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
Question about this one: Do we have to disable arp_interval if we have
obtained at least 1 valid IP address ? 
I think this can be addressed in a net-next patch.

 drivers/net/bonding/bond_main.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1a0cc13..d6a96cb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4470,7 +4470,7 @@ int bond_parse_parm(const char *buf, const struct bond_parm_tbl *tbl)
 
 static int bond_check_params(struct bond_params *params)
 {
-	int arp_validate_value, fail_over_mac_value, primary_reselect_value;
+	int arp_validate_value, fail_over_mac_value, primary_reselect_value, i;
 
 	/*
 	 * Convert string parameters.
@@ -4650,19 +4650,18 @@ static int bond_check_params(struct bond_params *params)
 		arp_interval = BOND_LINK_ARP_INTERV;
 	}
 
-	for (arp_ip_count = 0;
-	     (arp_ip_count < BOND_MAX_ARP_TARGETS) && arp_ip_target[arp_ip_count];
-	     arp_ip_count++) {
+	for (arp_ip_count = 0, i = 0;
+	     (arp_ip_count < BOND_MAX_ARP_TARGETS) && arp_ip_target[i]; i++) {
 		/* not complete check, but should be good enough to
 		   catch mistakes */
-		__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
-		if (!isdigit(arp_ip_target[arp_ip_count][0]) ||
-		    ip == 0 || ip == htonl(INADDR_BROADCAST)) {
+		__be32 ip = in_aton(arp_ip_target[i]);
+		if (!isdigit(arp_ip_target[i][0]) || ip == 0 ||
+		    ip == htonl(INADDR_BROADCAST)) {
 			pr_warning("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
-				   arp_ip_target[arp_ip_count]);
+				   arp_ip_target[i]);
 			arp_interval = 0;
 		} else {
-			arp_target[arp_ip_count] = ip;
+			arp_target[arp_ip_count++] = ip;
 		}
 	}
 
@@ -4696,8 +4695,6 @@ static int bond_check_params(struct bond_params *params)
 	if (miimon) {
 		pr_info("MII link monitoring set to %d ms\n", miimon);
 	} else if (arp_interval) {
-		int i;
-
 		pr_info("ARP monitoring set to %d ms, validate %s, with %d target(s):",
 			arp_interval,
 			arp_validate_tbl[arp_validate_value].modename,
-- 
1.8.1.4
