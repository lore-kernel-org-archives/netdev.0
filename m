From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/4] [PKT_SCHED] Allow socket attributes to be matched on via meta ematch
Date: Fri, 03 Jun 2005 23:12:43 +0200
Message-ID: <20050603211315.677553000@axs>
References: <20050603211241.593114000@axs>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline; filename=ematch_meta_sk
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adds meta collectors for all socket attributes that make sense
to be filtered upon. Some of them are only useful for debugging
but having them doesn't hurt.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: ematch/net/sched/em_meta.c
===================================================================
--- ematch.orig/net/sched/em_meta.c
+++ ematch/net/sched/em_meta.c
@@ -32,7 +32,7 @@
  * 	      +-----------+                           +-----------+
  * 	            |                                       |
  * 	            ---> meta_ops[INT][INDEV](...)          |
- *                            |                            |
+ *	                      |                             |
  * 	            -----------                             |
  * 	            V                                       V
  * 	      +-----------+                           +-----------+
@@ -70,6 +70,7 @@
 #include <net/dst.h>
 #include <net/route.h>
 #include <net/pkt_cls.h>
+#include <net/sock.h>
 
 struct meta_obj
 {
@@ -284,6 +285,214 @@ META_COLLECTOR(int_rtiif)
 }
 
 /**************************************************************************
+ * Socket Attributes
+ **************************************************************************/
+
+#define SKIP_NONLOCAL(skb)			\
+	if (unlikely(skb->sk == NULL)) {	\
+		*err = -1;			\
+		return;				\
+	}
+
+META_COLLECTOR(int_sk_family)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_family;
+}
+
+META_COLLECTOR(int_sk_state)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_state;
+}
+
+META_COLLECTOR(int_sk_reuse)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_reuse;
+}
+
+META_COLLECTOR(int_sk_bound_if)
+{
+	SKIP_NONLOCAL(skb);
+	/* No error if bound_dev_if is 0, legal userspace check */
+	dst->value = skb->sk->sk_bound_dev_if;
+}
+
+META_COLLECTOR(var_sk_bound_if)
+{
+	SKIP_NONLOCAL(skb);
+
+	 if (skb->sk->sk_bound_dev_if == 0) {
+		dst->value = (unsigned long) "any";
+		dst->len = 3;
+	 } else  {
+		struct net_device *dev;
+		
+		dev = dev_get_by_index(skb->sk->sk_bound_dev_if);
+		*err = var_dev(dev, dst);
+		if (dev)
+			dev_put(dev);
+	 }
+}
+
+META_COLLECTOR(int_sk_refcnt)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = atomic_read(&skb->sk->sk_refcnt);
+}
+
+META_COLLECTOR(int_sk_rcvbuf)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_rcvbuf;
+}
+
+META_COLLECTOR(int_sk_shutdown)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_shutdown;
+}
+
+META_COLLECTOR(int_sk_proto)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_protocol;
+}
+
+META_COLLECTOR(int_sk_type)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_type;
+}
+
+META_COLLECTOR(int_sk_rmem_alloc)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = atomic_read(&skb->sk->sk_rmem_alloc);
+}
+
+META_COLLECTOR(int_sk_wmem_alloc)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = atomic_read(&skb->sk->sk_wmem_alloc);
+}
+
+META_COLLECTOR(int_sk_omem_alloc)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = atomic_read(&skb->sk->sk_omem_alloc);
+}
+
+META_COLLECTOR(int_sk_rcv_qlen)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_receive_queue.qlen;
+}
+
+META_COLLECTOR(int_sk_snd_qlen)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_write_queue.qlen;
+}
+
+META_COLLECTOR(int_sk_wmem_queued)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_wmem_queued;
+}
+
+META_COLLECTOR(int_sk_fwd_alloc)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_forward_alloc;
+}
+
+META_COLLECTOR(int_sk_sndbuf)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_sndbuf;
+}
+
+META_COLLECTOR(int_sk_alloc)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_allocation;
+}
+
+META_COLLECTOR(int_sk_route_caps)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_route_caps;
+}
+
+META_COLLECTOR(int_sk_hashent)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_hashent;
+}
+
+META_COLLECTOR(int_sk_lingertime)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_lingertime / HZ;
+}
+
+META_COLLECTOR(int_sk_err_qlen)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_error_queue.qlen;
+}
+
+META_COLLECTOR(int_sk_ack_bl)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_ack_backlog;
+}
+
+META_COLLECTOR(int_sk_max_ack_bl)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_max_ack_backlog;
+}
+
+META_COLLECTOR(int_sk_prio)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_priority;
+}
+
+META_COLLECTOR(int_sk_rcvlowat)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_rcvlowat;
+}
+
+META_COLLECTOR(int_sk_rcvtimeo)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_rcvtimeo / HZ;
+}
+
+META_COLLECTOR(int_sk_sndtimeo)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_sndtimeo / HZ;
+}
+
+META_COLLECTOR(int_sk_sendmsg_off)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_sndmsg_off;
+}
+
+META_COLLECTOR(int_sk_write_pend)
+{
+	SKIP_NONLOCAL(skb);
+	dst->value = skb->sk->sk_write_pending;
+}
+
+/**************************************************************************
  * Meta value collectors assignment table
  **************************************************************************/
 
