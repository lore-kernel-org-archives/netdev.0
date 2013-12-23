From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 2/2] netlink: specify netlink packet direction for nlmon
Date: Mon, 23 Dec 2013 14:35:56 +0100
Message-ID: <1387805756-21121-3-git-send-email-dborkman@redhat.com>
References: <1387805756-21121-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138Ab3LWNgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Dec 2013 08:36:18 -0500
In-Reply-To: <1387805756-21121-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to facilitate development for netlink protocol dissector,
fill the unused field skb->pkt_type of the cloned skb with a hint
of the address space of the new owner (receiver) socket in the
notion of "to kernel" resp. "to user".

At the time we invoke __netlink_deliver_tap_skb(), we already have
set the new skb owner via netlink_skb_set_owner_r(), so we can use
that for netlink_is_kernel() probing.

In normal PF_PACKET network traffic, this field denotes if the
packet is destined for us (PACKET_HOST), if it's broadcast
(PACKET_BROADCAST), etc.

As we only have 3 bit reserved, we can use the value (= 6) of
PACKET_FASTROUTE as it's _not used_ anywhere in the whole kernel
and not supported anywhere, and packets of such type were never
exposed to user space, so there are no overlapping users of such
kind. Thus, as wished, that seems the only way to make both
PACKET_* values non-overlapping and therefore device agnostic.

By using those two flags for netlink skbs on nlmon devices, they
can be made available and picked up via sll_pkttype (previously
unused in netlink context) in struct sockaddr_ll. We now have
these two directions:

 - PACKET_USER (= 6)    ->  to user space
 - PACKET_KERNEL (= 7)  ->  to kernel space

Partial `ip a` example strace for sa_family=AF_NETLINK with
detected nl msg direction:

syscall:                     direction:
sendto(3,  ...) = 40         /* to kernel */
recvmsg(3, ...) = 3404       /* to user */
recvmsg(3, ...) = 1120       /* to user */
recvmsg(3, ...) = 20         /* to user */
sendto(3,  ...) = 40         /* to kernel */
recvmsg(3, ...) = 168        /* to user */
recvmsg(3, ...) = 144        /* to user */
recvmsg(3, ...) = 20         /* to user */

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Jakub Zawadzki <darkjames-ws@darkjames.pl>
---
 v1->v2:
  - let PACKET_* values not overlap as requested by Dave
 v2->v3:
  - fixed typo in comment spotted by Nicolas, thanks

 include/uapi/linux/if_packet.h | 4 +++-
 net/netlink/af_netlink.c       | 2 ++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index e9d844c..06e2a28 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -26,8 +26,10 @@ struct sockaddr_ll {
 #define PACKET_MULTICAST	2		/* To group		*/
 #define PACKET_OTHERHOST	3		/* To someone else 	*/
 #define PACKET_OUTGOING		4		/* Outgoing of any type */
-/* These ones are invisible by user level */
 #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
+#define PACKET_USER		6		/* To user space	*/
+#define PACKET_KERNEL		7		/* To kernel space	*/
+/* Unused, PACKET_FASTROUTE and PACKET_LOOPBACK are invisible to user space */
 #define PACKET_FASTROUTE	6		/* Fastrouted frame	*/
 
 /* Packet socket options */
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 56e09d8..3f75f1c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -204,6 +204,8 @@ static int __netlink_deliver_tap_skb(struct sk_buff *skb,
 	if (nskb) {
 		nskb->dev = dev;
 		nskb->protocol = htons((u16) sk->sk_protocol);
+		nskb->pkt_type = netlink_is_kernel(sk) ?
+				 PACKET_KERNEL : PACKET_USER;
 
 		ret = dev_queue_xmit(nskb);
 		if (unlikely(ret > 0))
-- 
1.7.11.7
