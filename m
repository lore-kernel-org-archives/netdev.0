From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 3/8] tipc: use standard printk shortcut macros (pr_err etc.)
Date: Thu, 12 Jul 2012 12:39:56 -0400
Message-ID: <1342111201-9426-4-git-send-email-paul.gortmaker@windriver.com>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43552 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161336Ab2GLQk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:40:29 -0400
In-Reply-To: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

All messages should go directly to the kernel log.  The TIPC
specific error, warning, info and debug trace macro's are
removed and all references replaced with pr_err, pr_warn,
pr_info and pr_debug.

Commonly used sub-strings are explicitly declared as a const
char to reduce .text size.

Note that this means the debug messages (changed to pr_debug),
are now enabled through dynamic debugging, instead of a TIPC
specific Kconfig option (TIPC_DEBUG).  The latter will be
phased out completely

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c       |    2 +-
 net/tipc/bearer.c      |   52 ++++++++++++-----------
 net/tipc/config.c      |    6 +--
 net/tipc/core.c        |   10 ++---
 net/tipc/core.h        |   10 -----
 net/tipc/discover.c    |    4 +-
 net/tipc/handler.c     |    4 +-
 net/tipc/link.c        |  109 +++++++++++++++++++++++++-----------------------
 net/tipc/name_distr.c  |   25 +++++------
 net/tipc/name_table.c  |   40 +++++++++---------
 net/tipc/net.c         |    8 ++--
 net/tipc/netlink.c     |    2 +-
 net/tipc/node.c        |   23 +++++-----
 net/tipc/node_subscr.c |    3 +-
 net/tipc/port.c        |    8 ++--
 net/tipc/ref.c         |   10 ++---
 net/tipc/socket.c      |    4 +-
 net/tipc/subscr.c      |   14 +++----
 18 files changed, 168 insertions(+), 166 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index d9df34f..c4414c7 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -880,7 +880,7 @@ void tipc_port_list_add(struct tipc_port_list *pl_ptr, u32 port)
 		if (!item->next) {
 			item->next = kmalloc(sizeof(*item), GFP_ATOMIC);
 			if (!item->next) {
-				warn("Incomplete multicast delivery, no memory\n");
+				pr_warn("TIPC: Incomplete multicast delivery, no memory\n");
 				return;
 			}
 			item->next->next = NULL;
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 86b703f..a663d30 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -123,7 +123,7 @@ int tipc_register_media(struct tipc_media *m_ptr)
 exit:
 	write_unlock_bh(&tipc_net_lock);
 	if (res)
-		warn("Media <%s> registration error\n", m_ptr->name);
+		pr_warn("TIPC: Media <%s> registration error\n", m_ptr->name);
 	return res;
 }
 
@@ -418,12 +418,12 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 	int res = -EINVAL;
 
 	if (!tipc_own_addr) {
-		warn("Bearer <%s> rejected, not supported in standalone mode\n",
-		     name);
+		pr_warn("TIPC: Bearer <%s> rejected, not supported in standalone mode\n",
+			name);
 		return -ENOPROTOOPT;
 	}
 	if (!bearer_name_validate(name, &b_names)) {
-		warn("Bearer <%s> rejected, illegal name\n", name);
+		pr_warn("TIPC: Bearer <%s> rejected, illegal name\n", name);
 		return -EINVAL;
 	}
 	if (tipc_addr_domain_valid(disc_domain) &&
@@ -435,12 +435,13 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 			res = 0;   /* accept specified node in own cluster */
 	}
 	if (res) {
-		warn("Bearer <%s> rejected, illegal discovery domain\n", name);
+		pr_warn("TIPC: Bearer <%s> rejected, illegal discovery domain\n",
+			name);
 		return -EINVAL;
 	}
 	if ((priority > TIPC_MAX_LINK_PRI) &&
 	    (priority != TIPC_MEDIA_LINK_PRI)) {
-		warn("Bearer <%s> rejected, illegal priority\n", name);
+		pr_warn("TIPC: Bearer <%s> rejected, illegal priority\n", name);
 		return -EINVAL;
 	}
 
@@ -448,8 +449,8 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 
 	m_ptr = tipc_media_find(b_names.media_name);
 	if (!m_ptr) {
-		warn("Bearer <%s> rejected, media <%s> not registered\n", name,
-		     b_names.media_name);
+		pr_warn("TIPC: Bearer <%s> rejected, media <%s> not registered\n",
+			name, b_names.media_name);
 		goto exit;
 	}
 
@@ -465,24 +466,25 @@ restart:
 			continue;
 		}
 		if (!strcmp(name, tipc_bearers[i].name)) {
-			warn("Bearer <%s> rejected, already enabled\n", name);
+			pr_warn("TIPC: Bearer <%s> rejected, already enabled\n",
+				name);
 			goto exit;
 		}
 		if ((tipc_bearers[i].priority == priority) &&
 		    (++with_this_prio > 2)) {
 			if (priority-- == 0) {
-				warn("Bearer <%s> rejected, duplicate priority\n",
-				     name);
+				pr_warn("TIPC: Bearer <%s> rejected, duplicate priority\n",
+					name);
 				goto exit;
 			}
-			warn("Bearer <%s> priority adjustment required %u->%u\n",
-			     name, priority + 1, priority);
+			pr_warn("TIPC: Bearer <%s> priority adjustment required %u->%u\n",
+				name, priority + 1, priority);
 			goto restart;
 		}
 	}
 	if (bearer_id >= MAX_BEARERS) {
-		warn("Bearer <%s> rejected, bearer limit reached (%u)\n",
-		     name, MAX_BEARERS);
+		pr_warn("TIPC: Bearer <%s> rejected, bearer limit reached (%u)\n",
+			name, MAX_BEARERS);
 		goto exit;
 	}
 
