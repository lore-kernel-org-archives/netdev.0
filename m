From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: Propagate lookup failure in l3mdev_get_saddr to caller
Date: Mon,  4 Jan 2016 09:09:27 -0800
Message-ID: <1451927367-14527-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32866 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbcADRJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 12:09:34 -0500
Received: by mail-pa0-f41.google.com with SMTP id cy9so200009148pac.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 09:09:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commands run in a vrf context are not failing as expected on a route lookup:
    root@kenny:~# ip ro ls table vrf-red
    unreachable default

    root@kenny:~# ping -I vrf-red -c1 -w1 10.100.1.254
    ping: Warning: source address might be selected on device other than vrf-red.
    PING 10.100.1.254 (10.100.1.254) from 0.0.0.0 vrf-red: 56(84) bytes of data.

    --- 10.100.1.254 ping statistics ---
    2 packets transmitted, 0 received, 100% packet loss, time 999ms

Since the vrf table does not have a route for 10.100.1.254 the ping
should have failed. The saddr lookup causes a full VRF table lookup.
Propogating a lookup failure to the user allows the command to fail as
expected:

    root@kenny:~# ping -I vrf-red -c1 -w1 10.100.1.254
    connect: No route to host

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
DaveM: This is needed for 4.4; no backport to 4.3 is needed.

 drivers/net/vrf.c    | 10 +++++++---
 include/net/l3mdev.h | 16 ++++++++++------
 include/net/route.h  |  7 ++++++-
 net/ipv4/raw.c       |  7 +++++--
 net/ipv4/udp.c       |  7 +++++--
 5 files changed, 33 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 56abdf224d35..66addb7a7911 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -742,7 +742,7 @@ static struct rtable *vrf_get_rtable(const struct net_device *dev,
 }
 
 /* called under rcu_read_lock */
-static void vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
+static int vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 {
 	struct fib_result res = { .tclassid = 0 };
 	struct net *net = dev_net(dev);
@@ -750,9 +750,10 @@ static void vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 	u8 flags = fl4->flowi4_flags;
 	u8 scope = fl4->flowi4_scope;
 	u8 tos = RT_FL_TOS(fl4);
+	int rc;
 
 	if (unlikely(!fl4->daddr))
-		return;
+		return 0;
 
 	fl4->flowi4_flags |= FLOWI_FLAG_SKIP_NH_OIF;
 	fl4->flowi4_iif = LOOPBACK_IFINDEX;
@@ -760,7 +761,8 @@ static void vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 	fl4->flowi4_scope = ((tos & RTO_ONLINK) ?
 			     RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
 
-	if (!fib_lookup(net, fl4, &res, 0)) {
+	rc = fib_lookup(net, fl4, &res, 0);
+	if (!rc) {
 		if (res.type == RTN_LOCAL)
 			fl4->saddr = res.fi->fib_prefsrc ? : fl4->daddr;
 		else
@@ -770,6 +772,8 @@ static void vrf_get_saddr(struct net_device *dev, struct flowi4 *fl4)
 	fl4->flowi4_flags = flags;
 	fl4->flowi4_tos = orig_tos;
 	fl4->flowi4_scope = scope;
+
+	return rc;
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 786226f8e77b..5567d46b3cff 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -29,7 +29,7 @@ struct l3mdev_ops {
 	/* IPv4 ops */
 	struct rtable *	(*l3mdev_get_rtable)(const struct net_device *dev,
 					     const struct flowi4 *fl4);
-	void		(*l3mdev_get_saddr)(struct net_device *dev,
+	int		(*l3mdev_get_saddr)(struct net_device *dev,
 					    struct flowi4 *fl4);
 
 	/* IPv6 ops */
@@ -130,10 +130,11 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 	return rc;
 }
 
-static inline void l3mdev_get_saddr(struct net *net, int ifindex,
-				    struct flowi4 *fl4)
+static inline int l3mdev_get_saddr(struct net *net, int ifindex,
+				   struct flowi4 *fl4)
 {
 	struct net_device *dev;
+	int rc = 0;
 
 	if (ifindex) {
 
@@ -142,11 +143,13 @@ static inline void l3mdev_get_saddr(struct net *net, int ifindex,
 		dev = dev_get_by_index_rcu(net, ifindex);
 		if (dev && netif_is_l3_master(dev) &&
 		    dev->l3mdev_ops->l3mdev_get_saddr) {
-			dev->l3mdev_ops->l3mdev_get_saddr(dev, fl4);
+			rc = dev->l3mdev_ops->l3mdev_get_saddr(dev, fl4);
 		}
 
 		rcu_read_unlock();
 	}
+
+	return rc;
 }
 
 static inline struct dst_entry *l3mdev_get_rt6_dst(const struct net_device *dev,
@@ -223,9 +226,10 @@ static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
 	return false;
 }
 
-static inline void l3mdev_get_saddr(struct net *net, int ifindex,
-				    struct flowi4 *fl4)
+static inline int l3mdev_get_saddr(struct net *net, int ifindex,
+				   struct flowi4 *fl4)
 {
+	return 0;
 }
 
 static inline
diff --git a/include/net/route.h b/include/net/route.h
index ee81307863d5..a3b9ef74a389 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -283,7 +283,12 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
 			      sport, dport, sk);
 
 	if (!src && oif) {
-		l3mdev_get_saddr(net, oif, fl4);
+		int rc;
+
+		rc = l3mdev_get_saddr(net, oif, fl4);
+		if (rc < 0)
+			return ERR_PTR(rc);
+
 		src = fl4->saddr;
 	}
 	if (!dst || !src) {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 63e5be0abd86..bc35f1842512 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -601,8 +601,11 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 			    (inet->hdrincl ? FLOWI_FLAG_KNOWN_NH : 0),
 			   daddr, saddr, 0, 0);
 
-	if (!saddr && ipc.oif)
-		l3mdev_get_saddr(net, ipc.oif, &fl4);
+	if (!saddr && ipc.oif) {
+		err = l3mdev_get_saddr(net, ipc.oif, &fl4);
+		if (err < 0)
+			goto done;
+	}
 
 	if (!inet->hdrincl) {
 		rfv.msg = msg;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8841e984f8bf..93eec90fb880 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1026,8 +1026,11 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 				   flow_flags,
 				   faddr, saddr, dport, inet->inet_sport);
 
-		if (!saddr && ipc.oif)
-			l3mdev_get_saddr(net, ipc.oif, fl4);
+		if (!saddr && ipc.oif) {
+			err = l3mdev_get_saddr(net, ipc.oif, fl4);
+			if (err < 0)
+				goto out;
+		}
 
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 		rt = ip_route_output_flow(net, fl4, sk);
-- 
1.9.1
