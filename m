From: Hal Rosenstock <halr@voltaire.com>
Subject: [PATCH] sockaddr_ll change for IPoIB interfaces
Date: 05 Aug 2005 14:25:57 -0400
Message-ID: <1123266356.4451.243.camel@hal.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: netdev@vger.kernel.org
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Hi,

The patch below is to accomodate IPoIB link layer address in the
sockaddr_ll struct so that user space can send and receive IPoIB link
later packets. Unfortunately, IPoIB has 20 bytes LL addresses rather
than the 8 byte MAC addresses (or under) used by other LLs.

There is a similar change to both:
/usr/include/linux/if_packet.h
/usr/include/netpacket/packet.h
as in:
include/linux/if_packet.h below
to increase sll_addr from 8 to 20 bytes.

Thanks.

-- Hal

sockaddr_ll changes to accomodate IPoIB interfaces.
This is due to the fact that the IPoIB link layer
address is 20 bytes rather than 8 bytes. With the current 8 byte
address, it is not possible to send ARPs and RARPs from userspace as the
broadcast and unicast IPoIB addresses cannot be supplied properly.
There is backward compatibility support for those applications built
with the existing structure (prior to this patch).

Signed-off-by: Hal Rosenstock <halr@voltaire.com>

--- include/linux/if_packet.h.orig	2005-06-29 19:00:53.000000000 -0400
+++ include/linux/if_packet.h	2005-08-05 10:04:06.000000000 -0400
@@ -8,6 +8,7 @@ struct sockaddr_pkt
 	unsigned short spkt_protocol;
 };
 
+#define SOCKADDR_LL_COMPAT	12
 struct sockaddr_ll
 {
 	unsigned short	sll_family;
@@ -16,7 +17,7 @@ struct sockaddr_ll
 	unsigned short	sll_hatype;
 	unsigned char	sll_pkttype;
 	unsigned char	sll_halen;
-	unsigned char	sll_addr[8];
+	unsigned char	sll_addr[20];
 };
 
 /* Packet types */

--- af_packet.c.orig	2005-06-29 19:00:53.000000000 -0400
+++ af_packet.c	2005-08-05 13:28:49.000000000 -0400
@@ -708,8 +708,12 @@ static int packet_sendmsg(struct kiocb *
 		addr	= NULL;
 	} else {
 		err = -EINVAL;
-		if (msg->msg_namelen < sizeof(struct sockaddr_ll))
-			goto out;
+		if (msg->msg_namelen < sizeof(struct sockaddr_ll)) {
+			/* Support for older sockaddr_ll structs */
+			if ((msg->msg_namelen != sizeof(struct sockaddr_ll) - SOCKADDR_LL_COMPAT) ||
+			    (saddr->sll_hatype == ARPHRD_INFINIBAND))
+				goto out;
+		}
 		ifindex	= saddr->sll_ifindex;
 		proto	= saddr->sll_protocol;
 		addr	= saddr->sll_addr;
@@ -937,7 +941,11 @@ static int packet_bind(struct socket *so
 	 */
 	 
 	if (addr_len < sizeof(struct sockaddr_ll))
-		return -EINVAL;
+		/* Support for older sockaddr_ll structs */
+		if ((addr_len != sizeof(struct sockaddr_ll) -
+				 SOCKADDR_LL_COMPAT) || 
+		    (sll->sll_hatype == ARPHRD_INFINIBAND))
+			return -EINVAL;
 	if (sll->sll_family != AF_PACKET)
 		return -EINVAL;
 
