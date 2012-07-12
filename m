From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 7/8] tipc: phase out most of the struct print_buf usage
Date: Thu, 12 Jul 2012 12:40:00 -0400
Message-ID: <1342111201-9426-8-git-send-email-paul.gortmaker@windriver.com>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43566 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161345Ab2GLQkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:40:32 -0400
In-Reply-To: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

The tipc_printf is renamed to tipc_snprintf, as the new name
describes more what the function actually does.  It is also
changed to take a buffer and length parameter and return
number of characters written to the buffer.  All callers of
this function that used to pass a print_buf are updated.

Final removal of the struct print_buf itself will be done
synchronously with the pending removal of the deprecated
logging code that also was using it.

Functions that build up a response message with a list of
ports, nametable contents etc. are changed to return the number
of characters written to the output buffer. This information
was previously hidden in a field of the print_buf struct, and
the number of chars written was fetched with a call to
tipc_printbuf_validate.  This function is removed since it
is no longer referenced nor needed.

A generic max size ULTRA_STRING_MAX_LEN is defined, named
in keeping with the existing TIPC_TLV_ULTRA_STRING, and the
various definitions in port, link and nametable code that
largely duplicated this information are removed.  This means
that amount of link statistics that can be returned is now
increased from 2k to 32k.

The buffer overflow check is now done just before the reply
message is passed over netlink or TIPC to a remote node and
the message indicating a truncated buffer is changed to a less
dramatic one (less CAPS), placed at the end of the message.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c      |   63 +++++++++++-------------
 net/tipc/bearer.c     |   10 ++--
 net/tipc/bearer.h     |    2 +-
 net/tipc/config.c     |   27 ++++++----
 net/tipc/core.h       |    4 +-
 net/tipc/discover.c   |    6 +--
 net/tipc/link.c       |  130 +++++++++++++++++++++++++------------------------
 net/tipc/log.c        |   47 ++----------------
 net/tipc/name_table.c |   88 +++++++++++++++++++--------------
 net/tipc/port.c       |   58 ++++++++++++----------
 10 files changed, 213 insertions(+), 222 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index c4414c7..5b84337 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -701,48 +701,43 @@ void tipc_bcbearer_sort(void)
 
 int tipc_bclink_stats(char *buf, const u32 buf_size)
 {
-	struct print_buf pb;
+	int ret;
+	struct tipc_stats *s;
 
 	if (!bcl)
 		return 0;
 
-	tipc_printbuf_init(&pb, buf, buf_size);
-
 	spin_lock_bh(&bc_lock);
 
-	tipc_printf(&pb, "Link <%s>\n"
-			 "  Window:%u packets\n",
-		    bcl->name, bcl->queue_limit[0]);
-	tipc_printf(&pb, "  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
-		    bcl->stats.recv_info,
-		    bcl->stats.recv_fragments,
-		    bcl->stats.recv_fragmented,
-		    bcl->stats.recv_bundles,
-		    bcl->stats.recv_bundled);
-	tipc_printf(&pb, "  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
-		    bcl->stats.sent_info,
-		    bcl->stats.sent_fragments,
-		    bcl->stats.sent_fragmented,
-		    bcl->stats.sent_bundles,
-		    bcl->stats.sent_bundled);
-	tipc_printf(&pb, "  RX naks:%u defs:%u dups:%u\n",
-		    bcl->stats.recv_nacks,
-		    bcl->stats.deferred_recv,
-		    bcl->stats.duplicates);
-	tipc_printf(&pb, "  TX naks:%u acks:%u dups:%u\n",
-		    bcl->stats.sent_nacks,
-		    bcl->stats.sent_acks,
-		    bcl->stats.retransmitted);
-	tipc_printf(&pb, "  Congestion bearer:%u link:%u  Send queue max:%u avg:%u\n",
-		    bcl->stats.bearer_congs,
-		    bcl->stats.link_congs,
-		    bcl->stats.max_queue_sz,
-		    bcl->stats.queue_sz_counts
-		    ? (bcl->stats.accu_queue_sz / bcl->stats.queue_sz_counts)
-		    : 0);
+	s = &bcl->stats;
+
+	ret = tipc_snprintf(buf, buf_size, "Link <%s>\n"
+			    "  Window:%u packets\n",
+			    bcl->name, bcl->queue_limit[0]);
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
+			     s->recv_info, s->recv_fragments,
+			     s->recv_fragmented, s->recv_bundles,
+			     s->recv_bundled);
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
+			     s->sent_info, s->sent_fragments,
+			     s->sent_fragmented, s->sent_bundles,
+			     s->sent_bundled);
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  RX naks:%u defs:%u dups:%u\n",
+			     s->recv_nacks, s->deferred_recv, s->duplicates);
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  TX naks:%u acks:%u dups:%u\n",
+			     s->sent_nacks, s->sent_acks, s->retransmitted);
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  Congestion bearer:%u link:%u  Send queue max:%u avg:%u\n",
+			     s->bearer_congs, s->link_congs, s->max_queue_sz,
+			     s->queue_sz_counts ?
+			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
 
 	spin_unlock_bh(&bc_lock);
