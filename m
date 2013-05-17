From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 3/4] bonding: arp_ip_count and arp_targets can be wrong
Date: Fri, 17 May 2013 11:00:52 -0700
Message-ID: <30653.1368813652@death.nxdomain>
References: <1368621162-6807-1-git-send-email-nikolay@redhat.com> <1368621162-6807-4-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:47811 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756530Ab3EQSBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 14:01:09 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 17 May 2013 12:01:08 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D13B11FF0022
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 11:55:55 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4HI0srl102802
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 12:00:57 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4HI0r1B031966
	for <netdev@vger.kernel.org>; Fri, 17 May 2013 12:00:54 -0600
In-reply-to: <1368621162-6807-4-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>When getting arp_ip_targets if we encounter a bad IP, arp_ip_count still
>gets increased and all the targets after the wrong one will not be probed
>if arp_interval is enabled after that (unless a new IP target is added
>through sysfs) because of the zero entry, in this case reading
>arp_ip_target through sysfs will show valid targets even if there's a
>zero entry.
>Example: 1.2.3.4,4.5.6.7,blah,5.6.7.8
>When retrieving the list from arp_ip_target the output would be:
>1.2.3.4,4.5.6.7,5.6.7.8
>but there will be a 0 entry between 4.5.6.7 and 5.6.7.8. If arp_interval
>is enabled after that 5.6.7.8 will never be checked because of that.

	This patch looks good for the description above.

>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
>Question about this one: Do we have to disable arp_interval if we have
>obtained at least 1 valid IP address ? 
>I think this can be addressed in a net-next patch.

	My personal thought is that, ideally, it should be all or none,
i.e., either all of the targets are valid and are accepted as a set, and
if any are wrong, the entire set is rejected.

	That change could break existing installations, although
probably only on embedded or other systems without sysfs; regular
distros generally configure bonding via sysfs.

	If we're not going to do it the right way for fear of
compatibility issues, then I'd just leave it alone.  If compatibility
isn't a concern, then I'd fix it as I described above.

	-J

> drivers/net/bonding/bond_main.c | 19 ++++++++-----------
> 1 file changed, 8 insertions(+), 11 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 1a0cc13..d6a96cb 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4470,7 +4470,7 @@ int bond_parse_parm(const char *buf, const struct bond_parm_tbl *tbl)
>
> static int bond_check_params(struct bond_params *params)
> {
>-	int arp_validate_value, fail_over_mac_value, primary_reselect_value;
>+	int arp_validate_value, fail_over_mac_value, primary_reselect_value, i;
>
> 	/*
> 	 * Convert string parameters.
>@@ -4650,19 +4650,18 @@ static int bond_check_params(struct bond_params *params)
> 		arp_interval = BOND_LINK_ARP_INTERV;
> 	}
>
>-	for (arp_ip_count = 0;
>-	     (arp_ip_count < BOND_MAX_ARP_TARGETS) && arp_ip_target[arp_ip_count];
>-	     arp_ip_count++) {
>+	for (arp_ip_count = 0, i = 0;
>+	     (arp_ip_count < BOND_MAX_ARP_TARGETS) && arp_ip_target[i]; i++) {
> 		/* not complete check, but should be good enough to
> 		   catch mistakes */
>-		__be32 ip = in_aton(arp_ip_target[arp_ip_count]);
>-		if (!isdigit(arp_ip_target[arp_ip_count][0]) ||
>-		    ip == 0 || ip == htonl(INADDR_BROADCAST)) {
>+		__be32 ip = in_aton(arp_ip_target[i]);
>+		if (!isdigit(arp_ip_target[i][0]) || ip == 0 ||
>+		    ip == htonl(INADDR_BROADCAST)) {
> 			pr_warning("Warning: bad arp_ip_target module parameter (%s), ARP monitoring will not be performed\n",
>-				   arp_ip_target[arp_ip_count]);
>+				   arp_ip_target[i]);
> 			arp_interval = 0;
> 		} else {
>-			arp_target[arp_ip_count] = ip;
>+			arp_target[arp_ip_count++] = ip;
> 		}
> 	}
>
>@@ -4696,8 +4695,6 @@ static int bond_check_params(struct bond_params *params)
> 	if (miimon) {
> 		pr_info("MII link monitoring set to %d ms\n", miimon);
> 	} else if (arp_interval) {
>-		int i;
>-
> 		pr_info("ARP monitoring set to %d ms, validate %s, with %d target(s):",
> 			arp_interval,
> 			arp_validate_tbl[arp_validate_value].modename,
>-- 
>1.8.1.4

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
