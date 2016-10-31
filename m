From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 4/4] bridge: mcast: add router port on PIM hello message
Date: Mon, 31 Oct 2016 13:21:05 +0100
Message-ID: <1477916465-20406-5-git-send-email-nikolay@cumulusnetworks.com>
References: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dwalton@cumulusnetworks.com,
        stephen@networkplumber.org, davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35873 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941446AbcJaMVV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 08:21:21 -0400
Received: by mail-wm0-f48.google.com with SMTP id p190so143768569wmp.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 05:21:20 -0700 (PDT)
In-Reply-To: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we receive a PIM Hello message on a port we can consider that it
has a multicast router attached, thus it is correct to add it to the
router list. The only catch is it shouldn't be considered for a querier.

Using Daniel's description:
leaf-11  leaf-12  leaf-13
       \   |    /
        bridge-1
         /    \
    host-11  host-12

 - all ports in bridge-1 are in a single vlan aware bridge
 - leaf-11 is the IGMP querier
 - leaf-13 is the PIM DR
 - host-11 TXes packets to 226.10.10.10
 - bridge-1 only forwards the 226.10.10.10 traffic out the port to
   leaf-11, it should also forward this traffic out the port to leaf-13

Suggested-by: Daniel Walton <dwalton@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_multicast.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2136e45f5277..073d54afa056 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -25,6 +25,7 @@
 #include <linux/slab.h>
 #include <linux/timer.h>
 #include <linux/inetdevice.h>
+#include <linux/mroute.h>
 #include <net/ip.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -1638,6 +1639,21 @@ static void br_multicast_err_count(const struct net_bridge *br,
 	u64_stats_update_end(&pstats->syncp);
 }
 
+static void br_multicast_pim(struct net_bridge *br,
+			     struct net_bridge_port *port,
+			     const struct sk_buff *skb)
+{
+	unsigned int offset = skb_transport_offset(skb);
+	struct pimhdr *pimhdr, _pimhdr;
+
+	pimhdr = skb_header_pointer(skb, offset, sizeof(_pimhdr), &_pimhdr);
+	if (!pimhdr || pim_hdr_version(pimhdr) != PIM_VERSION ||
+	    pim_hdr_type(pimhdr) != PIM_TYPE_HELLO)
+		return;
+
+	br_multicast_mark_router(br, port);
+}
+
 static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
 				 struct sk_buff *skb,
@@ -1650,8 +1666,12 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	err = ip_mc_check_igmp(skb, &skb_trimmed);
 
 	if (err == -ENOMSG) {
-		if (!ipv4_is_local_multicast(ip_hdr(skb)->daddr))
+		if (!ipv4_is_local_multicast(ip_hdr(skb)->daddr)) {
 			BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
+		} else if (pim_ipv4_all_pim_routers(ip_hdr(skb)->daddr)) {
+			if (ip_hdr(skb)->protocol == IPPROTO_PIM)
+				br_multicast_pim(br, port, skb);
+		}
 		return 0;
 	} else if (err < 0) {
 		br_multicast_err_count(br, port, skb->protocol);
-- 
2.1.4
