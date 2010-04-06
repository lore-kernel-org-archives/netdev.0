From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] ipmr:  Fix struct mfcctl to be independent of MAXVIFS v2
Date: Tue, 06 Apr 2010 08:38:17 -0700
Message-ID: <m1eiis8uc6.fsf@fess.ebiederm.org>
References: <m1mxxgbwtl.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Ilia K <mail4ilia@gmail.com>, Tom Goff <thomas.goff@boeing.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51147 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100Ab0DFPiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 11:38:22 -0400
In-Reply-To: <m1mxxgbwtl.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 06 Apr 2010 05\:16\:22 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Right now if you recompile the kernel increasing MAXVIFS
to support more VIFS users of the MRT_ADD_VIF and MRT_DEL_VIF
will break because the ABI changed.

My goal is an API that works with just a recompile of existing
applications, and an ABI that continues to work for old
applications.

The unused/dead fields at the end of struct mfcctl make this
exercise more difficult than it should be.

- Rename the existing struct mfcctl mfcctl_old.
- Define a new and larger struct mfcctl that we can detect
  by size.

  The new and larger struct mfcctl won't have trailing garbage
  fields so we can accept anything of that size or larger,
  and simply ignore the entries that are above MAXVIFS.

My new struct mfcctl is now 128 bytes which is noticeable on
the stack but should still be small enough not to cause problems.

v2:  Rework the support larger arrays so that most/all? existing
   applications can simply be recompiled and work with a larger
   maximum number of VIFS.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/mroute.h |   20 +++++++++++++++-----
 net/ipv4/ipmr.c        |   17 ++++++++++++++---
 2 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index c5f3d53..6dbdebf 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -76,15 +76,25 @@ struct vifctl {
  *	Cache manipulation structures for mrouted and PIMd
  */
  
+struct mfcctl_old {
+#define MFCCTL_OLD_VIFS 32
+	struct in_addr mfcc_origin;		/* Origin of mcast	*/
+	struct in_addr mfcc_mcastgrp;		/* Group in question	*/
+	vifi_t	mfcc_parent;			/* Where it arrived	*/
+	unsigned char mfcc_ttls[MFCCTL_OLD_VIFS];		/* Where it is going	*/
+	unsigned int mfcc_pkt_cnt;		/* dead */
+	unsigned int mfcc_byte_cnt;		/* dead */
+	unsigned int mfcc_wrong_if;		/* dead */
+	int	     mfcc_expire;		/* dead */
+};
+
 struct mfcctl {
+#define MFCCTL_VIFS 118
 	struct in_addr mfcc_origin;		/* Origin of mcast	*/
 	struct in_addr mfcc_mcastgrp;		/* Group in question	*/
 	vifi_t	mfcc_parent;			/* Where it arrived	*/
-	unsigned char mfcc_ttls[MAXVIFS];	/* Where it is going	*/
-	unsigned int mfcc_pkt_cnt;		/* pkt count for src-grp */
-	unsigned int mfcc_byte_cnt;
-	unsigned int mfcc_wrong_if;
-	int	     mfcc_expire;
+	unsigned char mfcc_ttls[MFCCTL_VIFS];	/* Where it is going 	*/
+	/* Don't put anything here as mfcc_ttls should grow into here */
 };
 
 /* 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 0b9d03c..516289b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1012,10 +1012,18 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		 */
 	case MRT_ADD_MFC:
 	case MRT_DEL_MFC:
-		if (optlen != sizeof(mfc))
+
+		if (optlen == sizeof(struct mfcctl_old)) {
+			if (copy_from_user(&mfc, optval, sizeof(struct mfcctl_old)))
+				return -EFAULT;
+			memset(mfc.mfcc_ttls + MFCCTL_OLD_VIFS, 255,
+			       MFCCTL_VIFS - MFCCTL_OLD_VIFS);
+		} else if (optlen >= (sizeof(struct mfcctl))) {
+			if (copy_from_user(&mfc, optval, sizeof(mfc)))
+				return -EFAULT;
+		} else
 			return -EINVAL;
-		if (copy_from_user(&mfc, optval, sizeof(mfc)))
-			return -EFAULT;
+
 		rtnl_lock();
 		if (optname == MRT_DEL_MFC)
 			ret = ipmr_mfc_delete(net, &mfc);
@@ -2032,6 +2040,9 @@ int __init ip_mr_init(void)
 {
 	int err;
 
+	BUILD_BUG_ON(MFCCTL_VIFS < MAXVIFS);
+	BUILD_BUG_ON(sizeof(struct mfcctl) <= sizeof(struct mfcctl_old));
+
 	mrt_cachep = kmem_cache_create("ip_mrt_cache",
 				       sizeof(struct mfc_cache),
 				       0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-- 
1.6.5.2.143.g8cc62

