From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit kernels.
Date: Thu, 24 Apr 2008 17:02:57 +0900 (JST)
Message-ID: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33436 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbYDXIDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:03:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider pulling following changes on top of net-2.6
to fix several bugs related to 32-bit SSM (Source Specific Multicast)
applications on 64bit kernel because of difference of alignment
requirements between 64bit mode and 32bit mode.

IPv4 side should be fixed as well, but it is less critical
because we have ip_mreqn / ip_mreq_source /ip_msfilter,
which does not need compat layer.  Anyway, I plan to post
IPv4 side as well.

Tree is available at
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6-gd7d31300/inet6/05_compat-20080423

Thanks.

----

HEADLINES
---------

    [NET]: Introduce __compat_sockaddr_storage{}.
    [IPV6] COMPAT: Introduce compat_do_ipv6_{set,get}sockopt() wrapper.
    [IPV6] MCAST: Move mode check for group_source_req{}-sockopt to net/ipv6/mcast.c.
    [IPV6] COMPAT: group_source_req{}-setsockopt compat layer.
    [IPV6] COMPAT: group_req{}-setsockopt compat layer.
    [IPV6] COMPAT: group_filter{}-setsockopt compat layer.
    [IPV6] MCAST: Split ip6_mc_msfget().
    [IPV6] MCAST: Make ip6_mc_msfget() more generic.
    [IPV6] COMPAT: group_filter{}-getsockopt compat layer.

DIFFSTAT
--------

 include/linux/in.h       |   31 +++++++
 include/linux/socket.h   |    7 ++
 include/net/ipv6.h       |    6 +
 net/ipv6/ipv6_sockglue.c |  181 +++++++++++++++++++++++++++++++++++--------
 net/ipv6/mcast.c         |  194 +++++++++++++++++++++++++++++++++++-----------
 5 files changed, 338 insertions(+), 81 deletions(-)

CHANGESETS
----------

commit 0f382e910bc7d34e5619c6a038efa2e3396359d0
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 22 01:12:25 2008 +0900

    [NET]: Introduce __compat_sockaddr_storage{}.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/socket.h b/include/linux/socket.h
index bd2b30a..a3d77e7 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -16,6 +16,13 @@ struct __kernel_sockaddr_storage {
 				/* _SS_MAXSIZE value minus size of ss_family */
 } __attribute__ ((aligned(_K_SS_ALIGNSIZE)));	/* force desired alignment */
 
+#ifdef __KERNEL__
+struct __compat_sockaddr_storage {
+	unsigned short  ss_family;
+	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
+} __attribute__ ((aligned(4)));
+#endif
+
 #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
 
 #include <asm/socket.h>			/* arch-dependent defines	*/

