From: greearb@candelatech.com
Subject: [PATCH 1/5] send-crc: Add framework to allow sending packets with customized CRC.
Date: Tue,  7 Feb 2012 11:49:40 -0800
Message-ID: <1328644182-7872-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35670 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756739Ab2BGTtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 14:49:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This is useful for testing RX handling of frames with bad
CRCs.

Requires driver support to actually put the packet on the
wire properly.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 7d27812... 0bc0d37... M	Documentation/networking/netdev-features.txt
:100644 100644 082355f... 87ba870... M	arch/alpha/include/asm/socket.h
:100644 100644 dec6f9a... ea7629e... M	arch/arm/include/asm/socket.h
:100644 100644 247b88c... 6d2e448... M	arch/avr32/include/asm/socket.h
:100644 100644 e269264... 9ba1079... M	arch/cris/include/asm/socket.h
:100644 100644 ce80fda... ff8a4c3... M	arch/frv/include/asm/socket.h
:100644 100644 cf1daab... 8be2267... M	arch/h8300/include/asm/socket.h
:100644 100644 4b03664... 17664c9... M	arch/ia64/include/asm/socket.h
:100644 100644 e8b8c5b... 20de3ac... M	arch/m32r/include/asm/socket.h
:100644 100644 d4708ce... 98bf770... M	arch/m68k/include/asm/socket.h
:100644 100644 ad5c0a7... d97c83a... M	arch/mips/include/asm/socket.h
:100644 100644 876356d... 545cbbe... M	arch/mn10300/include/asm/socket.h
:100644 100644 d28c51b... 15d2d90... M	arch/parisc/include/asm/socket.h
:100644 100644 2fc2af8... 29bbe62... M	arch/powerpc/include/asm/socket.h
:100644 100644 67b5c1b... 237b1e7... M	arch/s390/include/asm/socket.h
:100644 100644 8af1b64... 18d523a... M	arch/sparc/include/asm/socket.h
:100644 100644 bb06968... 00af4e6... M	arch/xtensa/include/asm/socket.h
:100644 100644 49c1704... 3c59235... M	include/asm-generic/socket.h
:100644 100644 d133186... 3bae320... M	include/linux/netdev_features.h
:100644 100644 50db9b0... cc614a9... M	include/linux/skbuff.h
:100644 100644 91c1c8b... 5d8ecbc... M	include/net/sock.h
:100644 100644 0801619... cf81ccf... M	net/core/ethtool.c
:100644 100644 da0c97f... 36e7b7c... M	net/core/skbuff.c
:100644 100644 3e81fd2... 1db3096... M	net/core/sock.c
:100644 100644 2dbb32b... f4c833e... M	net/packet/af_packet.c
 Documentation/networking/netdev-features.txt |    9 +++++++
 arch/alpha/include/asm/socket.h              |    3 ++
 arch/arm/include/asm/socket.h                |    3 ++
 arch/avr32/include/asm/socket.h              |    3 ++
 arch/cris/include/asm/socket.h               |    3 ++
 arch/frv/include/asm/socket.h                |    3 ++
 arch/h8300/include/asm/socket.h              |    3 ++
 arch/ia64/include/asm/socket.h               |    3 ++
 arch/m32r/include/asm/socket.h               |    3 ++
 arch/m68k/include/asm/socket.h               |    3 ++
 arch/mips/include/asm/socket.h               |    3 ++
 arch/mn10300/include/asm/socket.h            |    3 ++
 arch/parisc/include/asm/socket.h             |    4 +++
 arch/powerpc/include/asm/socket.h            |    3 ++
 arch/s390/include/asm/socket.h               |    3 ++
 arch/sparc/include/asm/socket.h              |    4 +++
 arch/xtensa/include/asm/socket.h             |    3 ++
 include/asm-generic/socket.h                 |    4 +++
 include/linux/netdev_features.h              |    2 +
 include/linux/skbuff.h                       |    4 ++-
 include/net/sock.h                           |    4 +++
 net/core/ethtool.c                           |    1 +
 net/core/skbuff.c                            |    1 +
 net/core/sock.c                              |    4 +++
 net/packet/af_packet.c                       |   32 ++++++++++++++++++++++---
 25 files changed, 106 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/netdev-features.txt b/Documentation/networking/netdev-features.txt
