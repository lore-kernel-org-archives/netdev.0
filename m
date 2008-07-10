From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 4/7 net-next-2.6] tipc: Eliminate improper use of TIPC_OK error code
Date: Thu, 10 Jul 2008 17:26:08 -0400
Message-ID: <1215725171-10094-5-git-send-email-allan.stephens@windriver.com>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33118 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753570AbYGJVZK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:25:10 -0400
In-Reply-To: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch corrects many places where TIPC routines indicated
successful completion by returning TIPC_OK instead of 0.
(The TIPC_OK symbol has the value 0, but it should only be used
in contexts that deal with the error code field of a TIPC
message header.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/bcast.c     |   10 +++++-----
 net/tipc/bearer.c    |    8 ++++----
 net/tipc/cluster.c   |    2 +-
 net/tipc/eth_media.c |    6 +++---
 net/tipc/link.c      |   18 +++++++++---------
 net/tipc/net.c       |    4 ++--
 net/tipc/port.c      |   34 +++++++++++++++++-----------------
 net/tipc/ref.c       |    2 +-
 net/tipc/user_reg.c  |   14 +++++++-------
 9 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index a5883b1..b1ff16a 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -611,7 +611,7 @@ swap:
 		bcbearer->bpairs[bp_index].secondary = p;
 update:
 		if (bcbearer->remains_new.count == 0)
-			return TIPC_OK;
+			return 0;
 
 		bcbearer->remains = bcbearer->remains_new;
 	}
@@ -620,7 +620,7 @@ update:
 
 	bcbearer->bearer.publ.blocked = 1;
 	bcl->stats.bearer_congs++;
-	return ~TIPC_OK;
+	return 1;
 }
 
 /**
@@ -756,7 +756,7 @@ int tipc_bclink_reset_stats(void)
 	spin_lock_bh(&bc_lock);
 	memset(&bcl->stats, 0, sizeof(bcl->stats));
 	spin_unlock_bh(&bc_lock);
-	return TIPC_OK;
+	return 0;
 }
 
 int tipc_bclink_set_queue_limits(u32 limit)
@@ -769,7 +769,7 @@ int tipc_bclink_set_queue_limits(u32 limit)
 	spin_lock_bh(&bc_lock);
 	tipc_link_set_queue_limits(bcl, limit);
 	spin_unlock_bh(&bc_lock);
-	return TIPC_OK;
+	return 0;
 }
 
 int tipc_bclink_init(void)
@@ -810,7 +810,7 @@ int tipc_bclink_init(void)
 		tipc_printbuf_init(&bcl->print_buf, pb, BCLINK_LOG_BUF_SIZE);
 	}
 
-	return TIPC_OK;
+	return 0;
 }
 
 void tipc_bclink_stop(void)
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 271a375..6a9aba3 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -370,7 +370,7 @@ void tipc_bearer_remove_dest(struct bearer *b_ptr, u32 dest)
  */
 static int bearer_push(struct bearer *b_ptr)
 {
-	u32 res = TIPC_OK;
+	u32 res = 0;
 	struct link *ln, *tln;
 
 	if (b_ptr->publ.blocked)
@@ -607,7 +607,7 @@ int tipc_block_bearer(const char *name)
 	}
 	spin_unlock_bh(&b_ptr->publ.lock);
 	read_unlock_bh(&tipc_net_lock);
