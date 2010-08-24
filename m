From: Joe Perches <joe@perches.com>
Subject: net/sctp: Use pr_fmt and pr_<level>
Date: Tue, 24 Aug 2010 16:21:08 -0700
Message-ID: <1282692068.25208.11.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change SCTP_DEBUG_PRINTK and SCTP_DEBUG_PRINTK_IPADDR to
use do { print } while (0) guards.
Add SCTP_DEBUG_PRINTK_CONT to fix errors in log when
lines were continued.
Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Add a missing newline in "Failed bind hash alloc"

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/sctp/sctp.h  |   48 ++++++++++++++++++++++++++++-----------------
 net/sctp/associola.c     |    2 +
 net/sctp/chunk.c         |    2 +
 net/sctp/inqueue.c       |    2 +
 net/sctp/ipv6.c          |    4 ++-
 net/sctp/objcnt.c        |    5 ++-
 net/sctp/output.c        |    2 +
 net/sctp/outqueue.c      |   34 +++++++++++++++++---------------
 net/sctp/probe.c         |    4 ++-
 net/sctp/protocol.c      |   17 +++++++--------
 net/sctp/sm_make_chunk.c |    2 +
 net/sctp/sm_sideeffect.c |   21 +++++++++----------
 net/sctp/sm_statefuns.c  |   20 +++++++++---------
 net/sctp/sm_statetable.c |   42 ++++++++++++++++++++--------------------
 net/sctp/socket.c        |   39 ++++++++++++++-----------------------
 net/sctp/transport.c     |    9 ++++---
 16 files changed, 136 insertions(+), 117 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 65946bc..2cb3980 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -275,24 +275,35 @@ struct sctp_mib {
 /* Print debugging messages.  */
 #if SCTP_DEBUG
 extern int sctp_debug_flag;
-#define SCTP_DEBUG_PRINTK(whatever...) \
-	((void) (sctp_debug_flag && printk(KERN_DEBUG whatever)))
-#define SCTP_DEBUG_PRINTK_IPADDR(lead, trail, leadparm, saddr, otherparms...) \
-	if (sctp_debug_flag) { \
-		if (saddr->sa.sa_family == AF_INET6) { \
-			printk(KERN_DEBUG \
-			       lead "%pI6" trail, \
-			       leadparm, \
-			       &saddr->v6.sin6_addr, \
-			       otherparms); \
-		} else { \
-			printk(KERN_DEBUG \
-			       lead "%pI4" trail, \
-			       leadparm, \
-			       &saddr->v4.sin_addr.s_addr, \
-			       otherparms); \
-		} \
-	}
+#define SCTP_DEBUG_PRINTK(fmt, args...)			\
+do {							\
+	if (sctp_debug_flag)				\
+		printk(KERN_DEBUG pr_fmt(fmt), ##args);	\
+} while (0)
+#define SCTP_DEBUG_PRINTK_CONT(fmt, args...)		\
+do {							\
+	if (sctp_debug_flag)				\
+		pr_cont(fmt, ##args);			\
+} while (0)
+#define SCTP_DEBUG_PRINTK_IPADDR(fmt_lead, fmt_trail,			\
+				 args_lead, saddr, args_trail...)	\
+do {									\
+	if (sctp_debug_flag) {						\
+		if (saddr->sa.sa_family == AF_INET6) {			\
+			printk(KERN_DEBUG				\
+			       pr_fmt(fmt_lead "%pI6" fmt_trail),	\
+			       args_lead,				\
+			       &saddr->v6.sin6_addr,			\
+			       args_trail);				\
+		} else {						\
+			printk(KERN_DEBUG				\
+			       pr_fmt(fmt_lead "%pI4" fmt_trail),	\
+			       args_lead,				\
+			       &saddr->v4.sin_addr.s_addr,		\
+			       args_trail);				\
+		}							\
+	}								\
+} while (0)
 #define SCTP_ENABLE_DEBUG { sctp_debug_flag = 1; }
 #define SCTP_DISABLE_DEBUG { sctp_debug_flag = 0; }
 
@@ -306,6 +317,7 @@ extern int sctp_debug_flag;
 #else	/* SCTP_DEBUG */
 
 #define SCTP_DEBUG_PRINTK(whatever...)
+#define SCTP_DEBUG_PRINTK_CONT(fmt, args...)
 #define SCTP_DEBUG_PRINTK_IPADDR(whatever...)
 #define SCTP_ENABLE_DEBUG
 #define SCTP_DISABLE_DEBUG
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 0b85e52..5f1fb8b 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -48,6 +48,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/fcntl.h>
 #include <linux/poll.h>
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 476caaf..6c85564 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -37,6 +37,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/net.h>
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index ccb6dc4..397296f 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -43,6 +43,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 #include <linux/interrupt.h>
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 7326891..95e0c8e 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -47,6 +47,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -336,7 +338,7 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
 		memcpy(saddr, baddr, sizeof(union sctp_addr));
 		SCTP_DEBUG_PRINTK("saddr: %pI6\n", &saddr->v6.sin6_addr);
 	} else {
-		printk(KERN_ERR "%s: asoc:%p Could not find a valid source "
+		pr_err("%s: asoc:%p Could not find a valid source "
 		       "address for the dest:%pI6\n",
 		       __func__, asoc, &daddr->v6.sin6_addr);
 	}
diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index f73ec0e..8ef8e7d 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -38,6 +38,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <net/sctp/sctp.h>
 
@@ -134,8 +136,7 @@ void sctp_dbg_objcnt_init(void)
 	ent = proc_create("sctp_dbg_objcnt", 0,
 			  proc_net_sctp, &sctp_objcnt_ops);
 	if (!ent)
-		printk(KERN_WARNING
-			"sctp_dbg_objcnt: Unable to create /proc entry.\n");
+		pr_warn("sctp_dbg_objcnt: Unable to create /proc entry.\n");
 }
 
 /* Cleanup the objcount entry in the proc filesystem.  */
diff --git a/net/sctp/output.c b/net/sctp/output.c
index a646681..901764b 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -41,6 +41,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/wait.h>
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index c04b2eb..8c6d379 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -46,6 +46,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/list.h>   /* For struct list_head */
 #include <linux/socket.h>
@@ -1463,23 +1465,23 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 					/* Display the end of the
 					 * current range.
 					 */
-					SCTP_DEBUG_PRINTK("-%08x",
-							  dbg_last_ack_tsn);
+					SCTP_DEBUG_PRINTK_CONT("-%08x",
+							       dbg_last_ack_tsn);
 				}
 
 				/* Start a new range.  */
