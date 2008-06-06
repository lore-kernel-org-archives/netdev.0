From: frank.blaschka@de.ibm.com
Subject: [patch 3/5] qeth: reduce number of kernel messages
Date: Fri, 06 Jun 2008 12:37:46 +0200
Message-ID: <20080606103828.976900000@de.ibm.com>
References: <20080606103743.638691000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:24675 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754947AbYFFKjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 06:39:14 -0400
Content-Disposition: inline; filename=602-qeth-rmmsg.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Remove unnecessary messages. Write important debug information to
s390dbf.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |   30 +++------------
 drivers/s390/net/qeth_core_offl.c |    6 +--
 drivers/s390/net/qeth_core_sys.c  |   12 ------
 drivers/s390/net/qeth_l2_main.c   |   29 +++++----------
 drivers/s390/net/qeth_l3_main.c   |   72 +++++++++++---------------------------
 drivers/s390/net/qeth_l3_sys.c    |   24 ------------
 6 files changed, 42 insertions(+), 131 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2008-06-06 10:53:13.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2008-06-06 10:53:13.000000000 +0200
@@ -290,9 +290,6 @@ int qeth_set_large_send(struct qeth_card
 			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
 						NETIF_F_HW_CSUM;
 		} else {
-			PRINT_WARN("TSO not supported on %s. "
-				   "large_send set to 'no'.\n",
-				   card->dev->name);
 			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
 						NETIF_F_HW_CSUM);
 			card->options.large_send = QETH_LARGE_SEND_NO;
