From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: packet: add PACKET_RESERVE sockopt
Date: Fri, 18 Jul 2008 19:57:02 +0200
Message-ID: <4880D96E.4060708@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010604060308050003050902"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59288 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbYGRR5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 13:57:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010604060308050003050902
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------010604060308050003050902
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 4e7a0d5a01de2f1cd07b83e8418feb2eae9d217d
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jul 18 19:56:35 2008 +0200

    packet: add PACKET_RESERVE sockopt
    
    Add new sockopt to reserve some headroom in the mmaped ring frames in
    front of the packet payload. This can be used f.i. when the VLAN header
    needs to be (re)constructed to avoid moving the entire payload.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index a630295..18db066 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -45,6 +45,7 @@ struct sockaddr_ll
 #define PACKET_ORIGDEV			9
 #define PACKET_VERSION			10
 #define PACKET_HDRLEN			11
+#define PACKET_RESERVE			12
 
 struct tpacket_stats
 {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index db792e0..de73bcb 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -188,6 +188,7 @@ struct packet_sock {
 	unsigned int		pg_vec_len;
 	enum tpacket_versions	tp_version;
 	unsigned int		tp_hdrlen;
+	unsigned int		tp_reserve;
 #endif
 };
 
@@ -635,11 +636,13 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 		snaplen = res;
 
 	if (sk->sk_type == SOCK_DGRAM) {
-		macoff = netoff = TPACKET_ALIGN(po->tp_hdrlen) + 16;
+		macoff = netoff = TPACKET_ALIGN(po->tp_hdrlen) + 16 +
+				  po->tp_reserve;
 	} else {
 		unsigned maclen = skb_network_offset(skb);
 		netoff = TPACKET_ALIGN(po->tp_hdrlen +
-				       (maclen < 16 ? 16 : maclen));
+				       (maclen < 16 ? 16 : maclen)) +
+			po->tp_reserve;
 		macoff = netoff - maclen;
 	}
 
@@ -1448,6 +1451,19 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 			return -EINVAL;
 		}
 	}
+	case PACKET_RESERVE:
+	{
+		unsigned int val;
+
+		if (optlen != sizeof(val))
+			return -EINVAL;
+		if (po->pg_vec)
+			return -EBUSY;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+		po->tp_reserve = val;
+		return 0;
+	}
 #endif
 	case PACKET_AUXDATA:
 	{
@@ -1547,6 +1563,12 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 		}
 		data = &val;
 		break;
+	case PACKET_RESERVE:
+		if (len > sizeof(unsigned int))
+			len = sizeof(unsigned int);
+		val = po->tp_reserve;
+		data = &val;
+		break;
 #endif
 	default:
 		return -ENOPROTOOPT;
@@ -1790,7 +1812,8 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req, int closing
 			return -EINVAL;
 		if (unlikely(req->tp_block_size & (PAGE_SIZE - 1)))
 			return -EINVAL;
-		if (unlikely(req->tp_frame_size < po->tp_hdrlen))
+		if (unlikely(req->tp_frame_size < po->tp_hdrlen +
+						  po->tp_reserve))
 			return -EINVAL;
 		if (unlikely(req->tp_frame_size & (TPACKET_ALIGNMENT - 1)))
 			return -EINVAL;

--------------010604060308050003050902--
