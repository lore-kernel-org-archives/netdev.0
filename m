From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 6/8] net: implement emergency pools
Date: Fri,  2 Jul 2010 21:20:19 +0200
Message-ID: <1278098421-21296-7-git-send-email-sebastian@breakpoint.cc>
References: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Cc: tglx@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:41207 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757546Ab0GBTUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 15:20:35 -0400
In-Reply-To: <1278098421-21296-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

This patch implements emergency pools which are bound to a specific
network device. They can be activated via the socket interface and used
for a specific socket.
The pools are built on top of rx-recycling. The socket interface allows
to set the number of skbs in the pool and to active the pool.
The size of the skb which are accepted / added to the pool can not be
changed. It is set by the network driver and get altered on MTU change.
This requires to drop the current pool and re-allocate it. If the driver
does not set the skb size, the emergency pools can not be used.
Once the emergency pools are activated all rx-skbs allocation by the
network driver are taken from the pool. tx-skbs are allocated from the
emergency pool only for the relevant socket, i.e. that one which
activated the emergency mode.
Since the socket _and_ the driver can add/remove skbs to/from the pool
the list operations are using now skb_queue_head() and skb_dequeue().
There is patch later in the series which tries to bring the old unlock
behavior back if the emergency pools are not used by the user.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 arch/alpha/include/asm/socket.h   |    4 +
 arch/arm/include/asm/socket.h     |    3 +
 arch/avr32/include/asm/socket.h   |    3 +
 arch/cris/include/asm/socket.h    |    5 +-
 arch/frv/include/asm/socket.h     |    4 +-
 arch/h8300/include/asm/socket.h   |    3 +
 arch/ia64/include/asm/socket.h    |    3 +
 arch/m32r/include/asm/socket.h    |    3 +
 arch/m68k/include/asm/socket.h    |    3 +
 arch/mips/include/asm/socket.h    |    3 +
 arch/mn10300/include/asm/socket.h |    3 +
 arch/parisc/include/asm/socket.h  |    3 +
 arch/powerpc/include/asm/socket.h |    3 +
 arch/s390/include/asm/socket.h    |    3 +
 arch/sparc/include/asm/socket.h   |    3 +
 arch/xtensa/include/asm/socket.h  |    3 +
 include/asm-generic/socket.h      |    4 +
 include/linux/netdevice.h         |   52 +++++++------
 include/linux/skbuff.h            |    1 +
 include/net/sock.h                |    2 +
 net/core/skbuff.c                 |    8 ++
 net/core/sock.c                   |  142 +++++++++++++++++++++++++++++++++++++
 22 files changed, 234 insertions(+), 27 deletions(-)

