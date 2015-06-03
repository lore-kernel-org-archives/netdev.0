From: Tom Herbert <tom@herbertland.com>
Subject: [RFC net-next 6/6] ipvlan: Call ILA in incoming and outgoing receive paths
Date: Wed, 3 Jun 2015 12:58:22 -0700
Message-ID: <1433361502-3478761-7-git-send-email-tom@herbertland.com>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <agartrell@fb.com>, <maheshb@google.com>,
	<tgraf@suug.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50054 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755180AbbFCT6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 15:58:53 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t53JvuC9008240
	for <netdev@vger.kernel.org>; Wed, 3 Jun 2015 12:58:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ut7h4r4hg-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 12:58:52 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 f44916680a2a11e5aa0a0002c992ebde-4d7fb280 for <netdev@vger.kernel.org>;	Wed,
 03 Jun 2015 12:58:50 -0700
In-Reply-To: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hacked IPVLAN to call ILA functions in send and receive paths.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ipvlan/ipvlan.h      |  1 +
 drivers/net/ipvlan/ipvlan_core.c | 27 ++++++++++++++++++---------
 drivers/net/ipvlan/ipvlan_main.c |  4 ++++
 3 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 953a974..3b85260 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -28,6 +28,7 @@
 #include <net/rtnetlink.h>
 #include <net/route.h>
 #include <net/addrconf.h>
+#include <net/ila.h>
 
 #define IPVLAN_DRV	"ipvlan"
 #define IPV_DRV_VER	"0.1"
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 8afbeda..7e71907 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -9,6 +9,8 @@
 
 #include "ipvlan.h"
 
+extern bool query_ila;
+
 static u32 ipvlan_jhash_secret __read_mostly;
 
 void ipvlan_init_secret(void)
@@ -385,15 +387,18 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	struct dst_entry *dst;
 	int err, ret = NET_XMIT_DROP;
-	struct flowi6 fl6 = {
-		.flowi6_iif = skb->dev->ifindex,
-		.daddr = ip6h->daddr,
-		.saddr = ip6h->saddr,
-		.flowi6_flags = FLOWI_FLAG_ANYSRC,
-		.flowlabel = ip6_flowinfo(ip6h),
-		.flowi6_mark = skb->mark,
-		.flowi6_proto = ip6h->nexthdr,
-	};
+	struct flowi6 fl6;
+
+	if (query_ila && ila_xlat_outgoing(skb) < 0)
+		goto err;
+
+	fl6.flowi6_iif = skb->dev->ifindex;
+	fl6.daddr = ip6h->daddr;
+	fl6.saddr = ip6h->saddr;
+	fl6.flowi6_flags = FLOWI_FLAG_ANYSRC;
+	fl6.flowlabel = ip6_flowinfo(ip6h);
+	fl6.flowi6_mark = skb->mark;
+	fl6.flowi6_proto = ip6h->nexthdr;
 
 	dst = ip6_route_output(dev_net(dev), NULL, &fl6);
 	if (dst->error) {
@@ -401,6 +406,7 @@ static int ipvlan_process_v6_outbound(struct sk_buff *skb)
 		dst_release(dst);
 		goto err;
 	}
+
 	skb_dst_drop(skb);
 	skb_dst_set(skb, dst);
 	err = ip6_local_out(skb);
@@ -583,6 +589,9 @@ static rx_handler_result_t ipvlan_handle_mode_l3(struct sk_buff **pskb,
 	struct sk_buff *skb = *pskb;
 	rx_handler_result_t ret = RX_HANDLER_PASS;
 
+	if (query_ila && ila_xlat_incoming(skb) < 0)
+		goto out;
+
 	lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
 	if (!lyr3h)
 		goto out;
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 1acc283..e029fad 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -9,6 +9,10 @@
 
 #include "ipvlan.h"
 
+bool query_ila = false;
+module_param(query_ila, bool, 0644);
+MODULE_PARM_DESC(query_ila, "Query ILA in incoming and outgoing paths");
+
 void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
 {
 	ipvlan->dev->mtu = dev->mtu - ipvlan->mtu_adj;
-- 
1.8.1
