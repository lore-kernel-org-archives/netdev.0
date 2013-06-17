From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net] Fix the VLAN_TAG_PRESENT in netvsc_recv_callback()
Date: Mon, 17 Jun 2013 15:36:49 -0700
Message-ID: <1371508609-22780-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should call __vlan_hwaccel_put_tag() only if the packet
comes from vlan, otherwise VLAN_TAG_PRESENT will always be
added.

Reported-by: Olaf Hering <olaf@aepfle.de>
Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/netvsc_drv.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index ab2307b..4dccead 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -285,7 +285,9 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 
 	skb->protocol = eth_type_trans(skb, net);
 	skb->ip_summed = CHECKSUM_NONE;
-	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), packet->vlan_tci);
+	if (packet->vlan_tci & VLAN_TAG_PRESENT)
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+				       packet->vlan_tci);
 
 	net->stats.rx_packets++;
 	net->stats.rx_bytes += packet->total_data_buflen;
-- 
1.7.4.1
