From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC] pktgen: don't wait for the device who doesn't free skb
	immediately after sent
Date: Mon, 26 Nov 2012 15:56:52 +0800
Message-ID: <1353916612-6357-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com
To: rusty@rustcorp.com.au, mst@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Some deivces do not free the old tx skbs immediately after it has been sent
(usually in tx interrupt). One such example is virtio-net which optimizes for
virt and only free the possible old tx skbs during the next packet sending. This
would lead the pktgen to wait forever in the refcount of the skb if no other
pakcet will be sent afterwards.

Solving this issue by introducing a new flag IFF_TX_SKB_FREE_DELAY which could
notify the pktgen that the device does not free skb immediately after it has
been sent and let it not to wait for the refcount to be one.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---

Another choice is to introduce an new .ndo which could be called by pktgen
during the waiting to free the old tx skbs.

 drivers/net/virtio_net.c |    3 ++-
 include/uapi/linux/if.h  |    2 ++
 net/core/pktgen.c        |    3 ++-
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 26c502e..8262232 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1058,7 +1058,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 		return -ENOMEM;
 
 	/* Set up network device as normal. */
-	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE;
+	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE |
+			   IFF_TX_SKB_FREE_DELAY;
 	dev->netdev_ops = &virtnet_netdev;
 	dev->features = NETIF_F_HIGHDMA;
 
diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
index 1ec407b..a0d2168 100644
--- a/include/uapi/linux/if.h
+++ b/include/uapi/linux/if.h
@@ -83,6 +83,8 @@
 #define IFF_SUPP_NOFCS	0x80000		/* device supports sending custom FCS */
 #define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware address
 					 * change when it's running */
+#define IFF_TX_SKB_FREE_DELAY 0x200000	/* device does free the tx skb
+					 * immediately when it is sent */
 
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b29dacf..85d4e53 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3269,7 +3269,8 @@ unlock:
 
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
-		pktgen_wait_for_skb(pkt_dev);
+		if (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_FREE_DELAY))
+			pktgen_wait_for_skb(pkt_dev);
 
 		/* Done with this */
 		pktgen_stop_device(pkt_dev);
-- 
1.7.1
