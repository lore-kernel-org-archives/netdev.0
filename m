From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 8/9] net: ipmr: rearrange and cleanup setsockopt
Date: Sat, 21 Nov 2015 14:01:41 +0100
Message-ID: <1448110902-28793-9-git-send-email-razor@blackwall.org>
References: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38370 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759929AbbKUNBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 08:01:54 -0500
Received: by wmec201 with SMTP id c201so52520407wme.1
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 05:01:53 -0800 (PST)
In-Reply-To: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Take rtnl in the beginning unconditionally as most options already need
it (one exception - MRT_DONE, see the comment inside), make the
lock/unlock places central and move out the switch() local variables.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 191 +++++++++++++++++++++++++++++++-------------------------
 1 file changed, 107 insertions(+), 84 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 2c7fa584a274..f2ea97fbb8a8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1276,38 +1276,45 @@ static void mrtsock_destruct(struct sock *sk)
  * MOSPF/PIM router set up we can clean this up.
  */
 
-int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsigned int optlen)
+int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
+			 unsigned int optlen)
 {
-	int ret, parent = 0;
-	struct vifctl vif;
-	struct mfcctl mfc;
 	struct net *net = sock_net(sk);
+	int val, ret = 0, parent = 0;
 	struct mr_table *mrt;
+	struct vifctl vif;
+	struct mfcctl mfc;
+	u32 uval;
 
+	/* There's one exception to the lock - MRT_DONE which needs to unlock */
+	rtnl_lock();
 	if (sk->sk_type != SOCK_RAW ||
-	    inet_sk(sk)->inet_num != IPPROTO_IGMP)
-		return -EOPNOTSUPP;
+	    inet_sk(sk)->inet_num != IPPROTO_IGMP) {
+		ret = -EOPNOTSUPP;
+		goto out_unlock;
+	}
 
 	mrt = ipmr_get_table(net, raw_sk(sk)->ipmr_table ? : RT_TABLE_DEFAULT);
-	if (!mrt)
-		return -ENOENT;
-
+	if (!mrt) {
+		ret = -ENOENT;
+		goto out_unlock;
+	}
 	if (optname != MRT_INIT) {
 		if (sk != rcu_access_pointer(mrt->mroute_sk) &&
-		    !ns_capable(net->user_ns, CAP_NET_ADMIN))
-			return -EACCES;
+		    !ns_capable(net->user_ns, CAP_NET_ADMIN)) {
+			ret = -EACCES;
+			goto out_unlock;
+		}
 	}
 
 	switch (optname) {
 	case MRT_INIT:
 		if (optlen != sizeof(int))
-			return -EINVAL;
-
-		rtnl_lock();
-		if (rtnl_dereference(mrt->mroute_sk)) {
-			rtnl_unlock();
-			return -EADDRINUSE;
-		}
+			ret = -EINVAL;
+		if (rtnl_dereference(mrt->mroute_sk))
+			ret = -EADDRINUSE;
+		if (ret)
+			break;
 
 		ret = ip_ra_control(sk, 1, mrtsock_destruct);
 		if (ret == 0) {
@@ -1317,30 +1324,41 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 						    NETCONFA_IFINDEX_ALL,
 						    net->ipv4.devconf_all);
 		}
-		rtnl_unlock();
-		return ret;
+		break;
 	case MRT_DONE:
-		if (sk != rcu_access_pointer(mrt->mroute_sk))
-			return -EACCES;
-		return ip_ra_control(sk, 0, NULL);
+		if (sk != rcu_access_pointer(mrt->mroute_sk)) {
+			ret = -EACCES;
+		} else {
+			/* We need to unlock here because mrtsock_destruct takes
+			 * care of rtnl itself and we can't change that due to
+			 * the IP_ROUTER_ALERT setsockopt which runs without it.
+			 */
+			rtnl_unlock();
+			ret = ip_ra_control(sk, 0, NULL);
+			goto out;
+		}
+		break;
 	case MRT_ADD_VIF:
 	case MRT_DEL_VIF:
-		if (optlen != sizeof(vif))
-			return -EINVAL;
-		if (copy_from_user(&vif, optval, sizeof(vif)))
-			return -EFAULT;
-		if (vif.vifc_vifi >= MAXVIFS)
-			return -ENFILE;
-		rtnl_lock();
+		if (optlen != sizeof(vif)) {
+			ret = -EINVAL;
+			break;
+		}
+		if (copy_from_user(&vif, optval, sizeof(vif))) {
+			ret = -EFAULT;
+			break;
+		}
+		if (vif.vifc_vifi >= MAXVIFS) {
+			ret = -ENFILE;
+			break;
+		}
 		if (optname == MRT_ADD_VIF) {
 			ret = vif_add(net, mrt, &vif,
 				      sk == rtnl_dereference(mrt->mroute_sk));
 		} else {
 			ret = vif_delete(mrt, vif.vifc_vifi, 0, NULL);
 		}
