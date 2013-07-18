From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 2/2] vxlan: fix igmp races
Date: Thu, 18 Jul 2013 08:40:15 -0700
Message-ID: <20130718084015.507bd03c@nehalam.linuxnetplumber.net>
References: <20130718083826.58ae2b77@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:48198 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758607Ab3GRPqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 11:46:35 -0400
Received: by mail-pb0-f51.google.com with SMTP id um15so3305586pbc.38
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 08:46:34 -0700 (PDT)
In-Reply-To: <20130718083826.58ae2b77@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two race conditions in existing code for doing IGMP
management in workqueue in vxlan. First, the vxlan_group_used
function checks the list of vxlan's without any protection, and
it is possible for open followed by close to occur before the
igmp work queue runs.

To solve these move the check into vxlan_open/stop so it is
protected by RTNL. And split into two work structures so that
there is no racy reference to underlying device state.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/vxlan.c	2013-07-17 17:03:05.136038741 -0700
+++ b/drivers/net/vxlan.c	2013-07-17 17:31:33.822426541 -0700
@@ -136,7 +136,8 @@ struct vxlan_dev {
 	u32		  flags;	/* VXLAN_F_* below */
 
 	struct work_struct sock_work;
-	struct work_struct igmp_work;
+	struct work_struct igmp_join;
+	struct work_struct igmp_leave;
 
 	unsigned long	  age_interval;
 	struct timer_list age_timer;
@@ -736,7 +737,6 @@ static bool vxlan_snoop(struct net_devic
 	return false;
 }
 
-
 /* See if multicast group is already in use by other ID */
 static bool vxlan_group_used(struct vxlan_net *vn, __be32 remote_ip)
 {
@@ -770,12 +770,13 @@ static void vxlan_sock_release(struct vx
 	queue_work(vxlan_wq, &vs->del_work);
 }
 
-/* Callback to update multicast group membership.
- * Scheduled when vxlan goes up/down.
+/* Callback to update multicast group membership when first VNI on
+ * multicast asddress is brought up
+ * Done as workqueue because ip_mc_join_group acquires RTNL.
  */
-static void vxlan_igmp_work(struct work_struct *work)
+static void vxlan_igmp_join(struct work_struct *work)
 {
-	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_work);
+	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_join);
 	struct vxlan_net *vn = net_generic(dev_net(vxlan->dev), vxlan_net_id);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 	struct sock *sk = vs->sock->sk;
@@ -785,10 +786,27 @@ static void vxlan_igmp_work(struct work_
 	};
 
 	lock_sock(sk);
-	if (vxlan_group_used(vn, vxlan->default_dst.remote_ip))
-		ip_mc_join_group(sk, &mreq);
-	else
-		ip_mc_leave_group(sk, &mreq);
+	ip_mc_join_group(sk, &mreq);
+	release_sock(sk);
+
+	vxlan_sock_release(vn, vs);
+	dev_put(vxlan->dev);
+}
+
+/* Inverse of vxlan_igmp_join when last VNI is brought down */
+static void vxlan_igmp_leave(struct work_struct *work)
+{
+	struct vxlan_dev *vxlan = container_of(work, struct vxlan_dev, igmp_leave);
+	struct vxlan_net *vn = net_generic(dev_net(vxlan->dev), vxlan_net_id);
+	struct vxlan_sock *vs = vxlan->vn_sock;
+	struct sock *sk = vs->sock->sk;
+	struct ip_mreqn mreq = {
+		.imr_multiaddr.s_addr	= vxlan->default_dst.remote_ip,
+		.imr_ifindex		= vxlan->default_dst.remote_ifindex,
+	};
+
+	lock_sock(sk);
+	ip_mc_leave_group(sk, &mreq);
 	release_sock(sk);
 
 	vxlan_sock_release(vn, vs);
@@ -1359,6 +1377,7 @@ static void vxlan_uninit(struct net_devi
 /* Start ageing timer and join group when device is brought up */
 static int vxlan_open(struct net_device *dev)
 {
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 
@@ -1366,10 +1385,11 @@ static int vxlan_open(struct net_device
 	if (!vs)
 		return -ENOTCONN;
 
-	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
+	if (IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip)) &&
+	    ! vxlan_group_used(vn, vxlan->default_dst.remote_ip)) {
 		vxlan_sock_hold(vs);
 		dev_hold(dev);
-		queue_work(vxlan_wq, &vxlan->igmp_work);
+		queue_work(vxlan_wq, &vxlan->igmp_join);
 	}
 
 	if (vxlan->age_interval)
@@ -1400,13 +1420,15 @@ static void vxlan_flush(struct vxlan_dev
 /* Cleanup timer and forwarding table on shutdown */
 static int vxlan_stop(struct net_device *dev)
 {
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_sock *vs = vxlan->vn_sock;
 
-	if (vs && IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip))) {
+	if (vs && IN_MULTICAST(ntohl(vxlan->default_dst.remote_ip)) &&
+	    ! vxlan_group_used(vn, vxlan->default_dst.remote_ip)) {
 		vxlan_sock_hold(vs);
 		dev_hold(dev);
-		queue_work(vxlan_wq, &vxlan->igmp_work);
+		queue_work(vxlan_wq, &vxlan->igmp_leave);
 	}
 
 	del_timer_sync(&vxlan->age_timer);
@@ -1471,7 +1493,8 @@ static void vxlan_setup(struct net_devic
 
 	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
-	INIT_WORK(&vxlan->igmp_work, vxlan_igmp_work);
+	INIT_WORK(&vxlan->igmp_join, vxlan_igmp_join);
+	INIT_WORK(&vxlan->igmp_leave, vxlan_igmp_leave);
 	INIT_WORK(&vxlan->sock_work, vxlan_sock_work);
 
 	init_timer_deferrable(&vxlan->age_timer);