-	return tipc_printbuf_validate(&pb);
+	return ret;
 }
 
 int tipc_bclink_reset_stats(void)
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index a663d30..1186413 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -130,21 +130,23 @@ exit:
 /**
  * tipc_media_addr_printf - record media address in print buffer
  */
-void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a)
+void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a)
 {
 	char addr_str[MAX_ADDR_STR];
 	struct tipc_media *m_ptr;
+	int ret;
 
 	m_ptr = media_find_id(a->media_id);
 
 	if (m_ptr && !m_ptr->addr2str(a, addr_str, sizeof(addr_str)))
-		tipc_printf(pb, "%s(%s)", m_ptr->name, addr_str);
+		ret = tipc_snprintf(buf, len, "%s(%s)", m_ptr->name, addr_str);
 	else {
 		u32 i;
 
-		tipc_printf(pb, "UNKNOWN(%u)", a->media_id);
+		ret = tipc_snprintf(buf, len, "UNKNOWN(%u)", a->media_id);
 		for (i = 0; i < sizeof(a->value); i++)
-			tipc_printf(pb, "-%02x", a->value[i]);
+			ret += tipc_snprintf(buf - ret, len + ret,
+					    "-%02x", a->value[i]);
 	}
 }
 
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 4680de1..dd4c2ab 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -179,7 +179,7 @@ void tipc_eth_media_stop(void);
 
 int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
-void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a);
+void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a);
 struct sk_buff *tipc_media_get_names(void);
 
 struct sk_buff *tipc_bearer_get_names(void);
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 30e5b0a..65057e9 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -39,6 +39,8 @@
 #include "name_table.h"
 #include "config.h"
 
+#define REPLY_TRUNCATED "<truncated>\n"
+
 static u32 config_port_ref;
 
 static DEFINE_SPINLOCK(config_lock);
@@ -104,13 +106,12 @@ struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string)
 	return buf;
 }
 
-#define MAX_STATS_INFO 2000
-
 static struct sk_buff *tipc_show_stats(void)
 {
 	struct sk_buff *buf;
 	struct tlv_desc *rep_tlv;
-	struct print_buf pb;
+	char *pb;
+	int pb_len;
 	int str_len;
 	u32 value;
 
@@ -121,17 +122,16 @@ static struct sk_buff *tipc_show_stats(void)
 	if (value != 0)
 		return tipc_cfg_reply_error_string("unsupported argument");
 
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(MAX_STATS_INFO));
+	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
 	if (buf == NULL)
 		return NULL;
 
 	rep_tlv = (struct tlv_desc *)buf->data;
-	tipc_printbuf_init(&pb, (char *)TLV_DATA(rep_tlv), MAX_STATS_INFO);
-
-	tipc_printf(&pb, "TIPC version " TIPC_MOD_VER "\n");
+	pb = TLV_DATA(rep_tlv);
+	pb_len = ULTRA_STRING_MAX_LEN;
 
-	/* Use additional tipc_printf()'s to return more info ... */
-	str_len = tipc_printbuf_validate(&pb);
+	str_len = tipc_snprintf(pb, pb_len, "TIPC version " TIPC_MOD_VER "\n");
+	str_len += 1;	/* for "\0" */
 	skb_put(buf, TLV_SPACE(str_len));
 	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
 
