From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH 5, last for now]  net: unlock before return
Date: Fri, 26 Oct 2007 20:32:17 +0200
Message-ID: <472232B1.5090006@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out0.tiscali.nl ([195.241.79.175]:39349 "EHLO
	smtp-out0.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757091AbXJZScU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 14:32:20 -0400
Received: from [82.171.216.234] (helo=[192.168.1.2])
	by smtp-out0.tiscali.nl with esmtp (Tiscali http://www.tiscali.nl)
	id 1IlTyl-0003F5-3O
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 20:32:19 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To David Miller: this was the one you asked to send. I removed the incorrect one
(net/bridge/netfilter/ebtables.c). Note the drivers/net/cris/eth_v10.c, which
you may not yet have reviewed, But I checked, and there was not a similar
comment above the header of the function :)

Roel

--
     unlock before return fixes
     Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index edd6828..5478549 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1476,6 +1476,7 @@ e100_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			e100_set_duplex(dev, autoneg);
 			break;
 		default:
+			spin_unlock(&np->lock);
 			return -EINVAL;
 	}
 	spin_unlock(&np->lock);
diff --git a/net/9p/mux.c b/net/9p/mux.c
index f140147..c9f0805 100644
--- a/net/9p/mux.c
+++ b/net/9p/mux.c
@@ -222,8 +222,10 @@ static int p9_mux_poll_start(struct p9_conn *m)
 	}
 
 	if (i >= ARRAY_SIZE(p9_mux_poll_tasks)) {
-		if (vptlast == NULL)
+		if (vptlast == NULL) {
+			mutex_unlock(&p9_mux_task_lock);
 			return -ENOMEM;
+		}
 
 		P9_DPRINTK(P9_DEBUG_MUX, "put in proc %d\n", i);
 		list_add(&m->mux_list, &vptlast->mux_list);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9be1826..cf18097 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1079,7 +1079,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 						    CTA_TUPLE_MASTER,
 						    u3);
 			if (err < 0)
-				return err;
+				goto out_unlock;
 
 			master_h = __nf_conntrack_find(&master, NULL);
 			if (master_h == NULL) {
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 509defe..859fdc0 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -750,8 +750,10 @@ static int rose_connect(struct socket *sock, struct sockaddr *uaddr, int addr_le
 
 	rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause,
 					 &diagnostic);
-	if (!rose->neighbour)
-		return -ENETUNREACH;
+	if (!rose->neighbour) {
+		err = -ENETUNREACH;
+		goto out_release;
+	}
 
 	rose->lci = rose_new_lci(rose->neighbour);
 	if (!rose->lci) {