index 7d27812..0bc0d37 100644
--- a/Documentation/networking/netdev-features.txt
+++ b/Documentation/networking/netdev-features.txt
@@ -158,3 +158,12 @@ VLANs. This may be not useful, though.]
 This requests that the NIC append the Ethernet Frame Checksum (FCS)
 to the end of the skb data.  This allows sniffers and other tools to
 read the CRC recorded by the NIC on receipt of the packet.
+
+*  no-fcs
+
+This requests that the NIC not calculated the Ethernet Frame Checksum (FCS)
+for packets flagged to use this feature.  Instead, the NIC will use the last
+4 bytes of the skb data as the FCS.  This allows user-space to create packets
+with custom (including mal-formed) Ethernet FCS.  Probably most useful for
+sniffers.  Note that in addition to enabling this device flag, a socket option
+or similar must be used to flag specific SKBs as wanting to use this behaviour.
diff --git a/arch/alpha/include/asm/socket.h b/arch/alpha/include/asm/socket.h
index 082355f..87ba870 100644
--- a/arch/alpha/include/asm/socket.h
+++ b/arch/alpha/include/asm/socket.h
@@ -72,6 +72,9 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/arm/include/asm/socket.h b/arch/arm/include/asm/socket.h
index dec6f9a..ea7629e 100644
--- a/arch/arm/include/asm/socket.h
+++ b/arch/arm/include/asm/socket.h
@@ -65,4 +65,7 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/avr32/include/asm/socket.h b/arch/avr32/include/asm/socket.h
index 247b88c..6d2e448 100644
--- a/arch/avr32/include/asm/socket.h
+++ b/arch/avr32/include/asm/socket.h
@@ -65,4 +65,7 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* __ASM_AVR32_SOCKET_H */
diff --git a/arch/cris/include/asm/socket.h b/arch/cris/include/asm/socket.h
index e269264..9ba1079 100644
--- a/arch/cris/include/asm/socket.h
+++ b/arch/cris/include/asm/socket.h
@@ -67,6 +67,9 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* _ASM_SOCKET_H */
 
 
diff --git a/arch/frv/include/asm/socket.h b/arch/frv/include/asm/socket.h
index ce80fda..ff8a4c3 100644
--- a/arch/frv/include/asm/socket.h
+++ b/arch/frv/include/asm/socket.h
@@ -65,5 +65,8 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* _ASM_SOCKET_H */
 
