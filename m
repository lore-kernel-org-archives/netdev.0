From: kaber@trash.net
Subject: [PATCH 28/72] netfilter: ipt_LOG: add bufferisation to call printk() once
Date: Thu, 21 Oct 2010 17:19:15 +0200
Message-ID: <1287674399-31455-29-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60006 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706Ab0JUPUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:08 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

ipt_LOG & ip6t_LOG use lot of calls to printk() and use a lock in a hope
several cpus wont mix their output in syslog.

printk() being very expensive [1], its better to call it once, on a
prebuilt and complete line. Also, with mixed IPv4 and IPv6 trafic,
separate IPv4/IPv6 locks dont avoid garbage.

I used an allocation of a 1024 bytes structure, sort of seq_printf() but
with a fixed size limit.
Use a static buffer if dynamic allocation failed.

Emit a once time alert if buffer size happens to be too short.

[1]: printk() has various features like printk_delay()...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ipt_LOG.c  |  145 +++++++++++++++++++-------------------
 net/ipv6/netfilter/ip6t_LOG.c |  157 +++++++++++++++++++++--------------------
 2 files changed, 152 insertions(+), 150 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 915fc17..72ffc8f 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -24,16 +24,15 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ipt_LOG.h>
 #include <net/netfilter/nf_log.h>
+#include <net/netfilter/xt_log.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("Xtables: IPv4 packet logging to syslog");
 
-/* Use lock to serialize, so printks don't overlap */
-static DEFINE_SPINLOCK(log_lock);
-
 /* One level of recursion won't kill us */