-				SCTP_DEBUG_PRINTK(",%08x", tsn);
+				SCTP_DEBUG_PRINTK_CONT(",%08x", tsn);
 				dbg_ack_tsn = tsn;
 				break;
 
 			case 1:	/* The last TSN was NOT ACKed. */
 				if (dbg_last_kept_tsn != dbg_kept_tsn) {
 					/* Display the end of current range. */
-					SCTP_DEBUG_PRINTK("-%08x",
-							  dbg_last_kept_tsn);
+					SCTP_DEBUG_PRINTK_CONT("-%08x",
+							       dbg_last_kept_tsn);
 				}
 
-				SCTP_DEBUG_PRINTK("\n");
+				SCTP_DEBUG_PRINTK_CONT("\n");
 
 				/* FALL THROUGH... */
 			default:
@@ -1526,18 +1528,18 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 					break;
 
 				if (dbg_last_kept_tsn != dbg_kept_tsn)
-					SCTP_DEBUG_PRINTK("-%08x",
-							  dbg_last_kept_tsn);
+					SCTP_DEBUG_PRINTK_CONT("-%08x",
+							       dbg_last_kept_tsn);
 
-				SCTP_DEBUG_PRINTK(",%08x", tsn);
+				SCTP_DEBUG_PRINTK_CONT(",%08x", tsn);
 				dbg_kept_tsn = tsn;
 				break;
 
 			case 0:
 				if (dbg_last_ack_tsn != dbg_ack_tsn)
