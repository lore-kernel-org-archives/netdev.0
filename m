From: Dan Eble <dane@aiinet.com>
Subject: [FYI PATCH] Ethernet over Cisco HDLC
Date: Wed, 23 Jun 2004 16:37:06 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0406231625490.7776-100000@dane-linux.aiinet.priv>
Reply-To: dane@aiinet.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I don't expect this patch to apply to any recent versions of the kernel.  
I'm posting it in case there is someone interested in porting it.  If
someone has the time to comment on the locking during dev destruction, I
would appreciate receiving pointers.  Any other comments are welcome too.

[To Krzysztof Halasa: All my mail to your pm.waw address bounces.  Is
there an alternate address I can use to contact you?]

-- 
Dan Eble <dane@aiinet.com>  _____  .
Software Engineer          |  _  |/|
Applied Innovation Inc.    | |_| | |
http://www.aiinet.com/     |__/|_|_|

diff -10 -wbBurN Old/include/linux/hdlc/ioctl.h New/include/linux/hdlc/ioctl.h
--- Old/include/linux/hdlc/ioctl.h	2004-06-23 13:59:58.000000000 -0400
+++ New/include/linux/hdlc/ioctl.h	2004-06-23 16:19:07.000000000 -0400
@@ -38,15 +38,20 @@
 typedef struct {
 	unsigned int dlci;
 	char master[IFNAMSIZ];	/* Name of master FRAD device */
 }fr_proto_pvc_info;		/* for returning PVC information only */
 
 typedef struct {
     unsigned int interval;
     unsigned int timeout;
 } cisco_proto;
 
+typedef struct { /* for enabling/disabling certain encapsulated protocols */
+	unsigned short proto;
+	char name[IFNAMSIZ]; /* filled in by driver */
+} cisco_proto_inner;
+
 typedef struct {
 	int channel; /* read-only index assigned by generic PPP layer */
 } ppp_proto;
 
 #endif /* __HDLC_IOCTL_H__ */