diff --git a/arch/h8300/include/asm/socket.h b/arch/h8300/include/asm/socket.h
index cf1daab..8be2267 100644
--- a/arch/h8300/include/asm/socket.h
+++ b/arch/h8300/include/asm/socket.h
@@ -65,4 +65,7 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/ia64/include/asm/socket.h b/arch/ia64/include/asm/socket.h
index 4b03664..17664c9 100644
--- a/arch/ia64/include/asm/socket.h
+++ b/arch/ia64/include/asm/socket.h
@@ -74,4 +74,7 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* _ASM_IA64_SOCKET_H */
diff --git a/arch/m32r/include/asm/socket.h b/arch/m32r/include/asm/socket.h
index e8b8c5b..20de3ac 100644
--- a/arch/m32r/include/asm/socket.h
+++ b/arch/m32r/include/asm/socket.h
@@ -65,4 +65,7 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* _ASM_M32R_SOCKET_H */
diff --git a/arch/m68k/include/asm/socket.h b/arch/m68k/include/asm/socket.h
index d4708ce..98bf770 100644
--- a/arch/m68k/include/asm/socket.h
+++ b/arch/m68k/include/asm/socket.h
@@ -65,4 +65,7 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/mips/include/asm/socket.h b/arch/mips/include/asm/socket.h
index ad5c0a7..d97c83a 100644
--- a/arch/mips/include/asm/socket.h
+++ b/arch/mips/include/asm/socket.h
@@ -85,6 +85,9 @@ To add: #define SO_REUSEPORT 0x0200	/* Allow local address and port reuse.  */
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #ifdef __KERNEL__
 
 /** sock_type - Socket types
diff --git a/arch/mn10300/include/asm/socket.h b/arch/mn10300/include/asm/socket.h
index 876356d..545cbbe 100644
--- a/arch/mn10300/include/asm/socket.h
+++ b/arch/mn10300/include/asm/socket.h
@@ -65,4 +65,7 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/parisc/include/asm/socket.h b/arch/parisc/include/asm/socket.h
index d28c51b..15d2d90 100644
--- a/arch/parisc/include/asm/socket.h
+++ b/arch/parisc/include/asm/socket.h
@@ -64,6 +64,10 @@
 #define SO_WIFI_STATUS		0x4022
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		0x4023
+
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
diff --git a/arch/powerpc/include/asm/socket.h b/arch/powerpc/include/asm/socket.h
index 2fc2af8..29bbe62 100644
--- a/arch/powerpc/include/asm/socket.h
+++ b/arch/powerpc/include/asm/socket.h
@@ -72,4 +72,7 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
diff --git a/arch/s390/include/asm/socket.h b/arch/s390/include/asm/socket.h
index 67b5c1b..237b1e7 100644
--- a/arch/s390/include/asm/socket.h
+++ b/arch/s390/include/asm/socket.h
@@ -73,4 +73,7 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* _ASM_SOCKET_H */
diff --git a/arch/sparc/include/asm/socket.h b/arch/sparc/include/asm/socket.h
index 8af1b64..18d523a 100644
--- a/arch/sparc/include/asm/socket.h
+++ b/arch/sparc/include/asm/socket.h
@@ -61,6 +61,10 @@
 #define SO_WIFI_STATUS		0x0025
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		0x0026
+
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
diff --git a/arch/xtensa/include/asm/socket.h b/arch/xtensa/include/asm/socket.h
index bb06968..00af4e6 100644
--- a/arch/xtensa/include/asm/socket.h
+++ b/arch/xtensa/include/asm/socket.h
@@ -76,4 +76,7 @@
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS		SO_WIFI_STATUS
 
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif	/* _XTENSA_SOCKET_H */
diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 49c1704..3c59235 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -67,4 +67,8 @@
 
 #define SO_WIFI_STATUS		41
 #define SCM_WIFI_STATUS	SO_WIFI_STATUS
