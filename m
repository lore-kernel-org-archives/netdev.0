From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 29/32] [TIPC] Enhanced & cleaned up system messages; fixed 2 obscure memory leaks.
Date: Thu, 22 Jun 2006 15:59:42 +0200
Message-ID: <11509847872930-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:42902 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1030662AbWFVN7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:53 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/bcast.c      |    2 +
 net/tipc/bcast.h      |    2 +
 net/tipc/bearer.c     |   70 +++++++++++++++++++++++++++----------------------
 net/tipc/cluster.c    |   22 +++++++++------
 net/tipc/config.c     |    2 +
 net/tipc/discover.c   |    7 +----
 net/tipc/link.c       |   39 +++++++++++++++------------
 net/tipc/name_distr.c |   10 ++++---
 net/tipc/name_table.c |    6 ++--
 net/tipc/node.c       |   68 +++++++++++++++++++++++++-----------------------
 net/tipc/port.c       |   10 ++++---
 net/tipc/subscr.c     |   18 ++++++-------
 net/tipc/zone.c       |   19 ++++++++-----
 13 files changed, 149 insertions(+), 126 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 44645f5..1633ef2 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -785,7 +785,7 @@ int tipc_bclink_init(void)
 	bclink = kmalloc(sizeof(*bclink), GFP_ATOMIC);
 	if (!bcbearer || !bclink) {
  nomem:
-	 	warn("Memory squeeze; Failed to create multicast link\n");
+	 	warn("Multicast link creation failed, no memory\n");
 		kfree(bcbearer);
 		bcbearer = NULL;
 		kfree(bclink);
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 0e3be2a..b243d9d 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -180,7 +180,7 @@ static inline void tipc_port_list_add(st
 		if (!item->next) {
 			item->next = kmalloc(sizeof(*item), GFP_ATOMIC);
 			if (!item->next) {
-				warn("Memory squeeze: multicast destination port list is incomplete\n");
+				warn("Incomplete multicast delivery, no memory\n");
 				return;
 			}
 			item->next->next = NULL;
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index e213a8e..4fa24b5 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -112,39 +112,42 @@ int  tipc_register_media(u32 media_type,
 		goto exit;
 
 	if (!media_name_valid(name)) {
-		warn("Media registration error: illegal name <%s>\n", name);
+		warn("Media <%s> rejected, illegal name\n", name);
 		goto exit;
 	}
 	if (!bcast_addr) {
-		warn("Media registration error: no broadcast address supplied\n");
+		warn("Media <%s> rejected, no broadcast address\n", name);
 		goto exit;
 	}
 	if ((bearer_priority < TIPC_MIN_LINK_PRI) &&
 	    (bearer_priority > TIPC_MAX_LINK_PRI)) {
-		warn("Media registration error: priority %u\n", bearer_priority);
+		warn("Media <%s> rejected, illegal priority (%u)\n", name, 
+		     bearer_priority);
 		goto exit;
 	}
 	if ((link_tolerance < TIPC_MIN_LINK_TOL) || 
 	    (link_tolerance > TIPC_MAX_LINK_TOL)) {
-		warn("Media registration error: tolerance %u\n", link_tolerance);
+		warn("Media <%s> rejected, illegal tolerance (%u)\n", name,
+		     link_tolerance);
 		goto exit;
 	}
 
 	media_id = media_count++;
 	if (media_id >= MAX_MEDIA) {
-		warn("Attempt to register more than %u media\n", MAX_MEDIA);
+		warn("Media <%s> rejected, media limit reached (%u)\n", name,
+		     MAX_MEDIA);
 		media_count--;
 		goto exit;
 	}
 	for (i = 0; i < media_id; i++) {
 		if (media_list[i].type_id == media_type) {
-			warn("Attempt to register second media with type %u\n", 
+			warn("Media <%s> rejected, duplicate type (%u)\n", name,
 			     media_type);
 			media_count--;
 			goto exit;
 		}
 		if (!strcmp(name, media_list[i].name)) {
-			warn("Attempt to re-register media name <%s>\n", name);
+			warn("Media <%s> rejected, duplicate name\n", name);
 			media_count--;
 			goto exit;
 		}
@@ -283,6 +286,9 @@ static struct bearer *bearer_find(const 
 	struct bearer *b_ptr;
 	u32 i;
 
+	if (tipc_mode != TIPC_NET_MODE)
+		return NULL;
+
 	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
 		if (b_ptr->active && (!strcmp(b_ptr->publ.name, name)))
 			return b_ptr;
@@ -475,26 +481,33 @@ int tipc_enable_bearer(const char *name,
 	u32 i;
 	int res = -EINVAL;
 
-	if (tipc_mode != TIPC_NET_MODE)
+	if (tipc_mode != TIPC_NET_MODE) {
+		warn("Bearer <%s> rejected, not supported in standalone mode\n",
+		     name);
 		return -ENOPROTOOPT;
-
-	if (!bearer_name_validate(name, &b_name) ||
-	    !tipc_addr_domain_valid(bcast_scope) ||
-	    !in_scope(bcast_scope, tipc_own_addr))
+	}
+	if (!bearer_name_validate(name, &b_name)) {
+		warn("Bearer <%s> rejected, illegal name\n", name);
 		return -EINVAL;
-
+	}
+	if (!tipc_addr_domain_valid(bcast_scope) || 
+	    !in_scope(bcast_scope, tipc_own_addr)) {
+		warn("Bearer <%s> rejected, illegal broadcast scope\n", name);
+		return -EINVAL;
+	}
 	if ((priority < TIPC_MIN_LINK_PRI ||
 	     priority > TIPC_MAX_LINK_PRI) &&
-	    (priority != TIPC_MEDIA_LINK_PRI))
+	    (priority != TIPC_MEDIA_LINK_PRI)) {
+		warn("Bearer <%s> rejected, illegal priority\n", name);
 		return -EINVAL;
+	}
 
 	write_lock_bh(&tipc_net_lock);
-	if (!tipc_bearers)
-		goto failed;
 
 	m_ptr = media_find(b_name.media_name);
 	if (!m_ptr) {
-		warn("No media <%s>\n", b_name.media_name);
+		warn("Bearer <%s> rejected, media <%s> not registered\n", name,
+		     b_name.media_name);
 		goto failed;
 	}
 
@@ -510,23 +523,24 @@ restart:
 			continue;
 		}
 		if (!strcmp(name, tipc_bearers[i].publ.name)) {
-			warn("Bearer <%s> already enabled\n", name);
+			warn("Bearer <%s> rejected, already enabled\n", name);
 			goto failed;
 		}
 		if ((tipc_bearers[i].priority == priority) &&
 		    (++with_this_prio > 2)) {
 			if (priority-- == 0) {
-				warn("Third bearer <%s> with priority %u, unable to lower to %u\n",
-				     name, priority + 1, priority);
+				warn("Bearer <%s> rejected, duplicate priority\n",
+				     name);
 				goto failed;
 			}
-			warn("Third bearer <%s> with priority %u, lowering to %u\n",
+			warn("Bearer <%s> priority adjustment required %u->%u\n",
 			     name, priority + 1, priority);
 			goto restart;
 		}
 	}
 	if (bearer_id >= MAX_BEARERS) {
-		warn("Attempt to enable more than %d bearers\n", MAX_BEARERS);
+		warn("Bearer <%s> rejected, bearer limit reached (%u)\n", 
+		     name, MAX_BEARERS);
 		goto failed;
 	}
 
@@ -536,7 +550,7 @@ restart:
 	strcpy(b_ptr->publ.name, name);
 	res = m_ptr->enable_bearer(&b_ptr->publ);
 	if (res) {
-		warn("Failed to enable bearer <%s>\n", name);
+		warn("Bearer <%s> rejected, enable failure (%d)\n", name, -res);
 		goto failed;
 	}
 
@@ -573,9 +587,6 @@ int tipc_block_bearer(const char *name)
 	struct link *l_ptr;
 	struct link *temp_l_ptr;
 
-	if (tipc_mode != TIPC_NET_MODE)
-		return -ENOPROTOOPT;
-
 	read_lock_bh(&tipc_net_lock);
 	b_ptr = bearer_find(name);
 	if (!b_ptr) {
@@ -584,6 +595,7 @@ int tipc_block_bearer(const char *name)
 		return -EINVAL;
 	}
 
+	info("Blocking bearer <%s>\n", name);
 	spin_lock_bh(&b_ptr->publ.lock);
 	b_ptr->publ.blocked = 1;
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
@@ -595,7 +607,6 @@ int tipc_block_bearer(const char *name)
 	}
 	spin_unlock_bh(&b_ptr->publ.lock);
 	read_unlock_bh(&tipc_net_lock);
-	info("Blocked bearer <%s>\n", name);
 	return TIPC_OK;
 }
 
@@ -611,15 +622,13 @@ static int bearer_disable(const char *na
 	struct link *l_ptr;
 	struct link *temp_l_ptr;
 
-	if (tipc_mode != TIPC_NET_MODE)
-		return -ENOPROTOOPT;
-
 	b_ptr = bearer_find(name);
 	if (!b_ptr) {
 		warn("Attempt to disable unknown bearer <%s>\n", name);
 		return -EINVAL;
 	}
 
+	info("Disabling bearer <%s>\n", name);
 	tipc_disc_stop_link_req(b_ptr->link_req);
 	spin_lock_bh(&b_ptr->publ.lock);
 	b_ptr->link_req = NULL;
@@ -635,7 +644,6 @@ static int bearer_disable(const char *na
 		tipc_link_delete(l_ptr);
 	}
 	spin_unlock_bh(&b_ptr->publ.lock);
-	info("Disabled bearer <%s>\n", name);
 	memset(b_ptr, 0, sizeof(struct bearer));
 	return TIPC_OK;
 }
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index 1aed815..1dcb694 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -60,8 +60,10 @@ struct cluster *tipc_cltr_create(u32 add
 	int alloc;
 
 	c_ptr = (struct cluster *)kmalloc(sizeof(*c_ptr), GFP_ATOMIC);
-	if (c_ptr == NULL)
+	if (c_ptr == NULL) {
+		warn("Cluster creation failure, no memory\n");
 		return NULL;
+	}
 	memset(c_ptr, 0, sizeof(*c_ptr));
 
 	c_ptr->addr = tipc_addr(tipc_zone(addr), tipc_cluster(addr), 0);
@@ -70,30 +72,32 @@ struct cluster *tipc_cltr_create(u32 add
 	else
 		max_nodes = tipc_max_nodes + 1;
 	alloc = sizeof(void *) * (max_nodes + 1);
+
 	c_ptr->nodes = (struct node **)kmalloc(alloc, GFP_ATOMIC);
 	if (c_ptr->nodes == NULL) {
+		warn("Cluster creation failure, no memory for node area\n");
 		kfree(c_ptr);
 		return NULL;
 	}
-	memset(c_ptr->nodes, 0, alloc);  
+	memset(c_ptr->nodes, 0, alloc);
+
 	if (in_own_cluster(addr))
 		tipc_local_nodes = c_ptr->nodes;
 	c_ptr->highest_slave = LOWEST_SLAVE - 1;
 	c_ptr->highest_node = 0;
 	
 	z_ptr = tipc_zone_find(tipc_zone(addr));
-	if (z_ptr == NULL) {
+	if (!z_ptr) {
 		z_ptr = tipc_zone_create(addr);
 	}
-	if (z_ptr != NULL) {
-		tipc_zone_attach_cluster(z_ptr, c_ptr);
-		c_ptr->owner = z_ptr;
-	}
-	else {
+	if (!z_ptr) {
+		kfree(c_ptr->nodes);
 		kfree(c_ptr);
-		c_ptr = NULL;
+		return NULL;
 	}
 
+	tipc_zone_attach_cluster(z_ptr, c_ptr);
+	c_ptr->owner = z_ptr;
 	return c_ptr;
 }
 
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 41c8447..3ec502f 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -642,7 +642,7 @@ static void cfg_named_msg_event(void *us
 	if ((size < sizeof(*req_hdr)) ||
 	    (size != TCM_ALIGN(ntohl(req_hdr->tcm_len))) ||
 	    (ntohs(req_hdr->tcm_flags) != TCM_F_REQUEST)) {
-		warn("discarded invalid configuration message\n");
+		warn("Invalid configuration message discarded\n");
 		return;
 	}
 
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 9260138..ee9b448 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -176,7 +176,6 @@ void tipc_disc_recv_msg(struct sk_buff *
 			n_ptr = tipc_node_create(orig);
 		}
 		if (n_ptr == NULL) {
-			warn("Memory squeeze; Failed to create node\n");
 			return;
 		}
 		spin_lock_bh(&n_ptr->lock);
@@ -191,10 +190,8 @@ void tipc_disc_recv_msg(struct sk_buff *
 		}
 		addr = &link->media_addr;
 		if (memcmp(addr, &media_addr, sizeof(*addr))) {
-			char addr_string[16];
-
-			warn("New bearer address for %s\n", 
-			     addr_string_fill(addr_string, orig));
+			warn("Resetting link <%s>, peer interface address changed\n",
+			     link->name);
 			memcpy(addr, &media_addr, sizeof(*addr));
 			tipc_link_reset(link);     
 		}
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2efced5..d7668b8 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -419,7 +419,7 @@ struct link *tipc_link_create(struct bea
 
 	l_ptr = (struct link *)kmalloc(sizeof(*l_ptr), GFP_ATOMIC);
 	if (!l_ptr) {
-		warn("Memory squeeze; Failed to create link\n");
+		warn("Link creation failed, no memory\n");
 		return NULL;
 	}
 	memset(l_ptr, 0, sizeof(*l_ptr));
@@ -469,7 +469,7 @@ struct link *tipc_link_create(struct bea
 
 		if (!pb) {
 			kfree(l_ptr);
-			warn("Memory squeeze; Failed to create link\n");
+			warn("Link creation failed, no memory for print buffer\n");
 			return NULL;
 		}
 		tipc_printbuf_init(&l_ptr->print_buf, pb, LINK_LOG_BUF_SIZE);
@@ -819,6 +819,8 @@ static void link_state_event(struct link
 			break;
 		case RESET_MSG:
 			dbg_link("RES -> RR\n");
+			info("Resetting link <%s>, requested by peer\n", 
+			     l_ptr->name);
 			tipc_link_reset(l_ptr);
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
@@ -843,6 +845,8 @@ static void link_state_event(struct link
 			break;
 		case RESET_MSG:
 			dbg_link("RES -> RR\n");
+			info("Resetting link <%s>, requested by peer "
+			     "while probing\n", l_ptr->name);
 			tipc_link_reset(l_ptr);
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
@@ -874,6 +878,8 @@ static void link_state_event(struct link
 			} else {	/* Link has failed */
 				dbg_link("-> RU (%u probes unanswered)\n",
 					 l_ptr->fsm_msg_cnt);
+				warn("Resetting link <%s>, peer not responding\n",
+				     l_ptr->name);
 				tipc_link_reset(l_ptr);
 				l_ptr->state = RESET_UNKNOWN;
 				l_ptr->fsm_msg_cnt = 0;
@@ -1049,7 +1055,7 @@ int tipc_link_send_buf(struct link *l_pt
 		msg_dbg(msg, "TIPC: Congestion, throwing away\n");
 		buf_discard(buf);
 		if (imp > CONN_MANAGER) {
-			warn("Resetting <%s>, send queue full", l_ptr->name);
+			warn("Resetting link <%s>, send queue full", l_ptr->name);
 			tipc_link_reset(l_ptr);
 		}
 		return dsz;
@@ -2228,7 +2234,7 @@ static void link_recv_proto_msg(struct l
 		
 		if (msg_linkprio(msg) && 
 		    (msg_linkprio(msg) != l_ptr->priority)) {
-			warn("Changing prio <%s>: %u->%u\n",
+			warn("Resetting link <%s>, priority change %u->%u\n",
 			     l_ptr->name, l_ptr->priority, msg_linkprio(msg));
 			l_ptr->priority = msg_linkprio(msg);
 			tipc_link_reset(l_ptr); /* Enforce change to take effect */
@@ -2348,7 +2354,8 @@ void tipc_link_changeover(struct link *l
 			msg_dbg(&tunnel_hdr, "EMPTY>SEND>");
 			tipc_link_send_buf(tunnel, buf);
 		} else {
-			warn("Memory squeeze; link changeover failed\n");
+			warn("Link changeover error, "
+			     "unable to send changeover msg\n");
 		}
 		return;
 	}
@@ -2398,7 +2405,8 @@ void tipc_link_send_duplicate(struct lin
 		msg_set_size(&tunnel_hdr, length + INT_H_SIZE);
 		outbuf = buf_acquire(length + INT_H_SIZE);
 		if (outbuf == NULL) {
-			warn("Memory squeeze; buffer duplication failed\n");
+			warn("Link changeover error, "
+			     "unable to send duplicate msg\n");
 			return;
 		}
 		memcpy(outbuf->data, (unchar *)&tunnel_hdr, INT_H_SIZE);
@@ -2473,7 +2481,7 @@ static int link_recv_changeover_msg(stru
 		}
 		*buf = buf_extract(tunnel_buf,INT_H_SIZE);
 		if (*buf == NULL) {
-			warn("Memory squeeze; failed to extract msg\n");
+			warn("Link changeover error, duplicate msg dropped\n");
 			goto exit;
 		}
 		msg_dbg(tunnel_msg, "TNL<REC<");
@@ -2485,6 +2493,8 @@ static int link_recv_changeover_msg(stru
 
 	if (tipc_link_is_up(dest_link)) {
 		msg_dbg(tunnel_msg, "UP/FIRST/<REC<");
+		info("Resetting link <%s>, changeover initiated by peer\n",
+		     dest_link->name);
 		tipc_link_reset(dest_link);
 		dest_link->exp_msg_count = msg_count;
 		if (!msg_count)
@@ -2514,7 +2524,7 @@ static int link_recv_changeover_msg(stru
 			buf_discard(tunnel_buf);
 			return 1;
 		} else {
-			warn("Memory squeeze; dropped incoming msg\n");
+			warn("Link changeover error, original msg dropped\n");
 		}
 	}
 exit:
@@ -2536,13 +2546,8 @@ void tipc_link_recv_bundle(struct sk_buf
 	while (msgcount--) {
 		obuf = buf_extract(buf, pos);
 		if (obuf == NULL) {
-			char addr_string[16];
-
-			warn("Buffer allocation failure;\n");
-			warn("  incoming message(s) from %s lost\n",
-			     addr_string_fill(addr_string, 
-					      msg_orignode(buf_msg(buf))));
-			return;
+			warn("Link unable to unbundle message(s)\n");
+			break;
 		};
 		pos += align(msg_size(buf_msg(obuf)));
 		msg_dbg(buf_msg(obuf), "     /");
@@ -2600,7 +2605,7 @@ int tipc_link_send_long_buf(struct link 
 		}
 		fragm = buf_acquire(fragm_sz + INT_H_SIZE);
 		if (fragm == NULL) {
-			warn("Memory squeeze; failed to fragment msg\n");
+			warn("Link unable to fragment message\n");
 			dsz = -ENOMEM;
 			goto exit;
 		}
@@ -2715,7 +2720,7 @@ int tipc_link_recv_fragment(struct sk_bu
 			set_fragm_size(pbuf,fragm_sz); 
 			set_expected_frags(pbuf,exp_fragm_cnt - 1); 
 		} else {
-			warn("Memory squeeze; got no defragmenting buffer\n");
+			warn("Link unable to reassemble fragmented message\n");
 		}
 		buf_discard(fbuf);
 		return 0;
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 5718ecb..f0b063b 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -127,7 +127,7 @@ void tipc_named_publish(struct publicati
 
 	buf = named_prepare_buf(PUBLICATION, ITEM_SIZE, 0);
 	if (!buf) {
-		warn("Memory squeeze; failed to distribute publication\n");
+		warn("Publication distribution failure\n");
 		return;
 	}
 
@@ -151,7 +151,7 @@ void tipc_named_withdraw(struct publicat
 
 	buf = named_prepare_buf(WITHDRAWAL, ITEM_SIZE, 0);
 	if (!buf) {
-		warn("Memory squeeze; failed to distribute withdrawal\n");
+		warn("Withdrawl distribution failure\n");
 		return;
 	}
 
@@ -184,8 +184,8 @@ void tipc_named_node_up(unsigned long no
 			left = (rest <= max_item_buf) ? rest : max_item_buf;
 			rest -= left;
 			buf = named_prepare_buf(PUBLICATION, left, node);       
-			if (buf == NULL) {
-				warn("Memory Squeeze; could not send publication\n");
+			if (!buf) {
+				warn("Bulk publication distribution failure\n");
 				goto exit;
 			}
 			item = (struct distr_item *)msg_data(buf_msg(buf));
@@ -291,7 +291,7 @@ void tipc_named_recv(struct sk_buff *buf
 				    ntohl(item->ref), ntohl(item->key));
 			}
 		} else {
-			warn("tipc_named_recv: unknown msg\n");
+			warn("Unrecognized name table message received\n");
 		}
 		item++;
 	}
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index e90dc80..3857130 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -120,7 +120,7 @@ static struct publication *publ_create(u
 	struct publication *publ =
 		(struct publication *)kmalloc(sizeof(*publ), GFP_ATOMIC);
 	if (publ == NULL) {
-		warn("Memory squeeze; failed to create publication\n");
+		warn("Publication creation failure, no memory\n");
 		return NULL;
 	}
 
@@ -165,7 +165,7 @@ static struct name_seq *tipc_nameseq_cre
 	struct sub_seq *sseq = tipc_subseq_alloc(1);
 
 	if (!nseq || !sseq) {
-		warn("Memory squeeze; failed to create name sequence\n");
+		warn("Name sequence creation failed, no memory\n");
 		kfree(nseq);
 		kfree(sseq);
 		return NULL;
@@ -759,7 +759,7 @@ struct publication *tipc_nametbl_publish
 	struct publication *publ;
 
 	if (table.local_publ_count >= tipc_max_publications) {
-		warn("Failed publish: max %u local publication\n", 
+		warn("Publication failed, local publication limit reached (%u)\n", 
 		     tipc_max_publications);
 		return NULL;
 	}
diff --git a/net/tipc/node.c b/net/tipc/node.c
index b54462b..5f09754 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -61,34 +61,37 @@ struct node *tipc_node_create(u32 addr)
         struct node **curr_node;
 
 	n_ptr = kmalloc(sizeof(*n_ptr),GFP_ATOMIC);
-        if (n_ptr != NULL) {
-                memset(n_ptr, 0, sizeof(*n_ptr));
-                n_ptr->addr = addr;
-                n_ptr->lock =  SPIN_LOCK_UNLOCKED;	
-                INIT_LIST_HEAD(&n_ptr->nsub);
-	
-		c_ptr = tipc_cltr_find(addr);
-                if (c_ptr == NULL)
-                        c_ptr = tipc_cltr_create(addr);
-                if (c_ptr != NULL) {
-                        n_ptr->owner = c_ptr;
-                        tipc_cltr_attach_node(c_ptr, n_ptr);
-                        n_ptr->last_router = -1;
-
-                        /* Insert node into ordered list */
-                        for (curr_node = &tipc_nodes; *curr_node; 
-			     curr_node = &(*curr_node)->next) {
-                                if (addr < (*curr_node)->addr) {
-                                        n_ptr->next = *curr_node;
-                                        break;
-                                }
-                        }
-                        (*curr_node) = n_ptr;
-                } else {
-                        kfree(n_ptr);
-                        n_ptr = NULL;
-                }
-        }
+	if (!n_ptr) {
+		warn("Node creation failed, no memory\n");
+		return NULL;
+	}
+
+	c_ptr = tipc_cltr_find(addr);
+	if (!c_ptr) {
+		c_ptr = tipc_cltr_create(addr);
+	}
+	if (!c_ptr) {
+		kfree(n_ptr);
+		return NULL;
+	}
+		
+	memset(n_ptr, 0, sizeof(*n_ptr));
+	n_ptr->addr = addr;
+	n_ptr->lock =  SPIN_LOCK_UNLOCKED;	
+	INIT_LIST_HEAD(&n_ptr->nsub);
+	n_ptr->owner = c_ptr;
+	tipc_cltr_attach_node(c_ptr, n_ptr);
+	n_ptr->last_router = -1;
+
+	/* Insert node into ordered list */
+	for (curr_node = &tipc_nodes; *curr_node; 
+	     curr_node = &(*curr_node)->next) {
+		if (addr < (*curr_node)->addr) {
+			n_ptr->next = *curr_node;
+			break;
+		}
+	}
+	(*curr_node) = n_ptr;
 	return n_ptr;
 }
 
@@ -132,7 +135,7 @@ void tipc_node_link_up(struct node *n_pt
 		return;
 	}
 	if (l_ptr->priority < active[0]->priority) { 
-		info("Link is standby\n");
+		info("New link <%s> becomes standby\n", l_ptr->name);
 		return;
 	}
 	tipc_link_send_duplicate(active[0], l_ptr);
@@ -140,8 +143,9 @@ void tipc_node_link_up(struct node *n_pt
 		active[0] = l_ptr;
 		return;
 	}
-	info("Link <%s> on network plane %c becomes standby\n",
-	     active[0]->name, active[0]->b_ptr->net_plane);
+	info("Old link <%s> becomes standby\n", active[0]->name);
+	if (active[1] != active[0])
+		info("Old link <%s> becomes standby\n", active[1]->name);
 	active[0] = active[1] = l_ptr;
 }
 
@@ -248,7 +252,7 @@ struct node *tipc_node_attach_link(struc
                         n_ptr->link_cnt++;
                         return n_ptr;
                 }
-                err("Attempt to establish second link on <%s> to <%s> \n",
+                err("Attempt to establish second link on <%s> to %s \n",
                     l_ptr->b_ptr->publ.name, 
 		    addr_string_fill(addr_string, l_ptr->addr));
         }
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 3aab67a..47d9740 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -195,7 +195,7 @@ void tipc_port_recv_mcast(struct sk_buff
 			struct sk_buff *b = skb_clone(buf, GFP_ATOMIC);
 
 			if (b == NULL) {
-				warn("Buffer allocation failure\n");
+				warn("Unable to deliver multicast message(s)\n");
 				msg_dbg(msg, "LOST:");
 				goto exit;
 			}
@@ -227,14 +227,14 @@ u32 tipc_createport_raw(void *usr_handle
 	u32 ref;
 
 	p_ptr = kmalloc(sizeof(*p_ptr), GFP_ATOMIC);
-	if (p_ptr == NULL) {
-		warn("Memory squeeze; failed to create port\n");
+	if (!p_ptr) {
+		warn("Port creation failed, no memory\n");
 		return 0;
 	}
 	memset(p_ptr, 0, sizeof(*p_ptr));
 	ref = tipc_ref_acquire(p_ptr, &p_ptr->publ.lock);
 	if (!ref) {
-		warn("Reference Table Exhausted\n");
+		warn("Port creation failed, reference table exhausted\n");
 		kfree(p_ptr);
 		return 0;
 	}
@@ -1059,7 +1059,7 @@ int tipc_createport(u32 user_ref, 
 	u32 ref;
 
 	up_ptr = (struct user_port *)kmalloc(sizeof(*up_ptr), GFP_ATOMIC);
-	if (up_ptr == NULL) {
+	if (!up_ptr) {
 		warn("Port creation failed, no memory\n");
 		return -ENOMEM;
 	}
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index c5f026c..fc17187 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -266,7 +266,8 @@ static void subscr_subscribe(struct tipc
 	/* Refuse subscription if global limit exceeded */
 
 	if (atomic_read(&topsrv.subscription_count) >= tipc_max_subscriptions) {
-		warn("Failed: max %u subscriptions\n", tipc_max_subscriptions);
+		warn("Subscription rejected, subscription limit reached (%u)\n",
+		     tipc_max_subscriptions);
 		subscr_terminate(subscriber);
 		return;
 	}
@@ -274,8 +275,8 @@ static void subscr_subscribe(struct tipc
 	/* Allocate subscription object */
 
 	sub = kmalloc(sizeof(*sub), GFP_ATOMIC);
-	if (sub == NULL) {
-		warn("Memory squeeze; ignoring subscription\n");
+	if (!sub) {
+		warn("Subscription rejected, no memory\n");
 		subscr_terminate(subscriber);
 		return;
 	}
@@ -298,8 +299,7 @@ static void subscr_subscribe(struct tipc
 	if ((((sub->filter != TIPC_SUB_PORTS) 
 	      && (sub->filter != TIPC_SUB_SERVICE)))
 	    || (sub->seq.lower > sub->seq.upper)) {
-		warn("Rejecting illegal subscription %u,%u,%u\n",
-		     sub->seq.type, sub->seq.lower, sub->seq.upper);
+		warn("Subscription rejected, illegal request\n");
 		kfree(sub);
 		subscr_terminate(subscriber);
 		return;
@@ -387,7 +387,7 @@ static void subscr_named_msg_event(void 
 	dbg("subscr_named_msg_event: orig = %x own = %x,\n",
 	    orig->node, tipc_own_addr);
 	if (size && (size != sizeof(struct tipc_subscr))) {
-		warn("Received tipc_subscr of invalid size\n");
+		warn("Subscriber rejected, invalid subscription size\n");
 		return;
 	}
 
@@ -395,7 +395,7 @@ static void subscr_named_msg_event(void 
 
 	subscriber = kmalloc(sizeof(struct subscriber), GFP_ATOMIC);
 	if (subscriber == NULL) {
-		warn("Memory squeeze; ignoring subscriber setup\n");
+		warn("Subscriber rejected, no memory\n");
 		return;
 	}
 	memset(subscriber, 0, sizeof(struct subscriber));
@@ -403,7 +403,7 @@ static void subscr_named_msg_event(void 
 	INIT_LIST_HEAD(&subscriber->subscriber_list);
 	subscriber->ref = tipc_ref_acquire(subscriber, &subscriber->lock);
 	if (subscriber->ref == 0) {
-		warn("Failed to acquire subscriber reference\n");
+		warn("Subscriber rejected, reference table exhausted\n");
 		kfree(subscriber);
 		return;
 	}
@@ -422,7 +422,7 @@ static void subscr_named_msg_event(void 
 			NULL,
 			&subscriber->port_ref);
 	if (subscriber->port_ref == 0) {
-		warn("Memory squeeze; failed to create subscription port\n");
+		warn("Subscriber rejected, unable to create port\n");
 		tipc_ref_discard(subscriber->ref);
 		kfree(subscriber);
 		return;
diff --git a/net/tipc/zone.c b/net/tipc/zone.c
index 2803e1b..316c487 100644
--- a/net/tipc/zone.c
+++ b/net/tipc/zone.c
@@ -44,19 +44,24 @@ #include "node.h"
 
 struct _zone *tipc_zone_create(u32 addr)
 {
-	struct _zone *z_ptr = NULL;
+	struct _zone *z_ptr;
 	u32 z_num;
 
-	if (!tipc_addr_domain_valid(addr))
+	if (!tipc_addr_domain_valid(addr)) {
+		err("Zone creation failed, invalid domain 0x%x\n", addr);
 		return NULL;
+	}
 
 	z_ptr = (struct _zone *)kmalloc(sizeof(*z_ptr), GFP_ATOMIC);
-	if (z_ptr != NULL) {
-		memset(z_ptr, 0, sizeof(*z_ptr));
-		z_num = tipc_zone(addr);
-		z_ptr->addr = tipc_addr(z_num, 0, 0);
-		tipc_net.zones[z_num] = z_ptr;
+	if (!z_ptr) {
+		warn("Zone creation failed, insufficient memory\n");
+		return NULL;
 	}
+
+	memset(z_ptr, 0, sizeof(*z_ptr));
+	z_num = tipc_zone(addr);
+	z_ptr->addr = tipc_addr(z_num, 0, 0);
+	tipc_net.zones[z_num] = z_ptr;
 	return z_ptr;
 }
 
-- 
1.4.0

