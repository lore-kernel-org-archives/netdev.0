From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: [PATCH v2] ipv6: Reparent temporary address(es) if global address
 was, deleted from userspace
Date: Mon, 07 Apr 2014 07:43:12 +0200
Message-ID: <53423AF0.5080308@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:59933 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750743AbaDGFn1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2014 01:43:27 -0400
Received: from [192.168.178.101] ([84.142.80.96]) by smtp.web.de (mrweb101)
 with ESMTPSA (Nemesis) id 0MPYB3-1WbhAV0Caf-004jIK for
 <netdev@vger.kernel.org>; Mon, 07 Apr 2014 07:43:26 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the kernel takes care of global and temporary addresses it can happen
that the global address is deleted from userspace,
e.g. by network managers in case the link goes (temporarily) down.
In addition to the then orphaned temporary address(es) the next RA will
create a new temporary address. Therefore we might end up with more than
one non-deprecated temporary address for the same prefix for a longer
period of time (>regen_advance). According to RfC4941 sect. 3.4 this
should not happen.

Fix this by reparenting orphaned temporary addresses.

v2: style fixes

Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>
---
 net/ipv6/addrconf.c | 30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6c7fa08..8072968 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2077,14 +2077,33 @@ static void manage_tempaddrs(struct inet6_dev *idev,
 {
 	u32 flags;
 	struct inet6_ifaddr *ift;
+	unsigned long regen_advance;
 
 	read_lock_bh(&idev->lock);
+	regen_advance = idev->cnf.regen_max_retry *
+			idev->cnf.dad_transmits *
+			NEIGH_VAR(idev->nd_parms, RETRANS_TIME) / HZ;
 	/* update all temporary addresses in the list */
 	list_for_each_entry(ift, &idev->tempaddr_list, tmp_list) {
 		int age, max_valid, max_prefered;
+		bool reparent = false;
 
-		if (ifp != ift->ifpub)
-			continue;
+		spin_lock(&ift->lock);
+		if (ifp != ift->ifpub) {
+			/* reparent if orphaned temporary address with same
+			 * prefix is found
+			 */
+			if (ipv6_prefix_equal(&ift->addr, &ifp->addr,
+					      ift->prefix_len)) {
+				in6_ifa_hold(ifp);
+				in6_ifa_put(ift->ifpub);
+				ift->ifpub = ifp;
+				reparent = true;
+			} else {
+				spin_unlock(&ift->lock);
+				continue;
+			}
+		}
 
 		/* RFC 4941 section 3.3:
 		 * If a received option will extend the lifetime of a public
@@ -2110,7 +2129,6 @@ static void manage_tempaddrs(struct inet6_dev *idev,
 		if (prefered_lft > max_prefered)
 			prefered_lft = max_prefered;
 
-		spin_lock(&ift->lock);
 		flags = ift->flags;
 		ift->valid_lft = valid_lft;
 		ift->prefered_lft = prefered_lft;
@@ -2119,6 +2137,12 @@ static void manage_tempaddrs(struct inet6_dev *idev,
 			ift->flags &= ~IFA_F_DEPRECATED;
 
 		spin_unlock(&ift->lock);
+		/* Don't create a temporary address if we reparented one which
+		 * is preferred more than regen_advance
+		 */
+		if (reparent && prefered_lft > regen_advance)
+			create = false;
+
 		if (!(flags&IFA_F_TENTATIVE))
 			ipv6_ifa_notify(0, ift);
 	}
-- 
1.9.1.315.g3f09db0.dirty