-	return TIPC_OK;
+	return 0;
 }
 
 /**
@@ -645,7 +645,7 @@ static int bearer_disable(const char *name)
 	}
 	spin_unlock_bh(&b_ptr->publ.lock);
 	memset(b_ptr, 0, sizeof(struct bearer));
-	return TIPC_OK;
+	return 0;
 }
 
 int tipc_disable_bearer(const char *name)
@@ -668,7 +668,7 @@ int tipc_bearer_init(void)
 	tipc_bearers = kcalloc(MAX_BEARERS, sizeof(struct bearer), GFP_ATOMIC);
 	media_list = kcalloc(MAX_MEDIA, sizeof(struct media), GFP_ATOMIC);
 	if (tipc_bearers && media_list) {
-		res = TIPC_OK;
+		res = 0;
 	} else {
 		kfree(tipc_bearers);
 		kfree(media_list);
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index bc1db47..46ee6c5 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -571,6 +571,6 @@ exit:
 int tipc_cltr_init(void)
 {
 	tipc_highest_allowed_slave = LOWEST_SLAVE + tipc_max_slaves;
-	return tipc_cltr_create(tipc_own_addr) ? TIPC_OK : -ENOMEM;
+	return tipc_cltr_create(tipc_own_addr) ? 0 : -ENOMEM;
 }
 
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 9cd35ee..bc72fbc 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -82,7 +82,7 @@ static int send_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr,
 				 dev->dev_addr, clone->len);
 		dev_queue_xmit(clone);
 	}
-	return TIPC_OK;
+	return 0;
 }
 
 /**
@@ -113,12 +113,12 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 			if (likely(buf->len == size)) {
 				buf->next = NULL;
 				tipc_recv_msg(buf, eb_ptr->bearer);
-				return TIPC_OK;
+				return 0;
 			}
 		}
 	}
 	kfree_skb(buf);
-	return TIPC_OK;
+	return 0;
 }
 
 /**
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 9784a8e..d60113b 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1561,7 +1561,7 @@ u32 tipc_link_push_packet(struct link *l_ptr)
 			l_ptr->retransm_queue_head = mod(++r_q_head);
 			l_ptr->retransm_queue_size = --r_q_size;
 			l_ptr->stats.retransmitted++;
-			return TIPC_OK;
+			return 0;
 		} else {
 			l_ptr->stats.bearer_congs++;
 			msg_dbg(buf_msg(buf), "|>DEF-RETR>");
@@ -1580,7 +1580,7 @@ u32 tipc_link_push_packet(struct link *l_ptr)
 			l_ptr->unacked_window = 0;
 			buf_discard(buf);
 			l_ptr->proto_msg_queue = NULL;
-			return TIPC_OK;
+			return 0;
 		} else {
 			msg_dbg(buf_msg(buf), "|>DEF-PROT>");
 			l_ptr->stats.bearer_congs++;
@@ -1604,7 +1604,7 @@ u32 tipc_link_push_packet(struct link *l_ptr)
 					msg_set_type(msg, CLOSED_MSG);
 				msg_dbg(msg, ">PUSH-DATA>");
 				l_ptr->next_out = buf->next;
-				return TIPC_OK;
+				return 0;
 			} else {
 				msg_dbg(msg, "|PUSH-DATA|");
 				l_ptr->stats.bearer_congs++;
@@ -1628,8 +1628,8 @@ void tipc_link_push_queue(struct link *l_ptr)
 
 	do {
 		res = tipc_link_push_packet(l_ptr);
-	}
-	while (res == TIPC_OK);
+	} while (!res);
+
 	if (res == PUSH_FAILED)
 		tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
 }
@@ -2998,7 +2998,7 @@ struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space
 			link_set_supervision_props(l_ptr, new_value);
 			tipc_link_send_proto_msg(l_ptr, STATE_MSG,
 						 0, 0, new_value, 0, 0);
-			res = TIPC_OK;
+			res = 0;
 		}
 		break;
 	case TIPC_CMD_SET_LINK_PRI:
@@ -3007,14 +3007,14 @@ struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space
 			l_ptr->priority = new_value;
 			tipc_link_send_proto_msg(l_ptr, STATE_MSG,
 						 0, 0, 0, new_value, 0);
-			res = TIPC_OK;
+			res = 0;
 		}
 		break;
 	case TIPC_CMD_SET_LINK_WINDOW:
 		if ((new_value >= TIPC_MIN_LINK_WIN) &&
 		    (new_value <= TIPC_MAX_LINK_WIN)) {
 			tipc_link_set_queue_limits(l_ptr, new_value);
-			res = TIPC_OK;
+			res = 0;
 		}
 		break;
 	}
@@ -3230,7 +3230,7 @@ int link_control(const char *name, u32 op, u32 val)
 			if (op == TIPC_CMD_UNBLOCK_LINK) {
 				l_ptr->blocked = 0;
 			}
-			res = TIPC_OK;
+			res = 0;
 		}
 		tipc_node_unlock(node);
 	}
diff --git a/net/tipc/net.c b/net/tipc/net.c
index cc51fa4..ec7b04f 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -165,7 +165,7 @@ static int net_init(void)
 	if (!tipc_net.zones) {
 		return -ENOMEM;
 	}
-	return TIPC_OK;
+	return 0;
 }
 
 static void net_stop(void)
@@ -295,7 +295,7 @@ int tipc_net_start(u32 addr)
 	info("Started in network mode\n");
 	info("Own node address %s, network identity %u\n",
 	     addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
-	return TIPC_OK;
+	return 0;
 }
 
 void tipc_net_stop(void)
diff --git a/net/tipc/port.c b/net/tipc/port.c
index ffba1e7..e70d27e 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -291,7 +291,7 @@ int tipc_deleteport(u32 ref)
 	kfree(p_ptr);
 	dbg("Deleted port %u\n", ref);
 	tipc_net_route_msg(buf);
-	return TIPC_OK;
+	return 0;
 }
 
 /**
@@ -336,7 +336,7 @@ int tipc_portunreliable(u32 ref, unsigned int *isunreliable)
 		return -EINVAL;
 	*isunreliable = port_unreliable(p_ptr);
 	tipc_port_unlock(p_ptr);
-	return TIPC_OK;
+	return 0;
 }
 
 int tipc_set_portunreliable(u32 ref, unsigned int isunreliable)
@@ -348,7 +348,7 @@ int tipc_set_portunreliable(u32 ref, unsigned int isunreliable)
 		return -EINVAL;
 	msg_set_src_droppable(&p_ptr->publ.phdr, (isunreliable != 0));
 	tipc_port_unlock(p_ptr);
-	return TIPC_OK;
+	return 0;
 }
 
 static int port_unreturnable(struct port *p_ptr)
@@ -365,7 +365,7 @@ int tipc_portunreturnable(u32 ref, unsigned int *isunrejectable)
 		return -EINVAL;
 	*isunrejectable = port_unreturnable(p_ptr);
 	tipc_port_unlock(p_ptr);
-	return TIPC_OK;
+	return 0;
 }
 
 int tipc_set_portunreturnable(u32 ref, unsigned int isunrejectable)
@@ -377,7 +377,7 @@ int tipc_set_portunreturnable(u32 ref, unsigned int isunrejectable)
 		return -EINVAL;
 	msg_set_dest_droppable(&p_ptr->publ.phdr, (isunrejectable != 0));
 	tipc_port_unlock(p_ptr);
-	return TIPC_OK;
+	return 0;
 }
 
 /*
@@ -963,7 +963,7 @@ static u32 port_dispatcher(struct tipc_port *dummy, struct sk_buff *buf)
 		tipc_k_signal((Handler)port_dispatcher_sigh, 0);
 	}
 	spin_unlock_bh(&queue_lock);
-	return TIPC_OK;
+	return 0;
 }
 
 /*
@@ -1068,14 +1068,14 @@ int tipc_createport(u32 user_ref,
 	tipc_reg_add_port(up_ptr);
 	*portref = p_ptr->publ.ref;
 	tipc_port_unlock(p_ptr);
-	return TIPC_OK;
+	return 0;
 }
 
 int tipc_ownidentity(u32 ref, struct tipc_portid *id)
 {
 	id->ref = ref;
 	id->node = tipc_own_addr;
-	return TIPC_OK;
+	return 0;
 }
 
 int tipc_portimportance(u32 ref, unsigned int *importance)
@@ -1087,7 +1087,7 @@ int tipc_portimportance(u32 ref, unsigned int *importance)
 		return -EINVAL;
 	*importance = (unsigned int)msg_importance(&p_ptr->publ.phdr);
 	tipc_port_unlock(p_ptr);
-	return TIPC_OK;
+	return 0;
 }
 
 int tipc_set_portimportance(u32 ref, unsigned int imp)
@@ -1102,7 +1102,7 @@ int tipc_set_portimportance(u32 ref, unsigned int imp)
 		return -EINVAL;
 	msg_set_importance(&p_ptr->publ.phdr, (u32)imp);
 	tipc_port_unlock(p_ptr);
-	return TIPC_OK;
+	return 0;
 }
 
 
@@ -1137,7 +1137,7 @@ int tipc_publish(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 		list_add(&publ->pport_list, &p_ptr->publications);
 		p_ptr->pub_count++;
 		p_ptr->publ.published = 1;
-		res = TIPC_OK;
+		res = 0;
 	}
 exit:
 	tipc_port_unlock(p_ptr);
@@ -1160,7 +1160,7 @@ int tipc_withdraw(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 			tipc_nametbl_withdraw(publ->type, publ->lower,
 					      publ->ref, publ->key);
 		}
-		res = TIPC_OK;
+		res = 0;
 	} else {
 		list_for_each_entry_safe(publ, tpubl,
 					 &p_ptr->publications, pport_list) {
@@ -1174,7 +1174,7 @@ int tipc_withdraw(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 				break;
 			tipc_nametbl_withdraw(publ->type, publ->lower,
 					      publ->ref, publ->key);
-			res = TIPC_OK;
+			res = 0;
 			break;
 		}
 	}
@@ -1218,7 +1218,7 @@ int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
 	tipc_nodesub_subscribe(&p_ptr->subscription,peer->node,
 			  (void *)(unsigned long)ref,
 			  (net_ev_handler)port_handle_node_down);
-	res = TIPC_OK;
+	res = 0;
 exit:
 	tipc_port_unlock(p_ptr);
 	p_ptr->publ.max_pkt = tipc_link_get_max_pkt(peer->node, ref);
@@ -1240,7 +1240,7 @@ int tipc_disconnect_port(struct tipc_port *tp_ptr)
 		/* let timer expire on it's own to avoid deadlock! */
 		tipc_nodesub_unsubscribe(
 			&((struct port *)tp_ptr)->subscription);