@@ -408,6 +408,15 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 		break;
 	}
 
+	WARN_ON(rep_tlv_buf->len > TLV_SPACE(ULTRA_STRING_MAX_LEN));
+
+	/* Append an error message if we cannot return all requested data */
+	if (rep_tlv_buf->len == TLV_SPACE(ULTRA_STRING_MAX_LEN)) {
+		if (*(rep_tlv_buf->data + ULTRA_STRING_MAX_LEN) != '\0')
+			sprintf(rep_tlv_buf->data + rep_tlv_buf->len -
+				sizeof(REPLY_TRUNCATED) - 1, REPLY_TRUNCATED);
+	}
+
 	/* Return reply buffer */
 exit:
 	spin_unlock_bh(&config_lock);
diff --git a/net/tipc/core.h b/net/tipc/core.h
index c7b5ab5..7ba74ba 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -58,6 +58,8 @@
 
 #define TIPC_MOD_VER "2.0.0"
 
+#define ULTRA_STRING_MAX_LEN 32768
+
 struct tipc_msg;	/* msg.h */
 struct print_buf;	/* log.h */
 
@@ -80,7 +82,7 @@ extern struct print_buf *const TIPC_NULL;
 extern struct print_buf *const TIPC_CONS;
 extern struct print_buf *const TIPC_LOG;
 
-void tipc_printf(struct print_buf *, const char *fmt, ...);
+int tipc_snprintf(char *buf, int len, const char *fmt, ...);
 
 /*
  * TIPC_OUTPUT is the destination print buffer for system messages.
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 8f92e52..f385fde 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -100,12 +100,10 @@ static void disc_dupl_alert(struct tipc_bearer *b_ptr, u32 node_addr,
 {
 	char node_addr_str[16];
 	char media_addr_str[64];
-	struct print_buf pb;
 
 	tipc_addr_string_fill(node_addr_str, node_addr);
-	tipc_printbuf_init(&pb, media_addr_str, sizeof(media_addr_str));
-	tipc_media_addr_printf(&pb, media_addr);
-	tipc_printbuf_validate(&pb);
+	tipc_media_addr_printf(media_addr_str, sizeof(media_addr_str),
+			       media_addr);
 	pr_warn("TIPC: Duplicate %s using %s seen on <%s>\n",
 		node_addr_str, media_addr_str, b_ptr->name);
 }
diff --git a/net/tipc/link.c b/net/tipc/link.c
index bf4cc41..dab3503 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2865,112 +2865,114 @@ static u32 percent(u32 count, u32 total)
  */
 static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 {
-	struct print_buf pb;
-	struct tipc_link *l_ptr;
+	struct tipc_link *l;
+	struct tipc_stats *s;
 	struct tipc_node *node;
 	char *status;
 	u32 profile_total = 0;
+	int ret;
 
 	if (!strcmp(name, tipc_bclink_name))
 		return tipc_bclink_stats(buf, buf_size);
 
-	tipc_printbuf_init(&pb, buf, buf_size);
-
 	read_lock_bh(&tipc_net_lock);
-	l_ptr = link_find_link(name, &node);
-	if (!l_ptr) {
+	l = link_find_link(name, &node);
+	if (!l) {
 		read_unlock_bh(&tipc_net_lock);
 		return 0;
 	}
 	tipc_node_lock(node);
+	s = &l->stats;
 
-	if (tipc_link_is_active(l_ptr))
+	if (tipc_link_is_active(l))
 		status = "ACTIVE";
-	else if (tipc_link_is_up(l_ptr))
+	else if (tipc_link_is_up(l))
 		status = "STANDBY";
 	else
 		status = "DEFUNCT";
-	tipc_printf(&pb, "Link <%s>\n"
-			 "  %s  MTU:%u  Priority:%u  Tolerance:%u ms"
-			 "  Window:%u packets\n",
-		    l_ptr->name, status, l_ptr->max_pkt,
-		    l_ptr->priority, l_ptr->tolerance, l_ptr->queue_limit[0]);
-	tipc_printf(&pb, "  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
-		    l_ptr->next_in_no - l_ptr->stats.recv_info,
-		    l_ptr->stats.recv_fragments,
-		    l_ptr->stats.recv_fragmented,
-		    l_ptr->stats.recv_bundles,
-		    l_ptr->stats.recv_bundled);
-	tipc_printf(&pb, "  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
-		    l_ptr->next_out_no - l_ptr->stats.sent_info,
-		    l_ptr->stats.sent_fragments,
-		    l_ptr->stats.sent_fragmented,
-		    l_ptr->stats.sent_bundles,
-		    l_ptr->stats.sent_bundled);
-	profile_total = l_ptr->stats.msg_length_counts;
+
+	ret = tipc_snprintf(buf, buf_size, "Link <%s>\n"
+			    "  %s  MTU:%u  Priority:%u  Tolerance:%u ms"
+			    "  Window:%u packets\n",
+			    l->name, status, l->max_pkt, l->priority,
+			    l->tolerance, l->queue_limit[0]);
+
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
+			     l->next_in_no - s->recv_info, s->recv_fragments,
+			     s->recv_fragmented, s->recv_bundles,
+			     s->recv_bundled);
+
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
+			     l->next_out_no - s->sent_info, s->sent_fragments,
+			     s->sent_fragmented, s->sent_bundles,
+			     s->sent_bundled);
+
+	profile_total = s->msg_length_counts;
 	if (!profile_total)
 		profile_total = 1;
