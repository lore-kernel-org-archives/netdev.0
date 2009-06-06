From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next 4/4] tun: Allow tap device to send/receive UFO
 packets.
Date: Fri, 05 Jun 2009 17:16:39 -0700
Message-ID: <1244247399.1526.173.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, kvm@vger.kernel.org,
	herbert.xu@redhat.com, rusty@rustcorp.com.au
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle send/receive of UFO packets in tun/tap driver.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 drivers/net/tun.c      |   13 ++++++++++++-
 include/linux/if_tun.h |    1 +
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 15cfcb2..96d23b8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -635,6 +635,9 @@ static __inline__ ssize_t tun_get_user(struct tun_struct *tun,
 		case VIRTIO_NET_HDR_GSO_TCPV6:
 			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
 			break;
+		case VIRTIO_NET_HDR_GSO_UDP:
+			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+			break;
 		default:
 			tun->dev->stats.rx_frame_errors++;
 			kfree_skb(skb);
@@ -720,6 +723,8 @@ static __inline__ ssize_t tun_put_user(struct tun_struct *tun,
 				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 			else if (sinfo->gso_type & SKB_GSO_TCPV6)
 				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+			else if (sinfo->gso_type & SKB_GSO_UDP)
+				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
 			else
 				BUG();
 			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
@@ -1068,7 +1073,8 @@ static int set_offload(struct net_device *dev, unsigned long arg)
 	old_features = dev->features;
 	/* Unset features, set them as we chew on the arg. */
 	features = (old_features & ~(NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST
-				    |NETIF_F_TSO_ECN|NETIF_F_TSO|NETIF_F_TSO6));
+				    |NETIF_F_TSO_ECN|NETIF_F_TSO|NETIF_F_TSO6
+				    |NETIF_F_UFO));
 
 	if (arg & TUN_F_CSUM) {
 		features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
@@ -1085,6 +1091,11 @@ static int set_offload(struct net_device *dev, unsigned long arg)
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
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 915ba57..3f5fd52 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -62,6 +62,7 @@
 #define TUN_F_TSO4	0x02	/* I can handle TSO for IPv4 packets */
 #define TUN_F_TSO6	0x04	/* I can handle TSO for IPv6 packets */
 #define TUN_F_TSO_ECN	0x08	/* I can handle TSO with ECN bits. */
+#define TUN_F_UFO	0x10	/* I can handle UFO packets */
 
 /* Protocol info prepended to the packets (when IFF_NO_PI is not set) */
 #define TUN_PKT_STRIP	0x0001


