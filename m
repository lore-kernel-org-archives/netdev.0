From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH] Implementation for IPv6 MIB:ipv6AddressTable
Date: Wed, 8 Oct 2003 11:23:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310081121.02222.mashirle@us.ibm.com>
References: <OFB064680A.7B686FB0-ON87256DB8.005E1987@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
In-Reply-To: <OFB064680A.7B686FB0-ON87256DB8.005E1987@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks for all your comments. Here is the new patch. This patch is against 
linux-2.6.0-test6-bk8. This patch has been tested.

Please review this again.

Thanks
Shirley Ma
IBM Linux Technology Center
-------------------------------------------


diff -urN linux-2.6.0-test6/include/linux/rtnetlink.h 
linux-2.6.0-test6-ipv6mib4/include/linux/rtnetlink.h
--- linux-2.6.0-test6/include/linux/rtnetlink.h	2003-09-27 17:50:40.000000000 
-0700
+++ linux-2.6.0-test6-ipv6mib4/include/linux/rtnetlink.h	2003-10-07 
23:37:29.000000000 -0700
@@ -352,8 +352,10 @@
 
 struct ifa_cacheinfo
 {
-	__s32	ifa_prefered;
-	__s32	ifa_valid;
+	__u32	ifa_prefered;
+	__u32	ifa_valid;
+	__u32	cstamp; /* created timestamp, hundredths of seconds */
+	__u32	tstamp; /* updated timestamp, hundredths of seconds */
 };
 
 
diff -urN linux-2.6.0-test6/include/linux/time.h 
linux-2.6.0-test6-ipv6mib4/include/linux/time.h
--- linux-2.6.0-test6/include/linux/time.h	2003-09-27 17:50:30.000000000 -0700
+++ linux-2.6.0-test6-ipv6mib4/include/linux/time.h	2003-10-07 
23:37:29.000000000 -0700
@@ -55,6 +55,7 @@
  * at _least_ "jiffies" - so "jiffies+1" had better still
  * be positive.
  */
+#define MAX_JIFFIES (~0)
 #define MAX_JIFFY_OFFSET ((~0UL >> 1)-1)
 
 /* Parameters used to convert the timespec values */
diff -urN linux-2.6.0-test6/include/net/if_inet6.h 
linux-2.6.0-test6-ipv6mib4/include/net/if_inet6.h
--- linux-2.6.0-test6/include/net/if_inet6.h	2003-09-27 17:51:07.000000000 
-0700
+++ linux-2.6.0-test6-ipv6mib4/include/net/if_inet6.h	2003-10-07 
23:37:29.000000000 -0700
@@ -34,7 +34,8 @@
 	
 	__u32			valid_lft;
 	__u32			prefered_lft;
-	unsigned long		tstamp;
+	unsigned long		cstamp;	/* created timestamp */
+	unsigned long		tstamp; /* updated timestamp */
 	atomic_t		refcnt;
 	spinlock_t		lock;
 
@@ -111,6 +112,8 @@
 	atomic_t		mca_refcnt;
 	spinlock_t		mca_lock;
 	unsigned char		mca_crcount;
+	unsigned long		mca_cstamp;
+	unsigned long		mca_tstamp;
 };
 
 /* Anycast stuff */
@@ -130,6 +133,8 @@
 	int			aca_users;
 	atomic_t		aca_refcnt;
 	spinlock_t		aca_lock;
+	unsigned long		aca_cstamp;
+	unsigned long		aca_tstamp;
 };
 
 #define	IFA_HOST	IPV6_ADDR_LOOPBACK
diff -urN linux-2.6.0-test6/net/ipv6/addrconf.c 
linux-2.6.0-test6-ipv6mib4/net/ipv6/addrconf.c
--- linux-2.6.0-test6/net/ipv6/addrconf.c	2003-09-27 17:51:02.000000000 -0700
+++ linux-2.6.0-test6-ipv6mib4/net/ipv6/addrconf.c	2003-10-07 
23:58:39.000000000 -0700
@@ -92,6 +92,8 @@
 #define ADBG(x)
 #endif
 