---
commit 70be517de9b9582ace4633918f967c61345a978f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Apr 23 18:00:20 2008 +0900

    [IPV6] COMPAT: Introduce compat_do_ipv6_{set,get}sockopt() wrapper.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 06de9d0..a53aed4 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -764,6 +764,13 @@ int ipv6_setsockopt(struct sock *sk, int level, int optname,
 EXPORT_SYMBOL(ipv6_setsockopt);
 
 #ifdef CONFIG_COMPAT
+static int
+compat_do_ipv6_setsockopt(struct sock *sk, int level, int optname,
+			  char __user *optval, int optlen)
+{
+	return do_ipv6_setsockopt(sk, level, optname, optval, optlen);
+}
+
 int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			   char __user *optval, int optlen)
 {
@@ -779,7 +786,7 @@ int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	if (level != SOL_IPV6)
 		return -ENOPROTOOPT;
 
-	err = do_ipv6_setsockopt(sk, level, optname, optval, optlen);
+	err = compat_do_ipv6_setsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err == -ENOPROTOOPT && optname != IPV6_IPSEC_POLICY &&
@@ -1107,6 +1114,13 @@ int ipv6_getsockopt(struct sock *sk, int level, int optname,
 EXPORT_SYMBOL(ipv6_getsockopt);
 
 #ifdef CONFIG_COMPAT
+static int
+compat_do_ipv6_getsockopt(struct sock *sk, int level, int optname,
+			  char __user *optval, int __user *optlen)
+{
+	return do_ipv6_getsockopt(sk, level, optname, optval, optlen);
+}
+
 int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			   char __user *optval, int __user *optlen)
 {
@@ -1122,7 +1136,7 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 	if (level != SOL_IPV6)
 		return -ENOPROTOOPT;
 
-	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
+	err = compat_do_ipv6_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err == -ENOPROTOOPT && optname != IPV6_2292PKTOPTIONS) {

---
commit 5f4a79968bd9b82d06324ddc10ae41d95fd53896
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 22 12:14:20 2008 +0900

    [IPV6] MCAST: Move mode check for group_source_req{}-sockopt to net/ipv6/mcast.c.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 49c4898..aa81120 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -565,7 +565,7 @@ extern const struct proto_ops inet6_dgram_ops;
 struct group_source_req;
 struct group_filter;
 
-extern int ip6_mc_source(int add, int omode, struct sock *sk,
+extern int ip6_mc_source(struct sock *sk, int optname,
 			 struct group_source_req *pgsr);
 extern int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf);
 extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index a53aed4..694e031 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -542,7 +542,6 @@ done:
 	case MCAST_UNBLOCK_SOURCE:
 	{
 		struct group_source_req greqs;
-		int omode, add;
 
 		if (optlen < sizeof(struct group_source_req))
 			goto e_inval;
@@ -550,33 +549,7 @@ done:
 			retv = -EFAULT;
 			break;
 		}
-		if (greqs.gsr_group.ss_family != AF_INET6 ||
-		    greqs.gsr_source.ss_family != AF_INET6) {
-			retv = -EADDRNOTAVAIL;
-			break;
-		}
-		if (optname == MCAST_BLOCK_SOURCE) {
-			omode = MCAST_EXCLUDE;
-			add = 1;
-		} else if (optname == MCAST_UNBLOCK_SOURCE) {
-			omode = MCAST_EXCLUDE;
-			add = 0;
-		} else if (optname == MCAST_JOIN_SOURCE_GROUP) {
-			struct sockaddr_in6 *psin6;
-
-			psin6 = (struct sockaddr_in6 *)&greqs.gsr_group;
-			retv = ipv6_sock_mc_join(sk, greqs.gsr_interface,
-				&psin6->sin6_addr);
-			/* prior join w/ different source is ok */
-			if (retv && retv != -EADDRINUSE)
-				break;
-			omode = MCAST_INCLUDE;
-			add = 1;
-		} else /* MCAST_LEAVE_SOURCE_GROUP */ {
-			omode = MCAST_INCLUDE;
-			add = 0;
-		}
-		retv = ip6_mc_source(add, omode, sk, &greqs);
+		retv = ip6_mc_source(sk, optname, &greqs);
 		break;
 	}
 	case MCAST_MSFILTER:
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 54f91ef..5d8d653 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -355,8 +355,8 @@ void ipv6_sock_mc_close(struct sock *sk)
 	write_unlock_bh(&ipv6_sk_mc_lock);
 }
 
-int ip6_mc_source(int add, int omode, struct sock *sk,
-	struct group_source_req *pgsr)
+static int __ip6_mc_source(int add, int omode, struct sock *sk,
+			   struct group_source_req *pgsr)
 {
 	struct in6_addr *source, *group;
 	struct ipv6_mc_socklist *pmc;
@@ -496,6 +496,40 @@ done:
 	return err;
 }
 
