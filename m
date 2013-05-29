From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next] vxlan: do real refcnt for vn_sock
Date: Tue, 28 May 2013 21:41:42 -0700
Message-ID: <20130528214142.4e41db6f@nehalam.linuxnetplumber.net>
References: <1369739242-5944-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:51580 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab3E2Elr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 00:41:47 -0400
Received: by mail-pd0-f175.google.com with SMTP id 6so8108163pdd.20
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 21:41:47 -0700 (PDT)
In-Reply-To: <1369739242-5944-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Why not just fix the requirement to drop rtnl when calling igmp.
The code comes out cleaner and safer as well.

The follow COMPILE TESTED ONLY is a starting point...

--- a/drivers/net/vxlan.c	2013-05-20 10:24:19.624427346 -0700
+++ b/drivers/net/vxlan.c	2013-05-28 21:39:57.502351889 -0700
@@ -657,20 +657,12 @@ static int vxlan_join_group(struct net_d
 		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
 		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
 	};
-	int err;
 
 	/* Already a member of group */
 	if (vxlan_group_used(vn, vxlan))
 		return 0;
 
-	/* Need to drop RTNL to call multicast join */
-	rtnl_unlock();
-	lock_sock(sk);
-	err = ip_mc_join_group(sk, &mreq);
-	release_sock(sk);
-	rtnl_lock();
-
-	return err;
+	return _ip_mc_join_group(sk, &mreq);
 }
 
 