-	tipc_printf(&pb, "  TX profile sample:%u packets  average:%u octets\n"
-			 "  0-64:%u%% -256:%u%% -1024:%u%% -4096:%u%% "
-			 "-16384:%u%% -32768:%u%% -66000:%u%%\n",
-		    l_ptr->stats.msg_length_counts,
-		    l_ptr->stats.msg_lengths_total / profile_total,
-		    percent(l_ptr->stats.msg_length_profile[0], profile_total),
-		    percent(l_ptr->stats.msg_length_profile[1], profile_total),
-		    percent(l_ptr->stats.msg_length_profile[2], profile_total),
-		    percent(l_ptr->stats.msg_length_profile[3], profile_total),
-		    percent(l_ptr->stats.msg_length_profile[4], profile_total),
-		    percent(l_ptr->stats.msg_length_profile[5], profile_total),
-		    percent(l_ptr->stats.msg_length_profile[6], profile_total));
-	tipc_printf(&pb, "  RX states:%u probes:%u naks:%u defs:%u dups:%u\n",
-		    l_ptr->stats.recv_states,
-		    l_ptr->stats.recv_probes,
-		    l_ptr->stats.recv_nacks,
-		    l_ptr->stats.deferred_recv,
-		    l_ptr->stats.duplicates);
-	tipc_printf(&pb, "  TX states:%u probes:%u naks:%u acks:%u dups:%u\n",
-		    l_ptr->stats.sent_states,
-		    l_ptr->stats.sent_probes,
-		    l_ptr->stats.sent_nacks,
-		    l_ptr->stats.sent_acks,
-		    l_ptr->stats.retransmitted);
-	tipc_printf(&pb, "  Congestion bearer:%u link:%u  Send queue max:%u avg:%u\n",
-		    l_ptr->stats.bearer_congs,
-		    l_ptr->stats.link_congs,
-		    l_ptr->stats.max_queue_sz,
-		    l_ptr->stats.queue_sz_counts
-		    ? (l_ptr->stats.accu_queue_sz / l_ptr->stats.queue_sz_counts)
-		    : 0);
+
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  TX profile sample:%u packets  average:%u octets\n"
+			     "  0-64:%u%% -256:%u%% -1024:%u%% -4096:%u%% "
+			     "-16384:%u%% -32768:%u%% -66000:%u%%\n",
+			     s->msg_length_counts,
+			     s->msg_lengths_total / profile_total,
+			     percent(s->msg_length_profile[0], profile_total),
+			     percent(s->msg_length_profile[1], profile_total),
+			     percent(s->msg_length_profile[2], profile_total),
+			     percent(s->msg_length_profile[3], profile_total),
+			     percent(s->msg_length_profile[4], profile_total),
+			     percent(s->msg_length_profile[5], profile_total),
+			     percent(s->msg_length_profile[6], profile_total));
+
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  RX states:%u probes:%u naks:%u defs:%u"
+			     " dups:%u\n", s->recv_states, s->recv_probes,
+			     s->recv_nacks, s->deferred_recv, s->duplicates);
+
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  TX states:%u probes:%u naks:%u acks:%u"
+			     " dups:%u\n", s->sent_states, s->sent_probes,
+			     s->sent_nacks, s->sent_acks, s->retransmitted);
+
+	ret += tipc_snprintf(buf + ret, buf_size - ret,
+			     "  Congestion bearer:%u link:%u  Send queue"
+			     " max:%u avg:%u\n", s->bearer_congs, s->link_congs,
+			     s->max_queue_sz, s->queue_sz_counts ?
+			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
 
 	tipc_node_unlock(node);
 	read_unlock_bh(&tipc_net_lock);
-	return tipc_printbuf_validate(&pb);
+	return ret;
 }
 