@@ -293,41 +502,75 @@ struct meta_ops
 			       struct meta_value *, struct meta_obj *, int *);
 };
 
+#define META_ID(name) TCF_META_ID_##name
+#define META_FUNC(name) { .get = meta_##name }
+
 /* Meta value operations table listing all meta value collectors and
  * assigns them to a type and meta id. */
 static struct meta_ops __meta_ops[TCF_META_TYPE_MAX+1][TCF_META_ID_MAX+1] = {
 	[TCF_META_TYPE_VAR] = {
-		[TCF_META_ID_DEV]	= { .get = meta_var_dev },
-		[TCF_META_ID_INDEV]	= { .get = meta_var_indev },
-		[TCF_META_ID_REALDEV]	= { .get = meta_var_realdev }
+		[META_ID(DEV)]			= META_FUNC(var_dev),
+		[META_ID(INDEV)]		= META_FUNC(var_indev),
+		[META_ID(REALDEV)]		= META_FUNC(var_realdev),
+		[META_ID(SK_BOUND_IF)] 		= META_FUNC(var_sk_bound_if),
 	},
 	[TCF_META_TYPE_INT] = {
-		[TCF_META_ID_RANDOM]	= { .get = meta_int_random },
-		[TCF_META_ID_LOADAVG_0]	= { .get = meta_int_loadavg_0 },
-		[TCF_META_ID_LOADAVG_1]	= { .get = meta_int_loadavg_1 },
-		[TCF_META_ID_LOADAVG_2]	= { .get = meta_int_loadavg_2 },
-		[TCF_META_ID_DEV]	= { .get = meta_int_dev },
-		[TCF_META_ID_INDEV]	= { .get = meta_int_indev },
-		[TCF_META_ID_REALDEV]	= { .get = meta_int_realdev },
-		[TCF_META_ID_PRIORITY]	= { .get = meta_int_priority },
-		[TCF_META_ID_PROTOCOL]	= { .get = meta_int_protocol },
-		[TCF_META_ID_SECURITY]	= { .get = meta_int_security },
-		[TCF_META_ID_PKTTYPE]	= { .get = meta_int_pkttype },
-		[TCF_META_ID_PKTLEN]	= { .get = meta_int_pktlen },
-		[TCF_META_ID_DATALEN]	= { .get = meta_int_datalen },
-		[TCF_META_ID_MACLEN]	= { .get = meta_int_maclen },
+		[META_ID(RANDOM)]		= META_FUNC(int_random),
+		[META_ID(LOADAVG_0)]		= META_FUNC(int_loadavg_0),
+		[META_ID(LOADAVG_1)]		= META_FUNC(int_loadavg_1),
+		[META_ID(LOADAVG_2)]		= META_FUNC(int_loadavg_2),
+		[META_ID(DEV)]			= META_FUNC(int_dev),
+		[META_ID(INDEV)]		= META_FUNC(int_indev),
+		[META_ID(REALDEV)]		= META_FUNC(int_realdev),
+		[META_ID(PRIORITY)]		= META_FUNC(int_priority),
+		[META_ID(PROTOCOL)]		= META_FUNC(int_protocol),
+		[META_ID(SECURITY)]		= META_FUNC(int_security),
+		[META_ID(PKTTYPE)]		= META_FUNC(int_pkttype),
+		[META_ID(PKTLEN)]		= META_FUNC(int_pktlen),
+		[META_ID(DATALEN)]		= META_FUNC(int_datalen),
+		[META_ID(MACLEN)]		= META_FUNC(int_maclen),
 #ifdef CONFIG_NETFILTER
-		[TCF_META_ID_NFMARK]	= { .get = meta_int_nfmark },
+		[META_ID(NFMARK)]		= META_FUNC(int_nfmark),
 #endif
-		[TCF_META_ID_TCINDEX]	= { .get = meta_int_tcindex },
+		[META_ID(TCINDEX)]		= META_FUNC(int_tcindex),
 #ifdef CONFIG_NET_CLS_ACT
-		[TCF_META_ID_TCVERDICT]	= { .get = meta_int_tcverd },
-		[TCF_META_ID_TCCLASSID]	= { .get = meta_int_tcclassid },
+		[META_ID(TCVERDICT)]		= META_FUNC(int_tcverd),
+		[META_ID(TCCLASSID)]		= META_FUNC(int_tcclassid),
 #endif
 #ifdef CONFIG_NET_CLS_ROUTE
-		[TCF_META_ID_RTCLASSID]	= { .get = meta_int_rtclassid },
+		[META_ID(RTCLASSID)]		= META_FUNC(int_rtclassid),
 #endif
-		[TCF_META_ID_RTIIF]	= { .get = meta_int_rtiif }
+		[META_ID(RTIIF)]		= META_FUNC(int_rtiif),
+		[META_ID(SK_FAMILY)]		= META_FUNC(int_sk_family),
+		[META_ID(SK_STATE)]		= META_FUNC(int_sk_state),
+		[META_ID(SK_REUSE)]		= META_FUNC(int_sk_reuse),
+		[META_ID(SK_BOUND_IF)]		= META_FUNC(int_sk_bound_if),
+		[META_ID(SK_REFCNT)]		= META_FUNC(int_sk_refcnt),
+		[META_ID(SK_RCVBUF)]		= META_FUNC(int_sk_rcvbuf),
+		[META_ID(SK_SNDBUF)]		= META_FUNC(int_sk_sndbuf),
+		[META_ID(SK_SHUTDOWN)]		= META_FUNC(int_sk_shutdown),
+		[META_ID(SK_PROTO)]		= META_FUNC(int_sk_proto),
+		[META_ID(SK_TYPE)]		= META_FUNC(int_sk_type),
+		[META_ID(SK_RMEM_ALLOC)]	= META_FUNC(int_sk_rmem_alloc),
+		[META_ID(SK_WMEM_ALLOC)]	= META_FUNC(int_sk_wmem_alloc),
+		[META_ID(SK_OMEM_ALLOC)]	= META_FUNC(int_sk_omem_alloc),
+		[META_ID(SK_WMEM_QUEUED)]	= META_FUNC(int_sk_wmem_queued),
+		[META_ID(SK_RCV_QLEN)]		= META_FUNC(int_sk_rcv_qlen),
+		[META_ID(SK_SND_QLEN)]		= META_FUNC(int_sk_snd_qlen),
+		[META_ID(SK_ERR_QLEN)]		= META_FUNC(int_sk_err_qlen),
+		[META_ID(SK_FORWARD_ALLOCS)]	= META_FUNC(int_sk_fwd_alloc),
+		[META_ID(SK_ALLOCS)]		= META_FUNC(int_sk_alloc),
+		[META_ID(SK_ROUTE_CAPS)]	= META_FUNC(int_sk_route_caps),
+		[META_ID(SK_HASHENT)]		= META_FUNC(int_sk_hashent),
+		[META_ID(SK_LINGERTIME)]	= META_FUNC(int_sk_lingertime),
+		[META_ID(SK_ACK_BACKLOG)]	= META_FUNC(int_sk_ack_bl),
+		[META_ID(SK_MAX_ACK_BACKLOG)]	= META_FUNC(int_sk_max_ack_bl),
+		[META_ID(SK_PRIO)]		= META_FUNC(int_sk_prio),
+		[META_ID(SK_RCVLOWAT)]		= META_FUNC(int_sk_rcvlowat),
+		[META_ID(SK_RCVTIMEO)]		= META_FUNC(int_sk_rcvtimeo),
+		[META_ID(SK_SNDTIMEO)]		= META_FUNC(int_sk_sndtimeo),
+		[META_ID(SK_SENDMSG_OFF)]	= META_FUNC(int_sk_sendmsg_off),
+		[META_ID(SK_WRITE_PENDING)]	= META_FUNC(int_sk_write_pend),
 	}
 };
 
