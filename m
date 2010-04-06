From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] ipmr: Fix struct mfcctl to be independent of MAXVIFS.
Date: Tue, 06 Apr 2010 05:16:22 -0700
Message-ID: <m1mxxgbwtl.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Ilia K <mail4ilia@gmail.com>, Tom Goff <thomas.goff@boeing.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42615 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab0DFMQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 08:16:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Right now if you recompile the kernel to support more VIFS users of
the MRT_ADD_VIF and MRT_DEL_VIF will break because the ABI changes.

Correct this by forcing the number of VIFS handled in mfcctl to 32.
Allow for larger MAXVIFS by placing a second array of ttls at the end
of struct mfcctl.

struct mfcctl is insane.  The last 4 fields are dead, and the mfc_ttls
array is only 2 byte aligned, with a 2 byte hole right after it.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/mroute.h |    4 +++-
 net/ipv4/ipmr.c        |   29 +++++++++++++++++++++++------
 2 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index c5f3d53..c5e066c 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -76,15 +76,17 @@ struct vifctl {
  *	Cache manipulation structures for mrouted and PIMd
  */
  
+#define MFCCTL_VIFS 32
 struct mfcctl {
 	struct in_addr mfcc_origin;		/* Origin of mcast	*/
 	struct in_addr mfcc_mcastgrp;		/* Group in question	*/
 	vifi_t	mfcc_parent;			/* Where it arrived	*/
-	unsigned char mfcc_ttls[MAXVIFS];	/* Where it is going	*/
+	unsigned char mfcc_ttls[MFCCTL_VIFS];	/* Where it is going	*/
 	unsigned int mfcc_pkt_cnt;		/* pkt count for src-grp */
 	unsigned int mfcc_byte_cnt;
 	unsigned int mfcc_wrong_if;
 	int	     mfcc_expire;
+	unsigned char mfcc_ttls_extra[];	/* The rest of where it is going */
 };
 
 /* 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 0b9d03c..2120668 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -797,7 +797,8 @@ static int ipmr_mfc_delete(struct net *net, struct mfcctl *mfc)
 	return -ENOENT;
 }
 
-static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
+static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc,
+			unsigned char *ttls, int mrtsock)
 {
 	int line;
 	struct mfc_cache *uc, *c, **cp;
@@ -817,7 +818,7 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	if (c != NULL) {
 		write_lock_bh(&mrt_lock);
 		c->mfc_parent = mfc->mfcc_parent;
-		ipmr_update_thresholds(c, mfc->mfcc_ttls);
+		ipmr_update_thresholds(c, ttls);
 		if (!mrtsock)
 			c->mfc_flags |= MFC_STATIC;
 		write_unlock_bh(&mrt_lock);
@@ -834,7 +835,7 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	c->mfc_origin = mfc->mfcc_origin.s_addr;
 	c->mfc_mcastgrp = mfc->mfcc_mcastgrp.s_addr;
 	c->mfc_parent = mfc->mfcc_parent;
-	ipmr_update_thresholds(c, mfc->mfcc_ttls);
+	ipmr_update_thresholds(c, ttls);
 	if (!mrtsock)
 		c->mfc_flags |= MFC_STATIC;
 
@@ -954,6 +955,8 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 	int ret;
 	struct vifctl vif;
 	struct mfcctl mfc;
+	unsigned char ttls[MAXVIFS];
+	unsigned extra_oifs;
 	struct net *net = sock_net(sk);
 
 	if (optname != MRT_INIT) {
@@ -961,7 +964,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 			return -EACCES;
 	}
 
-	switch (optname) {
+	switch (optname){
 	case MRT_INIT:
 		if (sk->sk_type != SOCK_RAW ||
 		    inet_sk(sk)->inet_num != IPPROTO_IGMP)
@@ -1012,15 +1015,29 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		 */
 	case MRT_ADD_MFC:
 	case MRT_DEL_MFC:
-		if (optlen != sizeof(mfc))
+		/* How many extra interfaces do we have information for? */
+		extra_oifs = optlen - sizeof(mfc);
+		if (extra_oifs > (MAXVIFS - MFCCTL_VIFS))
+			extra_oifs = MAXVIFS - MFCCTL_VIFS;
+
+		if (optlen < sizeof(mfc))
 			return -EINVAL;
 		if (copy_from_user(&mfc, optval, sizeof(mfc)))
 			return -EFAULT;
+
+		memcpy(ttls, mfc.mfcc_ttls, sizeof(mfc.mfcc_ttls));
+		memset(ttls + MFCCTL_VIFS, 255, MAXVIFS - MFCCTL_VIFS);
+		if (copy_from_user(ttls + MFCCTL_VIFS,optval + sizeof(mfc),
+				   extra_oifs))
+			return -EFAULT;
+
+
 		rtnl_lock();
 		if (optname == MRT_DEL_MFC)
 			ret = ipmr_mfc_delete(net, &mfc);
 		else
-			ret = ipmr_mfc_add(net, &mfc, sk == net->ipv4.mroute_sk);
+			ret = ipmr_mfc_add(net, &mfc, ttls,
+					   sk == net->ipv4.mroute_sk);
 		rtnl_unlock();
 		return ret;
 		/*
-- 
1.6.5.2.143.g8cc62

