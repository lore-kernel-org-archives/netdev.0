From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] DSCP support for pktgen
Date: Tue, 26 Sep 2006 16:18:10 +0200
Message-ID: <17689.13986.848022.719899@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:38278 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1750813AbWIZOSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 10:18:15 -0400
To: "Francesco Fondelli" <francesco.fondelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Francesco Fondelli writes:

 > Anyway, I've been asked to add support for managing DSCP codepoints, so
 > one can test DiffServ capable routers. It's very simple code and is working for
 > me.

Looks fine too. We ask Dave to apply again.

Cheers.
					--ro


Signed-off-by: Francesco Fondelli <francesco.fondelli@gmail.com>
Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>



--- new/net/core/pktgen.c.vlan	2006-09-26 14:53:34.000000000 +0200
+++ new/net/core/pktgen.c	2006-09-26 14:54:49.000000000 +0200
@@ -160,7 +160,7 @@
 #include <asm/div64.h>		/* do_div */
 #include <asm/timex.h>
 
-#define VERSION  "pktgen v2.67: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.68: Packet Generator for packet performance testing.\n"
 
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a)
@@ -292,6 +292,10 @@
 	__u16 udp_dst_min;	/* inclusive, dest UDP port */
 	__u16 udp_dst_max;	/* exclusive, dest UDP port */
 
+	/* DSCP + ECN */
+	__u8 tos;            /* six most significant bits of (former) IPv4 TOS are for dscp codepoint */
+	__u8 traffic_class;  /* ditto for the (former) Traffic Class in IPv6 (see RFC 3260, sec. 4) */
+
 	/* MPLS */
 	unsigned nr_labels;	/* Depth of stack, 0 = no MPLS */
 	__be32 labels[MAX_MPLS_LABELS];
@@ -671,6 +675,14 @@
 			   pkt_dev->svlan_id, pkt_dev->svlan_p, pkt_dev->svlan_cfi);
 	}
 
+	if (pkt_dev->tos) {
+		seq_printf(seq, "     tos: 0x%02x\n", pkt_dev->tos);
+	}
+
+	if (pkt_dev->traffic_class) {
+		seq_printf(seq, "     traffic_class: 0x%02x\n", pkt_dev->traffic_class);
+	}
+
 	seq_printf(seq, "     Flags: ");
 
 	if (pkt_dev->flags & F_IPV6)
@@ -748,12 +760,12 @@
 }
 
 
-static int hex32_arg(const char __user *user_buffer, __u32 *num)
+static int hex32_arg(const char __user *user_buffer, unsigned long maxlen, __u32 *num)
 {
 	int i = 0;
 	*num = 0;
 
-	for(; i < 8; i++) {
+	for(; i < maxlen; i++) {
 		char c;
 		*num <<= 4;
 		if (get_user(c, &user_buffer[i]))
@@ -848,7 +860,7 @@
 	pkt_dev->nr_labels = 0;
 	do {
 		__u32 tmp;
-		len = hex32_arg(&buffer[i], &tmp);
+		len = hex32_arg(&buffer[i], 8, &tmp);
 		if (len <= 0)
 			return len;
 		pkt_dev->labels[n] = htonl(tmp);
@@ -1185,11 +1197,15 @@
 		else if (strcmp(f, "!SVID_RND") == 0)
 			pkt_dev->flags &= ~F_SVID_RND;
 
+		else if (strcmp(f, "!IPV6") == 0)
+			pkt_dev->flags &= ~F_IPV6;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
 				f,
-				"IPSRC_RND, IPDST_RND, TXSIZE_RND, UDPSRC_RND, UDPDST_RND, MACSRC_RND, MACDST_RND\n");
+				"IPSRC_RND, IPDST_RND, UDPSRC_RND, UDPDST_RND, "
+				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID_RND\n");
 			return count;
 		}
 		sprintf(pg_result, "OK: flags=0x%x", pkt_dev->flags);
@@ -1615,6 +1631,38 @@
 		return count;
 	}
 
+	if (!strcmp(name, "tos")) {
+		__u32 tmp_value = 0;
+		len = hex32_arg(&user_buffer[i], 2, &tmp_value);
+		if (len < 0) {
+			return len;
+		}
+		i += len;
+		if (len == 2) {
+			pkt_dev->tos = tmp_value;
+			sprintf(pg_result, "OK: tos=0x%02x", pkt_dev->tos);
+		} else {
+			sprintf(pg_result, "ERROR: tos must be 00-ff");
+		}
+		return count;
+	}
+
+	if (!strcmp(name, "traffic_class")) {
+		__u32 tmp_value = 0;
+		len = hex32_arg(&user_buffer[i], 2, &tmp_value);
+		if (len < 0) {
+			return len;
+		}
+		i += len;
+		if (len == 2) {
+			pkt_dev->traffic_class = tmp_value;
+			sprintf(pg_result, "OK: traffic_class=0x%02x", pkt_dev->traffic_class);
+		} else {
+			sprintf(pg_result, "ERROR: traffic_class must be 00-ff");
+		}
+		return count;
+	}
+
 	sprintf(pkt_dev->result, "No such parameter \"%s\"", name);
 	return -EINVAL;
 }
@@ -2339,7 +2387,7 @@
 	iph->ihl = 5;
 	iph->version = 4;
 	iph->ttl = 32;
-	iph->tos = 0;
+	iph->tos = pkt_dev->tos;
 	iph->protocol = IPPROTO_UDP;	/* UDP */
 	iph->saddr = pkt_dev->cur_saddr;
 	iph->daddr = pkt_dev->cur_daddr;
@@ -2678,6 +2726,11 @@
 
 	*(u32 *) iph = __constant_htonl(0x60000000);	/* Version + flow */
 
+	if(pkt_dev->traffic_class) {
+		/* Version + traffic class + flow (0) */
+		*(u32 *)iph |= htonl(0x60000000 | (pkt_dev->traffic_class << 20));
+	}
+
 	iph->hop_limit = 32;
 
 	iph->payload_len = htons(sizeof(struct udphdr) + datalen);
