From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Allow IP_MULTICAST_IF to set index to L3 slave
Date: Thu, 29 Dec 2016 15:39:37 -0800
Message-ID: <1483054777-11306-1-git-send-email-dsa@cumulusnetworks.com>
Cc: darwin.dingel@alliedtelesis.co.nz,
        Mark.Tomlinson@alliedtelesis.co.nz,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34647 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753039AbcL2Xjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 18:39:43 -0500
Received: by mail-pg0-f51.google.com with SMTP id y62so118971394pgy.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 15:39:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IP_MULTICAST_IF fails if sk_bound_dev_if is already set and the new index
does not match it. e.g.,

    ntpd[15381]: setsockopt IP_MULTICAST_IF 192.168.1.23 fails: Invalid argument

Relax the check in setsockopt to allow setting mc_index to an L3 slave if
sk_bound_dev_if points to an L3 master.

Make a similar change for IPv6. In this case change the device lookup to
take the rcu_read_lock avoiding a refcnt. The rcu lock is also needed for
the lookup of a potential L3 master device.

This really only silences a setsockopt failure since uses of mc_index are
secondary to sk_bound_dev_if if it is set. In both cases, if either index
is an L3 slave or master, lookups are directed to the same FIB table so
relaxing the check at setsockopt time causes no harm.

Patch is based on a suggested change by Darwin for a problem noted in
their code base.

Suggested-by: Darwin Dingel <darwin.dingel@alliedtelesis.co.nz>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/ip_sockglue.c   |  7 ++++++-
 net/ipv6/ipv6_sockglue.c | 16 ++++++++++++----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8b13881ed064..72071a9a348d 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -843,6 +843,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	{
 		struct ip_mreqn mreq;
 		struct net_device *dev = NULL;
+		int midx;
 
 		if (sk->sk_type == SOCK_STREAM)
 			goto e_inval;
@@ -887,11 +888,15 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		err = -EADDRNOTAVAIL;
 		if (!dev)
 			break;
+
+		midx = l3mdev_master_ifindex(dev);
+
 		dev_put(dev);
 
 		err = -EINVAL;
 		if (sk->sk_bound_dev_if &&
-		    mreq.imr_ifindex != sk->sk_bound_dev_if)
+		    mreq.imr_ifindex != sk->sk_bound_dev_if &&
+		    (!midx || midx != sk->sk_bound_dev_if))
 			break;
 
 		inet->mc_index = mreq.imr_ifindex;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 3ba530373560..bdf1227fd433 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -595,16 +595,24 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 
 		if (val) {
 			struct net_device *dev;
+			int midx;
 
-			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
-				goto e_inval;
+			rcu_read_lock();
 
-			dev = dev_get_by_index(net, val);
+			dev = dev_get_by_index_rcu(net, val);
 			if (!dev) {
+				rcu_read_unlock();
 				retv = -ENODEV;
 				break;
 			}
-			dev_put(dev);
+			midx = l3mdev_master_ifindex_rcu(dev);
+
+			rcu_read_unlock();
+
+			if (sk->sk_bound_dev_if &&
+			    sk->sk_bound_dev_if != val &&
+			    (!midx || midx != sk->sk_bound_dev_if))
+				goto e_inval;
 		}
 		np->mcast_oif = val;
 		retv = 0;
-- 
2.1.4
