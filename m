From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT][PATCH] Convert bluetooth to dynamic net_device.
Date: Mon, 11 Aug 2003 11:53:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030811115334.4bd4521a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Maxim Krasnyansky <maxk@qualcomm.com>,
   "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert Bluetooth networking to dynamic allocation of network devices.
This will allow fixing races with rmmod and sysfs access.
The patch is against 2.6.0-test3 and correctly loads/unloads but
since I don't have bluetooth hardware can't test it more.

Since the initialization code changed slightly, I would like to have
someone do a basic sanity test before it is merged.


diff -Nru a/net/bluetooth/bnep/bnep.h b/net/bluetooth/bnep/bnep.h
--- a/net/bluetooth/bnep/bnep.h	Mon Aug 11 11:42:08 2003
+++ b/net/bluetooth/bnep/bnep.h	Mon Aug 11 11:42:08 2003
@@ -168,11 +168,11 @@
 	u64    mc_filter;
 	
 	struct socket    *sock;
-	struct net_device dev;
+	struct net_device *dev;
 	struct net_device_stats stats;
 };
 
-int bnep_net_init(struct net_device *dev);
+void bnep_net_setup(struct net_device *dev);
 int bnep_sock_init(void);
 int bnep_sock_cleanup(void);
 
diff -Nru a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
--- a/net/bluetooth/bnep/core.c	Mon Aug 11 11:42:08 2003
+++ b/net/bluetooth/bnep/core.c	Mon Aug 11 11:42:08 2003
@@ -180,7 +180,7 @@
 		s->mc_filter = 0;
 
 		/* Always send broadcast */
-		set_bit(bnep_mc_hash(s->dev.broadcast), (ulong *) &s->mc_filter);
+		set_bit(bnep_mc_hash(s->dev->broadcast), (ulong *) &s->mc_filter);
 
 		/* Add address ranges to the multicast hash */
 		for (; n > 0; n--) {
@@ -293,7 +293,7 @@
 
 static inline int bnep_rx_frame(struct bnep_session *s, struct sk_buff *skb)
 {
-	struct net_device *dev = &s->dev;
+	struct net_device *dev = s->dev;
 	struct sk_buff *nskb;
 	u8 type;
 
@@ -451,7 +451,7 @@
 static int bnep_session(void *arg)
 {
 	struct bnep_session *s = arg;
-	struct net_device *dev = &s->dev;
+	struct net_device *dev = s->dev;
 	struct sock *sk = s->sock->sk;
 	struct sk_buff *skb;
 	wait_queue_t wait;
@@ -501,7 +501,7 @@
 	__bnep_unlink_session(s);
 
 	up_write(&bnep_session_sem);
-	kfree(s);
+	kfree(dev);
 	return 0;
 }
 
@@ -517,10 +517,13 @@
 	baswap((void *) dst, &bt_sk(sock->sk)->dst);
 	baswap((void *) src, &bt_sk(sock->sk)->src);
 
-	s = kmalloc(sizeof(struct bnep_session), GFP_KERNEL);
-	if (!s) 
-		return -ENOMEM;
-	memset(s, 0, sizeof(struct bnep_session));
+	/* session struct allocated as private part of net_device */
+	dev = alloc_netdev(sizeof(struct bnep_session),
+			   (*req->device) ? req->device : "bnep%d",
+			   bnep_net_setup);
+	if (!dev) 
+		return ENOMEM;
+
 
 	down_write(&bnep_session_sem);
 
@@ -530,20 +533,15 @@
 		goto failed;
 	}
 
-	dev = &s->dev;
-	
-	if (*req->device)
-		strcpy(dev->name, req->device);
-	else
-		strcpy(dev->name, "bnep%d");
+	s = dev->priv;
 
-	memset(dev->broadcast, 0xff, ETH_ALEN);
-	
 	/* This is rx header therefore addresses are swapped.
 	 * ie eh.h_dest is our local address. */
 	memcpy(s->eh.h_dest,   &src, ETH_ALEN);
 	memcpy(s->eh.h_source, &dst, ETH_ALEN);
+	memcpy(dev->dev_addr, s->eh.h_dest, ETH_ALEN);
 
+	s->dev = dev;
 	s->sock  = sock;
 	s->role  = req->role;
 	s->state = BT_CONNECTED;
@@ -569,8 +567,6 @@
 	s->proto_filter[2].end   = htons(0x86DD);
 #endif
 	
-	dev->init = bnep_net_init;
-	dev->priv = s;
 	err = register_netdev(dev);
 	if (err) {
 		goto failed;
@@ -592,7 +588,7 @@
 
 failed:
 	up_write(&bnep_session_sem);
-	kfree(s);
+	kfree(dev);
 	return err;
 }
 
@@ -624,7 +620,7 @@
 static void __bnep_copy_ci(struct bnep_conninfo *ci, struct bnep_session *s)
 {
 	memcpy(ci->dst, s->eh.h_source, ETH_ALEN);
-	strcpy(ci->device, s->dev.name);
+	strcpy(ci->device, s->dev->name);
 	ci->flags = s->flags;
 	ci->state = s->state;
 	ci->role  = s->role;
diff -Nru a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
--- a/net/bluetooth/bnep/netdev.c	Mon Aug 11 11:42:08 2003
+++ b/net/bluetooth/bnep/netdev.c	Mon Aug 11 11:42:08 2003
@@ -226,11 +226,10 @@
 	return 0;
 }
 
-int bnep_net_init(struct net_device *dev)
+void bnep_net_setup(struct net_device *dev)
 {
-	struct bnep_session *s = dev->priv;
 
-	memcpy(dev->dev_addr, s->eh.h_dest, ETH_ALEN);
+	memset(dev->broadcast, 0xff, ETH_ALEN);
 	dev->addr_len = ETH_ALEN;
 
 	ether_setup(dev);
@@ -245,6 +244,4 @@
 
 	dev->watchdog_timeo  = HZ * 2;
 	dev->tx_timeout      = bnep_net_timeout;
-
-	return 0;
 }
