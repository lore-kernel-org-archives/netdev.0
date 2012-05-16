From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 3/4] net: delete all instances of special processing for token ring
Date: Tue, 15 May 2012 20:35:43 -0400
Message-ID: <1337128544-18680-4-git-send-email-paul.gortmaker@windriver.com>
References: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44439 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967099Ab2EPAgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 20:36:31 -0400
In-Reply-To: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are going to delete the Token ring support.  This removes any
special processing in the core networking for token ring, (aside
from net/tr.c itself), leaving the drivers and remaining tokenring
support present but inert.

The mass removal of the drivers and net/tr.c will be in a separate
commit, so that the history of these files that we still care
about won't have the giant deletion tied into their history.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/if_arp.h |    2 +-
 include/linux/ipx.h    |    2 +-
 include/net/if_inet6.h |   54 ------------------------------------------------
 include/net/ip.h       |   17 ---------------
 include/net/llc_pdu.h  |    7 ------
 net/802/p8022.c        |    3 +-
 net/802/tr.c           |    1 -
 net/core/dev.c         |   14 +++++-------
 net/ipv4/Kconfig       |    4 +-
 net/ipv4/arp.c         |   13 +----------
 net/ipv4/ipconfig.c    |    2 -
 net/ipv6/addrconf.c    |    2 -
 net/ipv6/ndisc.c       |   17 ---------------
 net/ipx/af_ipx.c       |   10 +--------
 net/llc/af_llc.c       |    3 +-
 net/llc/llc_output.c   |    3 --
 net/llc/llc_sap.c      |    4 ---
 net/sysctl_net.c       |    4 ---
 18 files changed, 14 insertions(+), 148 deletions(-)

diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 6d722f4..3718acf 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -82,7 +82,7 @@
 #define ARPHRD_FCPL	786		/* Fibrechannel public loop	*/
 #define ARPHRD_FCFABRIC	787		/* Fibrechannel fabric		*/
 	/* 787->799 reserved for fibrechannel media types */
-#define ARPHRD_IEEE802_TR 800		/* Magic type ident for TR	*/
+/* 800 used to be used for token ring */
 #define ARPHRD_IEEE80211 801		/* IEEE 802.11			*/
 #define ARPHRD_IEEE80211_PRISM 802	/* IEEE 802.11 + Prism2 header  */
 #define ARPHRD_IEEE80211_RADIOTAP 803	/* IEEE 802.11 + radiotap header */
diff --git a/include/linux/ipx.h b/include/linux/ipx.h
index 3d48014..8f02439 100644
--- a/include/linux/ipx.h
+++ b/include/linux/ipx.h
@@ -38,7 +38,7 @@ struct ipx_interface_definition {
 #define IPX_FRAME_8022		2
 #define IPX_FRAME_ETHERII	3
 #define IPX_FRAME_8023		4
-#define IPX_FRAME_TR_8022       5 /* obsolete */
+/* obsolete token ring was	5 */
 	unsigned char ipx_special;
 #define IPX_SPECIAL_NONE	0
 #define IPX_PRIMARY		1
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 50f325f..9356322 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -209,60 +209,6 @@ static inline void ipv6_eth_mc_map(const struct in6_addr *addr, char *buf)
 	memcpy(buf + 2, &addr->s6_addr32[3], sizeof(__u32));
 }
 
