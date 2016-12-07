From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 17/18] RDS: add receive message trace used by application
Date: Tue,  6 Dec 2016 20:01:55 -0800
Message-ID: <1481083316-11648-18-git-send-email-santosh.shilimkar@oracle.com>
References: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Socket option to tap receive path latency in various stages
in nano seconds. It can be enabled on selective sockets using
using SO_RDS_MSG_RXPATH_LATENCY socket option. RDS will return
the data to application with RDS_CMSG_RXPATH_LATENCY in defined
format. Scope is left to add more trace points for future
without need of change in the interface.

Reviewed-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 include/uapi/linux/rds.h | 33 +++++++++++++++++++++++++++++++++
 net/rds/af_rds.c         | 28 ++++++++++++++++++++++++++++
 net/rds/ib_recv.c        |  4 ++++
 net/rds/rds.h            | 10 ++++++++++
 net/rds/recv.c           | 32 +++++++++++++++++++++++++++++---
 net/rds/tcp_recv.c       |  5 +++++
 6 files changed, 109 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/rds.h b/include/uapi/linux/rds.h
index 0f9265c..3833113 100644
--- a/include/uapi/linux/rds.h
+++ b/include/uapi/linux/rds.h
@@ -52,6 +52,13 @@
 #define RDS_GET_MR_FOR_DEST		7
 #define SO_RDS_TRANSPORT		8
 
+/* Socket option to tap receive path latency
+ *	SO_RDS: SO_RDS_MSG_RXPATH_LATENCY
+ *	Format used struct rds_rx_trace_so
+ */
+#define SO_RDS_MSG_RXPATH_LATENCY	10
+
+
 /* supported values for SO_RDS_TRANSPORT */
 #define	RDS_TRANS_IB	0
 #define	RDS_TRANS_IWARP	1
@@ -77,6 +84,12 @@
  *	the same as for the GET_MR setsockopt.
  * RDS_CMSG_RDMA_STATUS (recvmsg)
  *	Returns the status of a completed RDMA operation.
+ * RDS_CMSG_RXPATH_LATENCY(recvmsg)
+ *	Returns rds message latencies in various stages of receive
+ *	path in nS. Its set per socket using SO_RDS_MSG_RXPATH_LATENCY
+ *	socket option. Legitimate points are defined in
+ *	enum rds_message_rxpath_latency. More points can be added in
+ *	future. CSMG format is struct rds_cmsg_rx_trace.
  */
 #define RDS_CMSG_RDMA_ARGS		1
 #define RDS_CMSG_RDMA_DEST		2
@@ -87,6 +100,7 @@
 #define RDS_CMSG_ATOMIC_CSWP		7
 #define RDS_CMSG_MASKED_ATOMIC_FADD	8
 #define RDS_CMSG_MASKED_ATOMIC_CSWP	9
+#define RDS_CMSG_RXPATH_LATENCY		11
 
 #define RDS_INFO_FIRST			10000
 #define RDS_INFO_COUNTERS		10000
@@ -171,6 +185,25 @@ struct rds_info_rdma_connection {
 	uint32_t	rdma_mr_size;
 };
 