@@ -679,7 +671,6 @@ static int vxlan_leave_group(struct net_
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	int err = 0;
 	struct sock *sk = vxlan->vn_sock->sock->sk;
 	struct ip_mreqn mreq = {
 		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
@@ -690,14 +681,7 @@ static int vxlan_leave_group(struct net_
 	if (vxlan_group_used(vn, vxlan))
 		return 0;
 
-	/* Need to drop RTNL to call multicast leave */
-	rtnl_unlock();
-	lock_sock(sk);
-	err = ip_mc_leave_group(sk, &mreq);
-	release_sock(sk);
-	rtnl_lock();
-
-	return err;
+	return _ip_mc_leave_group(sk, &mreq);
 }
 
 /* Callback from net/ipv4/udp.c to receive packets */
@@ -1244,6 +1228,7 @@ static int vxlan_open(struct net_device
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	int err;
 
+	dev_hold(dev);
 	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
 		err = vxlan_join_group(dev);
 		if (err)
@@ -1252,6 +1237,7 @@ static int vxlan_open(struct net_device
 
 	if (vxlan->age_interval)
 		mod_timer(&vxlan->age_timer, jiffies + FDB_AGE_INTERVAL);
+	dev_put(dev);
 
 	return 0;
 }
--- a/include/linux/igmp.h	2013-05-11 15:58:53.692325370 -0700
+++ b/include/linux/igmp.h	2013-05-28 21:37:40.560328674 -0700
@@ -109,7 +109,9 @@ struct ip_mc_list {
 
 extern int ip_check_mc_rcu(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto);
 extern int igmp_rcv(struct sk_buff *);
+extern int _ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
 extern int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
+extern int _ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
 extern int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
 extern void ip_mc_drop_socket(struct sock *sk);
 extern int ip_mc_source(int add, int omode, struct sock *sk,
--- a/net/ipv4/igmp.c	2013-05-11 15:58:53.992318551 -0700
+++ b/net/ipv4/igmp.c	2013-05-28 21:39:43.302554701 -0700
@@ -1781,48 +1781,36 @@ static void ip_mc_clear_src(struct ip_mc
 	pmc->sfcount[MCAST_EXCLUDE] = 1;
 }
 
-
-/*
- * Join a multicast group
- */
-int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
+int _ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
 {
-	int err;
 	__be32 addr = imr->imr_multiaddr.s_addr;
-	struct ip_mc_socklist *iml = NULL, *i;
+	struct ip_mc_socklist *iml, *i;
 	struct in_device *in_dev;
 	struct inet_sock *inet = inet_sk(sk);
 	struct net *net = sock_net(sk);
 	int ifindex;
 	int count = 0;
 
-	if (!ipv4_is_multicast(addr))
-		return -EINVAL;
-
-	rtnl_lock();
+	ASSERT_RTNL();
 
 	in_dev = ip_mc_find_dev(net, imr);
+	if (!in_dev)
+		return -ENODEV;
 
-	if (!in_dev) {
-		iml = NULL;
-		err = -ENODEV;
-		goto done;
-	}
-
-	err = -EADDRINUSE;
 	ifindex = imr->imr_ifindex;
 	for_each_pmc_rtnl(inet, i) {
 		if (i->multi.imr_multiaddr.s_addr == addr &&
 		    i->multi.imr_ifindex == ifindex)
-			goto done;
+			return -EADDRINUSE;
 		count++;
 	}
-	err = -ENOBUFS;
+
 	if (count >= sysctl_igmp_max_memberships)
-		goto done;
+		return -ENOBUFS;
+
 	iml = sock_kmalloc(sk, sizeof(*iml), GFP_KERNEL);
 	if (iml == NULL)
-		goto done;
+		return -ENOMEM;
 
 	memcpy(&iml->multi, imr, sizeof(*imr));
 	iml->next_rcu = inet->mc_list;
@@ -1830,8 +1818,24 @@ int ip_mc_join_group(struct sock *sk , s
 	iml->sfmode = MCAST_EXCLUDE;
 	rcu_assign_pointer(inet->mc_list, iml);
 	ip_mc_inc_group(in_dev, addr);
-	err = 0;
-done:
+
+	return 0;
+}
+EXPORT_SYMBOL(_ip_mc_join_group);
+
+/*
+ * Join a multicast group
+ */
+int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
+{
+	int err;
+	__be32 addr = imr->imr_multiaddr.s_addr;
+
+	if (!ipv4_is_multicast(addr))
+		return -EINVAL;
+
+	rtnl_lock();
+	err = _ip_mc_join_group(sk, imr);
 	rtnl_unlock();
 	return err;
 }
@@ -1857,11 +1861,7 @@ static int ip_mc_leave_src(struct sock *
 	return err;
 }
 
-/*
- *	Ask a socket to leave a group.
- */
-
-int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
+int _ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_mc_socklist *iml;
@@ -1870,9 +1870,9 @@ int ip_mc_leave_group(struct sock *sk, s
 	struct net *net = sock_net(sk);
 	__be32 group = imr->imr_multiaddr.s_addr;
 	u32 ifindex;
-	int ret = -EADDRNOTAVAIL;
 
-	rtnl_lock();
+	ASSERT_RTNL();
+
 	in_dev = ip_mc_find_dev(net, imr);
 	ifindex = imr->imr_ifindex;
 	for (imlp = &inet->mc_list;
@@ -1880,6 +1880,7 @@ int ip_mc_leave_group(struct sock *sk, s
 	     imlp = &iml->next_rcu) {
 		if (iml->multi.imr_multiaddr.s_addr != group)
 			continue;
+
 		if (ifindex) {
 			if (iml->multi.imr_ifindex != ifindex)
 				continue;
@@ -1887,20 +1888,32 @@ int ip_mc_leave_group(struct sock *sk, s
 				iml->multi.imr_address.s_addr)
 			continue;
 
-		(void) ip_mc_leave_src(sk, iml, in_dev);
+		ip_mc_leave_src(sk, iml, in_dev);
 
 		*imlp = iml->next_rcu;
 
 		if (in_dev)
 			ip_mc_dec_group(in_dev, group);
-		rtnl_unlock();
+
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
 		kfree_rcu(iml, rcu);
 		return 0;
 	}
-	if (!in_dev)
-		ret = -ENODEV;
+
+	return !in_dev ? -ENODEV : -EADDRNOTAVAIL;
+}
+EXPORT_SYMBOL(_ip_mc_leave_group);
+
+/*
+ *	Ask a socket to leave a group.
+ */
+int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
+{
+	int ret;
+
+	rtnl_lock();
+	ret = _ip_mc_leave_group(sk, imr);
 	rtnl_unlock();
 	return ret;
 }