-#define MAX_LINK_STATS_INFO 2000
-
 struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area, int req_tlv_space)
 {
 	struct sk_buff *buf;
 	struct tlv_desc *rep_tlv;
 	int str_len;
+	int pb_len;
+	char *pb;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_NAME))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(MAX_LINK_STATS_INFO));
+	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
 	if (!buf)
 		return NULL;
 
 	rep_tlv = (struct tlv_desc *)buf->data;
-
+	pb = TLV_DATA(rep_tlv);
+	pb_len = ULTRA_STRING_MAX_LEN;
 	str_len = tipc_link_stats((char *)TLV_DATA(req_tlv_area),
-				  (char *)TLV_DATA(rep_tlv), MAX_LINK_STATS_INFO);
+				  pb, pb_len);
 	if (!str_len) {
 		kfree_skb(buf);
 		return tipc_cfg_reply_error_string("link not found");
 	}
-
+	str_len += 1;	/* for "\0" */
 	skb_put(buf, TLV_SPACE(str_len));
 	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
 
diff --git a/net/tipc/log.c b/net/tipc/log.c
index d01e37a..fa7ce92 100644
--- a/net/tipc/log.c
+++ b/net/tipc/log.c
@@ -125,40 +125,6 @@ static int tipc_printbuf_empty(struct print_buf *pb)
 }
 
 /**
- * tipc_printbuf_validate - check for print buffer overflow
- * @pb: pointer to print buffer structure
- *
- * Verifies that a print buffer has captured all data written to it.
- * If data has been lost, linearize buffer and prepend an error message
- *
- * Returns length of print buffer data string (including trailing NUL)
- */
-int tipc_printbuf_validate(struct print_buf *pb)
-{
-	char *err = "\n\n*** PRINT BUFFER OVERFLOW ***\n\n";
-	char *cp_buf;
-	struct print_buf cb;
-
-	if (!pb->buf)
-		return 0;
-
-	if (pb->buf[pb->size - 1] == 0) {
-		cp_buf = kmalloc(pb->size, GFP_ATOMIC);
-		if (cp_buf) {
-			tipc_printbuf_init(&cb, cp_buf, pb->size);
-			tipc_printbuf_move(&cb, pb);
-			tipc_printbuf_move(pb, &cb);
-			kfree(cp_buf);
-			memcpy(pb->buf, err, strlen(err));
-		} else {
-			tipc_printbuf_reset(pb);
-			tipc_printf(pb, err);
-		}
-	}
-	return pb->crs - pb->buf + 1;
-}
-
-/**
  * tipc_printbuf_move - move print buffer contents to another print buffer
  * @pb_to: pointer to destination print buffer structure
  * @pb_from: pointer to source print buffer structure
@@ -204,23 +170,20 @@ static void tipc_printbuf_move(struct print_buf *pb_to,
 }
 
 /**
- * tipc_printf - append formatted output to print buffer
- * @pb: pointer to print buffer
+ * tipc_snprintf - append formatted output to print buffer
+ * @buf: pointer to print buffer
+ * @len: buffer length
  * @fmt: formatted info to be printed
  */