+/* RDS message Receive Path Latency points */
+enum rds_message_rxpath_latency {
+	RDS_MSG_RX_HDR_TO_DGRAM_START = 0,
+	RDS_MSG_RX_DGRAM_REASSEMBLE,
+	RDS_MSG_RX_DGRAM_DELIVERED,
+	RDS_MSG_RX_DGRAM_TRACE_MAX
+};
+
+struct rds_rx_trace_so {
+	u8 rx_traces;
+	u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
+};
+
+struct rds_cmsg_rx_trace {
+	u8 rx_traces;
+	u8 rx_trace_pos[RDS_MSG_RX_DGRAM_TRACE_MAX];
+	u64 rx_trace[RDS_MSG_RX_DGRAM_TRACE_MAX];
+};
+
 /*
  * Congestion monitoring.
  * Congestion control in RDS happens at the host connection
diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 2ac1e61..fd821740 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -298,6 +298,30 @@ static int rds_enable_recvtstamp(struct sock *sk, char __user *optval,
 	return 0;
 }
 
+static int rds_recv_track_latency(struct rds_sock *rs, char __user *optval,
+				  int optlen)
+{
+	struct rds_rx_trace_so trace;
+	int i;
+
+	if (optlen != sizeof(struct rds_rx_trace_so))
+		return -EFAULT;
+
+	if (copy_from_user(&trace, optval, sizeof(trace)))
+		return -EFAULT;
+
+	rs->rs_rx_traces = trace.rx_traces;
+	for (i = 0; i < rs->rs_rx_traces; i++) {
+		if (trace.rx_trace_pos[i] > RDS_MSG_RX_DGRAM_TRACE_MAX) {
+			rs->rs_rx_traces = 0;
+			return -EFAULT;
+		}
+		rs->rs_rx_trace[i] = trace.rx_trace_pos[i];
+	}
+
+	return 0;
+}
+
 static int rds_setsockopt(struct socket *sock, int level, int optname,
 			  char __user *optval, unsigned int optlen)
 {
@@ -338,6 +362,9 @@ static int rds_setsockopt(struct socket *sock, int level, int optname,
 		ret = rds_enable_recvtstamp(sock->sk, optval, optlen);
 		release_sock(sock->sk);
 		break;
+	case SO_RDS_MSG_RXPATH_LATENCY:
+		ret = rds_recv_track_latency(rs, optval, optlen);
+		break;
 	default:
 		ret = -ENOPROTOOPT;
 	}
@@ -484,6 +511,7 @@ static int __rds_create(struct socket *sock, struct sock *sk, int protocol)
 	INIT_LIST_HEAD(&rs->rs_cong_list);
 	spin_lock_init(&rs->rs_rdma_lock);
 	rs->rs_rdma_keys = RB_ROOT;
+	rs->rs_rx_traces = 0;
 
 	spin_lock_bh(&rds_sock_lock);
 	list_add_tail(&rs->rs_item, &rds_sock_list);
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 4b0f126..e10624a 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -911,8 +911,12 @@ static void rds_ib_process_recv(struct rds_connection *conn,
 		ic->i_ibinc = ibinc;
 
 		hdr = &ibinc->ii_inc.i_hdr;
+		ibinc->ii_inc.i_rx_lat_trace[RDS_MSG_RX_HDR] =
+				local_clock();
 		memcpy(hdr, ihdr, sizeof(*hdr));
 		ic->i_recv_data_rem = be32_to_cpu(hdr->h_len);
+		ibinc->ii_inc.i_rx_lat_trace[RDS_MSG_RX_START] =
+				local_clock();
 
 		rdsdebug("ic %p ibinc %p rem %u flag 0x%x\n", ic, ibinc,
 			 ic->i_recv_data_rem, hdr->h_flags);
diff --git a/net/rds/rds.h b/net/rds/rds.h
index f713194..07fff73 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -253,6 +253,11 @@ struct rds_ext_header_rdma_dest {
 #define RDS_EXTHDR_GEN_NUM	6
 
 #define __RDS_EXTHDR_MAX	16 /* for now */
