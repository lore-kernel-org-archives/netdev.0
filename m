From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/8] tcp: Add GRO support
Date: Fri, 12 Dec 2008 16:31:55 +1100
Message-ID: <E1LB0d1-0000rd-B2@gondolin.me.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59007 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757525AbYLLFb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 00:31:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp: Add GRO support

This patch adds the TCP-specific portion of GRO.  The criterion for
merging is extremely strict (the TCP header must match exactly apart
from the checksum) so as to allow refragmentation.  Otherwise this
is pretty much identical to LRO, except that we support the merging
of ECN packets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/tcp.h   |    6 +++
 net/ipv4/af_inet.c  |    2 +
 net/ipv4/tcp.c      |  100 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c |   35 ++++++++++++++++++
 4 files changed, 143 insertions(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 438014d..cd571a9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1358,6 +1358,12 @@ extern void tcp_v4_destroy_sock(struct sock *sk);
 
 extern int tcp_v4_gso_send_check(struct sk_buff *skb);
 extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features);
+extern struct sk_buff **tcp_gro_receive(struct sk_buff **head,
+					struct sk_buff *skb);
+extern struct sk_buff **tcp4_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb);
+extern int tcp_gro_complete(struct sk_buff *skb);
+extern int tcp4_gro_complete(struct sk_buff *skb);
 
 #ifdef CONFIG_PROC_FS
 extern int  tcp4_proc_init(void);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 260f081..dafbfbd 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1413,6 +1413,8 @@ static struct net_protocol tcp_protocol = {
 	.err_handler =	tcp_v4_err,
 	.gso_send_check = tcp_v4_gso_send_check,
 	.gso_segment =	tcp_tso_segment,
+	.gro_receive =	tcp4_gro_receive,
+	.gro_complete =	tcp4_gro_complete,
 	.no_policy =	1,
 	.netns_ok =	1,
 };
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c5aca0b..294d838 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2461,6 +2461,106 @@ out:
 }
 EXPORT_SYMBOL(tcp_tso_segment);
 
+struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+{
+	struct sk_buff **pp = NULL;
+	struct sk_buff *p;
+	struct tcphdr *th;
+	struct tcphdr *th2;
+	unsigned int thlen;
+	unsigned int flags;
+	unsigned int total;
+	unsigned int mss = 1;
+	int flush = 1;
+
+	if (!pskb_may_pull(skb, sizeof(*th)))
+		goto out;
+
+	th = tcp_hdr(skb);
+	thlen = th->doff * 4;
+	if (thlen < sizeof(*th))
+		goto out;
+
+	if (!pskb_may_pull(skb, thlen))
+		goto out;
+
+	th = tcp_hdr(skb);
+	__skb_pull(skb, thlen);
+
+	flags = tcp_flag_word(th);
+
+	for (; (p = *head); head = &p->next) {
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		th2 = tcp_hdr(p);
+
+		if (th->source != th2->source || th->dest != th2->dest) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+
+		goto found;
+	}
+
+	goto out_check_final;
+
+found:
+	flush = NAPI_GRO_CB(p)->flush;
+	flush |= flags & TCP_FLAG_CWR;
+	flush |= (flags ^ tcp_flag_word(th2)) &
+		  ~(TCP_FLAG_CWR | TCP_FLAG_FIN | TCP_FLAG_PSH);
+	flush |= th->ack_seq != th2->ack_seq || th->window != th2->window;
+	flush |= memcmp(th + 1, th2 + 1, thlen - sizeof(*th));
+
+	total = p->len;
+	mss = total;
+	if (skb_shinfo(p)->frag_list)
+		mss = skb_shinfo(p)->frag_list->len;
+
+	flush |= skb->len > mss || skb->len <= 0;
+	flush |= ntohl(th2->seq) + total != ntohl(th->seq);
+
+	if (flush || skb_gro_receive(head, skb)) {
+		mss = 1;
+		goto out_check_final;
+	}
+
+	p = *head;
+	th2 = tcp_hdr(p);
+	tcp_flag_word(th2) |= flags & (TCP_FLAG_FIN | TCP_FLAG_PSH);
+
+out_check_final:
+	flush = skb->len < mss;
+	flush |= flags & (TCP_FLAG_URG | TCP_FLAG_PSH | TCP_FLAG_RST |
+			  TCP_FLAG_SYN | TCP_FLAG_FIN);
+
+	if (p && (!NAPI_GRO_CB(skb)->same_flow || flush))
+		pp = head;
+
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+int tcp_gro_complete(struct sk_buff *skb)
+{
+	struct tcphdr *th = tcp_hdr(skb);
+
+	skb->csum_start = skb_transport_header(skb) - skb->head;
+	skb->csum_offset = offsetof(struct tcphdr, check);
+	skb->ip_summed = CHECKSUM_PARTIAL;
+
+	skb_shinfo(skb)->gso_size = skb_shinfo(skb)->frag_list->len;
+	skb_shinfo(skb)->gso_segs = NAPI_GRO_CB(skb)->count;
+
+	if (th->cwr)
+		skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
+
+	return 0;
+}
+
 #ifdef CONFIG_TCP_MD5SIG
 static unsigned long tcp_md5sig_users;
 static struct tcp_md5sig_pool **tcp_md5sig_pool;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5c8fa7f..5b7ce84 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2350,6 +2350,41 @@ void tcp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */
 
+struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	switch (skb->ip_summed) {
+	case CHECKSUM_COMPLETE:
+		if (!tcp_v4_check(skb->len, iph->saddr, iph->daddr,
+				  skb->csum)) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			break;
+		}
+
+		/* fall through */
+	case CHECKSUM_NONE:
+		NAPI_GRO_CB(skb)->flush = 1;
+		return NULL;
+	}
+
+	return tcp_gro_receive(head, skb);
+}
+EXPORT_SYMBOL(tcp4_gro_receive);
+
+int tcp4_gro_complete(struct sk_buff *skb)
+{
+	struct iphdr *iph = ip_hdr(skb);
+	struct tcphdr *th = tcp_hdr(skb);
+
+	th->check = ~tcp_v4_check(skb->len - skb_transport_offset(skb),
+				  iph->saddr, iph->daddr, 0);
+	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+
+	return tcp_gro_complete(skb);
+}
+EXPORT_SYMBOL(tcp4_gro_complete);
+
 struct proto tcp_prot = {
 	.name			= "TCP",
 	.owner			= THIS_MODULE,
