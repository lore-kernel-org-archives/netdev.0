From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] drivers/net/ethernet/via/via-velocity.c: update napi implementation
Date: Wed, 14 Aug 2013 16:26:53 +0200
Message-ID: <1376490413-12067-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, grant.likely@linaro.org,
	rob.herring@calxeda.com
To: Francois Romieu <romieu@fr.zoreil.com>, roszenrami@gmail.com,
	dshwatrz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Drivers supporting NAPI should use a NAPI-specific function for receiving
packets.  Hence netif_rx is changed to netif_receive_skb.

Furthermore netif_napi_del should be used in the probe and remove function
to clean up the NAPI resource information.

Thanks to Francois Romieu, David Shwatrz and Rami Rosen for their help on
this patch.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
I still don't understand the reason for choosing netif_receive_skb,
specifically.  This patch is not tested.

 drivers/net/ethernet/via/via-velocity.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index ef77631..d022bf9 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2100,7 +2100,7 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
 	}
-	netif_rx(skb);
+	netif_receive_skb(skb);
 
 	stats->rx_bytes += pkt_len;
 	stats->rx_packets++;
@@ -2904,6 +2904,7 @@ out:
 	return ret;
 
 err_iounmap:
+	netif_napi_del(&vptr->napi);
 	iounmap(regs);
 err_free_dev:
 	free_netdev(netdev);
@@ -2924,6 +2925,7 @@ static int velocity_remove(struct device *dev)
 	struct velocity_info *vptr = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
+	netif_napi_del(&vptr->napi);
 	iounmap(vptr->mac_regs);
 	free_netdev(netdev);
 	velocity_nics--;
