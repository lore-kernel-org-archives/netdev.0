From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 09/10] macvtap: Re-enable UFO support
Date: Wed, 17 Dec 2014 13:20:54 -0500
Message-ID: <1418840455-22598-10-git-send-email-vyasevic@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org, mst@redhat.com,
	ben@decadent.org.uk, stefanha@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:54842 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbaLQSV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 13:21:29 -0500
Received: by mail-qc0-f172.google.com with SMTP id m20so12391835qcx.17
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 10:21:29 -0800 (PST)
In-Reply-To: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that UFO is split into v4 and v6 parts, we can bring
back v4 support.  Continue to handle legacy applications
by selecting the ipv6 fagment id but do not change the
gso type.  This allows 2 legacy VMs to continue to communicate.

Based on original work from Ben Hutchings.

Fixes: 88e0e0e5aa7a ("drivers/net: Disable UFO through virtio")
CC: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 880cc09..75febd4 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -66,7 +66,7 @@ static struct cdev macvtap_cdev;
 static const struct proto_ops macvtap_socket_ops;
 
 #define TUN_OFFLOADS (NETIF_F_HW_CSUM | NETIF_F_TSO_ECN | NETIF_F_TSO | \
-		      NETIF_F_TSO6)
+		      NETIF_F_TSO6 | NETIF_F_UFO)
 #define RX_OFFLOADS (NETIF_F_GRO | NETIF_F_LRO)
 #define TAP_FEATURES (NETIF_F_GSO | NETIF_F_SG)
 
@@ -570,11 +570,14 @@ static int macvtap_skb_from_vnet_hdr(struct sk_buff *skb,
 			gso_type = SKB_GSO_TCPV6;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
-			pr_warn_once("macvtap: %s: using disabled UFO feature; please fix this program\n",
-				     current->comm);
 			gso_type = SKB_GSO_UDP;
-			if (skb->protocol == htons(ETH_P_IPV6))
+			if (vlan_get_protocol(skb) == htons(ETH_P_IPV6)) {
+				/* This is to support legacy appliacations.
+				 * Do not change the gso_type as legacy apps
+				 * may not know about the new type.
+				 */
 				ipv6_proxy_select_ident(skb);
+			}
 			break;
 		default:
 			return -EINVAL;
@@ -619,6 +622,8 @@ static void macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
 			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 		else if (sinfo->gso_type & SKB_GSO_TCPV6)
 			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+		else if (sinfo->gso_type & SKB_GSO_UDP)
+			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
 		else
 			BUG();
 		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
@@ -955,6 +960,9 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
 			if (arg & TUN_F_TSO6)
 				feature_mask |= NETIF_F_TSO6;
 		}
+
+		if (arg & TUN_F_UFO)
+			feature_mask |= NETIF_F_UFO;
 	}
 
 	/* tun/tap driver inverts the usage for TSO offloads, where
@@ -965,7 +973,7 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
 	 * When user space turns off TSO, we turn off GSO/LRO so that
 	 * user-space will not receive TSO frames.
 	 */
-	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6))
+	if (feature_mask & (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_UFO))
 		features |= RX_OFFLOADS;
 	else
 		features &= ~RX_OFFLOADS;
@@ -1066,7 +1074,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 	case TUNSETOFFLOAD:
 		/* let the user check for future flags */
 		if (arg & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
-			    TUN_F_TSO_ECN))
+			    TUN_F_TSO_ECN | TUN_F_UFO))
 			return -EINVAL;
 
 		rtnl_lock();
-- 
1.9.3