-					SCTP_DEBUG_PRINTK("-%08x",
-							  dbg_last_ack_tsn);
-				SCTP_DEBUG_PRINTK("\n");
+					SCTP_DEBUG_PRINTK_CONT("-%08x",
+							       dbg_last_ack_tsn);
+				SCTP_DEBUG_PRINTK_CONT("\n");
 
 				/* FALL THROUGH... */
 			default:
@@ -1556,17 +1558,17 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 	switch (dbg_prt_state) {
 	case 0:
 		if (dbg_last_ack_tsn != dbg_ack_tsn) {
-			SCTP_DEBUG_PRINTK("-%08x\n", dbg_last_ack_tsn);
+			SCTP_DEBUG_PRINTK_CONT("-%08x\n", dbg_last_ack_tsn);
 		} else {
-			SCTP_DEBUG_PRINTK("\n");
+			SCTP_DEBUG_PRINTK_CONT("\n");
 		}
 	break;
 
 	case 1:
 		if (dbg_last_kept_tsn != dbg_kept_tsn) {
-			SCTP_DEBUG_PRINTK("-%08x\n", dbg_last_kept_tsn);
+			SCTP_DEBUG_PRINTK_CONT("-%08x\n", dbg_last_kept_tsn);
 		} else {
-			SCTP_DEBUG_PRINTK("\n");
+			SCTP_DEBUG_PRINTK_CONT("\n");
 		}
 	}
 #endif /* SCTP_DEBUG */
diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index db3a42b..2e63e9d 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -22,6 +22,8 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/kprobes.h>
 #include <linux/socket.h>
@@ -192,7 +194,7 @@ static __init int sctpprobe_init(void)
 	if (ret)
 		goto remove_proc;
 
-	pr_info("SCTP probe registered (port=%d)\n", port);
+	pr_info("probe registered (port=%d)\n", port);
 
 	return 0;
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 5027b83..f774e65 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -46,6 +46,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
@@ -707,8 +709,7 @@ static int sctp_ctl_sock_init(void)
 					   &init_net);
 
 	if (err < 0) {
-		printk(KERN_ERR
-		       "SCTP: Failed to create the SCTP control socket.\n");
+		pr_err("Failed to create the SCTP control socket\n");
 		return err;
 	}
 	return 0;
@@ -1206,7 +1207,7 @@ SCTP_STATIC __init int sctp_init(void)
 					__get_free_pages(GFP_ATOMIC, order);
 	} while (!sctp_assoc_hashtable && --order > 0);
 	if (!sctp_assoc_hashtable) {
-		printk(KERN_ERR "SCTP: Failed association hash alloc.\n");
+		pr_err("Failed association hash alloc\n");
 		status = -ENOMEM;
 		goto err_ahash_alloc;
 	}
@@ -1220,7 +1221,7 @@ SCTP_STATIC __init int sctp_init(void)
 	sctp_ep_hashtable = (struct sctp_hashbucket *)
 		kmalloc(64 * sizeof(struct sctp_hashbucket), GFP_KERNEL);
 	if (!sctp_ep_hashtable) {
-		printk(KERN_ERR "SCTP: Failed endpoint_hash alloc.\n");
+		pr_err("Failed endpoint_hash alloc\n");
 		status = -ENOMEM;
 		goto err_ehash_alloc;
 	}
@@ -1239,7 +1240,7 @@ SCTP_STATIC __init int sctp_init(void)
 					__get_free_pages(GFP_ATOMIC, order);
 	} while (!sctp_port_hashtable && --order > 0);
 	if (!sctp_port_hashtable) {
-		printk(KERN_ERR "SCTP: Failed bind hash alloc.");
+		pr_err("Failed bind hash alloc\n");
 		status = -ENOMEM;
 		goto err_bhash_alloc;
 	}
@@ -1248,8 +1249,7 @@ SCTP_STATIC __init int sctp_init(void)
 		INIT_HLIST_HEAD(&sctp_port_hashtable[i].chain);
 	}
 
