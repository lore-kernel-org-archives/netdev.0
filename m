From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PACKET]: Add PACKET_AUXDATA cmsg
Date: Wed, 24 Jan 2007 10:38:34 +1100
Message-ID: <20070123233834.GA4923@gondor.apana.org.au>
References: <20070110025435.GA19599@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3636 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965599AbXAWXij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 18:38:39 -0500
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20070110025435.GA19599@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 01:54:35PM +1100, Herbert Xu wrote:
> 
> [PACKET]: Add optional checksum computation for recvmsg

Unfortunately I missed the fact the skb->cb is already used to store
the sockaddr.  This patch fixes it up.

[PACKET]: Fix skb->cb clobbering between aux and sockaddr

Both aux data and sockaddr tries to use the same buffer which
obviously doesn't work.  We just happen to have 4 bytes free in
the skb->cb if you take away the maximum length of sockaddr_ll.
That's just enough to store the one piece of info from aux data
that we can't generate at recvmsg(2) time.

This is what the following patch does.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index dab117e..4c7f9d7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -60,6 +60,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_packet.h>
 #include <linux/wireless.h>
+#include <linux/kernel.h>
 #include <linux/kmod.h>
 #include <net/ip.h>
 #include <net/protocol.h>
@@ -215,7 +216,15 @@ struct packet_sock {
 #endif
 };
 
-#define PACKET_SKB_CB(__skb)	((struct tpacket_auxdata *)((__skb)->cb))
+struct packet_skb_cb {
+	unsigned int origlen;
+	union {
+		struct sockaddr_pkt pkt;
+		struct sockaddr_ll ll;
+	} sa;
+};
+
+#define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
 
 #ifdef CONFIG_PACKET_MMAP
 
@@ -296,7 +305,7 @@ static int packet_rcv_spkt(struct sk_buff *skb, struct net_device *dev,  struct
 	/* drop conntrack reference */
 	nf_reset(skb);
 
-	spkt = (struct sockaddr_pkt*)skb->cb;
+	spkt = &PACKET_SKB_CB(skb)->sa.pkt;
 
 	skb_push(skb, skb->data-skb->mac.raw);
 
@@ -471,7 +480,6 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	u8 * skb_head = skb->data;
 	int skb_len = skb->len;
 	unsigned snaplen;
-	struct tpacket_auxdata *aux;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -519,7 +527,10 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 		skb = nskb;
 	}
 
-	sll = (struct sockaddr_ll*)skb->cb;
+	BUILD_BUG_ON(sizeof(*PACKET_SKB_CB(skb)) + MAX_ADDR_LEN - 8 >
+		     sizeof(skb->cb));
+
+	sll = &PACKET_SKB_CB(skb)->sa.ll;
 	sll->sll_family = AF_PACKET;
 	sll->sll_hatype = dev->type;
 	sll->sll_protocol = skb->protocol;
@@ -530,14 +541,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	if (dev->hard_header_parse)
 		sll->sll_halen = dev->hard_header_parse(skb, sll->sll_addr);
 
-	aux = PACKET_SKB_CB(skb);
-	aux->tp_status = TP_STATUS_USER;
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		aux->tp_status |= TP_STATUS_CSUMNOTREADY;
-	aux->tp_len = skb->len;
-	aux->tp_snaplen = snaplen;
-	aux->tp_mac = 0;
-	aux->tp_net = skb->nh.raw - skb->data;
+	PACKET_SKB_CB(skb)->origlen = skb->len;
 
 	if (pskb_trim(skb, snaplen))
 		goto drop_n_acct;
@@ -1106,7 +1110,7 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 *	it in now.
 	 */
 
-	sll = (struct sockaddr_ll*)skb->cb;
+	sll = &PACKET_SKB_CB(skb)->sa.ll;
 	if (sock->type == SOCK_PACKET)
 		msg->msg_namelen = sizeof(struct sockaddr_pkt);
 	else
@@ -1131,11 +1135,21 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 	sock_recv_timestamp(msg, sk, skb);
 
 	if (msg->msg_name)
-		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
+		memcpy(msg->msg_name, &PACKET_SKB_CB(skb)->sa,
+		       msg->msg_namelen);
 
 	if (pkt_sk(sk)->auxdata) {
-		struct tpacket_auxdata *aux = PACKET_SKB_CB(skb);
-		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(*aux), aux);
+		struct tpacket_auxdata aux;
+
+		aux.tp_status = TP_STATUS_USER;
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			aux.tp_status |= TP_STATUS_CSUMNOTREADY;
+		aux.tp_len = PACKET_SKB_CB(skb)->origlen;
+		aux.tp_snaplen = skb->len;
+		aux.tp_mac = 0;
+		aux.tp_net = skb->nh.raw - skb->data;
+
+		put_cmsg(msg, SOL_PACKET, PACKET_AUXDATA, sizeof(aux), &aux);
 	}
 
 	/*