@@ -1433,7 +1430,7 @@ static int qeth_idx_activate_get_answer(
 	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
 
 	if (rc) {
-		PRINT_ERR("Error2 in activating channel rc=%d\n", rc);
+		QETH_DBF_MESSAGE(2, "Error2 in activating channel rc=%d\n", rc);
 		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		atomic_set(&channel->irq_pending, 0);
 		wake_up(&card->wait_q);
@@ -1503,7 +1500,8 @@ static int qeth_idx_activate_channel(str
 	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
 
 	if (rc) {
-		PRINT_ERR("Error1 in activating channel. rc=%d\n", rc);
+		QETH_DBF_MESSAGE(2, "Error1 in activating channel. rc=%d\n",
+			rc);
 		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		atomic_set(&channel->irq_pending, 0);
 		wake_up(&card->wait_q);
@@ -1653,7 +1651,6 @@ int qeth_send_control_data(struct qeth_c
 
 	reply = qeth_alloc_reply(card);
 	if (!reply) {
-		PRINT_WARN("Could not alloc qeth_reply!\n");
 		return -ENOMEM;
 	}
 	reply->callback = reply_cb;
@@ -2607,15 +2604,9 @@ void qeth_queue_input_buffer(struct qeth
 		if (newcount < count) {
 			/* we are in memory shortage so we switch back to
 			   traditional skb allocation and drop packages */
-			if (!atomic_read(&card->force_alloc_skb) &&
-			    net_ratelimit())
-				PRINT_WARN("Switch to alloc skb\n");
 			atomic_set(&card->force_alloc_skb, 3);
 			count = newcount;
 		} else {
-			if ((atomic_read(&card->force_alloc_skb) == 1) &&
-			    net_ratelimit())
-				PRINT_WARN("Switch to sg\n");
 			atomic_add_unless(&card->force_alloc_skb, -1, 0);
 		}
 
@@ -3029,7 +3020,7 @@ int qeth_get_elements_no(struct qeth_car
 		elements_needed = 1 + (((((unsigned long) hdr) % PAGE_SIZE)
 			+ skb->len) >> PAGE_SHIFT);
 	if ((elements_needed + elems) > QETH_MAX_BUFFER_ELEMENTS(card)) {
-		PRINT_ERR("Invalid size of IP packet "
+		QETH_DBF_MESSAGE(2, "Invalid size of IP packet "
 			"(Number=%d / Length=%d). Discarded.\n",
 			(elements_needed+elems), skb->len);
 		return 0;
@@ -3242,8 +3233,6 @@ int qeth_do_send_packet(struct qeth_card
 			 * free buffers) to handle eddp context */
 			if (qeth_eddp_check_buffers_for_context(queue, ctx)
 				< 0) {
-				if (net_ratelimit())
-					PRINT_WARN("eddp tx_dropped 1\n");
 				rc = -EBUSY;
 				goto out;
 			}
@@ -3255,7 +3244,6 @@ int qeth_do_send_packet(struct qeth_card
 		tmp = qeth_eddp_fill_buffer(queue, ctx,
 						queue->next_buf_to_fill);
 		if (tmp < 0) {
-			PRINT_ERR("eddp tx_dropped 2\n");
 			rc = -EBUSY;
 			goto out;
 		}
@@ -3597,8 +3585,6 @@ int qeth_snmp_command(struct qeth_card *
 
 	if ((!qeth_adp_supported(card, IPA_SETADP_SET_SNMP_CONTROL)) &&
 	    (!card->options.layer2)) {
-		PRINT_WARN("SNMP Query MIBS not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 	/* skip 4 bytes (data_len struct member) to get req_len */
@@ -3629,7 +3615,7 @@ int qeth_snmp_command(struct qeth_card *
 	rc = qeth_send_ipa_snmp_cmd(card, iob, QETH_SETADP_BASE_LEN + req_len,
 				    qeth_snmp_command_cb, (void *)&qinfo);
 	if (rc)
-		PRINT_WARN("SNMP command failed on %s: (0x%x)\n",
+		QETH_DBF_MESSAGE(2, "SNMP command failed on %s: (0x%x)\n",
 			   QETH_CARD_IFNAME(card), rc);
 	else {
 		if (copy_to_user(udata, qinfo.udata, qinfo.udata_len))
@@ -3802,8 +3788,8 @@ retry:
 	if (mpno)
 		mpno = min(mpno - 1, QETH_MAX_PORTNO);
 	if (card->info.portno > mpno) {
-		PRINT_ERR("Device %s does not offer port number %d \n.",
-			CARD_BUS_ID(card), card->info.portno);
+		QETH_DBF_MESSAGE(2, "Device %s does not offer port number %d"
+			"\n.", CARD_BUS_ID(card), card->info.portno);
 		rc = -ENODEV;
 		goto out;
 	}
@@ -3980,8 +3966,6 @@ struct sk_buff *qeth_core_get_next_skb(s
 	return skb;
 no_mem:
 	if (net_ratelimit()) {
-		PRINT_WARN("No memory for packet received on %s.\n",
-			   QETH_CARD_IFNAME(card));
 		QETH_DBF_TEXT(TRACE, 2, "noskbmem");
 		QETH_DBF_TEXT_(TRACE, 2, "%s", CARD_BUS_ID(card));
 	}
diff -urpN linux-2.6/drivers/s390/net/qeth_core_offl.c linux-2.6-patched/drivers/s390/net/qeth_core_offl.c
--- linux-2.6/drivers/s390/net/qeth_core_offl.c	2008-06-06 10:52:45.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_offl.c	2008-06-06 10:53:13.000000000 +0200
@@ -122,8 +122,8 @@ int qeth_eddp_fill_buffer(struct qeth_qd
 			if (element == 0)
 				return -EBUSY;
 			else {
-				PRINT_WARN("could only partially fill eddp "
-					   "buffer!\n");
+				QETH_DBF_MESSAGE(2, "could only partially fill"
+					"eddp buffer!\n");
 				goto out;
 			}
 		}
@@ -143,8 +143,6 @@ int qeth_eddp_fill_buffer(struct qeth_qd
 		if (must_refcnt) {
 			must_refcnt = 0;
 			if (qeth_eddp_buf_ref_context(buf, ctx)) {
-				PRINT_WARN("no memory to create eddp context "
-					   "reference\n");
 				goto out_check;
 			}
 		}
diff -urpN linux-2.6/drivers/s390/net/qeth_core_sys.c linux-2.6-patched/drivers/s390/net/qeth_core_sys.c
--- linux-2.6/drivers/s390/net/qeth_core_sys.c	2008-06-06 10:52:45.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_sys.c	2008-06-06 10:53:13.000000000 +0200
@@ -129,7 +129,6 @@ static ssize_t qeth_dev_portno_store(str
 
 	portno = simple_strtoul(buf, &tmp, 16);
 	if (portno > QETH_MAX_PORTNO) {
-		PRINT_WARN("portno 0x%X is out of range\n", portno);
 		return -EINVAL;
 	}
 
@@ -223,8 +222,6 @@ static ssize_t qeth_dev_prioqing_store(s
 	 * if though we have to permit priority queueing
 	 */
 	if (card->qdio.no_out_queues == 1) {
-		PRINT_WARN("Priority queueing disabled due "
-			   "to hardware limitations!\n");
 		card->qdio.do_prio_queueing = QETH_PRIOQ_DEFAULT;
 		return -EPERM;
 	}
@@ -250,7 +247,6 @@ static ssize_t qeth_dev_prioqing_store(s
 		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
 		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
 	} else {
-		PRINT_WARN("Unknown queueing type '%s'\n", tmp);
 		return -EINVAL;
 	}
 	return count;
@@ -291,9 +287,6 @@ static ssize_t qeth_dev_bufcnt_store(str
 		((cnt > QETH_IN_BUF_COUNT_MAX) ? QETH_IN_BUF_COUNT_MAX : cnt);
 	if (old_cnt != cnt) {
 		rc = qeth_realloc_buffer_pool(card, cnt);
-		if (rc)
-			PRINT_WARN("Error (%d) while setting "
-				   "buffer count.\n", rc);
 	}
 	return count;
 }
@@ -355,7 +348,6 @@ static ssize_t qeth_dev_performance_stat
 		card->perf_stats.initial_rx_packets = card->stats.rx_packets;
 		card->perf_stats.initial_tx_packets = card->stats.tx_packets;
 	} else {
-		PRINT_WARN("performance_stats: write 0 or 1 to this file!\n");
 		return -EINVAL;
 	}
 	return count;
@@ -399,7 +391,6 @@ static ssize_t qeth_dev_layer2_store(str
 		newdis = QETH_DISCIPLINE_LAYER2;
 		break;
 	default:
-		PRINT_WARN("layer2: write 0 or 1 to this file!\n");
 		return -EINVAL;
 	}
 
@@ -463,7 +454,6 @@ static ssize_t qeth_dev_large_send_store
 	} else if (!strcmp(tmp, "TSO")) {
 		type = QETH_LARGE_SEND_TSO;
 	} else {
-		PRINT_WARN("large_send: invalid mode %s!\n", tmp);
 		return -EINVAL;
 	}
 	if (card->options.large_send == type)
@@ -503,8 +493,6 @@ static ssize_t qeth_dev_blkt_store(struc
 	if (i <= max_value) {
 		*value = i;
 	} else {
-		PRINT_WARN("blkt total time: write values between"
-			   " 0 and %d to this file!\n", max_value);
 		return -EINVAL;
 	}
 	return count;
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2008-06-06 10:53:13.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2008-06-06 10:53:13.000000000 +0200
@@ -131,14 +131,14 @@ static int qeth_l2_send_setgroupmac_cb(s
 	mac = &cmd->data.setdelmac.mac[0];
 	/* MAC already registered, needed in couple/uncouple case */
 	if (cmd->hdr.return_code == 0x2005) {
-		PRINT_WARN("Group MAC %02x:%02x:%02x:%02x:%02x:%02x " \
+		QETH_DBF_MESSAGE(2, "Group MAC %02x:%02x:%02x:%02x:%02x:%02x "
 			  "already existing on %s \n",
 			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
 			  QETH_CARD_IFNAME(card));
 		cmd->hdr.return_code = 0;
 	}
 	if (cmd->hdr.return_code)
-		PRINT_ERR("Could not set group MAC " \
+		QETH_DBF_MESSAGE(2, "Could not set group MAC "
 			  "%02x:%02x:%02x:%02x:%02x:%02x on %s: %x\n",
 			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
 			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
@@ -163,7 +163,7 @@ static int qeth_l2_send_delgroupmac_cb(s
 	cmd = (struct qeth_ipa_cmd *) data;
 	mac = &cmd->data.setdelmac.mac[0];
 	if (cmd->hdr.return_code)
-		PRINT_ERR("Could not delete group MAC " \
+		QETH_DBF_MESSAGE(2, "Could not delete group MAC "
 			  "%02x:%02x:%02x:%02x:%02x:%02x on %s: %x\n",
 			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
 			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
@@ -183,10 +183,8 @@ static void qeth_l2_add_mc(struct qeth_c
 
 	mc = kmalloc(sizeof(struct qeth_mc_mac), GFP_ATOMIC);
 
-	if (!mc) {
-		PRINT_ERR("no mem vor mc mac address\n");
+	if (!mc)
 		return;
-	}
 
 	memcpy(mc->mc_addr, mac, OSA_ADDR_LEN);
 	mc->mc_addrlen = OSA_ADDR_LEN;
@@ -277,7 +275,7 @@ static int qeth_l2_send_setdelvlan_cb(st
 	QETH_DBF_TEXT(TRACE, 2, "L2sdvcb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		PRINT_ERR("Error in processing VLAN %i on %s: 0x%x. "
+		QETH_DBF_MESSAGE(2, "Error in processing VLAN %i on %s: 0x%x. "
 			  "Continuing\n", cmd->data.setdelvlan.vlan_id,
 			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
 		QETH_DBF_TEXT_(TRACE, 2, "L2VL%4x", cmd->hdr.command);
@@ -330,8 +328,6 @@ static void qeth_l2_vlan_rx_add_vid(stru
 		spin_lock_bh(&card->vlanlock);
 		list_add_tail(&id->list, &card->vid_list);
 		spin_unlock_bh(&card->vlanlock);
-	} else {
-		PRINT_ERR("no memory for vid\n");
 	}
 }
 
@@ -547,16 +543,15 @@ static int qeth_l2_request_initial_mac(s
 
 	rc = qeth_query_setadapterparms(card);
 	if (rc) {
-		PRINT_WARN("could not query adapter parameters on device %s: "
-			   "x%x\n", CARD_BUS_ID(card), rc);
+		QETH_DBF_MESSAGE(2, "could not query adapter parameters on "
+			"device %s: x%x\n", CARD_BUS_ID(card), rc);
 	}
 
 	if (card->info.guestlan) {
 		rc = qeth_setadpparms_change_macaddr(card);
 		if (rc) {
-			PRINT_WARN("couldn't get MAC address on "
-			   "device %s: x%x\n",
-			   CARD_BUS_ID(card), rc);
+			QETH_DBF_MESSAGE(2, "couldn't get MAC address on "
+				"device %s: x%x\n", CARD_BUS_ID(card), rc);
 			QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 			return rc;
 		}
@@ -582,8 +577,6 @@ static int qeth_l2_set_mac_address(struc
 	}
 
 	if (card->info.type == QETH_CARD_TYPE_OSN) {
-		PRINT_WARN("Setting MAC address on %s is not supported.\n",
-			   dev->name);
 		QETH_DBF_TEXT(TRACE, 3, "setmcOSN");
 		return -EOPNOTSUPP;
 	}
@@ -663,7 +656,7 @@ static int qeth_l2_hard_start_xmit(struc
 		ctx = qeth_eddp_create_context(card, new_skb, hdr,
 						skb->sk->sk_protocol);
 		if (ctx == NULL) {
-			PRINT_WARN("could not create eddp context\n");
+			QETH_DBF_MESSAGE(2, "could not create eddp context\n");
 			goto tx_drop;
 		}
 	} else {
@@ -1152,7 +1145,7 @@ static int qeth_osn_send_control_data(st
 			      (addr_t) iob, 0, 0);
 	spin_unlock_irqrestore(get_ccwdev_lock(card->write.ccwdev), flags);
 	if (rc) {
-		PRINT_WARN("qeth_osn_send_control_data: "
+		QETH_DBF_MESSAGE(2, "qeth_osn_send_control_data: "
 			   "ccw_device_start rc = %i\n", rc);
 		QETH_DBF_TEXT_(TRACE, 2, " err%d", rc);
 		qeth_release_buffer(iob->channel, iob);
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2008-06-06 10:53:12.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2008-06-06 10:53:13.000000000 +0200
@@ -311,7 +311,6 @@ static struct qeth_ipaddr *qeth_l3_get_a
 
 	addr = kzalloc(sizeof(struct qeth_ipaddr), GFP_ATOMIC);
 	if (addr == NULL) {
-		PRINT_WARN("Not enough memory to add address\n");
 		return NULL;
 	}
 	addr->type = QETH_IP_TYPE_NORMAL;
@@ -649,15 +648,6 @@ static void qeth_l3_correct_routing_type
 		}
 	}
 out_inval:
-	PRINT_WARN("Routing type '%s' not supported for interface %s.\n"
-		   "Router status set to 'no router'.\n",
-		   ((*type == PRIMARY_ROUTER)? "primary router" :
-		    (*type == SECONDARY_ROUTER)? "secondary router" :
-		    (*type == PRIMARY_CONNECTOR)? "primary connector" :
-		    (*type == SECONDARY_CONNECTOR)? "secondary connector" :
-		    (*type == MULTICAST_ROUTER)? "multicast router" :
-		    "unknown"),
-		   card->dev->name);
 	*type = NO_ROUTER;
 }
 
@@ -674,9 +664,9 @@ int qeth_l3_setrouting_v4(struct qeth_ca
 				  QETH_PROT_IPV4);
 	if (rc) {
 		card->options.route4.type = NO_ROUTER;
-		PRINT_WARN("Error (0x%04x) while setting routing type on %s. "
-			   "Type set to 'no router'.\n",
-			   rc, QETH_CARD_IFNAME(card));
+		QETH_DBF_MESSAGE(2, "Error (0x%04x) while setting routing type"
+			" on %s. Type set to 'no router'.\n", rc,
+			QETH_CARD_IFNAME(card));
 	}
 	return rc;
 }
@@ -697,9 +687,9 @@ int qeth_l3_setrouting_v6(struct qeth_ca
 				  QETH_PROT_IPV6);
 	if (rc) {
 		card->options.route6.type = NO_ROUTER;
-		PRINT_WARN("Error (0x%04x) while setting routing type on %s. "
-			   "Type set to 'no router'.\n",
-			   rc, QETH_CARD_IFNAME(card));
+		QETH_DBF_MESSAGE(2, "Error (0x%04x) while setting routing type"
+			" on %s. Type set to 'no router'.\n", rc,
+			QETH_CARD_IFNAME(card));
 	}
 #endif
 	return rc;
@@ -737,7 +727,6 @@ int qeth_l3_add_ipato_entry(struct qeth_
 		if (!memcmp(ipatoe->addr, new->addr,
 			    (ipatoe->proto == QETH_PROT_IPV4)? 4:16) &&
 		    (ipatoe->mask_bits == new->mask_bits)) {
-			PRINT_WARN("ipato entry already exists!\n");
 			rc = -EEXIST;
 			break;
 		}
@@ -802,7 +791,6 @@ int qeth_l3_add_vipa(struct qeth_card *c
 		rc = -EEXIST;
 	spin_unlock_irqrestore(&card->ip_lock, flags);
 	if (rc) {
-		PRINT_WARN("Cannot add VIPA. Address already exists!\n");
 		return rc;
 	}
 	if (!qeth_l3_add_ip(card, ipaddr))
@@ -867,7 +855,6 @@ int qeth_l3_add_rxip(struct qeth_card *c
 		rc = -EEXIST;
 	spin_unlock_irqrestore(&card->ip_lock, flags);
 	if (rc) {
-		PRINT_WARN("Cannot add RXIP. Address already exists!\n");
 		return rc;
 	}
 	if (!qeth_l3_add_ip(card, ipaddr))
@@ -1020,23 +1007,23 @@ static int qeth_l3_setadapter_hstr(struc
 					IPA_SETADP_SET_BROADCAST_MODE,
 					card->options.broadcast_mode);
 		if (rc)
-			PRINT_WARN("couldn't set broadcast mode on "
+			QETH_DBF_MESSAGE(2, "couldn't set broadcast mode on "
 				   "device %s: x%x\n",
 				   CARD_BUS_ID(card), rc);
 		rc = qeth_l3_send_setadp_mode(card,
 					IPA_SETADP_ALTER_MAC_ADDRESS,
 					card->options.macaddr_mode);
 		if (rc)
-			PRINT_WARN("couldn't set macaddr mode on "
+			QETH_DBF_MESSAGE(2, "couldn't set macaddr mode on "
 				   "device %s: x%x\n", CARD_BUS_ID(card), rc);
 		return rc;
 	}
 	if (card->options.broadcast_mode == QETH_TR_BROADCAST_LOCAL)
-		PRINT_WARN("set adapter parameters not available "
+		QETH_DBF_MESSAGE(2, "set adapter parameters not available "
 			   "to set broadcast mode, using ALLRINGS "
 			   "on device %s:\n", CARD_BUS_ID(card));
 	if (card->options.macaddr_mode == QETH_TR_MACADDR_CANONICAL)
-		PRINT_WARN("set adapter parameters not available "
+		QETH_DBF_MESSAGE(2, "set adapter parameters not available "
 			   "to set macaddr mode, using NONCANONICAL "
 			   "on device %s:\n", CARD_BUS_ID(card));
 	return 0;
@@ -2182,8 +2169,6 @@ static int qeth_l3_arp_set_no_entries(st
 	if (card->info.guestlan)
 		return -EOPNOTSUPP;
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
-		PRINT_WARN("ARP processing not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 	rc = qeth_l3_send_simple_setassparms(card, IPA_ARP_PROCESSING,
@@ -2191,8 +2176,8 @@ static int qeth_l3_arp_set_no_entries(st
 					  no_entries);
 	if (rc) {
 		tmp = rc;
-		PRINT_WARN("Could not set number of ARP entries on %s: "
-			"%s (0x%x/%d)\n", QETH_CARD_IFNAME(card),
+		QETH_DBF_MESSAGE(2, "Could not set number of ARP entries on "
+			"%s: %s (0x%x/%d)\n", QETH_CARD_IFNAME(card),
 			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 	}
 	return rc;
@@ -2260,9 +2245,6 @@ static int qeth_l3_arp_query_cb(struct q
 			qdata->no_entries * uentry_size){
 		QETH_DBF_TEXT_(TRACE, 4, "qaer3%i", -ENOMEM);
 		cmd->hdr.return_code = -ENOMEM;
-		PRINT_WARN("query ARP user space buffer is too small for "
-			   "the returned number of ARP entries. "
-			   "Aborting query!\n");
 		goto out_error;
 	}
 	QETH_DBF_TEXT_(TRACE, 4, "anore%i",
@@ -2324,8 +2306,6 @@ static int qeth_l3_arp_query(struct qeth
 
 	if (!qeth_is_supported(card,/*IPA_QUERY_ARP_ADDR_INFO*/
 			       IPA_ARP_PROCESSING)) {
-		PRINT_WARN("ARP processing not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 	/* get size of userspace buffer and mask_bits -> 6 bytes */
@@ -2344,7 +2324,7 @@ static int qeth_l3_arp_query(struct qeth
 				   qeth_l3_arp_query_cb, (void *)&qinfo);
 	if (rc) {
 		tmp = rc;
-		PRINT_WARN("Error while querying ARP cache on %s: %s "
+		QETH_DBF_MESSAGE(2, "Error while querying ARP cache on %s: %s "
 			"(0x%x/%d)\n", QETH_CARD_IFNAME(card),
 			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 		if (copy_to_user(udata, qinfo.udata, 4))
@@ -2375,8 +2355,6 @@ static int qeth_l3_arp_add_entry(struct 
 	if (card->info.guestlan)
 		return -EOPNOTSUPP;
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
-		PRINT_WARN("ARP processing not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 
@@ -2391,10 +2369,9 @@ static int qeth_l3_arp_add_entry(struct 
 	if (rc) {
 		tmp = rc;
 		qeth_l3_ipaddr4_to_string((u8 *)entry->ipaddr, buf);
-		PRINT_WARN("Could not add ARP entry for address %s on %s: "
-			   "%s (0x%x/%d)\n",
-			   buf, QETH_CARD_IFNAME(card),
-			   qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
+		QETH_DBF_MESSAGE(2, "Could not add ARP entry for address %s "
+			"on %s: %s (0x%x/%d)\n", buf, QETH_CARD_IFNAME(card),
+			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 	}
 	return rc;
 }
@@ -2417,8 +2394,6 @@ static int qeth_l3_arp_remove_entry(stru
 	if (card->info.guestlan)
 		return -EOPNOTSUPP;
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
-		PRINT_WARN("ARP processing not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 	memcpy(buf, entry, 12);
@@ -2433,10 +2408,9 @@ static int qeth_l3_arp_remove_entry(stru
 		tmp = rc;
 		memset(buf, 0, 16);
 		qeth_l3_ipaddr4_to_string((u8 *)entry->ipaddr, buf);
-		PRINT_WARN("Could not delete ARP entry for address %s on %s: "
-			   "%s (0x%x/%d)\n",
-			   buf, QETH_CARD_IFNAME(card),
-			   qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
+		QETH_DBF_MESSAGE(2, "Could not delete ARP entry for address %s"
+			" on %s: %s (0x%x/%d)\n", buf, QETH_CARD_IFNAME(card),
+			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 	}
 	return rc;
 }
@@ -2456,16 +2430,14 @@ static int qeth_l3_arp_flush_cache(struc
 	if (card->info.guestlan || (card->info.type == QETH_CARD_TYPE_IQD))
 		return -EOPNOTSUPP;
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
-		PRINT_WARN("ARP processing not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 	rc = qeth_l3_send_simple_setassparms(card, IPA_ARP_PROCESSING,
 					  IPA_CMD_ASS_ARP_FLUSH_CACHE, 0);
 	if (rc) {
 		tmp = rc;
-		PRINT_WARN("Could not flush ARP cache on %s: %s (0x%x/%d)\n",
-			QETH_CARD_IFNAME(card),
+		QETH_DBF_MESSAGE(2, "Could not flush ARP cache on %s: %s "
+			"(0x%x/%d)\n", QETH_CARD_IFNAME(card),
 			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 	}
 	return rc;
@@ -2724,7 +2696,7 @@ static int qeth_l3_hard_start_xmit(struc
 		ctx = qeth_eddp_create_context(card, new_skb, hdr,
 						skb->sk->sk_protocol);
 		if (ctx == NULL) {
-			PRINT_WARN("could not create eddp context\n");
+			QETH_DBF_MESSAGE(2, "could not create eddp context\n");
 			goto tx_drop;
 		}
 	} else {
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_sys.c linux-2.6-patched/drivers/s390/net/qeth_l3_sys.c
--- linux-2.6/drivers/s390/net/qeth_l3_sys.c	2008-06-06 10:52:45.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_sys.c	2008-06-06 10:53:13.000000000 +0200
@@ -85,7 +85,6 @@ static ssize_t qeth_l3_dev_route_store(s
 	} else if (!strcmp(tmp, "multicast_router")) {
 		route->type = MULTICAST_ROUTER;
 	} else {
-		PRINT_WARN("Invalid routing type '%s'.\n", tmp);
 		return -EINVAL;
 	}
 	if (((card->state == CARD_STATE_SOFTSETUP) ||
@@ -137,9 +136,6 @@ static ssize_t qeth_l3_dev_route6_store(
 		return -EINVAL;
 
 	if (!qeth_is_supported(card, IPA_IPV6)) {
-		PRINT_WARN("IPv6 not supported for interface %s.\n"
-			   "Routing status no changed.\n",
-			   QETH_CARD_IFNAME(card));
 		return -ENOTSUPP;
 	}
 
@@ -179,7 +175,6 @@ static ssize_t qeth_l3_dev_fake_broadcas
 	if ((i == 0) || (i == 1))
 		card->options.fake_broadcast = i;
 	else {
-		PRINT_WARN("fake_broadcast: write 0 or 1 to this file!\n");
 		return -EINVAL;
 	}
 	return count;
@@ -220,7 +215,6 @@ static ssize_t qeth_l3_dev_broadcast_mod
 
 	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
 	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR))) {
-		PRINT_WARN("Device is not a tokenring device!\n");
 		return -EINVAL;
 	}
 
@@ -233,8 +227,6 @@ static ssize_t qeth_l3_dev_broadcast_mod
 		card->options.broadcast_mode = QETH_TR_BROADCAST_ALLRINGS;
 		return count;
 	} else {
-		PRINT_WARN("broadcast_mode: invalid mode %s!\n",
-			   tmp);
 		return -EINVAL;
 	}
 	return count;
@@ -275,7 +267,6 @@ static ssize_t qeth_l3_dev_canonical_mac
 
 	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
 	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR))) {
-		PRINT_WARN("Device is not a tokenring device!\n");
 		return -EINVAL;
 	}
 
@@ -285,7 +276,6 @@ static ssize_t qeth_l3_dev_canonical_mac
 			QETH_TR_MACADDR_CANONICAL :
 			QETH_TR_MACADDR_NONCANONICAL;
 	else {
-		PRINT_WARN("canonical_macaddr: write 0 or 1 to this file!\n");
 		return -EINVAL;
 	}
 	return count;
@@ -327,7 +317,6 @@ static ssize_t qeth_l3_dev_checksum_stor
 	else if (!strcmp(tmp, "no_checksumming"))
 		card->options.checksum_type = NO_CHECKSUMMING;
 	else {
-		PRINT_WARN("Unknown checksumming type '%s'\n", tmp);
 		return -EINVAL;
 	}
 	return count;
@@ -382,8 +371,6 @@ static ssize_t qeth_l3_dev_ipato_enable_
 	} else if (!strcmp(tmp, "0")) {
 		card->ipato.enabled = 0;
 	} else {
-		PRINT_WARN("ipato_enable: write 0, 1 or 'toggle' to "
-			   "this file\n");
 		return -EINVAL;
 	}
 	return count;
@@ -422,8 +409,6 @@ static ssize_t qeth_l3_dev_ipato_invert4
 	} else if (!strcmp(tmp, "0")) {
 		card->ipato.invert4 = 0;
 	} else {
-		PRINT_WARN("ipato_invert4: write 0, 1 or 'toggle' to "
-			   "this file\n");
 		return -EINVAL;
 	}
 	return count;
@@ -486,13 +471,10 @@ static int qeth_l3_parse_ipatoe(const ch
 	/* get address string */
 	end = strchr(start, '/');
 	if (!end || (end - start >= 40)) {
-		PRINT_WARN("Invalid format for ipato_addx/delx. "
-			   "Use <ip addr>/<mask bits>\n");
 		return -EINVAL;
 	}
 	strncpy(buffer, start, end - start);
 	if (qeth_l3_string_to_ipaddr(buffer, proto, addr)) {
-		PRINT_WARN("Invalid IP address format!\n");
 		return -EINVAL;
 	}
 	start = end + 1;
@@ -500,7 +482,6 @@ static int qeth_l3_parse_ipatoe(const ch
 	if (!strlen(start) ||
 	    (tmp == start) ||
 	    (*mask_bits > ((proto == QETH_PROT_IPV4) ? 32 : 128))) {
-		PRINT_WARN("Invalid mask bits for ipato_addx/delx !\n");
 		return -EINVAL;
 	}
 	return 0;
@@ -520,7 +501,6 @@ static ssize_t qeth_l3_dev_ipato_add_sto
 
 	ipatoe = kzalloc(sizeof(struct qeth_ipato_entry), GFP_KERNEL);
 	if (!ipatoe) {
-		PRINT_WARN("No memory to allocate ipato entry\n");
 		return -ENOMEM;
 	}
 	ipatoe->proto = proto;
@@ -609,8 +589,6 @@ static ssize_t qeth_l3_dev_ipato_invert6
 	} else if (!strcmp(tmp, "0")) {
 		card->ipato.invert6 = 0;
 	} else {
-		PRINT_WARN("ipato_invert6: write 0, 1 or 'toggle' to "
-			   "this file\n");
 		return -EINVAL;
 	}
 	return count;
@@ -724,7 +702,6 @@ static int qeth_l3_parse_vipae(const cha
 		 u8 *addr)
 {
 	if (qeth_l3_string_to_ipaddr(buf, proto, addr)) {
-		PRINT_WARN("Invalid IP address format!\n");
 		return -EINVAL;
 	}
 	return 0;
@@ -891,7 +868,6 @@ static int qeth_l3_parse_rxipe(const cha
 		 u8 *addr)
 {
 	if (qeth_l3_string_to_ipaddr(buf, proto, addr)) {
-		PRINT_WARN("Invalid IP address format!\n");
 		return -EINVAL;
 	}
 	return 0;

-- 