diff -10 -wbBurN Old/include/linux/hdlc.h New/include/linux/hdlc.h
--- Old/include/linux/hdlc.h	2004-06-23 13:59:57.000000000 -0400
+++ New/include/linux/hdlc.h	2004-06-23 16:19:07.000000000 -0400
@@ -214,20 +214,25 @@
 
 		struct {
 			cisco_proto settings;
 
 			struct timer_list timer;
 			int last_poll;
 			int up;
 			u32 txseq; /* TX sequence number */
 			u32 rxseq; /* RX sequence number */
 			u32 mineseen; /* echoed sequence number from remote */
+
+			struct hdlc_cisco_br_eth {
+				struct net_device dev; /* must be first */
+				struct net_device_stats stats;
+			} *cbe; /* cbe == Cisco bridged ethernet */
 		}cisco;
 
 		struct {
 			raw_hdlc_proto settings;
 		}raw_hdlc;
 
 		struct {
 			ppp_proto settings;
 
 			unsigned int	flags;
diff -10 -wbBurN Old/include/linux/if_ether.h New/include/linux/if_ether.h
--- Old/include/linux/if_ether.h	2004-06-23 13:59:58.000000000 -0400
+++ New/include/linux/if_ether.h	2004-06-23 16:19:07.000000000 -0400
@@ -47,20 +47,21 @@
 #define ETH_P_IEEEPUP	0x0a00		/* Xerox IEEE802.3 PUP packet */
 #define ETH_P_IEEEPUPAT	0x0a01		/* Xerox IEEE802.3 PUP Addr Trans packet */
 #define ETH_P_DEC       0x6000          /* DEC Assigned proto           */
 #define ETH_P_DNA_DL    0x6001          /* DEC DNA Dump/Load            */
 #define ETH_P_DNA_RC    0x6002          /* DEC DNA Remote Console       */
 #define ETH_P_DNA_RT    0x6003          /* DEC DNA Routing              */
 #define ETH_P_LAT       0x6004          /* DEC LAT                      */
 #define ETH_P_DIAG      0x6005          /* DEC Diagnostics              */
 #define ETH_P_CUST      0x6006          /* DEC Customer use             */
 #define ETH_P_SCA       0x6007          /* DEC Systems Comms Arch       */
+#define ETH_P_ETH_BR    0x6558          /* Trans Ether Bridging [RFC1701] */
 #define ETH_P_RARP      0x8035		/* Reverse Addr Res packet	*/
 #define ETH_P_ATALK	0x809B		/* Appletalk DDP		*/
 #define ETH_P_AARP	0x80F3		/* Appletalk AARP		*/
 #define ETH_P_8021Q	0x8100          /* 802.1Q VLAN Extended Header  */
 #define ETH_P_IPX	0x8137		/* IPX over DIX			*/
 #define ETH_P_IPV6	0x86DD		/* IPv6 over bluebook		*/
 #define ETH_P_PPP_DISC	0x8863		/* PPPoE discovery messages     */
 #define ETH_P_PPP_SES	0x8864		/* PPPoE session messages	*/
 #define ETH_P_ATMMPOA	0x884c		/* MultiProtocol Over ATM	*/
 #define ETH_P_ATMFATE	0x8884		/* Frame-based ATM Transport
diff -10 -wbBurN Old/include/linux/if.h New/include/linux/if.h
--- Old/include/linux/if.h	2004-06-23 13:59:58.000000000 -0400
+++ New/include/linux/if.h	2004-06-23 16:19:07.000000000 -0400
@@ -69,20 +69,22 @@
 #define IF_PROTO_CISCO	0x2002		/* Cisco HDLC protocol		*/
 #define IF_PROTO_FR	0x2003		/* Frame Relay protocol		*/
 #define IF_PROTO_FR_ADD_PVC 0x2004	/*    Create FR PVC		*/
 #define IF_PROTO_FR_DEL_PVC 0x2005	/*    Delete FR PVC		*/
 #define IF_PROTO_X25	0x2006		/* X.25				*/
 #define IF_PROTO_HDLC_ETH 0x2007	/* raw HDLC, Ethernet emulation	*/
 #define IF_PROTO_FR_ADD_ETH_PVC 0x2008	/*  Create FR Ethernet-bridged PVC */
 #define IF_PROTO_FR_DEL_ETH_PVC 0x2009	/*  Delete FR Ethernet-bridged PVC */
 #define IF_PROTO_FR_PVC	0x200A		/* for reading PVC status	*/
 #define IF_PROTO_FR_ETH_PVC 0x200B
+#define IF_PROTO_CISCO_ENABLE_PROTO 0x200C  /* enable an encapsulated proto  */
+#define IF_PROTO_CISCO_DISABLE_PROTO 0x200D /* disable an encapsulated proto */
 
 
 /*
  *	Device mapping structure. I'd just gone off and designed a
  *	beautiful scheme using only loadable modules with arguments
  *	for driver options and along come the PCMCIA people 8)
  *
  *	Ah well. The get() side of this is good for WDSETUP, and it'll
  *	be handy for debugging things. The set side is fine for now and
  *	being very small might be worth keeping for clean configuration.
@@ -100,20 +102,21 @@
 };
 
 struct if_settings
 {
 	unsigned int type;	/* Type of physical device or protocol */
 	unsigned int size;	/* Size of the data allocated by the caller */
 	union {
 		/* {atm/eth/dsl}_settings anyone ? */
 		raw_hdlc_proto		*raw_hdlc;
 		cisco_proto		*cisco;
+		cisco_proto_inner	*cisco_inner;
 		fr_proto		*fr;
 		fr_proto_pvc		*fr_pvc;
 		fr_proto_pvc_info	*fr_pvc_info;
 		ppp_proto		*ppp;
 
 		/* interface settings */
 		sync_serial_settings	*sync;
 		te1_settings		*te1;
 	} ifs_ifsu;
 };