-static void dump_packet(const struct nf_loginfo *info,
+static void dump_packet(struct sbuff *m,
+			const struct nf_loginfo *info,
 			const struct sk_buff *skb,
 			unsigned int iphoff)
 {
@@ -48,32 +47,32 @@ static void dump_packet(const struct nf_loginfo *info,
 
 	ih = skb_header_pointer(skb, iphoff, sizeof(_iph), &_iph);
 	if (ih == NULL) {
-		printk("TRUNCATED");
+		sb_add(m, "TRUNCATED");
 		return;
 	}
 
 	/* Important fields:
 	 * TOS, len, DF/MF, fragment offset, TTL, src, dst, options. */
 	/* Max length: 40 "SRC=255.255.255.255 DST=255.255.255.255 " */
-	printk("SRC=%pI4 DST=%pI4 ",
+	sb_add(m, "SRC=%pI4 DST=%pI4 ",
 	       &ih->saddr, &ih->daddr);
 
 	/* Max length: 46 "LEN=65535 TOS=0xFF PREC=0xFF TTL=255 ID=65535 " */
-	printk("LEN=%u TOS=0x%02X PREC=0x%02X TTL=%u ID=%u ",
+	sb_add(m, "LEN=%u TOS=0x%02X PREC=0x%02X TTL=%u ID=%u ",
 	       ntohs(ih->tot_len), ih->tos & IPTOS_TOS_MASK,
 	       ih->tos & IPTOS_PREC_MASK, ih->ttl, ntohs(ih->id));
 
 	/* Max length: 6 "CE DF MF " */
 	if (ntohs(ih->frag_off) & IP_CE)
-		printk("CE ");
+		sb_add(m, "CE ");
 	if (ntohs(ih->frag_off) & IP_DF)
-		printk("DF ");
+		sb_add(m, "DF ");
 	if (ntohs(ih->frag_off) & IP_MF)
-		printk("MF ");
+		sb_add(m, "MF ");
 
 	/* Max length: 11 "FRAG:65535 " */
 	if (ntohs(ih->frag_off) & IP_OFFSET)
-		printk("FRAG:%u ", ntohs(ih->frag_off) & IP_OFFSET);
+		sb_add(m, "FRAG:%u ", ntohs(ih->frag_off) & IP_OFFSET);
 
 	if ((logflags & IPT_LOG_IPOPT) &&
 	    ih->ihl * 4 > sizeof(struct iphdr)) {
@@ -85,15 +84,15 @@ static void dump_packet(const struct nf_loginfo *info,
 		op = skb_header_pointer(skb, iphoff+sizeof(_iph),
 					optsize, _opt);
 		if (op == NULL) {
-			printk("TRUNCATED");
+			sb_add(m, "TRUNCATED");
 			return;
 		}
 
 		/* Max length: 127 "OPT (" 15*4*2chars ") " */
-		printk("OPT (");
+		sb_add(m, "OPT (");
 		for (i = 0; i < optsize; i++)
-			printk("%02X", op[i]);
-		printk(") ");
+			sb_add(m, "%02X", op[i]);
+		sb_add(m, ") ");
 	}
 
 	switch (ih->protocol) {
@@ -102,7 +101,7 @@ static void dump_packet(const struct nf_loginfo *info,
 		const struct tcphdr *th;
 
 		/* Max length: 10 "PROTO=TCP " */
-		printk("PROTO=TCP ");
+		sb_add(m, "PROTO=TCP ");
 
 		if (ntohs(ih->frag_off) & IP_OFFSET)
 			break;
@@ -111,41 +110,41 @@ static void dump_packet(const struct nf_loginfo *info,
 		th = skb_header_pointer(skb, iphoff + ih->ihl * 4,
 					sizeof(_tcph), &_tcph);
 		if (th == NULL) {
-			printk("INCOMPLETE [%u bytes] ",
+			sb_add(m, "INCOMPLETE [%u bytes] ",
 			       skb->len - iphoff - ih->ihl*4);
 			break;
 		}
 
 		/* Max length: 20 "SPT=65535 DPT=65535 " */
-		printk("SPT=%u DPT=%u ",
+		sb_add(m, "SPT=%u DPT=%u ",
 		       ntohs(th->source), ntohs(th->dest));
 		/* Max length: 30 "SEQ=4294967295 ACK=4294967295 " */
 		if (logflags & IPT_LOG_TCPSEQ)
-			printk("SEQ=%u ACK=%u ",
+			sb_add(m, "SEQ=%u ACK=%u ",
 			       ntohl(th->seq), ntohl(th->ack_seq));
 		/* Max length: 13 "WINDOW=65535 " */
-		printk("WINDOW=%u ", ntohs(th->window));
+		sb_add(m, "WINDOW=%u ", ntohs(th->window));
 		/* Max length: 9 "RES=0x3F " */
-		printk("RES=0x%02x ", (u8)(ntohl(tcp_flag_word(th) & TCP_RESERVED_BITS) >> 22));
+		sb_add(m, "RES=0x%02x ", (u8)(ntohl(tcp_flag_word(th) & TCP_RESERVED_BITS) >> 22));
 		/* Max length: 32 "CWR ECE URG ACK PSH RST SYN FIN " */
 		if (th->cwr)
-			printk("CWR ");
+			sb_add(m, "CWR ");
 		if (th->ece)
-			printk("ECE ");
+			sb_add(m, "ECE ");
 		if (th->urg)
-			printk("URG ");
+			sb_add(m, "URG ");
 		if (th->ack)
-			printk("ACK ");
+			sb_add(m, "ACK ");
 		if (th->psh)
-			printk("PSH ");
+			sb_add(m, "PSH ");
 		if (th->rst)
-			printk("RST ");
+			sb_add(m, "RST ");
 		if (th->syn)
-			printk("SYN ");
+			sb_add(m, "SYN ");
 		if (th->fin)
-			printk("FIN ");
+			sb_add(m, "FIN ");
 		/* Max length: 11 "URGP=65535 " */
-		printk("URGP=%u ", ntohs(th->urg_ptr));
+		sb_add(m, "URGP=%u ", ntohs(th->urg_ptr));
 
 		if ((logflags & IPT_LOG_TCPOPT) &&
 		    th->doff * 4 > sizeof(struct tcphdr)) {
@@ -158,15 +157,15 @@ static void dump_packet(const struct nf_loginfo *info,
 						iphoff+ih->ihl*4+sizeof(_tcph),
 						optsize, _opt);
 			if (op == NULL) {
-				printk("TRUNCATED");
+				sb_add(m, "TRUNCATED");
 				return;
 			}
 
 			/* Max length: 127 "OPT (" 15*4*2chars ") " */
-			printk("OPT (");
+			sb_add(m, "OPT (");
 			for (i = 0; i < optsize; i++)
-				printk("%02X", op[i]);
-			printk(") ");
+				sb_add(m, "%02X", op[i]);
+			sb_add(m, ") ");
 		}
 		break;
 	}
@@ -177,9 +176,9 @@ static void dump_packet(const struct nf_loginfo *info,
 
 		if (ih->protocol == IPPROTO_UDP)
 			/* Max length: 10 "PROTO=UDP "     */
-			printk("PROTO=UDP " );
+			sb_add(m, "PROTO=UDP " );
 		else	/* Max length: 14 "PROTO=UDPLITE " */
-			printk("PROTO=UDPLITE ");
+			sb_add(m, "PROTO=UDPLITE ");
 
 		if (ntohs(ih->frag_off) & IP_OFFSET)
 			break;
@@ -188,13 +187,13 @@ static void dump_packet(const struct nf_loginfo *info,
 		uh = skb_header_pointer(skb, iphoff+ih->ihl*4,
 					sizeof(_udph), &_udph);
 		if (uh == NULL) {
-			printk("INCOMPLETE [%u bytes] ",
+			sb_add(m, "INCOMPLETE [%u bytes] ",
 			       skb->len - iphoff - ih->ihl*4);
 			break;
 		}
 
 		/* Max length: 20 "SPT=65535 DPT=65535 " */
-		printk("SPT=%u DPT=%u LEN=%u ",
+		sb_add(m, "SPT=%u DPT=%u LEN=%u ",
 		       ntohs(uh->source), ntohs(uh->dest),
 		       ntohs(uh->len));
 		break;
@@ -221,7 +220,7 @@ static void dump_packet(const struct nf_loginfo *info,
 			    [ICMP_ADDRESSREPLY] = 12 };
 
 		/* Max length: 11 "PROTO=ICMP " */
-		printk("PROTO=ICMP ");
+		sb_add(m, "PROTO=ICMP ");
 
 		if (ntohs(ih->frag_off) & IP_OFFSET)
 			break;
@@ -230,19 +229,19 @@ static void dump_packet(const struct nf_loginfo *info,
 		ich = skb_header_pointer(skb, iphoff + ih->ihl * 4,
 					 sizeof(_icmph), &_icmph);
 		if (ich == NULL) {
-			printk("INCOMPLETE [%u bytes] ",
+			sb_add(m, "INCOMPLETE [%u bytes] ",
 			       skb->len - iphoff - ih->ihl*4);
 			break;
 		}
 
 		/* Max length: 18 "TYPE=255 CODE=255 " */
-		printk("TYPE=%u CODE=%u ", ich->type, ich->code);
+		sb_add(m, "TYPE=%u CODE=%u ", ich->type, ich->code);
 
 		/* Max length: 25 "INCOMPLETE [65535 bytes] " */
 		if (ich->type <= NR_ICMP_TYPES &&
 		    required_len[ich->type] &&
 		    skb->len-iphoff-ih->ihl*4 < required_len[ich->type]) {
-			printk("INCOMPLETE [%u bytes] ",
+			sb_add(m, "INCOMPLETE [%u bytes] ",
 			       skb->len - iphoff - ih->ihl*4);
 			break;
 		}
@@ -251,35 +250,35 @@ static void dump_packet(const struct nf_loginfo *info,
 		case ICMP_ECHOREPLY:
 		case ICMP_ECHO:
 			/* Max length: 19 "ID=65535 SEQ=65535 " */
-			printk("ID=%u SEQ=%u ",
+			sb_add(m, "ID=%u SEQ=%u ",
 			       ntohs(ich->un.echo.id),
 			       ntohs(ich->un.echo.sequence));
 			break;
 
 		case ICMP_PARAMETERPROB:
 			/* Max length: 14 "PARAMETER=255 " */
-			printk("PARAMETER=%u ",
+			sb_add(m, "PARAMETER=%u ",
 			       ntohl(ich->un.gateway) >> 24);
 			break;
 		case ICMP_REDIRECT:
 			/* Max length: 24 "GATEWAY=255.255.255.255 " */
-			printk("GATEWAY=%pI4 ", &ich->un.gateway);
+			sb_add(m, "GATEWAY=%pI4 ", &ich->un.gateway);
 			/* Fall through */
 		case ICMP_DEST_UNREACH:
 		case ICMP_SOURCE_QUENCH:
 		case ICMP_TIME_EXCEEDED:
 			/* Max length: 3+maxlen */
 			if (!iphoff) { /* Only recurse once. */
-				printk("[");
-				dump_packet(info, skb,
+				sb_add(m, "[");
+				dump_packet(m, info, skb,
 					    iphoff + ih->ihl*4+sizeof(_icmph));
-				printk("] ");
+				sb_add(m, "] ");
 			}
 
 			/* Max length: 10 "MTU=65535 " */
 			if (ich->type == ICMP_DEST_UNREACH &&
 			    ich->code == ICMP_FRAG_NEEDED)
-				printk("MTU=%u ", ntohs(ich->un.frag.mtu));
+				sb_add(m, "MTU=%u ", ntohs(ich->un.frag.mtu));
 		}
 		break;
 	}
@@ -292,19 +291,19 @@ static void dump_packet(const struct nf_loginfo *info,
 			break;
 
 		/* Max length: 9 "PROTO=AH " */
-		printk("PROTO=AH ");
+		sb_add(m, "PROTO=AH ");
 
 		/* Max length: 25 "INCOMPLETE [65535 bytes] " */
 		ah = skb_header_pointer(skb, iphoff+ih->ihl*4,
 					sizeof(_ahdr), &_ahdr);
 		if (ah == NULL) {
-			printk("INCOMPLETE [%u bytes] ",
+			sb_add(m, "INCOMPLETE [%u bytes] ",
 			       skb->len - iphoff - ih->ihl*4);
 			break;
 		}
 
 		/* Length: 15 "SPI=0xF1234567 " */
-		printk("SPI=0x%x ", ntohl(ah->spi));
+		sb_add(m, "SPI=0x%x ", ntohl(ah->spi));
 		break;
 	}
 	case IPPROTO_ESP: {
@@ -312,7 +311,7 @@ static void dump_packet(const struct nf_loginfo *info,
 		const struct ip_esp_hdr *eh;
 
 		/* Max length: 10 "PROTO=ESP " */
-		printk("PROTO=ESP ");
+		sb_add(m, "PROTO=ESP ");
 
 		if (ntohs(ih->frag_off) & IP_OFFSET)
 			break;
@@ -321,25 +320,25 @@ static void dump_packet(const struct nf_loginfo *info,
 		eh = skb_header_pointer(skb, iphoff+ih->ihl*4,
 					sizeof(_esph), &_esph);
 		if (eh == NULL) {
-			printk("INCOMPLETE [%u bytes] ",
+			sb_add(m, "INCOMPLETE [%u bytes] ",
 			       skb->len - iphoff - ih->ihl*4);
 			break;
 		}
 
 		/* Length: 15 "SPI=0xF1234567 " */
-		printk("SPI=0x%x ", ntohl(eh->spi));
+		sb_add(m, "SPI=0x%x ", ntohl(eh->spi));
 		break;
 	}
 	/* Max length: 10 "PROTO 255 " */
 	default:
-		printk("PROTO=%u ", ih->protocol);
+		sb_add(m, "PROTO=%u ", ih->protocol);
 	}
 
 	/* Max length: 15 "UID=4294967295 " */
 	if ((logflags & IPT_LOG_UID) && !iphoff && skb->sk) {
 		read_lock_bh(&skb->sk->sk_callback_lock);
 		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
-			printk("UID=%u GID=%u ",
+			sb_add(m, "UID=%u GID=%u ",
 				skb->sk->sk_socket->file->f_cred->fsuid,
 				skb->sk->sk_socket->file->f_cred->fsgid);
 		read_unlock_bh(&skb->sk->sk_callback_lock);
@@ -347,7 +346,7 @@ static void dump_packet(const struct nf_loginfo *info,
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
 	if (!iphoff && skb->mark)
-		printk("MARK=0x%x ", skb->mark);
+		sb_add(m, "MARK=0x%x ", skb->mark);
 
 	/* Proto    Max log string length */
 	/* IP:      40+46+6+11+127 = 230 */
@@ -364,7 +363,8 @@ static void dump_packet(const struct nf_loginfo *info,
 	/* maxlen = 230+   91  + 230 + 252 = 803 */
 }
 
-static void dump_mac_header(const struct nf_loginfo *info,
+static void dump_mac_header(struct sbuff *m,
+			    const struct nf_loginfo *info,
 			    const struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
@@ -378,7 +378,7 @@ static void dump_mac_header(const struct nf_loginfo *info,
 
 	switch (dev->type) {
 	case ARPHRD_ETHER:
-		printk("MACSRC=%pM MACDST=%pM MACPROTO=%04x ",
+		sb_add(m, "MACSRC=%pM MACDST=%pM MACPROTO=%04x ",
 		       eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
 		       ntohs(eth_hdr(skb)->h_proto));
 		return;
@@ -387,17 +387,17 @@ static void dump_mac_header(const struct nf_loginfo *info,
 	}
 
 fallback:
-	printk("MAC=");
+	sb_add(m, "MAC=");
 	if (dev->hard_header_len &&
 	    skb->mac_header != skb->network_header) {
 		const unsigned char *p = skb_mac_header(skb);
 		unsigned int i;
 
-		printk("%02x", *p++);
+		sb_add(m, "%02x", *p++);
 		for (i = 1; i < dev->hard_header_len; i++, p++)
-			printk(":%02x", *p);
+			sb_add(m, ":%02x", *p);
 	}
-	printk(" ");
+	sb_add(m, " ");
 }
 
 static struct nf_loginfo default_loginfo = {
@@ -419,11 +419,12 @@ ipt_log_packet(u_int8_t pf,
 	       const struct nf_loginfo *loginfo,
 	       const char *prefix)
 {
+	struct sbuff *m = sb_open();
+
 	if (!loginfo)
 		loginfo = &default_loginfo;
 
-	spin_lock_bh(&log_lock);
-	printk("<%d>%sIN=%s OUT=%s ", loginfo->u.log.level,
+	sb_add(m, "<%d>%sIN=%s OUT=%s ", loginfo->u.log.level,
 	       prefix,
 	       in ? in->name : "",
 	       out ? out->name : "");
@@ -434,20 +435,20 @@ ipt_log_packet(u_int8_t pf,
 
 		physindev = skb->nf_bridge->physindev;
 		if (physindev && in != physindev)
-			printk("PHYSIN=%s ", physindev->name);
+			sb_add(m, "PHYSIN=%s ", physindev->name);
 		physoutdev = skb->nf_bridge->physoutdev;
 		if (physoutdev && out != physoutdev)
-			printk("PHYSOUT=%s ", physoutdev->name);
+			sb_add(m, "PHYSOUT=%s ", physoutdev->name);
 	}
 #endif
 
 	/* MAC logging for input path only. */
 	if (in && !out)
-		dump_mac_header(loginfo, skb);
+		dump_mac_header(m, loginfo, skb);
+
+	dump_packet(m, loginfo, skb, 0);
 
-	dump_packet(loginfo, skb, 0);
-	printk("\n");
-	spin_unlock_bh(&log_lock);
+	sb_close(m);
 }
 
 static unsigned int
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 0a07ae7..09c8889 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -23,6 +23,7 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <net/netfilter/nf_log.h>
+#include <net/netfilter/xt_log.h>
 
 MODULE_AUTHOR("Jan Rekorajski <baggins@pld.org.pl>");
 MODULE_DESCRIPTION("Xtables: IPv6 packet logging to syslog");
@@ -32,11 +33,9 @@ struct in_device;
 #include <net/route.h>
 #include <linux/netfilter_ipv6/ip6t_LOG.h>
 
-/* Use lock to serialize, so printks don't overlap */
-static DEFINE_SPINLOCK(log_lock);
-
 /* One level of recursion won't kill us */
-static void dump_packet(const struct nf_loginfo *info,
+static void dump_packet(struct sbuff *m,
+			const struct nf_loginfo *info,
 			const struct sk_buff *skb, unsigned int ip6hoff,
 			int recurse)
 {
@@ -55,15 +54,15 @@ static void dump_packet(const struct nf_loginfo *info,
 
 	ih = skb_header_pointer(skb, ip6hoff, sizeof(_ip6h), &_ip6h);
 	if (ih == NULL) {
-		printk("TRUNCATED");
+		sb_add(m, "TRUNCATED");
 		return;
 	}
 
 	/* Max length: 88 "SRC=0000.0000.0000.0000.0000.0000.0000.0000 DST=0000.0000.0000.0000.0000.0000.0000.0000 " */
-	printk("SRC=%pI6 DST=%pI6 ", &ih->saddr, &ih->daddr);
+	sb_add(m, "SRC=%pI6 DST=%pI6 ", &ih->saddr, &ih->daddr);
 
 	/* Max length: 44 "LEN=65535 TC=255 HOPLIMIT=255 FLOWLBL=FFFFF " */
-	printk("LEN=%Zu TC=%u HOPLIMIT=%u FLOWLBL=%u ",
+	sb_add(m, "LEN=%Zu TC=%u HOPLIMIT=%u FLOWLBL=%u ",
 	       ntohs(ih->payload_len) + sizeof(struct ipv6hdr),
 	       (ntohl(*(__be32 *)ih) & 0x0ff00000) >> 20,
 	       ih->hop_limit,
@@ -78,35 +77,35 @@ static void dump_packet(const struct nf_loginfo *info,
 
 		hp = skb_header_pointer(skb, ptr, sizeof(_hdr), &_hdr);
 		if (hp == NULL) {
-			printk("TRUNCATED");
+			sb_add(m, "TRUNCATED");
 			return;
 		}
 
 		/* Max length: 48 "OPT (...) " */
 		if (logflags & IP6T_LOG_IPOPT)
-			printk("OPT ( ");
+			sb_add(m, "OPT ( ");
 
 		switch (currenthdr) {
 		case IPPROTO_FRAGMENT: {
 			struct frag_hdr _fhdr;
 			const struct frag_hdr *fh;
 
-			printk("FRAG:");
+			sb_add(m, "FRAG:");
 			fh = skb_header_pointer(skb, ptr, sizeof(_fhdr),
 						&_fhdr);
 			if (fh == NULL) {
-				printk("TRUNCATED ");
+				sb_add(m, "TRUNCATED ");
 				return;
 			}
 
 			/* Max length: 6 "65535 " */
-			printk("%u ", ntohs(fh->frag_off) & 0xFFF8);
+			sb_add(m, "%u ", ntohs(fh->frag_off) & 0xFFF8);
 
 			/* Max length: 11 "INCOMPLETE " */
 			if (fh->frag_off & htons(0x0001))
-				printk("INCOMPLETE ");
+				sb_add(m, "INCOMPLETE ");
 
-			printk("ID:%08x ", ntohl(fh->identification));
+			sb_add(m, "ID:%08x ", ntohl(fh->identification));
 
 			if (ntohs(fh->frag_off) & 0xFFF8)
 				fragment = 1;
@@ -120,7 +119,7 @@ static void dump_packet(const struct nf_loginfo *info,
 		case IPPROTO_HOPOPTS:
 			if (fragment) {
 				if (logflags & IP6T_LOG_IPOPT)
-					printk(")");
+					sb_add(m, ")");
 				return;
 			}
 			hdrlen = ipv6_optlen(hp);
@@ -132,10 +131,10 @@ static void dump_packet(const struct nf_loginfo *info,
 				const struct ip_auth_hdr *ah;
 
 				/* Max length: 3 "AH " */
-				printk("AH ");
+				sb_add(m, "AH ");
 
 				if (fragment) {
-					printk(")");
+					sb_add(m, ")");
 					return;
 				}
 
@@ -146,13 +145,13 @@ static void dump_packet(const struct nf_loginfo *info,
 					 * Max length: 26 "INCOMPLETE [65535
 					 *  bytes] )"
 					 */
-					printk("INCOMPLETE [%u bytes] )",
+					sb_add(m, "INCOMPLETE [%u bytes] )",
 					       skb->len - ptr);
 					return;
 				}
 
 				/* Length: 15 "SPI=0xF1234567 */
-				printk("SPI=0x%x ", ntohl(ah->spi));
+				sb_add(m, "SPI=0x%x ", ntohl(ah->spi));
 
 			}
 
@@ -164,10 +163,10 @@ static void dump_packet(const struct nf_loginfo *info,
 				const struct ip_esp_hdr *eh;
 
 				/* Max length: 4 "ESP " */
-				printk("ESP ");
+				sb_add(m, "ESP ");
 
 				if (fragment) {
-					printk(")");
+					sb_add(m, ")");
 					return;
 				}
 
@@ -177,23 +176,23 @@ static void dump_packet(const struct nf_loginfo *info,
 				eh = skb_header_pointer(skb, ptr, sizeof(_esph),
 							&_esph);
 				if (eh == NULL) {
-					printk("INCOMPLETE [%u bytes] )",
+					sb_add(m, "INCOMPLETE [%u bytes] )",
 					       skb->len - ptr);
 					return;
 				}
 
 				/* Length: 16 "SPI=0xF1234567 )" */
-				printk("SPI=0x%x )", ntohl(eh->spi) );
+				sb_add(m, "SPI=0x%x )", ntohl(eh->spi) );
 
 			}
 			return;
 		default:
 			/* Max length: 20 "Unknown Ext Hdr 255" */
-			printk("Unknown Ext Hdr %u", currenthdr);
+			sb_add(m, "Unknown Ext Hdr %u", currenthdr);
 			return;
 		}
 		if (logflags & IP6T_LOG_IPOPT)
-			printk(") ");
+			sb_add(m, ") ");
 
 		currenthdr = hp->nexthdr;
 		ptr += hdrlen;
@@ -205,7 +204,7 @@ static void dump_packet(const struct nf_loginfo *info,
 		const struct tcphdr *th;
 
 		/* Max length: 10 "PROTO=TCP " */
-		printk("PROTO=TCP ");
+		sb_add(m, "PROTO=TCP ");
 
 		if (fragment)
 			break;
@@ -213,40 +212,40 @@ static void dump_packet(const struct nf_loginfo *info,
 		/* Max length: 25 "INCOMPLETE [65535 bytes] " */
 		th = skb_header_pointer(skb, ptr, sizeof(_tcph), &_tcph);
 		if (th == NULL) {
-			printk("INCOMPLETE [%u bytes] ", skb->len - ptr);
+			sb_add(m, "INCOMPLETE [%u bytes] ", skb->len - ptr);
 			return;
 		}
 
 		/* Max length: 20 "SPT=65535 DPT=65535 " */
-		printk("SPT=%u DPT=%u ",
+		sb_add(m, "SPT=%u DPT=%u ",
 		       ntohs(th->source), ntohs(th->dest));
 		/* Max length: 30 "SEQ=4294967295 ACK=4294967295 " */
 		if (logflags & IP6T_LOG_TCPSEQ)
-			printk("SEQ=%u ACK=%u ",
+			sb_add(m, "SEQ=%u ACK=%u ",
 			       ntohl(th->seq), ntohl(th->ack_seq));
 		/* Max length: 13 "WINDOW=65535 " */
-		printk("WINDOW=%u ", ntohs(th->window));
+		sb_add(m, "WINDOW=%u ", ntohs(th->window));
 		/* Max length: 9 "RES=0x3C " */
-		printk("RES=0x%02x ", (u_int8_t)(ntohl(tcp_flag_word(th) & TCP_RESERVED_BITS) >> 22));
+		sb_add(m, "RES=0x%02x ", (u_int8_t)(ntohl(tcp_flag_word(th) & TCP_RESERVED_BITS) >> 22));
 		/* Max length: 32 "CWR ECE URG ACK PSH RST SYN FIN " */
 		if (th->cwr)
-			printk("CWR ");
+			sb_add(m, "CWR ");
 		if (th->ece)
-			printk("ECE ");
+			sb_add(m, "ECE ");
 		if (th->urg)
-			printk("URG ");
+			sb_add(m, "URG ");
 		if (th->ack)
-			printk("ACK ");
+			sb_add(m, "ACK ");
 		if (th->psh)
-			printk("PSH ");
+			sb_add(m, "PSH ");
 		if (th->rst)
-			printk("RST ");
+			sb_add(m, "RST ");
 		if (th->syn)
-			printk("SYN ");
+			sb_add(m, "SYN ");
 		if (th->fin)
-			printk("FIN ");
+			sb_add(m, "FIN ");
 		/* Max length: 11 "URGP=65535 " */
-		printk("URGP=%u ", ntohs(th->urg_ptr));
+		sb_add(m, "URGP=%u ", ntohs(th->urg_ptr));
 
 		if ((logflags & IP6T_LOG_TCPOPT) &&
 		    th->doff * 4 > sizeof(struct tcphdr)) {
@@ -260,15 +259,15 @@ static void dump_packet(const struct nf_loginfo *info,
 						ptr + sizeof(struct tcphdr),
 						optsize, _opt);
 			if (op == NULL) {
-				printk("OPT (TRUNCATED)");
+				sb_add(m, "OPT (TRUNCATED)");
 				return;
 			}
 
 			/* Max length: 127 "OPT (" 15*4*2chars ") " */
-			printk("OPT (");
+			sb_add(m, "OPT (");
 			for (i =0; i < optsize; i++)
-				printk("%02X", op[i]);
-			printk(") ");
+				sb_add(m, "%02X", op[i]);
+			sb_add(m, ") ");
 		}
 		break;
 	}
@@ -279,9 +278,9 @@ static void dump_packet(const struct nf_loginfo *info,
 
 		if (currenthdr == IPPROTO_UDP)
 			/* Max length: 10 "PROTO=UDP "     */
-			printk("PROTO=UDP " );
+			sb_add(m, "PROTO=UDP " );
 		else	/* Max length: 14 "PROTO=UDPLITE " */
-			printk("PROTO=UDPLITE ");
+			sb_add(m, "PROTO=UDPLITE ");
 
 		if (fragment)
 			break;
@@ -289,12 +288,12 @@ static void dump_packet(const struct nf_loginfo *info,
 		/* Max length: 25 "INCOMPLETE [65535 bytes] " */
 		uh = skb_header_pointer(skb, ptr, sizeof(_udph), &_udph);
 		if (uh == NULL) {
-			printk("INCOMPLETE [%u bytes] ", skb->len - ptr);
+			sb_add(m, "INCOMPLETE [%u bytes] ", skb->len - ptr);
 			return;
 		}
 
 		/* Max length: 20 "SPT=65535 DPT=65535 " */
-		printk("SPT=%u DPT=%u LEN=%u ",
+		sb_add(m, "SPT=%u DPT=%u LEN=%u ",
 		       ntohs(uh->source), ntohs(uh->dest),
 		       ntohs(uh->len));
 		break;
@@ -304,7 +303,7 @@ static void dump_packet(const struct nf_loginfo *info,
 		const struct icmp6hdr *ic;
 
 		/* Max length: 13 "PROTO=ICMPv6 " */
-		printk("PROTO=ICMPv6 ");
+		sb_add(m, "PROTO=ICMPv6 ");
 
 		if (fragment)
 			break;
@@ -312,18 +311,18 @@ static void dump_packet(const struct nf_loginfo *info,
 		/* Max length: 25 "INCOMPLETE [65535 bytes] " */
 		ic = skb_header_pointer(skb, ptr, sizeof(_icmp6h), &_icmp6h);
 		if (ic == NULL) {
-			printk("INCOMPLETE [%u bytes] ", skb->len - ptr);
+			sb_add(m, "INCOMPLETE [%u bytes] ", skb->len - ptr);
 			return;
 		}
 
 		/* Max length: 18 "TYPE=255 CODE=255 " */
-		printk("TYPE=%u CODE=%u ", ic->icmp6_type, ic->icmp6_code);
+		sb_add(m, "TYPE=%u CODE=%u ", ic->icmp6_type, ic->icmp6_code);
 
 		switch (ic->icmp6_type) {
 		case ICMPV6_ECHO_REQUEST:
 		case ICMPV6_ECHO_REPLY:
 			/* Max length: 19 "ID=65535 SEQ=65535 " */
-			printk("ID=%u SEQ=%u ",
+			sb_add(m, "ID=%u SEQ=%u ",
 				ntohs(ic->icmp6_identifier),
 				ntohs(ic->icmp6_sequence));
 			break;
@@ -334,35 +333,35 @@ static void dump_packet(const struct nf_loginfo *info,
 
 		case ICMPV6_PARAMPROB:
 			/* Max length: 17 "POINTER=ffffffff " */
-			printk("POINTER=%08x ", ntohl(ic->icmp6_pointer));
+			sb_add(m, "POINTER=%08x ", ntohl(ic->icmp6_pointer));
 			/* Fall through */
 		case ICMPV6_DEST_UNREACH:
 		case ICMPV6_PKT_TOOBIG:
 		case ICMPV6_TIME_EXCEED:
 			/* Max length: 3+maxlen */
 			if (recurse) {
-				printk("[");
-				dump_packet(info, skb, ptr + sizeof(_icmp6h),
-					    0);
-				printk("] ");
+				sb_add(m, "[");
+				dump_packet(m, info, skb,
+					    ptr + sizeof(_icmp6h), 0);
+				sb_add(m, "] ");
 			}
 
 			/* Max length: 10 "MTU=65535 " */
 			if (ic->icmp6_type == ICMPV6_PKT_TOOBIG)
-				printk("MTU=%u ", ntohl(ic->icmp6_mtu));
+				sb_add(m, "MTU=%u ", ntohl(ic->icmp6_mtu));
 		}
 		break;
 	}
 	/* Max length: 10 "PROTO=255 " */
 	default:
-		printk("PROTO=%u ", currenthdr);
+		sb_add(m, "PROTO=%u ", currenthdr);
 	}
 
 	/* Max length: 15 "UID=4294967295 " */
 	if ((logflags & IP6T_LOG_UID) && recurse && skb->sk) {
 		read_lock_bh(&skb->sk->sk_callback_lock);
 		if (skb->sk->sk_socket && skb->sk->sk_socket->file)
-			printk("UID=%u GID=%u ",
+			sb_add(m, "UID=%u GID=%u ",
 				skb->sk->sk_socket->file->f_cred->fsuid,
 				skb->sk->sk_socket->file->f_cred->fsgid);
 		read_unlock_bh(&skb->sk->sk_callback_lock);
@@ -370,10 +369,11 @@ static void dump_packet(const struct nf_loginfo *info,
 
 	/* Max length: 16 "MARK=0xFFFFFFFF " */
 	if (!recurse && skb->mark)
-		printk("MARK=0x%x ", skb->mark);
+		sb_add(m, "MARK=0x%x ", skb->mark);
 }
 
-static void dump_mac_header(const struct nf_loginfo *info,
+static void dump_mac_header(struct sbuff *m,
+			    const struct nf_loginfo *info,
 			    const struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
@@ -387,7 +387,7 @@ static void dump_mac_header(const struct nf_loginfo *info,
 
 	switch (dev->type) {
 	case ARPHRD_ETHER:
-		printk("MACSRC=%pM MACDST=%pM MACPROTO=%04x ",
+		sb_add(m, "MACSRC=%pM MACDST=%pM MACPROTO=%04x ",
 		       eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
 		       ntohs(eth_hdr(skb)->h_proto));
 		return;
@@ -396,7 +396,7 @@ static void dump_mac_header(const struct nf_loginfo *info,
 	}
 
 fallback:
-	printk("MAC=");
+	sb_add(m, "MAC=");
 	if (dev->hard_header_len &&
 	    skb->mac_header != skb->network_header) {
 		const unsigned char *p = skb_mac_header(skb);
@@ -408,19 +408,19 @@ fallback:
 			p = NULL;
 
 		if (p != NULL) {
-			printk("%02x", *p++);
+			sb_add(m, "%02x", *p++);
 			for (i = 1; i < len; i++)
-				printk(":%02x", p[i]);
+				sb_add(m, ":%02x", p[i]);
 		}
-		printk(" ");
+		sb_add(m, " ");
 
 		if (dev->type == ARPHRD_SIT) {
 			const struct iphdr *iph =
 				(struct iphdr *)skb_mac_header(skb);
-			printk("TUNNEL=%pI4->%pI4 ", &iph->saddr, &iph->daddr);
+			sb_add(m, "TUNNEL=%pI4->%pI4 ", &iph->saddr, &iph->daddr);
 		}
 	} else
-		printk(" ");
+		sb_add(m, " ");
 }
 
 static struct nf_loginfo default_loginfo = {
@@ -442,22 +442,23 @@ ip6t_log_packet(u_int8_t pf,
 		const struct nf_loginfo *loginfo,
 		const char *prefix)
 {
+	struct sbuff *m = sb_open();
+
 	if (!loginfo)
 		loginfo = &default_loginfo;
 
-	spin_lock_bh(&log_lock);
-	printk("<%d>%sIN=%s OUT=%s ", loginfo->u.log.level,
-		prefix,
-		in ? in->name : "",
-		out ? out->name : "");
+	sb_add(m, "<%d>%sIN=%s OUT=%s ", loginfo->u.log.level,
+	       prefix,
+	       in ? in->name : "",
+	       out ? out->name : "");
 
 	/* MAC logging for input path only. */
 	if (in && !out)
-		dump_mac_header(loginfo, skb);
+		dump_mac_header(m, loginfo, skb);
+
+	dump_packet(m, loginfo, skb, skb_network_offset(skb), 1);
 
-	dump_packet(loginfo, skb, skb_network_offset(skb), 1);
-	printk("\n");
-	spin_unlock_bh(&log_lock);
+	sb_close(m);
 }
 
 static unsigned int
-- 
1.7.1