-		rtnl_unlock();
-		return ret;
-
+		break;
 	/* Manipulate the forwarding caches. These live
 	 * in a sort of kernel/user symbiosis.
 	 */
@@ -1349,82 +1367,87 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		parent = -1;
 	case MRT_ADD_MFC_PROXY:
 	case MRT_DEL_MFC_PROXY:
-		if (optlen != sizeof(mfc))
-			return -EINVAL;
-		if (copy_from_user(&mfc, optval, sizeof(mfc)))
-			return -EFAULT;
+		if (optlen != sizeof(mfc)) {
+			ret = -EINVAL;
+			break;
+		}
+		if (copy_from_user(&mfc, optval, sizeof(mfc))) {
+			ret = -EFAULT;
+			break;
+		}
 		if (parent == 0)
 			parent = mfc.mfcc_parent;
-		rtnl_lock();
 		if (optname == MRT_DEL_MFC || optname == MRT_DEL_MFC_PROXY)
 			ret = ipmr_mfc_delete(mrt, &mfc, parent);
 		else
 			ret = ipmr_mfc_add(net, mrt, &mfc,
 					   sk == rtnl_dereference(mrt->mroute_sk),
 					   parent);
-		rtnl_unlock();
-		return ret;
+		break;
 	/* Control PIM assert. */
 	case MRT_ASSERT:
-	{
-		int v;
-		if (optlen != sizeof(v))
-			return -EINVAL;
-		if (get_user(v, (int __user *)optval))
-			return -EFAULT;
-		mrt->mroute_do_assert = v;
-		return 0;
-	}
+		if (optlen != sizeof(val)) {
+			ret = -EINVAL;
+			break;
+		}
+		if (get_user(val, (int __user *)optval)) {
+			ret = -EFAULT;
+			break;
+		}
+		mrt->mroute_do_assert = val;
+		break;
 	case MRT_PIM:
-	{
-		int v;
-
-		if (!pimsm_enabled())
-			return -ENOPROTOOPT;
-		if (optlen != sizeof(v))
-			return -EINVAL;
-		if (get_user(v, (int __user *)optval))
-			return -EFAULT;
-		v = !!v;
+		if (!pimsm_enabled()) {
+			ret = -ENOPROTOOPT;
+			break;
+		}
+		if (optlen != sizeof(val)) {
+			ret = -EINVAL;
+			break;
+		}
+		if (get_user(val, (int __user *)optval)) {
+			ret = -EFAULT;
+			break;
+		}
 
-		rtnl_lock();
-		ret = 0;
-		if (v != mrt->mroute_do_pim) {
-			mrt->mroute_do_pim = v;
-			mrt->mroute_do_assert = v;
+		val = !!val;
+		if (val != mrt->mroute_do_pim) {
+			mrt->mroute_do_pim = val;
+			mrt->mroute_do_assert = val;
 		}
-		rtnl_unlock();
-		return ret;
-	}
+		break;
 	case MRT_TABLE:
-	{
-		u32 v;
-
-		if (!IS_BUILTIN(CONFIG_IP_MROUTE_MULTIPLE_TABLES))
-			return -ENOPROTOOPT;
-		if (optlen != sizeof(u32))
-			return -EINVAL;
-		if (get_user(v, (u32 __user *)optval))
-			return -EFAULT;
+		if (!IS_BUILTIN(CONFIG_IP_MROUTE_MULTIPLE_TABLES)) {
+			ret = -ENOPROTOOPT;
+			break;
+		}
+		if (optlen != sizeof(uval)) {
+			ret = -EINVAL;
+			break;
+		}
+		if (get_user(uval, (u32 __user *)optval)) {
+			ret = -EFAULT;
+			break;
+		}
 
-		rtnl_lock();
-		ret = 0;
 		if (sk == rtnl_dereference(mrt->mroute_sk)) {
 			ret = -EBUSY;
 		} else {
-			mrt = ipmr_new_table(net, v);
+			mrt = ipmr_new_table(net, uval);
 			if (IS_ERR(mrt))
 				ret = PTR_ERR(mrt);
 			else
-				raw_sk(sk)->ipmr_table = v;
+				raw_sk(sk)->ipmr_table = uval;
 		}
-		rtnl_unlock();
-		return ret;
-	}
+		break;
 	/* Spurious command, or MRT_VERSION which you cannot set. */
 	default:
-		return -ENOPROTOOPT;
+		ret = -ENOPROTOOPT;
 	}
+out_unlock:
+	rtnl_unlock();
+out:
+	return ret;
 }
 
 /* Getsock opt support for the multicast routing system. */
-- 
2.4.3