-static inline void ipv6_tr_mc_map(const struct in6_addr *addr, char *buf)
-{
-	/* All nodes FF01::1, FF02::1, FF02::1:FFxx:xxxx */
-
-	if (((addr->s6_addr[0] == 0xFF) &&
-	    ((addr->s6_addr[1] == 0x01) || (addr->s6_addr[1] == 0x02)) &&
-	     (addr->s6_addr16[1] == 0) &&
-	     (addr->s6_addr32[1] == 0) &&
-	     (addr->s6_addr32[2] == 0) &&
-	     (addr->s6_addr16[6] == 0) &&
-	     (addr->s6_addr[15] == 1)) ||
-	    ((addr->s6_addr[0] == 0xFF) &&
-	     (addr->s6_addr[1] == 0x02) &&
-	     (addr->s6_addr16[1] == 0) &&
-	     (addr->s6_addr32[1] == 0) &&
-	     (addr->s6_addr16[4] == 0) &&
-	     (addr->s6_addr[10] == 0) &&
-	     (addr->s6_addr[11] == 1) &&
-	     (addr->s6_addr[12] == 0xff)))
-	{
-		buf[0]=0xC0;
-		buf[1]=0x00;
-		buf[2]=0x01;
-		buf[3]=0x00;
-		buf[4]=0x00;
-		buf[5]=0x00;
-	/* All routers FF0x::2 */
-	} else if ((addr->s6_addr[0] ==0xff) &&
-		((addr->s6_addr[1] & 0xF0) == 0) &&
-		(addr->s6_addr16[1] == 0) &&
-		(addr->s6_addr32[1] == 0) &&
-		(addr->s6_addr32[2] == 0) &&
-		(addr->s6_addr16[6] == 0) &&
-		(addr->s6_addr[15] == 2))
-	{
-		buf[0]=0xC0;
-		buf[1]=0x00;
-		buf[2]=0x02;
-		buf[3]=0x00;
-		buf[4]=0x00;
-		buf[5]=0x00;
-	} else {
-		unsigned char i ; 
-		
-		i = addr->s6_addr[15] & 7 ; 
-		buf[0]=0xC0;
-		buf[1]=0x00;
-		buf[2]=0x00;
-		buf[3]=0x01 << i ; 
-		buf[4]=0x00;
-		buf[5]=0x00;
-	}
-}
-
 static inline void ipv6_arcnet_mc_map(const struct in6_addr *addr, char *buf)
 {
 	buf[0] = 0x00;
diff --git a/include/net/ip.h b/include/net/ip.h
index 94ddb69c..83e0619 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -141,23 +141,6 @@ static inline struct sk_buff *ip_finish_skb(struct sock *sk, struct flowi4 *fl4)
 extern int		ip4_datagram_connect(struct sock *sk, 
 					     struct sockaddr *uaddr, int addr_len);
 
-/*
- *	Map a multicast IP onto multicast MAC for type Token Ring.
- *      This conforms to RFC1469 Option 2 Multicasting i.e.
- *      using a functional address to transmit / receive 
- *      multicast packets.
- */
-
-static inline void ip_tr_mc_map(__be32 addr, char *buf)
-{
-	buf[0]=0xC0;
-	buf[1]=0x00;
-	buf[2]=0x00;
-	buf[3]=0x04;
-	buf[4]=0x00;
-	buf[5]=0x00;
-}
-
 struct ip_reply_arg {
 	struct kvec iov[1];   
 	int	    flags;
diff --git a/include/net/llc_pdu.h b/include/net/llc_pdu.h
index f57e7d4..5a93d13 100644
--- a/include/net/llc_pdu.h
+++ b/include/net/llc_pdu.h
@@ -13,7 +13,6 @@
  */
 
 #include <linux/if_ether.h>
-#include <linux/if_tr.h>
 
 /* Lengths of frame formats */
 #define LLC_PDU_LEN_I	4       /* header and 2 control bytes */
@@ -253,10 +252,6 @@ static inline void llc_pdu_decode_sa(struct sk_buff *skb, u8 *sa)
 {
 	if (skb->protocol == htons(ETH_P_802_2))
 		memcpy(sa, eth_hdr(skb)->h_source, ETH_ALEN);
-	else if (skb->protocol == htons(ETH_P_TR_802_2)) {
-		memcpy(sa, tr_hdr(skb)->saddr, ETH_ALEN);
-		*sa &= 0x7F;
-	}
 }
 
 /**
@@ -270,8 +265,6 @@ static inline void llc_pdu_decode_da(struct sk_buff *skb, u8 *da)
 {
 	if (skb->protocol == htons(ETH_P_802_2))
 		memcpy(da, eth_hdr(skb)->h_dest, ETH_ALEN);
-	else if (skb->protocol == htons(ETH_P_TR_802_2))
-		memcpy(da, tr_hdr(skb)->daddr, ETH_ALEN);
 }
 
 /**
diff --git a/net/802/p8022.c b/net/802/p8022.c
index 7f353c4..0bda8de 100644
--- a/net/802/p8022.c
+++ b/net/802/p8022.c
@@ -1,6 +1,5 @@
 /*
- *	NET3:	Support for 802.2 demultiplexing off Ethernet (Token ring
- *		is kept separate see p8022tr.c)
+ *	NET3:	Support for 802.2 demultiplexing off Ethernet
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
  *		as published by the Free Software Foundation; either version
diff --git a/net/802/tr.c b/net/802/tr.c
index 30a352e..175243b 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -604,7 +604,6 @@ static void tr_setup(struct net_device *dev)
 
 	dev->header_ops	= &tr_header_ops;
 
-	dev->type		= ARPHRD_IEEE802_TR;
 	dev->hard_header_len	= TR_HLEN;
 	dev->mtu		= 2000;
 	dev->addr_len		= TR_ALEN;
diff --git a/net/core/dev.c b/net/core/dev.c
index 3dd8539..66cae6e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -300,10 +300,9 @@ static const unsigned short netdev_lock_type[] =
 	 ARPHRD_BIF, ARPHRD_SIT, ARPHRD_IPDDP, ARPHRD_IPGRE,
 	 ARPHRD_PIMREG, ARPHRD_HIPPI, ARPHRD_ASH, ARPHRD_ECONET,
 	 ARPHRD_IRDA, ARPHRD_FCPP, ARPHRD_FCAL, ARPHRD_FCPL,
-	 ARPHRD_FCFABRIC, ARPHRD_IEEE802_TR, ARPHRD_IEEE80211,
-	 ARPHRD_IEEE80211_PRISM, ARPHRD_IEEE80211_RADIOTAP, ARPHRD_PHONET,
-	 ARPHRD_PHONET_PIPE, ARPHRD_IEEE802154,
-	 ARPHRD_VOID, ARPHRD_NONE};
+	 ARPHRD_FCFABRIC, ARPHRD_IEEE80211, ARPHRD_IEEE80211_PRISM,
+	 ARPHRD_IEEE80211_RADIOTAP, ARPHRD_PHONET, ARPHRD_PHONET_PIPE,
+	 ARPHRD_IEEE802154, ARPHRD_VOID, ARPHRD_NONE};
 
 static const char *const netdev_lock_name[] =
 	{"_xmit_NETROM", "_xmit_ETHER", "_xmit_EETHER", "_xmit_AX25",
@@ -318,10 +317,9 @@ static const char *const netdev_lock_name[] =
 	 "_xmit_BIF", "_xmit_SIT", "_xmit_IPDDP", "_xmit_IPGRE",
 	 "_xmit_PIMREG", "_xmit_HIPPI", "_xmit_ASH", "_xmit_ECONET",
 	 "_xmit_IRDA", "_xmit_FCPP", "_xmit_FCAL", "_xmit_FCPL",
-	 "_xmit_FCFABRIC", "_xmit_IEEE802_TR", "_xmit_IEEE80211",
-	 "_xmit_IEEE80211_PRISM", "_xmit_IEEE80211_RADIOTAP", "_xmit_PHONET",
-	 "_xmit_PHONET_PIPE", "_xmit_IEEE802154",
-	 "_xmit_VOID", "_xmit_NONE"};
+	 "_xmit_FCFABRIC", "_xmit_IEEE80211", "_xmit_IEEE80211_PRISM",
+	 "_xmit_IEEE80211_RADIOTAP", "_xmit_PHONET", "_xmit_PHONET_PIPE",
+	 "_xmit_IEEE802154", "_xmit_VOID", "_xmit_NONE"};
 
 static struct lock_class_key netdev_xmit_lock_key[ARRAY_SIZE(netdev_lock_type)];
 static struct lock_class_key netdev_addr_lock_key[ARRAY_SIZE(netdev_lock_type)];
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 2c8febd..20f1cb5 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -262,8 +262,8 @@ config ARPD
 	bool "IP: ARP daemon support"
 	---help---
 	  The kernel maintains an internal cache which maps IP addresses to
-	  hardware addresses on the local network, so that Ethernet/Token Ring/
-	  etc. frames are sent to the proper address on the physical networking
+	  hardware addresses on the local network, so that Ethernet
+	  frames are sent to the proper address on the physical networking
 	  layer. Normally, kernel uses the ARP protocol to resolve these
 	  mappings.
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 373b56b..5097571 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -89,7 +89,6 @@
 #include <linux/etherdevice.h>
 #include <linux/fddidevice.h>
 #include <linux/if_arp.h>
-#include <linux/trdevice.h>
 #include <linux/skbuff.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -193,9 +192,6 @@ int arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir)
 	case ARPHRD_IEEE802:
 		ip_eth_mc_map(addr, haddr);
 		return 0;
-	case ARPHRD_IEEE802_TR:
-		ip_tr_mc_map(addr, haddr);
-		return 0;
 	case ARPHRD_INFINIBAND:
 		ip_ib_mc_map(addr, dev->broadcast, haddr);
 		return 0;
@@ -648,12 +644,6 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 		arp->ar_pro = htons(ETH_P_IP);
 		break;
 #endif
-#if IS_ENABLED(CONFIG_TR)
-	case ARPHRD_IEEE802_TR:
-		arp->ar_hrd = htons(ARPHRD_IEEE802);
-		arp->ar_pro = htons(ETH_P_IP);
-		break;
-#endif
 	}
 
 	arp->ar_hln = dev->addr_len;
@@ -751,11 +741,10 @@ static int arp_process(struct sk_buff *skb)
 			goto out;
 		break;
 	case ARPHRD_ETHER:
-	case ARPHRD_IEEE802_TR:
 	case ARPHRD_FDDI:
 	case ARPHRD_IEEE802:
 		/*
-		 * ETHERNET, Token Ring and Fibre Channel (which are IEEE 802
+		 * ETHERNET, and Fibre Channel (which are IEEE 802
 		 * devices, according to RFC 2625) devices will accept ARP
 		 * hardware types of either 1 (Ethernet) or 6 (IEEE 802.2).
 		 * This is the case also of FDDI, where the RFC 1390 says that
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 24a3df9..4300150 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -808,8 +808,6 @@ static void __init ic_bootp_send_if(struct ic_device *d, unsigned long jiffies_d
 	b->op = BOOTP_REQUEST;
 	if (dev->type < 256) /* check for false types */
 		b->htype = dev->type;
-	else if (dev->type == ARPHRD_IEEE802_TR) /* fix for token ring */
-		b->htype = ARPHRD_IEEE802;
 	else if (dev->type == ARPHRD_FDDI)
 		b->htype = ARPHRD_ETHER;
 	else {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4d1d51a..f6b5b8a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1575,7 +1575,6 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 	switch (dev->type) {
 	case ARPHRD_ETHER:
 	case ARPHRD_FDDI:
-	case ARPHRD_IEEE802_TR:
 		return addrconf_ifid_eui48(eui, dev);
 	case ARPHRD_ARCNET:
 		return addrconf_ifid_arcnet(eui, dev);
@@ -2444,7 +2443,6 @@ static void addrconf_dev_config(struct net_device *dev)
 
 	if ((dev->type != ARPHRD_ETHER) &&
 	    (dev->type != ARPHRD_FDDI) &&
-	    (dev->type != ARPHRD_IEEE802_TR) &&
 	    (dev->type != ARPHRD_ARCNET) &&
 	    (dev->type != ARPHRD_INFINIBAND) &&
 	    (dev->type != ARPHRD_IEEE802154)) {
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 35615c6..56963f1 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -327,9 +327,6 @@ int ndisc_mc_map(const struct in6_addr *addr, char *buf, struct net_device *dev,
 	case ARPHRD_FDDI:
 		ipv6_eth_mc_map(addr, buf);
 		return 0;
-	case ARPHRD_IEEE802_TR:
-		ipv6_tr_mc_map(addr,buf);
-		return 0;
 	case ARPHRD_ARCNET:
 		ipv6_arcnet_mc_map(addr, buf);
 		return 0;
@@ -795,20 +792,6 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 
 		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
 			if (dad) {
-				if (dev->type == ARPHRD_IEEE802_TR) {
-					const unsigned char *sadr;
-					sadr = skb_mac_header(skb);
-					if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
-					    sadr[9] == dev->dev_addr[1] &&
-					    sadr[10] == dev->dev_addr[2] &&
-					    sadr[11] == dev->dev_addr[3] &&
-					    sadr[12] == dev->dev_addr[4] &&
-					    sadr[13] == dev->dev_addr[5]) {
-						/* looped-back to us */
-						goto out;
-					}
-				}
-
 				/*
 				 * We are colliding with another node
 				 * who is doing DAD
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 9680226..824d4a3 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -983,10 +983,6 @@ static int ipxitf_create(struct ipx_interface_definition *idef)
 		goto out;
 
 	switch (idef->ipx_dlink_type) {
-	case IPX_FRAME_TR_8022:
-		printk(KERN_WARNING "IPX frame type 802.2TR is "
-			"obsolete Use 802.2 instead.\n");
-		/* fall through */
 	case IPX_FRAME_8022:
 		dlink_type 	= htons(ETH_P_802_2);
 		datalink 	= p8022_datalink;
@@ -996,10 +992,7 @@ static int ipxitf_create(struct ipx_interface_definition *idef)
 			dlink_type 	= htons(ETH_P_IPX);
 			datalink 	= pEII_datalink;
 			break;
-		} else
-			printk(KERN_WARNING "IPX frame type EtherII over "
-					"token-ring is obsolete. Use SNAP "
-					"instead.\n");
+		}
 		/* fall through */
 	case IPX_FRAME_SNAP:
 		dlink_type 	= htons(ETH_P_SNAP);
@@ -1275,7 +1268,6 @@ const char *ipx_frame_name(__be16 frame)
 	case ETH_P_802_2:	rc = "802.2";	break;
 	case ETH_P_SNAP:	rc = "SNAP";	break;
 	case ETH_P_802_3:	rc = "802.3";	break;
-	case ETH_P_TR_802_2:	rc = "802.2TR";	break;
 	}
 
 	return rc;
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 78424f4..e944075 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -71,8 +71,7 @@ static inline u16 llc_ui_next_link_no(int sap)
  */
 static inline __be16 llc_proto_type(u16 arphrd)
 {
-	return arphrd == ARPHRD_IEEE802_TR ?
-			 htons(ETH_P_TR_802_2) : htons(ETH_P_802_2);
+	return htons(ETH_P_802_2);
 }
 
 /**
diff --git a/net/llc/llc_output.c b/net/llc/llc_output.c
index b658cba..2dae8a5 100644
--- a/net/llc/llc_output.c
+++ b/net/llc/llc_output.c
@@ -14,9 +14,7 @@
  */
 
 #include <linux/if_arp.h>
-#include <linux/if_tr.h>
 #include <linux/netdevice.h>
-#include <linux/trdevice.h>
 #include <linux/skbuff.h>
 #include <linux/export.h>
 #include <net/llc.h>
@@ -37,7 +35,6 @@ int llc_mac_hdr_init(struct sk_buff *skb,
 	int rc = -EINVAL;
 
 	switch (skb->dev->type) {
-	case ARPHRD_IEEE802_TR:
 	case ARPHRD_ETHER:
 	case ARPHRD_LOOPBACK:
 		rc = dev_hard_header(skb, skb->dev, ETH_P_802_2, da, sa,
diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index 94e7fca..7c5073b 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -31,10 +31,6 @@ static int llc_mac_header_len(unsigned short devtype)
 	case ARPHRD_ETHER:
 	case ARPHRD_LOOPBACK:
 		return sizeof(struct ethhdr);
-#if defined(CONFIG_TR) || defined(CONFIG_TR_MODULE)
-	case ARPHRD_IEEE802_TR:
-		return sizeof(struct trh_hdr);
-#endif
 	}
 	return 0;
 }
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index f3e813a..e3a6e37 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -26,10 +26,6 @@
 #include <linux/if_ether.h>
 #endif
 
-#ifdef CONFIG_TR
-#include <linux/if_tr.h>
-#endif
-
 static struct ctl_table_set *
 net_ctl_header_lookup(struct ctl_table_root *root, struct nsproxy *namespaces)
 {
-- 
1.7.9.1