+#define RDS_RX_MAX_TRACES	(RDS_MSG_RX_DGRAM_TRACE_MAX + 1)
+#define	RDS_MSG_RX_HDR		0
+#define	RDS_MSG_RX_START	1
+#define	RDS_MSG_RX_END		2
+#define	RDS_MSG_RX_CMSG		3
 
 struct rds_incoming {
 	atomic_t		i_refcount;
@@ -265,6 +270,7 @@ struct rds_incoming {
 
 	rds_rdma_cookie_t	i_rdma_cookie;
 	struct timeval		i_rx_tstamp;
+	u64			i_rx_lat_trace[RDS_RX_MAX_TRACES];
 };
 
 struct rds_mr {
@@ -575,6 +581,10 @@ struct rds_sock {
 	unsigned char		rs_recverr,
 				rs_cong_monitor;
 	u32			rs_hash_initval;
+
+	/* Socket receive path trace points*/
+	u8			rs_rx_traces;
+	u8			rs_rx_trace[RDS_MSG_RX_DGRAM_TRACE_MAX];
 };
 
 static inline struct rds_sock *rds_sk_to_rs(const struct sock *sk)
diff --git a/net/rds/recv.c b/net/rds/recv.c
index ba19eee..8b7e7b7 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -43,6 +43,8 @@
 void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
 		  __be32 saddr)
 {
+	int i;
+
 	atomic_set(&inc->i_refcount, 1);
 	INIT_LIST_HEAD(&inc->i_item);
 	inc->i_conn = conn;
@@ -50,6 +52,9 @@ void rds_inc_init(struct rds_incoming *inc, struct rds_connection *conn,
 	inc->i_rdma_cookie = 0;
 	inc->i_rx_tstamp.tv_sec = 0;
 	inc->i_rx_tstamp.tv_usec = 0;
+
+	for (i = 0; i < RDS_RX_MAX_TRACES; i++)
+		inc->i_rx_lat_trace[i] = 0;
 }
 EXPORT_SYMBOL_GPL(rds_inc_init);
 
@@ -373,6 +378,7 @@ void rds_recv_incoming(struct rds_connection *conn, __be32 saddr, __be32 daddr,
 		if (sock_flag(sk, SOCK_RCVTSTAMP))
 			do_gettimeofday(&inc->i_rx_tstamp);
 		rds_inc_addref(inc);
+		inc->i_rx_lat_trace[RDS_MSG_RX_END] = local_clock();
 		list_add_tail(&inc->i_item, &rs->rs_recv_queue);
 		__rds_wake_sk_sleep(sk);
 	} else {
@@ -534,7 +540,7 @@ static int rds_cmsg_recv(struct rds_incoming *inc, struct msghdr *msg,
 		ret = put_cmsg(msg, SOL_RDS, RDS_CMSG_RDMA_DEST,
 				sizeof(inc->i_rdma_cookie), &inc->i_rdma_cookie);
 		if (ret)
-			return ret;
+			goto out;
 	}
 
 	if ((inc->i_rx_tstamp.tv_sec != 0) &&
@@ -543,10 +549,30 @@ static int rds_cmsg_recv(struct rds_incoming *inc, struct msghdr *msg,
 			       sizeof(struct timeval),
 			       &inc->i_rx_tstamp);
 		if (ret)
-			return ret;
+			goto out;
 	}
 
-	return 0;
+	if (rs->rs_rx_traces) {
+		struct rds_cmsg_rx_trace t;
+		int i, j;
+
+		inc->i_rx_lat_trace[RDS_MSG_RX_CMSG] = local_clock();
+		t.rx_traces =  rs->rs_rx_traces;
+		for (i = 0; i < rs->rs_rx_traces; i++) {
+			j = rs->rs_rx_trace[i];
+			t.rx_trace_pos[i] = j;
+			t.rx_trace[i] = inc->i_rx_lat_trace[j + 1] -
+					  inc->i_rx_lat_trace[j];
+		}
+
+		ret = put_cmsg(msg, SOL_RDS, RDS_CMSG_RXPATH_LATENCY,
+			       sizeof(t), &t);
+		if (ret)
+			goto out;
+	}
+
+out:
+	return ret;
 }
 
 int rds_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index ad4892e..e006ef8 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -180,6 +180,9 @@ static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
 			rdsdebug("alloced tinc %p\n", tinc);
 			rds_inc_path_init(&tinc->ti_inc, cp,
 					  cp->cp_conn->c_faddr);
+			tinc->ti_inc.i_rx_lat_trace[RDS_MSG_RX_HDR] =
+					local_clock();
+
 			/*
 			 * XXX * we might be able to use the __ variants when
 			 * we've already serialized at a higher level.
@@ -204,6 +207,8 @@ static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
 				/* could be 0 for a 0 len message */
 				tc->t_tinc_data_rem =
 					be32_to_cpu(tinc->ti_inc.i_hdr.h_len);
+				tinc->ti_inc.i_rx_lat_trace[RDS_MSG_RX_START] =
+					local_clock();
 			}
 		}
 
-- 
1.9.1