-void tipc_printf(struct print_buf *pb, const char *fmt, ...)
+int tipc_snprintf(char *buf, int len, const char *fmt, ...)
 {
 	int i;
 	va_list args;
-	char *buf;
-	int len;
 
-	buf = pb->crs;
-	len = pb->buf + pb->size - pb->crs;
 	va_start(args, fmt);
 	i = vscnprintf(buf, len, fmt, args);
 	va_end(args);
-	pb->crs += i;
+	return i;
 }
 
 /**
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 0b48fbb..0b7eaf1 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -753,19 +753,20 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 /**
  * subseq_list - print specified sub-sequence contents into the given buffer
  */
-static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
+static int subseq_list(struct sub_seq *sseq, char *buf, int len, u32 depth,
 			u32 index)
 {
 	char portIdStr[27];
 	const char *scope_str[] = {"", " zone", " cluster", " node"};
 	struct publication *publ;
 	struct name_info *info;
+	int ret;
 
-	tipc_printf(buf, "%-10u %-10u ", sseq->lower, sseq->upper);
+	ret = tipc_snprintf(buf, len, "%-10u %-10u ", sseq->lower, sseq->upper);
 
 	if (depth == 2) {
-		tipc_printf(buf, "\n");
-		return;
+		ret += tipc_snprintf(buf - ret, len + ret, "\n");
+		return ret;
 	}
 
 	info = sseq->info;
@@ -774,52 +775,58 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 		sprintf(portIdStr, "<%u.%u.%u:%u>",
 			 tipc_zone(publ->node), tipc_cluster(publ->node),
 			 tipc_node(publ->node), publ->ref);
-		tipc_printf(buf, "%-26s ", portIdStr);
+		ret += tipc_snprintf(buf + ret, len - ret, "%-26s ", portIdStr);
 		if (depth > 3) {
-			tipc_printf(buf, "%-10u %s", publ->key,
-				    scope_str[publ->scope]);
+			ret += tipc_snprintf(buf + ret, len - ret, "%-10u %s",
+					     publ->key, scope_str[publ->scope]);
 		}
 		if (!list_is_last(&publ->zone_list, &info->zone_list))
-			tipc_printf(buf, "\n%33s", " ");
+			ret += tipc_snprintf(buf + ret, len - ret,
+					     "\n%33s", " ");
 	};
 
-	tipc_printf(buf, "\n");
+	ret += tipc_snprintf(buf + ret, len - ret, "\n");
+	return ret;
 }
 
 /**
  * nameseq_list - print specified name sequence contents into the given buffer
  */