diff --git a/arch/alpha/include/asm/socket.h b/arch/alpha/include/asm/socket.h
index 06edfef..ea49db3 100644
--- a/arch/alpha/include/asm/socket.h
+++ b/arch/alpha/include/asm/socket.h
@@ -69,6 +69,10 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/arm/include/asm/socket.h b/arch/arm/include/asm/socket.h
index 90ffd04..b827010 100644
--- a/arch/arm/include/asm/socket.h
+++ b/arch/arm/include/asm/socket.h
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/avr32/include/asm/socket.h b/arch/avr32/include/asm/socket.h
index c8d1fae..64a7d45 100644
--- a/arch/avr32/include/asm/socket.h
+++ b/arch/avr32/include/asm/socket.h
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/asm/socket.h b/arch/cris/include/asm/socket.h
index 1a4a619..9b8e7ed 100644
--- a/arch/cris/include/asm/socket.h
+++ b/arch/cris/include/asm/socket.h
@@ -64,6 +64,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #endif /* _ASM_SOCKET_H */
-
-
diff --git a/arch/frv/include/asm/socket.h b/arch/frv/include/asm/socket.h
index a6b2688..15a262f 100644
--- a/arch/frv/include/asm/socket.h
+++ b/arch/frv/include/asm/socket.h
@@ -62,5 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #endif /* _ASM_SOCKET_H */
-
diff --git a/arch/h8300/include/asm/socket.h b/arch/h8300/include/asm/socket.h
index 04c0f45..d46d64e 100644
--- a/arch/h8300/include/asm/socket.h
+++ b/arch/h8300/include/asm/socket.h
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/asm/socket.h b/arch/ia64/include/asm/socket.h
index 51427ea..04983aa 100644
--- a/arch/ia64/include/asm/socket.h
+++ b/arch/ia64/include/asm/socket.h
@@ -71,4 +71,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/asm/socket.h b/arch/m32r/include/asm/socket.h
index 469787c..a0e5431 100644
--- a/arch/m32r/include/asm/socket.h
+++ b/arch/m32r/include/asm/socket.h
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/m68k/include/asm/socket.h b/arch/m68k/include/asm/socket.h
index 9bf49c8..7018ceb 100644
--- a/arch/m68k/include/asm/socket.h
+++ b/arch/m68k/include/asm/socket.h
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/mips/include/asm/socket.h b/arch/mips/include/asm/socket.h
index 9de5190..9f9d93a 100644
--- a/arch/mips/include/asm/socket.h
+++ b/arch/mips/include/asm/socket.h
@@ -82,6 +82,9 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #ifdef __KERNEL__
 
 /** sock_type - Socket types
diff --git a/arch/mn10300/include/asm/socket.h b/arch/mn10300/include/asm/socket.h
index 4e60c42..70476eb 100644
--- a/arch/mn10300/include/asm/socket.h
+++ b/arch/mn10300/include/asm/socket.h
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/asm/socket.h b/arch/parisc/include/asm/socket.h
index 225b7d6..a4706d0 100644
--- a/arch/parisc/include/asm/socket.h
+++ b/arch/parisc/include/asm/socket.h
@@ -61,6 +61,9 @@
 
 #define SO_RXQ_OVFL             0x4021
 
+#define SO_EPOOL_QLEN		0x4022
+#define SO_EPOOL_SIZE		0x4023
+#define SO_EPOOL_MODE		0x4024
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/powerpc/include/asm/socket.h b/arch/powerpc/include/asm/socket.h
index 866f760..dce10f9 100644
--- a/arch/powerpc/include/asm/socket.h
+++ b/arch/powerpc/include/asm/socket.h
@@ -69,4 +69,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN           41
+#define SO_EPOOL_SIZE           42
+#define SO_EPOOL_MODE           43
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/asm/socket.h b/arch/s390/include/asm/socket.h
index fdff1e9..73d0117 100644
--- a/arch/s390/include/asm/socket.h
+++ b/arch/s390/include/asm/socket.h
@@ -70,4 +70,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN           41
+#define SO_EPOOL_SIZE           42
+#define SO_EPOOL_MODE           43
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/asm/socket.h b/arch/sparc/include/asm/socket.h
index 9d3fefc..39eea91 100644
--- a/arch/sparc/include/asm/socket.h
+++ b/arch/sparc/include/asm/socket.h
@@ -58,6 +58,9 @@
 
 #define SO_RXQ_OVFL             0x0024
 
+#define SO_EPOOL_QLEN           0x0025
+#define SO_EPOOL_SIZE           0x0026
+#define SO_EPOOL_MODE           0x0027
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/asm/socket.h b/arch/xtensa/include/asm/socket.h
index cbdf2ff..161a2e5 100644
--- a/arch/xtensa/include/asm/socket.h
+++ b/arch/xtensa/include/asm/socket.h
@@ -73,4 +73,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_EPOOL_QLEN           41
+#define SO_EPOOL_SIZE           42
+#define SO_EPOOL_MODE           43
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 9a6115e..fa9ccbb 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -64,4 +64,8 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+
+#define SO_EPOOL_QLEN		41
+#define SO_EPOOL_SIZE		42
+#define SO_EPOOL_MODE		43
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4fa400b..fa7e951 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1095,6 +1095,28 @@ struct net_device {
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
+/**
+ *	dev_put - release reference to device
+ *	@dev: network device
+ *
+ * Release reference to device to allow it to be freed.
+ */
+static inline void dev_put(struct net_device *dev)
+{
+	atomic_dec(&dev->refcnt);
+}
+
+/**
+ *	dev_hold - get reference to device
+ *	@dev: network device
+ *
+ * Hold reference to device to keep it from being freed.
+ */
+static inline void dev_hold(struct net_device *dev)
+{
+	atomic_inc(&dev->refcnt);
+}
+
 static inline void net_recycle_init(struct net_device *dev, u32 qlen, u32 size)
 {
 	dev->rx_rec_skbs_max = qlen;
@@ -1118,9 +1140,13 @@ static inline void net_recycle_cleanup(struct net_device *dev)
 
 static inline void net_recycle_add(struct net_device *dev, struct sk_buff *skb)
 {
+	if (skb->emerg_dev) {
+		dev_put(skb->emerg_dev);
+		skb->emerg_dev = NULL;
+	}
 	if (skb_queue_len(&dev->rx_recycle) < dev->rx_rec_skbs_max &&
 			skb_recycle_check(skb, dev->rx_rec_skb_size))
-		__skb_queue_head(&dev->rx_recycle, skb);
+		skb_queue_head(&dev->rx_recycle, skb);
 	else
 		dev_kfree_skb_any(skb);
 }
@@ -1129,7 +1155,7 @@ static inline struct sk_buff *net_recycle_get(struct net_device *dev)
 {
 	struct sk_buff *skb;
 
-	skb = __skb_dequeue(&dev->rx_recycle);
+	skb = skb_dequeue(&dev->rx_recycle);
 	if (skb)
 		return skb;
 	return netdev_alloc_skb(dev, dev->rx_rec_skb_size);
@@ -1783,28 +1809,6 @@ extern int		netdev_budget;
 /* Called by rtnetlink.c:rtnl_unlock() */
 extern void netdev_run_todo(void);
 
-/**
- *	dev_put - release reference to device
- *	@dev: network device
- *
- * Release reference to device to allow it to be freed.
- */
-static inline void dev_put(struct net_device *dev)
-{
-	atomic_dec(&dev->refcnt);
-}
-
-/**
- *	dev_hold - get reference to device
- *	@dev: network device
- *
- * Hold reference to device to keep it from being freed.
- */
-static inline void dev_hold(struct net_device *dev)
-{
-	atomic_inc(&dev->refcnt);
-}
-
 /* Carrier loss detection, dial on demand. The functions netif_carrier_on
  * and _off may be called from IRQ context, but it is caller
  * who is responsible for serialization of these calls.
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac74ee0..caee62c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -319,6 +319,7 @@ struct sk_buff {
 
 	struct sock		*sk;
 	struct net_device	*dev;
+	struct net_device	*emerg_dev;
 
 	/*
 	 * This is the control buffer. It is free to use for every
diff --git a/include/net/sock.h b/include/net/sock.h
index 4f26f2f..3f3518a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -314,6 +314,8 @@ struct sock {
 #endif
 	__u32			sk_mark;
 	u32			sk_classid;
+	u32			emerg_en;
+	/* XXX 4 bytes hole on 64 bit */
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 34432b4..f02737d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -425,6 +425,13 @@ static void skb_release_all(struct sk_buff *skb)
 
 void __kfree_skb(struct sk_buff *skb)
 {
+	struct net_device *ndev = skb->emerg_dev;
+
+	if (ndev) {
+		net_recycle_add(ndev, skb);
+		return;
+	}
+
 	skb_release_all(skb);
 	kfree_skbmem(skb);
 }
@@ -563,6 +570,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 {
 #define C(x) n->x = skb->x
 
+	n->emerg_dev = NULL;
 	n->next = n->prev = NULL;
 	n->sk = NULL;
 	__copy_skb_header(n, skb);
diff --git a/net/core/sock.c b/net/core/sock.c
index fef2434..33aa1a5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -472,6 +472,71 @@ static inline void sock_valbool_flag(struct sock *sk, int bit, int valbool)
 		sock_reset_flag(sk, bit);
 }
 
+static int sock_epool_set_qlen(struct sock *sk, int val)
+{
+	struct net *net = sock_net(sk);
+	struct net_device *dev;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!sk->sk_bound_dev_if)
+		return -ENODEV;
+	dev = dev_get_by_index(net, sk->sk_bound_dev_if);
+	if (!dev)
+		return -ENODEV;
+
+	net_recycle_qlen(dev, val);
+	dev_put(dev);
+	return 0;
+}
+
+static int sock_epool_set_mode(struct sock *sk, int val)
+{
+	int ret;
+	struct net *net = sock_net(sk);
+	struct net_device *dev;
+
+	if (!val) {
+		sk->emerg_en = 0;
+		return 0;
+	}
+	if (sk->emerg_en && val)
+		return -EBUSY;
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+	if (!sk->sk_bound_dev_if)
+		return -ENODEV;
+	dev = dev_get_by_index(net, sk->sk_bound_dev_if);
+	if (!dev)
+		return -ENODEV;
+	ret = -ENODEV;
+	if (!dev->rx_rec_skb_size)
+		goto out;
+
+	do {
+		struct sk_buff *skb;
+
+		if (skb_queue_len(&dev->rx_recycle) >= dev->rx_rec_skbs_max) {
+			ret = 0;
+			break;
+		}
+
+		skb = __netdev_alloc_skb(dev, dev->rx_rec_skb_size, GFP_KERNEL);
+		if (!skb) {
+			ret = -ENOMEM;
+			break;
+		}
+		net_recycle_add(dev, skb);
+	} while (1);
+
+	if (!ret)
+		sk->emerg_en = 1;
+out:
+	dev_put(dev);
+	return ret;
+}
+
 /*
  *	This is meant for all protocols to use and covers goings on
  *	at the socket level. Everything here is generic.
@@ -740,6 +805,15 @@ set_rcvbuf:
 		else
 			sock_reset_flag(sk, SOCK_RXQ_OVFL);
 		break;
+	case SO_EPOOL_QLEN:
+		ret = sock_epool_set_qlen(sk, val);
+		break;
+	case SO_EPOOL_SIZE:
+		ret = -EINVAL;
+		break;
+	case SO_EPOOL_MODE:
+		ret = sock_epool_set_mode(sk, valbool);
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -961,6 +1035,35 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		v.val = !!sock_flag(sk, SOCK_RXQ_OVFL);
 		break;
 
+	case SO_EPOOL_QLEN:
+	{
+		struct net *net = sock_net(sk);
+		struct net_device *dev;
+
+		if (!sk->sk_bound_dev_if)
+			return -ENODEV;
+		dev = dev_get_by_index(net, sk->sk_bound_dev_if);
+		if (!dev)
+			return -ENODEV;
+		v.val = dev->rx_rec_skbs_max;
+		break;
+	}
+	case SO_EPOOL_SIZE:
+	{
+		struct net *net = sock_net(sk);
+		struct net_device *dev;
+
+		if (!sk->sk_bound_dev_if)
+			return -ENODEV;
+		dev = dev_get_by_index(net, sk->sk_bound_dev_if);
+		if (!dev)
+			return -ENODEV;
+		v.val = dev->rx_rec_skb_size;
+		break;
+	}
+	case SO_EPOOL_MODE:
+		v.val = sk->emerg_en;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -1459,6 +1562,37 @@ static long sock_wait_for_wmem(struct sock *sk, long timeo)
 	return timeo;
 }
 
+static struct sk_buff *alloc_emerg_skb(struct sock *sk, unsigned int skb_len)
+{
+	struct net *net = sock_net(sk);
+	struct net_device *dev;
+	int err;
+	struct sk_buff *skb;
+
+	err = -ENODEV;
+	if (!sk->sk_bound_dev_if)
+		return ERR_PTR(err);
+	dev = dev_get_by_index(net, sk->sk_bound_dev_if);
+	if (!dev)
+		return ERR_PTR(err);
+	err = -EINVAL;
+	if (dev->rx_rec_skb_size < skb_len) {
+		dev_put(dev);
+		return ERR_PTR(err);
+	}
+	skb = skb_dequeue(&dev->rx_recycle);
+	if (!skb) {
+		dev_put(dev);
+		err = -ENOBUFS;
+		return ERR_PTR(err);
+	}
+	/*
+	 * dev will be put once the skb is back from
+	 * its journey.
+	 */
+	skb->emerg_dev = dev;
+	return skb;
+}
 
 /*
  *	Generic send/receive buffer handlers
@@ -1488,6 +1622,14 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
 			goto failure;
 
 		if (atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf) {
+			if (sk->emerg_en) {
+				skb = alloc_emerg_skb(sk, header_len + data_len);
+				if (IS_ERR(skb)) {
+					err = PTR_ERR(skb);
+					goto failure;
+				}
+				break;
+			}
 			skb = alloc_skb(header_len, gfp_mask);
 			if (skb) {
 				int npages;
-- 
1.6.6.1

