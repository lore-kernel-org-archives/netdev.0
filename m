From: lorenzo@google.com (Lorenzo Colitti)
Subject: [PATCH] ipv6: updates to privacy addresses per RFC 4941.
Date: Tue, 26 Jul 2011 16:50:49 -0700 (PDT)
Message-ID: <20110726235049.6D52516A59B@drone1.mtv.corp.google.com>
Cc: lorenzo@google.com, yoshfuji@linux-ipv6.org, jpa@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:35450 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064Ab1GZXuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 19:50:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the code to handle some of the differences between
RFC 3041 and RFC 4941, which obsoletes it. Also a couple
of janitorial fixes.

- Allow router advertisements to increase the lifetime of
  temporary addresses. This was not allowed by RFC 3041,
  but is specified by RFC 4941. It is useful when RA
  lifetimes are lower than TEMP_{VALID,PREFERRED}_LIFETIME:
  in this case, the previous code would delete or deprecate
  addresses prematurely.

- Change the default of MAX_RETRY to 3 per RFC 4941.

- Add a comment to clarify that the preferred and valid
  lifetimes in inet6_ifaddr are relative to the timestamp.

- Shorten lines to 80 characters in a couple of places.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/addrconf.h |    2 +-
 include/net/if_inet6.h |    1 +
 net/ipv6/addrconf.c    |   69 +++++++++++++++++++++++++++++++++--------------
 3 files changed, 50 insertions(+), 22 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 582e4ae..cbc6bb0 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -8,7 +8,7 @@
 
 #define TEMP_VALID_LIFETIME		(7*86400)
 #define TEMP_PREFERRED_LIFETIME		(86400)
-#define REGEN_MAX_RETRY			(5)
+#define REGEN_MAX_RETRY			(3)
 #define MAX_DESYNC_FACTOR		(600)
 
 #define ADDR_CHECK_FREQUENCY		(120*HZ)
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 11cf373..51a7031 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -41,6 +41,7 @@ struct inet6_ifaddr {
 	struct in6_addr		addr;
 	__u32			prefix_len;
 	
+	/* In seconds, relative to tstamp. Expiry is at tstamp + HZ * lft. */
 	__u32			valid_lft;
 	__u32			prefered_lft;
 	atomic_t		refcnt;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a06c53c..7d07624 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -824,12 +824,13 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr addr, *tmpaddr;
-	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp, age;
+	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_tstamp, age;
 	unsigned long regen_advance;
 	int tmp_plen;
 	int ret = 0;
 	int max_addresses;
 	u32 addr_flags;
+	unsigned long now = jiffies;
 
 	write_lock(&idev->lock);
 	if (ift) {
@@ -874,7 +875,7 @@ retry:
 		goto out;
 	}
 	memcpy(&addr.s6_addr[8], idev->rndid, 8);
-	age = (jiffies - ifp->tstamp) / HZ;
+	age = (now - ifp->tstamp) / HZ;
 	tmp_valid_lft = min_t(__u32,
 			      ifp->valid_lft,
 			      idev->cnf.temp_valid_lft + age);
@@ -884,7 +885,6 @@ retry:
 				 idev->cnf.max_desync_factor);
 	tmp_plen = ifp->prefix_len;
 	max_addresses = idev->cnf.max_addresses;
-	tmp_cstamp = ifp->cstamp;
 	tmp_tstamp = ifp->tstamp;
 	spin_unlock_bh(&ifp->lock);
 
@@ -929,7 +929,7 @@ retry:
 	ift->ifpub = ifp;
 	ift->valid_lft = tmp_valid_lft;
 	ift->prefered_lft = tmp_prefered_lft;
-	ift->cstamp = tmp_cstamp;
+	ift->cstamp = now;
 	ift->tstamp = tmp_tstamp;
 	spin_unlock_bh(&ift->lock);
 
@@ -1997,25 +1997,50 @@ ok:
 #ifdef CONFIG_IPV6_PRIVACY
 			read_lock_bh(&in6_dev->lock);
 			/* update all temporary addresses in the list */
-			list_for_each_entry(ift, &in6_dev->tempaddr_list, tmp_list) {
-				/*
-				 * When adjusting the lifetimes of an existing
-				 * temporary address, only lower the lifetimes.
-				 * Implementations must not increase the
-				 * lifetimes of an existing temporary address
-				 * when processing a Prefix Information Option.
-				 */
+			list_for_each_entry(ift, &in6_dev->tempaddr_list,
+					    tmp_list) {
+				int age, max_valid, max_prefered;
+
 				if (ifp != ift->ifpub)
 					continue;
 
+				/*
+				 * RFC 4941 section 3.3:
+				 * If a received option will extend the lifetime
+				 * of a public address, the lifetimes of
+				 * temporary addresses should be extended,
+				 * subject to the overall constraint that no
+				 * temporary addresses should ever remain
+				 * "valid" or "preferred" for a time longer than
+				 * (TEMP_VALID_LIFETIME) or
+				 * (TEMP_PREFERRED_LIFETIME - DESYNC_FACTOR),
+				 * respectively.
+				 */
+				age = (now - ift->cstamp) / HZ;
+				max_valid = in6_dev->cnf.temp_valid_lft - age;
+				if (max_valid < 0)
+					max_valid = 0;
+
+				max_prefered = in6_dev->cnf.temp_prefered_lft -
+					       in6_dev->cnf.max_desync_factor -
+					       age;
+				if (max_prefered < 0)
+					max_prefered = 0;
+
+				if (valid_lft > max_valid)
+					valid_lft = max_valid;
+
+				if (prefered_lft > max_prefered)
+					prefered_lft = max_prefered;
+
 				spin_lock(&ift->lock);
 				flags = ift->flags;
-				if (ift->valid_lft > valid_lft &&
-				    ift->valid_lft - valid_lft > (jiffies - ift->tstamp) / HZ)
-					ift->valid_lft = valid_lft + (jiffies - ift->tstamp) / HZ;
-				if (ift->prefered_lft > prefered_lft &&
-				    ift->prefered_lft - prefered_lft > (jiffies - ift->tstamp) / HZ)
-					ift->prefered_lft = prefered_lft + (jiffies - ift->tstamp) / HZ;
+				ift->valid_lft = valid_lft;
+				ift->prefered_lft = prefered_lft;
+				ift->tstamp = now;
+				if (prefered_lft > 0)
+					ift->flags &= ~IFA_F_DEPRECATED;
+
 				spin_unlock(&ift->lock);
 				if (!(flags&IFA_F_TENTATIVE))
 					ipv6_ifa_notify(0, ift);
@@ -2023,9 +2048,11 @@ ok:
 
 			if ((create || list_empty(&in6_dev->tempaddr_list)) && in6_dev->cnf.use_tempaddr > 0) {
 				/*
-				 * When a new public address is created as described in [ADDRCONF],
-				 * also create a new temporary address. Also create a temporary
-				 * address if it's enabled but no temporary address currently exists.
+				 * When a new public address is created as
+				 * described in [ADDRCONF], also create a new
+				 * temporary address. Also create a temporary
+				 * address if it's enabled but no temporary
+				 * address currently exists.
 				 */
 				read_unlock_bh(&in6_dev->lock);
 				ipv6_create_tempaddr(ifp, NULL);
-- 
1.7.3.1