+int ip6_mc_source(struct sock *sk, int optname,
+		  struct group_source_req *pgsr)
+{
+	int omode, add, retv;
+
+	if (pgsr->gsr_group.ss_family != AF_INET6 ||
+	    pgsr->gsr_source.ss_family != AF_INET6)
+		return -EADDRNOTAVAIL;
+
+	if (optname == MCAST_BLOCK_SOURCE) {
+		omode = MCAST_EXCLUDE;
+		add = 1;
+	} else if (optname == MCAST_UNBLOCK_SOURCE) {
+		omode = MCAST_EXCLUDE;
+		add = 0;
+	} else if (optname == MCAST_JOIN_SOURCE_GROUP) {
+		struct sockaddr_in6 *psin6;
+
+		psin6 = (struct sockaddr_in6 *)&pgsr->gsr_group;
+		retv = ipv6_sock_mc_join(sk, pgsr->gsr_interface,
+					 &psin6->sin6_addr);
+		/* prior join w/ different source is ok */
+		if (retv && retv != -EADDRINUSE)
+			return retv;
+		omode = MCAST_INCLUDE;
+		add = 1;
+	} else /* MCAST_LEAVE_SOURCE_GROUP */ {
+		omode = MCAST_INCLUDE;
+		add = 0;
+	}
+
+	return __ip6_mc_source(add, omode, sk, pgsr);
+}
+
 int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 {
 	struct in6_addr *group;

---
commit a001dde8990027b0235ce729a8ce3acebc819bdd
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 22 12:22:20 2008 +0900

    [IPV6] COMPAT: group_source_req{}-setsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/in.h b/include/linux/in.h
index 4065313..cbeaee0 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -156,6 +156,14 @@ struct group_source_req
 	struct __kernel_sockaddr_storage gsr_source;	/* source address */
 };
 
+#ifdef __KERNEL__
+struct compat_group_source_req {
+	__u32					gsr_interface;
+	struct __compat_sockaddr_storage	gsr_group;
+	struct __compat_sockaddr_storage	gsr_source;
+};
+#endif
+
 struct group_filter
 {
 	__u32				 gf_interface;	/* interface index */
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 694e031..b7ae360 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -741,7 +741,37 @@ static int
 compat_do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int optlen)
 {
-	return do_ipv6_setsockopt(sk, level, optname, optval, optlen);
+	int retv;
+
+	switch (optname) {
+	case MCAST_JOIN_SOURCE_GROUP:
+	case MCAST_LEAVE_SOURCE_GROUP:
+	case MCAST_BLOCK_SOURCE:
+	case MCAST_UNBLOCK_SOURCE:
+	    {
+		struct group_source_req greqs;
+		struct compat_group_source_req __user *ugreqs = (void __user *)optval;
+
+		if (optlen < sizeof(*ugreqs)) {
+			retv = -EINVAL;
+			break;
+		}
+		if (access_ok(VERIFY_READ, optval, sizeof(*ugreqs)) ||
+		    __get_user(greqs.gsr_interface, &ugreqs->gsr_interface) ||
+		    __copy_from_user(&greqs.gsr_group, &ugreqs->gsr_group,
+				     sizeof(greqs.gsr_group)) ||
+		    __copy_from_user(&greqs.gsr_source, &ugreqs->gsr_source,
+				     sizeof(greqs.gsr_source))) {
+			retv = -EFAULT;
+			break;
+		}
+		retv = ip6_mc_source(sk, optname, &greqs);
+		break;
+	    }
+	default:
+		retv = do_ipv6_setsockopt(sk, level, optname, optval, optlen);
+	}
+	return retv;
 }
 
 int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,

---
commit 1190e439a3d0b631349d068f534e5b912ede72b5
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 22 12:29:11 2008 +0900

    [IPV6] COMPAT: group_req{}-setsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/in.h b/include/linux/in.h
index cbeaee0..9ec8e2a 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -149,6 +149,14 @@ struct group_req
 	struct __kernel_sockaddr_storage gr_group;	/* group address */
 };
 
