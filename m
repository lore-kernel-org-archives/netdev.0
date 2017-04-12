From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv4: fix a deadlock in ip_ra_control
Date: Wed, 12 Apr 2017 12:32:13 -0700
Message-ID: <1492025533-23084-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, andreyknvl@google.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33285 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752304AbdDLTc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 15:32:29 -0400
Received: by mail-pf0-f194.google.com with SMTP id c198so6849855pfc.0
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 12:32:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit 87e9f0315952
("ipv4: fix a potential deadlock in mcast getsockopt() path"),
there is a deadlock scenario for IP_ROUTER_ALERT too:

       CPU0                    CPU1
       ----                    ----
  lock(rtnl_mutex);
                               lock(sk_lock-AF_INET);
                               lock(rtnl_mutex);
  lock(sk_lock-AF_INET);

Fix this by always locking RTNL first on all setsockopt() paths.

Note, after this patch ip_ra_lock is no longer needed either.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/ip_sockglue.c |  1 +
 net/ipv4/ipmr.c        | 11 ++---------
 net/ipv4/raw.c         |  2 ++
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index ebd953b..bda318a 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -591,6 +591,7 @@ static bool setsockopt_needs_rtnl(int optname)
 	case MCAST_LEAVE_GROUP:
 	case MCAST_LEAVE_SOURCE_GROUP:
 	case MCAST_UNBLOCK_SOURCE:
+	case IP_ROUTER_ALERT:
 		return true;
 	}
 	return false;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c0317c9..b036e85 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1278,7 +1278,7 @@ static void mrtsock_destruct(struct sock *sk)
 	struct net *net = sock_net(sk);
 	struct mr_table *mrt;
 
-	rtnl_lock();
+	ASSERT_RTNL();
 	ipmr_for_each_table(mrt, net) {
 		if (sk == rtnl_dereference(mrt->mroute_sk)) {
 			IPV4_DEVCONF_ALL(net, MC_FORWARDING)--;
@@ -1289,7 +1289,6 @@ static void mrtsock_destruct(struct sock *sk)
 			mroute_clean_tables(mrt, false);
 		}
 	}
-	rtnl_unlock();
 }
 
 /* Socket options and virtual interface manipulation. The whole
@@ -1353,13 +1352,8 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 		if (sk != rcu_access_pointer(mrt->mroute_sk)) {
 			ret = -EACCES;
 		} else {
-			/* We need to unlock here because mrtsock_destruct takes
-			 * care of rtnl itself and we can't change that due to
-			 * the IP_ROUTER_ALERT setsockopt which runs without it.
-			 */
-			rtnl_unlock();
 			ret = ip_ra_control(sk, 0, NULL);
-			goto out;
+			goto out_unlock;
 		}
 		break;
 	case MRT_ADD_VIF:
@@ -1470,7 +1464,6 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 	}
 out_unlock:
 	rtnl_unlock();
-out:
 	return ret;
 }
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 8119e1f..9d94397 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -682,7 +682,9 @@ static void raw_close(struct sock *sk, long timeout)
 	/*
 	 * Raw sockets may have direct kernel references. Kill them.
 	 */
+	rtnl_lock();
 	ip_ra_control(sk, 0, NULL);
+	rtnl_unlock();
 
 	sk_common_release(sk);
 }
-- 
2.5.5
