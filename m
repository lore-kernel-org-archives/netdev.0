From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,2/3] hv_netvsc: Add ethtool handler to set and get TCP hash levels
Date: Fri,  6 Oct 2017 08:33:58 -0700
Message-ID: <20171006153359.8400-3-haiyangz@exchange.microsoft.com>
References: <20171006153359.8400-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171006153359.8400-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

The patch supports the options to switch TCP hash level between
L3 and L4 by ethtool command. TCP over IPv4 and v6 can be set
differently. The default hash level is L4. We currently only
allow switching TX hash level from within the guests.

For example, for TCP over IPv4 on eth0:
To include TCP port numbers in hashing:
	ethtool -N eth0 rx-flow-hash tcp4 sdfn
To exclude TCP port numbers in hashing:
	ethtool -N eth0 rx-flow-hash tcp4 sd
To show TCP hash level:
	ethtool -n eth0 rx-flow-hash tcp4

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 9bc7dbab9506..44746de3dd4c 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1264,8 +1264,15 @@ netvsc_get_rss_hash_opts(struct net_device_context *ndc,
 
 	switch (info->flow_type) {
 	case TCP_V4_FLOW:
+		if (ndc->l4_hash & HV_TCP4_L4HASH)
+			info->data |= l4_flag;
+
+		break;
+
 	case TCP_V6_FLOW:
-		info->data |= l4_flag;
+		if (ndc->l4_hash & HV_TCP6_L4HASH)
+			info->data |= l4_flag;
+
 		break;
 
 	case UDP_V4_FLOW:
@@ -1318,6 +1325,14 @@ static int netvsc_set_rss_hash_opts(struct net_device_context *ndc,
 	if (info->data == (RXH_IP_SRC | RXH_IP_DST |
 			   RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
 		switch (info->flow_type) {
+		case TCP_V4_FLOW:
+			ndc->l4_hash |= HV_TCP4_L4HASH;
+			break;
+
+		case TCP_V6_FLOW:
+			ndc->l4_hash |= HV_TCP6_L4HASH;
+			break;
+
 		case UDP_V4_FLOW:
 			ndc->l4_hash |= HV_UDP4_L4HASH;
 			break;
@@ -1335,6 +1350,14 @@ static int netvsc_set_rss_hash_opts(struct net_device_context *ndc,
 
 	if (info->data == (RXH_IP_SRC | RXH_IP_DST)) {
 		switch (info->flow_type) {
+		case TCP_V4_FLOW:
+			ndc->l4_hash &= ~HV_TCP4_L4HASH;
+			break;
+
+		case TCP_V6_FLOW:
+			ndc->l4_hash &= ~HV_TCP6_L4HASH;
+			break;
+
 		case UDP_V4_FLOW:
 			ndc->l4_hash &= ~HV_UDP4_L4HASH;
 			break;
-- 
2.14.1