+#ifdef __KERNEL__
+struct compat_group_req
+{
+	__u32				 gr_interface;
+	struct __compat_sockaddr_storage gr_group;
+};
+#endif
+
 struct group_source_req
 {
 	__u32				 gsr_interface;	/* interface index */
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index b7ae360..30e6ca1 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -744,6 +744,32 @@ compat_do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	int retv;
 
 	switch (optname) {
+	case MCAST_JOIN_GROUP:
+	case MCAST_LEAVE_GROUP:
+	    {
+		struct group_req greq;
+		struct compat_group_req __user *ugreq = (void __user *)optval;
+		struct sockaddr_in6 *psin6;
+
+		if (optlen < sizeof(*ugreq))
+			return -EINVAL;
+		if (access_ok(VERIFY_READ, ugreq, sizeof(*ugreq)) ||
+		    __get_user(greq.gr_interface, &ugreq->gr_interface) ||
+		    __copy_from_user(&greq.gr_group, &ugreq->gr_group,
+				     sizeof(greq.gr_group)))
+			return -EFAULT;
+		if (greq.gr_group.ss_family != AF_INET6)
+			return -EADDRNOTAVAIL;
+
+		psin6 = (struct sockaddr_in6 *)&greq.gr_group;
+		if (optname == MCAST_JOIN_GROUP)
+			retv = ipv6_sock_mc_join(sk, greq.gr_interface,
+				&psin6->sin6_addr);
+		else
+			retv = ipv6_sock_mc_drop(sk, greq.gr_interface,
+				&psin6->sin6_addr);
+		break;
+	    }
 	case MCAST_JOIN_SOURCE_GROUP:
 	case MCAST_LEAVE_SOURCE_GROUP:
 	case MCAST_BLOCK_SOURCE:

---
commit 947e9bb2d318179936b414250d2ae31398aff0ba
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 22 12:32:44 2008 +0900

    [IPV6] COMPAT: group_filter{}-setsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/in.h b/include/linux/in.h
index 9ec8e2a..14a3cdb 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -185,6 +185,21 @@ struct group_filter
 	(sizeof(struct group_filter) - sizeof(struct __kernel_sockaddr_storage) \
 	+ (numsrc) * sizeof(struct __kernel_sockaddr_storage))
 
+#ifdef __KERNEL__
+struct compat_group_filter
+{
+	__u32					gf_interface;
+	struct __compat_sockaddr_storage	gf_group;
+	__u32					gf_fmode;
+	__u32					gf_numsrc;
+	struct __compat_sockaddr_storage	gf_slist[1];
+};
+
+#define COMPAT_GROUP_FILTER_SIZE(numsrc) \
+	(sizeof(struct compat_group_filter) - sizeof(struct __compat_sockaddr_storage) \
+	+ (numsrc) * sizeof(struct __compat_sockaddr_storage))
+#endif
+
 struct in_pktinfo
 {
 	int		ipi_ifindex;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 30e6ca1..0895e7d 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -794,6 +794,57 @@ compat_do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		retv = ip6_mc_source(sk, optname, &greqs);
 		break;
 	    }
+	case MCAST_MSFILTER:
+	    {
+		extern int sysctl_mld_max_msf;
+		struct compat_group_filter __user *ugsf = (void __user *)optval;
+		struct group_filter *gsf;
+		u32 gf_numsrc;
+		int i;
+
+		if (optlen < COMPAT_GROUP_FILTER_SIZE(0))
+			return -EINVAL;
+
+		if (access_ok(VERIFY_READ, ugsf, COMPAT_GROUP_FILTER_SIZE(0)) ||
+		    __get_user(gf_numsrc, &ugsf->gf_numsrc))
+			return -EFAULT;
+
+		if (COMPAT_GROUP_FILTER_SIZE(gf_numsrc) > optlen)
+			return -EINVAL;
+
+		if (optlen > sysctl_optmem_max ||
+		    gf_numsrc >= 0x1ffffffU ||
+		    gf_numsrc > sysctl_mld_max_msf)
+			return -ENOBUFS;
+
+		optlen = GROUP_FILTER_SIZE(gf_numsrc);
+		gsf = kmalloc(optlen, GFP_KERNEL);
+		if (!gsf) {
+			retv = -ENOBUFS;
+			break;
+		}
+		retv = -EFAULT;
+		if (__get_user(gsf->gf_interface, &ugsf->gf_interface) ||
+		    __copy_from_user(&gsf->gf_group, &ugsf->gf_group, sizeof(gsf->gf_group)) ||
+		    __get_user(gsf->gf_fmode, &ugsf->gf_fmode) ||
+		    access_ok(VERIFY_READ, ugsf->gf_slist,
+			      sizeof(struct __compat_sockaddr_storage) * gf_numsrc))
+			goto kfree_out;
+
+		gsf->gf_numsrc = gf_numsrc;
+
+		for (i = 0; i < gf_numsrc; i++) {
+			if (__copy_from_user(&gsf->gf_slist[i],
+					     &ugsf->gf_slist[i],
+					     sizeof(gsf->gf_slist[i])))
+				goto kfree_out;
+		}
+
+		retv = ip6_mc_msfilter(sk, gsf);
+kfree_out:
+		kfree(gsf);
+		break;
+	    }
 	default:
 		retv = do_ipv6_setsockopt(sk, level, optname, optval, optlen);
 	}

---
commit 19e24c1dabcc43c2febe076afd1e984cf1e13979
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 22 19:16:33 2008 +0900

    [IPV6] MCAST: Split ip6_mc_msfget().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 5d8d653..d32d6a3 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -621,79 +621,99 @@ done:
 	return err;
 }
 
