From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next-2.6 PATCH] net: add priority field to pktgen
Date: Tue, 16 Nov 2010 21:12:28 -0800
Message-ID: <20101117051228.19479.8267.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37172 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab0KQFPZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Nov 2010 00:15:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add option to set skb priority to pktgen. Useful for testing
QOS features. Also by running pktgen on the vlan device the
qdisc on the real device can be tested.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/pktgen.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 33bc382..52fc1e0 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -378,6 +378,7 @@ struct pktgen_dev {
 
 	u16 queue_map_min;
 	u16 queue_map_max;
+	__u32 skb_priority;	/* skb priority field */
 	int node;               /* Memory node */
 
 #ifdef CONFIG_XFRM
@@ -547,6 +548,10 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 		   pkt_dev->queue_map_min,
 		   pkt_dev->queue_map_max);
 
+	if (pkt_dev->skb_priority)
+		seq_printf(seq, "     skb_priority: %u\n",
+			   pkt_dev->skb_priority);
+
 	if (pkt_dev->flags & F_IPV6) {
 		char b1[128], b2[128], b3[128];
 		fmt_ip6(b1, pkt_dev->in6_saddr.s6_addr);
@@ -1711,6 +1716,18 @@ static ssize_t pktgen_if_write(struct file *file,
 		return count;
 	}
 
+	if (!strcmp(name, "skb_priority")) {
+		len = num_arg(&user_buffer[i], 9, &value);
+		if (len < 0)
+			return len;
+
+		i += len;
+		pkt_dev->skb_priority = value;
+		sprintf(pg_result, "OK: skb_priority=%i",
+			pkt_dev->skb_priority);
+		return count;
+	}
+
 	sprintf(pkt_dev->result, "No such parameter \"%s\"", name);
 	return -EINVAL;
 }
@@ -2671,6 +2688,8 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	skb->transport_header = skb->network_header + sizeof(struct iphdr);
 	skb_put(skb, sizeof(struct iphdr) + sizeof(struct udphdr));
 	skb_set_queue_mapping(skb, queue_map);
+	skb->priority = pkt_dev->skb_priority;
+
 	iph = ip_hdr(skb);
 	udph = udp_hdr(skb);
 
@@ -3016,6 +3035,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	skb->transport_header = skb->network_header + sizeof(struct ipv6hdr);
 	skb_put(skb, sizeof(struct ipv6hdr) + sizeof(struct udphdr));
 	skb_set_queue_mapping(skb, queue_map);
+	skb->priority = pkt_dev->skb_priority;
 	iph = ipv6_hdr(skb);
 	udph = udp_hdr(skb);
 