@@ -490,7 +492,8 @@ restart:
 	strcpy(b_ptr->name, name);
 	res = m_ptr->enable_bearer(b_ptr);
 	if (res) {
-		warn("Bearer <%s> rejected, enable failure (%d)\n", name, -res);
+		pr_warn("TIPC: Bearer <%s> rejected, enable failure (%d)\n",
+			name, -res);
 		goto exit;
 	}
 
@@ -508,12 +511,13 @@ restart:
 	res = tipc_disc_create(b_ptr, &m_ptr->bcast_addr, disc_domain);
 	if (res) {
 		bearer_disable(b_ptr);
-		warn("Bearer <%s> rejected, discovery object creation failed\n",
-		     name);
+		pr_warn("TIPC: Bearer <%s> rejected, discovery object creation failed\n",
+			name);
 		goto exit;
 	}
-	info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
-	     name, tipc_addr_string_fill(addr_string, disc_domain), priority);
+	pr_info("TIPC: Enabled bearer <%s>, discovery domain %s, priority %u\n",
+		name,
+		tipc_addr_string_fill(addr_string, disc_domain), priority);
 exit:
 	write_unlock_bh(&tipc_net_lock);
 	return res;
@@ -531,12 +535,12 @@ int tipc_block_bearer(const char *name)
 	read_lock_bh(&tipc_net_lock);
 	b_ptr = tipc_bearer_find(name);
 	if (!b_ptr) {
-		warn("Attempt to block unknown bearer <%s>\n", name);
+		pr_warn("TIPC: Attempt to block unknown bearer <%s>\n", name);
 		read_unlock_bh(&tipc_net_lock);
 		return -EINVAL;
 	}
 