-int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
-	struct group_filter __user *optval, int __user *optlen)
+int __ip6_mc_msf_lookup(struct sock *sk,
+			struct in6_addr *group, int interface,
+			struct ip6_sf_socklist **ppsl)
 {
-	int err, i, count, copycount;
-	struct in6_addr *group;
 	struct ipv6_mc_socklist *pmc;
-	struct inet6_dev *idev;
-	struct net_device *dev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
-	struct ip6_sf_socklist *psl;
+	struct net_device *dev;
+	struct inet6_dev *idev;
 	struct net *net = sock_net(sk);
+	int ret = 0;
 
-	group = &((struct sockaddr_in6 *)&gsf->gf_group)->sin6_addr;
-
-	if (!ipv6_addr_is_multicast(group))
-		return -EINVAL;
-
-	idev = ip6_mc_find_dev(net, group, gsf->gf_interface);
+	if (!ipv6_addr_is_multicast(group)) {
+		ret = -EINVAL;
+		goto out;
+	}
 
-	if (!idev)
-		return -ENODEV;
+	idev = ip6_mc_find_dev(net, group, interface);
+	if (!idev) {
+		ret = -ENODEV;
+		goto out;
+	}
 
 	dev = idev->dev;
 
-	err = -EADDRNOTAVAIL;
+	ret = -EADDRNOTAVAIL;
 	/*
 	 * changes to the ipv6_mc_list require the socket lock and
 	 * a read lock on ip6_sk_mc_lock. We have the socket lock,
 	 * so reading the list is safe.
 	 */
 
-	for (pmc=inet6->ipv6_mc_list; pmc; pmc=pmc->next) {
-		if (pmc->ifindex != gsf->gf_interface)
+	for (pmc = inet6->ipv6_mc_list; pmc; pmc = pmc->next) {
+		if (pmc->ifindex != interface)
 			continue;
 		if (ipv6_addr_equal(group, &pmc->addr))
 			break;
 	}
-	if (!pmc)		/* must have a prior join */
-		goto done;
-	gsf->gf_fmode = pmc->sfmode;
-	psl = pmc->sflist;
-	count = psl ? psl->sl_count : 0;
+	if (pmc) {
+		*ppsl = pmc->sflist;
+		ret = pmc->sfmode;
+	}
+
 	read_unlock_bh(&idev->lock);
 	in6_dev_put(idev);
 	dev_put(dev);
+out:
+	return ret;
+}
 
-	copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
-	gsf->gf_numsrc = count;
-	if (put_user(GROUP_FILTER_SIZE(copycount), optlen) ||
-	    copy_to_user(optval, gsf, GROUP_FILTER_SIZE(0))) {
-		return -EFAULT;
-	}
-	/* changes to psl require the socket lock, a read lock on
-	 * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
-	 * have the socket lock, so reading here is safe.
-	 */
-	for (i=0; i<copycount; i++) {
-		struct sockaddr_in6 *psin6;
-		struct sockaddr_storage ss;
+int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
+	struct group_filter __user *optval, int __user *optlen)
+{
+	struct in6_addr *group;
+	struct ip6_sf_socklist *psl;
+	int fmode;
+
+	group = &((struct sockaddr_in6 *)&gsf->gf_group)->sin6_addr;
+
+	fmode = __ip6_mc_msf_lookup(sk, group, gsf->gf_interface, &psl);
+	if (fmode < 0)
+		return fmode;
 
-		psin6 = (struct sockaddr_in6 *)&ss;
-		memset(&ss, 0, sizeof(ss));
-		psin6->sin6_family = AF_INET6;
-		psin6->sin6_addr = psl->sl_addr[i];
-		if (copy_to_user(&optval->gf_slist[i], &ss, sizeof(ss)))
+	if (psl) {
+		int count = psl ? psl->sl_count : 0;
+		int i, copycount;
+		struct sockaddr_in6 sin6;
+
+		copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
+
+		if (put_user(GROUP_FILTER_SIZE(copycount), optlen) ||
+		    access_ok(VERIFY_WRITE, optval, GROUP_FILTER_SIZE(copycount)) ||
+		    __put_user((u32)fmode, &optval->gf_fmode) ||
+		    __put_user((u32)count, &optval->gf_numsrc))
 			return -EFAULT;
+
+		/* changes to psl require the socket lock, a read lock on
+		 * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
+		 * have the socket lock, so reading here is safe.
+		 */
+		memset(&sin6, 0, sizeof(sin6));
+		sin6.sin6_family = AF_INET6;
+
+		for (i = 0; i < copycount; i++) {
+			struct sockaddr_in6 __user *usin6 = (void __user *)&optval->gf_slist[i];
+
+			ipv6_addr_copy(&sin6.sin6_addr, &psl->sl_addr[i]);
+
+			if (__copy_to_user(usin6, &sin6, sizeof(sin6)) ||
+			    __clear_user(usin6 + 1, sizeof(optval->gf_slist[i]) - sizeof(*usin6)))
+				return -EFAULT;
+		}
 	}
 	return 0;
-done:
-	read_unlock_bh(&idev->lock);
-	in6_dev_put(idev);
-	dev_put(dev);
-	return err;
 }
 
 int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,

---
commit 533a1a4139aee99a4068f804b0d3db91152dab42
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Apr 23 18:03:14 2008 +0900

    [IPV6] MCAST: Make ip6_mc_msfget() more generic.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index aa81120..103272f 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -568,7 +568,9 @@ struct group_filter;
 extern int ip6_mc_source(struct sock *sk, int optname,
 			 struct group_source_req *pgsr);
 extern int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf);