-static void nameseq_list(struct name_seq *seq, struct print_buf *buf, u32 depth,
+static int nameseq_list(struct name_seq *seq, char *buf, int len, u32 depth,
 			 u32 type, u32 lowbound, u32 upbound, u32 index)
 {
 	struct sub_seq *sseq;
 	char typearea[11];
+	int ret = 0;
 
 	if (seq->first_free == 0)
-		return;
+		return 0;
 
 	sprintf(typearea, "%-10u", seq->type);
 
 	if (depth == 1) {
-		tipc_printf(buf, "%s\n", typearea);
-		return;
+		ret += tipc_snprintf(buf, len, "%s\n", typearea);
+		return ret;
 	}
 
 	for (sseq = seq->sseqs; sseq != &seq->sseqs[seq->first_free]; sseq++) {
 		if ((lowbound <= sseq->upper) && (upbound >= sseq->lower)) {
-			tipc_printf(buf, "%s ", typearea);
+			ret += tipc_snprintf(buf + ret, len - ret, "%s ",
+					    typearea);
 			spin_lock_bh(&seq->lock);
-			subseq_list(sseq, buf, depth, index);
+			ret += subseq_list(sseq, buf + ret, len - ret,
+					  depth, index);
 			spin_unlock_bh(&seq->lock);
 			sprintf(typearea, "%10s", " ");
 		}
 	}
+	return ret;
 }
 
 /**
  * nametbl_header - print name table header into the given buffer
  */
-static void nametbl_header(struct print_buf *buf, u32 depth)
+static int nametbl_header(char *buf, int len, u32 depth)
 {
 	const char *header[] = {
 		"Type       ",
@@ -829,24 +836,27 @@ static void nametbl_header(struct print_buf *buf, u32 depth)
 	};
 
 	int i;
+	int ret = 0;
 
 	if (depth > 4)
 		depth = 4;
 	for (i = 0; i < depth; i++)
-		tipc_printf(buf, header[i]);
-	tipc_printf(buf, "\n");
+		ret += tipc_snprintf(buf + ret, len - ret, header[i]);
+	ret += tipc_snprintf(buf + ret, len - ret, "\n");
+	return ret;
 }
 
 /**
  * nametbl_list - print specified name table contents into the given buffer
  */
-static void nametbl_list(struct print_buf *buf, u32 depth_info,
+static int nametbl_list(char *buf, int len, u32 depth_info,
 			 u32 type, u32 lowbound, u32 upbound)
 {
 	struct hlist_head *seq_head;
 	struct hlist_node *seq_node;
 	struct name_seq *seq;
 	int all_types;
+	int ret = 0;
 	u32 depth;
 	u32 i;
 
@@ -854,65 +864,69 @@ static void nametbl_list(struct print_buf *buf, u32 depth_info,
 	depth = (depth_info & ~TIPC_NTQ_ALLTYPES);
 
 	if (depth == 0)
-		return;
+		return 0;
 
 	if (all_types) {
 		/* display all entries in name table to specified depth */
-		nametbl_header(buf, depth);
+		ret += nametbl_header(buf, len, depth);
 		lowbound = 0;
 		upbound = ~0;
 		for (i = 0; i < tipc_nametbl_size; i++) {
 			seq_head = &table.types[i];
 			hlist_for_each_entry(seq, seq_node, seq_head, ns_list) {
-				nameseq_list(seq, buf, depth, seq->type,
-					     lowbound, upbound, i);
+				ret += nameseq_list(seq, buf + ret, len - ret,
+						   depth, seq->type,
+						   lowbound, upbound, i);
 			}
 		}
 	} else {
 		/* display only the sequence that matches the specified type */
 		if (upbound < lowbound) {
-			tipc_printf(buf, "invalid name sequence specified\n");
-			return;
+			ret += tipc_snprintf(buf + ret, len - ret,
+					"invalid name sequence specified\n");
+			return ret;
 		}
-		nametbl_header(buf, depth);
+		ret += nametbl_header(buf + ret, len - ret, depth);
 		i = hash(type);
 		seq_head = &table.types[i];
 		hlist_for_each_entry(seq, seq_node, seq_head, ns_list) {
 			if (seq->type == type) {
-				nameseq_list(seq, buf, depth, type,
-					     lowbound, upbound, i);
+				ret += nameseq_list(seq, buf + ret, len - ret,
+						   depth, type,
+						   lowbound, upbound, i);
 				break;
 			}
 		}
 	}
+	return ret;
 }
 
-#define MAX_NAME_TBL_QUERY 32768
-
 struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space)
 {
 	struct sk_buff *buf;
 	struct tipc_name_table_query *argv;
 	struct tlv_desc *rep_tlv;
-	struct print_buf b;
+	char *pb;
+	int pb_len;
 	int str_len;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NAME_TBL_QUERY))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(MAX_NAME_TBL_QUERY));
+	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
 	if (!buf)
 		return NULL;
 
 	rep_tlv = (struct tlv_desc *)buf->data;
-	tipc_printbuf_init(&b, TLV_DATA(rep_tlv), MAX_NAME_TBL_QUERY);
+	pb = TLV_DATA(rep_tlv);
+	pb_len = ULTRA_STRING_MAX_LEN;
 	argv = (struct tipc_name_table_query *)TLV_DATA(req_tlv_area);
 	read_lock_bh(&tipc_nametbl_lock);
-	nametbl_list(&b, ntohl(argv->depth), ntohl(argv->type),
-		     ntohl(argv->lowbound), ntohl(argv->upbound));
+	str_len = nametbl_list(pb, pb_len, ntohl(argv->depth),
+			       ntohl(argv->type),
+			       ntohl(argv->lowbound), ntohl(argv->upbound));
 	read_unlock_bh(&tipc_nametbl_lock);
-	str_len = tipc_printbuf_validate(&b);
-
+	str_len += 1;	/* for "\0" */
 	skb_put(buf, TLV_SPACE(str_len));
 	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
 
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 5d374d7..cee4d24 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -581,67 +581,73 @@ exit:
 	kfree_skb(buf);
 }
 