-	info("Blocking bearer <%s>\n", name);
+	pr_info("TIPC: Blocking bearer <%s>\n", name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->blocked = 1;
 	list_splice_init(&b_ptr->cong_links, &b_ptr->links);
@@ -562,7 +566,7 @@ static void bearer_disable(struct tipc_bearer *b_ptr)
 	struct tipc_link *l_ptr;
 	struct tipc_link *temp_l_ptr;
 
-	info("Disabling bearer <%s>\n", b_ptr->name);
+	pr_info("TIPC: Disabling bearer <%s>\n", b_ptr->name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->blocked = 1;
 	b_ptr->media->disable_bearer(b_ptr);
@@ -584,7 +588,7 @@ int tipc_disable_bearer(const char *name)
 	write_lock_bh(&tipc_net_lock);
 	b_ptr = tipc_bearer_find(name);
 	if (b_ptr == NULL) {
-		warn("Attempt to disable unknown bearer <%s>\n", name);
+		pr_warn("TIPC: Attempt to disable unknown bearer <%s>\n", name);
 		res = -EINVAL;
 	} else {
 		bearer_disable(b_ptr);
diff --git a/net/tipc/config.c b/net/tipc/config.c
index c5712a3..30e5b0a 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -432,7 +432,7 @@ static void cfg_named_msg_event(void *userdata,
 	if ((size < sizeof(*req_hdr)) ||
 	    (size != TCM_ALIGN(ntohl(req_hdr->tcm_len))) ||
 	    (ntohs(req_hdr->tcm_flags) != TCM_F_REQUEST)) {
-		warn("Invalid configuration message discarded\n");
+		pr_warn("TIPC: Invalid configuration message discarded\n");
 		return;
 	}
 
@@ -478,7 +478,7 @@ int tipc_cfg_init(void)
 	return 0;
 
 failed:
-	err("Unable to create configuration service\n");
+	pr_err("TIPC: Unable to create configuration service\n");
 	return res;
 }
 
@@ -494,7 +494,7 @@ void tipc_cfg_reinit(void)
 	seq.lower = seq.upper = tipc_own_addr;
 	res = tipc_publish(config_port_ref, TIPC_ZONE_SCOPE, &seq);
 	if (res)
-		err("Unable to reinitialize configuration service\n");
+		pr_err("TIPC: Unable to reinitialize configuration service\n");
 }
 
 void tipc_cfg_stop(void)
diff --git a/net/tipc/core.c b/net/tipc/core.c
index f7b9523..019d054 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -162,9 +162,9 @@ static int __init tipc_init(void)
 	int res;
 
 	if (tipc_log_resize(CONFIG_TIPC_LOG) != 0)
-		warn("Unable to create log buffer\n");
+		pr_warn("TIPC: Unable to create log buffer\n");
 
-	info("Activated (version " TIPC_MOD_VER ")\n");
+	pr_info("TIPC: Activated (version " TIPC_MOD_VER ")\n");
 
 	tipc_own_addr = 0;
 	tipc_remote_management = 1;
@@ -175,9 +175,9 @@ static int __init tipc_init(void)
 
 	res = tipc_core_start();
 	if (res)
-		err("Unable to start in single node mode\n");
+		pr_err("TIPC: Unable to start in single node mode\n");
 	else
-		info("Started in single node mode\n");
+		pr_info("TIPC: Started in single node mode\n");
 	return res;
 }
 
@@ -185,7 +185,7 @@ static void __exit tipc_exit(void)
 {
 	tipc_core_stop_net();
 	tipc_core_stop();
-	info("Deactivated\n");
+	pr_info("TIPC: Deactivated\n");
 }
 
 module_init(tipc_init);
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 2a9bb99..e8b4909 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -89,13 +89,6 @@ void tipc_printf(struct print_buf *, const char *fmt, ...);
 #define TIPC_OUTPUT TIPC_LOG
 #endif
 
-#define err(fmt, arg...)  tipc_printf(TIPC_OUTPUT, \
-				      KERN_ERR "TIPC: " fmt, ## arg)
-#define warn(fmt, arg...) tipc_printf(TIPC_OUTPUT, \
-				      KERN_WARNING "TIPC: " fmt, ## arg)
-#define info(fmt, arg...) tipc_printf(TIPC_OUTPUT, \
-				      KERN_NOTICE "TIPC: " fmt, ## arg)
-
 #ifdef CONFIG_TIPC_DEBUG
 
 /*
@@ -105,15 +98,12 @@ void tipc_printf(struct print_buf *, const char *fmt, ...);
 #define DBG_OUTPUT TIPC_LOG
 #endif
 
-#define dbg(fmt, arg...)  tipc_printf(DBG_OUTPUT, KERN_DEBUG fmt, ## arg);
-
 #define msg_dbg(msg, txt) tipc_msg_dbg(DBG_OUTPUT, msg, txt);
 
 void tipc_msg_dbg(struct print_buf *, struct tipc_msg *, const char *);
 
 #else
 
-#define dbg(fmt, arg...)	do {} while (0)
 #define msg_dbg(msg, txt)	do {} while (0)
 
 #define tipc_msg_dbg(buf, msg, txt) do {} while (0)
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index ae054cf..8f92e52 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -106,8 +106,8 @@ static void disc_dupl_alert(struct tipc_bearer *b_ptr, u32 node_addr,
 	tipc_printbuf_init(&pb, media_addr_str, sizeof(media_addr_str));
 	tipc_media_addr_printf(&pb, media_addr);
 	tipc_printbuf_validate(&pb);
-	warn("Duplicate %s using %s seen on <%s>\n",
-	     node_addr_str, media_addr_str, b_ptr->name);
+	pr_warn("TIPC: Duplicate %s using %s seen on <%s>\n",
+		node_addr_str, media_addr_str, b_ptr->name);
 }
 
 /**
diff --git a/net/tipc/handler.c b/net/tipc/handler.c
index 9c6f22f..061e7a6 100644
--- a/net/tipc/handler.c
+++ b/net/tipc/handler.c
@@ -57,14 +57,14 @@ unsigned int tipc_k_signal(Handler routine, unsigned long argument)
 	struct queue_item *item;
 
 	if (!handler_enabled) {
-		err("Signal request ignored by handler\n");
+		pr_err("TIPC: Signal request ignored by handler\n");
 		return -ENOPROTOOPT;
 	}
 
 	spin_lock_bh(&qitem_lock);
 	item = kmem_cache_alloc(tipc_queue_item_cache, GFP_ATOMIC);
 	if (!item) {
-		err("Signal queue out of memory\n");
+		pr_err("TIPC: Signal queue out of memory\n");
 		spin_unlock_bh(&qitem_lock);
 		return -ENOMEM;
 	}
diff --git a/net/tipc/link.c b/net/tipc/link.c
index f6bf483..da1f3c5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -41,6 +41,12 @@
 #include "discover.h"
 #include "config.h"
 
+/*
+ * Error message prefixes
+ */
+static const char *link_co_err = "TIPC: Link changeover error, ";
+static const char *link_rst_msg = "TIPC: Resetting link ";
+static const char *link_unk_evt = "TIPC: Unknown link event ";
 
 /*
  * Out-of-range value for link session numbers
@@ -300,20 +306,21 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 
 	if (n_ptr->link_cnt >= 2) {
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
-		err("Attempt to establish third link to %s\n", addr_string);
+		pr_err("TIPC: Attempt to establish third link to %s\n",
+		       addr_string);
 		return NULL;
 	}
 
 	if (n_ptr->links[b_ptr->identity]) {
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
-		err("Attempt to establish second link on <%s> to %s\n",
+		pr_err("TIPC: Attempt to establish second link on <%s> to %s\n",
 		    b_ptr->name, addr_string);
 		return NULL;
 	}
 
 	l_ptr = kzalloc(sizeof(*l_ptr), GFP_ATOMIC);
 	if (!l_ptr) {
-		warn("Link creation failed, no memory\n");
+		pr_warn("TIPC: Link creation failed, no memory\n");
 		return NULL;
 	}
 
@@ -371,7 +378,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 void tipc_link_delete(struct tipc_link *l_ptr)
 {
 	if (!l_ptr) {
-		err("Attempt to delete non-existent link\n");
+		pr_err("TIPC: Attempt to delete non-existent link\n");
 		return;
 	}
 
@@ -632,8 +639,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv / 4);
 			break;
 		case RESET_MSG:
-			info("Resetting link <%s>, requested by peer\n",
-			     l_ptr->name);
+			pr_info("%s<%s>, requested by peer\n", link_rst_msg,
+				l_ptr->name);
 			tipc_link_reset(l_ptr);
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
@@ -642,7 +649,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		default:
-			err("Unknown link event %u in WW state\n", event);
+			pr_err("%s%u in WW state\n", link_unk_evt, event);
 		}
 		break;
 	case WORKING_UNKNOWN:
@@ -654,8 +661,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		case RESET_MSG:
-			info("Resetting link <%s>, requested by peer "
-			     "while probing\n", l_ptr->name);
+			pr_info("%s<%s>, requested by peer while probing\n",
+				link_rst_msg, l_ptr->name);
 			tipc_link_reset(l_ptr);
 			l_ptr->state = RESET_RESET;
 			l_ptr->fsm_msg_cnt = 0;
@@ -680,8 +687,8 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 				l_ptr->fsm_msg_cnt++;
 				link_set_timer(l_ptr, cont_intv / 4);
 			} else {	/* Link has failed */
-				warn("Resetting link <%s>, peer not responding\n",
-				     l_ptr->name);
+				pr_warn("%s<%s>, peer not responding\n",
+					link_rst_msg, l_ptr->name);
 				tipc_link_reset(l_ptr);
 				l_ptr->state = RESET_UNKNOWN;
 				l_ptr->fsm_msg_cnt = 0;
@@ -692,7 +699,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			}
 			break;
 		default:
