From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] add compat support for getsockopt (MCAST_MSFILTER)
Date: Mon, 28 Apr 2008 16:52:20 +0900 (JST)
Message-ID: <20080428.165220.27263306.yoshfuji@linux-ipv6.org>
References: <20080428.153650.57555735.yoshfuji@linux-ipv6.org>
	<OF81CA6D67.1BAD70DD-ON88257439.00251005-88257439.0025FC25@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Mon_Apr_28_16_52_22_2008_171)--"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33836 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932816AbYD1HwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 03:52:21 -0400
In-Reply-To: <OF81CA6D67.1BAD70DD-ON88257439.00251005-88257439.0025FC25@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----Next_Part(Mon_Apr_28_16_52_22_2008_171)--
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit

In article <OF81CA6D67.1BAD70DD-ON88257439.00251005-88257439.0025FC25@us.ibm.com> (at Sun, 27 Apr 2008 23:54:56 -0700), David Stevens <dlstevens@us.ibm.com> says:

> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote on 04/27/2008 
> 11:36:50 PM:
> 
> > IMHO, It's much better to split into 2 pathces - bug fixes and
> > getsockopt() support...
> 
>         Ordinarily, I'd agree, but I came across this in the
> getsockopt code which has the same issue and both the
> new code and fix require the same #define that's in the
> getsockopt code. I retested all of it before submitting, too.

That does not seem to be an excuse, and it is not a
good practice to me.

- Several cleanups for the setsockopt compat support.
- Add compat support for getsockopt (MCAST_MSFILTER)

Feel free to use these, sync'ed with current net-2.6.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

----Next_Part(Mon_Apr_28_16_52_22_2008_171)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-Several-cleanups-for-the-setsockopt-compat-support.txt"

>From dd8100caaa5669ee31e20e1c4a5568f3777fbaf5 Mon Sep 17 00:00:00 2001
From: David Stevens <dlstevens@us.ibm.com>
Date: Sun, 27 Apr 2008 23:41:51 -0600
Subject: [PATCH 1/2] Several cleanups for the setsockopt compat support.

1) added missing "__user" for kgsr and kgf pointers
2) verify read for only GROUP_FILTER_SIZE(0). The group_filter
        structure definition (via RFC) includes space for one source
        in the source list array, but that source need not be present.
        So, sizeof(group_filter) > GROUP_FILTER_SIZE(0). Fixed
        the user read-check for minimum length to use the smaller size.
3) remove unneeded "&" for gf_slist addresses

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/compat.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/compat.c b/net/compat.c
index 01bf95d..8146f65 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -548,6 +548,9 @@ struct compat_group_filter {
 		__attribute__ ((aligned(4)));
 } __attribute__ ((packed));
 