diff -10 -wbBurN Old/drivers/net/wan/hdlc_cisco.c New/drivers/net/wan/hdlc_cisco.c
--- Old/drivers/net/wan/hdlc_cisco.c	2004-06-23 13:59:57.000000000 -0400
+++ New/drivers/net/wan/hdlc_cisco.c	2004-06-23 16:19:07.000000000 -0400
@@ -13,50 +13,89 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/poll.h>
 #include <linux/errno.h>
 #include <linux/if_arp.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/pkt_sched.h>
 #include <linux/inetdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/lapb.h>
 #include <linux/rtnetlink.h>
 #include <linux/hdlc.h>
 #include "hdlc_proc.h"
 
 
 #define CISCO_MULTICAST		0x8F	/* Cisco multicast address */
 #define CISCO_UNICAST		0x0F	/* Cisco unicast address */
+#define CISCO_IEEE_802_1D	0x4242	/* Spanning Tree PDU */
 #define CISCO_KEEPALIVE		0x8035	/* Cisco keepalive protocol */
 #define CISCO_SYS_INFO		0x2000	/* Cisco interface/system info */
 #define CISCO_ADDR_REQ		0	/* Cisco address request */
 #define CISCO_ADDR_REPLY	1	/* Cisco address reply */
 #define CISCO_KEEPALIVE_REQ	2	/* Cisco keepalive request */
 
+static __inline__ int cbe_create(struct hdlc_device_struct *hdlc);
+static __inline__ int cbe_destroy(struct hdlc_device_struct *hdlc);
+static struct net_device_stats* cbe_stats(struct net_device *edev);
+static int cbe_ioctl(struct net_device *edev, struct ifreq *ifr, int cmd);
+static int cbe_start_xmit(struct sk_buff *skb, struct net_device *edev);
+
+static __inline__ struct hdlc_cisco_br_eth*
+dev_to_cbe(struct net_device *dev)
+{
+	/* the net_device is the first member of hdlc_cisco_br_eth */
+	return (struct hdlc_cisco_br_eth*)dev;
+}
+
+static __inline__ struct net_device *
+cbe_to_dev(struct hdlc_cisco_br_eth *cbe)
+{
+	/* the net_device is the first member of hdlc_cisco_br_eth */
+	return (struct net_device*)cbe;
+}
+
+static __inline__ struct hdlc_device_struct*
+cbe_to_hdlc(struct hdlc_cisco_br_eth *cbe)
+{
+	return (struct hdlc_device_struct*)cbe->dev.priv;
+}
+
+/* IEEE 802.1D bridge PDU destination address */
+static const __u8 IEEE_802_1D_DSTADDR[ETH_ALEN] = { 1, 0x80, 0xC2, 0, 0, 0 };
+
+/* A few bytes that are present when and IEEE 802.1D bridge PDU is
+ * packed into an IEEE 802.3 frame. */
+static const __u8 IEEE_802_1D_802_2_HDR[] = { 0x42, 0x42, 0x03 };
 
 static int cisco_hard_header(struct sk_buff *skb, struct net_device *dev,
 			     u16 type, void *daddr, void *saddr,
 			     unsigned int len)
 {
 	hdlc_header *data;
 #ifdef CONFIG_HDLC_DEBUG_HARD_HEADER
 	printk(KERN_DEBUG "hdlc: %s: cisco_hard_header called\n", dev->name);
 #endif
 
 	skb_push(skb, sizeof(hdlc_header));
 	data = (hdlc_header*)skb->data;
-	if (type == CISCO_KEEPALIVE)
+	switch (type) {
+	case CISCO_IEEE_802_1D:
+	case CISCO_KEEPALIVE:
 		data->address = CISCO_MULTICAST;
-	else
+		break;
+	default:
 		data->address = CISCO_UNICAST;
+		break;
+	}
 	data->control = 0;
 	data->protocol = htons(type);
 
 	return sizeof(hdlc_header);
 }
 
 
 
 static void cisco_keepalive_send(hdlc_device *hdlc, u32 type,
 				 u32 par1, u32 par2)
