From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] netlink: specify netlink packet direction for nlmon
Date: Thu, 19 Dec 2013 02:29:39 +0100
Message-ID: <1387416579-3098-3-git-send-email-dborkman@redhat.com>
References: <1387416579-3098-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140Ab3LSDLg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 22:11:36 -0500
In-Reply-To: <1387416579-3098-1-git-send-email-dborkman@redhat.com>
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

As we only have 3 bit reserved, "overload" the meaning of these
flags for netlink skbs on nlmon devices, thus it can be picked up
via sll_pkttype in struct sockaddr_ll. We have now:

 - PACKET_USER    ->  to user space
 - PACKET_KERNEL  ->  to kernel space

Partial `ip a` example strace for sa_family=AF_NETLINK with detected
nl msg direction:

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
 include/uapi/linux/if_packet.h | 3 +++
 net/netlink/af_netlink.c       | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index e9d844c..a8d4ff1 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -29,6 +29,9 @@ struct sockaddr_ll {
 /* These ones are invisible by user level */
 #define PACKET_LOOPBACK		5		/* MC/BRD frame looped back */
 #define PACKET_FASTROUTE	6		/* Fastrouted frame	*/
+/* These ones are for nlmon devices */
+#define PACKET_USER		0		/* To user space */
+#define PACKET_KERNEL		1		/* To kernel space */
 
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
1.8.3.1
