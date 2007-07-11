From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [RFC 1/3] lro: Generic LRO for TCP traffic
Date: Wed, 11 Jul 2007 16:21:34 +0200
Message-ID: <200707111621.34376.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764076AbXGKOr6@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Large Receive Offload (tcp)

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
---
 include/linux/inet_lro.h |  107 ++++++++++++++++
 net/ipv4/inet_lro.c      |  311 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 418 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/inet_lro.h
 create mode 100644 net/ipv4/inet_lro.c

diff --git a/include/linux/inet_lro.h b/include/linux/inet_lro.h
new file mode 100644
index 0000000..6df444a
--- /dev/null
+++ b/include/linux/inet_lro.h
@@ -0,0 +1,107 @@
+/*
+ *  linux/include/linux/inet_lro.h
+ *
+ *  Large Receive Offload (ipv4 / tcp)
+ *
+ *  (C) Copyright IBM Corp. 2007
+ *
+ *  Authors:
+ *       Jan-Bernd Themann <themann@de.ibm.com>
+ *       Christoph Raisch <raisch@de.ibm.com>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef __INET_LRO_H_
+#define __INET_LRO_H_
+
+#include <net/ip.h>
+#include <net/tcp.h>
+
+/*
+ * LRO descriptor for a tcp session
+ */
+struct net_lro_desc {
+	struct sk_buff *parent;
+	struct sk_buff *last_skb;
+	struct iphdr *iph;
+	struct tcphdr *tcph;
+	struct vlan_group *vgrp;
+	u32 tcp_rcv_tsecr;
+	u32 tcp_rcv_tsval;
+	u32 tcp_ack;
+	u32 tcp_next_seq;
+	u32 skb_tot_frags_len;
+	u16 ip_tot_len;
+	u16 tcp_saw_tstamp; 		/* timestamps enabled */
+	u16 tcp_window;
+	u16 vlan_tag;
+	int skb_sg_cnt;			/* counts aggregated skbs */
+	int vlan_packet;
+	int active;
+};
+
+/*
+ * Large Receive Offload (LRO) Manager
+ *
+ * Fields must be set by driver
+ */
+
+struct net_lro_mgr {
+	int max_desc; /* Max number of LRO descriptors  */
+	int max_aggr; /* Max number of LRO packets to be aggregated */
+
+	struct net_lro_desc *lro_arr; /* Array of LRO descriptors */
+
+	/*
+	 * Optimized driver functions
+	 *
+	 * get_tcp_ip_hdr: returns tcp and ip header for packet in SKB
+	 */
+	int (*get_ip_tcp_hdr)(struct sk_buff *skb, struct iphdr **iphdr,
+			      struct tcphdr **tcph, void *priv);
+};
+
+/*
+ * Processes a SKB
+ *
+ * @lro_mgr: LRO manager to use
+ * @skb: SKB to aggregate
+ * @priv: Private data that may be used by driver functions
+ *        (for example get_tcp_ip_hdr)
+ */
+
+void lro_receive_skb(struct net_lro_mgr *lro_mgr,
+		     struct sk_buff *skb,
+		     void *priv);
+
+/*
+ * Processes a SKB with VLAN HW acceleration support
+ */
+
+void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
+				  struct sk_buff *skb,
+				  struct vlan_group *vgrp,
+				  u16 vlan_tag,
+				  void *priv);
+
+/*
+ * Forward all aggregated SKBs held by lro_mgr to network stack
+ */
+
+void lro_flush_all(struct net_lro_mgr *lro_mgr);
+
+#endif
diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
new file mode 100644
index 0000000..2b9d871
--- /dev/null
+++ b/net/ipv4/inet_lro.c
@@ -0,0 +1,311 @@
+/*
+ *  linux/net/ipv4/inet_lro.c
+ *
+ *  Large Receive Offload (ipv4 / tcp)
+ *
+ *  (C) Copyright IBM Corp. 2007
+ *
+ *  Authors:
+ *       Jan-Bernd Themann <themann@de.ibm.com>
+ *       Christoph Raisch <raisch@de.ibm.com>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+
+#include <linux/module.h>
+#include <linux/if_vlan.h>
+#include <linux/inet_lro.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Jan-Bernd Themann <themann@de.ibm.com>");
+MODULE_DESCRIPTION("Large Receive Offload (ipv4 / tcp)");
+
+#define TCP_PAYLOAD_LENGTH(iph, tcph) \
+(ntohs(iph->tot_len) - (iph->ihl << 2) - (tcph->doff << 2))
+
+#define IPH_LEN_WO_OPTIONS 5
+#define TCPH_LEN_WO_OPTIONS 5
+#define TCPH_LEN_W_TIMESTAMP 8
+
+/*
+ * Basic tcp checks whether packet is suitable for LRO
+ */
+
+static int lro_tcp_ip_check(struct sk_buff *skb, struct iphdr *iph,
+			    struct tcphdr *tcph, struct net_lro_desc *lro_desc)
+{
+        /* check ip header: packet length */
+        if (ntohs(iph->tot_len) > skb->len)
+		return -1;
+
+	if (TCP_PAYLOAD_LENGTH(iph, tcph) == 0)
+		return -1;
+
+	if (iph->ihl != IPH_LEN_WO_OPTIONS)
+		return -1;
+
+	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack || tcph->psh
+	    || tcph->rst || tcph->syn || tcph->fin)
+		return -1;
+
+	if (INET_ECN_is_ce(ipv4_get_dsfield(iph)))
+		return -1;
+
+	if (tcph->doff != TCPH_LEN_WO_OPTIONS
+	    && tcph->doff != TCPH_LEN_W_TIMESTAMP)
+		return -1;
+
+	/* check tcp options (only timestamp allowed) */
+	if (tcph->doff == TCPH_LEN_W_TIMESTAMP) {
+		u32 *topt = (u32 *)(tcph + 1);
+
+		if (*topt != htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16)
+				   | (TCPOPT_TIMESTAMP << 8)
+				   | TCPOLEN_TIMESTAMP))
+			return -1;
+
+		/* timestamp should be in right order */
+		topt++;
+		if (lro_desc && (ntohl(lro_desc->tcp_rcv_tsval) > ntohl(*topt)))
+			return -1;
+
+		/* timestamp reply should not be zero */
+		topt++;
+		if (*topt == 0)
+			return -1;
+	}
+
+	return 0;
+}
+
+static void lro_update_tcp_ip_header(struct net_lro_desc *lro_desc)
+{
+	struct iphdr *iph = lro_desc->iph;
+	struct tcphdr *tcph = lro_desc->tcph;
+	u32 *p;
+
+	tcph->ack_seq = lro_desc->tcp_ack;
+	tcph->window = lro_desc->tcp_window;
+
+	if (lro_desc->tcp_saw_tstamp) {
+		p = (u32 *)(tcph + 1);
+		*(p+2) = lro_desc->tcp_rcv_tsecr;
+	}
+
+	iph->tot_len = htons(lro_desc->ip_tot_len);
+	iph->check = 0;
+	iph->check = ip_fast_csum((u8 *)lro_desc->iph, iph->ihl);
+}
+
+static void lro_init_desc(struct net_lro_desc *lro_desc, struct sk_buff *skb,
+			  struct iphdr *iph, struct tcphdr *tcph,
+			  u16 vlan_tag, struct vlan_group *vgrp)
+{
+	u32 *ptr;
+	u32 tcp_data_len = TCP_PAYLOAD_LENGTH(iph, tcph);
+
+	lro_desc->parent = skb;
+	lro_desc->iph = iph;
+	lro_desc->tcph = tcph;
+	lro_desc->tcp_next_seq = ntohl(tcph->seq) + tcp_data_len;
+	lro_desc->tcp_ack = ntohl(tcph->ack_seq);
+
+	lro_desc->skb_sg_cnt = 1;
+	lro_desc->ip_tot_len = ntohs(iph->tot_len);
+
+	if (tcph->doff == 8) {
+		ptr = (u32 *)(tcph+1);
+		lro_desc->tcp_saw_tstamp = 1;
+		lro_desc->tcp_rcv_tsval = *(ptr+1);
+		lro_desc->tcp_rcv_tsecr = *(ptr+2);
+	}
+
+	lro_desc->vgrp = vgrp;
+	lro_desc->vlan_tag = vlan_tag;
+	lro_desc->active = 1;
+}
+
+static inline void lro_clear_desc(struct net_lro_desc *lro_desc)
+{
+	memset(lro_desc, 0, sizeof(struct net_lro_desc));
+}
+
+static void lro_add_packet(struct net_lro_desc *lro_desc, struct sk_buff *skb,
+			   struct iphdr *iph, struct tcphdr *tcph)
+{
+	struct sk_buff *parent = lro_desc->parent;
+	u32 *topt;
+	u32 tcp_data_len = TCP_PAYLOAD_LENGTH(iph, tcph);
+
+	lro_desc->skb_sg_cnt++;
+
+	lro_desc->ip_tot_len += tcp_data_len;
+	lro_desc->tcp_next_seq += tcp_data_len;
+	lro_desc->tcp_window = lro_desc->tcph->window;
+	lro_desc->tcp_ack = lro_desc->tcph->ack_seq;
+
+	/* don't update tcp_rcv_tsval, would not work with PAWS */
+	if (lro_desc->tcp_saw_tstamp) {
+		topt = (u32 *) (tcph + 1);
+		lro_desc->tcp_rcv_tsecr = *(topt + 2);
+	}
+
+	parent->len += tcp_data_len;
+	parent->data_len += tcp_data_len;
+
+	skb_pull(skb, (skb->len - tcp_data_len));
+	parent->truesize += skb->truesize;
+
+	if (lro_desc->last_skb)
+		lro_desc->last_skb->next = skb;
+	else
+		skb_shinfo(parent)->frag_list = skb;
+
+	lro_desc->last_skb = skb;
+
+	return;
+}
+
+static int lro_check_tcp_conn(struct net_lro_desc *lro_desc,
+			      struct iphdr *iph,
+			      struct tcphdr *tcph)
+{
+	if ((lro_desc->iph->saddr != iph->saddr)
+	    || (lro_desc->iph->daddr != iph->daddr)
+	    || (lro_desc->tcph->source != tcph->source)
+	    || (lro_desc->tcph->dest != tcph->dest))
+		return -1;
+	return 0;
+}
+
+static struct net_lro_desc *lro_get_desc(struct net_lro_mgr *mgr,
+					 struct net_lro_desc *lro_arr,
+					 struct iphdr *iph,
+					 struct tcphdr *tcph)
+{
+	struct net_lro_desc *lro_desc = NULL;
+	struct net_lro_desc *tmp;
+	int max_desc = mgr->max_desc;
+	int i;
+
+	for (i = 0; i < max_desc; i++) {
+		tmp = &lro_arr[i];
+		if (tmp->active)
+			if (!lro_check_tcp_conn(tmp, iph, tcph)) {
+				lro_desc = tmp;
+				goto out;
+			}
+	}
+
+	for (i = 0; i < max_desc; i++) {
+		if(!lro_arr[i].active) {
+			lro_desc = &lro_arr[i];
+			goto out;
+		}
+	}
+
+out:
+	return lro_desc;
+}
+
+static void lro_flush(struct net_lro_desc *lro_desc)
+{
+	lro_update_tcp_ip_header(lro_desc);
+
+	if (lro_desc->vgrp)
+		vlan_hwaccel_receive_skb(lro_desc->parent, lro_desc->vgrp,
+					 lro_desc->vlan_tag);
+	else
+		netif_receive_skb(lro_desc->parent);
+
+	lro_clear_desc(lro_desc);
+}
+
+void lro_flush_all(struct net_lro_mgr *lro_mgr)
+{
+	int i;
+	struct net_lro_desc *lro_desc = lro_mgr->lro_arr;
+
+	for (i = 0; i < lro_mgr->max_desc; i++) {
+		if (lro_desc[i].active)
+			lro_flush(&lro_desc[i]);
+	}
+}
+EXPORT_SYMBOL(lro_flush_all);
+
+int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
+		   struct vlan_group *vgrp, u16 vlan_tag, void *priv)
+{
+	struct net_lro_desc *lro_desc;
+        struct iphdr *iph;
+        struct tcphdr *tcph;
+
+	if (!lro_mgr->get_ip_tcp_hdr
+	    || lro_mgr->get_ip_tcp_hdr(skb, &iph, &tcph, priv))
+		goto out;
+
+	lro_desc = lro_get_desc(lro_mgr, lro_mgr->lro_arr, iph, tcph);
+	if (!lro_desc)
+		goto out;
+
+	if (!lro_desc->active) { /* start new lro session */
+		if (lro_tcp_ip_check(skb, iph, tcph, NULL))
+			goto out;
+
+		lro_init_desc(lro_desc, skb, iph, tcph, vlan_tag, vgrp);
+		return 0;
+	}
+
+	if (lro_desc->tcp_next_seq != ntohl(tcph->seq))
+		goto out2;
+
+	if (lro_tcp_ip_check(skb, iph, tcph, lro_desc))
+		goto out2;
+
+	lro_add_packet(lro_desc, skb, iph, tcph);
+
+	if (lro_desc->skb_sg_cnt >= lro_mgr->max_aggr)
+		lro_flush(lro_desc);
+
+	return 0;
+
+out2: /* send aggregated SKBs to stack */
+	lro_flush(lro_desc);
+
+out:  /* Original SKB has to be posted to stack */
+	return 1;
+}
+
+void lro_receive_skb(struct net_lro_mgr *lro_mgr,
+		     struct sk_buff *skb,
+		     void *priv)
+{
+	if (__lro_proc_skb(lro_mgr, skb, NULL, 0, priv))
+		netif_receive_skb(skb);
+}
+EXPORT_SYMBOL(lro_receive_skb);
+
+void lro_vlan_hwaccel_receive_skb(struct net_lro_mgr *lro_mgr,
+				  struct sk_buff *skb,
+				  struct vlan_group *vgrp,
+				  u16 vlan_tag,
+				  void *priv)
+{
+	if (__lro_proc_skb(lro_mgr, skb, vgrp, vlan_tag, priv))
+		vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
+}
+EXPORT_SYMBOL(lro_vlan_hwaccel_receive_skb);
-- 
1.5.2
