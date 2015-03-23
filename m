From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: [PATCH V2 2/2] af_packet: pass checksum validation status to the user
Date: Mon, 23 Mar 2015 09:11:13 +0300
Message-ID: <1427091073-8129-2-git-send-email-al.drozdov@gmail.com>
References: <1426752102-12786-2-git-send-email-al.drozdov@gmail.com>
 <1427091073-8129-1-git-send-email-al.drozdov@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Willem de Bruijn <willemb@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>,
	linux-doc@vger.kernel.org, linux-api@vger.kernel.org,
	Alexander Drozdov <al.drozdov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427091073-8129-1-git-send-email-al.drozdov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce TP_STATUS_CSUM_VALID tp_status flag to tell the
af_packet user that at least the transport header checksum
has been already validated.

For now, the flag may be set for incoming packets only.

Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 Documentation/networking/packet_mmap.txt | 13 ++++++++++---
 include/uapi/linux/if_packet.h           |  1 +
 net/packet/af_packet.c                   |  9 +++++++++
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index a6d7cb9..daa015a 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -440,9 +440,10 @@ and the following flags apply:
 +++ Capture process:
      from include/linux/if_packet.h
 
-     #define TP_STATUS_COPY          2 
-     #define TP_STATUS_LOSING        4 
-     #define TP_STATUS_CSUMNOTREADY  8 
+     #define TP_STATUS_COPY          (1 << 1)
+     #define TP_STATUS_LOSING        (1 << 2)
+     #define TP_STATUS_CSUMNOTREADY  (1 << 3)
+     #define TP_STATUS_CSUM_VALID    (1 << 7)
 
 TP_STATUS_COPY        : This flag indicates that the frame (and associated
                         meta information) has been truncated because it's 
@@ -466,6 +467,12 @@ TP_STATUS_CSUMNOTREADY: currently it's used for outgoing IP packets which
                         reading the packet we should not try to check the 
                         checksum. 
 
+TP_STATUS_CSUM_VALID  : This flag indicates that at least the transport
+                        header checksum of the packet has been already
+                        validated on the kernel side. If the flag is not set
+                        then we are free to check the checksum by ourselves
+                        provided that TP_STATUS_CSUMNOTREADY is also not set.
+
 for convenience there are also the following defines:
 
      #define TP_STATUS_KERNEL        0
diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index da2d668..053bd10 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -99,6 +99,7 @@ struct tpacket_auxdata {
 #define TP_STATUS_VLAN_VALID		(1 << 4) /* auxdata has valid tp_vlan_tci */
 #define TP_STATUS_BLK_TMO		(1 << 5)
 #define TP_STATUS_VLAN_TPID_VALID	(1 << 6) /* auxdata has valid tp_vlan_tpid */
+#define TP_STATUS_CSUM_VALID		(1 << 7)
 
 /* Tx ring - header status */
 #define TP_STATUS_AVAILABLE	      0
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6ecf8dd..3f09dda 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1918,6 +1918,10 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		status |= TP_STATUS_CSUMNOTREADY;
+	else if (skb->pkt_type != PACKET_OUTGOING &&
+		 (skb->ip_summed == CHECKSUM_COMPLETE ||
+		  skb_csum_unnecessary(skb)))
+		status |= TP_STATUS_CSUM_VALID;
 
 	if (snaplen > res)
 		snaplen = res;
@@ -3015,6 +3019,11 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		aux.tp_status = TP_STATUS_USER;
 		if (skb->ip_summed == CHECKSUM_PARTIAL)
 			aux.tp_status |= TP_STATUS_CSUMNOTREADY;
+		else if (skb->pkt_type != PACKET_OUTGOING &&
+			 (skb->ip_summed == CHECKSUM_COMPLETE ||
+			  skb_csum_unnecessary(skb)))
+			aux.tp_status |= TP_STATUS_CSUM_VALID;
+
 		aux.tp_len = PACKET_SKB_CB(skb)->origlen;
 		aux.tp_snaplen = skb->len;
 		aux.tp_mac = 0;
-- 
1.9.1
