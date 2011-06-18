From: greearb@candelatech.com
Subject: [RFC 4/5] net:  Support sending frame with specified FCS.
Date: Fri, 17 Jun 2011 17:09:42 -0700
Message-ID: <1308355783-22407-5-git-send-email-greearb@candelatech.com>
References: <1308355783-22407-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45566 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695Ab1FRAKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 20:10:53 -0400
In-Reply-To: <1308355783-22407-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows user-space to send a packet with the
ethernet FCS appended to the end.  Supporting NICs
will know to disable their own FCS calculations and
send frame as is.

This is useful for injecting bad frames on a network
for testing.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 9a6115e... 22193a2... M	include/asm-generic/socket.h
:100644 100644 c0a4f3a... 05b15be... M	include/linux/skbuff.h
:100644 100644 f2046e4... d7e0d88... M	include/net/sock.h
:100644 100644 46cbd28... a552560... M	net/core/skbuff.c
:100644 100644 6e81978... 0c5f827... M	net/core/sock.c
:100644 100644 c0c3cda... 0d29d68... M	net/packet/af_packet.c
 include/asm-generic/socket.h |    7 +++++++
 include/linux/skbuff.h       |    5 ++++-
 include/net/sock.h           |    6 ++++++
 net/core/skbuff.c            |    1 +
 net/core/sock.c              |    7 +++++++
 net/packet/af_packet.c       |   22 ++++++++++++++++++++--
 6 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
index 9a6115e..22193a2 100644
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -64,4 +64,11 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+
+/* Instruct lower device to not calculate the frame
+ * checksum.  Useful for generating Ethernet frames
+ * with custom checksums.
+ */
+#define SO_NOFCS		41
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c0a4f3a..05b15be 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -307,6 +307,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@peeked: this packet has been seen already, so stats have been
  *		done for it, don't do them again
  *	@nf_trace: netfilter packet trace flag
+ *	@use_specified_ether_crc: skb is Ethernet frame with FCS already
+ *		appended.  Use that FCS.  Requires special support in NIC.
  *	@nfctinfo: Relationship of this skb to the connection
  *	@nfct_reasm: netfilter conntrack re-assembly pointer
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
@@ -396,7 +398,8 @@ struct sk_buff {
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	__u8			ndisc_nodetype:2;
 #endif
-	__u8			ooo_okay:1;
+	__u8			ooo_okay:1,
+				use_specified_ether_crc:1;
 	kmemcheck_bitfield_end(flags2);
 
 	/* 0/13 bit hole */
diff --git a/include/net/sock.h b/include/net/sock.h
index f2046e4..d7e0d88 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -563,6 +563,12 @@ enum sock_flags {
 	SOCK_TIMESTAMPING_SYS_HARDWARE, /* %SOF_TIMESTAMPING_SYS_HARDWARE */
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
+	SOCK_DONT_DO_LL_FCS, /* Tell NIC not to do the Ethernet FCS.
+			      * Will use last 4 bytes of packet sent from
+			      * user-space instead.  Requires special
+			      * support in NIC.
+			      */
+
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 46cbd28..a552560 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -541,6 +541,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->tc_verd		= old->tc_verd;
 #endif
 #endif
+	new->use_specified_ether_crc = old->use_specified_ether_crc;
 	new->vlan_tci		= old->vlan_tci;
 
 	skb_copy_secmark(new, old);
diff --git a/net/core/sock.c b/net/core/sock.c
index 6e81978..0c5f827 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -641,6 +641,13 @@ set_rcvbuf:
 		sock_warn_obsolete_bsdism("setsockopt");
 		break;
 
+	case SO_NOFCS:
+		if (valbool)
+			sk->sk_flags |= SOCK_DONT_DO_LL_FCS;
+		else
+			sk->sk_flags &= ~(SOCK_DONT_DO_LL_FCS);
+		break;
+
 	case SO_PASSCRED:
 		if (valbool)
 			set_bit(SOCK_PASSCRED, &sock->flags);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c0c3cda..0d29d68 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -430,6 +430,10 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	struct net_device *dev;
 	__be16 proto = 0;
 	int err;
+	int kludge = 0;
+
+	if (unlikely(sk->sk_flags & SOCK_DONT_DO_LL_FCS))
+		kludge = 4; /* We're doing our own FCS */
 
 	/*
 	 *	Get and verify the address.
@@ -465,7 +469,7 @@ retry:
 	 */
 
 	err = -EMSGSIZE;
-	if (len > dev->mtu + dev->hard_header_len + VLAN_HLEN)
+	if (len > dev->mtu + dev->hard_header_len + VLAN_HLEN + kludge)
 		goto out_unlock;
 
 	if (!skb) {
@@ -518,6 +522,11 @@ retry:
 	if (err < 0)
 		goto out_unlock;
 
+	if (unlikely(sk->sk_flags & SOCK_DONT_DO_LL_FCS))
+		skb->use_specified_ether_crc = 1;
+	else
+		skb->use_specified_ether_crc = 0;
+
 	dev_queue_xmit(skb);
 	rcu_read_unlock();
 	return len;
@@ -1134,6 +1143,10 @@ static int packet_snd(struct socket *sock,
 	int vnet_hdr_len;
 	struct packet_sock *po = pkt_sk(sk);
 	unsigned short gso_type = 0;
+	int kludge = 0;
+
+	if (unlikely(sk->sk_flags & SOCK_DONT_DO_LL_FCS))
+		kludge = 4; /* We're doing our own Ethernet FCS */
 
 	/*
 	 *	Get and verify the address.
@@ -1215,7 +1228,7 @@ static int packet_snd(struct socket *sock,
 	}
 
 	err = -EMSGSIZE;
-	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN))
+	if (!gso_type && (len > dev->mtu + reserve + VLAN_HLEN + kludge))
 		goto out_unlock;
 
 	err = -ENOBUFS;
@@ -1278,6 +1291,11 @@ static int packet_snd(struct socket *sock,
 		len += vnet_hdr_len;
 	}
 
+	if (unlikely(sk->sk_flags & SOCK_DONT_DO_LL_FCS))
+		skb->use_specified_ether_crc = 1;
+	else
+		skb->use_specified_ether_crc = 0;
+
 	/*
 	 *	Now send it
 	 */
-- 
1.7.3.4