-	printk(KERN_INFO "SCTP: Hash tables configured "
-			 "(established %d bind %d)\n",
+	pr_info("Hash tables configured (established %d bind %d)\n",
 		sctp_assoc_hashsize, sctp_port_hashsize);
 
 	/* Disable ADDIP by default. */
@@ -1290,8 +1290,7 @@ SCTP_STATIC __init int sctp_init(void)
 
 	/* Initialize the control inode/socket for handling OOTB packets.  */
 	if ((status = sctp_ctl_sock_init())) {
-		printk (KERN_ERR
-			"SCTP: Failed to initialize the SCTP control sock.\n");
+		pr_err("Failed to initialize the SCTP control sock\n");
 		goto err_ctl_sock_init;
 	}
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 246f929..2cc46f0 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -50,6 +50,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/ip.h>
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index f5e5e27..b21b218 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -47,6 +47,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/skbuff.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -1146,26 +1148,23 @@ static int sctp_side_effects(sctp_event_t event_type, sctp_subtype_t subtype,
 
 	case SCTP_DISPOSITION_VIOLATION:
 		if (net_ratelimit())
-			printk(KERN_ERR "sctp protocol violation state %d "
-			       "chunkid %d\n", state, subtype.chunk);
+			pr_err("protocol violation state %d chunkid %d\n",
+			       state, subtype.chunk);
 		break;
 
 	case SCTP_DISPOSITION_NOT_IMPL:
-		printk(KERN_WARNING "sctp unimplemented feature in state %d, "
-		       "event_type %d, event_id %d\n",
-		       state, event_type, subtype.chunk);
+		pr_warn("unimplemented feature in state %d, event_type %d, event_id %d\n",
+			state, event_type, subtype.chunk);
 		break;
 
 	case SCTP_DISPOSITION_BUG:
-		printk(KERN_ERR "sctp bug in state %d, "
-		       "event_type %d, event_id %d\n",
+		pr_err("bug in state %d, event_type %d, event_id %d\n",
 		       state, event_type, subtype.chunk);
 		BUG();
 		break;
 
 	default:
-		printk(KERN_ERR "sctp impossible disposition %d "
-		       "in state %d, event_type %d, event_id %d\n",
+		pr_err("impossible disposition %d in state %d, event_type %d, event_id %d\n",
 		       status, state, event_type, subtype.chunk);
 		BUG();
 		break;
@@ -1679,8 +1678,8 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 			sctp_cmd_send_asconf(asoc);
 			break;
 		default:
-			printk(KERN_WARNING "Impossible command: %u, %p\n",
-			       cmd->verb, cmd->obj.ptr);
+			pr_warn("Impossible command: %u, %p\n",
+				cmd->verb, cmd->obj.ptr);
 			break;
 		}
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 24b2cd5..8b28443 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -50,6 +50,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/ip.h>
@@ -1138,18 +1140,16 @@ sctp_disposition_t sctp_sf_backbeat_8_3(const struct sctp_endpoint *ep,
 	if (unlikely(!link)) {
 		if (from_addr.sa.sa_family == AF_INET6) {
 			if (net_ratelimit())
-				printk(KERN_WARNING
-				    "%s association %p could not find address %pI6\n",
-				    __func__,
-				    asoc,
-				    &from_addr.v6.sin6_addr);
+				pr_warn("%s association %p could not find address %pI6\n",
+					__func__,
+					asoc,
+					&from_addr.v6.sin6_addr);
 		} else {
 			if (net_ratelimit())
-				printk(KERN_WARNING
-				    "%s association %p could not find address %pI4\n",
-				    __func__,
-				    asoc,
-				    &from_addr.v4.sin_addr.s_addr);
+				pr_warn("%s association %p could not find address %pI4\n",
+					__func__,
+					asoc,
+					&from_addr.v4.sin_addr.s_addr);
 		}
 		return SCTP_DISPOSITION_DISCARD;
 	}
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 6d9b3aa..546d4387 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -46,6 +46,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/skbuff.h>
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
@@ -66,15 +68,19 @@ static const sctp_sm_table_entry_t bug = {
 	.name = "sctp_sf_bug"
 };
 
-#define DO_LOOKUP(_max, _type, _table) \
-	if ((event_subtype._type > (_max))) { \
-		printk(KERN_WARNING \
-		       "sctp table %p possible attack:" \
-		       " event %d exceeds max %d\n", \
-		       _table, event_subtype._type, _max); \
-		return &bug; \
-	} \
-	return &_table[event_subtype._type][(int)state];
+#define DO_LOOKUP(_max, _type, _table)					\
+({									\
+	const sctp_sm_table_entry_t *rtn;				\
+									\
+	if ((event_subtype._type > (_max))) {				\
+		pr_warn("table %p possible attack: event %d exceeds max %d\n", \
+			_table, event_subtype._type, _max);		\
+	        rtn = &bug;						\
+	} else								\
+		rtn = &_table[event_subtype._type][(int)state];		\
+									\
+	rtn;								\
+})
 
 const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 						  sctp_state_t state,
@@ -83,21 +89,15 @@ const sctp_sm_table_entry_t *sctp_sm_lookup_event(sctp_event_t event_type,
 	switch (event_type) {
 	case SCTP_EVENT_T_CHUNK:
 		return sctp_chunk_event_lookup(event_subtype.chunk, state);
-		break;
 	case SCTP_EVENT_T_TIMEOUT:
-		DO_LOOKUP(SCTP_EVENT_TIMEOUT_MAX, timeout,
-			  timeout_event_table);
-		break;
-
+		return DO_LOOKUP(SCTP_EVENT_TIMEOUT_MAX, timeout,
+				 timeout_event_table);
 	case SCTP_EVENT_T_OTHER:
-		DO_LOOKUP(SCTP_EVENT_OTHER_MAX, other, other_event_table);
-		break;
-
+		return DO_LOOKUP(SCTP_EVENT_OTHER_MAX, other,
+				 other_event_table);
 	case SCTP_EVENT_T_PRIMITIVE:
-		DO_LOOKUP(SCTP_EVENT_PRIMITIVE_MAX, primitive,
-			  primitive_event_table);
-		break;
-
+		return DO_LOOKUP(SCTP_EVENT_PRIMITIVE_MAX, primitive,
+				 primitive_event_table);
 	default:
 		/* Yikes!  We got an illegal event type.  */
 		return &bug;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ca44917..f4bec27 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -57,6 +57,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/wait.h>
@@ -2458,9 +2460,8 @@ static int sctp_setsockopt_delayed_ack(struct sock *sk,
 		if (params.sack_delay == 0 && params.sack_freq == 0)
 			return 0;
 	} else if (optlen == sizeof(struct sctp_assoc_value)) {
-		printk(KERN_WARNING "SCTP: Use of struct sctp_assoc_value "
-		       "in delayed_ack socket option deprecated\n");
-		printk(KERN_WARNING "SCTP: Use struct sctp_sack_info instead\n");
+		pr_warn("Use of struct sctp_assoc_value in delayed_ack socket option deprecated\n");
+		pr_warn("Use struct sctp_sack_info instead\n");
 		if (copy_from_user(&params, optval, optlen))
 			return -EFAULT;
 
@@ -2868,10 +2869,8 @@ static int sctp_setsockopt_maxseg(struct sock *sk, char __user *optval, unsigned
 	int val;
 
 	if (optlen == sizeof(int)) {
-		printk(KERN_WARNING
-		   "SCTP: Use of int in maxseg socket option deprecated\n");
-		printk(KERN_WARNING
-		   "SCTP: Use struct sctp_assoc_value instead\n");
+		pr_warn("Use of int in maxseg socket option deprecated\n");
+		pr_warn("Use struct sctp_assoc_value instead\n");
 		if (copy_from_user(&val, optval, optlen))
 			return -EFAULT;
 		params.assoc_id = 0;
@@ -3121,10 +3120,8 @@ static int sctp_setsockopt_maxburst(struct sock *sk,
 	int assoc_id = 0;
 
 	if (optlen == sizeof(int)) {
-		printk(KERN_WARNING
-		   "SCTP: Use of int in max_burst socket option deprecated\n");
-		printk(KERN_WARNING
-		   "SCTP: Use struct sctp_assoc_value instead\n");
+		pr_warn("Use of int in max_burst socket option deprecated\n");
+		pr_warn("Use struct sctp_assoc_value instead\n");
 		if (copy_from_user(&val, optval, optlen))
 			return -EFAULT;
 	} else if (optlen == sizeof(struct sctp_assoc_value)) {
@@ -4281,9 +4278,8 @@ static int sctp_getsockopt_delayed_ack(struct sock *sk, int len,
 		if (copy_from_user(&params, optval, len))
 			return -EFAULT;
 	} else if (len == sizeof(struct sctp_assoc_value)) {
-		printk(KERN_WARNING "SCTP: Use of struct sctp_assoc_value "
-		       "in delayed_ack socket option deprecated\n");
-		printk(KERN_WARNING "SCTP: Use struct sctp_sack_info instead\n");
+		pr_warn("Use of struct sctp_assoc_value in delayed_ack socket option deprecated\n");
+		pr_warn("Use struct sctp_sack_info instead\n");
 		if (copy_from_user(&params, optval, len))
 			return -EFAULT;
 	} else
@@ -4929,10 +4925,8 @@ static int sctp_getsockopt_maxseg(struct sock *sk, int len,
 	struct sctp_association *asoc;
 
 	if (len == sizeof(int)) {
-		printk(KERN_WARNING
-		   "SCTP: Use of int in maxseg socket option deprecated\n");
-		printk(KERN_WARNING
-		   "SCTP: Use struct sctp_assoc_value instead\n");
+		pr_warn("Use of int in maxseg socket option deprecated\n");
+		pr_warn("Use struct sctp_assoc_value instead\n");
 		params.assoc_id = 0;
 	} else if (len >= sizeof(struct sctp_assoc_value)) {
 		len = sizeof(struct sctp_assoc_value);
@@ -5023,10 +5017,8 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
 	struct sctp_association *asoc;
 
 	if (len == sizeof(int)) {
-		printk(KERN_WARNING
-		   "SCTP: Use of int in max_burst socket option deprecated\n");
-		printk(KERN_WARNING
-		   "SCTP: Use struct sctp_assoc_value instead\n");
+		pr_warn("Use of int in max_burst socket option deprecated\n");
+		pr_warn("Use struct sctp_assoc_value instead\n");
 		params.assoc_id = 0;
 	} else if (len >= sizeof(struct sctp_assoc_value)) {
 		len = sizeof(struct sctp_assoc_value);
@@ -5586,8 +5578,7 @@ SCTP_STATIC int sctp_listen_start(struct sock *sk, int backlog)
 		tfm = crypto_alloc_hash(sctp_hmac_alg, 0, CRYPTO_ALG_ASYNC);
 		if (IS_ERR(tfm)) {
 			if (net_ratelimit()) {
-				printk(KERN_INFO
-				       "SCTP: failed to load transform for %s: %ld\n",
+				pr_info("failed to load transform for %s: %ld\n",
 					sctp_hmac_alg, PTR_ERR(tfm));
 			}
 			return -ENOSYS;
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 132046c..d3ae493 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -48,6 +48,8 @@
  * be incorporated into the next SCTP release.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/slab.h>
 #include <linux/types.h>
 #include <linux/random.h>
@@ -244,10 +246,9 @@ void sctp_transport_update_pmtu(struct sctp_transport *t, u32 pmtu)
 	struct dst_entry *dst;
 
 	if (unlikely(pmtu < SCTP_DEFAULT_MINSEGMENT)) {
-		printk(KERN_WARNING "%s: Reported pmtu %d too low, "
-		       "using default minimum of %d\n",
-		       __func__, pmtu,
-		       SCTP_DEFAULT_MINSEGMENT);
+		pr_warn("%s: Reported pmtu %d too low, using default minimum of %d\n",
+			__func__, pmtu,
+			SCTP_DEFAULT_MINSEGMENT);
 		/* Use default minimum segment size and disable
 		 * pmtu discovery on this transport.
 		 */