-			err("Unknown link event %u in WU state\n", event);
+			pr_err("%s%u in WU state\n", link_unk_evt, event);
 		}
 		break;
 	case RESET_UNKNOWN:
@@ -726,7 +733,7 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		default:
-			err("Unknown link event %u in RU state\n", event);
+			pr_err("%s%u in RU state\n", link_unk_evt, event);
 		}
 		break;
 	case RESET_RESET:
@@ -751,11 +758,11 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 			link_set_timer(l_ptr, cont_intv);
 			break;
 		default:
-			err("Unknown link event %u in RR state\n", event);
+			pr_err("%s%u in RR state\n", link_unk_evt, event);
 		}
 		break;
 	default:
-		err("Unknown link state %u/%u\n", l_ptr->state, event);
+		pr_err("TIPC: Unknown link state %u/%u\n", l_ptr->state, event);
 	}
 }
 
@@ -856,7 +863,8 @@ int tipc_link_send_buf(struct tipc_link *l_ptr, struct sk_buff *buf)
 		}
 		kfree_skb(buf);
 		if (imp > CONN_MANAGER) {
-			warn("Resetting link <%s>, send queue full", l_ptr->name);
+			pr_warn("%s<%s>, send queue full", link_rst_msg,
+				l_ptr->name);
 			tipc_link_reset(l_ptr);
 		}
 		return dsz;
@@ -1409,8 +1417,8 @@ static void link_reset_all(unsigned long addr)
 
 	tipc_node_lock(n_ptr);
 
