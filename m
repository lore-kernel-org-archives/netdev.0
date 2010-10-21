From: kaber@trash.net
Subject: [PATCH 22/72] IPVS: Add persistence engine data to /proc/net/ip_vs_conn
Date: Thu, 21 Oct 2010 17:19:09 +0200
Message-ID: <1287674399-31455-23-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60001 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab0JUPUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:06 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

This shouldn't break compatibility with userspace as the new data
is at the end of the line.

I have confirmed that this doesn't break ipvsadm, the main (only?)
user-space user of this data.

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |    1 +
 net/netfilter/ipvs/ip_vs_conn.c |   25 ++++++++++++++++++++-----
 2 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b6b309d..974daf5 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -572,6 +572,7 @@ struct ip_vs_pe {
 			 struct ip_vs_conn *ct);
 	u32 (*hashkey_raw)(const struct ip_vs_conn_param *p, u32 initval,
 			   bool inverse);
+	int (*show_pe_data)(const struct ip_vs_conn *cp, char *buf);
 };
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 06da21e..4adedef 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -950,30 +950,45 @@ static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,
-   "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires\n");
+   "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires PEName PEData\n");
 	else {
 		const struct ip_vs_conn *cp = v;
+		char pe_data[IP_VS_PENAME_MAXLEN + IP_VS_PEDATA_MAXLEN + 3];
+		size_t len = 0;
+
+		if (cp->dest && cp->dest->svc->pe &&
+		    cp->dest->svc->pe->show_pe_data) {
+			pe_data[0] = ' ';
+			len = strlen(cp->dest->svc->pe->name);
+			memcpy(pe_data + 1, cp->dest->svc->pe->name, len);
+			pe_data[len + 1] = ' ';
+			len += 2;
+			len += cp->dest->svc->pe->show_pe_data(cp,
+							       pe_data + len);
+		}
+		pe_data[len] = '\0';
 
 #ifdef CONFIG_IP_VS_IPV6
 		if (cp->af == AF_INET6)
-			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X %pI6 %04X %-11s %7lu\n",
+			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X "
+				"%pI6 %04X %-11s %7lu%s\n",
 				ip_vs_proto_name(cp->protocol),
 				&cp->caddr.in6, ntohs(cp->cport),
 				&cp->vaddr.in6, ntohs(cp->vport),
 				&cp->daddr.in6, ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
-				(cp->timer.expires-jiffies)/HZ);
+				(cp->timer.expires-jiffies)/HZ, pe_data);
 		else
 #endif
 			seq_printf(seq,
 				"%-3s %08X %04X %08X %04X"
-				" %08X %04X %-11s %7lu\n",
+				" %08X %04X %-11s %7lu%s\n",
 				ip_vs_proto_name(cp->protocol),
 				ntohl(cp->caddr.ip), ntohs(cp->cport),
 				ntohl(cp->vaddr.ip), ntohs(cp->vport),
 				ntohl(cp->daddr.ip), ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
-				(cp->timer.expires-jiffies)/HZ);
+				(cp->timer.expires-jiffies)/HZ, pe_data);
 	}
 	return 0;
 }
-- 
1.7.1

