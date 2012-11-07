From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: [PATCH net-next v3] packet: tx_ring: allow the user to choose tx data offset
Date: Wed,  7 Nov 2012 10:10:47 +0100
Message-ID: <1352279447-2980-1-git-send-email-paul.chavent@onera.fr>
Cc: Paul Chavent <Paul.Chavent@onera.fr>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:50906 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab2KGIOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 03:14:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tx data offset of packet mmap tx ring used to be :
(TPACKET2_HDRLEN - sizeof(struct sockaddr_ll))

The problem is that, with SOCK_RAW socket, the payload (14 bytes after
the beginning of the user data) is misaligned.

This patch allows to let the user gives an offset for it's tx data if
he desires.

Set sock option PACKET_TX_HAS_OFF to 1, then specify in each frame of
your tx ring tp_net for SOCK_DGRAM, or tp_mac for SOCK_RAW.

Signed-off-by: Paul Chavent <paul.chavent@onera.fr>
---
 Documentation/networking/packet_mmap.txt | 13 +++++++++
 include/uapi/linux/if_packet.h           |  1 +
 net/packet/af_packet.c                   | 46 +++++++++++++++++++++++++++++++-
 net/packet/internal.h                    |  1 +
 4 files changed, 60 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index 1c08a4b..7cd879e 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -163,6 +163,19 @@ As capture, each frame contains two parts:
 
  A complete tutorial is available at: http://wiki.gnu-log.net/
 
+By default, the user should put data at :
+ frame base + TPACKET_HDRLEN - sizeof(struct sockaddr_ll)
+
+So, whatever you choose for the socket mode (SOCK_DGRAM or SOCK_RAW),
+the beginning of the user data will be at :
+ frame base + TPACKET_ALIGN(sizeof(struct tpacket_hdr))
+
+If you wish to put user data at a custom offset from the beginning of
+the frame (for payload alignment with SOCK_RAW mode for instance) you
+can set tp_net (with SOCK_DGRAM) or tp_mac (with SOCK_RAW). In order
+to make this work it must be enabled previously with setsockopt()
+and the PACKET_TX_HAS_OFF option.
+
 --------------------------------------------------------------------------------
 + PACKET_MMAP settings
 --------------------------------------------------------------------------------
diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index f379929..f9a6037 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -50,6 +50,7 @@ struct sockaddr_ll {
 #define PACKET_TX_TIMESTAMP		16
 #define PACKET_TIMESTAMP		17
 #define PACKET_FANOUT			18
+#define PACKET_TX_HAS_OFF		19
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9034f52..f262dbf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1881,7 +1881,35 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
 
-	data = ph.raw + po->tp_hdrlen - sizeof(struct sockaddr_ll);
+	if (po->tp_tx_has_off) {
+		int off_min, off_max, off;
+		off_min = po->tp_hdrlen - sizeof(struct sockaddr_ll);
+		off_max = po->tx_ring.frame_size - tp_len;
+		if (sock->type == SOCK_DGRAM) {
+			switch (po->tp_version) {
+			case TPACKET_V2:
+				off = ph.h2->tp_net;
+				break;
+			default:
+				off = ph.h1->tp_net;
+				break;
+			}
+		} else {
+			switch (po->tp_version) {
+			case TPACKET_V2:
+				off = ph.h2->tp_mac;
+				break;
+			default:
+				off = ph.h1->tp_mac;
+				break;
+			}
+		}
+		if (unlikely((off < off_min) || (off_max < off)))
+			return -EINVAL;
+		data = ph.raw + off;
+	} else {
+		data = ph.raw + po->tp_hdrlen - sizeof(struct sockaddr_ll);
+	}
 	to_write = tp_len;
 
 	if (sock->type == SOCK_DGRAM) {
@@ -3109,6 +3137,19 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 
 		return fanout_add(sk, val & 0xffff, val >> 16);
 	}
+	case PACKET_TX_HAS_OFF:
+	{
+		unsigned int val;
+
+		if (optlen != sizeof(val))
+			return -EINVAL;
+		if (po->rx_ring.pg_vec || po->tx_ring.pg_vec)
+			return -EBUSY;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+		po->tp_tx_has_off = !!val;
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -3200,6 +3241,9 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 			((u32)po->fanout->type << 16)) :
 		       0);
 		break;
+	case PACKET_TX_HAS_OFF:
+		val = po->tp_tx_has_off;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 44945f6..e84cab8 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -109,6 +109,7 @@ struct packet_sock {
 	unsigned int		tp_hdrlen;
 	unsigned int		tp_reserve;
 	unsigned int		tp_loss:1;
+	unsigned int		tp_tx_has_off:1;
 	unsigned int		tp_tstamp;
 	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
 };
-- 
1.7.12.1