+#define	INFINITY_LIFE_TIME	0xFFFFFFFF
+
 #ifdef CONFIG_SYSCTL
 static void addrconf_sysctl_register(struct inet6_dev *idev, struct 
ipv6_devconf *p);
 static void addrconf_sysctl_unregister(struct ipv6_devconf *p);
@@ -505,6 +507,7 @@
 	ifa->scope = scope;
 	ifa->prefix_len = pfxlen;
 	ifa->flags = flags | IFA_F_TENTATIVE;
+	ifa->cstamp = ifa->tstamp = jiffies;
 
 	read_lock(&addrconf_lock);
 	if (idev->dead) {
@@ -707,6 +710,7 @@
 	ift->ifpub = ifp;
 	ift->valid_lft = tmp_valid_lft;
 	ift->prefered_lft = tmp_prefered_lft;
+	ift->cstamp = ifp->cstamp;
 	ift->tstamp = ifp->tstamp;
 	spin_unlock_bh(&ift->lock);
 	addrconf_dad_start(ift, 0);
@@ -1412,6 +1416,7 @@
 			}
 
 			update_lft = create = 1;
+			ifp->cstamp = jiffies;
 			addrconf_dad_start(ifp, RTF_ADDRCONF|RTF_PREFIX_RT);
 		}
 