+
+/* Instruct lower device to use last 4-bytes of skb data as FCS */
+#define SO_NOFCS		42
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index d133186..3bae320 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -55,6 +55,7 @@ enum {
 	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
 	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
 	NETIF_F_RXFCS_BIT,		/* Append FCS to skb pkt data */
+	NETIF_F_NOFCS_BIT,		/* Use last 4 bytes of skb as tx FCS */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -100,6 +101,7 @@ enum {
 #define NETIF_F_UFO		__NETIF_F(UFO)
 #define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
+#define NETIF_F_NOFCS		__NETIF_F(NOFCS)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 50db9b0..cc614a9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -361,6 +361,7 @@ typedef unsigned char *sk_buff_data_t;
  *		ports.
  *	@wifi_acked_valid: wifi_acked was set
  *	@wifi_acked: whether frame was acked on wifi or not
+ *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
  *	@secmark: security marking
@@ -456,7 +457,8 @@ struct sk_buff {
 	__u8			l4_rxhash:1;
 	__u8			wifi_acked_valid:1;
 	__u8			wifi_acked:1;
-	/* 10/12 bit hole (depending on ndisc_nodetype presence) */
+	__u8			no_fcs:1;
+	/* 9/11 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #ifdef CONFIG_NET_DMA
diff --git a/include/net/sock.h b/include/net/sock.h
index 91c1c8b..5d8ecbc 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -590,6 +590,10 @@ enum sock_flags {
 	SOCK_RXQ_OVFL,
 	SOCK_ZEROCOPY, /* buffers from userspace */
 	SOCK_WIFI_STATUS, /* push wifi status to userspace */
+	SOCK_NOFCS, /* Tell NIC not to do the Ethernet FCS.
+		     * Will use last 4 bytes of packet sent from
+		     * user-space instead.
+		     */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 0801619..cf81ccf 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -74,6 +74,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_NOCACHE_COPY_BIT] =     "tx-nocache-copy",
 	[NETIF_F_LOOPBACK_BIT] =         "loopback",
 	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
+	[NETIF_F_NOFCS_BIT] =            "no-fcs",
 };
 
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index da0c97f..36e7b7c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -592,6 +592,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->rxhash		= old->rxhash;
 	new->ooo_okay		= old->ooo_okay;
 	new->l4_rxhash		= old->l4_rxhash;
+	new->no_fcs		= old->no_fcs;
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
diff --git a/net/core/sock.c b/net/core/sock.c
index 3e81fd2..1db3096 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -793,6 +793,10 @@ set_rcvbuf:
 		sock_valbool_flag(sk, SOCK_WIFI_STATUS, valbool);
 		break;
 
+	case SO_NOFCS:
+		sock_valbool_flag(sk, SOCK_NOFCS, valbool);
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2dbb32b..f4c833e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1459,6 +1459,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	struct net_device *dev;
 	__be16 proto = 0;
 	int err;
+	int extra_len = 0;
 
 	/*
 	 *	Get and verify the address.
@@ -1493,8 +1494,16 @@ retry:
 	 * raw protocol and you must do your own fragmentation at this level.
 	 */
 
+	if (unlikely(sock_flag(sk, SOCK_NOFCS))) {
+		if (!(dev->features & NETIF_F_NOFCS)) {
+			err = -EINVAL;
+			goto out_unlock;
+		}
+		extra_len = 4; /* We're doing our own CRC */
+	}
+
 	err = -EMSGSIZE;
-	if (len > dev->mtu + dev->hard_header_len + VLAN_HLEN)
+	if (len > dev->mtu + dev->hard_header_len + VLAN_HLEN + extra_len)
 		goto out_unlock;
 
 	if (!skb) {
@@ -1526,7 +1535,7 @@ retry:
 		goto retry;
 	}
 
-	if (len > (dev->mtu + dev->hard_header_len)) {
+	if (len > (dev->mtu + dev->hard_header_len + extra_len)) {
 		/* Earlier code assumed this would be a VLAN pkt,
 		 * double-check this now that we have the actual
 		 * packet in hand.
@@ -1548,6 +1557,9 @@ retry:
 	if (err < 0)
 		goto out_unlock;
 
+	if (unlikely(extra_len == 4))
+		skb->no_fcs = 1;
+
 	dev_queue_xmit(skb);
 	rcu_read_unlock();
 	return len;
@@ -2209,6 +2221,7 @@ static int packet_snd(struct socket *sock,
 	struct packet_sock *po = pkt_sk(sk);
 	unsigned short gso_type = 0;
 	int hlen, tlen;
+	int extra_len = 0;
 
 	/*
 	 *	Get and verify the address.
@@ -2288,8 +2301,16 @@ static int packet_snd(struct socket *sock,
 		}
 	}
 
+	if (unlikely(sock_flag(sk, SOCK_NOFCS))) {
+		if (!(dev->features & NETIF_F_NOFCS)) {
+			err = -EINVAL;
+			goto out_unlock;
+		}
+		extra_len = 4; /* We're doing our own CRC */
+	}
+
 	err = -EMSGSIZE;
-	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN))
+	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN + extra_len))
 		goto out_unlock;
 
 	err = -ENOBUFS;
@@ -2315,7 +2336,7 @@ static int packet_snd(struct socket *sock,
 	if (err < 0)
 		goto out_free;
 
-	if (!gso_type && (len > dev->mtu + reserve)) {
+	if (!gso_type && (len > dev->mtu + reserve + extra_len)) {
 		/* Earlier code assumed this would be a VLAN pkt,
 		 * double-check this now that we have the actual
 		 * packet in hand.
@@ -2353,6 +2374,9 @@ static int packet_snd(struct socket *sock,
 		len += vnet_hdr_len;
 	}
 
+	if (unlikely(extra_len == 4))
+		skb->no_fcs = 1;
+
 	/*
 	 *	Now send it
 	 */
-- 
1.7.3.4