-extern int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
+extern int ip6_mc_msfget(struct sock *sk,
+			 struct in6_addr *group, u32 gf_interface,
+			 u32 gf_srcnum,
 			 struct group_filter __user *optval,
 			 int __user *optlen);
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 0895e7d..d670078 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -949,8 +949,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		if (copy_from_user(&gsf, optval, GROUP_FILTER_SIZE(0)))
 			return -EFAULT;
 		lock_sock(sk);
-		err = ip6_mc_msfget(sk, &gsf,
-			(struct group_filter __user *)optval, optlen);
+		err = ip6_mc_msfget(sk,
+				    &((struct sockaddr_in6 *)&gsf.gf_group)->sin6_addr,
+				    gsf.gf_interface, gsf.gf_numsrc,
+				    (struct group_filter __user *)optval, optlen);
 		release_sock(sk);
 		return err;
 	}
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index d32d6a3..b781192 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -670,16 +670,14 @@ out:
 	return ret;
 }
 
-int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
-	struct group_filter __user *optval, int __user *optlen)
+int ip6_mc_msfget(struct sock *sk,
+		  struct in6_addr *group, u32 gf_interface, u32 gf_numsrc,
+		  struct group_filter __user *optval, int __user *optlen)
 {
-	struct in6_addr *group;
 	struct ip6_sf_socklist *psl;
 	int fmode;
 
-	group = &((struct sockaddr_in6 *)&gsf->gf_group)->sin6_addr;
-
-	fmode = __ip6_mc_msf_lookup(sk, group, gsf->gf_interface, &psl);
+	fmode = __ip6_mc_msf_lookup(sk, group, gf_interface, &psl);
 	if (fmode < 0)
 		return fmode;
 
@@ -688,7 +686,7 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 		int i, copycount;
 		struct sockaddr_in6 sin6;
 
-		copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
+		copycount = count < gf_numsrc ? count : gf_numsrc;
 
 		if (put_user(GROUP_FILTER_SIZE(copycount), optlen) ||
 		    access_ok(VERIFY_WRITE, optval, GROUP_FILTER_SIZE(copycount)) ||

---
commit f14168835b7e389649383a285015a83d4d4e7968
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Apr 23 18:06:37 2008 +0900

    [IPV6] COMPAT: group_filter{}-getsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index d670078..27d9b3d 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1200,7 +1200,28 @@ static int
 compat_do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int __user *optlen)
 {
-	return do_ipv6_getsockopt(sk, level, optname, optval, optlen);
+	switch (optname) {
+	case MCAST_MSFILTER:
+	    {
+		struct compat_group_filter gsf;
+		int err;
+
+		if (len < COMPAT_GROUP_FILTER_SIZE(0))
+			return -EINVAL;
+		if (copy_from_user(&gsf, optval, COMPAT_GROUP_FILTER_SIZE(0)))
+			return -EFAULT;
+		lock_sock(sk);
+		err = ip6_mc_compat_msfget(sk,
+					   &((struct sockaddr_in6 *)&gsf.gf_group)->sin6_addr,
+					   gsf.gf_interface, gsf.gsf_numsrc,
+					   (struct group_filter __user *)optval,
+					   optlen);
+		release_sock(sk);
+	    }
+	default:
+		err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
+	}
+	return err;
 }
 
 int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index b781192..bdfabbb 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -714,6 +714,54 @@ int ip6_mc_msfget(struct sock *sk,
 	return 0;
 }
 
+#ifdef CONFIG_COMPAT
+int ip6_mc_compat_msfget(struct sock *sk,
+			 struct in6_addr *group,
+			 u32 gf_interface, u32 gf_numsrc,
+			 struct compat_group_filter __user *optval,
+			 int __user *optlen)
+{
+	struct ip6_sf_socklist *psl;
+	int fmode;
+
+	fmode = __ip6_mc_msf_lookup(sk, group, gf_interface, &psl);
+	if (fmode < 0)
+		return fmode;
+
+	if (psl) {
+		int count = psl ? psl->sl_count : 0;
+		int i, copycount;
+		struct sockaddr_in6 sin6;
+
+		copycount = count < gf_numsrc ? count : gf_numsrc;
+
+		if (put_user(COMPAT_GROUP_FILTER_SIZE(copycount), optlen) ||
+		    access_ok(VERIFY_WRITE, optval, COMPAT_GROUP_FILTER_SIZE(copycount)) ||
+		    __put_user((u32)fmode, &optval->gf_fmode) ||
+		    __put_user((u32)count, &optval->gf_numsrc))
+			return -EFAULT;
+
+		/* changes to psl require the socket lock, a read lock on
+		 * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
+		 * have the socket lock, so reading here is safe.
+		 */
+		memset(&sin6, 0, sizeof(sin6));
+		sin6.sin6_family = AF_INET6;
+
+		for (i = 0; i < copycount; i++) {
+			struct sockaddr_in6 __user *usin6 = (void __user *)&optval->gf_slist[i];
+
+			ipv6_addr_copy(&sin6.sin6_addr, &psl->sl_addr[i]);
+
+			if (__copy_to_user(usin6, &sin6, sizeof(sin6)) ||
+			    __clear_user(usin6 + 1, sizeof(optval->gf_slist[i]) - sizeof(*usin6)))
+				return -EFAULT;
+		}
+	}
+	return 0;
+}
+#endif
+
 int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 		   const struct in6_addr *src_addr)
 {

---