@@ -2447,14 +2452,103 @@
 	if (!(ifa->flags&IFA_F_PERMANENT)) {
 		ci.ifa_prefered = ifa->prefered_lft;
 		ci.ifa_valid = ifa->valid_lft;
-		if (ci.ifa_prefered != 0xFFFFFFFF) {
+		if (ci.ifa_prefered != INFINITY_LIFE_TIME) {
 			long tval = (jiffies - ifa->tstamp)/HZ;
 			ci.ifa_prefered -= tval;
-			if (ci.ifa_valid != 0xFFFFFFFF)
+			if (ci.ifa_valid != INFINITY_LIFE_TIME)
 				ci.ifa_valid -= tval;
 		}
-		RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
+	} else {
+		ci.ifa_prefered = INFINITY_LIFE_TIME;
+		ci.ifa_valid = INFINITY_LIFE_TIME;
 	}
+	if (ifa->cstamp < INITIAL_JIFFIES)
+		ci.cstamp = (ifa->cstamp + MAX_JIFFIES - INITIAL_JIFFIES) / HZ * 100;
+	else
+		ci.cstamp = (ifa->cstamp - INITIAL_JIFFIES) / HZ * 100;
+	if (ifa->tstamp < INITIAL_JIFFIES)
+		ci.tstamp = (ifa->tstamp + MAX_JIFFIES - INITIAL_JIFFIES) / HZ * 100;
+	else
+		ci.tstamp = (ifa->tstamp - INITIAL_JIFFIES) / HZ * 100;
+	RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
+				u32 pid, u32 seq, int event)
+{
+	struct ifaddrmsg *ifm;
+	struct nlmsghdr  *nlh;
+	struct ifa_cacheinfo ci;
+	unsigned char	 *b = skb->tail;
+
+	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
+	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	ifm = NLMSG_DATA(nlh);
+	ifm->ifa_family = AF_INET6;	
+	ifm->ifa_prefixlen = 128;
+	ifm->ifa_flags = IFA_F_PERMANENT;
+	ifm->ifa_scope = RT_SCOPE_UNIVERSE;
+	if (ipv6_addr_scope(&ifmca->mca_addr)&IFA_SITE)
+		ifm->ifa_scope = RT_SCOPE_SITE;
+	ifm->ifa_index = ifmca->idev->dev->ifindex;
+	RTA_PUT(skb, IFA_ADDRESS, 16, &ifmca->mca_addr);
+	if (ifmca->mca_cstamp < INITIAL_JIFFIES)
+		ci.cstamp = (ifmca->mca_cstamp + MAX_JIFFIES - INITIAL_JIFFIES) / HZ * 100;
+	else
+		ci.cstamp = (ifmca->mca_cstamp - INITIAL_JIFFIES) / HZ * 100;
+	if (ifmca->mca_tstamp < INITIAL_JIFFIES)
+		ci.tstamp = (ifmca->mca_tstamp + MAX_JIFFIES - INITIAL_JIFFIES) / HZ * 100;
+	else
+		ci.tstamp = (ifmca->mca_tstamp - INITIAL_JIFFIES) / HZ * 100;
+	ci.ifa_prefered = INFINITY_LIFE_TIME;
+	ci.ifa_valid = INFINITY_LIFE_TIME;
+	RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int inet6_fill_ifacaddr(struct sk_buff *skb, struct ifacaddr6 *ifaca,
+				u32 pid, u32 seq, int event)
+{
+	struct ifaddrmsg *ifm;
+	struct nlmsghdr  *nlh;
+	struct ifa_cacheinfo ci;
+	unsigned char	 *b = skb->tail;
+
+	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*ifm));
+	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	ifm = NLMSG_DATA(nlh);
+	ifm->ifa_family = AF_INET6;	
+	ifm->ifa_prefixlen = 128;
+	ifm->ifa_flags = IFA_F_PERMANENT;
+	ifm->ifa_scope = RT_SCOPE_UNIVERSE;
+	if (ipv6_addr_scope(&ifaca->aca_addr)&IFA_SITE)
+		ifm->ifa_scope = RT_SCOPE_SITE;
+	ifm->ifa_index = ifaca->aca_idev->dev->ifindex;
+	RTA_PUT(skb, IFA_ADDRESS, 16, &ifaca->aca_addr);
+	if (ifaca->aca_cstamp < INITIAL_JIFFIES)
+		ci.cstamp = (ifaca->aca_cstamp + MAX_JIFFIES - INITIAL_JIFFIES) / HZ * 100;
+	else
+		ci.cstamp = (ifaca->aca_cstamp - INITIAL_JIFFIES) / HZ * 100;
+	if (ifaca->aca_tstamp < INITIAL_JIFFIES)
+		ci.tstamp = (ifaca->aca_tstamp + MAX_JIFFIES - INITIAL_JIFFIES) / HZ * 100;
+	else
+		ci.tstamp = (ifaca->aca_tstamp - INITIAL_JIFFIES) / HZ * 100;
+	ci.ifa_prefered = INFINITY_LIFE_TIME;
+	ci.ifa_valid = INFINITY_LIFE_TIME;
+	RTA_PUT(skb, IFA_CACHEINFO, sizeof(ci), &ci);
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
 