@@ -201,53 +240,102 @@
 
 		case CISCO_ADDR_REPLY:
 			printk(KERN_INFO "hdlc: %s: Unexpected Cisco IP address "
 			       "reply\n", hdlc_to_name(hdlc));
 			goto rx_error;
 
 		case CISCO_KEEPALIVE_REQ:
 			hdlc->state.cisco.rxseq = ntohl(cisco_data->par1);
                         hdlc->state.cisco.mineseen = ntohl(cisco_data->par2);
 
-                        // DWD - allow sequence numbers to be off by one. This copes with the race condition of
-                        // having both ends transmitting keepalives at the same time
-#if 1
+                        /* Allow sequence numbers to be off by one. This copes
+			 * with the race condition of having both ends
+			 * transmitting keepalives at the same time */
                         if ((hdlc->state.cisco.mineseen == hdlc->state.cisco.txseq) ||
                             (hdlc->state.cisco.mineseen == (hdlc->state.cisco.txseq-1))) {
-#else
-			if (ntohl(cisco_data->par2) == hdlc->state.cisco.txseq) {
-#endif
 				hdlc->state.cisco.last_poll = jiffies;
 				if (!hdlc->state.cisco.up) {
-#if 0 // DWD - the uptime reporting provides strange values
+#if 0 /* DWD - the uptime reporting provides strange values */
 					if (skb->len >= CISCO_UPTIME_PACKET_LEN) {
 						cisco_log_link_uptime(hdlc,
 						      ntohl(cisco_data->time));
 					} else
 #endif
                                         {
 						cisco_log_link_up(hdlc);
 					}
 				}
 				hdlc->state.cisco.up = 1;
 			}
 
 			dev_kfree_skb_any(skb);
 			return;
 		} /* switch(keepalive type) */
+		break;
+
+	case CISCO_IEEE_802_1D:
+		if (!hdlc->state.cisco.cbe)
+			goto rx_drop;
+
+		if (skb_cow(skb, ETH_HLEN+sizeof(IEEE_802_1D_802_2_HDR)) != 0)
+			goto rx_drop;
+
+		/* Prepend the 802.2 SSAP, DSAP and control byte. */
+		memcpy(skb_push(skb, sizeof(IEEE_802_1D_802_2_HDR)),
+		       IEEE_802_1D_802_2_HDR,
+		       sizeof(IEEE_802_1D_802_2_HDR));
+
+		/* Prepend an 802.3 header. */
+		{
+			struct ethhdr *eth =
+				(struct ethhdr *)skb_push(skb, ETH_HLEN);
+			memcpy(eth->h_dest, IEEE_802_1D_DSTADDR, ETH_ALEN);
+			memset(eth->h_source, 0, ETH_ALEN);
+			eth->h_proto = htons(skb->len - ETH_HLEN);
+		}
+
+		/* FALL THROUGH to ETH_P_ETH_BR */
+
+	case ETH_P_ETH_BR:
+		if (hdlc->state.cisco.cbe)
+		{
+			struct net_device *const edev =
+				cbe_to_dev(hdlc->state.cisco.cbe);
+
+			/* Assign this buffer to the bridged eth dev. */
+			skb->dev = edev;
+
+			/* Parse the ethernet header.  Because of the
+			 * increased hard_header_len, eth_type_trans()
+			 * skips too much, so push some back afterward. */
+			skb->protocol = eth_type_trans(skb, edev);
+			skb_push(skb, edev->hard_header_len - ETH_HLEN);
+
+			/* Receive the buffer on the bridged eth dev. */
+			netif_rx(skb);
+			edev->last_rx = jiffies;
+			return;
+		}
+		goto rx_drop;
+
 	} /* switch(protocol) */
 
 	printk(KERN_INFO "hdlc: %s: Unsupported protocol %x\n", hdlc_to_name(hdlc),
 	       data->protocol);
 	dev_kfree_skb_any(skb);
 	return;
 