Index: ematch/include/linux/tc_ematch/tc_em_meta.h
===================================================================
--- ematch.orig/include/linux/tc_ematch/tc_em_meta.h
+++ ematch/include/linux/tc_ematch/tc_em_meta.h
@@ -56,6 +56,36 @@ enum
 	TCF_META_ID_TCCLASSID,
 	TCF_META_ID_RTCLASSID,
 	TCF_META_ID_RTIIF,
+	TCF_META_ID_SK_FAMILY,
+	TCF_META_ID_SK_STATE,
+	TCF_META_ID_SK_REUSE,
+	TCF_META_ID_SK_BOUND_IF,
+	TCF_META_ID_SK_REFCNT,
+	TCF_META_ID_SK_SHUTDOWN,
+	TCF_META_ID_SK_PROTO,
+	TCF_META_ID_SK_TYPE,
+	TCF_META_ID_SK_RCVBUF,
+	TCF_META_ID_SK_RMEM_ALLOC,
+	TCF_META_ID_SK_WMEM_ALLOC,
+	TCF_META_ID_SK_OMEM_ALLOC,
+	TCF_META_ID_SK_WMEM_QUEUED,
+	TCF_META_ID_SK_RCV_QLEN,
+	TCF_META_ID_SK_SND_QLEN,
+ 	TCF_META_ID_SK_ERR_QLEN,
+	TCF_META_ID_SK_FORWARD_ALLOCS,
+	TCF_META_ID_SK_SNDBUF,
+ 	TCF_META_ID_SK_ALLOCS,
+ 	TCF_META_ID_SK_ROUTE_CAPS,
+ 	TCF_META_ID_SK_HASHENT,
+ 	TCF_META_ID_SK_LINGERTIME,
+ 	TCF_META_ID_SK_ACK_BACKLOG,
+ 	TCF_META_ID_SK_MAX_ACK_BACKLOG,
+ 	TCF_META_ID_SK_PRIO,
+ 	TCF_META_ID_SK_RCVLOWAT,
+ 	TCF_META_ID_SK_RCVTIMEO,
+ 	TCF_META_ID_SK_SNDTIMEO,
+ 	TCF_META_ID_SK_SENDMSG_OFF,
+ 	TCF_META_ID_SK_WRITE_PENDING,
 	__TCF_META_ID_MAX
 };
 #define TCF_META_ID_MAX (__TCF_META_ID_MAX - 1)
