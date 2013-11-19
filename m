From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC v2 2/2] ipv6 addrconf: introduce IFA_F_MANAGETEMPADDR to tell kernel to manage temporary addresses
Date: Tue, 19 Nov 2013 11:43:29 +0100
Message-ID: <1384857809-6573-3-git-send-email-jiri@resnulli.us>
References: <1384857809-6573-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:53049 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064Ab3KSKni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 05:43:38 -0500
Received: by mail-ee0-f48.google.com with SMTP id e49so3084147eek.7
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 02:43:37 -0800 (PST)
In-Reply-To: <1384857809-6573-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Creating an address with this flag set will result in kernel taking care
of temporary addresses in the same way as if the address was created by
kernel itself (after RA receive). This allows userspace applications
implementing the autoconfiguration (NetworkManager for example) to
implement ipv6 addresses privacy.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Thomas Haller <thaller@redhat.com>
---
v1->v2:
- Added possibility to change IFA_F_MANAGETEMPADDR flag as suggested by Thomas Haller

 include/uapi/linux/if_addr.h |   1 +
 net/ipv6/addrconf.c          | 167 ++++++++++++++++++++++++-------------------
 2 files changed, 96 insertions(+), 72 deletions(-)

diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.h
index 8ab0c2c..cfed10b 100644
--- a/include/uapi/linux/if_addr.h
+++ b/include/uapi/linux/if_addr.h
@@ -48,6 +48,7 @@ enum {
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
 #define IFA_F_PERMANENT		0x80
+#define IFA_F_MANAGETEMPADDR	0x100
 
 struct ifa_cacheinfo {
 	__u32	ifa_prefered;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c94da31..a29e782 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1010,7 +1010,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 	u32 addr_flags;
 	unsigned long now = jiffies;
 
-	write_lock(&idev->lock);
+	write_lock_bh(&idev->lock);
 	if (ift) {
 		spin_lock_bh(&ift->lock);
 		memcpy(&addr.s6_addr[8], &ift->addr.s6_addr[8], 8);
@@ -1022,7 +1022,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 retry:
 	in6_dev_hold(idev);
 	if (idev->cnf.use_tempaddr <= 0) {
-		write_unlock(&idev->lock);
+		write_unlock_bh(&idev->lock);
 		pr_info("%s: use_tempaddr is disabled\n", __func__);
 		in6_dev_put(idev);
 		ret = -1;
@@ -1032,7 +1032,7 @@ retry:
 	if (ifp->regen_count++ >= idev->cnf.regen_max_retry) {
 		idev->cnf.use_tempaddr = -1;	/*XXX*/
 		spin_unlock_bh(&ifp->lock);
-		write_unlock(&idev->lock);
+		write_unlock_bh(&idev->lock);
 		pr_warn("%s: regeneration time exceeded - disabled temporary address support\n",
 			__func__);
 		in6_dev_put(idev);
@@ -1058,7 +1058,7 @@ retry:
 	regen_advance = idev->cnf.regen_max_retry *
 	                idev->cnf.dad_transmits *
 	                idev->nd_parms->retrans_time / HZ;
-	write_unlock(&idev->lock);
+	write_unlock_bh(&idev->lock);
 
 	/* A temporary address is created only if this calculated Preferred
 	 * Lifetime is greater than REGEN_ADVANCE time units.  In particular,
@@ -1085,7 +1085,7 @@ retry:
 		in6_dev_put(idev);
 		pr_info("%s: retry temporary address regeneration\n", __func__);
 		tmpaddr = &addr;
-		write_lock(&idev->lock);
+		write_lock_bh(&idev->lock);
 		goto retry;
 	}
 
@@ -2019,6 +2019,73 @@ static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
 	return idev;
 }
 
+static void manage_tempaddrs(struct inet6_dev *idev,
+			     struct inet6_ifaddr *ifp,
+			     __u32 valid_lft, __u32 prefered_lft,
+			     bool create, unsigned long now)
+{
+	u32 flags;
+	struct inet6_ifaddr *ift;
+
+	read_lock_bh(&idev->lock);
+	/* update all temporary addresses in the list */
+	list_for_each_entry(ift, &idev->tempaddr_list, tmp_list) {
+		int age, max_valid, max_prefered;
+
+		if (ifp != ift->ifpub)
+			continue;
+
+		/* RFC 4941 section 3.3:
+		 * If a received option will extend the lifetime of a public
+		 * address, the lifetimes of temporary addresses should
+		 * be extended, subject to the overall constraint that no
+		 * temporary addresses should ever remain "valid" or "preferred"
+		 * for a time longer than (TEMP_VALID_LIFETIME) or
+		 * (TEMP_PREFERRED_LIFETIME - DESYNC_FACTOR), respectively.
+		 */
+		age = (now - ift->cstamp) / HZ;
+		max_valid = idev->cnf.temp_valid_lft - age;
+		if (max_valid < 0)
+			max_valid = 0;
+
+		max_prefered = idev->cnf.temp_prefered_lft -
+			       idev->cnf.max_desync_factor - age;
+		if (max_prefered < 0)
+			max_prefered = 0;
+
+		if (valid_lft > max_valid)
+			valid_lft = max_valid;
+
+		if (prefered_lft > max_prefered)
+			prefered_lft = max_prefered;
+
+		spin_lock(&ift->lock);
+		flags = ift->flags;
+		ift->valid_lft = valid_lft;
+		ift->prefered_lft = prefered_lft;
+		ift->tstamp = now;
+		if (prefered_lft > 0)
+			ift->flags &= ~IFA_F_DEPRECATED;
+
+		spin_unlock(&ift->lock);
+		if (!(flags&IFA_F_TENTATIVE))
+			ipv6_ifa_notify(0, ift);
+	}
+
+	if ((create || list_empty(&idev->tempaddr_list)) &&
+	    idev->cnf.use_tempaddr > 0) {
+		/* When a new public address is created as described
+		 * in [ADDRCONF], also create a new temporary address.
+		 * Also create a temporary address if it's enabled but
+		 * no temporary address currently exists.
+		 */
+		read_unlock_bh(&idev->lock);
+		ipv6_create_tempaddr(ifp, NULL);
+	} else {
+		read_unlock_bh(&idev->lock);
+	}
+}
+
 void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 {
 	struct prefix_info *pinfo;
@@ -2173,6 +2240,7 @@ ok:
 				return;
 			}
 
+			ifp->flags |= IFA_F_MANAGETEMPADDR;
 			update_lft = 0;
 			create = 1;
 			ifp->cstamp = jiffies;
@@ -2183,7 +2251,6 @@ ok:
 		if (ifp) {
 			u32 flags;
 			unsigned long now;
-			struct inet6_ifaddr *ift;
 			u32 stored_lft;
 
 			/* update lifetime (RFC2462 5.5.3 e) */
@@ -2224,70 +2291,8 @@ ok:
 			} else
 				spin_unlock(&ifp->lock);
 
-			read_lock_bh(&in6_dev->lock);
-			/* update all temporary addresses in the list */
-			list_for_each_entry(ift, &in6_dev->tempaddr_list,
-					    tmp_list) {
-				int age, max_valid, max_prefered;
-
-				if (ifp != ift->ifpub)
-					continue;
-
-				/*
-				 * RFC 4941 section 3.3:
-				 * If a received option will extend the lifetime
-				 * of a public address, the lifetimes of
-				 * temporary addresses should be extended,
-				 * subject to the overall constraint that no
-				 * temporary addresses should ever remain
-				 * "valid" or "preferred" for a time longer than
-				 * (TEMP_VALID_LIFETIME) or
-				 * (TEMP_PREFERRED_LIFETIME - DESYNC_FACTOR),
-				 * respectively.
-				 */
-				age = (now - ift->cstamp) / HZ;
-				max_valid = in6_dev->cnf.temp_valid_lft - age;
-				if (max_valid < 0)
-					max_valid = 0;
-
-				max_prefered = in6_dev->cnf.temp_prefered_lft -
-					       in6_dev->cnf.max_desync_factor -
-					       age;
-				if (max_prefered < 0)
-					max_prefered = 0;
-
-				if (valid_lft > max_valid)
-					valid_lft = max_valid;
-
-				if (prefered_lft > max_prefered)
-					prefered_lft = max_prefered;
-
-				spin_lock(&ift->lock);
-				flags = ift->flags;
-				ift->valid_lft = valid_lft;
-				ift->prefered_lft = prefered_lft;
-				ift->tstamp = now;
-				if (prefered_lft > 0)
-					ift->flags &= ~IFA_F_DEPRECATED;
-
-				spin_unlock(&ift->lock);
-				if (!(flags&IFA_F_TENTATIVE))
-					ipv6_ifa_notify(0, ift);
-			}
-
-			if ((create || list_empty(&in6_dev->tempaddr_list)) && in6_dev->cnf.use_tempaddr > 0) {
-				/*
-				 * When a new public address is created as
-				 * described in [ADDRCONF], also create a new
-				 * temporary address. Also create a temporary
-				 * address if it's enabled but no temporary
-				 * address currently exists.
-				 */
-				read_unlock_bh(&in6_dev->lock);
-				ipv6_create_tempaddr(ifp, NULL);
-			} else {
-				read_unlock_bh(&in6_dev->lock);
-			}
+			manage_tempaddrs(in6_dev, ifp, valid_lft, prefered_lft,
+					 create, now);
 
 			in6_ifa_put(ifp);
 			addrconf_verify(0);
@@ -2429,6 +2434,9 @@ static int inet6_addr_add(struct net *net, int ifindex,
 		 * manually configured addresses
 		 */
 		addrconf_dad_start(ifp);
+		if (ifa_flags & IFA_F_MANAGETEMPADDR)
+			manage_tempaddrs(idev, ifp, valid_lft, prefered_lft,
+					 true, jiffies);
 		in6_ifa_put(ifp);
 		addrconf_verify(0);
 		return 0;
@@ -3609,6 +3617,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 	u32 flags;
 	clock_t expires;
 	unsigned long timeout;
+	bool was_managetempaddr;
 
 	if (!valid_lft || (prefered_lft > valid_lft))
 		return -EINVAL;
@@ -3632,7 +3641,10 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 	}
 
 	spin_lock_bh(&ifp->lock);
-	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
+	was_managetempaddr = ifp->flags & IFA_F_MANAGETEMPADDR;
+	ifp->flags &= ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD |
+			IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR);
+	ifp->flags |= ifa_flags;
 	ifp->tstamp = jiffies;
 	ifp->valid_lft = valid_lft;
 	ifp->prefered_lft = prefered_lft;
@@ -3643,6 +3655,14 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 
 	addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
 			      expires, flags);
+
+	if (was_managetempaddr || ifp->flags & IFA_F_MANAGETEMPADDR) {
+		if (was_managetempaddr && !(ifp->flags & IFA_F_MANAGETEMPADDR))
+			valid_lft = prefered_lft = 0;
+		manage_tempaddrs(ifp->idev, ifp, valid_lft, prefered_lft,
+				 false, jiffies);
+	}
+
 	addrconf_verify(0);
 
 	return 0;
@@ -3687,8 +3707,11 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ifa_flags = tb[IFA_FLAGS] ? nla_get_u32(tb[IFA_FLAGS]) : ifm->ifa_flags;
 
+	if (ifa_flags & IFA_F_MANAGETEMPADDR && ifm->ifa_prefixlen != 64)
+		return -EINVAL;
+
 	/* We ignore other flags so far. */
-	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS;
+	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR;
 
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (ifa == NULL) {
-- 
1.8.3.1
