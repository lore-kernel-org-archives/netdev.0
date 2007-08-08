From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/14] nes: connection manager routines
Date: Tue, 07 Aug 2007 21:46:37 -0400
Message-ID: <46B9207D.6000905@garzik.org>
References: <200708080050.l780oGxo004694@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: ggrundstrom@neteffect.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36723 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758194AbXHHBqo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 21:46:44 -0400
In-Reply-To: <200708080050.l780oGxo004694@neteffect.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ggrundstrom@neteffect.com wrote:
> +atomic_t cm_connects;
> +atomic_t cm_accepts;
> +atomic_t cm_disconnects;
> +atomic_t cm_closes;
> +atomic_t cm_connecteds;
> +atomic_t cm_connect_reqs;
> +atomic_t cm_rejects;

do you really want to take the hit of a LOCK prefix each time you 
increment a stat???


> +static struct nes_cm_event *create_event(struct nes_cm_node *node_p,
> +		enum nes_cm_event_type type)
> +{
> +	struct nes_cm_event *event_p;
> +
> +	if(!node_p->cm_id)
> +		return NULL;
> +
> +	/* allocate an empty event */
> +	event_p = (struct nes_cm_event *)kzalloc(sizeof(struct nes_cm_event),
> +			GFP_ATOMIC);

kill pointless cast from void*

> +	if (!event_p)
> +		return(NULL);

return is not a function.  remove the parens.


> +	event_p->type = type;
> +	event_p->node_p = node_p;
> +	event_p->cm_info.rem_addr = node_p->rem_addr;
> +	event_p->cm_info.loc_addr = node_p->loc_addr;
> +	event_p->cm_info.rem_port = node_p->rem_port;
> +	event_p->cm_info.loc_port = node_p->loc_port;
> +	event_p->cm_info.cm_id = node_p->cm_id;
> +
> +	dprintk("%s[%u] Created event_p=%p, type=%u, dst_addr=%08x[%x], src_addr=%08x[%x]\n",
> +			__FUNCTION__, __LINE__, event_p, type,
> +			event_p->cm_info.loc_addr, event_p->cm_info.loc_port,
> +			event_p->cm_info.rem_addr, event_p->cm_info.rem_port);

these dprintk's make the code far more unreadable than it should be. 
these should be cleaned up.


> +	nes_cm_post_event(event_p);
> +	return(event_p);

return is not a function, remove parens


> +int send_mpa_request(struct nes_cm_node *node_p)
> +{
> +	struct sk_buff *skb_p;
> +	int ret;
> +
> +	skb_p = get_free_pkt(node_p);
> +	if (!skb_p) {
> +		dprintk("%s:%s[%u] -- Failed to get a Free pkt\n",
> +				__FILE__, __FUNCTION__, __LINE__);
> +		return (-1);
> +	}
> +
> +	/* send an MPA Request frame */
> +	form_cm_frame(skb_p, node_p, NULL, 0, &node_p->mpa_frame_p,
> +			node_p->mpa_frame_size, SET_ACK);
> +
> +	ret = schedule_nes_timer(node_p, skb_p, NES_TIMER_TYPE_SEND, 1);
> +	if (ret < 0) {
> +		return (ret);
> +	}

remove braces around single C statements


> +	dprintk("%s[%u] -- \n", __FUNCTION__, __LINE__);
> +	return (0);

* remove all the "_p" suffixes.  the kernel is not the place to start 
approaching Hungarian notation

* return is not a function


> + * recv_mpa - process a received TCP pkt, we are expecting an
> + * IETF MPA frame
> + */
> +static int parse_mpa(struct nes_cm_node *node_p, u8 *buffer, u32 len)

'buffer' should be void* not u8*


> +{
> +	struct ietf_mpa_frame *mpa_frame_p;
> +
> +	dprintk("%s[%u] Enter, node_p=%p\n", __FUNCTION__, __LINE__, node_p);
> +	nes_dump_mem(buffer, len);
> +
> +	/* assume req frame is in tcp data payload */
> +	if (len < sizeof(struct ietf_mpa_frame)) {
> +		dprintk("The received ietf buffer was too small (%x)\n", len);
> +		return (-1);

return is not a function


> +	}
> +
> +	mpa_frame_p = (struct ietf_mpa_frame *)buffer;

kill pointless cast, once 'buffer' type is fixed


> +	node_p->mpa_frame_size = (u32)ntohs(mpa_frame_p->priv_data_len);

kill pointless cast


> +	if (node_p->mpa_frame_size + sizeof(struct ietf_mpa_frame) != len) {
> +		dprintk("The received ietf buffer was not right complete (%x + %x != %x)\n",
> +				node_p->mpa_frame_size, (u32)sizeof(struct ietf_mpa_frame), len);
> +		return (-1);
> +	}
> +
> +	dprintk("%s[%u] -- recvd MPA Frame - with private data len = %u\n",
> +			__FILE__, __LINE__, node_p->mpa_frame_size);
> +
> +	/* copy entire MPA frame to our node's frame */
> +	memcpy(node_p->mpa_frame_b, buffer + sizeof(struct ietf_mpa_frame),
> +			node_p->mpa_frame_size);
> +	nes_dump_mem(&node_p->mpa_frame_p, node_p->mpa_frame_size);
> +	dprintk("%s:%s[%u] -- Exit\n", __FILE__, __FUNCTION__, __LINE__);
> +
> +	return(0);
> +}

return is not a function


> + * handle_exception_pkt - process an exception packet.
> + * We have been in a TSA state, and we have now received SW
> + * TCP/IP traffic should be a FIN request or IP pkt with options
> + */
> +static int handle_exception_pkt(struct nes_cm_node *node_p,
> +		struct sk_buff *skb_p)
> +{
> +	int ret = 0;
> +	struct tcphdr *tcphdr_p = skb_p->h.th;

kill all "_p" suffixes


> +	/* first check to see if this a FIN pkt */
> +	if (tcphdr_p->fin) {
> +		/* we need to ACK the FIN request */
> +		send_ack(node_p);
> +
> +		/* check which side we are (client/server) and set next state accordingly */
> +		if (node_p->tcp_cntxt.client)
> +			node_p->state = NES_CM_STATE_CLOSING;
> +		else {
> +			/* we are the server side */
> +			node_p->state = NES_CM_STATE_CLOSE_WAIT;
> +			/* since this is a self contained CM we don't wait for */
> +			/* an APP to close us, just send final FIN immediately */
> +			ret = send_fin(node_p, NULL);
> +			node_p->state = NES_CM_STATE_LAST_ACK;
> +		}
> +	} else {
> +		ret = -EINVAL;

why is this TCP management in this driver?


> + * form_cm_frame - get a free packet and build empty frame Use
> + * node info to build.
> + */
> +struct sk_buff *form_cm_frame(struct sk_buff *skb_p, struct nes_cm_node *node_p,
> +		void *options, u32 optionsize, void *data, u32 datasize, u8 flags)
> +{
> +	struct tcphdr *tcphdr_p;
> +	struct iphdr *iphdr_p;
> +	struct ethhdr *ethhdr_p;
> +	u8 *buf_p;

'buf' should be void* not u8*


> +	u16 packetsize = sizeof(*iphdr_p);

kill suffixes


> +	packetsize += sizeof(*tcphdr_p);
> +	packetsize +=  optionsize + datasize;
> +
> +	memset(skb_p->data, 0x00, ETH_HLEN + sizeof(*iphdr_p) + sizeof(*tcphdr_p));
> +
> +	skb_p->len = 0;

why?  are you reusing or abusing the skb somehow?


> +	buf_p = skb_put(skb_p, packetsize + ETH_HLEN);
> +
> +	ethhdr_p = (struct ethhdr *) buf_p;
> +	buf_p += ETH_HLEN;
> +
> +	iphdr_p = skb_p->nh.iph = (struct iphdr *)buf_p;
> +	buf_p += sizeof(*iphdr_p);
> +
> +	tcphdr_p  = skb_p->h.th = (struct tcphdr *) buf_p;
> +	buf_p += sizeof(*tcphdr_p);
> +
> +#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,20))
> +	skb_p->ip_summed = CHECKSUM_HW;
> +#else
> +	skb_p->ip_summed = CHECKSUM_PARTIAL;
> +#endif
> +	skb_p->protocol = ntohs(0x800);
> +	skb_p->data_len = 0;
> +	skb_p->mac.raw = skb_p->data;
> +	skb_p->mac_len = ETH_HLEN;
> +
> +	memcpy(ethhdr_p->h_dest, node_p->rem_mac, ETH_ALEN);
> +	memcpy(ethhdr_p->h_source, node_p->loc_mac, ETH_ALEN);
> +	ethhdr_p->h_proto = htons(0x0800);
> +
> +	iphdr_p->version = IPVERSION;
> +	iphdr_p->ihl = 5;		/* 5 * 4Byte words, IP headr len */
> +	iphdr_p->tos = 0;
> +	iphdr_p->tot_len = htons(packetsize);
> +	iphdr_p->id = htons(++node_p->tcp_cntxt.loc_id);
> +	
> +	iphdr_p->frag_off = ntohs(0x4000);
> +	iphdr_p->ttl = 0x40;
> +	iphdr_p->protocol= 0x06;	/* IPPROTO_TCP */
> +
> +	iphdr_p->saddr = htonl(node_p->loc_addr);
> +	iphdr_p->daddr = htonl(node_p->rem_addr);
> +
> +	tcphdr_p->source = htons(node_p->loc_port);
> +	tcphdr_p->dest = htons(node_p->rem_port);
> +	tcphdr_p->seq = htonl(node_p->tcp_cntxt.loc_seq_num);
> +
> +	if (flags & SET_ACK) {
> +		node_p->tcp_cntxt.loc_ack_num = node_p->tcp_cntxt.rcv_nxt;
> +		tcphdr_p->ack_seq = htonl(node_p->tcp_cntxt.loc_ack_num);
> +		tcphdr_p->ack = 1;
> +	} else
> +		tcphdr_p->ack_seq = 0;
> +
> +	if (flags & SET_SYN) {
> +		node_p->tcp_cntxt.loc_seq_num ++;
> +		tcphdr_p->syn = 1;
> +	} else
> +		node_p->tcp_cntxt.loc_seq_num += datasize;	/* data (no headers) */
> +
> +	dprintk("%s[%u] Local seq # now %x\n", __FUNCTION__, __LINE__,
> +			node_p->tcp_cntxt.loc_seq_num);
> +	if (flags & SET_FIN)
> +		tcphdr_p->fin = 1;
> +
> +	if (flags & SET_RST)
> +		tcphdr_p->rst = 1;
> +
> +	tcphdr_p->doff = (u16) ((sizeof(*tcphdr_p) + optionsize + 3)>> 2);
> +	tcphdr_p->window = htons(node_p->tcp_cntxt.rcv_wnd);
> +	tcphdr_p->urg_ptr = 0;
> +	if (optionsize)
> +		memcpy(buf_p, options, optionsize);
> +	buf_p += optionsize;
> +	if (datasize)
> +		memcpy(buf_p, data, datasize);
> +
> +	skb_shinfo(skb_p)->nr_frags = 0;
> +
> +	return(skb_p);

creating TCP packets by hand?


> +static void dump_pkt(struct sk_buff *skb_p)
> +{
> +	u8 *pkt_p;
> +
> +	if (!skb_p)
> +		return;
> +
> +	pkt_p = (u8 *)skb_p->data;
> +	/* dprintk("skb_p->head=%p, data=%p, tail=%p, end=%p,"
> +			"skb_p->len=%u, data_len=%u\n",
> +			skb_p->head, skb_p->data, skb_p->tail, skb_p->end,
> +			skb_p->len, skb_p->data_len);
> +	*/
> +	nes_dump_mem(pkt_p, skb_p->len);
> +
> +	return;
> +}
> +
> +
> +/**
> + * print_core - dump a cm core
> + */
> +static void print_core(struct nes_cm_core *core_p)
> +{
> +	dprintk("---------------------------------------------\n");
> +	dprintk("CM Core  -- (core_p = %p )\n", core_p);
> +	if (!core_p)
> +		return;
> +	dprintk("---------------------------------------------\n");
> +	dprintk("Session ID    : %u \n", atomic_read(&core_p->session_id));
> +
> +	dprintk("State         : %u \n",  core_p->state);
> +
> +	dprintk("Tx Free cnt   : %u \n", skb_queue_len(&core_p->tx_free_list));
> +	dprintk("Listen Nodes  : %u \n", atomic_read(&core_p->listen_node_cnt));
> +	dprintk("Active Nodes  : %u \n", atomic_read(&core_p->node_cnt));
> +
> +	dprintk("core_p        : %p \n",  core_p);
> +
> +	dprintk("-------------- end core ---------------\n");
> +	return;

kill all pointless "return;" at the end of functions


> +int schedule_nes_timer(struct nes_cm_node *node_p, struct sk_buff *skb_p,
> +						enum nes_timer_type type, int send_retrans)
> +{
> +	unsigned long  flags;
> +	struct nes_cm_core *core_p;
> +	struct nes_timer_entry *new_send;
> +	int ret = 0;
> +	u32 was_timer_set;
> +
> +	new_send = kzalloc(sizeof(struct nes_timer_entry), GFP_ATOMIC);
> +	if(!new_send)
> +		return -1;
> +	/* new_send->timetosend = currenttime */
> +	new_send->retrycount = NES_DEFAULT_RETRYS;
> +	new_send->retranscount = NES_DEFAULT_RETRANS;
> +	new_send->skb = skb_p;
> +	new_send->timetosend = jiffies;
> +	new_send->type = type;
> +	new_send->netdev = node_p->netdev_p;
> +	new_send->send_retrans = send_retrans;
> +
> +	if(type == NES_TIMER_TYPE_CLOSE) {
> +		dprintk("Scheduling Close: node_p = %p, new_send = %p.\n", node_p, new_send);
> +		new_send->timetosend += (HZ/2); /* TODO: decide on the correct value here */
> +		spin_lock_irqsave(&node_p->recv_list_lock, flags);
> +		list_add_tail(&new_send->list, &node_p->recv_list);
> +		spin_unlock_irqrestore(&node_p->recv_list_lock, flags);
> +	}
> +
> +	if(type == NES_TIMER_TYPE_SEND)	{
> +		dprintk("Sending Packet %p:\n", new_send);
> +		new_send->seq_num = htonl(skb_p->h.th->seq);
> +		dump_pkt(skb_p);
> +		spin_lock_irqsave(&node_p->retrans_list_lock, flags);
> +		list_add_tail(&new_send->list, &node_p->retrans_list);
> +		spin_unlock_irqrestore(&node_p->retrans_list_lock, flags);
> +	}
> +	if(type == NES_TIMER_TYPE_RECV)	{
> +		new_send->seq_num = htonl(skb_p->h.th->seq);
> +		spin_lock_irqsave(&node_p->recv_list_lock, flags);
> +		list_add_tail(&new_send->list, &node_p->recv_list);
> +		spin_unlock_irqrestore(&node_p->recv_list_lock, flags);
> +	}

the lack of 'else' keywords implies these more than one of these 
conditions can occur simultaneously.  If so, don't you think it's quite 
expensive to grab and release all these locks?


> +	core_p = node_p->core_p;
> +
> +	was_timer_set = timer_pending(&core_p->tcp_timer);
> +
> +	if(!was_timer_set || time_before(new_send->timetosend,
> +									core_p->tcp_timer.expires)){
> +		if(was_timer_set) {
> +			del_timer(&core_p->tcp_timer);
> +		}

single C statement: remove braces

> +		core_p->tcp_timer.expires = new_send->timetosend;
> +
> +		add_timer(&core_p->tcp_timer);
> +	}
> +	return(ret);

return not a function


> +/**
> + * nes_cm_timer_tick
> + */
> +void nes_cm_timer_tick(unsigned long pass)

this seems like a poor design.  AFAICS you should be using delayed 
workqueues or something other than a timer.



> +	unsigned long flags, qplockflags;
> +	unsigned long nexttimeout = jiffies + NES_LONG_TIME;
> +	struct iw_cm_id *cm_id;
> +	struct nes_cm_node *node_p;
> +	struct nes_timer_entry *send_entry, *recv_entry;
> +	struct list_head *list_p_core, *list_p_core_temp, *list_p_node_temp, *list_p_node;
> +	struct nes_cm_core *core_p = g_cm_core_p;
> +	struct nes_qp *nesqp;
> +	u32 settimer = 0;
> +	int ret = NETDEV_TX_OK;
> +
> +	list_for_each_safe(list_p_node, list_p_core_temp, &core_p->connected_nodes) {
> +		node_p = container_of(list_p_node, struct nes_cm_node, list);
> +		spin_lock_irqsave(&node_p->recv_list_lock, flags);
> +		list_for_each_safe(list_p_core, list_p_node_temp, &node_p->recv_list) {
> +			recv_entry = container_of(list_p_core, struct nes_timer_entry, list);
> +			if ((time_after(recv_entry->timetosend, jiffies)) &&
> +					(recv_entry->type == NES_TIMER_TYPE_CLOSE)) {
> +				if(nexttimeout > recv_entry->timetosend || !settimer) {
> +					nexttimeout = recv_entry->timetosend;
> +					settimer = 1;
> +				}
> +				continue;
> +			}
> +			list_del(&recv_entry->list);
> +			cm_id = node_p->cm_id;
> +			spin_unlock_irqrestore(&node_p->recv_list_lock, flags);
> +			if(recv_entry->type == NES_TIMER_TYPE_CLOSE) {
> +				nesqp = (struct nes_qp *)recv_entry->skb;
> +				cm_id->rem_ref(cm_id);
> +				spin_lock_irqsave(&nesqp->lock, qplockflags);
> +				if (nesqp->cm_id) {
> +					dprintk("%s: QP%u: cm_id = %p: ****** HIT A NES_TIMER_TYPE_CLOSE"
> +							" with something to do!!! ******\n",
> +							__FUNCTION__, nesqp->hwqp.qp_id, cm_id);
> +					nesqp->hw_tcp_state = NES_AEQE_TCP_STATE_CLOSED;
> +					nesqp->last_aeq = NES_AEQE_AEID_RESET_SENT;
> +					nesqp->ibqp_state = IB_QPS_ERR;
> +					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
> +					nes_cm_disconn(nesqp);
> +				} else {
> +					spin_unlock_irqrestore(&nesqp->lock, qplockflags);
> +					dprintk("%s: QP%u: cm_id = %p: ****** HIT A NES_TIMER_TYPE_CLOSE"
> +							" with nothing to do!!! ******\n",
> +							__FUNCTION__, nesqp->hwqp.qp_id, cm_id);
> +					nes_rem_ref(&nesqp->ibqp);
> +				}
> +			}
> +			else if(recv_entry->type == NES_TIMER_TYPE_RECV) {
> +				dprintk("Processing Packet (%p):\n", recv_entry->skb->data);
> +				dump_pkt(recv_entry->skb);
> +				process_packet(node_p, recv_entry->skb, core_p);
> +				dev_kfree_skb_any(recv_entry->skb);
> +			}
> +			kfree(recv_entry);
> +			spin_lock_irqsave(&node_p->recv_list_lock, flags);
> +		}
> +		spin_unlock_irqrestore(&node_p->recv_list_lock, flags);
> +
> +		spin_lock_irqsave(&node_p->retrans_list_lock, flags);
> +		list_for_each_safe(list_p_core, list_p_node_temp, &node_p->retrans_list) {
> +			send_entry = container_of(list_p_core, struct nes_timer_entry, list);
> +			if(time_after(send_entry->timetosend, jiffies)) {
> +				if(nexttimeout > send_entry->timetosend || !settimer) {
> +					nexttimeout = send_entry->timetosend;
> +					settimer = 1;
> +				}
> +				continue;
> +			}
> +			list_del(&send_entry->list);
> +			spin_unlock_irqrestore(&node_p->retrans_list_lock, flags);
> +			if(send_entry->type == NES_TIMER_NODE_CLEANUP){
> +				dprintk("!send - %p-> next/prev=%p,%p, tts=%lx, skb=%p, type=%x,"
> +						" retry=%x, retrans=%x, context=%x, seq=%x\n",
> +						send_entry, send_entry->list.next, send_entry->list.prev,
> +						send_entry->timetosend, send_entry->skb, send_entry->type,
> +						send_entry->retrycount, send_entry->retranscount,
> +						send_entry->context, send_entry->seq_num);
> +				spin_lock_irqsave(&node_p->retrans_list_lock, flags);
> +				continue;
> +			}
> +			if(send_entry->seq_num < node_p->tcp_cntxt.rem_ack_num ||
> +				node_p->accelerated) {
> +					dev_kfree_skb_any(send_entry->skb);
> +					kfree(send_entry);
> +					spin_lock_irqsave(&node_p->retrans_list_lock, flags);
> +					continue;
> +			}
> +
> +			if(!send_entry->retranscount || !send_entry->retrycount) {
> +				dev_kfree_skb_any(send_entry->skb);
> +				kfree(send_entry);
> +				create_event(node_p, NES_CM_EVENT_ABORTED);
> +				spin_lock_irqsave(&node_p->retrans_list_lock, flags);
> +				continue;
> +			}
> +			atomic_inc(&send_entry->skb->users);
> +			ret = nes_nic_cm_xmit(send_entry->skb, node_p->netdev_p);
> +			if(ret != NETDEV_TX_OK) {
> +				atomic_dec(&send_entry->skb->users);
> +				send_entry->retrycount--;
> +				nexttimeout = jiffies + NES_SHORT_TIME;
> +				settimer = 1;
> +				spin_lock_irqsave(&node_p->retrans_list_lock, flags);
> +				list_add(&send_entry->list, &node_p->retrans_list);
> +				break;
> +			}
> +			dprintk("Packet Sent:\n");
> +			dump_pkt(send_entry->skb);
> +			if(send_entry->send_retrans) {
> +				send_entry->retranscount--;
> +				send_entry->timetosend = jiffies + NES_RETRY_TIMEOUT;
> +				if(nexttimeout > send_entry->timetosend || !settimer) {
> +					nexttimeout = send_entry->timetosend;
> +					settimer = 1;
> +				}
> +				spin_lock_irqsave(&node_p->retrans_list_lock, flags);
> +				list_add(&send_entry->list, &node_p->retrans_list);
> +				continue;
> +			}
> +			else {
> +				dev_kfree_skb_any(send_entry->skb);
> +				kfree(send_entry);
> +				spin_lock_irqsave(&node_p->retrans_list_lock, flags);
> +				continue;
> +			}
> +		}
> +		spin_unlock_irqrestore(&node_p->retrans_list_lock, flags);
> +
> +		if(ret != NETDEV_TX_OK)
> +			break;
> +	}
> +
> +	if(settimer)
> +	{
> +		if(timer_pending(&core_p->tcp_timer)) {
> +			del_timer(&core_p->tcp_timer);
> +		}
> +		core_p->tcp_timer.expires  = nexttimeout;
> +		add_timer(&core_p->tcp_timer);

are you reinventing mod_timer() ?

I stopped reviewing here.  Please make all the style changes so that we 
can review your driver in depth.

All the debug-print code makes the driver highly unreadable.  Most of 
that should go away now that you are moving towards a kernel submission.

	Jeff


