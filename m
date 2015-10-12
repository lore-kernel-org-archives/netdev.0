From: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Subject: [PATCH] - gre: add eth_p_teb gro-handler for OVS with gre tunnels
Date: Mon, 12 Oct 2015 15:26:24 -0700
Message-ID: <fc84377af8867930138e05c27952d4d4@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Davem <davem@davemloft.net>,
	jkidambi@us.ibm.com, manand@us.ibm.com
To: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesse Gross <jesse@nicira.com>, hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:59453 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbbJLW03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 18:26:29 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sramamur@linux.vnet.ibm.com>;
	Mon, 12 Oct 2015 16:26:29 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 2AE8019D8042
	for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 16:14:37 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9CMPPvv4850020
	for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 15:25:25 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9CMQOG2017744
	for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 16:26:25 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Problem:
--------

When using OVS with GRE tunnels, and GRO is enabled on the nic,
We find that GRO doesnt really take effect. As a result, TCP stream
performance on a 10G nic is around 2-3Gbps.

Root Cause:
-----------

The protocol field set in GRE (by OVS) is ETH_P_TEB.
The code in gre_gro_receive() (gre_offload.c) calls
gro_find_receive_by_type() to determine a gro handler for the
ETH_P_TEB protocol. However, no such protocol is registered
at the device layer (only ETH_P_IP, ETH_P_IPV6, and mpls related
protocols are registered). Hence, GRO is skipped.


Fix:
----

Add a GRO handler at the device layer for the ETH_P_TEB protocol. It is 
implemented
as a independent module, so it can be added if needed.


Measurements:

Single TCP stream performance

Before:  2.4 Gbps

After:   7.1 Gbps





Signed-off-by: Ramu Ramamurthy <ramu.ramamurthy@us.ibm.com>
---
  net/ipv4/Makefile          |    1 +
  net/ipv4/eth_teb_offload.c |  114 
++++++++++++++++++++++++++++++++++++++++++++
  2 files changed, 115 insertions(+), 0 deletions(-)
  create mode 100644 net/ipv4/eth_teb_offload.c

diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 89aacb6..8b2d7ee 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_NET_IPIP) += ipip.o
  gre-y := gre_demux.o
  obj-$(CONFIG_NET_FOU) += fou.o
  obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
+obj-$(CONFIG_NET_IPGRE_DEMUX) += eth_teb_offload.o
  obj-$(CONFIG_NET_IPGRE) += ip_gre.o
  obj-$(CONFIG_NET_UDP_TUNNEL) += udp_tunnel.o
  obj-$(CONFIG_NET_IPVTI) += ip_vti.o
diff --git a/net/ipv4/eth_teb_offload.c b/net/ipv4/eth_teb_offload.c
new file mode 100644
index 0000000..fc4aabd
--- /dev/null
+++ b/net/ipv4/eth_teb_offload.c
@@ -0,0 +1,114 @@
+/*
+ * This module performs GRO for Transparent Ethernet Bridging
+ * protocol encapulated within GRE. The usecase is to boost the
+ * performance of OpenVswitch with GRE tunnels.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <net/protocol.h>
+#include <linux/etherdevice.h>
+
+static struct sk_buff **eth_teb_gro_receive(struct sk_buff **head,
+					    struct sk_buff *skb)
+{
+	struct sk_buff *p, **pp = NULL;
+	struct ethhdr *eh, *eh2;
+	unsigned int hlen, off_eth;
+	const struct packet_offload *ptype;
+	__be16 type;
+	int flush = 1;
+
+	off_eth = skb_gro_offset(skb);
+	hlen = off_eth + sizeof(*eh);
+	eh   = skb_gro_header_fast(skb, off_eth);
+	if (skb_gro_header_hard(skb, hlen)) {
+		eh = skb_gro_header_slow(skb, hlen, off_eth);
+		if (unlikely(!eh))
+			goto out;
+	}
+
+	flush = 0;
+
+	for (p = *head; p; p = p->next) {
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		eh2 = (struct ethhdr   *)(p->data + off_eth);
+		if (compare_ether_header(eh, eh2)) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+	}
+
+	type = eh->h_proto;
+
+	rcu_read_lock();
+	ptype = gro_find_receive_by_type(type);
+	if (!ptype) {
+		flush = 1;
+		goto out_unlock;
+	}
+
+	skb_gro_pull(skb, sizeof(*eh));
+	skb_gro_postpull_rcsum(skb, eh, sizeof(*eh));
+	pp = ptype->callbacks.gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int eth_teb_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct ethhdr *eh;
+	struct packet_offload *ptype;
+	__be16 type;
+	int ethteb_len	= sizeof(struct ethhdr);
+	int err = -ENOSYS;
+
+	eh = (struct ethhdr *)(skb->data + nhoff);
+	type = eh->h_proto;
+
+	rcu_read_lock();
+	ptype = gro_find_complete_by_type(type);
+	if (ptype)
+		err = ptype->callbacks.gro_complete(skb, nhoff + ethteb_len);
+
+	rcu_read_unlock();
+	return err;
+}
+
+static struct packet_offload ethteb_offload __read_mostly = {
+	.type = cpu_to_be16(ETH_P_TEB),
+	.callbacks = {
+		.gro_receive = eth_teb_gro_receive,
+		.gro_complete = eth_teb_gro_complete,
+	},
+};
+
+static int __init eth_teb_offload_init(void)
+{
+	pr_info("Transparent Ethernet Bridging offload register\n");
+	dev_add_offload(&ethteb_offload);
+	return 0;
+}
+
+static void __exit eth_teb_offload_exit(void)
+{
+	dev_remove_offload(&ethteb_offload);
+	pr_info("Transparent Ethernet Bridging offload deregister\n");
+}
+
+module_init(eth_teb_offload_init)
+module_exit(eth_teb_offload_exit)
+
+MODULE_DESCRIPTION("Offload for Transparent Ethernet Bridging");
+MODULE_AUTHOR("Ramu Ramamurthy (ramu.ramamurthy@us.ibm.com)");
+MODULE_LICENSE("GPL");
-- 
1.7.1