-	warn("Resetting all links to %s\n",
-	     tipc_addr_string_fill(addr_string, n_ptr->addr));
+	pr_warn("TIPC: Resetting all links to %s\n",
+		tipc_addr_string_fill(addr_string, n_ptr->addr));
 
 	for (i = 0; i < MAX_BEARERS; i++) {
 		if (n_ptr->links[i]) {
@@ -1428,7 +1436,7 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 {
 	struct tipc_msg *msg = buf_msg(buf);
 
-	warn("Retransmission failure on link <%s>\n", l_ptr->name);
+	pr_warn("TIPC: Retransmission failure on link <%s>\n", l_ptr->name);
 
 	if (l_ptr->addr) {
 		/* Handle failure on standard link */
@@ -1440,21 +1448,21 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 		struct tipc_node *n_ptr;
 		char addr_string[16];
 
-		info("Msg seq number: %u,  ", msg_seqno(msg));
-		info("Outstanding acks: %lu\n",
-		     (unsigned long) TIPC_SKB_CB(buf)->handle);
+		pr_info("TIPC: Msg seq number: %u,  ", msg_seqno(msg));
+		pr_info("TIPC: Outstanding acks: %lu\n",
+			(unsigned long) TIPC_SKB_CB(buf)->handle);
 
 		n_ptr = tipc_bclink_retransmit_to();
 		tipc_node_lock(n_ptr);
 
 		tipc_addr_string_fill(addr_string, n_ptr->addr);
-		info("Broadcast link info for %s\n", addr_string);
-		info("Supportable: %d,  ", n_ptr->bclink.supportable);
-		info("Supported: %d,  ", n_ptr->bclink.supported);
-		info("Acked: %u\n", n_ptr->bclink.acked);
-		info("Last in: %u,  ", n_ptr->bclink.last_in);
-		info("Oos state: %u,  ", n_ptr->bclink.oos_state);
-		info("Last sent: %u\n", n_ptr->bclink.last_sent);
+		pr_info("TIPC: Broadcast link info for %s\n", addr_string);
+		pr_info("TIPC: Supportable: %d,  ", n_ptr->bclink.supportable);
+		pr_info("TIPC: Supported: %d,  ", n_ptr->bclink.supported);
+		pr_info("TIPC: Acked: %u\n", n_ptr->bclink.acked);
+		pr_info("TIPC: Last in: %u,  ", n_ptr->bclink.last_in);
+		pr_info("TIPC: Oos state: %u,  ", n_ptr->bclink.oos_state);
+		pr_info("TIPC: Last sent: %u\n", n_ptr->bclink.last_sent);
 
 		tipc_k_signal((Handler)link_reset_all, (unsigned long)n_ptr->addr);
 
@@ -1479,7 +1487,7 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *buf,
 			l_ptr->retransm_queue_head = msg_seqno(msg);
 			l_ptr->retransm_queue_size = retransmits;
 		} else {
-			err("Unexpected retransmit on link %s (qsize=%d)\n",
+			pr_err("TIPC: Unexpected retransmit on link %s (qsize=%d)\n",
 			    l_ptr->name, l_ptr->retransm_queue_size);
 		}
 		return;
@@ -2074,8 +2082,9 @@ static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf)
 
 		if (msg_linkprio(msg) &&
 		    (msg_linkprio(msg) != l_ptr->priority)) {
-			warn("Resetting link <%s>, priority change %u->%u\n",
-			     l_ptr->name, l_ptr->priority, msg_linkprio(msg));
+			pr_warn("%s<%s>, priority change %u->%u\n",
+				link_rst_msg, l_ptr->name, l_ptr->priority,
+				msg_linkprio(msg));
 			l_ptr->priority = msg_linkprio(msg);
 			tipc_link_reset(l_ptr); /* Enforce change to take effect */
 			break;
@@ -2139,15 +2148,13 @@ static void tipc_link_tunnel(struct tipc_link *l_ptr,
 
 	tunnel = l_ptr->owner->active_links[selector & 1];
 	if (!tipc_link_is_up(tunnel)) {
-		warn("Link changeover error, "
-		     "tunnel link no longer available\n");
+		pr_warn("%stunnel link no longer available\n", link_co_err);
 		return;
 	}
 	msg_set_size(tunnel_hdr, length + INT_H_SIZE);
 	buf = tipc_buf_acquire(length + INT_H_SIZE);
 	if (!buf) {
-		warn("Link changeover error, "
-		     "unable to send tunnel msg\n");
+		pr_warn("%sunable to send tunnel msg\n", link_co_err);
 		return;
 	}
 	skb_copy_to_linear_data(buf, tunnel_hdr, INT_H_SIZE);
@@ -2173,8 +2180,7 @@ void tipc_link_changeover(struct tipc_link *l_ptr)
 		return;
 
 	if (!l_ptr->owner->permit_changeover) {
-		warn("Link changeover error, "
-		     "peer did not permit changeover\n");
+		pr_warn("%speer did not permit changeover\n", link_co_err);
 		return;
 	}
 
@@ -2192,8 +2198,8 @@ void tipc_link_changeover(struct tipc_link *l_ptr)
 			msg_set_size(&tunnel_hdr, INT_H_SIZE);
 			tipc_link_send_buf(tunnel, buf);
 		} else {
-			warn("Link changeover error, "
-			     "unable to send changeover msg\n");
+			pr_warn("%sunable to send changeover msg\n",
+				link_co_err);
 		}
 		return;
 	}
@@ -2246,8 +2252,8 @@ void tipc_link_send_duplicate(struct tipc_link *l_ptr, struct tipc_link *tunnel)
 		msg_set_size(&tunnel_hdr, length + INT_H_SIZE);
 		outbuf = tipc_buf_acquire(length + INT_H_SIZE);
 		if (outbuf == NULL) {
-			warn("Link changeover error, "
-			     "unable to send duplicate msg\n");
+			pr_warn("%sunable to send duplicate msg\n",
+				link_co_err);
 			return;
 		}
 		skb_copy_to_linear_data(outbuf, &tunnel_hdr, INT_H_SIZE);
@@ -2298,7 +2304,7 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 	if (!dest_link)
 		goto exit;
 	if (dest_link == *l_ptr) {
-		err("Unexpected changeover message on link <%s>\n",
+		pr_err("TIPC: Unexpected changeover message on link <%s>\n",
 		    (*l_ptr)->name);
 		goto exit;
 	}
@@ -2310,7 +2316,7 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 			goto exit;
 		*buf = buf_extract(tunnel_buf, INT_H_SIZE);
 		if (*buf == NULL) {
-			warn("Link changeover error, duplicate msg dropped\n");
+			pr_warn("%sduplicate msg dropped\n", link_co_err);
 			goto exit;
 		}
 		kfree_skb(tunnel_buf);
@@ -2319,8 +2325,8 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 
 	/* First original message ?: */
 	if (tipc_link_is_up(dest_link)) {
-		info("Resetting link <%s>, changeover initiated by peer\n",
-		     dest_link->name);
+		pr_info("%s<%s>, changeover initiated by peer\n", link_rst_msg,
+			dest_link->name);
 		tipc_link_reset(dest_link);
 		dest_link->exp_msg_count = msg_count;
 		if (!msg_count)
@@ -2333,8 +2339,7 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 
 	/* Receive original message */
 	if (dest_link->exp_msg_count == 0) {
-		warn("Link switchover error, "
-		     "got too many tunnelled messages\n");
+		pr_warn("%sgot too many tunnelled messages\n", link_co_err);
 		goto exit;
 	}
 	dest_link->exp_msg_count--;
@@ -2346,7 +2351,7 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 			kfree_skb(tunnel_buf);
 			return 1;
 		} else {
-			warn("Link changeover error, original msg dropped\n");
+			pr_warn("%soriginal msg dropped\n", link_co_err);
 		}
 	}
 exit:
@@ -2367,7 +2372,7 @@ void tipc_link_recv_bundle(struct sk_buff *buf)
 	while (msgcount--) {
 		obuf = buf_extract(buf, pos);
 		if (obuf == NULL) {
-			warn("Link unable to unbundle message(s)\n");
+			pr_warn("TIPC: Link unable to unbundle message(s)\n");
 			break;
 		}
 		pos += align(msg_size(buf_msg(obuf)));
@@ -2538,7 +2543,7 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 			set_fragm_size(pbuf, fragm_sz);
 			set_expected_frags(pbuf, exp_fragm_cnt - 1);
 		} else {
-			dbg("Link unable to reassemble fragmented message\n");
+			pr_debug("TIPC: Link unable to reassemble fragmented message\n");
 			kfree_skb(fbuf);
 			return -1;
 		}
@@ -3060,5 +3065,5 @@ print_state:
 	tipc_printf(buf, "\n");
 
 	tipc_printbuf_validate(buf);
-	info("%s", print_area);
+	pr_info("TIPC: %s", print_area);
 }
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 158318e..cdd614e 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -161,7 +161,7 @@ void tipc_named_publish(struct publication *publ)
 
 	buf = named_prepare_buf(PUBLICATION, ITEM_SIZE, 0);
 	if (!buf) {
-		warn("Publication distribution failure\n");
+		pr_warn("TIPC: Publication distribution failure\n");
 		return;
 	}
 
@@ -186,7 +186,7 @@ void tipc_named_withdraw(struct publication *publ)
 
 	buf = named_prepare_buf(WITHDRAWAL, ITEM_SIZE, 0);
 	if (!buf) {
-		warn("Withdrawal distribution failure\n");
+		pr_warn("TIPC: Withdrawal distribution failure\n");
 		return;
 	}
 
@@ -213,7 +213,7 @@ static void named_distribute(struct list_head *message_list, u32 node,
 			rest -= left;
 			buf = named_prepare_buf(PUBLICATION, left, node);
 			if (!buf) {
-				warn("Bulk publication failure\n");
+				pr_warn("TIPC: Bulk publication failure\n");
 				return;
 			}
 			item = (struct distr_item *)msg_data(buf_msg(buf));
@@ -283,9 +283,10 @@ static void named_purge_publ(struct publication *publ)
 	write_unlock_bh(&tipc_nametbl_lock);
 
 	if (p != publ) {
-		err("Unable to remove publication from failed node\n"
-		    "(type=%u, lower=%u, node=0x%x, ref=%u, key=%u)\n",
-		    publ->type, publ->lower, publ->node, publ->ref, publ->key);
+		pr_err("TIPC: Unable to remove publication from failed node\n"
+		       " (type=%u, lower=%u, node=0x%x, ref=%u, key=%u)\n",
+		       publ->type, publ->lower, publ->node, publ->ref,
+		       publ->key);
 	}
 
 	kfree(p);
@@ -329,14 +330,14 @@ void tipc_named_recv(struct sk_buff *buf)
 				tipc_nodesub_unsubscribe(&publ->subscr);
 				kfree(publ);
 			} else {
-				err("Unable to remove publication by node 0x%x\n"
-				    "(type=%u, lower=%u, ref=%u, key=%u)\n",
-				    msg_orignode(msg),
-				    ntohl(item->type), ntohl(item->lower),
-				    ntohl(item->ref), ntohl(item->key));
+				pr_err("TIPC: Unable to remove publication by node 0x%x\n"
+				       " (type=%u, lower=%u, ref=%u, key=%u)\n",
+				       msg_orignode(msg), ntohl(item->type),
+				       ntohl(item->lower), ntohl(item->ref),
+				       ntohl(item->key));
 			}
 		} else {
-			warn("Unrecognized name table message received\n");
+			pr_warn("TIPC: Unrecognized name table message received\n");
 		}
 		item++;
 	}
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index cade0ac..0b48fbb 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -126,7 +126,7 @@ static struct publication *publ_create(u32 type, u32 lower, u32 upper,
 {
 	struct publication *publ = kzalloc(sizeof(*publ), GFP_ATOMIC);
 	if (publ == NULL) {
-		warn("Publication creation failure, no memory\n");
+		pr_warn("TIPC: Publication creation failure, no memory\n");
 		return NULL;
 	}
 
@@ -163,7 +163,7 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
 	struct sub_seq *sseq = tipc_subseq_alloc(1);
 
 	if (!nseq || !sseq) {
-		warn("Name sequence creation failed, no memory\n");
+		pr_warn("TIPC: Name sequence creation failed, no memory\n");
 		kfree(nseq);
 		kfree(sseq);
 		return NULL;
@@ -263,8 +263,8 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 
 		/* Lower end overlaps existing entry => need an exact match */
 		if ((sseq->lower != lower) || (sseq->upper != upper)) {
-			warn("Cannot publish {%u,%u,%u}, overlap error\n",
-			     type, lower, upper);
+			pr_warn("TIPC: Cannot publish {%u,%u,%u}, overlap error\n",
+				type, lower, upper);
 			return NULL;
 		}
 
@@ -286,8 +286,8 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 		/* Fail if upper end overlaps into an existing entry */
 		if ((inspos < nseq->first_free) &&
 		    (upper >= nseq->sseqs[inspos].lower)) {
-			warn("Cannot publish {%u,%u,%u}, overlap error\n",
-			     type, lower, upper);
+			pr_warn("TIPC: Cannot publish {%u,%u,%u}, overlap error\n",
+				type, lower, upper);
 			return NULL;
 		}
 
@@ -296,8 +296,8 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 			struct sub_seq *sseqs = tipc_subseq_alloc(nseq->alloc * 2);
 
 			if (!sseqs) {
-				warn("Cannot publish {%u,%u,%u}, no memory\n",
-				     type, lower, upper);
+				pr_warn("TIPC: Cannot publish {%u,%u,%u}, no memory\n",
+					type, lower, upper);
 				return NULL;
 			}
 			memcpy(sseqs, nseq->sseqs,
@@ -309,8 +309,8 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 
 		info = kzalloc(sizeof(*info), GFP_ATOMIC);
 		if (!info) {
-			warn("Cannot publish {%u,%u,%u}, no memory\n",
-			     type, lower, upper);
+			pr_warn("TIPC: Cannot publish {%u,%u,%u}, no memory\n",
+				type, lower, upper);
 			return NULL;
 		}
 
@@ -492,8 +492,8 @@ struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 
 	if ((scope < TIPC_ZONE_SCOPE) || (scope > TIPC_NODE_SCOPE) ||
 	    (lower > upper)) {
-		dbg("Failed to publish illegal {%u,%u,%u} with scope %u\n",
-		     type, lower, upper, scope);
+		pr_debug("TIPC: Failed to publish illegal {%u,%u,%u} with scope %u\n",
+			 type, lower, upper, scope);
 		return NULL;
 	}
 
@@ -668,8 +668,8 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 	struct publication *publ;
 
 	if (table.local_publ_count >= tipc_max_publications) {
-		warn("Publication failed, local publication limit reached (%u)\n",
-		     tipc_max_publications);
+		pr_warn("TIPC: Publication failed, local publication limit reached (%u)\n",
+			tipc_max_publications);
 		return NULL;
 	}
 
@@ -702,9 +702,9 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 		return 1;
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
-	err("Unable to remove local publication\n"
-	    "(type=%u, lower=%u, ref=%u, key=%u)\n",
-	    type, lower, ref, key);
+	pr_err("TIPC: Unable to remove local publication\n"
+	       "(type=%u, lower=%u, ref=%u, key=%u)\n",
+	       type, lower, ref, key);
 	return 0;
 }
 
@@ -725,8 +725,8 @@ void tipc_nametbl_subscribe(struct tipc_subscription *s)
 		tipc_nameseq_subscribe(seq, s);
 		spin_unlock_bh(&seq->lock);
 	} else {
-		warn("Failed to create subscription for {%u,%u,%u}\n",
-		     s->seq.type, s->seq.lower, s->seq.upper);
+		pr_warn("TIPC: Failed to create subscription for {%u,%u,%u}\n",
+			s->seq.type, s->seq.lower, s->seq.upper);
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
 }
@@ -942,7 +942,7 @@ void tipc_nametbl_stop(void)
 	for (i = 0; i < tipc_nametbl_size; i++) {
 		if (hlist_empty(&table.types[i]))
 			continue;
-		err("tipc_nametbl_stop(): orphaned hash chain detected\n");
+		pr_err("TIPC: nametbl_stop(): orphaned hash chain detected\n");
 		break;
 	}
 	kfree(table.types);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 7c236c8..38a34b9 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -184,9 +184,9 @@ int tipc_net_start(u32 addr)
 
 	tipc_cfg_reinit();
 
-	info("Started in network mode\n");
-	info("Own node address %s, network identity %u\n",
-	     tipc_addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
+	pr_info("TIPC: Started in network mode\n");
+	pr_info("TIPC: Own node address %s, network identity %u\n",
+		tipc_addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
 	return 0;
 }
 
@@ -202,5 +202,5 @@ void tipc_net_stop(void)
 	list_for_each_entry_safe(node, t_node, &tipc_node_list, list)
 		tipc_node_delete(node);
 	write_unlock_bh(&tipc_net_lock);
-	info("Left network mode\n");
+	pr_info("TIPC: Left network mode\n");
 }
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 7bda8e3..f8ca12d 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -90,7 +90,7 @@ int tipc_netlink_start(void)
 	res = genl_register_family_with_ops(&tipc_genl_family,
 		&tipc_genl_ops, 1);
 	if (res) {
-		err("Failed to register netlink interface\n");
+		pr_err("TIPC: Failed to register netlink interface\n");
 		return res;
 	}
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index d4fd341..e03fc45 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -105,7 +105,7 @@ struct tipc_node *tipc_node_create(u32 addr)
 	n_ptr = kzalloc(sizeof(*n_ptr), GFP_ATOMIC);
 	if (!n_ptr) {
 		spin_unlock_bh(&node_create_lock);
-		warn("Node creation failed, no memory\n");
+		pr_warn("TIPC: Node creation failed, no memory\n");
 		return NULL;
 	}
 
@@ -151,8 +151,8 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 
 	n_ptr->working_links++;
 
-	info("Established link <%s> on network plane %c\n",
-	     l_ptr->name, l_ptr->b_ptr->net_plane);
+	pr_info("TIPC: Established link <%s> on network plane %c\n",
+		l_ptr->name, l_ptr->b_ptr->net_plane);
 
 	if (!active[0]) {
 		active[0] = active[1] = l_ptr;
@@ -160,7 +160,7 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		return;
 	}
 	if (l_ptr->priority < active[0]->priority) {
-		info("New link <%s> becomes standby\n", l_ptr->name);
+		pr_info("TIPC: New link <%s> becomes standby\n", l_ptr->name);
 		return;
 	}
 	tipc_link_send_duplicate(active[0], l_ptr);
@@ -168,9 +168,10 @@ void tipc_node_link_up(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 		active[0] = l_ptr;
 		return;
 	}
-	info("Old link <%s> becomes standby\n", active[0]->name);
+	pr_info("TIPC: Old link <%s> becomes standby\n", active[0]->name);
 	if (active[1] != active[0])
-		info("Old link <%s> becomes standby\n", active[1]->name);
+		pr_info("TIPC: Old link <%s> becomes standby\n",
+			active[1]->name);
 	active[0] = active[1] = l_ptr;
 }
 
@@ -211,11 +212,11 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	n_ptr->working_links--;
 
 	if (!tipc_link_is_active(l_ptr)) {
-		info("Lost standby link <%s> on network plane %c\n",
-		     l_ptr->name, l_ptr->b_ptr->net_plane);
+		pr_info("TIPC: Lost standby link <%s> on network plane %c\n",
+			l_ptr->name, l_ptr->b_ptr->net_plane);
 		return;
 	}
-	info("Lost link <%s> on network plane %c\n",
+	pr_info("TIPC: Lost link <%s> on network plane %c\n",
 		l_ptr->name, l_ptr->b_ptr->net_plane);
 
 	active = &n_ptr->active_links[0];
@@ -290,8 +291,8 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	char addr_string[16];
 	u32 i;
 
-	info("Lost contact with %s\n",
-	     tipc_addr_string_fill(addr_string, n_ptr->addr));
+	pr_info("TIPC: Lost contact with %s\n",
+		tipc_addr_string_fill(addr_string, n_ptr->addr));
 
 	/* Flush broadcast link info associated with lost node */
 	if (n_ptr->bclink.supported) {
diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
index 7a27344..2256281 100644
--- a/net/tipc/node_subscr.c
+++ b/net/tipc/node_subscr.c
@@ -51,7 +51,8 @@ void tipc_nodesub_subscribe(struct tipc_node_subscr *node_sub, u32 addr,
 
 	node_sub->node = tipc_node_find(addr);
 	if (!node_sub->node) {
-		warn("Node subscription rejected, unknown node 0x%x\n", addr);
+		pr_warn("TIPC: Node subscription rejected, unknown node 0x%x\n",
+			addr);
 		return;
 	}
 	node_sub->handle_node_down = handle_down;
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 70bf78b..5d374d7 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -191,7 +191,7 @@ void tipc_port_recv_mcast(struct sk_buff *buf, struct tipc_port_list *dp)
 			struct sk_buff *b = skb_clone(buf, GFP_ATOMIC);
 
 			if (b == NULL) {
-				warn("Unable to deliver multicast message(s)\n");
+				pr_warn("TIPC: Unable to deliver multicast message(s)\n");
 				goto exit;
 			}
 			if ((index == 0) && (cnt != 0))
@@ -221,12 +221,12 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 
 	p_ptr = kzalloc(sizeof(*p_ptr), GFP_ATOMIC);
 	if (!p_ptr) {
-		warn("Port creation failed, no memory\n");
+		pr_warn("TIPC: Port creation failed, no memory\n");
 		return NULL;
 	}
 	ref = tipc_ref_acquire(p_ptr, &p_ptr->lock);
 	if (!ref) {
-		warn("Port creation failed, reference table exhausted\n");
+		pr_warn("TIPC: Port creation failed, ref. table exhausted\n");
 		kfree(p_ptr);
 		return NULL;
 	}
@@ -906,7 +906,7 @@ int tipc_createport(void *usr_handle,
 
 	up_ptr = kmalloc(sizeof(*up_ptr), GFP_ATOMIC);
 	if (!up_ptr) {
-		warn("Port creation failed, no memory\n");
+		pr_warn("TIPC: Port creation failed, no memory\n");
 		return -ENOMEM;
 	}
 	p_ptr = tipc_createport_raw(NULL, port_dispatcher, port_wakeup,
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 5cada0e..7435871 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -153,11 +153,11 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 	struct reference *entry = NULL;
 
 	if (!object) {
-		err("Attempt to acquire reference to non-existent object\n");
+		pr_err("TIPC: Attempt to acquire ref. to non-existent obj\n");
 		return 0;
 	}
 	if (!tipc_ref_table.entries) {
-		err("Reference table not found during acquisition attempt\n");
+		pr_err("TIPC: Ref. table not found in acquisition attempt\n");
 		return 0;
 	}
 
@@ -211,7 +211,7 @@ void tipc_ref_discard(u32 ref)
 	u32 index_mask;
 
 	if (!tipc_ref_table.entries) {
-		err("Reference table not found during discard attempt\n");
+		pr_err("TIPC: Ref. table not found during discard attempt\n");
 		return;
 	}
 
@@ -222,11 +222,11 @@ void tipc_ref_discard(u32 ref)
 	write_lock_bh(&ref_table_lock);
 
 	if (!entry->object) {
-		err("Attempt to discard reference to non-existent object\n");
+		pr_err("TIPC: Attempt to discard ref. to non-existent obj\n");
 		goto exit;
 	}
 	if (entry->ref != ref) {
-		err("Attempt to discard non-existent reference\n");
+		pr_err("TIPC: Attempt to discard non-existent reference\n");
 		goto exit;
 	}
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1ebb49f..fefec9c 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1787,13 +1787,13 @@ int tipc_socket_init(void)
 
 	res = proto_register(&tipc_proto, 1);
 	if (res) {
-		err("Failed to register TIPC protocol type\n");
+		pr_err("TIPC: Failed to register TIPC protocol type\n");
 		goto out;
 	}
 
 	res = sock_register(&tipc_family_ops);
 	if (res) {
-		err("Failed to register TIPC socket type\n");
+		pr_err("TIPC: Failed to register TIPC socket type\n");
 		proto_unregister(&tipc_proto);
 		goto out;
 	}
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index f976e9c..18703a5 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -305,8 +305,8 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 
 	/* Refuse subscription if global limit exceeded */
 	if (atomic_read(&topsrv.subscription_count) >= tipc_max_subscriptions) {
-		warn("Subscription rejected, subscription limit reached (%u)\n",
-		     tipc_max_subscriptions);
+		pr_warn("TIPC: Subscription rejected, limit reached (%u)\n",
+			tipc_max_subscriptions);
 		subscr_terminate(subscriber);
 		return NULL;
 	}
@@ -314,7 +314,7 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 	/* Allocate subscription object */
 	sub = kmalloc(sizeof(*sub), GFP_ATOMIC);
 	if (!sub) {
-		warn("Subscription rejected, no memory\n");
+		pr_warn("TIPC: Subscription rejected, no memory\n");
 		subscr_terminate(subscriber);
 		return NULL;
 	}
@@ -328,7 +328,7 @@ static struct tipc_subscription *subscr_subscribe(struct tipc_subscr *s,
 	if ((!(sub->filter & TIPC_SUB_PORTS) ==
 	     !(sub->filter & TIPC_SUB_SERVICE)) ||
 	    (sub->seq.lower > sub->seq.upper)) {
-		warn("Subscription rejected, illegal request\n");
+		pr_warn("TIPC: Subscription rejected, illegal request\n");
 		kfree(sub);
 		subscr_terminate(subscriber);
 		return NULL;
@@ -440,7 +440,7 @@ static void subscr_named_msg_event(void *usr_handle,
 	/* Create subscriber object */
 	subscriber = kzalloc(sizeof(struct tipc_subscriber), GFP_ATOMIC);
 	if (subscriber == NULL) {
-		warn("Subscriber rejected, no memory\n");
+		pr_warn("TIPC: Subscriber rejected, no memory\n");
 		return;
 	}
 	INIT_LIST_HEAD(&subscriber->subscription_list);
@@ -458,7 +458,7 @@ static void subscr_named_msg_event(void *usr_handle,
 			NULL,
 			&subscriber->port_ref);
 	if (subscriber->port_ref == 0) {
-		warn("Subscriber rejected, unable to create port\n");
+		pr_warn("TIPC: Subscriber rejected, unable to create port\n");
 		kfree(subscriber);
 		return;
 	}
@@ -517,7 +517,7 @@ int tipc_subscr_start(void)
 	return 0;
 
 failed:
-	err("Failed to create subscription service\n");
+	pr_err("TIPC: Failed to create subscription service\n");
 	return res;
 }
 
-- 
1.7.9.7