-		res = TIPC_OK;
+		res = 0;
 	} else {
 		res = -ENOTCONN;
 	}
@@ -1305,7 +1305,7 @@ int tipc_isconnected(u32 ref, int *isconnected)
 		return -EINVAL;
 	*isconnected = p_ptr->publ.connected;
 	tipc_port_unlock(p_ptr);
-	return TIPC_OK;
+	return 0;
 }
 
 int tipc_peer(u32 ref, struct tipc_portid *peer)
@@ -1319,7 +1319,7 @@ int tipc_peer(u32 ref, struct tipc_portid *peer)
 	if (p_ptr->publ.connected) {
 		peer->ref = port_peerport(p_ptr);
 		peer->node = port_peernode(p_ptr);
-		res = TIPC_OK;
+		res = 0;
 	} else
 		res = -ENOTCONN;
 	tipc_port_unlock(p_ptr);
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index a101de8..414fc34 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -123,7 +123,7 @@ int tipc_ref_table_init(u32 requested_size, u32 start)
 	tipc_ref_table.index_mask = actual_size - 1;
 	tipc_ref_table.start_mask = start & ~tipc_ref_table.index_mask;
 
-	return TIPC_OK;
+	return 0;
 }
 
 /**
diff --git a/net/tipc/user_reg.c b/net/tipc/user_reg.c
index 4146c40..5069288 100644
--- a/net/tipc/user_reg.c
+++ b/net/tipc/user_reg.c
@@ -91,7 +91,7 @@ static int reg_init(void)
 		}
 	}
 	spin_unlock_bh(&reg_lock);
-	return users ? TIPC_OK : -ENOMEM;
+	return users ? 0 : -ENOMEM;
 }
 
 /**
@@ -129,7 +129,7 @@ int tipc_reg_start(void)
 			tipc_k_signal((Handler)reg_callback,
 				      (unsigned long)&users[u]);
 	}
-	return TIPC_OK;
+	return 0;
 }
 
 /**
@@ -184,7 +184,7 @@ int tipc_attach(u32 *userid, tipc_mode_event cb, void *usr_handle)
 
 	if (cb && (tipc_mode != TIPC_NOT_RUNNING))
 		tipc_k_signal((Handler)reg_callback, (unsigned long)user_ptr);
-	return TIPC_OK;
+	return 0;
 }
 
 /**
@@ -230,7 +230,7 @@ int tipc_reg_add_port(struct user_port *up_ptr)
 	struct tipc_user *user_ptr;
 
 	if (up_ptr->user_ref == 0)
-		return TIPC_OK;
+		return 0;
 	if (up_ptr->user_ref > MAX_USERID)
 		return -EINVAL;
 	if ((tipc_mode == TIPC_NOT_RUNNING) || !users )
@@ -240,7 +240,7 @@ int tipc_reg_add_port(struct user_port *up_ptr)
 	user_ptr = &users[up_ptr->user_ref];
 	list_add(&up_ptr->uport_list, &user_ptr->ports);
 	spin_unlock_bh(&reg_lock);
-	return TIPC_OK;
+	return 0;
 }
 
 /**
@@ -250,7 +250,7 @@ int tipc_reg_add_port(struct user_port *up_ptr)
 int tipc_reg_remove_port(struct user_port *up_ptr)
 {
 	if (up_ptr->user_ref == 0)
-		return TIPC_OK;
+		return 0;
 	if (up_ptr->user_ref > MAX_USERID)
 		return -EINVAL;
 	if (!users )
@@ -259,6 +259,6 @@ int tipc_reg_remove_port(struct user_port *up_ptr)
 	spin_lock_bh(&reg_lock);
 	list_del_init(&up_ptr->uport_list);
 	spin_unlock_bh(&reg_lock);
-	return TIPC_OK;
+	return 0;
 }
 
-- 
1.5.4.3