@@ -2468,33 +2562,79 @@
 {
 	int idx, ip_idx;
 	int s_idx, s_ip_idx;
- 	struct inet6_ifaddr *ifa;
-
+	int err = 1;
+	struct net_device *dev;
+	struct inet6_dev *idev = NULL;
+	struct inet6_ifaddr *ifa;
+	struct ifmcaddr6 *ifmca;
+	struct ifacaddr6 *ifaca;
+	
 	s_idx = cb->args[0];
 	s_ip_idx = ip_idx = cb->args[1];
-
-	for (idx=0; idx < IN6_ADDR_HSIZE; idx++) {
+	read_lock(&dev_base_lock);
+	
+	for (dev = dev_base, idx = 0; dev; dev = dev->next, idx++) {
 		if (idx < s_idx)
 			continue;
 		if (idx > s_idx)
 			s_ip_idx = 0;
-		read_lock_bh(&addrconf_hash_lock);
-		for (ifa=inet6_addr_lst[idx], ip_idx = 0; ifa;
-		     ifa = ifa->lst_next, ip_idx++) {
+		ip_idx = 0;
+		if ((idev = in6_dev_get(dev)) == NULL)
+			continue;
+		read_lock_bh(&idev->lock);
+		/* unicast address */
+		for (ifa = idev->addr_list; ifa;
+		     ifa = ifa->if_next, ip_idx++) {
 			if (ip_idx < s_ip_idx)
 				continue;
-			if (inet6_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
-					      cb->nlh->nlmsg_seq, RTM_NEWADDR) <= 0) {
-				read_unlock_bh(&addrconf_hash_lock);
+			if ((err = inet6_fill_ifaddr(skb, ifa, 
+			    NETLINK_CB(cb->skb).pid, 
+			    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0)
 				goto done;
-			}
 		}
-		read_unlock_bh(&addrconf_hash_lock);
+		/* temp addr */
+#ifdef CONFIG_IPV6_PRIVACY
+		for (ifa = idev->tempaddr_list; ifa; 
+		     ifa = ifua->tmp_next, ip_idx++) {
+			if (ip_idx < s_ip_idx)
+				continue;
+			if ((err = inet6_fill_ifaddr(skb, ifa, 
+			    NETLINK_CB(cb->skb).pid, 
+			    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0) 
+				goto done;
+		}
+#endif
+		/* multicast address */
+		for (ifmca = idev->mc_list; ifmca; 
+		     ifmca = ifmca->next, ip_idx++) {
+			if (ip_idx < s_ip_idx)
+				continue;
+			if ((err = inet6_fill_ifmcaddr(skb, ifmca, 
+			    NETLINK_CB(cb->skb).pid, 
+			    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0) 
+				goto done;
+		}
+		/* anycast address */
+		for (ifaca = idev->ac_list; ifaca;
+		     ifaca = ifaca->aca_next, ip_idx++) {
+			if (ip_idx < s_ip_idx)
+				continue;
+			if ((err = inet6_fill_ifacaddr(skb, ifaca, 
+			    NETLINK_CB(cb->skb).pid, 
+			    cb->nlh->nlmsg_seq, RTM_NEWADDR)) <= 0) 
+				goto done;
+		}
+		read_unlock_bh(&idev->lock);
+		in6_dev_put(idev);
 	}
 done:
+	if (err <= 0) {
+		read_unlock_bh(&idev->lock);
+		in6_dev_put(idev);
+	}	
+	read_unlock(&dev_base_lock);
 	cb->args[0] = idx;
 	cb->args[1] = ip_idx;
-
 	return skb->len;
 }
 
diff -urN linux-2.6.0-test6/net/ipv6/anycast.c 
linux-2.6.0-test6-ipv6mib4/net/ipv6/anycast.c
--- linux-2.6.0-test6/net/ipv6/anycast.c	2003-09-27 17:50:06.000000000 -0700
+++ linux-2.6.0-test6-ipv6mib4/net/ipv6/anycast.c	2003-10-07 
23:37:29.000000000 -0700
@@ -343,6 +343,8 @@
 	ipv6_addr_copy(&aca->aca_addr, addr);
 	aca->aca_idev = idev;
 	aca->aca_users = 1;
+	/* aca_tstamp should be updated upon changes */
+	aca->aca_cstamp = aca->aca_tstamp = jiffies;
 	atomic_set(&aca->aca_refcnt, 2);
 	aca->aca_lock = SPIN_LOCK_UNLOCKED;
 
diff -urN linux-2.6.0-test6/net/ipv6/mcast.c 
linux-2.6.0-test6-ipv6mib4/net/ipv6/mcast.c
--- linux-2.6.0-test6/net/ipv6/mcast.c	2003-09-27 17:50:53.000000000 -0700
+++ linux-2.6.0-test6-ipv6mib4/net/ipv6/mcast.c	2003-10-07 23:37:29.000000000 
-0700
@@ -830,6 +830,8 @@
 	ipv6_addr_copy(&mc->mca_addr, addr);
 	mc->idev = idev;
 	mc->mca_users = 1;
+	/* mca_stamp should be updated upon changes */
+	mc->mca_cstamp = mc->mca_tstamp = jiffies;
 	atomic_set(&mc->mca_refcnt, 2);
 	mc->mca_lock = SPIN_LOCK_UNLOCKED;
 
