From: ggrundstrom@neteffect.com
Subject: [PATCH 3/14] nes: connection manager routines
Date: Tue, 7 Aug 2007 19:50:16 -0500
Message-ID: <200708080050.l780oGxo004694@neteffect.com>
Cc: ewg@lists.openfabrics.org, ggrundstrom@neteffect.com,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75.neteffect.com ([204.57.75.75]:50288 "EHLO
	localhost.localdomain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1763456AbXHHA4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 20:56:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetEffect connection manager routines.

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---
diff -Nurp NULL ofa_kernel-1.2/drivers/infiniband/hw/nes/nes_cm.c
--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.2/drivers/infiniband/hw/nes/nes_cm.c	2007-08-06 20:09:04.000000000 -0500
@@ -0,0 +1,2847 @@
+/*
+ * Copyright (c) 2006 - 2007 NetEffect, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+
+#define TCPOPT_TIMESTAMP 8
+
+#include <asm/atomic.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/init.h>
+#include <linux/if_arp.h>
+#include <linux/notifier.h>
+#include <linux/net.h>
+#include <linux/types.h>
+#include <linux/timer.h>
+#include <linux/time.h>
+#include <linux/delay.h>
+#include <linux/etherdevice.h>
+#include <linux/netdevice.h>
+#include <linux/random.h>
+#include <linux/list.h>
+#include <linux/threads.h>
+#include <linux/skbuff.h>
+
+#include <net/neighbour.h>
+#include <net/route.h>
+#include <net/ip_fib.h>
+
+#include "nes.h"
+
+static inline int mini_cm_accelerated(struct nes_cm_core *, struct nes_cm_node *);
+static struct nes_cm_listener *mini_cm_listen(struct nes_cm_core *,
+		struct nes_vnic *, struct nes_cm_info *);
+static int mini_cm_del_listen(struct nes_cm_core *, struct nes_cm_listener *);
+
+
+/* External CM API Interface */
+/* instance of function pointers for client API */
+/* set address of this instance to cm_core->cm_ops_p at cm_core alloc */
+struct nes_cm_ops nes_cm_api = {
+	mini_cm_accelerated,
+	mini_cm_listen,
+	mini_cm_del_listen,
+	mini_cm_connect,
+	mini_cm_close,
+	mini_cm_accept,
+	mini_cm_reject,
+	mini_cm_recv_pkt,
+	mini_cm_dealloc_core,
+	mini_cm_get,
+	mini_cm_set
+};
+
+struct nes_cm_core *g_cm_core_p;
+
+atomic_t cm_connects;
+atomic_t cm_accepts;
+atomic_t cm_disconnects;
+atomic_t cm_closes;
+atomic_t cm_connecteds;
+atomic_t cm_connect_reqs;
+atomic_t cm_rejects;
+
+
+/**
+ * create_event
+ */
+static struct nes_cm_event *create_event(struct nes_cm_node *node_p,
+		enum nes_cm_event_type type)
+{
+	struct nes_cm_event *event_p;
+
+	if(!node_p->cm_id)
+		return NULL;
+
+	/* allocate an empty event */
+	event_p = (struct nes_cm_event *)kzalloc(sizeof(struct nes_cm_event),
+			GFP_ATOMIC);
+	if (!event_p)
+		return(NULL);
+
+	event_p->type = type;
+	event_p->node_p = node_p;
+	event_p->cm_info.rem_addr = node_p->rem_addr;
+	event_p->cm_info.loc_addr = node_p->loc_addr;
+	event_p->cm_info.rem_port = node_p->rem_port;
+	event_p->cm_info.loc_port = node_p->loc_port;
+	event_p->cm_info.cm_id = node_p->cm_id;
+
+	dprintk("%s[%u] Created event_p=%p, type=%u, dst_addr=%08x[%x], src_addr=%08x[%x]\n",
+			__FUNCTION__, __LINE__, event_p, type,
+			event_p->cm_info.loc_addr, event_p->cm_info.loc_port,
+			event_p->cm_info.rem_addr, event_p->cm_info.rem_port);
+
+	nes_cm_post_event(event_p);
+	return(event_p);
+}
+
+
+/**
+ * send_mpa_request
+ */
+int send_mpa_request(struct nes_cm_node *node_p)
+{
+	struct sk_buff *skb_p;
+	int ret;
+
+	skb_p = get_free_pkt(node_p);
+	if (!skb_p) {
+		dprintk("%s:%s[%u] -- Failed to get a Free pkt\n",
+				__FILE__, __FUNCTION__, __LINE__);
+		return (-1);
+	}
+
+	/* send an MPA Request frame */
+	form_cm_frame(skb_p, node_p, NULL, 0, &node_p->mpa_frame_p,
+			node_p->mpa_frame_size, SET_ACK);
+
+	ret = schedule_nes_timer(node_p, skb_p, NES_TIMER_TYPE_SEND, 1);
+	if (ret < 0) {
+		return (ret);
+	}
+
+	dprintk("%s[%u] -- \n", __FUNCTION__, __LINE__);
+	return (0);
+}
+
+
+/**
+ * recv_mpa - process a received TCP pkt, we are expecting an
+ * IETF MPA frame
+ */
+static int parse_mpa(struct nes_cm_node *node_p, u8 *buffer, u32 len)
+{
+	struct ietf_mpa_frame *mpa_frame_p;
+
+	dprintk("%s[%u] Enter, node_p=%p\n", __FUNCTION__, __LINE__, node_p);
+	nes_dump_mem(buffer, len);
+
+	/* assume req frame is in tcp data payload */
+	if (len < sizeof(struct ietf_mpa_frame)) {
+		dprintk("The received ietf buffer was too small (%x)\n", len);
+		return (-1);
+	}
+
+	mpa_frame_p = (struct ietf_mpa_frame *)buffer;
+	node_p->mpa_frame_size = (u32)ntohs(mpa_frame_p->priv_data_len);
+
+	if (node_p->mpa_frame_size + sizeof(struct ietf_mpa_frame) != len) {
+		dprintk("The received ietf buffer was not right complete (%x + %x != %x)\n",
+				node_p->mpa_frame_size, (u32)sizeof(struct ietf_mpa_frame), len);
+		return (-1);
+	}
+
+	dprintk("%s[%u] -- recvd MPA Frame - with private data len = %u\n",
+			__FILE__, __LINE__, node_p->mpa_frame_size);
+
+	/* copy entire MPA frame to our node's frame */
+	memcpy(node_p->mpa_frame_b, buffer + sizeof(struct ietf_mpa_frame),
+			node_p->mpa_frame_size);
+	nes_dump_mem(&node_p->mpa_frame_p, node_p->mpa_frame_size);
+	dprintk("%s:%s[%u] -- Exit\n", __FILE__, __FUNCTION__, __LINE__);
+
+	return(0);
+}
+
+
+/**
+ * handle_exception_pkt - process an exception packet.
+ * We have been in a TSA state, and we have now received SW
+ * TCP/IP traffic should be a FIN request or IP pkt with options
+ */
+static int handle_exception_pkt(struct nes_cm_node *node_p,
+		struct sk_buff *skb_p)
+{
+	int ret = 0;
+	struct tcphdr *tcphdr_p = skb_p->h.th;
+
+	/* first check to see if this a FIN pkt */
+	if (tcphdr_p->fin) {
+		/* we need to ACK the FIN request */
+		send_ack(node_p);
+
+		/* check which side we are (client/server) and set next state accordingly */
+		if (node_p->tcp_cntxt.client)
+			node_p->state = NES_CM_STATE_CLOSING;
+		else {
+			/* we are the server side */
+			node_p->state = NES_CM_STATE_CLOSE_WAIT;
+			/* since this is a self contained CM we don't wait for */
+			/* an APP to close us, just send final FIN immediately */
+			ret = send_fin(node_p, NULL);
+			node_p->state = NES_CM_STATE_LAST_ACK;
+		}
+	} else {
+		ret = -EINVAL;
+	}
+
+	return(ret);
+}
+
+
+/**
+ * form_cm_frame - get a free packet and build empty frame Use
+ * node info to build.
+ */
+struct sk_buff *form_cm_frame(struct sk_buff *skb_p, struct nes_cm_node *node_p,
+		void *options, u32 optionsize, void *data, u32 datasize, u8 flags)
+{
+	struct tcphdr *tcphdr_p;
+	struct iphdr *iphdr_p;
+	struct ethhdr *ethhdr_p;
+	u8 *buf_p;
+	u16 packetsize = sizeof(*iphdr_p);
+
+	packetsize += sizeof(*tcphdr_p);
+	packetsize +=  optionsize + datasize;
+
+	memset(skb_p->data, 0x00, ETH_HLEN + sizeof(*iphdr_p) + sizeof(*tcphdr_p));
+
+	skb_p->len = 0;
+	buf_p = skb_put(skb_p, packetsize + ETH_HLEN);
+
+	ethhdr_p = (struct ethhdr *) buf_p;
+	buf_p += ETH_HLEN;
+
+	iphdr_p = skb_p->nh.iph = (struct iphdr *)buf_p;
+	buf_p += sizeof(*iphdr_p);
+
+	tcphdr_p  = skb_p->h.th = (struct tcphdr *) buf_p;
+	buf_p += sizeof(*tcphdr_p);
+
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,20))
+	skb_p->ip_summed = CHECKSUM_HW;
+#else
+	skb_p->ip_summed = CHECKSUM_PARTIAL;
+#endif
+	skb_p->protocol = ntohs(0x800);
+	skb_p->data_len = 0;
+	skb_p->mac.raw = skb_p->data;
+	skb_p->mac_len = ETH_HLEN;
+
+	memcpy(ethhdr_p->h_dest, node_p->rem_mac, ETH_ALEN);
+	memcpy(ethhdr_p->h_source, node_p->loc_mac, ETH_ALEN);
+	ethhdr_p->h_proto = htons(0x0800);
+
+	iphdr_p->version = IPVERSION;
+	iphdr_p->ihl = 5;		/* 5 * 4Byte words, IP headr len */
+	iphdr_p->tos = 0;
+	iphdr_p->tot_len = htons(packetsize);
+	iphdr_p->id = htons(++node_p->tcp_cntxt.loc_id);
+	
+	iphdr_p->frag_off = ntohs(0x4000);
+	iphdr_p->ttl = 0x40;
+	iphdr_p->protocol= 0x06;	/* IPPROTO_TCP */
+
+	iphdr_p->saddr = htonl(node_p->loc_addr);
+	iphdr_p->daddr = htonl(node_p->rem_addr);
+
+	tcphdr_p->source = htons(node_p->loc_port);
+	tcphdr_p->dest = htons(node_p->rem_port);
+	tcphdr_p->seq = htonl(node_p->tcp_cntxt.loc_seq_num);
+
+	if (flags & SET_ACK) {
+		node_p->tcp_cntxt.loc_ack_num = node_p->tcp_cntxt.rcv_nxt;
+		tcphdr_p->ack_seq = htonl(node_p->tcp_cntxt.loc_ack_num);
+		tcphdr_p->ack = 1;
+	} else
+		tcphdr_p->ack_seq = 0;
+
+	if (flags & SET_SYN) {
+		node_p->tcp_cntxt.loc_seq_num ++;
+		tcphdr_p->syn = 1;
+	} else
+		node_p->tcp_cntxt.loc_seq_num += datasize;	/* data (no headers) */
+
+	dprintk("%s[%u] Local seq # now %x\n", __FUNCTION__, __LINE__,
+			node_p->tcp_cntxt.loc_seq_num);
+	if (flags & SET_FIN)
+		tcphdr_p->fin = 1;
+
+	if (flags & SET_RST)
+		tcphdr_p->rst = 1;
+
+	tcphdr_p->doff = (u16) ((sizeof(*tcphdr_p) + optionsize + 3)>> 2);
+	tcphdr_p->window = htons(node_p->tcp_cntxt.rcv_wnd);
+	tcphdr_p->urg_ptr = 0;
+	if (optionsize)
+		memcpy(buf_p, options, optionsize);
+	buf_p += optionsize;
+	if (datasize)
+		memcpy(buf_p, data, datasize);
+
+	skb_shinfo(skb_p)->nr_frags = 0;
+
+	return(skb_p);
+}
+
+
+/**
+ * dump_pkt
+ */
+static void dump_pkt(struct sk_buff *skb_p)
+{
+	u8 *pkt_p;
+
+	if (!skb_p)
+		return;
+
+	pkt_p = (u8 *)skb_p->data;
+	/* dprintk("skb_p->head=%p, data=%p, tail=%p, end=%p,"
+			"skb_p->len=%u, data_len=%u\n",
+			skb_p->head, skb_p->data, skb_p->tail, skb_p->end,
+			skb_p->len, skb_p->data_len);
+	*/
+	nes_dump_mem(pkt_p, skb_p->len);
+
+	return;
+}
+
+
+/**
+ * print_core - dump a cm core
+ */
+static void print_core(struct nes_cm_core *core_p)
+{
+	dprintk("---------------------------------------------\n");
+	dprintk("CM Core  -- (core_p = %p )\n", core_p);
+	if (!core_p)
+		return;
+	dprintk("---------------------------------------------\n");
+	dprintk("Session ID    : %u \n", atomic_read(&core_p->session_id));
+
+	dprintk("State         : %u \n",  core_p->state);
+
+	dprintk("Tx Free cnt   : %u \n", skb_queue_len(&core_p->tx_free_list));
+	dprintk("Listen Nodes  : %u \n", atomic_read(&core_p->listen_node_cnt));
+	dprintk("Active Nodes  : %u \n", atomic_read(&core_p->node_cnt));
+
+	dprintk("core_p        : %p \n",  core_p);
+
+	dprintk("-------------- end core ---------------\n");
+	return;
+}
+
+
+/**
+ * schedule_nes_timer
+ */
+int schedule_nes_timer(struct nes_cm_node *node_p, struct sk_buff *skb_p,
+						enum nes_timer_type type, int send_retrans)
+{
+	unsigned long  flags;
+	struct nes_cm_core *core_p;
+	struct nes_timer_entry *new_send;
+	int ret = 0;
+	u32 was_timer_set;
+
+	new_send = kzalloc(sizeof(struct nes_timer_entry), GFP_ATOMIC);
+	if(!new_send)
+		return -1;
+	/* new_send->timetosend = currenttime */
+	new_send->retrycount = NES_DEFAULT_RETRYS;
+	new_send->retranscount = NES_DEFAULT_RETRANS;
+	new_send->skb = skb_p;
+	new_send->timetosend = jiffies;
+	new_send->type = type;
+	new_send->netdev = node_p->netdev_p;
+	new_send->send_retrans = send_retrans;
+
+	if(type == NES_TIMER_TYPE_CLOSE) {
+		dprintk("Scheduling Close: node_p = %p, new_send = %p.\n", node_p, new_send);
+		new_send->timetosend += (HZ/2); /* TODO: decide on the correct value here */
+		spin_lock_irqsave(&node_p->recv_list_lock, flags);
+		list_add_tail(&new_send->list, &node_p->recv_list);
+		spin_unlock_irqrestore(&node_p->recv_list_lock, flags);
+	}
+
+	if(type == NES_TIMER_TYPE_SEND)	{
+		dprintk("Sending Packet %p:\n", new_send);
+		new_send->seq_num = htonl(skb_p->h.th->seq);
+		dump_pkt(skb_p);
+		spin_lock_irqsave(&node_p->retrans_list_lock, flags);
+		list_add_tail(&new_send->list, &node_p->retrans_list);
+		spin_unlock_irqrestore(&node_p->retrans_list_lock, flags);
+	}
+	if(type == NES_TIMER_TYPE_RECV)	{
+		new_send->seq_num = htonl(skb_p->h.th->seq);
+		spin_lock_irqsave(&node_p->recv_list_lock, flags);
+		list_add_tail(&new_send->list, &node_p->recv_list);
+		spin_unlock_irqrestore(&node_p->recv_list_lock, flags);
+	}
+	core_p = node_p->core_p;
+
+	was_timer_set = timer_pending(&core_p->tcp_timer);
+
+	if(!was_timer_set || time_before(new_send->timetosend,
+									core_p->tcp_timer.expires)){
+		if(was_timer_set) {
+			del_timer(&core_p->tcp_timer);
+		}
+		core_p->tcp_timer.expires = new_send->timetosend;
+
+		add_timer(&core_p->tcp_timer);
+	}
+	return(ret);
+}
+
+
+/**
+ * nes_cm_timer_tick
+ */
+void nes_cm_timer_tick(unsigned long pass)
+{
+	unsigned long flags, qplockflags;
+	unsigned long nexttimeout = jiffies + NES_LONG_TIME;
+	struct iw_cm_id *cm_id;
+	struct nes_cm_node *node_p;
+	struct nes_timer_entry *send_entry, *recv_entry;
+	struct list_head *list_p_core, *list_p_core_temp, *list_p_node_temp, *list_p_node;
+	struct nes_cm_core *core_p = g_cm_core_p;
+	struct nes_qp *nesqp;
+	u32 settimer = 0;
+	int ret = NETDEV_TX_OK;
+
+	list_for_each_safe(list_p_node, list_p_core_temp, &core_p->connected_nodes) {
+		node_p = container_of(list_p_node, struct nes_cm_node, list);
+		spin_lock_irqsave(&node_p->recv_list_lock, flags);
+		list_for_each_safe(list_p_core, list_p_node_temp, &node_p->recv_list) {
+			recv_entry = container_of(list_p_core, struct nes_timer_entry, list);
+			if ((time_after(recv_entry->timetosend, jiffies)) &&
+					(recv_entry->type == NES_TIMER_TYPE_CLOSE)) {
+				if(nexttimeout > recv_entry->timetosend || !settimer) {
+					nexttimeout = recv_entry->timetosend;
+					settimer = 1;
+				}
+				continue;
+			}
+			list_del(&recv_entry->list);
+			cm_id = node_p->cm_id;
+			spin_unlock_irqrestore(&node_p->recv_list_lock, flags);
+			if(recv_entry->type == NES_TIMER_TYPE_CLOSE) {
+				nesqp = (struct nes_qp *)recv_entry->skb;
+				cm_id->rem_ref(cm_id);
+				spin_lock_irqsave(&nesqp->lock, qplockflags);
+				if (nesqp->cm_id) {
+					dprintk("%s: QP%u: cm_id = %p: ****** HIT A NES_TIMER_TYPE_CLOSE"
+							" with something to do!!! ******\n",
+							__FUNCTION__, nesqp->hwqp.qp_id, cm_id);
+					nesqp->hw_tcp_state = NES_AEQE_TCP_STATE_CLOSED;
+					nesqp->last_aeq = NES_AEQE_AEID_RESET_SENT;
+					nesqp->ibqp_state = IB_QPS_ERR;
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					nes_cm_disconn(nesqp);
+				} else {
+					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+					dprintk("%s: QP%u: cm_id = %p: ****** HIT A NES_TIMER_TYPE_CLOSE"
+							" with nothing to do!!! ******\n",
+							__FUNCTION__, nesqp->hwqp.qp_id, cm_id);
+					nes_rem_ref(&nesqp->ibqp);
+				}
+			}
+			else if(recv_entry->type == NES_TIMER_TYPE_RECV) {
+				dprintk("Processing Packet (%p):\n", recv_entry->skb->data);
+				dump_pkt(recv_entry->skb);
+				process_packet(node_p, recv_entry->skb, core_p);
+				dev_kfree_skb_any(recv_entry->skb);
+			}
+			kfree(recv_entry);
+			spin_lock_irqsave(&node_p->recv_list_lock, flags);
+		}
+		spin_unlock_irqrestore(&node_p->recv_list_lock, flags);
+
+		spin_lock_irqsave(&node_p->retrans_list_lock, flags);
+		list_for_each_safe(list_p_core, list_p_node_temp, &node_p->retrans_list) {
+			send_entry = container_of(list_p_core, struct nes_timer_entry, list);
+			if(time_after(send_entry->timetosend, jiffies)) {
+				if(nexttimeout > send_entry->timetosend || !settimer) {
+					nexttimeout = send_entry->timetosend;
+					settimer = 1;
+				}
+				continue;
+			}
+			list_del(&send_entry->list);
+			spin_unlock_irqrestore(&node_p->retrans_list_lock, flags);
+			if(send_entry->type == NES_TIMER_NODE_CLEANUP){
+				dprintk("!send - %p-> next/prev=%p,%p, tts=%lx, skb=%p, type=%x,"
+						" retry=%x, retrans=%x, context=%x, seq=%x\n",
+						send_entry, send_entry->list.next, send_entry->list.prev,
+						send_entry->timetosend, send_entry->skb, send_entry->type,
+						send_entry->retrycount, send_entry->retranscount,
+						send_entry->context, send_entry->seq_num);
+				spin_lock_irqsave(&node_p->retrans_list_lock, flags);
+				continue;
+			}
+			if(send_entry->seq_num < node_p->tcp_cntxt.rem_ack_num ||
+				node_p->accelerated) {
+					dev_kfree_skb_any(send_entry->skb);
+					kfree(send_entry);
+					spin_lock_irqsave(&node_p->retrans_list_lock, flags);
+					continue;
+			}
+
+			if(!send_entry->retranscount || !send_entry->retrycount) {
+				dev_kfree_skb_any(send_entry->skb);
+				kfree(send_entry);
+				create_event(node_p, NES_CM_EVENT_ABORTED);
+				spin_lock_irqsave(&node_p->retrans_list_lock, flags);
+				continue;
+			}
+			atomic_inc(&send_entry->skb->users);
+			ret = nes_nic_cm_xmit(send_entry->skb, node_p->netdev_p);
+			if(ret != NETDEV_TX_OK) {
+				atomic_dec(&send_entry->skb->users);
+				send_entry->retrycount--;
+				nexttimeout = jiffies + NES_SHORT_TIME;
+				settimer = 1;
+				spin_lock_irqsave(&node_p->retrans_list_lock, flags);
+				list_add(&send_entry->list, &node_p->retrans_list);
+				break;
+			}
+			dprintk("Packet Sent:\n");
+			dump_pkt(send_entry->skb);
+			if(send_entry->send_retrans) {
+				send_entry->retranscount--;
+				send_entry->timetosend = jiffies + NES_RETRY_TIMEOUT;
+				if(nexttimeout > send_entry->timetosend || !settimer) {
+					nexttimeout = send_entry->timetosend;
+					settimer = 1;
+				}
+				spin_lock_irqsave(&node_p->retrans_list_lock, flags);
+				list_add(&send_entry->list, &node_p->retrans_list);
+				continue;
+			}
+			else {
+				dev_kfree_skb_any(send_entry->skb);
+				kfree(send_entry);
+				spin_lock_irqsave(&node_p->retrans_list_lock, flags);
+				continue;
+			}
+		}
+		spin_unlock_irqrestore(&node_p->retrans_list_lock, flags);
+
+		if(ret != NETDEV_TX_OK)
+			break;
+	}
+
+	if(settimer)
+	{
+		if(timer_pending(&core_p->tcp_timer)) {
+			del_timer(&core_p->tcp_timer);
+		}
+		core_p->tcp_timer.expires  = nexttimeout;
+		add_timer(&core_p->tcp_timer);
+	}
+}
+
+
+/**
+ * send_syn
+ */
+int send_syn(struct nes_cm_node *node_p, u32 sendack)
+{
+	int ret;
+	int flags = SET_SYN;
+	struct sk_buff *skb_p;
+	char optionsbuffer[sizeof(struct option_mss) +
+			sizeof(struct option_windowscale) +
+			sizeof(struct option_base) + 1];
+
+	int optionssize = 0;
+	/* Sending MSS option */
+	union all_known_options *options;
+
+	if (!node_p)
+		return(-EINVAL);
+
+	options = (union all_known_options *)&optionsbuffer[optionssize];
+	options->as_mss.optionnum = OPTION_NUMBER_MSS;
+	options->as_mss.length = sizeof(struct option_mss);
+	options->as_mss.mss = htons(node_p->tcp_cntxt.mss);
+	optionssize += sizeof(struct option_mss);
+
+	options = (union all_known_options *)&optionsbuffer[optionssize];
+	options->as_windowscale.optionnum = OPTION_NUMBER_WINDOW_SCALE;
+	options->as_windowscale.length = sizeof(struct option_windowscale);
+	options->as_windowscale.shiftcount = 2;
+	optionssize += sizeof(struct option_windowscale);
+
+	if(sendack && !(NES_DRV_OPT_SUPRESS_OPTION_BC & nes_drv_opt)) {
+		options = (union all_known_options *)&optionsbuffer[optionssize];
+		options->as_base.optionnum = OPTION_NUMBER_WRITE0;
+		options->as_base.length = sizeof(struct option_base);
+		optionssize += sizeof(struct option_base);
+		/* we need the size to be a multiple of 4 */
+		options = (union all_known_options *)&optionsbuffer[optionssize];
+		options->as_end = 1;
+		optionssize += 1;
+		options = (union all_known_options *)&optionsbuffer[optionssize];
+		options->as_end = 1;
+		optionssize += 1;
+	}
+
+	options = (union all_known_options *)&optionsbuffer[optionssize];
+	options->as_end = OPTION_NUMBER_END;
+	optionssize += 1;
+
+	dprintk("%s: Enter\n", __FUNCTION__);
+
+	skb_p = get_free_pkt(node_p);
+	if (!skb_p) {
+		dprintk("%s:%s[%u] -- Failed to get a Free pkt\n",__FILE__, __FUNCTION__, __LINE__);
+		return (-1);
+	}
+
+	if (sendack)
+		flags |= SET_ACK;
+
+	form_cm_frame(skb_p, node_p, optionsbuffer, optionssize, NULL, 0, flags);
+	ret = schedule_nes_timer(node_p, skb_p, NES_TIMER_TYPE_SEND, 1);
+
+	return(ret);
+}
+
+
+/**
+ * send_reset
+ */
+int send_reset(struct nes_cm_node *node_p)
+{
+	int ret;
+	struct sk_buff *skb_p = get_free_pkt(node_p);
+	if (!skb_p) {
+		dprintk("%s:%s[%u] -- Failed to get a Free pkt\n",
+				__FILE__, __FUNCTION__, __LINE__);
+		return (-1);
+	}
+
+	form_cm_frame(skb_p, node_p, NULL, 0, NULL, 0, SET_RST);
+	ret = schedule_nes_timer(node_p, skb_p, NES_TIMER_TYPE_SEND, 0);
+
+	return(ret);
+}
+
+
+/**
+ * send_ack
+ */
+int send_ack(struct nes_cm_node *node_p)
+{
+	int ret;
+	struct sk_buff *skb_p = get_free_pkt(node_p);
+	if (!skb_p) {
+		dprintk("%s:%s[%u] -- Failed to get a Free pkt\n",
+				__FILE__, __FUNCTION__, __LINE__);
+		return (-1);
+	}
+
+	form_cm_frame(skb_p, node_p, NULL, 0, NULL, 0, SET_ACK);
+	ret = schedule_nes_timer(node_p, skb_p, NES_TIMER_TYPE_SEND, 0);
+
+	return(ret);
+}
+
+
+/**
+ * send_fin
+ */
+int send_fin(struct nes_cm_node *node_p, struct sk_buff *skb_p)
+{
+	int ret;
+
+	/* if we didn't get a frame get one */
+	if (!skb_p)
+		skb_p = get_free_pkt(node_p);
+
+	if (!skb_p) {
+		dprintk("%s:%s[%u] -- Failed to get a Free pkt\n",
+				__FILE__, __FUNCTION__, __LINE__);
+		return (-1);
+	}
+
+	form_cm_frame(skb_p, node_p, NULL, 0, NULL, 0, SET_ACK | SET_FIN);
+	ret = schedule_nes_timer(node_p, skb_p, NES_TIMER_TYPE_SEND, 1);
+
+	return(ret);
+}
+
+
+/**
+ * get_free_pkt
+ */
+struct sk_buff *get_free_pkt(struct nes_cm_node *node_p)
+{
+	struct sk_buff *skb_p, *new_skb_p;
+
+	/* check to see if we need to repopulate the free tx pkt queue */
+	if (skb_queue_len(&node_p->core_p->tx_free_list) < NES_CM_FREE_PKT_LO_WATERMARK) {
+		while (skb_queue_len(&node_p->core_p->tx_free_list) <
+				node_p->core_p->free_tx_pkt_max) {
+			/* replace the frame we took, we won't get it back */
+			new_skb_p = dev_alloc_skb(node_p->core_p->mtu);
+
+			/* add a replacement frame to the free tx list head */
+			skb_queue_head(&node_p->core_p->tx_free_list, new_skb_p);
+		}
+	}
+
+	skb_p = skb_dequeue(&node_p->core_p->tx_free_list);
+	return(skb_p);
+}
+
+
+/**
+ * make_hashkey - generate hash key from node tuple
+ */
+static inline int make_hashkey(u16 loc_port, nes_addr_t loc_addr, u16 rem_port,
+		nes_addr_t rem_addr)
+{
+	u32 hashkey = 0;
+
+	hashkey = loc_addr + rem_addr + loc_port + rem_port;
+	hashkey = (hashkey % NES_CM_HASHTABLE_SIZE);
+
+	return(hashkey);
+}
+
+
+/**
+ * find_node - find a cm node that matches the reference cm node
+ */
+static struct nes_cm_node * find_node(struct nes_cm_core *core_p,
+		u16 rem_port, nes_addr_t rem_addr, u16 loc_port, nes_addr_t loc_addr)
+{
+	u32 hashkey;
+	struct list_head *list_p;
+	struct list_head *hte_p;
+	struct nes_cm_node *node_p;
+
+	/* make a hash index key for this packet */
+	hashkey = make_hashkey(loc_port, loc_addr, rem_port, rem_addr);
+
+	/* get a handle on the hte */
+	
+	hte_p = &core_p->connected_nodes;
+
+	dprintk("%s[%u] -- Searching for an owner node:%x:%x from core %p->%p\n",
+			__FILE__, __LINE__, loc_addr, loc_port, core_p, hte_p);
+
+	/* walk list and find cm_node associated with this session ID */
+	list_for_each(list_p, hte_p)
+	{
+		node_p = container_of(list_p, struct nes_cm_node, list);
+		/* compare quad, return node handle if a match */
+		dprintk("finding node %x:%x =? %x:%x ^ %x:%x =? %x:%x\n",
+				node_p->loc_addr, node_p->loc_port,
+				loc_addr, loc_port,
+				node_p->rem_addr, node_p->rem_port,
+				rem_addr, rem_port);
+		if ((node_p->loc_addr == loc_addr) && (node_p->loc_port == loc_port) &&
+				(node_p->rem_addr == rem_addr) && (node_p->rem_port == rem_port)) {
+			return(node_p);
+		}
+	}
+
+	/* no owner node */
+	return(NULL);
+}
+
+
+/**
+ * find_listener - find a cm node listening on this addr-port pair
+ */
+static struct nes_cm_listener * find_listener(struct nes_cm_core *core_p,
+		nes_addr_t dst_addr, u16 dst_port)
+{
+	int flags;
+	struct list_head   *list_p;
+	struct nes_cm_listener *listen_node_p;
+
+	/* walk list and find cm_node associated with this session ID */
+	spin_lock_irqsave(&core_p->listen_list_lock, flags);
+	list_for_each(list_p, &core_p->listen_list.list) {
+		listen_node_p = container_of(list_p, struct nes_cm_listener, list);;
+		/* compare node pair, return node handle if a match */
+		if (((listen_node_p->loc_addr == dst_addr) ||
+				listen_node_p->loc_addr == 0x00000000) &&
+				(listen_node_p->loc_port == dst_port)) {
+			atomic_inc(&listen_node_p->ref_count);
+			spin_unlock_irqrestore(&core_p->listen_list_lock, flags);
+			return(listen_node_p);
+		}
+	}
+	spin_unlock_irqrestore(&core_p->listen_list_lock, flags);
+	dprintk("Unable to find listener- %x:%x\n",
+			dst_addr, dst_port);
+
+	/* no listener */
+	return(NULL);
+}
+
+
+/**
+ * add_hte_node - add a cm node to the hash table
+ */
+static int add_hte_node(struct nes_cm_core *core_p, struct nes_cm_node *node_p)
+{
+	unsigned long flags;
+	u32 hashkey;
+	struct list_head *hte_p;
+
+	if (!node_p || !core_p)
+		return(-EINVAL);
+
+	dprintk("%s:%s[%u] -- Adding Node to Active Connection HT\n",
+			__FILE__, __FUNCTION__, __LINE__);
+
+	/* first, make an index into our hash table */
+	hashkey = make_hashkey(node_p->loc_port, node_p->loc_addr,
+			node_p->rem_port, node_p->rem_addr);
+	node_p->hashkey = hashkey;
+
+	spin_lock_irqsave(&core_p->ht_lock, flags);
+
+	/* get a handle on the hash table element (list head for this slot) */
+	hte_p = &core_p->connected_nodes;
+	list_add_tail(&node_p->list, hte_p);
+	atomic_inc(&core_p->ht_node_cnt);
+
+	spin_unlock_irqrestore(&core_p->ht_lock, flags);
+
+	return(0);
+}
+
+
+/**
+ * del_hte_node - delete a cm node from the hash table
+ */
+int del_hte_node(struct nes_cm_core *core_p, struct nes_cm_node *node_p)
+{
+	unsigned long flags;
+
+	if (!node_p)
+		return(-EINVAL);
+	dprintk("%s[%u] -- (%p, %p)\n", __FILE__, __LINE__, core_p, node_p);
+
+	spin_lock_irqsave(&node_p->core_p->ht_lock, flags);
+	list_del(&node_p->list);
+	spin_unlock_irqrestore(&node_p->core_p->ht_lock, flags);
+
+	atomic_dec(&core_p->ht_node_cnt);
+	dprintk("%s[%u] -- \n", __FILE__,__LINE__);
+
+	return(0);
+}
+
+
+/**
+ * mini_cm_del_listen
+ */
+static int mini_cm_del_listen(struct nes_cm_core *core_p,
+		struct nes_cm_listener *node_p)
+{
+	int ret = 1;
+	struct nes_vnic *nesvnic;
+	struct iw_cm_id *cm_id;
+	int flags;
+
+	spin_lock_irqsave(&core_p->listen_list_lock, flags);
+	if(!atomic_dec_return(&node_p->ref_count)) {
+		list_del(&node_p->list);
+
+		/* decrement our listen node count */
+		atomic_dec(&core_p->listen_node_cnt);
+
+		spin_unlock_irqrestore(&core_p->listen_list_lock, flags);
+
+		cm_id = node_p->cm_id;
+		if(cm_id && cm_id->device) {
+			nesvnic = to_nesvnic(cm_id->device);
+			if (nesvnic) {
+				nes_manage_apbvt(nesvnic, node_p->loc_port,
+					PCI_FUNC(nesvnic->nesdev->pcidev->devfn), NES_MANAGE_APBVT_DEL);
+			}
+		}
+		dprintk("%s[%u] -- \n",__FILE__,__LINE__);
+		kfree(node_p);
+		ret = 0;
+	} else {
+		spin_unlock_irqrestore(&core_p->listen_list_lock, flags);
+	}
+	return(ret);
+}
+
+
+/**
+ * mini_cm_accelerated
+ */
+static inline int mini_cm_accelerated(struct nes_cm_core *core_p,
+		struct nes_cm_node *node_p)
+{
+	u32 was_timer_set;
+	node_p->accelerated = 1;
+	was_timer_set = timer_pending(&core_p->tcp_timer);
+	if(!was_timer_set){
+		core_p->tcp_timer.expires = jiffies + NES_SHORT_TIME;
+		add_timer(&core_p->tcp_timer);
+	}
+	return(0);
+}
+
+
+/**
+ * make_cm_node - create a new instance of a cm node
+ */
+static struct nes_cm_node *make_cm_node(struct nes_cm_core *core_p,
+		struct nes_vnic *nesvnic, struct nes_cm_info *nfo_p,
+		struct nes_cm_listener *listen_p)
+{
+	struct nes_cm_node *node_p;
+	struct timespec ts;
+	int arpindex = 0;
+	struct nes_device *nesdev;
+	struct nes_adapter *nesadapter;
+
+	/* create an hte and cm_node for this instance */
+	node_p = (struct nes_cm_node *)kzalloc(sizeof(*node_p), GFP_ATOMIC);
+	if (!node_p)
+		return NULL;
+
+	memset(node_p, 0, sizeof(struct nes_cm_node));
+	/* set our node specific transport info */
+	node_p->loc_addr = nfo_p->loc_addr;
+	node_p->rem_addr = nfo_p->rem_addr;
+	node_p->loc_port = nfo_p->loc_port;
+	node_p->rem_port = nfo_p->rem_port;
+	node_p->send_write0 = send_first;
+	dprintk("Make node addresses : loc = %x:%x, rem = %x:%x\n",
+			node_p->loc_addr, node_p->loc_port, node_p->rem_addr, node_p->rem_port);
+	node_p->listen_p = listen_p;
+	node_p->netdev_p = nesvnic->netdev;
+	node_p->cm_id = nfo_p->cm_id;
+	memcpy(node_p->loc_mac, nesvnic->netdev->dev_addr, ETH_ALEN);
+
+	INIT_LIST_HEAD(&node_p->retrans_list);
+	spin_lock_init(&node_p->retrans_list_lock);
+	INIT_LIST_HEAD(&node_p->recv_list);
+	spin_lock_init(&node_p->recv_list_lock);
+
+	node_p->loopbackpartner = NULL;
+	atomic_set(&node_p->ref_count, 1);
+	node_p->listener = NULL;
+	/* associate our parent CM core */
+	node_p->core_p = core_p;
+	node_p->tcp_cntxt.loc_id = NES_CM_DEF_LOCAL_ID;
+	node_p->tcp_cntxt.rcv_wnd = NES_CM_DEFAULT_RCV_WND;
+	ts = current_kernel_time();
+	node_p->tcp_cntxt.loc_seq_num = cpu_to_le32(htonl(ts.tv_nsec));
+	node_p->tcp_cntxt.mss = nesvnic->max_frame_size - sizeof(struct iphdr) -
+			sizeof(struct tcphdr) - ETH_HLEN;
+	dprintk("%s: Setting MSS to %u.\n",__FUNCTION__, node_p->tcp_cntxt.mss);
+	node_p->tcp_cntxt.rcv_nxt = 0;
+	/* get a unique session ID , add thread_id to an upcounter to handle race */
+	atomic_inc(&core_p->node_cnt);
+	atomic_inc(&core_p->session_id);
+	node_p->session_id = (u32)(atomic_read(&core_p->session_id) + current->tgid);
+	node_p->conn_type = nfo_p->conn_type;
+
+	/* get some device handles, for arp lookup */
+	nesdev = nesvnic->nesdev;
+	nesadapter = nesdev->nesadapter;
+
+	/* get the mac addr for the remote node */
+	arpindex = nes_arp_table(nesdev, node_p->rem_addr, NULL, NES_ARP_RESOLVE);
+	if (arpindex < 0) {
+		dprintk("%s[%d] -- IP addr %x NOT found in ARP table\n",
+				__FILE__, __LINE__, node_p->rem_addr);
+		kfree(node_p);
+		return(NULL);
+	}
+
+	/* copy the mac addr to node context */
+	memcpy(node_p->rem_mac, nesadapter->arp_table[arpindex].mac_addr, ETH_ALEN);
+	dprintk("%s[%u] -- Remote mac addr from arp table:%02x, %02x, %02x, %02x, %02x, %02x\n",
+			__FILE__, __LINE__,
+			node_p->rem_mac[0], node_p->rem_mac[1],
+			node_p->rem_mac[2], node_p->rem_mac[3],
+			node_p->rem_mac[4], node_p->rem_mac[5]);
+
+	add_hte_node(core_p, node_p);
+
+	return(node_p);
+}
+
+
+/**
+ * destroy_cm_node - destroy an instance of a cm node
+ */
+static int destroy_cm_node(struct nes_cm_core *core_p,
+		struct nes_cm_node *node_p)
+{
+	unsigned long flags, qplockflags;
+	struct nes_timer_entry *send_entry;
+	struct nes_timer_entry *recv_entry;
+	struct iw_cm_id *cm_id;
+	struct list_head *list_p_core, *list_p_node_temp;
+	struct nes_qp *nesqp;
+	struct nes_vnic *nesvnic;
+
+	if (!node_p)
+		return(-EINVAL);
+	del_hte_node(core_p, node_p);
+
+	spin_lock_irqsave(&node_p->retrans_list_lock, flags);
+	list_for_each_safe(list_p_core, list_p_node_temp, &node_p->retrans_list) {
+		send_entry = container_of(list_p_core, struct nes_timer_entry, list);
+		list_del(&send_entry->list);
+		spin_unlock_irqrestore(&node_p->retrans_list_lock, flags);
+		dev_kfree_skb_any(send_entry->skb);
+		kfree(send_entry);
+		spin_lock_irqsave(&node_p->retrans_list_lock, flags);
+		continue;
+	}
+	spin_unlock_irqrestore(&node_p->retrans_list_lock, flags);
+
+	spin_lock_irqsave(&node_p->recv_list_lock, flags);
+	list_for_each_safe(list_p_core, list_p_node_temp, &node_p->recv_list) {
+		recv_entry = container_of(list_p_core, struct nes_timer_entry, list);
+		list_del(&recv_entry->list);
+		cm_id = node_p->cm_id;
+		spin_unlock_irqrestore(&node_p->recv_list_lock, flags);
+		if(recv_entry->type == NES_TIMER_TYPE_CLOSE) {
+			nesqp = (struct nes_qp *)recv_entry->skb;
+			cm_id->rem_ref(cm_id);
+			spin_lock_irqsave(&nesqp->lock, qplockflags);
+			if (nesqp->cm_id) {
+				dprintk("%s: QP%u: cm_id = %p: ****** HIT A NES_TIMER_TYPE_CLOSE"
+						" with something to do!!! ******\n",
+						__FUNCTION__, nesqp->hwqp.qp_id, cm_id);
+				nesqp->hw_tcp_state = NES_AEQE_TCP_STATE_CLOSED;
+				nesqp->last_aeq = NES_AEQE_AEID_RESET_SENT;
+				nesqp->ibqp_state = IB_QPS_ERR;
+				spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+				nes_cm_disconn(nesqp);
+			} else {
+				spin_unlock_irqrestore(&nesqp->lock, qplockflags);
+				dprintk("%s: QP%u: cm_id = %p: ****** HIT A NES_TIMER_TYPE_CLOSE"
+						" with nothing to do!!! ******\n",
+						__FUNCTION__, nesqp->hwqp.qp_id, cm_id);
+				nes_rem_ref(&nesqp->ibqp);
+			}
+		}
+		else if(recv_entry->type == NES_TIMER_TYPE_RECV) {
+			dev_kfree_skb_any(recv_entry->skb);
+		}
+		kfree(recv_entry);
+		spin_lock_irqsave(&node_p->recv_list_lock, flags);
+	}
+	spin_unlock_irqrestore(&node_p->recv_list_lock, flags);
+
+	if(node_p->listen_p) {
+		mini_cm_del_listen(core_p, node_p->listen_p);
+	}
+	else {
+		cm_id = node_p->cm_id;
+		if(cm_id && cm_id->device) {
+			nesvnic = to_nesvnic(cm_id->device);
+			if (nesvnic) {
+				nes_manage_apbvt(nesvnic, node_p->loc_port,
+					PCI_FUNC(nesvnic->nesdev->pcidev->devfn), NES_MANAGE_APBVT_DEL);
+			}
+		}
+	}
+	if(!atomic_dec_return(&node_p->ref_count)) {
+		kfree(node_p);
+		atomic_dec(&core_p->node_cnt);
+	}
+	return(0);
+}
+
+
+/**
+ * process_options
+ */
+static void process_options(struct nes_cm_node *node_p, u8 *optionsloc, u32 optionsize)
+{
+	u32 tmp;
+	u32 offset = 0;
+	union all_known_options *all_options;
+
+	while(offset < optionsize)
+	{
+		all_options = (union all_known_options *)(optionsloc + offset);
+		switch(all_options->as_base.optionnum)
+		{
+		case OPTION_NUMBER_END:
+			offset = optionsize;
+			break;
+		case OPTION_NUMBER_NONE:
+			offset += 1;
+			continue;
+		case OPTION_NUMBER_MSS:
+			tmp = htons(all_options->as_mss.mss);
+			if(tmp < node_p->tcp_cntxt.mss)
+				node_p->tcp_cntxt.mss = tmp;
+			break;
+		case OPTION_NUMBER_WINDOW_SCALE:
+			node_p->tcp_cntxt.snd_wscale = all_options->as_windowscale.shiftcount;
+			node_p->tcp_cntxt.rcv_wscale = NES_CM_DEFAULT_RCV_WND_SCALE;
+			node_p->tcp_cntxt.rcv_wnd = NES_CM_DEFAULT_RCV_WND_SCALED >>
+					NES_CM_DEFAULT_RCV_WND_SCALE;
+			break;
+		case OPTION_NUMBER_WRITE0:
+			node_p->send_write0 = 1;
+			break;
+		default:
+			dprintk("TCP Option not understood: %x\n", all_options->as_base.optionnum);
+			break;
+		}
+		offset += all_options->as_base.length;
+	}
+}
+
+
+/**
+ * process_packet
+ */
+int process_packet(struct nes_cm_node *node_p, struct sk_buff *skb_p,
+		struct nes_cm_core *core_p)
+{
+	int optionsize;
+	int datasize;
+	int ret = 0;
+	struct tcphdr *tcphdr_p = skb_p->h.th;
+	u32 inc_sequence;
+
+	if(!tcphdr_p)
+		return -1;
+
+	if (tcphdr_p->rst) {
+		dprintk("%s[%u] Received Reset, node_p = %p, state = %u.\n",
+				__FUNCTION__, __LINE__, node_p, node_p->state);
+		switch(node_p->state) {
+			case NES_CM_STATE_TSA:
+			case NES_CM_STATE_CLOSED:
+				break;
+			case NES_CM_STATE_LISTENING:
+			case NES_CM_STATE_SYN_RCVD:
+				mini_cm_close(core_p, node_p);
+				break;
+			case NES_CM_STATE_ONE_SIDE_ESTABLISHED:
+			case NES_CM_STATE_ESTABLISHED:
+			case NES_CM_STATE_MPAREQ_SENT:
+			default:
+				// create event
+				node_p->state = NES_CM_STATE_CLOSED;
+				create_event(node_p, NES_CM_EVENT_ABORTED);
+				break;
+
+		}
+		return -1;
+	}
+
+	optionsize = (tcphdr_p->doff << 2) - sizeof(struct tcphdr);
+
+	skb_pull(skb_p, skb_p->nh.iph->ihl << 2);
+	skb_pull(skb_p, tcphdr_p->doff << 2);
+
+	datasize = skb_p->len;
+	inc_sequence = ntohl(tcphdr_p->seq);
+
+	if (!tcphdr_p->syn && (inc_sequence != node_p->tcp_cntxt.rcv_nxt)) {
+		return (-1);
+	}
+
+	node_p->tcp_cntxt.rcv_nxt = inc_sequence + datasize;
+	node_p->tcp_cntxt.snd_wnd = htons(tcphdr_p->window) <<
+			node_p->tcp_cntxt.snd_wscale;
+
+	if (node_p->tcp_cntxt.snd_wnd > node_p->tcp_cntxt.max_snd_wnd) {
+		node_p->tcp_cntxt.max_snd_wnd = node_p->tcp_cntxt.snd_wnd;
+	}
+
+	if (optionsize) {
+		u8 *optionsloc = (u8 *) &tcphdr_p[1];
+		process_options(node_p, optionsloc, optionsize);
+	}
+
+	if (tcphdr_p->ack) {
+		node_p->tcp_cntxt.rem_ack_num = ntohl(tcphdr_p->ack_seq);
+		switch (node_p->state) {
+			case NES_CM_STATE_SYN_RCVD:
+			case NES_CM_STATE_SYN_SENT:
+				/* read and stash current sequence number */
+				if (node_p->tcp_cntxt.rem_ack_num > node_p->tcp_cntxt.loc_seq_num) {
+					dprintk("ERROR - node_p->tcp_cntxt.rem_ack_num >"
+							" node_p->tcp_cntxt.loc_seq_num\n");
+					send_reset(node_p);
+					return (0);
+				}
+				if (node_p->conn_type == NES_CM_IWARP_CONN_TYPE) {
+					if (node_p->state == NES_CM_STATE_SYN_SENT)
+						node_p->state = NES_CM_STATE_ONE_SIDE_ESTABLISHED;
+					else
+						node_p->state = NES_CM_STATE_ESTABLISHED;
+				} else {
+					create_event(node_p, NES_CM_EVENT_MPA_REQ);
+					/* we are done handling this state, set node to a TSA state */
+					node_p->state = NES_CM_STATE_TSA;
+				}
+				break;
+			case NES_CM_STATE_LAST_ACK:
+				node_p->state = NES_CM_STATE_CLOSED;
+				break;
+			case NES_CM_STATE_FIN_WAIT1:
+				node_p->state = NES_CM_STATE_FIN_WAIT2;
+				break;
+			case NES_CM_STATE_CLOSING:
+				node_p->state = NES_CM_STATE_TIME_WAIT;
+				/* need to schedule this to happen in 2MSL timeouts */
+				node_p->state = NES_CM_STATE_CLOSED;
+				break;
+			case NES_CM_STATE_ONE_SIDE_ESTABLISHED:
+			case NES_CM_STATE_ESTABLISHED:
+			case NES_CM_STATE_MPAREQ_SENT:
+			case NES_CM_STATE_CLOSE_WAIT:
+			case NES_CM_STATE_TIME_WAIT:
+			case NES_CM_STATE_CLOSED:
+				break;
+			case NES_CM_STATE_LISTENING:
+				if (!(tcphdr_p->syn)) {
+					dprintk("Received an ack without a SYN on a listening port\n");
+					destroy_cm_node(core_p, node_p);
+				} else {
+					dprintk("Received an ack on a listening port (syn-ack maybe?)\n");
+				}
+				break;
+			case NES_CM_STATE_TSA:
+				dprintk("Received a packet while in TSA state\n");
+				break;
+			case NES_CM_STATE_UNKNOWN:
+			case NES_CM_STATE_INITED:
+			case NES_CM_STATE_ACCEPTING:
+			case NES_CM_STATE_FIN_WAIT2:
+			default:
+				dprintk("Received ack from unknown state: %x\n", node_p->state);
+				send_reset(node_p);
+				break;
+		}
+	}
+
+	if (tcphdr_p->syn) {
+		if (datasize == 0)
+			node_p->tcp_cntxt.rcv_nxt ++;
+
+		dprintk("%s: Received SYN\n", __FUNCTION__);
+		if (node_p->state == NES_CM_STATE_LISTENING) {
+			node_p->state = NES_CM_STATE_SYN_RCVD;
+			send_syn(node_p, 1);
+			dprintk("%s:%s[%u] -- Sent syn_ack\n",
+					__FILE__, __FUNCTION__, __LINE__);
+		}
+		if (node_p->state == NES_CM_STATE_ONE_SIDE_ESTABLISHED) {
+			node_p->state = NES_CM_STATE_ESTABLISHED;
+			/* send final handshake ACK */
+			ret = send_ack(node_p);
+			if (ret < 0)
+				return (ret);
+
+			if (node_p->conn_type == NES_CM_IWARP_CONN_TYPE) {
+				node_p->state = NES_CM_STATE_MPAREQ_SENT;
+				ret = send_mpa_request(node_p);
+				if (ret < 0)
+					return (ret);
+			} else {
+				create_event(node_p, NES_CM_EVENT_CONNECTED);
+				node_p->state = NES_CM_STATE_TSA;
+			}
+		}
+	}
+
+	if (tcphdr_p->fin) {
+		dprintk("%s: Received FIN\n", __FUNCTION__);
+		node_p->tcp_cntxt.rcv_nxt++;
+		switch (node_p->state) {
+			case NES_CM_STATE_SYN_RCVD:
+			case NES_CM_STATE_SYN_SENT:
+			case NES_CM_STATE_ONE_SIDE_ESTABLISHED:
+			case NES_CM_STATE_ESTABLISHED:
+			case NES_CM_STATE_ACCEPTING:
+			case NES_CM_STATE_MPAREQ_SENT:
+				node_p->state = NES_CM_STATE_CLOSE_WAIT;
+				node_p->state = NES_CM_STATE_LAST_ACK;
+				ret = send_fin(node_p, NULL);
+				break;
+			case NES_CM_STATE_FIN_WAIT1:
+				node_p->state = NES_CM_STATE_CLOSING;
+				ret = send_ack(node_p);
+				break;
+			case NES_CM_STATE_FIN_WAIT2:
+				node_p->state = NES_CM_STATE_TIME_WAIT;
+				node_p->tcp_cntxt.loc_seq_num ++;
+				ret = send_ack(node_p);
+				/* need to schedule this to happen in 2MSL timeouts */
+				node_p->state = NES_CM_STATE_CLOSED;
+				break;
+			case NES_CM_STATE_CLOSE_WAIT:
+			case NES_CM_STATE_LAST_ACK:
+			case NES_CM_STATE_CLOSING:
+			case NES_CM_STATE_TSA:
+			default:
+				dprintk(KERN_INFO PFX "Received a fin while in %x state\n",
+					node_p->state);
+				ret = -EINVAL;
+				break;
+		}
+	}
+
+	if (datasize) {
+		u8 *dataloc = skb_p->data;
+		/* figure out what state we are in and handle transition to next state */
+		switch (node_p->state) {
+			case NES_CM_STATE_LISTENING:
+			case NES_CM_STATE_SYN_RCVD:
+			case NES_CM_STATE_SYN_SENT:
+			case NES_CM_STATE_FIN_WAIT1:
+			case NES_CM_STATE_FIN_WAIT2:
+			case NES_CM_STATE_CLOSE_WAIT:
+			case NES_CM_STATE_LAST_ACK:
+			case NES_CM_STATE_CLOSING:
+				break;
+			case  NES_CM_STATE_MPAREQ_SENT:
+				/* recv the mpa res frame, ret=frame len (incl priv data) */
+				ret = parse_mpa(node_p, dataloc, datasize);
+				if (ret < 0)
+					break;
+				/* set the req frame payload len in skb */
+				/* we are done handling this state, set node to a TSA state */
+				node_p->state = NES_CM_STATE_TSA;
+				create_event(node_p, NES_CM_EVENT_CONNECTED);
+				break;
+
+			case  NES_CM_STATE_ESTABLISHED:
+				/* we are expecting an MPA req frame */
+				ret = parse_mpa(node_p, dataloc, datasize);
+				if (ret < 0)
+					break;
+				dprintk("%s[%u] -- MPA frame size = %u\n", __FILE__, __LINE__, ret);
+				node_p->state = NES_CM_STATE_TSA;
+				/* we got a valid MPA request, create an event */
+				create_event(node_p, NES_CM_EVENT_MPA_REQ);
+				break;
+			case  NES_CM_STATE_TSA:
+				handle_exception_pkt(node_p, skb_p);
+				break;
+			case NES_CM_STATE_UNKNOWN:
+			case NES_CM_STATE_INITED:
+			default:
+				ret = -1;
+		}
+	}
+
+	dprintk("%s[%u] Exit\n", __FUNCTION__, __LINE__);
+	return(ret);
+}
+
+
+/**
+ * mini_cm_listen - create a listen node with params
+ */
+static struct nes_cm_listener *mini_cm_listen(struct nes_cm_core *core_p,
+		struct nes_vnic *nesvnic, struct nes_cm_info *nfo_p)
+{
+	struct nes_cm_listener *listen_p;
+	unsigned long flags;
+
+	/* create a CM listen node (1/2 node to compare incoming traffic to) */
+	listen_p =  (struct nes_cm_listener *)kzalloc(sizeof(*listen_p), GFP_ATOMIC);
+	if (!listen_p)
+		return NULL;
+
+	memset(listen_p, 0, sizeof(struct nes_cm_listener));
+	listen_p->loc_addr = htonl(nfo_p->loc_addr);
+	listen_p->loc_port = htons(nfo_p->loc_port);
+	listen_p->cm_id = nfo_p->cm_id;
+	atomic_set(&listen_p->ref_count, 1);
+	listen_p->core_p = core_p;
+	atomic_inc(&core_p->node_cnt);
+	atomic_inc(&core_p->session_id);
+
+	listen_p->session_id = (u32)(atomic_read(&core_p->session_id) + current->tgid);
+	listen_p->conn_type = nfo_p->conn_type;
+
+	spin_lock_irqsave(&core_p->listen_list_lock, flags);
+	list_add(&listen_p->list, &core_p->listen_list.list);
+	spin_unlock_irqrestore(&core_p->listen_list_lock, flags);
+	atomic_inc(&core_p->listen_node_cnt);
+
+	dprintk("%s[%u] -- Api - listen(): addr=0x%08X, port=0x%04x\n",
+			__FILE__,__LINE__, ntohs(nfo_p->loc_addr), ntohs(nfo_p->loc_port));
+
+	return(listen_p);
+}
+
+
+/**
+ * mini_cm_connect - make a connection node with params
+ */
+struct nes_cm_node * mini_cm_connect(struct nes_cm_core *core_p,
+	struct nes_vnic *nesvnic, struct ietf_mpa_frame *mpa_frame_p,
+	struct nes_cm_info *nfo_p)
+{
+	int ret = 0;
+	struct nes_cm_node *node_p;
+
+	u16 mpa_frame_size = sizeof(struct ietf_mpa_frame) +
+			ntohs(mpa_frame_p->priv_data_len);
+
+	nfo_p->loc_addr = htonl(nfo_p->loc_addr);
+	nfo_p->rem_addr = htonl(nfo_p->rem_addr);
+	nfo_p->loc_port = htons(nfo_p->loc_port);
+	nfo_p->rem_port = htons(nfo_p->rem_port);
+
+	/* create a CM connection node */
+	node_p = make_cm_node(core_p, nesvnic, nfo_p, NULL);
+	if (!node_p)
+		return(NULL);
+
+
+	/* set our node side to client (active) side */
+	node_p->tcp_cntxt.client = 1;
+	/* init our MPA frame ptr */
+	nes_dump_mem(mpa_frame_p, mpa_frame_size);
+	memcpy(&node_p->mpa_frame_p, mpa_frame_p, mpa_frame_size);
+	node_p->mpa_frame_size = mpa_frame_size;
+
+	/* send a syn and goto syn sent state */
+	node_p->state = NES_CM_STATE_SYN_SENT;
+	ret = send_syn(node_p, 0);
+
+	dprintk("%s[%u] -- Exit\n", __FUNCTION__,__LINE__);
+
+	return(node_p);
+}
+
+
+/**
+ * mini_cm_accept - accept a connection
+ * This function is never called
+ */
+int mini_cm_accept(struct nes_cm_core *core_p, struct ietf_mpa_frame *mpa_frame_p,
+		struct nes_cm_node *node_p)
+{
+	return(0);
+}
+
+
+/**
+ * mini_cm_reject - reject and teardown a connection
+ */
+int mini_cm_reject(struct nes_cm_core *core_p, struct ietf_mpa_frame *mpa_frame_p,
+		struct nes_cm_node *node_p)
+{
+	int ret = 0;
+	struct sk_buff *skb_p;
+	u16 mpa_frame_size = sizeof(struct ietf_mpa_frame) +
+			ntohs(mpa_frame_p->priv_data_len);
+
+	skb_p = get_free_pkt(node_p);
+	if (!skb_p) {
+		dprintk("%s:%s[%u] -- Failed to get a Free pkt\n",__FILE__, __FUNCTION__, __LINE__);
+		return (-1);
+	}
+
+	/* send an MPA Request frame */
+	form_cm_frame(skb_p, node_p, NULL, 0, mpa_frame_p, mpa_frame_size, SET_ACK | SET_FIN);
+	ret = schedule_nes_timer(node_p, skb_p, NES_TIMER_TYPE_SEND, 1);
+
+	node_p->state = NES_CM_STATE_CLOSED;
+	ret = send_fin(node_p, NULL);
+
+	if (ret < 0) {
+		printk(KERN_INFO PFX "failed to send MPA Reply (reject)\n");
+		return (ret);
+	}
+
+	dprintk("%s[%u] -- \n", __FILE__, __LINE__);
+	return(ret);
+}
+
+
+/**
+ * mini_cm_close
+ */
+int mini_cm_close(struct nes_cm_core *core_p, struct nes_cm_node *node_p)
+{
+	int ret = 0;
+
+	if (!core_p || !node_p)
+		return(-EINVAL);
+
+	switch (node_p->state) {
+		/* if passed in node is null, create a reference key node for node search */
+		/* check if we found an owner node for this pkt */
+		case NES_CM_STATE_LISTENING:
+			ret = destroy_cm_node(core_p, node_p);
+			break;
+		case NES_CM_STATE_SYN_RCVD:
+		case NES_CM_STATE_SYN_SENT:
+		case NES_CM_STATE_ONE_SIDE_ESTABLISHED:
+		case NES_CM_STATE_ESTABLISHED:
+		case NES_CM_STATE_ACCEPTING:
+		case NES_CM_STATE_MPAREQ_SENT:
+			node_p->state = NES_CM_STATE_FIN_WAIT1;
+			send_fin(node_p, NULL);
+			break;
+		case NES_CM_STATE_CLOSE_WAIT:
+			node_p->state = NES_CM_STATE_LAST_ACK;
+			send_fin(node_p, NULL);
+			break;
+		case NES_CM_STATE_FIN_WAIT1:
+		case NES_CM_STATE_FIN_WAIT2:
+		case NES_CM_STATE_LAST_ACK:
+		case NES_CM_STATE_TIME_WAIT:
+		case NES_CM_STATE_CLOSING:
+			ret = -1;
+			break;
+		case NES_CM_STATE_UNKNOWN:
+		case NES_CM_STATE_INITED:
+		case NES_CM_STATE_CLOSED:
+		case NES_CM_STATE_TSA:
+			destroy_cm_node(core_p, node_p);
+			break;
+	}
+
+	return(ret);
+}
+
+
+/**
+ * recv_pkt - recv an ETHERNET packet, and process it through CM
+ * node state machine
+ */
+int mini_cm_recv_pkt(struct nes_cm_core *core_p, struct nes_vnic *nesvnic,
+		struct sk_buff *skb_p)
+{
+	struct nes_cm_node *node_p = NULL;
+	struct nes_cm_listener *listener = NULL;
+	struct iphdr *iphdr_p;
+	struct tcphdr *tcphdr_p;
+	struct nes_cm_info nfo;
+
+	if (!skb_p || skb_p->len < sizeof(struct iphdr) + sizeof(struct tcphdr))
+		return(-EINVAL);
+
+	iphdr_p = skb_p->nh.iph = (struct iphdr *)skb_p->data;
+	skb_p->len = htons(iphdr_p->tot_len);
+
+	tcphdr_p = skb_p->h.th = (struct tcphdr *)(skb_p->data + sizeof(struct iphdr));
+
+	nfo.loc_addr = ntohl(iphdr_p->daddr);
+	nfo.loc_port = ntohs(tcphdr_p->dest);
+	nfo.rem_addr = ntohl(iphdr_p->saddr);
+	nfo.rem_port = ntohs(tcphdr_p->source);
+
+	/* find a node this packet belongs to */
+	node_p = find_node(core_p,
+			nfo.rem_port, nfo.rem_addr,
+			nfo.loc_port, nfo.loc_addr);
+
+	if (!node_p) {
+		listener = find_listener(core_p, nfo.loc_addr, nfo.loc_port);
+		if (listener) {
+			nfo.cm_id = listener->cm_id;
+			nfo.conn_type = listener->conn_type;
+		}
+		else {
+			nfo.cm_id = NULL;
+			nfo.conn_type = 0;
+		}
+
+		node_p = make_cm_node(core_p, nesvnic, &nfo, listener);
+		if(!node_p) {
+			printk(KERN_ERR PFX "Unable to allocate node\n");
+			return (-1);
+		}
+		if (!listener) {
+			printk(KERN_ERR PFX "Packet found for unknown port %x\n", nfo.loc_port);
+			send_reset(node_p);
+			return (-1);
+		}
+		node_p->state = NES_CM_STATE_LISTENING;
+	}
+
+	schedule_nes_timer(node_p, skb_p, NES_TIMER_TYPE_RECV, 0);
+
+	return(0);
+}
+
+
+/**
+ * nes_cm_alloc_core - allocate a top level instance of a cm core
+ */
+struct nes_cm_core *nes_cm_alloc_core(void)
+{
+	int i;
+
+	struct nes_cm_core *core_p;
+	struct sk_buff *skb_p = NULL;
+
+	dprintk("%s[%u] -- Init CM Core: " __DATE__ ":" __TIME__ "\n",
+			__FILE__, __LINE__);
+
+	/* setup the CM core */
+	/* alloc top level core control structure */
+	core_p = kzalloc(sizeof(*core_p), GFP_KERNEL);
+	if (!core_p)
+		return(NULL);
+
+	INIT_LIST_HEAD(&core_p->connected_nodes);
+	init_timer(&core_p->tcp_timer);
+	core_p->tcp_timer.function = nes_cm_timer_tick;
+
+	core_p->mtu   = NES_CM_DEFAULT_MTU;
+	core_p->state = NES_CM_STATE_INITED;
+	core_p->free_tx_pkt_max = NES_CM_DEFAULT_FREE_PKTS;
+
+	atomic_set(&core_p->session_id, 0);
+	atomic_set(&core_p->events_posted, 0);
+
+	/* init the packet lists */
+	skb_queue_head_init(&core_p->tx_free_list);
+
+	for (i=0; i < NES_CM_DEFAULT_FRAME_CNT; i++) {
+		skb_p = dev_alloc_skb(core_p->mtu);
+		if (!skb_p) {
+			kfree(core_p);
+			return(NULL);
+		}
+		/* add 'raw' skb to free frame list */
+		skb_queue_head(&core_p->tx_free_list, skb_p);
+	}
+
+	core_p->api = &nes_cm_api;
+
+	spin_lock_init(&core_p->ht_lock);
+	spin_lock_init(&core_p->listen_list_lock);
+
+	INIT_LIST_HEAD(&core_p->listen_list.list);
+
+	dprintk("%s[%u] -- Init CM Core completed -- core_p=%p\n",
+			__FILE__,__LINE__, core_p);
+
+	dprintk("%s[%u] Enable QUEUE EVENTS\n", __FUNCTION__, __LINE__);
+	core_p->event_wq = create_singlethread_workqueue("nesewq");
+	core_p->post_event = nes_cm_post_event;
+	dprintk("%s[%u] Enable QUEUE DISCONNECTS\n", __FUNCTION__, __LINE__);
+	core_p->disconn_wq = create_singlethread_workqueue("nesdwq");
+
+	print_core(core_p);
+	return(core_p);
+}
+
+
+/**
+ * mini_cm_dealloc_core - deallocate a top level instance of a cm core
+ */
+int mini_cm_dealloc_core(struct nes_cm_core *core_p)
+{
+	/* int i; */
+	struct list_head *list_p, *list_p_temp;
+	struct nes_cm_node *node_p;
+	struct nes_cm_listener *listen_p;
+
+	dprintk("%s[%u] -- De-Alloc CM Core (%p)\n", __FILE__, __LINE__, core_p);
+
+	if (!core_p)
+		return(-EINVAL);
+
+	barrier();
+
+	if(timer_pending(&core_p->tcp_timer)) {
+		del_timer(&core_p->tcp_timer);
+	}
+
+	destroy_workqueue(core_p->event_wq);
+	destroy_workqueue(core_p->disconn_wq);
+
+	/* walk the entire HT and free each node */
+	list_for_each_safe(list_p, list_p_temp, &core_p->connected_nodes) {
+		node_p = container_of(list_p, struct nes_cm_node, list);
+		destroy_cm_node(core_p, node_p);
+	}
+
+	list_for_each_safe(list_p, list_p_temp, &core_p->listen_list.list)
+	{
+		listen_p = container_of(list_p, struct nes_cm_listener, list);
+		mini_cm_del_listen(core_p, listen_p);
+	}
+
+	dprintk("%s[%u] -- \n", __FILE__, __LINE__);
+	kfree(core_p);
+
+	return(0);
+}
+
+
+/**
+ * mini_cm_get
+ */
+int mini_cm_get(struct nes_cm_core *core_p)
+{
+	return(core_p->state);
+}
+
+
+/**
+ * mini_cm_set
+ */
+int mini_cm_set(struct nes_cm_core *core_p, u32 type, u32 value)
+{
+	int ret = 0;
+
+	switch (type) {
+		case NES_CM_SET_PKT_SIZE:
+			core_p->mtu = value;
+			break;
+		case NES_CM_SET_FREE_PKT_Q_SIZE:
+			core_p->free_tx_pkt_max = value;
+			break;
+		default:
+			/* unknown set option */
+			ret = -EINVAL;
+	}
+
+	return(ret);
+}
+
+
+/**
+ * nes_cm_init_tsa_conn setup HW; MPA frames must be
+ * successfully exchanged when this is called
+ */
+static int nes_cm_init_tsa_conn(struct nes_qp *nesqp, struct nes_cm_node *node_p)
+{
+	int ret = 0;
+
+	if (!nesqp)
+		return(-EINVAL);
+
+	nesqp->nesqp_context->misc |= NES_QPCONTEXT_MISC_IPV4 |
+			NES_QPCONTEXT_MISC_NO_NAGLE | NES_QPCONTEXT_MISC_DO_NOT_FRAG |
+			NES_QPCONTEXT_MISC_DROS;
+
+	if(node_p->tcp_cntxt.snd_wscale)
+		nesqp->nesqp_context->misc |= NES_QPCONTEXT_MISC_WSCALE;
+
+	nesqp->nesqp_context->misc2 |= (0 << NES_QPCONTEXT_MISC2_TOS_SHIFT);
+	nesqp->nesqp_context->misc2 |= (64 << NES_QPCONTEXT_MISC2_TTL_SHIFT);
+
+	nesqp->nesqp_context->mss |= ((u32)node_p->tcp_cntxt.mss) << 16;
+
+	nesqp->nesqp_context->tcp_state_flow_label |=
+			(u32)NES_QPCONTEXT_TCPSTATE_EST << NES_QPCONTEXT_TCPFLOW_TCP_STATE_SHIFT;
+
+	nesqp->nesqp_context->pd_index_wscale |=
+			(node_p->tcp_cntxt.snd_wscale << NES_QPCONTEXT_PDWSCALE_SND_WSCALE_SHIFT) &
+			NES_QPCONTEXT_PDWSCALE_SND_WSCALE_MASK;
+
+	nesqp->nesqp_context->pd_index_wscale |=
+			(node_p->tcp_cntxt.rcv_wscale << NES_QPCONTEXT_PDWSCALE_RCV_WSCALE_SHIFT) &
+			NES_QPCONTEXT_PDWSCALE_RCV_WSCALE_MASK;
+
+	nesqp->nesqp_context->keepalive = 0x80;
+	nesqp->nesqp_context->ts_recent = 0;	
+	nesqp->nesqp_context->ts_age = 0;	
+	nesqp->nesqp_context->snd_nxt = node_p->tcp_cntxt.loc_seq_num;	
+	nesqp->nesqp_context->snd_wnd = node_p->tcp_cntxt.snd_wnd;	
+	nesqp->nesqp_context->rcv_nxt = node_p->tcp_cntxt.rcv_nxt;	
+	nesqp->nesqp_context->rcv_wnd = node_p->tcp_cntxt.rcv_wnd << node_p->tcp_cntxt.rcv_wscale;	
+	nesqp->nesqp_context->snd_max = node_p->tcp_cntxt.loc_seq_num;	
+	nesqp->nesqp_context->snd_una = node_p->tcp_cntxt.loc_seq_num;	
+	nesqp->nesqp_context->srtt = 0;		
+	nesqp->nesqp_context->rttvar = 0x4B0;	
+	nesqp->nesqp_context->ssthresh = 0x3FFFC000;	
+	nesqp->nesqp_context->cwnd = NES_CM_DEFAULT_RCV_WND;	
+	nesqp->nesqp_context->snd_wl1 = node_p->tcp_cntxt.rcv_nxt;	
+	nesqp->nesqp_context->snd_wl2 = node_p->tcp_cntxt.loc_seq_num;	
+	nesqp->nesqp_context->max_snd_wnd = node_p->tcp_cntxt.max_snd_wnd;	
+
+	dprintk("%s: QP%u: rcv_nxt = 0x%08X, snd_nxt = 0x%08X, Setting MSS to %u, PDWscale = 0x%08X, rcv_wnd = %u, context misc = 0x%08X.\n",__FUNCTION__,
+		nesqp->hwqp.qp_id, nesqp->nesqp_context->rcv_nxt, nesqp->nesqp_context->snd_nxt,
+		node_p->tcp_cntxt.mss, nesqp->nesqp_context->pd_index_wscale, nesqp->nesqp_context->rcv_wnd,
+		nesqp->nesqp_context->misc);
+	dprintk("  snd_wnd  = 0x%08X.\n", nesqp->nesqp_context->snd_wnd);
+	dprintk("  snd_cwnd = 0x%08X.\n", nesqp->nesqp_context->cwnd);
+	dprintk("  max_swnd = 0x%08X.\n", nesqp->nesqp_context->max_snd_wnd);
+
+	dprintk("%s:%s[%u] -- Change node_p state to TSA\n",
+			__FILE__, __FUNCTION__, __LINE__);
+	node_p->state = NES_CM_STATE_TSA;
+
+	return(ret);
+}
+
+
+/**
+ * nes_cm_disconn
+ */
+int nes_cm_disconn(struct nes_qp *nesqp)
+{
+	unsigned long flags;
+
+	dprintk("%s[%u] -- \n", __FILE__, __LINE__);
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	spin_lock_irqsave(&nesqp->lock, flags);
+	if (0==nesqp->disconn_pending) {
+		nesqp->disconn_pending++;
+		spin_unlock_irqrestore(&nesqp->lock, flags);
+		/* nes_add_ref(&nesqp->ibqp); */
+		/* init our disconnect work element, to */
+		NES_INIT_WORK(&nesqp->disconn_work, nes_disconnect_worker, (void *)nesqp);
+
+		queue_work(g_cm_core_p->disconn_wq, &nesqp->disconn_work);
+	} else {
+		spin_unlock_irqrestore(&nesqp->lock, flags);
+		nes_rem_ref(&nesqp->ibqp);
+	}
+	dprintk("%s[%u] -- \n", __FILE__, __LINE__);
+	return(0);
+}
+
+
+/**
+ * nes_disconnect_worker
+ */
+void nes_disconnect_worker(void *parm)
+{
+	struct work_struct *work = parm;
+	struct nes_qp *nesqp = container_of(work, struct nes_qp, disconn_work);
+	dprintk("%s: processing AEQE id 0x%04X for QP%u.\n",
+			__FUNCTION__, nesqp->last_aeq, nesqp->hwqp.qp_id);
+	nes_cm_disconn_true(nesqp);
+}
+
+
+/**
+ * nes_cm_disconn_true
+ */
+int nes_cm_disconn_true(struct nes_qp *nesqp)
+{
+	unsigned long flags;
+	int ret = 0;
+	struct iw_cm_id *cm_id;
+	struct iw_cm_event cm_event;
+	struct nes_vnic *nesvnic;
+	u16 last_ae;
+	u8 original_hw_tcp_state;
+	u8 original_ibqp_state;
+	u8 issued_disconnect_reset = 0;
+
+	if (!nesqp) {
+		dprintk("%s[%u] -- disconnect_worker nesqp is NULL\n", __FILE__,__LINE__);
+		nes_rem_ref(&nesqp->ibqp);
+		return -1;
+	}
+
+	spin_lock_irqsave(&nesqp->lock, flags);
+	cm_id = nesqp->cm_id;
+	/* make sure we havent already closed this connection */
+	if (!cm_id) {
+		dprintk("%s[%u] -- QP%u disconnect_worker cmid is NULL\n",
+				__FILE__,__LINE__, nesqp->hwqp.qp_id);
+		spin_unlock_irqrestore(&nesqp->lock, flags);
+		nes_rem_ref(&nesqp->ibqp);
+		return -1;
+	}
+
+	nesvnic = to_nesvnic(nesqp->ibqp.device);
+	dprintk("%s:%u: Disconnecting QP%u\n",
+			__FUNCTION__, __LINE__, nesqp->hwqp.qp_id);
+
+	original_hw_tcp_state = nesqp->hw_tcp_state;
+	original_ibqp_state   = nesqp->ibqp_state;
+	last_ae = nesqp->last_aeq;
+
+	dprintk("%s:%u:QP%u: Last AEQ id = 0x%04X, cm_id = %p, tcp state = %d,"
+			" ib qp state = %d, refcount = %u\n",
+			__FUNCTION__, __LINE__, nesqp->hwqp.qp_id, last_ae, cm_id,
+			original_hw_tcp_state, original_ibqp_state, atomic_read(&nesqp->refcount));
+
+
+	dprintk("%s[%u] -- set ibqp_state=%u\n",
+			__FUNCTION__, __LINE__, nesqp->ibqp_state);
+
+	if ((nesqp->cm_id) && (cm_id->event_handler)) {
+		if ((original_hw_tcp_state == NES_AEQE_TCP_STATE_CLOSE_WAIT) ||
+				((original_ibqp_state == IB_QPS_RTS) &&
+				(last_ae == NES_AEQE_AEID_LLP_CONNECTION_RESET))) {
+			atomic_inc(&cm_disconnects);
+			cm_event.event = IW_CM_EVENT_DISCONNECT;
+			if (last_ae == NES_AEQE_AEID_LLP_CONNECTION_RESET) {
+				issued_disconnect_reset = 1;
+				cm_event.status = IW_CM_EVENT_STATUS_RESET;
+				dprintk("%s: Generating a CM Disconnect Event (status reset) for "
+						" QP%u, cm_id = %p. \n",
+						__FUNCTION__, nesqp->hwqp.qp_id, cm_id);
+			} else {
+				cm_event.status = IW_CM_EVENT_STATUS_OK;
+			}
+
+			cm_event.local_addr = cm_id->local_addr;
+			cm_event.remote_addr = cm_id->remote_addr;
+			cm_event.private_data = NULL;
+			cm_event.private_data_len = 0;
+
+			dprintk("%s: Generating a CM Disconnect Event for "
+					" QP%u, SQ Head = %u, SQ Tail = %u. cm_id = %p, refcount = %u. \n",
+					__FUNCTION__, nesqp->hwqp.qp_id,
+					nesqp->hwqp.sq_head, nesqp->hwqp.sq_tail, cm_id,
+					atomic_read(&nesqp->refcount));
+
+			spin_unlock_irqrestore(&nesqp->lock, flags);
+			ret = cm_id->event_handler(cm_id, &cm_event);
+			if (ret)
+				dprintk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+						__FUNCTION__, __LINE__, ret);
+			spin_lock_irqsave(&nesqp->lock, flags);
+		}
+
+		nesqp->disconn_pending = 0;
+
+		if ((0 == issued_disconnect_reset) && (nesqp->cm_id) &&
+				(((original_ibqp_state != IB_QPS_RTS) &&
+				((original_hw_tcp_state == NES_AEQE_TCP_STATE_CLOSE_WAIT) ||
+				(original_hw_tcp_state == NES_AEQE_TCP_STATE_CLOSED))) ||
+				(last_ae == NES_AEQE_AEID_RDMAP_ROE_BAD_LLP_CLOSE) ||
+				(last_ae == NES_AEQE_AEID_LLP_CONNECTION_RESET) ||
+				(nesqp->hw_iwarp_state == NES_AEQE_IWARP_STATE_CLOSING))) {
+			atomic_inc(&cm_closes);
+			nesqp->cm_id = NULL;
+			nesqp->in_disconnect = 0;
+			spin_unlock_irqrestore(&nesqp->lock, flags);
+			nes_disconnect(nesqp, 1, ntohs(cm_id->local_addr.sin_port));
+
+			dprintk("%s[%u] -- \n", __FUNCTION__, __LINE__);
+
+			cm_id->provider_data = nesqp;
+			/* Send up the close complete event */
+			cm_event.event = IW_CM_EVENT_CLOSE;
+			cm_event.status = IW_CM_EVENT_STATUS_OK;
+			cm_event.provider_data = cm_id->provider_data;
+			cm_event.local_addr = cm_id->local_addr;
+			cm_event.remote_addr = cm_id->remote_addr;
+			cm_event.private_data = NULL;
+			cm_event.private_data_len = 0;
+
+			dprintk("%s[%u] -- OFA CM upcall for QP%u, IW_CM_EVENT_CLOSE cm_id = %p."
+					" QP refcount = %d. nesadapter = %p\n",
+					__FUNCTION__, __LINE__, nesqp->hwqp.qp_id, cm_id,
+					atomic_read(&nesqp->refcount), nesvnic->nesdev->nesadapter);
+			ret = cm_id->event_handler(cm_id, &cm_event);
+			if (ret)
+				dprintk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+						__FUNCTION__, __LINE__, ret);
+
+			cm_id->rem_ref(cm_id);
+
+			spin_lock_irqsave(&nesqp->lock, flags);
+			if (0 == nesqp->flush_issued) {
+				nesqp->flush_issued = 1;
+				spin_unlock_irqrestore(&nesqp->lock, flags);
+				flush_wqes(nesvnic->nesdev, nesqp, NES_CQP_FLUSH_RQ, 1);
+			} else {
+				spin_unlock_irqrestore(&nesqp->lock, flags);
+			}
+
+			/* This reference is from either ModifyQP or the AE processing,
+					there is still a race here with modifyqp */
+			nes_rem_ref(&nesqp->ibqp);
+
+		} else {
+			cm_id = nesqp->cm_id;
+			spin_unlock_irqrestore(&nesqp->lock, flags);
+			/* check to see if the inbound reset beat the outbound reset */
+			if ((!cm_id) && (last_ae==NES_AEQE_AEID_RESET_SENT)) {
+				dprintk("%s[%u] QP%u: Decing refcount due to inbound reset"
+						" beating the outbound reset.\n",
+						__FUNCTION__, __LINE__, nesqp->hwqp.qp_id);
+				nes_rem_ref(&nesqp->ibqp);
+			}
+		}
+	} else {
+		nesqp->disconn_pending = 0;
+		spin_unlock_irqrestore(&nesqp->lock, flags);
+	}
+	nes_rem_ref(&nesqp->ibqp);
+	dprintk("%s[%u] Exiting. QP%u refcount = %d\n",
+			__FUNCTION__, __LINE__, nesqp->hwqp.qp_id, atomic_read(&nesqp->refcount));
+
+	return 0;
+}
+
+
+/**
+ * nes_disconnect
+ */
+int nes_disconnect(struct nes_qp *nesqp, int abrupt, u16 local_port)
+{
+	int ret = 0;
+	struct nes_vnic *nesvnic;
+	struct nes_device *nesdev;
+
+	dprintk("%s[%u] -- Enter, QP%u\n", __FUNCTION__, __LINE__, nesqp->hwqp.qp_id);
+
+	nesvnic = to_nesvnic(nesqp->ibqp.device);
+	if (!nesvnic)
+		return(-EINVAL);
+
+	nesdev = nesvnic->nesdev;
+
+	dprintk("%s: netdev refcnt = %u.\n",
+			__FUNCTION__, atomic_read(&nesvnic->netdev->refcnt));
+
+	if (nesqp->active_conn) {
+
+		/* indicate this connection is NOT active */
+		nesqp->active_conn = 0;
+	} else {
+		/* Need to free the Last Streaming Mode Message */
+		if (nesqp->ietf_frame) {
+			pci_free_consistent(nesdev->pcidev,
+					nesqp->private_data_len+sizeof(struct ietf_mpa_frame),
+					nesqp->ietf_frame, nesqp->ietf_frame_pbase);
+		}
+	}
+
+	/* close the CM node down if it is still active */
+	if (nesqp->cm_node_p) {
+		dprintk("%s[%u] -- Call close API\n", __FUNCTION__, __LINE__);
+
+		g_cm_core_p->api->close(g_cm_core_p, nesqp->cm_node_p);
+		nesqp->cm_node_p = NULL;
+	}
+
+	dprintk("%s[%u] -- Exit, QP%u\n", __FUNCTION__, __LINE__, nesqp->hwqp.qp_id);
+	return(ret);
+}
+
+
+/**
+ * nes_accept
+ */
+int nes_accept(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
+{
+	struct ib_qp *ibqp;
+	struct nes_qp *nesqp;
+	struct nes_vnic *nesvnic;
+	struct nes_device *nesdev;
+	struct nes_cm_node *node_p;
+	struct nes_adapter *adapter;
+	struct ib_qp_attr attr;
+	struct iw_cm_event cm_event;
+	struct nes_hw_qp_wqe *wqe;
+	struct nes_v4_quad nes_quad;
+	int ret;
+
+	dprintk("%s:%s:%u: data len = %u\n",
+			__FILE__, __FUNCTION__, __LINE__, conn_param->private_data_len);
+
+	ibqp = nes_get_qp(cm_id->device, conn_param->qpn);
+	if (!ibqp)
+		return(-EINVAL);
+
+	/* get all our handles */
+	nesqp = to_nesqp(ibqp);
+	nesvnic = to_nesvnic(nesqp->ibqp.device);
+	nesdev = nesvnic->nesdev;
+	adapter = nesdev->nesadapter;
+
+	/* since this is from a listen, we were able to put node handle into cm_id */
+	node_p = (struct nes_cm_node *)cm_id->provider_data;
+
+	/* associate the node with the QP */
+	nesqp->cm_node_p = (void *)node_p;
+
+	dprintk("%s: QP%u, node_p=%p\n", __FUNCTION__, nesqp->hwqp.qp_id, node_p);
+	atomic_inc(&cm_accepts);
+
+	dprintk("%s: netdev refcnt = %u.\n",
+			__FUNCTION__, atomic_read(&nesvnic->netdev->refcnt));
+
+	/* allocate the ietf frame and space for private data */
+	nesqp->ietf_frame = pci_alloc_consistent(nesdev->pcidev,
+			sizeof(struct ietf_mpa_frame) + conn_param->private_data_len,
+			&nesqp->ietf_frame_pbase);
+
+	if (!nesqp->ietf_frame) {
+		dprintk(KERN_ERR PFX "%s: Unable to allocate memory for private data\n",
+				__FUNCTION__);
+		return(-ENOMEM);
+	}
+
+	dprintk(PFX "%s: PCI consistent memory for "
+			"private data located @ %p (pa = 0x%08llX.) size = %u.\n",
+			__FUNCTION__, nesqp->ietf_frame,
+			(unsigned long long)nesqp->ietf_frame_pbase,
+			(u32)(conn_param->private_data_len +
+			sizeof(struct ietf_mpa_frame)));
+
+	/* setup the MPA frame */
+	nesqp->private_data_len = conn_param->private_data_len;
+	memcpy(nesqp->ietf_frame->key, IEFT_MPA_KEY_REP, IETF_MPA_KEY_SIZE);
+
+	memcpy(nesqp->ietf_frame->priv_data, conn_param->private_data,
+			conn_param->private_data_len);
+
+	nesqp->ietf_frame->priv_data_len = cpu_to_be16(conn_param->private_data_len);
+	nesqp->ietf_frame->rev = mpa_version;
+	nesqp->ietf_frame->flags = IETF_MPA_FLAGS_CRC;
+
+	dprintk("%s: Dump of ietf_frame=\n", __FUNCTION__);
+	nes_dump_mem(nesqp->ietf_frame, sizeof(struct ietf_mpa_frame) +
+			nesqp->private_data_len);
+
+	/* setup our first outgoing iWarp send WQE (the IETF frame response) */
+	wqe = &nesqp->hwqp.sq_vbase[0];
+
+	*((struct nes_qp **)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) = nesqp;
+	*((u64 *)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) |=
+			NES_SW_CONTEXT_ALIGN >> 1;
+	wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] =
+			cpu_to_le32(NES_IWARP_SQ_WQE_STREAMING | NES_IWARP_SQ_WQE_WRPDU);
+	wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] =
+			cpu_to_le32(conn_param->private_data_len + sizeof(struct ietf_mpa_frame));
+	wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX] =
+			cpu_to_le32((u32)nesqp->ietf_frame_pbase);
+	wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX] =
+			cpu_to_le32((u32)((u64)nesqp->ietf_frame_pbase >> 32));
+	wqe->wqe_words[NES_IWARP_SQ_WQE_LENGTH0_IDX] =
+			cpu_to_le32(conn_param->private_data_len + sizeof(struct ietf_mpa_frame));
+	wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX] = 0;
+
+	nesqp->nesqp_context->ird_ord_sizes |=
+			NES_QPCONTEXT_ORDIRD_LSMM_PRESENT | NES_QPCONTEXT_ORDIRD_WRPDU;
+	nesqp->skip_lsmm = 1;
+
+
+	/* Cache the cm_id in the qp */
+	nesqp->cm_id = cm_id;
+	node_p->cm_id = cm_id;
+
+	/*  nesqp->cm_node_p = (void *)cm_id->provider_data; */
+	cm_id->provider_data = nesqp;
+	nesqp->active_conn   = 0;
+
+	nes_cm_init_tsa_conn(nesqp, node_p);
+
+	nesqp->nesqp_context->tcpPorts = ntohs(cm_id->remote_addr.sin_port) << 16;
+	nesqp->nesqp_context->tcpPorts += ntohs(cm_id->local_addr.sin_port);
+	nesqp->nesqp_context->ip0 = ntohl(cm_id->remote_addr.sin_addr.s_addr);
+
+	nesqp->nesqp_context->misc2 |=
+			(u32)PCI_FUNC(nesdev->pcidev->devfn) << NES_QPCONTEXT_MISC2_SRC_IP_SHIFT;
+
+	nesqp->nesqp_context->arp_index_vlan |=
+			nes_arp_table(nesdev, nesqp->nesqp_context->ip0, NULL,
+			NES_ARP_RESOLVE) << 16;
+
+	nesqp->nesqp_context->ts_val_delta =
+			jiffies - nes_read_indexed(nesdev, NES_IDX_TCP_NOW);
+
+	nesqp->nesqp_context->ird_index = nesqp->hwqp.qp_id;
+
+	nesqp->nesqp_context->ird_ord_sizes |=
+			((u32)1 << NES_QPCONTEXT_ORDIRD_IWARP_MODE_SHIFT);
+	nesqp->nesqp_context->ird_ord_sizes |= (u32)conn_param->ord;
+
+	memset(&nes_quad, 0, sizeof(nes_quad));
+
+	nes_quad.DstIpAdrIndex = (u32)PCI_FUNC(nesdev->pcidev->devfn) << 27;
+	nes_quad.SrcIpadr      = cm_id->remote_addr.sin_addr.s_addr;
+	nes_quad.TcpPorts      = cm_id->remote_addr.sin_port;
+	nes_quad.TcpPorts     |= (u32)cm_id->local_addr.sin_port << 16;
+
+	/* Produce hash key */
+	nesqp->hte_index = nes_crc32(1, NES_HASH_CRC_INITAL_VALUE,
+			NES_HASH_CRC_FINAL_XOR, sizeof(nes_quad),
+			(u8 *)&nes_quad, ORDER, REFIN, REFOUT);
+
+	dprintk("%s: HTE Index = 0x%08X, CRC = 0x%08X\n",
+			__FUNCTION__, nesqp->hte_index,
+			nesqp->hte_index & adapter->hte_index_mask);
+
+	nesqp->hte_index &= adapter->hte_index_mask;
+	nesqp->nesqp_context->hte_index = nesqp->hte_index;
+
+	node_p->core_p->api->accelerated(node_p->core_p, node_p);
+
+	dprintk("%s: QP%u, Destination IP = 0x%08X:0x%04X, local = 0x%08X:0x%04X,"
+			" rcv_nxt=0x%08X, snd_nxt=0x%08X, mpa + private data length=%lu.\n",
+			__FUNCTION__, nesqp->hwqp.qp_id,
+			ntohl(cm_id->remote_addr.sin_addr.s_addr),
+			ntohs(cm_id->remote_addr.sin_port),
+			ntohl(cm_id->local_addr.sin_addr.s_addr),
+			ntohs(cm_id->local_addr.sin_port),
+			nesqp->nesqp_context->rcv_nxt,
+			nesqp->nesqp_context->snd_nxt,
+			conn_param->private_data_len+sizeof(struct ietf_mpa_frame));
+
+	attr.qp_state = IB_QPS_RTS;
+	nes_modify_qp(&nesqp->ibqp, &attr, IB_QP_STATE, NULL );
+
+	/* notify OF layer that accept event was successfull */
+	cm_id->add_ref(cm_id);
+
+	cm_event.event = IW_CM_EVENT_ESTABLISHED;
+	cm_event.status = IW_CM_EVENT_STATUS_ACCEPTED;
+	cm_event.provider_data = (void *)nesqp;
+	cm_event.local_addr = cm_id->local_addr;
+	cm_event.remote_addr = cm_id->remote_addr;
+	cm_event.private_data = NULL;
+	cm_event.private_data_len = 0;
+	ret = cm_id->event_handler(cm_id, &cm_event);
+	dprintk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+			__FUNCTION__, __LINE__, ret);
+	if (ret)
+		printk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+				__FUNCTION__, __LINE__, ret);
+
+	return(0);
+}
+
+
+/**
+ * nes_reject
+ */
+int nes_reject(struct iw_cm_id *cm_id, const void *pdata, u8 pdata_len)
+{
+	struct nes_cm_node *node_p;
+	struct nes_cm_core *cm_core_p;
+
+	atomic_inc(&cm_rejects);
+	node_p = (struct nes_cm_node *) cm_id->provider_data;
+	cm_core_p = node_p->core_p;
+	node_p->mpa_frame_size = sizeof(struct ietf_mpa_frame) + pdata_len;
+
+	strcpy(&node_p->mpa_frame_p.key[0], IEFT_MPA_KEY_REP);
+	memcpy(&node_p->mpa_frame_p.priv_data, pdata, pdata_len);
+
+	node_p->mpa_frame_p.priv_data_len = cpu_to_be16(pdata_len);
+	node_p->mpa_frame_p.rev = mpa_version;
+	node_p->mpa_frame_p.flags = IETF_MPA_FLAGS_CRC | IETF_MPA_FLAGS_REJECT;
+
+	cm_core_p->api->reject(cm_core_p, &node_p->mpa_frame_p, node_p);
+
+	return(0);
+}
+
+
+/**
+ * nes_connect
+ * setup and launch cm connect node
+ */
+int nes_connect(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
+{
+	struct ib_qp *ibqp;
+	struct nes_qp *nesqp;
+	struct nes_vnic *nesvnic;
+	struct nes_device *nesdev;
+	struct nes_cm_node *cm_node_p;
+	struct nes_cm_info cm_info;
+
+	dprintk("%s[%u] data len = %u, cm_id = %p, event handler = %p.\n",
+			__FILE__, __LINE__, conn_param->private_data_len,
+			cm_id, cm_id->event_handler);
+
+	if (cm_id->remote_addr.sin_addr.s_addr == cm_id->local_addr.sin_addr.s_addr) {
+		dprintk("Failing loopback connect attempt,"
+				" local address = 0x%08X:0x%04X, remote address = 0x%08X:0x%04X\n",
+				ntohl(cm_id->remote_addr.sin_addr.s_addr),
+				ntohs(cm_id->remote_addr.sin_port),
+				ntohl(cm_id->local_addr.sin_addr.s_addr),
+				ntohs(cm_id->local_addr.sin_port));
+		return(-EINVAL);
+	}
+
+	ibqp = nes_get_qp(cm_id->device, conn_param->qpn);
+	if (!ibqp)
+		return(-EINVAL);
+	nesqp = to_nesqp(ibqp);
+	if (!nesqp)
+		return(-EINVAL);
+	nesvnic = to_nesvnic(nesqp->ibqp.device);
+	if (!nesvnic)
+		return(-EINVAL);
+	nesdev  = nesvnic->nesdev;
+	if (!nesdev)
+		return(-EINVAL);
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+	atomic_inc(&cm_connects);
+
+	nesqp->ietf_frame = kzalloc(sizeof(struct ietf_mpa_frame) +
+			conn_param->private_data_len, GFP_KERNEL);
+	if (!nesqp->ietf_frame)
+		return(-ENOMEM);
+
+	/* set qp as having an active connection */
+	nesqp->active_conn = 1;
+
+	dprintk("%s: QP%u, Destination IP = 0x%08X:0x%04X, local = 0x%08X:0x%04X.\n",
+			__FUNCTION__, nesqp->hwqp.qp_id,
+			ntohl(cm_id->remote_addr.sin_addr.s_addr),
+			ntohs(cm_id->remote_addr.sin_port),
+			ntohl(cm_id->local_addr.sin_addr.s_addr),
+			ntohs(cm_id->local_addr.sin_port));
+
+	/* cache the cm_id in the qp */
+	nesqp->cm_id = cm_id;
+
+	cm_id->provider_data = nesqp;
+
+	cm_id->add_ref(cm_id);
+
+	/* copy the private data */
+	if (conn_param->private_data_len) {
+		memcpy(nesqp->ietf_frame->priv_data, conn_param->private_data,
+			   conn_param->private_data_len);
+	}
+
+	nesqp->private_data_len = conn_param->private_data_len;
+	nesqp->nesqp_context->ird_ord_sizes |= (u32)conn_param->ord;
+	dprintk("%s:requested ord = 0x%08X.\n",
+			__FUNCTION__, (u32)conn_param->ord);
+	dprintk("%s:mpa private data len =%u\n",
+			__FUNCTION__, conn_param->private_data_len);
+
+	strcpy(&nesqp->ietf_frame->key[0], IEFT_MPA_KEY_REQ);
+	nesqp->ietf_frame->flags = IETF_MPA_FLAGS_CRC;
+	nesqp->ietf_frame->rev = IETF_MPA_VERSION;
+	nesqp->ietf_frame->priv_data_len = htons(conn_param->private_data_len);
+
+	dprintk("%s:[%u] priv_data_len = %u\n", __FILE__, __LINE__,
+			ntohs(nesqp->ietf_frame->priv_data_len));
+
+	dprintk("%s:%s[%u] set bit in APBVT\n", __FILE__, __FUNCTION__, __LINE__);
+
+	nes_manage_apbvt(nesvnic, ntohs(cm_id->local_addr.sin_port),
+			PCI_FUNC(nesdev->pcidev->devfn), NES_MANAGE_APBVT_ADD);
+
+	/* set up the connection params for the node */
+	cm_info.loc_addr = (cm_id->local_addr.sin_addr.s_addr);
+	cm_info.loc_port = (cm_id->local_addr.sin_port);
+	cm_info.rem_addr = (cm_id->remote_addr.sin_addr.s_addr);
+	cm_info.rem_port = (cm_id->remote_addr.sin_port);
+	cm_info.cm_id = cm_id;
+	cm_info.conn_type = NES_CM_IWARP_CONN_TYPE;
+
+	/* create a connect CM node connection */
+	cm_node_p = g_cm_core_p->api->connect(g_cm_core_p, nesvnic, nesqp->ietf_frame, &cm_info);
+	nesqp->cm_node_p = cm_node_p;
+
+	if (!cm_node_p)
+		return(-ENOMEM);
+
+	return(0);
+}
+
+
+/**
+ * nes_create_listen
+ */
+int nes_create_listen(struct iw_cm_id *cm_id, int backlog)
+{
+	struct nes_vnic *nesvnic;
+	struct nes_cm_listener *cm_node_p;
+	struct nes_cm_info cm_info;
+	struct nes_adapter *adapter;
+
+	struct rdma_cm_id* rdma_cm_id = cm_id->context;
+	BUG_ON(!rdma_cm_id);
+
+	dprintk("%s[%u] Enter\n", __FUNCTION__, __LINE__);
+
+	nesvnic = to_nesvnic(cm_id->device);
+	if (!nesvnic)
+		return(-EINVAL);
+	adapter = nesvnic->nesdev->nesadapter;
+
+	/* setup listen params in our api call struct */
+	cm_info.loc_addr = cm_id->local_addr.sin_addr.s_addr;
+	cm_info.loc_port = cm_id->local_addr.sin_port;
+	/* cm_info.value = backlog; */
+	cm_info.cm_id = cm_id;
+
+	cm_info.conn_type = NES_CM_IWARP_CONN_TYPE;
+
+	cm_node_p = g_cm_core_p->api->listen(g_cm_core_p, nesvnic, &cm_info);
+
+	cm_id->provider_data = cm_node_p;
+	if (!cm_node_p) {
+		dprintk("%s[%u] Error returned from listen API call\n",
+				__FUNCTION__, __LINE__);
+		return(-ENOMEM);
+	}
+
+	cm_id->add_ref(cm_id);
+
+	cm_id->provider_data = (void *)cm_node_p;
+
+	nes_manage_apbvt(nesvnic, ntohs(cm_id->local_addr.sin_port),
+			PCI_FUNC(nesvnic->nesdev->pcidev->devfn), NES_MANAGE_APBVT_ADD);
+
+	dprintk("%s[%u] Exiting create listen, netdev->refcnt = %u.\n",
+			__FUNCTION__, __LINE__,	atomic_read(&nesvnic->netdev->refcnt));
+	return(0);
+}
+
+
+/**
+ * nes_destroy_listen
+ */
+int nes_destroy_listen(struct iw_cm_id *cm_id)
+{
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	if (cm_id->provider_data)
+		g_cm_core_p->api->stop_listener(g_cm_core_p, cm_id->provider_data);
+	else
+		dprintk("cm_id->provider_data was NULL\n");
+	cm_id->rem_ref(cm_id);
+
+	return(0);
+}
+
+
+/**
+ * nes_cm_recv
+ */
+int nes_cm_recv(struct sk_buff *skb_p, struct net_device *netdevice)
+{
+	g_cm_core_p->api->recv_pkt(g_cm_core_p, netdev_priv(netdevice), skb_p);
+	return(0);
+}
+
+
+/**
+ * nes_cm_start
+ * Start and init a cm core module
+ */
+int nes_cm_start(void)
+{
+	dprintk("%s:%s[%u]\n", __FILE__, __FUNCTION__, __LINE__);
+	/* create the primary CM core, pass this handle to subsequent core inits */
+	g_cm_core_p = nes_cm_alloc_core();
+
+	return (0);
+}
+
+
+/**
+ * nes_cm_stop
+ * stop and dealloc all cm core instances
+ */
+int nes_cm_stop(void)
+{
+	g_cm_core_p->api->destroy_cm_core(g_cm_core_p);
+	return (0);
+}
+
+
+/**
+ * cm_event_connected
+ * handle a connected event, setup QPs and HW
+ */
+void cm_event_connected(struct nes_cm_event *event_p)
+{
+	int ret;
+	struct nes_qp *nesqp;
+	struct nes_vnic *nesvnic;
+	struct nes_device *nesdev;
+	struct nes_cm_node *node_p;
+	struct nes_adapter *nesadapter;
+	struct ib_qp_attr attr;
+	struct iw_cm_id *cm_id;
+	struct iw_cm_event cm_event;
+	struct nes_hw_qp_wqe *wqe;
+	struct nes_v4_quad nes_quad;
+
+	/* get all our handles */
+	node_p = event_p->node_p;
+	cm_id = node_p->cm_id;
+	dprintk("%s[%u] cm_event_connected - %p - cm_id = %p\n",
+			__FUNCTION__, __LINE__, node_p, cm_id);
+	nesqp = (struct nes_qp *)cm_id->provider_data;
+	nesvnic = to_nesvnic(nesqp->ibqp.device);
+	nesdev = nesvnic->nesdev;
+	nesadapter = nesdev->nesadapter;
+
+	atomic_inc(&cm_connecteds);
+	dprintk("%s[%u] Attempting to connect to  0x%08X:0x%04X on local port 0x%04X.\n",
+			__FUNCTION__, __LINE__,
+			ntohl(cm_id->remote_addr.sin_addr.s_addr),
+			ntohs(cm_id->remote_addr.sin_port),
+			ntohs(cm_id->local_addr.sin_port));
+
+	nes_cm_init_tsa_conn(nesqp, node_p);
+
+	/* set the QP tsa context */
+	nesqp->nesqp_context->tcpPorts = ntohs(cm_id->remote_addr.sin_port) << 16;
+	nesqp->nesqp_context->tcpPorts += ntohs(cm_id->local_addr.sin_port);
+	nesqp->nesqp_context->ip0 = ntohl(cm_id->remote_addr.sin_addr.s_addr);
+
+	nesqp->nesqp_context->misc2 |=
+			(u32)PCI_FUNC(nesdev->pcidev->devfn) << NES_QPCONTEXT_MISC2_SRC_IP_SHIFT;
+	nesqp->nesqp_context->arp_index_vlan |=
+			nes_arp_table(nesdev, nesqp->nesqp_context->ip0,
+			NULL, NES_ARP_RESOLVE) << 16;
+	nesqp->nesqp_context->ts_val_delta =
+			jiffies - nes_read_indexed(nesdev, NES_IDX_TCP_NOW);
+	nesqp->nesqp_context->ird_index = nesqp->hwqp.qp_id;
+	nesqp->nesqp_context->ird_ord_sizes |=
+			(u32)1 << NES_QPCONTEXT_ORDIRD_IWARP_MODE_SHIFT;
+
+	/* Adjust tail for not having a LSMM */
+	nesqp->hwqp.sq_tail = 1;
+
+#if defined(NES_SEND_FIRST_WRITE)
+	if (send_first) {
+		wqe = &nesqp->hwqp.sq_vbase[0];
+		*((struct nes_qp **)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) = nesqp;
+		*((u64 *)&wqe->wqe_words[NES_IWARP_SQ_WQE_COMP_CTX_LOW_IDX]) |=
+		NES_SW_CONTEXT_ALIGN>>1;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_MISC_IDX] = cpu_to_le32(NES_IWARP_SQ_OP_RDMAW);
+		wqe->wqe_words[NES_IWARP_SQ_WQE_TOTAL_PAYLOAD_IDX] = 0;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_LOW_IDX] = 0;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_FRAG0_HIGH_IDX] = 0;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_LENGTH0_IDX] = 0;
+		wqe->wqe_words[NES_IWARP_SQ_WQE_STAG0_IDX] = 0;
+
+		/* use the reserved spot on the WQ for the extra first WQE */
+		nesqp->nesqp_context->ird_ord_sizes &= ~(NES_QPCONTEXT_ORDIRD_LSMM_PRESENT |
+				NES_QPCONTEXT_ORDIRD_WRPDU | NES_QPCONTEXT_ORDIRD_ALSMM);
+		nesqp->skip_lsmm = 1;
+		nesqp->hwqp.sq_tail = 0;
+		nes_write32(nesdev->regs + NES_WQE_ALLOC,
+				(1 << 24) | 0x00800000 | nesqp->hwqp.qp_id);
+	}
+#endif
+
+	memset(&nes_quad, 0, sizeof(nes_quad));
+
+	nes_quad.DstIpAdrIndex = (u32)PCI_FUNC(nesdev->pcidev->devfn) << 27;
+	nes_quad.SrcIpadr = cm_id->remote_addr.sin_addr.s_addr;
+	nes_quad.TcpPorts = cm_id->remote_addr.sin_port;
+	nes_quad.TcpPorts |= (u32)cm_id->local_addr.sin_port << 16;
+
+	nesqp->hte_index = nes_crc32( 1, NES_HASH_CRC_INITAL_VALUE,
+			NES_HASH_CRC_FINAL_XOR, sizeof(nes_quad), (u8 *)&nes_quad,
+			ORDER, REFIN, REFOUT);
+
+	dprintk("%s: HTE Index = 0x%08X, CRC = 0x%08X\n", __FUNCTION__,
+			nesqp->hte_index, nesqp->hte_index & nesadapter->hte_index_mask);
+
+	nesqp->hte_index &= nesadapter->hte_index_mask;
+	nesqp->nesqp_context->hte_index = nesqp->hte_index;
+
+	nesqp->ietf_frame = &node_p->mpa_frame_p;
+	nesqp->private_data_len = (u8) node_p->mpa_frame_size;
+	node_p->core_p->api->accelerated(node_p->core_p, node_p);
+
+	/* modify QP state to rts */
+	attr.qp_state = IB_QPS_RTS;
+	nes_modify_qp(&nesqp->ibqp, &attr, IB_QP_STATE, NULL);
+
+	/* notify OF layer we successfully created the requested connection */
+	cm_event.event = IW_CM_EVENT_CONNECT_REPLY;
+	cm_event.status = IW_CM_EVENT_STATUS_ACCEPTED;
+	cm_event.provider_data = cm_id->provider_data;
+	cm_event.local_addr.sin_family = AF_INET;
+	cm_event.local_addr.sin_port = cm_id->local_addr.sin_port;
+	cm_event.remote_addr = cm_id->remote_addr;
+
+	cm_event.private_data = (void *) event_p->node_p->mpa_frame_b;
+	cm_event.private_data_len = (u8) event_p->node_p->mpa_frame_size;
+
+	cm_event.local_addr.sin_addr.s_addr = event_p->cm_info.rem_addr;
+	ret = cm_id->event_handler(cm_id, &cm_event);
+	dprintk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+			__FUNCTION__, __LINE__, ret);
+
+	if (ret)
+		printk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+				__FUNCTION__, __LINE__, ret);
+	dprintk("%s: Exiting connect thread for QP%u\n",
+			__FUNCTION__,  nesqp->hwqp.qp_id );
+
+	return;
+}
+
+
+/**
+ * cm_event_connect_error
+ */
+void cm_event_connect_error(struct nes_cm_event *event_p)
+{
+	struct nes_qp *nesqp;
+	struct iw_cm_id *cm_id;
+	struct iw_cm_event cm_event;
+	/* struct nes_cm_info cm_info; */
+	int ret;
+
+	if (!event_p->node_p)
+		return;
+
+	/* close and destroy the node */
+	event_p->node_p->core_p->api->close(event_p->node_p->core_p, event_p->node_p);
+
+	cm_id = event_p->node_p->cm_id;
+	if(!cm_id)
+		return;
+
+	dprintk("cm_event_connect_error - %p - cm_id = %p\n", event_p->node_p, cm_id);
+	nesqp = cm_id->provider_data;
+
+	if(!nesqp)
+		return;
+
+	/* notify OF layer about this connection error event */
+	/* cm_id->rem_ref(cm_id); */
+	nesqp->cm_id = NULL;
+	cm_id->provider_data = NULL;
+	cm_event.event = IW_CM_EVENT_CONNECT_REPLY;
+	cm_event.status = IW_CM_EVENT_STATUS_REJECTED;
+	cm_event.provider_data = cm_id->provider_data;
+	cm_event.local_addr = cm_id->local_addr;
+	cm_event.remote_addr = cm_id->remote_addr;
+	cm_event.private_data = NULL;
+	cm_event.private_data_len = 0;
+
+	cm_id->rem_ref(cm_id);
+	ret = cm_id->event_handler(cm_id, &cm_event);
+	dprintk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+			__FUNCTION__, __LINE__, ret);
+	if (ret)
+		printk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+				__FUNCTION__, __LINE__, ret);
+
+	return;
+}
+
+
+/**
+ * cm_event_reset
+ */
+void cm_event_reset(struct nes_cm_event *event_p)
+{
+	struct nes_qp *nesqp;
+	struct iw_cm_id *cm_id;
+	struct iw_cm_event cm_event;
+	/* struct nes_cm_info cm_info; */
+	int ret;
+
+	if (!event_p->node_p)
+		return;
+
+	cm_id = event_p->node_p->cm_id;
+
+	dprintk("cm_event_connect_error - %p - cm_id = %p\n", event_p->node_p, cm_id);
+	nesqp = cm_id->provider_data;
+
+	/* notify OF layer about this connection error event */
+	cm_id->rem_ref(cm_id);
+	nesqp->cm_id = NULL;
+	/* cm_id->provider_data = NULL; */
+	cm_event.event = IW_CM_EVENT_DISCONNECT;
+	cm_event.status = IW_CM_EVENT_STATUS_RESET;
+	cm_event.provider_data = cm_id->provider_data;
+	cm_event.local_addr = cm_id->local_addr;
+	cm_event.remote_addr = cm_id->remote_addr;
+	cm_event.private_data = NULL;
+	cm_event.private_data_len = 0;
+
+	ret = cm_id->event_handler(cm_id, &cm_event);
+	dprintk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+			__FUNCTION__, __LINE__, ret);
+
+	return;
+}
+
+
+/**
+ * cm_event_mpa_req
+ */
+void cm_event_mpa_req(struct nes_cm_event *event_p)
+{
+	struct iw_cm_id   *cm_id;
+	struct iw_cm_event cm_event;
+	int ret;
+	struct nes_cm_node *node_p;
+
+	node_p = event_p->node_p;
+	if (!node_p)
+		return;
+	cm_id = node_p->cm_id;
+
+	atomic_inc(&cm_connect_reqs);
+	dprintk("%s[%u] cm_event_mpa_req - %p - cm_id = %p\n",
+			__FUNCTION__, __LINE__, node_p, cm_id);
+
+	cm_event.event = IW_CM_EVENT_CONNECT_REQUEST;
+	cm_event.status = IW_CM_EVENT_STATUS_OK;
+	cm_event.provider_data = (void *)node_p;
+
+	cm_event.local_addr.sin_family = AF_INET;
+	cm_event.local_addr.sin_port = htons(event_p->cm_info.loc_port);
+	cm_event.local_addr.sin_addr.s_addr = htonl(event_p->cm_info.loc_addr);
+
+	cm_event.remote_addr.sin_family = AF_INET;
+	cm_event.remote_addr.sin_port = htons(event_p->cm_info.rem_port);
+	cm_event.remote_addr.sin_addr.s_addr = htonl(event_p->cm_info.rem_addr);
+
+	cm_event.private_data                = node_p->mpa_frame_b;
+	cm_event.private_data_len            = (u8) node_p->mpa_frame_size;
+
+	ret = cm_id->event_handler(cm_id, &cm_event);
+	if (ret)
+		printk("%s[%u] OFA CM event_handler returned, ret=%d\n",
+				__FUNCTION__, __LINE__, ret);
+
+	return;
+}
+
+
+static void nes_cm_event_handler(void *parm);
+
+/**
+ * nes_cm_post_event
+ * post an event to the cm event handler
+ */
+int nes_cm_post_event(struct nes_cm_event *event_p)
+{
+	atomic_inc(&event_p->node_p->core_p->events_posted);
+
+	NES_INIT_WORK(&event_p->event_work, nes_cm_event_handler, (void *)event_p);
+	dprintk("%s[%u] queue_work, event_p=%p\n", __FUNCTION__, __LINE__, event_p);
+
+	queue_work(event_p->node_p->core_p->event_wq, &event_p->event_work);
+
+	dprintk("%s[%u] Exit\n", __FUNCTION__, __LINE__);
+	return(0);
+}
+
+
+/**
+ * nes_cm_event_handler
+ * worker function to handle cm events
+ * will free instance of nes_cm_event
+ */
+static void nes_cm_event_handler(void *parm)
+{
+	struct work_struct *work = parm;
+	struct nes_cm_event *event_p = container_of(work, struct nes_cm_event, event_work);
+	struct nes_cm_core *core_p;
+
+	dprintk("%s[%u] Enter\n", __FUNCTION__, __LINE__);
+
+	if (!event_p)
+		return;
+	core_p = event_p->node_p->core_p;
+	dprintk("%s[%u] event_p=%p, event_p->type=%u, events posted=%u\n",
+			__FUNCTION__, __LINE__,
+			event_p, event_p->type, atomic_read(&core_p->events_posted));
+
+	switch (event_p->type) {
+		case NES_CM_EVENT_MPA_REQ:
+			cm_event_mpa_req(event_p);
+			dprintk("%s:%s[%u] -- CM Event: MPA REQUEST\n",
+					__FILE__, __FUNCTION__, __LINE__);
+			break;
+		case NES_CM_EVENT_RESET:
+			dprintk("%s:%s[%u] -- CM Event: RESET\n",
+					__FILE__, __FUNCTION__, __LINE__);
+			cm_event_reset(event_p);
+			break;
+		case NES_CM_EVENT_CONNECTED:
+			cm_event_connected(event_p);
+			dprintk("%s:%s[%u] -- CM Event: CONNECTED\n",
+					__FILE__, __FUNCTION__, __LINE__);
+			break;
+		case NES_CM_EVENT_ABORTED:
+			cm_event_connect_error(event_p);
+			dprintk("%s:%s[%u] -- CM Event: ABORTED\n",
+					__FILE__, __FUNCTION__, __LINE__);
+			break;
+		case NES_CM_EVENT_DROPPED_PKT:
+			dprintk("%s:%s[%u] -- CM Event: DROPPED PKT\n",
+					__FILE__, __FUNCTION__, __LINE__);
+			break;
+		default:
+			dprintk("%s:%s[%u] -- CM Event: UNKNOWN EVENT TYPE\n",
+					__FILE__, __FUNCTION__, __LINE__);
+			break;
+	}
+
+	dprintk("%s[%u] decrement events_posted, =%u\n",
+			__FUNCTION__, __LINE__, atomic_read(&core_p->events_posted));
+	atomic_dec(&core_p->events_posted);
+	dprintk("%s[%u] free event_p=%p\n", __FUNCTION__, __LINE__, event_p);
+
+	kfree(event_p);
+	dprintk("%s[%u] Exit\n", __FUNCTION__, __LINE__);
+
+	return;
+}