-static void port_print(struct tipc_port *p_ptr, struct print_buf *buf, int full_id)
+static int port_print(struct tipc_port *p_ptr, char *buf, int len, int full_id)
 {
 	struct publication *publ;
+	int ret;
 
 	if (full_id)
-		tipc_printf(buf, "<%u.%u.%u:%u>:",
-			    tipc_zone(tipc_own_addr), tipc_cluster(tipc_own_addr),
-			    tipc_node(tipc_own_addr), p_ptr->ref);
+		ret = tipc_snprintf(buf, len, "<%u.%u.%u:%u>:",
+				    tipc_zone(tipc_own_addr),
+				    tipc_cluster(tipc_own_addr),
+				    tipc_node(tipc_own_addr), p_ptr->ref);
 	else
-		tipc_printf(buf, "%-10u:", p_ptr->ref);
+		ret = tipc_snprintf(buf, len, "%-10u:", p_ptr->ref);
 
 	if (p_ptr->connected) {
 		u32 dport = port_peerport(p_ptr);
 		u32 destnode = port_peernode(p_ptr);
 
-		tipc_printf(buf, " connected to <%u.%u.%u:%u>",
-			    tipc_zone(destnode), tipc_cluster(destnode),
-			    tipc_node(destnode), dport);
+		ret += tipc_snprintf(buf + ret, len - ret,
+				     " connected to <%u.%u.%u:%u>",
+				     tipc_zone(destnode),
+				     tipc_cluster(destnode),
+				     tipc_node(destnode), dport);
 		if (p_ptr->conn_type != 0)
-			tipc_printf(buf, " via {%u,%u}",
-				    p_ptr->conn_type,
-				    p_ptr->conn_instance);
+			ret += tipc_snprintf(buf + ret, len - ret,
+					     " via {%u,%u}", p_ptr->conn_type,
+					     p_ptr->conn_instance);
 	} else if (p_ptr->published) {
-		tipc_printf(buf, " bound to");
+		ret += tipc_snprintf(buf + ret, len - ret, " bound to");
 		list_for_each_entry(publ, &p_ptr->publications, pport_list) {
 			if (publ->lower == publ->upper)
-				tipc_printf(buf, " {%u,%u}", publ->type,
-					    publ->lower);
+				ret += tipc_snprintf(buf + ret, len - ret,
+						     " {%u,%u}", publ->type,
+						     publ->lower);
 			else
-				tipc_printf(buf, " {%u,%u,%u}", publ->type,
-					    publ->lower, publ->upper);
+				ret += tipc_snprintf(buf + ret, len - ret,
+						     " {%u,%u,%u}", publ->type,
+						     publ->lower, publ->upper);
 		}
 	}
-	tipc_printf(buf, "\n");
+	ret += tipc_snprintf(buf + ret, len - ret, "\n");
+	return ret;
 }
 
-#define MAX_PORT_QUERY 32768
-
 struct sk_buff *tipc_port_get_ports(void)
 {
 	struct sk_buff *buf;
 	struct tlv_desc *rep_tlv;
-	struct print_buf pb;
+	char *pb;
+	int pb_len;
 	struct tipc_port *p_ptr;
-	int str_len;
+	int str_len = 0;
 
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(MAX_PORT_QUERY));
+	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
 	if (!buf)
 		return NULL;
 	rep_tlv = (struct tlv_desc *)buf->data;
+	pb = TLV_DATA(rep_tlv);
+	pb_len = ULTRA_STRING_MAX_LEN;
 
-	tipc_printbuf_init(&pb, TLV_DATA(rep_tlv), MAX_PORT_QUERY);
 	spin_lock_bh(&tipc_port_list_lock);
 	list_for_each_entry(p_ptr, &ports, port_list) {
 		spin_lock_bh(p_ptr->lock);
-		port_print(p_ptr, &pb, 0);
+		str_len += port_print(p_ptr, pb, pb_len, 0);
 		spin_unlock_bh(p_ptr->lock);
 	}
 	spin_unlock_bh(&tipc_port_list_lock);
-	str_len = tipc_printbuf_validate(&pb);
-
+	str_len += 1;	/* for "\0" */
 	skb_put(buf, TLV_SPACE(str_len));
 	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
 
-- 
1.7.9.7
