From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Fri, 25 Apr 2008 03:46:04 +0900 (JST)
Message-ID: <20080425.034604.40676242.yoshfuji@linux-ipv6.org>
References: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
	<20080424.010845.257071066.davem@davemloft.net>
	<20080424.171644.106117727.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33487 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbYDXSqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 14:46:08 -0400
In-Reply-To: <20080424.171644.106117727.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080424.171644.106117727.yoshfuji@linux-ipv6.org> (at Thu, 24 Apr 2008 17:16:44 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> > Thanks for doing this work, please make corrections and I also
> > look forward to your ipv4 side fixes.
> 
> Will do.

Okay, here it is.

---
[GIT PULL] [IPV4,IPV6] Compat layer for IGMP/MLD (Take 2)

Many MCAST_xxx (IGMP/MLD) socket options did not work
appropriately for 32bit applications on 64bit kernel
because of the difference of alignment requirements between 
them
With this series of changes, compat layer is being added for them.

Tree is available at
    git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6-gd7d31300/inet6/05_compat-20080424a

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
    [IPV4] COMPAT: Introduce compat_do_ip_{set,get}sockopt() wrapper.
    [IPV4] IGMP: Move mode check for ip_mreq_source/group_source_req{}-sockopts to net/ipv4/igmp.c.
    [IPV4] COMPAT: group_source_req{}-setsockopt compat layer.
    [IPV4] COMPAT: group_req{}-setsockopt compat layer.
    [IPV4] COMPAT: group_filter{}-setsockopt compat layer.
    [IPV4] IGMP: Consolidate common code path of ip_mc_{msf,gsf}get().
    [IPV4] IGMP: Make ip_mc_gsfget() more generic.
    [IPV4] COMPAT: group_filter{}-getsockopt compat layer.

DIFFSTAT
--------

 include/linux/igmp.h     |   12 ++
 include/linux/in.h       |   29 +++++
 include/linux/socket.h   |   11 ++
 include/net/ipv6.h       |   16 ++-
 net/ipv4/igmp.c          |  259 +++++++++++++++++++++++++++++++---------------
 net/ipv4/ip_sockglue.c   |  200 ++++++++++++++++++++++++++----------
 net/ipv6/ipv6_sockglue.c |  186 +++++++++++++++++++++++++++------
 net/ipv6/mcast.c         |  194 ++++++++++++++++++++++++++--------
 8 files changed, 685 insertions(+), 222 deletions(-)

CHANGESETS
----------

commit 8d1070ce23288bfcc52835ef08bb0c7a9d45ad8c
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 25 02:56:32 2008 +0900

    [NET]: Introduce __compat_sockaddr_storage{}.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/socket.h b/include/linux/socket.h
index bd2b30a..7c30c6b 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -16,6 +16,17 @@ struct __kernel_sockaddr_storage {
 				/* _SS_MAXSIZE value minus size of ss_family */
 } __attribute__ ((aligned(_K_SS_ALIGNSIZE)));	/* force desired alignment */
 
+#ifdef __KERNEL__
+#ifdef CONFIG_COMPAT
+#define _K_CSS_ALIGNSIZE	4	/* __alignof__ (compat_uptr_t) */
+
+struct __compat_sockaddr_storage {
+	unsigned short  ss_family;
+	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
+} __attribute__ ((aligned(_K_CSS_ALIGNSIZE)));
+#endif
+#endif
+
 #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
 
 #include <asm/socket.h>			/* arch-dependent defines	*/

---
commit b43bfbc68b2bb862c309615f1b5074009b453d3d
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
commit afdf2703bd9423a62cf7d984bdc88273fa205033
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
commit d54a002064782edebf3544a6d509c4ed30a8a03b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 24 17:28:31 2008 +0900

    [IPV6] COMPAT: group_source_req{}-setsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/in.h b/include/linux/in.h
index 4065313..8554dee 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -169,6 +169,16 @@ struct group_filter
 	(sizeof(struct group_filter) - sizeof(struct __kernel_sockaddr_storage) \
 	+ (numsrc) * sizeof(struct __kernel_sockaddr_storage))
 
+#ifdef __KERNEL__
+#ifdef CONFIG_COMPAT
+struct compat_group_source_req {
+	__u32					gsr_interface;
+	struct __compat_sockaddr_storage	gsr_group;
+	struct __compat_sockaddr_storage	gsr_source;
+};
+#endif
+#endif
+
 struct in_pktinfo
 {
 	int		ipi_ifindex;
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
commit d9ba3ae81a4c11210bddaf9d9650323adb9e6d9f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 24 17:30:15 2008 +0900

    [IPV6] COMPAT: group_req{}-setsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/in.h b/include/linux/in.h
index 8554dee..2fbd7c7 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -176,6 +176,12 @@ struct compat_group_source_req {
 	struct __compat_sockaddr_storage	gsr_group;
 	struct __compat_sockaddr_storage	gsr_source;
 };
+
+struct compat_group_req
+{
+	__u32				 	gr_interface;
+	struct __compat_sockaddr_storage 	gr_group;
+};
 #endif
 #endif
 
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
commit 3c055f969f7f3716f6846037c2ec0fa06e0424b3
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 24 17:32:10 2008 +0900

    [IPV6] COMPAT: group_filter{}-setsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/in.h b/include/linux/in.h
index 2fbd7c7..ccbfc76 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -182,6 +182,19 @@ struct compat_group_req
 	__u32				 	gr_interface;
 	struct __compat_sockaddr_storage 	gr_group;
 };
+
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
 #endif
 #endif
 
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
commit 473fd7b42bc26e03847d85561f9afa1371bc99cc
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
commit e920bd82cbc6e0b83087513a25220e9379b24b49
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
commit 9153c1a545f2366f57bf46bcd59d5b99d61016f7
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 24 17:51:30 2008 +0900

    [IPV6] COMPAT: group_filter{}-getsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 103272f..c98c722 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -574,6 +574,16 @@ extern int ip6_mc_msfget(struct sock *sk,
 			 struct group_filter __user *optval,
 			 int __user *optlen);
 
+#ifdef CONFIG_COMPAT
+struct compat_group_filter;
+
+int ip6_mc_compat_msfget(struct sock *sk,
+			 struct in6_addr *group,
+			 u32 gf_interface, u32 gf_numsrc,
+			 struct compat_group_filter __user *optval,
+			 int __user *optlen);
+#endif
+
 #ifdef CONFIG_PROC_FS
 extern int  ac6_proc_init(struct net *net);
 extern void ac6_proc_exit(struct net *net);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index d670078..46bafee 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1200,7 +1200,33 @@ static int
 compat_do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int __user *optlen)
 {
-	return do_ipv6_getsockopt(sk, level, optname, optval, optlen);
+	int len, err;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+
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
+					   gsf.gf_interface, gsf.gf_numsrc,
+					   (struct compat_group_filter __user *)optval,
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
commit f0e116fa05474aa7a8cbf9d25a534ab6cbf67977
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 24 18:49:23 2008 +0900

    [IPV4] COMPAT: Introduce compat_do_ip_{set,get}sockopt() wrapper.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index d8adfd4..2ba4fac 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -915,6 +915,13 @@ int ip_setsockopt(struct sock *sk, int level,
 }
 
 #ifdef CONFIG_COMPAT
+static int
+compat_do_ip_setsockopt(struct sock *sk, int level, int optname,
+			char __user *optval, int optlen)
+{
+	return do_ip_setsockopt(sk, level, optname, optval, optlen);
+}
+
 int compat_ip_setsockopt(struct sock *sk, int level, int optname,
 			 char __user *optval, int optlen)
 {
@@ -923,7 +930,7 @@ int compat_ip_setsockopt(struct sock *sk, int level, int optname,
 	if (level != SOL_IP)
 		return -ENOPROTOOPT;
 
-	err = do_ip_setsockopt(sk, level, optname, optval, optlen);
+	err = compat_do_ip_setsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err == -ENOPROTOOPT && optname != IP_HDRINCL &&
@@ -1178,10 +1185,17 @@ int ip_getsockopt(struct sock *sk, int level,
 }
 
 #ifdef CONFIG_COMPAT
+static int
+compat_do_ip_getsockopt(struct sock *sk, int level, int optname,
+			char __user *optval, int __user *optlen)
+{
+	return do_ip_getsockopt(sk, level, optname, optval, optlen);
+}
+
 int compat_ip_getsockopt(struct sock *sk, int level, int optname,
 			 char __user *optval, int __user *optlen)
 {
-	int err = do_ip_getsockopt(sk, level, optname, optval, optlen);
+	int err = compat_do_ip_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err == -ENOPROTOOPT && optname != IP_PKTOPTIONS &&

---
commit e3291172d59ea751d9e08233215d6f8396d76989
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 24 21:29:13 2008 +0900

    [IPV4] IGMP: Move mode check for ip_mreq_source/group_source_req{}-sockopts to net/ipv4/igmp.c.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index f5a1a0d..f240284 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -220,8 +220,8 @@ extern int igmp_rcv(struct sk_buff *);
 extern int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
 extern int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
 extern void ip_mc_drop_socket(struct sock *sk);
-extern int ip_mc_source(int add, int omode, struct sock *sk,
-		struct ip_mreq_source *mreqs, int ifindex);
+extern int ip_mc_source(struct sock *sk, int optname,
+			struct ip_mreq_source *pmreqs, int ifindex);
 extern int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf,int ifindex);
 extern int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 		struct ip_msfilter __user *optval, int __user *optlen);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 6250f42..c7c2994 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1865,8 +1865,8 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 	return ret;
 }
 
-int ip_mc_source(int add, int omode, struct sock *sk, struct
-	ip_mreq_source *mreqs, int ifindex)
+static int __ip_mc_source(int add, int omode, struct sock *sk,
+			  struct ip_mreq_source *mreqs, int ifindex)
 {
 	int err;
 	struct ip_mreqn imr;
@@ -2000,6 +2000,36 @@ done:
 	return err;
 }
 
+int ip_mc_source(struct sock *sk, int optname,
+		 struct ip_mreq_source *pmreqs, int ifindex)
+{
+	int omode, add;
+
+	if (optname == MCAST_BLOCK_SOURCE) {
+		omode = MCAST_EXCLUDE;
+		add = 1;
+	} else if (optname == MCAST_UNBLOCK_SOURCE) {
+		omode = MCAST_EXCLUDE;
+		add = 0;
+	} else if (optname == MCAST_JOIN_SOURCE_GROUP) {
+		struct ip_mreqn mreq;
+		int err;
+
+		mreq.imr_multiaddr.s_addr = pmreqs->imr_multiaddr;
+		mreq.imr_address.s_addr = 0;
+		mreq.imr_ifindex = ifindex;
+		err = ip_mc_join_group(sk, &mreq);
+		if (err && err != -EADDRINUSE)
+			return err;
+		omode = MCAST_INCLUDE;
+		add = 1;
+	} else /* MCAST_LEAVE_SOURCE_GROUP */ {
+		omode = MCAST_INCLUDE;
+		add = 0;
+	}
+	return __ip_mc_source(add, omode, sk, pmreqs, ifindex);
+}
+
 int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 {
 	int err = 0;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 2ba4fac..5ebd668 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -684,7 +684,6 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	case IP_DROP_SOURCE_MEMBERSHIP:
 	{
 		struct ip_mreq_source mreqs;
-		int omode, add;
 
 		if (optlen != sizeof(struct ip_mreq_source))
 			goto e_inval;
@@ -692,28 +691,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			err = -EFAULT;
 			break;
 		}
-		if (optname == IP_BLOCK_SOURCE) {
-			omode = MCAST_EXCLUDE;
-			add = 1;
-		} else if (optname == IP_UNBLOCK_SOURCE) {
-			omode = MCAST_EXCLUDE;
-			add = 0;
-		} else if (optname == IP_ADD_SOURCE_MEMBERSHIP) {
-			struct ip_mreqn mreq;
-
-			mreq.imr_multiaddr.s_addr = mreqs.imr_multiaddr;
-			mreq.imr_address.s_addr = mreqs.imr_interface;
-			mreq.imr_ifindex = 0;
-			err = ip_mc_join_group(sk, &mreq);
-			if (err && err != -EADDRINUSE)
-				break;
-			omode = MCAST_INCLUDE;
-			add = 1;
-		} else /* IP_DROP_SOURCE_MEMBERSHIP */ {
-			omode = MCAST_INCLUDE;
-			add = 0;
-		}
-		err = ip_mc_source(add, omode, sk, &mreqs, 0);
+		err = ip_mc_source(sk, optname, &mreqs, 0);
 		break;
 	}
 	case MCAST_JOIN_GROUP:
@@ -749,7 +727,6 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		struct group_source_req greqs;
 		struct ip_mreq_source mreqs;
 		struct sockaddr_in *psin;
-		int omode, add;
 
 		if (optlen != sizeof(struct group_source_req))
 			goto e_inval;
@@ -768,31 +745,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		mreqs.imr_sourceaddr = psin->sin_addr.s_addr;
 		mreqs.imr_interface = 0; /* use index for mc_source */
 
-		if (optname == MCAST_BLOCK_SOURCE) {
-			omode = MCAST_EXCLUDE;
-			add = 1;
-		} else if (optname == MCAST_UNBLOCK_SOURCE) {
-			omode = MCAST_EXCLUDE;
-			add = 0;
-		} else if (optname == MCAST_JOIN_SOURCE_GROUP) {
-			struct ip_mreqn mreq;
-
-			psin = (struct sockaddr_in *)&greqs.gsr_group;
-			mreq.imr_multiaddr = psin->sin_addr;
-			mreq.imr_address.s_addr = 0;
-			mreq.imr_ifindex = greqs.gsr_interface;
-			err = ip_mc_join_group(sk, &mreq);
-			if (err && err != -EADDRINUSE)
-				break;
-			greqs.gsr_interface = mreq.imr_ifindex;
-			omode = MCAST_INCLUDE;
-			add = 1;
-		} else /* MCAST_LEAVE_SOURCE_GROUP */ {
-			omode = MCAST_INCLUDE;
-			add = 0;
-		}
-		err = ip_mc_source(add, omode, sk, &mreqs,
-				   greqs.gsr_interface);
+		err = ip_mc_source(sk, optname, &mreqs, greqs.gsr_interface);
 		break;
 	}
 	case MCAST_MSFILTER:

