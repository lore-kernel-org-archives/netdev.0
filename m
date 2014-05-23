From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/5 v3] net: Split sk_no_check into sk_no_check_{rx,tx}
Date: Fri, 23 May 2014 08:47:19 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405230839510.11904@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f73.google.com ([209.85.160.73]:40416 "EHLO
	mail-pb0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbaEWPrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 11:47:20 -0400
Received: by mail-pb0-f73.google.com with SMTP id ma3so724916pbc.2
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 08:47:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define separate fields in the sock structure for configuring disabling
checksums in both TX and RX-- sk_no_check_tx and sk_no_check_rx.
The SO_NO_CHECK socket option only affects sk_no_check_tx. Also,
removed UDP_CSUM_* defines since they are no longer necessary.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/scsi/iscsi_tcp.c | 2 +-
 include/net/sock.h       | 6 ++++--
 include/net/udp.h        | 9 ---------
 net/appletalk/ddp.c      | 2 +-
 net/core/sock.c          | 4 ++--
 net/decnet/af_decnet.c   | 2 +-
 net/ipv4/udp.c           | 2 +-
 net/ipv6/udp.c           | 6 +++---
 net/ipx/af_ipx.c         | 2 +-
 net/ipx/ipx_route.c      | 3 ++-
 net/l2tp/l2tp_core.c     | 4 ++--
 net/l2tp/l2tp_netlink.c  | 3 +--
 net/sctp/socket.c        | 3 ++-
 13 files changed, 21 insertions(+), 27 deletions(-)

diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 1185484..a669f2d 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -244,7 +244,7 @@ iscsi_sw_tcp_conn_restore_callbacks(struct iscsi_conn *conn)
 	sk->sk_data_ready   = tcp_sw_conn->old_data_ready;
 	sk->sk_state_change = tcp_sw_conn->old_state_change;
 	sk->sk_write_space  = tcp_sw_conn->old_write_space;
-	sk->sk_no_check	 = 0;
+	sk->sk_no_check_tx = 0;
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 21569cf..07b7fcd 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -243,7 +243,8 @@ struct cg_proto;
   *	@sk_sndbuf: size of send buffer in bytes
   *	@sk_flags: %SO_LINGER (l_onoff), %SO_BROADCAST, %SO_KEEPALIVE,
   *		   %SO_OOBINLINE settings, %SO_TIMESTAMPING settings
-  *	@sk_no_check: %SO_NO_CHECK setting, whether or not checkup packets
+  *	@sk_no_check_tx: %SO_NO_CHECK setting, set checksum in TX packets
+  *	@sk_no_check_rx: allow zero checksum in RX packets
   *	@sk_route_caps: route capabilities (e.g. %NETIF_F_TSO)
   *	@sk_route_nocaps: forbidden route capabilities (e.g NETIF_F_GSO_MASK)
   *	@sk_gso_type: GSO type (e.g. %SKB_GSO_TCPV4)
@@ -371,7 +372,8 @@ struct sock {
 	struct sk_buff_head	sk_write_queue;
 	kmemcheck_bitfield_begin(flags);
 	unsigned int		sk_shutdown  : 2,
-				sk_no_check  : 2,
+				sk_no_check_tx : 1,
+				sk_no_check_rx : 1,
 				sk_userlocks : 4,
 				sk_protocol  : 8,
 				sk_type      : 16;
diff --git a/include/net/udp.h b/include/net/udp.h
index a24f0f3..5eb8687 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -95,15 +95,6 @@ static inline struct udp_hslot *udp_hashslot2(struct udp_table *table,
 	return &table->hash2[hash & table->mask];
 }
 
-/* Note: this must match 'valbool' in sock_setsockopt */
-#define UDP_CSUM_NOXMIT		1
-
-/* Used by SunRPC/xprt layer. */
-#define UDP_CSUM_NORCV		2
-
-/* Default, as per the RFC, is to always do csums. */
-#define UDP_CSUM_DEFAULT	0
-
 extern struct proto udp_prot;
 
 extern atomic_long_t udp_memory_allocated;
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 786ee2f..01a1082 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1669,7 +1669,7 @@ static int atalk_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
 		goto out;
 	}
 
-	if (sk->sk_no_check == 1)
+	if (sk->sk_no_check_tx)
 		ddp->deh_sum = 0;
 	else
 		ddp->deh_sum = atalk_checksum(skb, len + sizeof(*ddp));
diff --git a/net/core/sock.c b/net/core/sock.c
index 664ee42..026e01f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -784,7 +784,7 @@ set_rcvbuf:
 		break;
 
 	case SO_NO_CHECK:
-		sk->sk_no_check = valbool;
+		sk->sk_no_check_tx = valbool;
 		break;
 
 	case SO_PRIORITY:
@@ -1064,7 +1064,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		break;
 
 	case SO_NO_CHECK:
-		v.val = sk->sk_no_check;
+		v.val = sk->sk_no_check_tx;
 		break;
 
 	case SO_PRIORITY:
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 4c04848..ae011b4 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -481,7 +481,7 @@ static struct sock *dn_alloc_sock(struct net *net, struct socket *sock, gfp_t gf
 
 	sk->sk_backlog_rcv = dn_nsp_backlog_rcv;
 	sk->sk_destruct    = dn_destruct;
-	sk->sk_no_check    = 1;
+	sk->sk_no_check_tx = 1;
 	sk->sk_family      = PF_DECnet;
 	sk->sk_protocol    = 0;
 	sk->sk_allocation  = gfp;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 590532a..12c6175 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -785,7 +785,7 @@ static int udp_send_skb(struct sk_buff *skb, struct flowi4 *fl4)
 	if (is_udplite)  				 /*     UDP-Lite      */
 		csum = udplite_csum(skb);
 
-	else if (sk->sk_no_check == UDP_CSUM_NOXMIT) {   /* UDP csum disabled */
+	else if (sk->sk_no_check_tx) {   /* UDP csum disabled */
 
 		skb->ip_summed = CHECKSUM_NONE;
 		goto send;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c7ed47b..b8db453 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -797,7 +797,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		/* If zero checksum and sk_no_check is not on for
 		 * the socket then skip it.
 		 */
-		if (uh->check || sk->sk_no_check)
+		if (uh->check || sk->sk_no_check_rx)
 			stack[count++] = sk;
 
 		sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
@@ -887,7 +887,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (sk != NULL) {
 		int ret;
 
-		if (!uh->check && !sk->sk_no_check) {
+		if (!uh->check && !sk->sk_no_check_rx) {
 			sock_put(sk);
 			udp6_csum_zero_error(skb);
 			goto csum_error;
@@ -1037,7 +1037,7 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 
 	if (is_udplite)
 		csum = udplite_csum_outgoing(sk, skb);
-	else if (sk->sk_no_check == UDP_CSUM_NOXMIT) {   /* UDP csum disabled */
+	else if (sk->sk_no_check_tx) {   /* UDP csum disabled */
 		skb->ip_summed = CHECKSUM_NONE;
 		goto send;
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 41e4e93..91729b8 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1353,7 +1353,7 @@ static int ipx_create(struct net *net, struct socket *sock, int protocol,
 
 	sk_refcnt_debug_inc(sk);
 	sock_init_data(sock, sk);
-	sk->sk_no_check = 1;		/* Checksum off by default */
+	sk->sk_no_check_tx = 1;		/* Checksum off by default */
 	sock->ops = &ipx_dgram_ops;
 	rc = 0;
 out:
diff --git a/net/ipx/ipx_route.c b/net/ipx/ipx_route.c
index c1f0318..67e7ad3 100644
--- a/net/ipx/ipx_route.c
+++ b/net/ipx/ipx_route.c
@@ -236,7 +236,8 @@ int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
 	}
 
 	/* Apply checksum. Not allowed on 802.3 links. */
-	if (sk->sk_no_check || intrfc->if_dlink_type == htons(IPX_FRAME_8023))
+	if (sk->sk_no_check_tx ||
+	    intrfc->if_dlink_type == htons(IPX_FRAME_8023))
 		ipx->ipx_checksum = htons(0xFFFF);
 	else
 		ipx->ipx_checksum = ipx_cksum(ipx, len + sizeof(struct ipxhdr));
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index ed0716a..a118610 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1188,7 +1188,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 			l2tp_xmit_ipv6_csum(sk, skb, udp_len);
 		else
 #endif
-		if (sk->sk_no_check == UDP_CSUM_NOXMIT)
+		if (sk->sk_no_check_tx)
 			skb->ip_summed = CHECKSUM_NONE;
 		else if ((skb_dst(skb) && skb_dst(skb)->dev) &&
 			 (!(skb_dst(skb)->dev->features & NETIF_F_V4_CSUM))) {
@@ -1463,7 +1463,7 @@ static int l2tp_tunnel_sock_create(struct net *net,
 		}
 
 		if (!cfg->use_udp_checksums)
-			sock->sk->sk_no_check = UDP_CSUM_NOXMIT;
+			sock->sk->sk_no_check_tx = 1;
 
 		break;
 
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index bd7387a..f3d331b 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -297,8 +297,7 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 	case L2TP_ENCAPTYPE_UDP:
 		if (nla_put_u16(skb, L2TP_ATTR_UDP_SPORT, ntohs(inet->inet_sport)) ||
 		    nla_put_u16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport)) ||
-		    nla_put_u8(skb, L2TP_ATTR_UDP_CSUM,
-			       (sk->sk_no_check != UDP_CSUM_NOXMIT)))
+		    nla_put_u8(skb, L2TP_ATTR_UDP_CSUM, !sk->sk_no_check_tx))
 			goto nla_put_failure;
 		/* NOBREAK */
 	case L2TP_ENCAPTYPE_IP:
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2af76ea..4298996 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6946,7 +6946,8 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 	newsk->sk_type = sk->sk_type;
 	newsk->sk_bound_dev_if = sk->sk_bound_dev_if;
 	newsk->sk_flags = sk->sk_flags;
-	newsk->sk_no_check = sk->sk_no_check;
+	newsk->sk_no_check_tx = sk->sk_no_check_tx;
+	newsk->sk_no_check_rx = sk->sk_no_check_rx;
 	newsk->sk_reuse = sk->sk_reuse;
 
 	newsk->sk_shutdown = sk->sk_shutdown;
-- 
1.9.1.423.g4596e3a
