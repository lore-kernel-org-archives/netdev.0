From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PACKET]: Add PACKET_AUXDATA cmsg
Date: Wed, 10 Jan 2007 13:54:35 +1100
Message-ID: <20070110025435.GA19599@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3961 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932690AbXAJCyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 21:54:39 -0500
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[PACKET]: Add optional checksum computation for recvmsg

This patch is needed to make ISC's DHCP server (and probably other
DHCP servers/clients using AF_PACKET) to be able to serve another
client on the same Xen host.

The problem is that packets between different domains on the same
Xen host only have partial checksums.  Unfortunately this piece of
information is not passed along in AF_PACKET unless you're using
the mmap interface.  Since dhcpd doesn't support packet-mmap, UDP
packets from the same host come out with apparently bogus checksums.

This patch adds a mechanism for AF_PACKET recvmsg(2) to return the
status along with the packet.  It does so by adding a new cmsg that
contains this information along with some other relevant data such
as the original packet length.

I didn't include the time stamp information since there is already
a cmsg for that.

This patch also changes the mmap code to set the CSUMNOTREADY flag
on all packets instead of just outoing packets on cooked sockets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 99393ef..f3de05c 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -41,6 +41,7 @@ struct sockaddr_ll
 #define PACKET_RX_RING			5
 #define PACKET_STATISTICS		6
 #define PACKET_COPY_THRESH		7
+#define PACKET_AUXDATA			8
 
 struct tpacket_stats
 {
@@ -48,6 +49,15 @@ struct tpacket_stats
 	unsigned int	tp_drops;
 };
 
+struct tpacket_auxdata
+{
+	__u32		tp_status;
+	__u32		tp_len;
+	__u32		tp_snaplen;
+	__u16		tp_mac;
+	__u16		tp_net;
+};
+
 struct tpacket_hdr
 {
 	unsigned long	tp_status;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index da73e8a..dab117e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -200,7 +200,8 @@ struct packet_sock {
 #endif
 	struct packet_type	prot_hook;
 	spinlock_t		bind_lock;
-	char			running;	/* prot_hook is attached*/
+	unsigned int		running:1,	/* prot_hook is attached*/
+				auxdata:1;
 	int			ifindex;	/* bound device		*/
 	__be16			num;
 #ifdef CONFIG_PACKET_MULTICAST
@@ -214,6 +215,8 @@ struct packet_sock {
 #endif
 };
 
+#define PACKET_SKB_CB(__skb)	((struct tpacket_auxdata *)((__skb)->cb))
+
 #ifdef CONFIG_PACKET_MMAP
 
 static inline char *packet_lookup_frame(struct packet_sock *po, unsigned int position)
@@ -468,6 +471,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	u8 * skb_head = skb->data;
 	int skb_len = skb->len;
 	unsigned snaplen;
+	struct tpacket_auxdata *aux;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -526,6 +530,15 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	if (dev->hard_header_parse)
 		sll->sll_halen = dev->hard_header_parse(skb, sll->sll_addr);
 
+	aux = PACKET_SKB_CB(skb);
+	aux->tp_status = TP_STATUS_USER;
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		aux->tp_status |= TP_STATUS_CSUMNOTREADY;
+	aux->tp_len = skb->len;
+	aux->tp_snaplen = snaplen;
+	aux->tp_mac = 0;
+	aux->tp_net = skb->nh.raw - skb->data;
+
 	if (pskb_trim(skb, snaplen))
 		goto drop_n_acct;
 
@@ -585,11 +598,12 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 		else if (skb->pkt_type == PACKET_OUTGOING) {
 			/* Special case: outgoing packets have ll header at head */
 			skb_pull(skb, skb->nh.raw - skb->data);
-			if (skb->ip_summed == CHECKSUM_PARTIAL)
-				status |= TP_STATUS_CSUMNOTREADY;
 		}
 	}
 
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		status |= TP_STATUS_CSUMNOTREADY;
+
 	snaplen = skb->len;
 
 	if (run_filter(skb, sk, &snaplen) < 0)
@@ -1119,6 +1133,11 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (msg->msg_name)
 		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
 
+	if (pkt_sk(sk)->auxdata) {
+		struct tpacket_auxdata *aux = PACKET_SKB_CB(skb);
+		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(*aux), aux);
+	}
+
 	/*
 	 *	Free or return the buffer as appropriate. Again this
 	 *	hides all the races and re-entrancy issues from us.
@@ -1317,6 +1336,7 @@ static int
 packet_setsockopt(struct socket *sock, int level, int optname, char __user *optval, int optlen)
 {
 	struct sock *sk = sock->sk;
+	struct packet_sock *po = pkt_sk(sk);
 	int ret;
 
 	if (level != SOL_PACKET)
@@ -1369,6 +1389,18 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		return 0;
 	}
 #endif
+	case PACKET_AUXDATA:
+	{
+		int val;
+
+		if (optlen < sizeof(val))
+			return -EINVAL;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+
+		po->auxdata = !!val;
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -1378,8 +1410,11 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 			     char __user *optval, int __user *optlen)
 {
 	int len;
+	int val;
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
+	void *data;
+	struct tpacket_stats st;
 
 	if (level != SOL_PACKET)
 		return -ENOPROTOOPT;
@@ -1392,9 +1427,6 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 		
 	switch(optname)	{
 	case PACKET_STATISTICS:
-	{
-		struct tpacket_stats st;
-
 		if (len > sizeof(struct tpacket_stats))
 			len = sizeof(struct tpacket_stats);
 		spin_lock_bh(&sk->sk_receive_queue.lock);
@@ -1403,16 +1435,23 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 		st.tp_packets += st.tp_drops;
 
-		if (copy_to_user(optval, &st, len))
-			return -EFAULT;
+		data = &st;
+		break;
+	case PACKET_AUXDATA:
+		if (len > sizeof(int))
+			len = sizeof(int);
+		val = po->auxdata;
+
+		data = &val;
 		break;
-	}
 	default:
 		return -ENOPROTOOPT;
 	}
 
 	if (put_user(len, optlen))
 		return -EFAULT;
+	if (copy_to_user(optval, data, len))
+		return -EFAULT;
 	return 0;
 }
 