+ rx_drop:
+	dev_kfree_skb_any(skb);
+	hdlc->stats.rx_dropped++;
+	return;
+
  rx_error:
 	hdlc->stats.rx_errors++; /* Mark error */
 	dev_kfree_skb_any(skb);
 }
 
 
 
 static void cisco_timer(unsigned long arg)
 {
 	hdlc_device *hdlc = (hdlc_device*)arg;
@@ -292,21 +380,27 @@
 }
 
 
 
 static void cisco_close(hdlc_device *hdlc)
 {
         hdlc_proc_session_clean(hdlc);
 	del_timer_sync(&hdlc->state.cisco.timer);
 }
 
+static void cisco_destroy(struct hdlc_device_struct *hdlc)
+{
+	cbe_destroy(hdlc);
 
+	/* Return dev attributes to their defaults set in hdlc_generic.c. */
+	hdlc_to_dev(hdlc)->hard_header_len = 16;
+}
 
 int hdlc_cisco_ioctl(hdlc_device *hdlc, struct ifreq *ifr)
 {
 	cisco_proto *cisco_s = ifr->ifr_settings.ifs_ifsu.cisco;
 	const size_t size = sizeof(cisco_proto);
 	cisco_proto new_settings;
 	struct net_device *dev = hdlc_to_dev(hdlc);
 	int result;
 
 	switch (ifr->ifr_settings.type) {
@@ -337,28 +431,111 @@
 		result=hdlc->attach(hdlc, ENCODING_NRZ,PARITY_CRC16_PR1_CCITT);
 
 		if (result)
 			return result;
 
 		hdlc_proto_detach(hdlc);
 		memcpy(&hdlc->state.cisco.settings, &new_settings, size);
 
 		hdlc->open = cisco_open;
 		hdlc->stop = cisco_close;
+		hdlc->proto_detach = cisco_destroy;
 		hdlc->netif_rx = cisco_rx;
 		hdlc->type_trans = cisco_type_trans;
 		hdlc->proto = IF_PROTO_CISCO;
 		dev->hard_start_xmit = hdlc->xmit;
 		dev->hard_header = cisco_hard_header;
+		dev->hard_header_len = sizeof(hdlc_header);
 		dev->type = ARPHRD_CISCO;
 		dev->addr_len = 0;
+
 		return 0;
+
+	case IF_PROTO_CISCO_ENABLE_PROTO:
+	{
+		cisco_proto_inner inner;
+
+		if(!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (copy_from_user(&inner,
+				   ifr->ifr_settings.ifs_ifsu.cisco_inner,
+				   sizeof(inner)))
+			return -EFAULT;
+
+		switch (inner.proto)
+		{
+		case ETH_P_ETH_BR:
+			result = cbe_create(hdlc);
+			if (0 == result)
+			{
+				strncpy(inner.name,
+					cbe_to_dev(hdlc->state.cisco.cbe)->name,
+					IFNAMSIZ);
+			}
+			break;
+
+		default:
+			result = -EINVAL;
+			break;
+		}
+
+		if (0 == result) {
+			if (copy_to_user(
+				    ifr->ifr_settings.ifs_ifsu.cisco_inner,
+				    &inner, sizeof(inner)))
+				return -EFAULT;
+		}
+
+		return result;
+	}
+
+	case IF_PROTO_CISCO_DISABLE_PROTO:
+	{
+		cisco_proto_inner inner;
+
+		if(!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (copy_from_user(&inner,
+				   ifr->ifr_settings.ifs_ifsu.cisco_inner,
+				   sizeof(inner)))
+			return -EFAULT;
+
+		switch (inner.proto)
+		{
+		case ETH_P_ETH_BR:
+			if (hdlc->state.cisco.cbe) {
+				strncpy(inner.name,
+					cbe_to_dev(hdlc->state.cisco.cbe)->name,
+					IFNAMSIZ);
+				result = cbe_destroy(hdlc);
+			} else {
+				result = -EINVAL;
+			}
+			break;
+
+		default:
+			result = -EINVAL;
+			break;
+		}
+
+		if (0 == result) {
+			if (copy_to_user(
+				    ifr->ifr_settings.ifs_ifsu.cisco_inner,
+				    &inner, sizeof(inner)))
+				return -EFAULT;
+		}
+
+		return result;
+	}
+
 	}
 
 	return -EINVAL;
 }
 
 /**
  * Get the Debug level
  */
 int hdlc_cisco_get_Debug(hdlc_device *hdlc,
                            void *debug)
@@ -401,14 +578,193 @@
 {
     *(int *)yourseen = hdlc->state.cisco.rxseq;
     return 0;
 }
 /**
  * Get MineSeen
  */
 int hdlc_cisco_get_MineSeen(hdlc_device *hdlc,
                            void *mineseen)
 {
-// need to store this for retreival
+/* need to store this for retrieval */
     *(int *)mineseen = hdlc->state.cisco.mineseen;
     return 0;
 }
+
+/**
+ * Allocate, initialize, and register a device for bridging Ethernet/802.3.
+ */
+static __inline__ int cbe_create(struct hdlc_device_struct *hdlc)
+{
+	struct hdlc_cisco_br_eth *cbe;
+	struct net_device *const hdev = hdlc_to_dev(hdlc); /* HDLC device */
+	struct net_device *edev; /* "ethernet" device */
+	int ret = 0;
+
+	/* "cbe" eventually is freed by unregister_netdevice() */
+	cbe = kmalloc(sizeof(*cbe), GFP_KERNEL);
+	if (!cbe) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	memset(cbe, 0, sizeof(*cbe));
+	edev = cbe_to_dev(cbe);
+
+	ether_setup(edev);
+	edev->priv = hdlc;
+
+	/* Reserve space for the ethernet header. */
+	edev->hard_header_len = hdev->hard_header_len + ETH_HLEN;
+	edev->mtu = hdev->mtu - ETH_HLEN;
+	if (edev->mtu > ETH_DATA_LEN)
+		edev->mtu = ETH_DATA_LEN;
+
+	edev->hard_start_xmit = cbe_start_xmit;
+	edev->get_stats = cbe_stats;
+	edev->do_ioctl = cbe_ioctl;
+	edev->tx_queue_len = 0; /* let underlying device queue packets */
+	edev->features |= NETIF_F_DYNALLOC;
+
+	/* Assign the name of the ethernet device by appending "eth0" to
+	 * the name of the underlying HDLC device. */
+	snprintf(edev->name, IFNAMSIZ, "%seth0", hdev->name);
+
+	ret = register_netdevice(edev);
+	if (ret != 0) {
+		printk(KERN_ERR "hdlc_cisco: could not register dev %s (%d)\n",
+		       edev->name, ret);
+		goto err;
+	} else {
+		/* After this, cisco_rx() will send packets to the new dev. */
+		hdlc->state.cisco.cbe = cbe;
+	}
+
+	return ret;
+
+ err:
+	if (cbe)
+		kfree(cbe);
+	return ret;
+}
+
+/**
+ * Unregister and deallocate the device for bridging Ethernet/802.3.
+ */
+static __inline__ int cbe_destroy(struct hdlc_device_struct *hdlc)
+{
+	struct hdlc_cisco_br_eth *const cbe = hdlc->state.cisco.cbe;
+	int result = -EINVAL;
+
+	if (cbe)
+	{
+		unsigned long flags;
+
+		/* Dissociate the devices. */
+
+		/* lock against cisco_rx() */
+		local_irq_save(flags);
+		hdlc->state.cisco.cbe = NULL;
+		local_irq_restore(flags);
+
+		/* lock against cbe_start_xmit() */
+		spin_lock_bh(&cbe_to_dev(cbe)->xmit_lock);
+		cbe_to_dev(cbe)->priv = NULL;
+		spin_unlock_bh(&cbe_to_dev(cbe)->xmit_lock);
+
+		unregister_netdevice(cbe_to_dev(cbe));
+
+		result = 0;
+	}
+
+	return result;
+}
+
+static struct net_device_stats* cbe_stats(struct net_device *edev)
+{
+	struct hdlc_cisco_br_eth *const cbe = dev_to_cbe(edev);
+	if (cbe)
+	{
+		return &cbe->stats;
+	}
+
+	return NULL;
+}
+
+static int cbe_ioctl(struct net_device *edev, struct ifreq *ifr, int cmd)
+{
+	return -EOPNOTSUPP;
+}
+
+static int cbe_start_xmit(struct sk_buff *skb, struct net_device *edev)
+{
+	struct hdlc_cisco_br_eth *const cbe = dev_to_cbe(edev);
+	struct hdlc_device_struct *const hdlc = cbe_to_hdlc(cbe);
+
+	if (hdlc) {
+		struct net_device *const hdev = hdlc_to_dev(hdlc);
+		unsigned short cproto; /* cisco protocol type */
+		unsigned short kproto; /* kernel protocol type */
+
+		/* If the MTU of the underlying HDLC interface is too
+		 * small to encapsulate the largest ethernet frame
+		 * (based on the MTU of this device), drop all
+		 * packets.  Even the packets that are small enough to
+		 * fit are dropped, in order to make it impossible to
+		 * overlook the misconfiguration.
+		 *
+		 * I have decided against enforcing MTU restrictions
+		 * in the dev->change_mtu() functions because I do not
+		 * want to force users to configure the devices in a
+		 * certain order (and a different order, depending on
+		 * whether the change is an increase or a decrease).
+		 *
+		 * I have also decided (for the time being) not to log
+		 * a message.  The device stats will record dropped
+		 * packets, and MTU is one of the things that should
+		 * be checked in that circumstance.
+		 */
+		if (hdev->mtu < ETH_HLEN + edev->mtu)
+			goto tx_drop;
+
+		/* make sure we can push/pull without side effects */
+		skb = skb_share_check(skb, GFP_ATOMIC);
+		if (!skb)
+			goto tx_dropped;
+
+		/* IEEE 802.1D PDUs get encapsulated without an ethernet header
+		 * and with a distinct Cisco protocol type. */
+		if (pskb_may_pull(skb,
+				  ETH_HLEN + sizeof(IEEE_802_1D_802_2_HDR)) &&
+		    (0 == memcmp(skb->data, IEEE_802_1D_DSTADDR, ETH_ALEN)) &&
+		    (0 == memcmp(&skb->data[ETH_HLEN], IEEE_802_1D_802_2_HDR,
+				 sizeof(IEEE_802_1D_802_2_HDR)))) {
+			cproto = CISCO_IEEE_802_1D;
+			kproto = ETH_P_HDLC;
+			skb_pull(skb, ETH_HLEN+sizeof(IEEE_802_1D_802_2_HDR));
+		} else { /* other frames get encapsulated verbatim */
+			cproto = ETH_P_ETH_BR;
+			kproto = ETH_P_ETH_BR;
+		}
+
+		skb->dev = hdev; /* send through the HDLC interface */
+		skb->protocol = __constant_htons(kproto);
+
+		if (skb_cow(skb, hdev->hard_header_len) != 0)
+			goto tx_drop;
+
+		if (!cisco_hard_header(skb, skb->dev, cproto,
+				       NULL, NULL, skb->len))
+			goto tx_drop;
+
+		++cbe->stats.tx_packets;
+		cbe->stats.tx_bytes += skb->len;
+		dev_queue_xmit(skb);
+		return 0;
+	}
+
+ tx_drop:
+	kfree_skb(skb);
+ tx_dropped:
+	++cbe->stats.tx_dropped;
+	return 0;
+}
