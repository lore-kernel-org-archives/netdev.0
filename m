From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 08/10] tun: Re-uanble UFO support.
Date: Wed, 17 Dec 2014 13:20:53 -0500
Message-ID: <1418840455-22598-9-git-send-email-vyasevic@redhat.com>
References: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Cc: virtualization@lists.linux-foundation.org, mst@redhat.com,
	ben@decadent.org.uk, stefanha@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:45876 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbaLQSV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 13:21:28 -0500
Received: by mail-qc0-f171.google.com with SMTP id r5so12430439qcx.16
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 10:21:27 -0800 (PST)
In-Reply-To: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that UFO is split into v4 and v6 parts, we can bring
back v4 support without any trouble.

Continue to handle legacy applications by selecting the
IPv6 fragment id but do not change the gso type.  Thist
makes sure that two legacy VMs may still communicate.

Based on original work from Ben Hutchings.

Fixes: 88e0e0e5aa7a ("drivers/net: Disable UFO through virtio")
CC: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/tun.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 9dd3746..8c32fca 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -175,7 +175,7 @@ struct tun_struct {
 	struct net_device	*dev;
 	netdev_features_t	set_features;
 #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO| \
-			  NETIF_F_TSO6)
+			  NETIF_F_TSO6|NETIF_F_UFO)
 
 	int			vnet_hdr_sz;
 	int			sndbuf;
@@ -1152,20 +1152,15 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
-		{
-			static bool warned;
-
-			if (!warned) {
-				warned = true;
-				netdev_warn(tun->dev,
-					    "%s: using disabled UFO feature; please fix this program\n",
-					    current->comm);
-			}
 			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
-			if (skb->protocol == htons(ETH_P_IPV6))
+			if (vlan_get_protocol(skb) == htons(ETH_P_IPV6)) {
+				/* This allows legacy application to work.
+				 * Do not change the gso_type as it may
+				 * not be upderstood by legacy applications.
+				 */
 				ipv6_proxy_select_ident(skb);
+			}
 			break;
-		}
 		default:
 			tun->dev->stats.rx_frame_errors++;
 			kfree_skb(skb);
@@ -1273,6 +1268,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 			else if (sinfo->gso_type & SKB_GSO_TCPV6)
 				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+			else if (sinfo->gso_type & SKB_GSO_UDP)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
 			else {
 				pr_err("unexpected GSO type: "
 				       "0x%x, gso_size %d, hdr_len %d\n",
@@ -1780,6 +1777,11 @@ static int set_offload(struct tun_struct *tun, unsigned long arg)
 				features |= NETIF_F_TSO6;
 			arg &= ~(TUN_F_TSO4|TUN_F_TSO6);
 		}
+
+		if (arg & TUN_F_UFO) {
+			features |= NETIF_F_UFO;
+			arg &= ~TUN_F_UFO;
+		}
 	}
 
 	/* This gives the user a way to test for new features in future by
-- 
1.9.3