+#define __COMPAT_GF0_SIZE (sizeof(struct compat_group_filter) - \
+			sizeof(struct __kernel_sockaddr_storage))
+
 
 int compat_mc_setsockopt(struct sock *sock, int level, int optname,
 	char __user *optval, int optlen,
@@ -582,7 +585,7 @@ int compat_mc_setsockopt(struct sock *sock, int level, int optname,
 	case MCAST_UNBLOCK_SOURCE:
 	{
 		struct compat_group_source_req __user *gsr32 = (void *)optval;
-		struct group_source_req *kgsr = compat_alloc_user_space(
+		struct group_source_req __user *kgsr = compat_alloc_user_space(
 			sizeof(struct group_source_req));
 		u32 interface;
 
@@ -603,10 +606,10 @@ int compat_mc_setsockopt(struct sock *sock, int level, int optname,
 	case MCAST_MSFILTER:
 	{
 		struct compat_group_filter __user *gf32 = (void *)optval;
-		struct group_filter *kgf;
+		struct group_filter __user *kgf;
 		u32 interface, fmode, numsrc;
 
-		if (!access_ok(VERIFY_READ, gf32, sizeof(*gf32)) ||
+		if (!access_ok(VERIFY_READ, gf32, __COMPAT_GF0_SIZE) ||
 		    __get_user(interface, &gf32->gf_interface) ||
 		    __get_user(fmode, &gf32->gf_fmode) ||
 		    __get_user(numsrc, &gf32->gf_numsrc))
@@ -622,7 +625,7 @@ int compat_mc_setsockopt(struct sock *sock, int level, int optname,
 		    __put_user(numsrc, &kgf->gf_numsrc) ||
 		    copy_in_user(&kgf->gf_group, &gf32->gf_group,
 				sizeof(kgf->gf_group)) ||
-		    (numsrc && copy_in_user(&kgf->gf_slist, &gf32->gf_slist,
+		    (numsrc && copy_in_user(kgf->gf_slist, gf32->gf_slist,
 				numsrc * sizeof(kgf->gf_slist[0]))))
 			return -EFAULT;
 		koptval = (char __user *)kgf;
-- 
1.4.4.4


----Next_Part(Mon_Apr_28_16_52_22_2008_171)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0002-Add-compat-support-for-getsockopt-MCAST_MSFILTER.txt"

>From 3a67089201855f959d7a93506cd4a21fd4df8183 Mon Sep 17 00:00:00 2001
From: David Stevens <dlstevens@us.ibm.com>
Date: Sun, 27 Apr 2008 23:41:51 -0600
Subject: [PATCH 2/2] Add compat support for getsockopt (MCAST_MSFILTER)

This patch adds support for getsockopt for MCAST_MSFILTER for
both IPv4 and IPv6. It depends on the previous setsockopt patch,
and uses the same method.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/compat.h     |    3 ++
 net/compat.c             |   79 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_sockglue.c   |    9 +++++-
 net/ipv6/ipv6_sockglue.c |    4 ++
 4 files changed, 94 insertions(+), 1 deletions(-)

diff --git a/include/net/compat.h b/include/net/compat.h
index 05fa5d0..164cb68 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -42,5 +42,8 @@ extern int cmsghdr_from_user_compat_to_kern(struct msghdr *, struct sock *, unsi
 
 extern int compat_mc_setsockopt(struct sock *, int, int, char __user *, int,
 	int (*)(struct sock *, int, int, char __user *, int));
+extern int compat_mc_getsockopt(struct sock *, int, int, char __user *,
+	int __user *, int (*)(struct sock *, int, int, char __user *,
+				int __user *));
 
 #endif /* NET_COMPAT_H */
diff --git a/net/compat.c b/net/compat.c
index 8146f65..c823f6f 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -640,6 +640,85 @@ int compat_mc_setsockopt(struct sock *sock, int level, int optname,
 
 EXPORT_SYMBOL(compat_mc_setsockopt);
 
+int compat_mc_getsockopt(struct sock *sock, int level, int optname,
+	char __user *optval, int __user *optlen,
+	int (*getsockopt)(struct sock *,int,int,char __user *,int __user *))
+{
+	struct compat_group_filter __user *gf32 = (void *)optval;
+	struct group_filter __user *kgf;
+	int __user	*koptlen;
+	u32 interface, fmode, numsrc;
+	int klen, ulen, err;
+
+	if (optname != MCAST_MSFILTER)
+		return getsockopt(sock, level, optname, optval, optlen);
+
+	koptlen = compat_alloc_user_space(sizeof(*koptlen));
+	if (!access_ok(VERIFY_READ, optlen, sizeof(*optlen)) ||
+	    __get_user(ulen, optlen))
+		return -EFAULT;
+
+	/* adjust len for pad */
+	klen = ulen + sizeof(*kgf) - sizeof(*gf32);
+
+	if (klen < GROUP_FILTER_SIZE(0))
+		return -EINVAL;
+
+	if (!access_ok(VERIFY_WRITE, koptlen, sizeof(*koptlen)) ||
+	    __put_user(klen, koptlen))
+		return -EFAULT;
+
+	/* have to allow space for previous compat_alloc_user_space, too */
+	kgf = compat_alloc_user_space(klen+sizeof(*optlen));
+
+	if (!access_ok(VERIFY_READ, gf32, __COMPAT_GF0_SIZE) ||
+	    __get_user(interface, &gf32->gf_interface) ||
+	    __get_user(fmode, &gf32->gf_fmode) ||
+	    __get_user(numsrc, &gf32->gf_numsrc) ||
+	    __put_user(interface, &kgf->gf_interface) ||
+	    __put_user(fmode, &kgf->gf_fmode) ||
+	    __put_user(numsrc, &kgf->gf_numsrc) ||
+	    copy_in_user(&kgf->gf_group,&gf32->gf_group,sizeof(kgf->gf_group)))
+		return -EFAULT;
+
+	err = getsockopt(sock, level, optname, (char __user *)kgf, koptlen);
+	if (err)
+		return err;
+
+	if (!access_ok(VERIFY_READ, koptlen, sizeof(*koptlen)) ||
+	    __get_user(klen, koptlen))
+		return -EFAULT;
+
+	ulen = klen - (sizeof(*kgf)-sizeof(*gf32));
+
+	if (!access_ok(VERIFY_WRITE, optlen, sizeof(*optlen)) ||
+	    __put_user(ulen, optlen))
+		return -EFAULT;
+
+	if (!access_ok(VERIFY_READ, kgf, klen) ||
+	    !access_ok(VERIFY_WRITE, gf32, ulen) ||
+	    __get_user(interface, &kgf->gf_interface) ||
+	    __get_user(fmode, &kgf->gf_fmode) ||
+	    __get_user(numsrc, &kgf->gf_numsrc) ||
+	    __put_user(interface, &gf32->gf_interface) ||
+	    __put_user(fmode, &gf32->gf_fmode) ||
+	    __put_user(numsrc, &gf32->gf_numsrc))
+		return -EFAULT;
+	if (numsrc) {
+		int copylen;
+
+		klen -= GROUP_FILTER_SIZE(0);
+		copylen = numsrc * sizeof(gf32->gf_slist[0]);
+		if (copylen > klen)
+			copylen = klen;
+	        if (copy_in_user(gf32->gf_slist, kgf->gf_slist, copylen))
+			return -EFAULT;
+	}
+	return err;
+}
+
+EXPORT_SYMBOL(compat_mc_getsockopt);
+
 
 /* Argument list sizes for compat_sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 4d8d954..e0514e8 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1186,7 +1186,14 @@ int ip_getsockopt(struct sock *sk, int level,
 int compat_ip_getsockopt(struct sock *sk, int level, int optname,
 			 char __user *optval, int __user *optlen)
 {
-	int err = do_ip_getsockopt(sk, level, optname, optval, optlen);
+	int err;
+
+	if (optname == MCAST_MSFILTER)
+		return compat_mc_getsockopt(sk, level, optname, optval, optlen,
+			ip_getsockopt);
+
+	err = do_ip_getsockopt(sk, level, optname, optval, optlen);
+
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err == -ENOPROTOOPT && optname != IP_PKTOPTIONS &&
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index db6fdc1..b4a26f2 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1089,6 +1089,10 @@ int ipv6_getsockopt(struct sock *sk, int level, int optname,
 	if(level != SOL_IPV6)
 		return -ENOPROTOOPT;
 
+	if (optname == MCAST_MSFILTER)
+		return compat_mc_getsockopt(sk, level, optname, optval, optlen,
+			ipv6_getsockopt);
+
 	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
-- 
1.4.4.4


----Next_Part(Mon_Apr_28_16_52_22_2008_171)----