---
commit 64c1bb9b0ba8ffb7ac6f666ae2cee08887ae49ee
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 24 21:49:30 2008 +0900

    [IPV4] COMPAT: group_source_req{}-setsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 5ebd668..40a43a8 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -872,7 +872,47 @@ static int
 compat_do_ip_setsockopt(struct sock *sk, int level, int optname,
 			char __user *optval, int optlen)
 {
-	return do_ip_setsockopt(sk, level, optname, optval, optlen);
+	int retv;
+
+	switch (optname) {
+	case MCAST_JOIN_SOURCE_GROUP:
+	case MCAST_LEAVE_SOURCE_GROUP:
+	case MCAST_BLOCK_SOURCE:
+	case MCAST_UNBLOCK_SOURCE:
+	    {
+		struct compat_group_source_req __user *ugreqs = (void __user *)optval;
+		struct sockaddr_in sin;
+		struct ip_mreq_source mreqs;
+		u32 interface;
+
+		if (optlen < sizeof(struct compat_group_source_req))
+			return -EINVAL;
+
+		if (access_ok(VERIFY_READ, optval, sizeof(*ugreqs)) ||
+		    __get_user(interface, &ugreqs->gsr_interface))
+			return -EFAULT;
+
+		if (__copy_from_user(&sin, &ugreqs->gsr_group, sizeof(sin)))
+			return -EFAULT;
+		if (sin.sin_family != AF_INET)
+			return -EADDRNOTAVAIL;
+		mreqs.imr_multiaddr = sin.sin_addr.s_addr;
+
+		if (__copy_from_user(&sin, &ugreqs->gsr_source, sizeof(sin)))
+			return -EFAULT;
+		if (sin.sin_family != AF_INET)
+			return -EADDRNOTAVAIL;
+		mreqs.imr_sourceaddr = sin.sin_addr.s_addr;
+
+		mreqs.imr_interface = 0; /* use index for mc_source */
+
+		retv = ip_mc_source(sk, optname, &mreqs, interface);
+		break;
+	    }
+	default:
+		retv = do_ip_setsockopt(sk, level, optname, optval, optlen);
+	}
+	return retv;
 }
 
 int compat_ip_setsockopt(struct sock *sk, int level, int optname,

---
commit 7413ae14041b6b4058d445c1b122d61305554869
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Apr 24 21:56:41 2008 +0900

    [IPV4] COMPAT: group_req{}-setsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 40a43a8..ad2fe9b 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -875,6 +875,35 @@ compat_do_ip_setsockopt(struct sock *sk, int level, int optname,
 	int retv;
 
 	switch (optname) {
+	case MCAST_JOIN_GROUP:
+	case MCAST_LEAVE_GROUP:
+	    {
+		struct compat_group_req __user *ugreq = (void __user *)optval;
+		struct ip_mreqn mreq;
+		struct sockaddr_in sin;
+		u32 interface;
+
+		if (optlen < sizeof(struct compat_group_req))
+			return -EINVAL;
+
+		if (access_ok(VERIFY_READ, ugreq, sizeof(*ugreq)) ||
+		    __get_user(interface, &ugreq->gr_interface) ||
+		    __copy_from_user(&sin, &ugreq->gr_group, sizeof(sin)))
+			return -EFAULT;
+
+		if (sin.sin_family != AF_INET)
+			return -EINVAL;
+
+		mreq.imr_multiaddr = sin.sin_addr;
+		mreq.imr_ifindex = interface;
+
+		if (optname == MCAST_JOIN_GROUP)
+			retv = ip_mc_join_group(sk, &mreq);
+		else
+			retv = ip_mc_leave_group(sk, &mreq);
+		break;
+	    }
+
 	case MCAST_JOIN_SOURCE_GROUP:
 	case MCAST_LEAVE_SOURCE_GROUP:
 	case MCAST_BLOCK_SOURCE:

---
commit 6e4ebfa0808931db2e00626f2b67568f4eb94efe
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 25 01:27:13 2008 +0900

    [IPV4] COMPAT: group_filter{}-setsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index ad2fe9b..b92b750 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -938,6 +938,64 @@ compat_do_ip_setsockopt(struct sock *sk, int level, int optname,
 		retv = ip_mc_source(sk, optname, &mreqs, interface);
 		break;
 	    }
+	case MCAST_MSFILTER:
+	    {
+		extern int sysctl_igmp_max_msf;
+		struct compat_group_filter __user *ugsf = (void __user *)optval;
+		struct ip_msfilter *msf;
+		struct sockaddr_in sin;
+		u32 gf_interface, gf_numsrc;
+		int i;
+
+		if (optlen < COMPAT_GROUP_FILTER_SIZE(0))
+			return -EINVAL;
+		if (access_ok(VERIFY_READ, ugsf, COMPAT_GROUP_FILTER_SIZE(0)) ||
+		    __get_user(gf_numsrc, &ugsf->gf_numsrc))
+			return -EFAULT;
+
+		if (COMPAT_GROUP_FILTER_SIZE(gf_numsrc) > optlen)
+			retv = -EINVAL;
+
+		if (optlen > sysctl_optmem_max ||
+		    gf_numsrc >= 0x1ffffffU ||
+		    gf_numsrc > sysctl_igmp_max_msf)
+			return -ENOBUFS;
+
+		optlen = IP_MSFILTER_SIZE(gf_numsrc);
+		msf = kmalloc(optlen, GFP_KERNEL);
+		if (!msf)
+			return -ENOBUFS;
+
+		retv = -EFAULT;
+		if (__get_user(gf_interface, &ugsf->gf_interface) ||
+		    __copy_from_user(&sin, &ugsf->gf_group, sizeof(sin)) ||
+		    __get_user(msf->imsf_fmode, &ugsf->gf_fmode) ||
+		    access_ok(VERIFY_READ, ugsf->gf_slist,
+			      sizeof(struct __compat_sockaddr_storage) * gf_numsrc))
+			goto kfree_out;
+
+		if (sin.sin_family != AF_INET) {
+			retv = -EADDRNOTAVAIL;
+			goto kfree_out;
+		}
+
+		msf->imsf_multiaddr = sin.sin_addr.s_addr;
+		msf->imsf_interface = 0;
+		msf->imsf_numsrc = gf_numsrc;
+
+		for (i = 0; i < gf_numsrc; i++) {
+			if (__copy_from_user(&sin, &ugsf->gf_slist[i], sizeof(sin)))
+				retv = -EFAULT;
+			if (sin.sin_family != AF_INET) {
+				retv = -EADDRNOTAVAIL;
+				goto kfree_out;
+			}
+			msf->imsf_slist[i] = sin.sin_addr.s_addr;
+		}
+		retv = ip_mc_msfilter(sk, msf, gf_interface);
+kfree_out:
+		kfree(msf);
+	    }
 	default:
 		retv = do_ip_setsockopt(sk, level, optname, optval, optlen);
 	}

---
commit 38e600fc28a5309be4fe100fede207486106ed70
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 25 00:59:49 2008 +0900

    [IPV4] IGMP: Consolidate common code path of ip_mc_{msf,gsf}get().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index c7c2994..adc0b03 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2116,123 +2116,129 @@ done:
 	return err;
 }
 
-int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
-	struct ip_msfilter __user *optval, int __user *optlen)
+int __ip_mc_msf_lookup(struct sock *sk, __be32 group, int interface,
+		       struct ip_sf_socklist **ppsl)
 {
-	int err, len, count, copycount;
-	struct ip_mreqn	imr;
-	__be32 addr = msf->imsf_multiaddr;
-	struct ip_mc_socklist *pmc;
+	struct ip_mreqn imr;
 	struct in_device *in_dev;
+	struct ip_mc_socklist *pmc;
 	struct inet_sock *inet = inet_sk(sk);
-	struct ip_sf_socklist *psl;
-
-	if (!ipv4_is_multicast(addr))
-		return -EINVAL;
-
-	if (sock_net(sk) != &init_net)
-		return -EPROTONOSUPPORT;
+	int ret;
 
 	rtnl_lock();
 
-	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
-	imr.imr_address.s_addr = msf->imsf_interface;
+	imr.imr_multiaddr.s_addr = group;
+	imr.imr_address.s_addr = interface;
 	imr.imr_ifindex = 0;
 	in_dev = ip_mc_find_dev(&imr);
 
 	if (!in_dev) {
-		err = -ENODEV;
-		goto done;
+		ret = -ENODEV;
+		goto out;
 	}
-	err = -EADDRNOTAVAIL;
 
+	ret = -EADDRNOTAVAIL;
 	for (pmc=inet->mc_list; pmc; pmc=pmc->next) {
-		if (pmc->multi.imr_multiaddr.s_addr == msf->imsf_multiaddr &&
-		    pmc->multi.imr_ifindex == imr.imr_ifindex)
+		if (pmc->multi.imr_multiaddr.s_addr == group &&
+		    pmc->multi.imr_ifindex == interface)
 			break;
 	}
-	if (!pmc)		/* must have a prior join */
-		goto done;
-	msf->imsf_fmode = pmc->sfmode;
-	psl = pmc->sflist;
-	rtnl_unlock();
-	if (!psl) {
-		len = 0;
-		count = 0;
-	} else {
-		count = psl->sl_count;
-	}
-	copycount = count < msf->imsf_numsrc ? count : msf->imsf_numsrc;
-	len = copycount * sizeof(psl->sl_addr[0]);
-	msf->imsf_numsrc = count;
-	if (put_user(IP_MSFILTER_SIZE(copycount), optlen) ||
-	    copy_to_user(optval, msf, IP_MSFILTER_SIZE(0))) {
-		return -EFAULT;
-	}
-	if (len &&
-	    copy_to_user(&optval->imsf_slist[0], psl->sl_addr, len))
-		return -EFAULT;
+
+        if (pmc) {
+		*ppsl = pmc->sflist;
+		ret = pmc->sfmode;
+	}
+
+out:
+        rtnl_unlock();
+	return ret;
+}
+
+int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
+	struct ip_msfilter __user *optval, int __user *optlen)
+{
+	struct ip_sf_socklist *psl;
+	__be32 group = msf->imsf_multiaddr;
+	int fmode;
+
+	if (sock_net(sk) != &init_net)
+		return -EPROTONOSUPPORT;
+
+	if (!ipv4_is_multicast(group))
+		return -EINVAL;
+
+	fmode = __ip_mc_msf_lookup(sk, group, msf->imsf_interface,
+				   &psl);
+	if (fmode < 0)
+		return fmode;
+
+	if (psl) {
+		int count = psl->sl_count;
+		int copycount;
+
+		copycount = count < msf->imsf_numsrc ? count : msf->imsf_numsrc;
+
+		if (put_user(IP_MSFILTER_SIZE(copycount), optlen) ||
+		    access_ok(VERIFY_WRITE, optval, IP_MSFILTER_SIZE(copycount)) ||
+		    __put_user((u32)fmode, &optval->imsf_fmode) ||
+		    __put_user((u32)count, &optval->imsf_numsrc))
+			return -EFAULT;
+
+		if (copycount &&
+		    __copy_to_user(psl->sl_addr, optval->imsf_slist,
+				   sizeof(psl->sl_addr[0]) * copycount))
+			return -EFAULT;
+	}
 	return 0;
-done:
-	rtnl_unlock();
-	return err;
 }
 
 int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	struct group_filter __user *optval, int __user *optlen)
 {
-	int err, i, count, copycount;
-	struct sockaddr_in *psin;
-	__be32 addr;
-	struct ip_mc_socklist *pmc;
-	struct inet_sock *inet = inet_sk(sk);
+	struct sockaddr_in *gf_group = (struct sockaddr_in *)&gsf->gf_group;
 	struct ip_sf_socklist *psl;
+	int fmode;
+
+	if (sock_net(sk) != &init_net)
+		return -EPROTONOSUPPORT;
 
-	psin = (struct sockaddr_in *)&gsf->gf_group;
-	if (psin->sin_family != AF_INET)
+	if (gf_group->sin_family != AF_INET)
 		return -EINVAL;
-	addr = psin->sin_addr.s_addr;
-	if (!ipv4_is_multicast(addr))
+	if (!ipv4_is_multicast(gf_group->sin_addr.s_addr))
 		return -EINVAL;
 
-	if (sock_net(sk) != &init_net)
-		return -EPROTONOSUPPORT;
+	fmode = __ip_mc_msf_lookup(sk, gf_group->sin_addr.s_addr, gsf->gf_interface,
+				   &psl);
+	if (fmode < 0)
+		return fmode;
 
-	rtnl_lock();
+	if (psl) {
+		int count = psl->sl_count;
+		int i, copycount;
+		struct sockaddr_in sin;
 
-	err = -EADDRNOTAVAIL;
+		copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
 
-	for (pmc=inet->mc_list; pmc; pmc=pmc->next) {
-		if (pmc->multi.imr_multiaddr.s_addr == addr &&
-		    pmc->multi.imr_ifindex == gsf->gf_interface)
-			break;
-	}
-	if (!pmc)		/* must have a prior join */
-		goto done;
-	gsf->gf_fmode = pmc->sfmode;
-	psl = pmc->sflist;
-	rtnl_unlock();
-	count = psl ? psl->sl_count : 0;
-	copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
-	gsf->gf_numsrc = count;
-	if (put_user(GROUP_FILTER_SIZE(copycount), optlen) ||
-	    copy_to_user(optval, gsf, GROUP_FILTER_SIZE(0))) {
-		return -EFAULT;
-	}
-	for (i=0; i<copycount; i++) {
-		struct sockaddr_storage ss;
-
-		psin = (struct sockaddr_in *)&ss;
-		memset(&ss, 0, sizeof(ss));
-		psin->sin_family = AF_INET;
-		psin->sin_addr.s_addr = psl->sl_addr[i];
-		if (copy_to_user(&optval->gf_slist[i], &ss, sizeof(ss)))
+		if (put_user(GROUP_FILTER_SIZE(copycount), optlen) ||
+		    access_ok(VERIFY_WRITE, optval, GROUP_FILTER_SIZE(copycount)) ||
+		    __put_user((u32)fmode, &optval->gf_fmode) ||
+		    __put_user((u32)count, &optval->gf_numsrc))
 			return -EFAULT;
+
+		memset(&sin, 0, sizeof(sin));
+		sin.sin_family = AF_INET;
+
+		for (i = 0; i < copycount; i++) {
+			struct sockaddr_in __user *usin = (void __user *)&optval->gf_slist[i];
+
+			sin.sin_addr.s_addr = psl->sl_addr[i];
+
+			if (__copy_to_user(usin, &sin, sizeof(sin)) ||
+			    __clear_user(usin + 1, sizeof(optval->gf_slist[i]) - sizeof(*usin)))
+				return -EFAULT;
+		}
 	}
 	return 0;
-done:
-	rtnl_unlock();
-	return err;
 }
 
 /*

---
commit 6cb6e044b1d3ead803053b482bd47a84a41b9a58
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 25 01:14:45 2008 +0900

    [IPV4] IGMP: Make ip_mc_gsfget() more generic.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index f240284..106d0d2 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -225,7 +225,8 @@ extern int ip_mc_source(struct sock *sk, int optname,
 extern int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf,int ifindex);
 extern int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 		struct ip_msfilter __user *optval, int __user *optlen);
-extern int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
+extern int ip_mc_gsfget(struct sock *sk,
+		struct sockaddr_in *gsf_group, u32 gsf_interface, u32 gsf_numsrc,
 		struct group_filter __user *optval, int __user *optlen);
 extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt, int dif);
 extern void ip_mr_init(void);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index adc0b03..a2bfc6d 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2192,10 +2192,10 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	return 0;
 }
 
-int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
+int ip_mc_gsfget(struct sock *sk,
+	struct sockaddr_in *gf_group, u32 gf_interface, u32 gf_numsrc,
 	struct group_filter __user *optval, int __user *optlen)
 {
-	struct sockaddr_in *gf_group = (struct sockaddr_in *)&gsf->gf_group;
 	struct ip_sf_socklist *psl;
 	int fmode;
 
@@ -2207,7 +2207,7 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	if (!ipv4_is_multicast(gf_group->sin_addr.s_addr))
 		return -EINVAL;
 
-	fmode = __ip_mc_msf_lookup(sk, gf_group->sin_addr.s_addr, gsf->gf_interface,
+	fmode = __ip_mc_msf_lookup(sk, gf_group->sin_addr.s_addr, gf_interface,
 				   &psl);
 	if (fmode < 0)
 		return fmode;
@@ -2217,7 +2217,7 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 		int i, copycount;
 		struct sockaddr_in sin;
 
-		copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
+		copycount = count < gf_numsrc ? count : gf_numsrc;
 
 		if (put_user(GROUP_FILTER_SIZE(copycount), optlen) ||
 		    access_ok(VERIFY_WRITE, optval, GROUP_FILTER_SIZE(copycount)) ||
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index b92b750..1e24209 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1178,7 +1178,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 			release_sock(sk);
 			return -EFAULT;
 		}
-		err = ip_mc_gsfget(sk, &gsf,
+		err = ip_mc_gsfget(sk,
+				   (struct sockaddr_in *)&gsf.gf_group,
+				   gsf.gf_interface, gsf.gf_numsrc,
 				   (struct group_filter __user *)optval, optlen);
 		release_sock(sk);
 		return err;

---
commit 22a5c1e1f922a15b03b7271eb9ce974833755721
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 25 01:41:44 2008 +0900

    [IPV4] COMPAT: group_filter{}-getsockopt compat layer.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 106d0d2..6a927dc 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -228,6 +228,11 @@ extern int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 extern int ip_mc_gsfget(struct sock *sk,
 		struct sockaddr_in *gsf_group, u32 gsf_interface, u32 gsf_numsrc,
 		struct group_filter __user *optval, int __user *optlen);
+#ifdef CONFIG_COMPAT
+extern int ip_mc_compat_gsfget(struct sock *sk,
+		struct sockaddr_in *gsf_group, u32 gsf_interface, u32 gsf_numsrc,
+		struct compat_group_filter __user *optval, int __user *optlen);
+#endif
 extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt, int dif);
 extern void ip_mr_init(void);
 extern void ip_mc_init_dev(struct in_device *);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index a2bfc6d..3e68dc6 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2241,6 +2241,57 @@ int ip_mc_gsfget(struct sock *sk,
 	return 0;
 }
 
+#ifdef CONFIG_COMPAST
+int ip_mc_compat_gsfget(struct sock *sk,
+	struct sockaddr_in *gr_group, u32 gf_interface, u32 gf_numsrc,
+	struct compat_group_filter __user *optval, int __user *optlen)
+{
+	struct ip_sf_socklist *psl;
+	int fmode;
+
+	if (sock_net(sk) != &init_net)
+		return -EPROTONOSUPPORT;
+
+	if (gr_group->sin_family != AF_INET)
+		return -EINVAL;
+	if (!ipv4_is_multicast(gr_group->sin_addr.s_addr))
+		return -EINVAL;
+
+	fmode = __ip_mc_msf_lookup(sk, gr_group->sin_addr.s_addr, gf_interface,
+				   &psl);
+	if (fmode < 0)
+		return fmode;
+
+	if (psl) {
+		int count = psl->sl_count;
+		int i, copycount;
+		struct sockaddr_in sin;
+		
+		copycount = count < gf_numsrc ? count : gf_numsrc;
+
+		if (put_user(COMPAT_GROUP_FILTER_SIZE(copycount), optlen) ||
+		    access_ok(VERIFY_WRITE, optval, COMPAT_GROUP_FILTER_SIZE(copycount)) ||
+		    __put_user((u32)fmode, &optval->gf_fmode) ||
+		    __put_user((u32)count, &optval->gf_numsrc))
+			return -EFAULT;
+
+		memset(&sin, 0, sizeof(sin));
+		sin.sin_family = AF_INET;
+
+		for (i = 0; i < copycount; i++) {
+			struct sockaddr_in __user *usin = (void __user *)&optval->gf_slist[i];
+
+			sin.sin_addr.s_addr = psl->sl_addr[i];
+
+			if (__copy_to_user(usin, &sin, sizeof(sin)) ||
+			    __clear_user(usin + 1, sizeof(optval->gf_slist[i]) - sizeof(*usin)))
+				return -EFAULT;
+		}
+	}
+	return 0;
+}
+#endif
+
 /*
  * check if a multicast source filter allows delivery for a given <src,dst,intf>
  */

---
