From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ipvs -- format /proc/net/ip_vs_conn entries in dotted
 notation.
Date: Mon, 15 Sep 2003 14:43:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915144329.6dc442ad.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, lvs-users@LinuxVirtualServer.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Easier for human's to read dotted notation IP addresses.

Assumes earlier seq_file patch.

diff -Nru a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
--- a/net/ipv4/ipvs/ip_vs_conn.c	Mon Sep 15 14:31:28 2003
+++ b/net/ipv4/ipvs/ip_vs_conn.c	Mon Sep 15 14:31:28 2003
@@ -682,23 +682,33 @@
 		ct_read_unlock(l - ip_vs_conn_tab);
 }
 
+static inline void addr_format(char * tmp,__u32 addr, __u16 port)
+{
+	sprintf(tmp, "%u.%u.%u.%u:%u",
+		NIPQUAD(addr), ntohs(port));
+}
+
+
 static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
 {
 
 	if (v == SEQ_START_TOKEN)
-		seq_puts(seq,
-   "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires\n");
+		seq_printf(seq, "%-3s %-18s %-18s %-18s %-11s %-6s\n",
+			   "Pro", "From", "To", "Destination", 
+			   "State", "Expire");
 	else {
 		const struct ip_vs_conn *cp = v;
+		char from[20], to[20], dest[20];
+
+		addr_format(from, cp->caddr, ntohs(cp->cport));
+		addr_format(to, cp->vaddr, ntohs(cp->vport));
+		addr_format(dest, cp->daddr, ntohs(cp->dport));
 
-		seq_printf(seq,
-			"%-3s %08X %04X %08X %04X %08X %04X %-11s %7lu\n",
-				ip_vs_proto_name(cp->protocol),
-				ntohl(cp->caddr), ntohs(cp->cport),
-				ntohl(cp->vaddr), ntohs(cp->vport),
-				ntohl(cp->daddr), ntohs(cp->dport),
-				ip_vs_state_name(cp->protocol, cp->state),
-				(cp->timer.expires-jiffies)/HZ);
+		seq_printf(seq,	"%-3s %-18s %-18s %-18s %-11s %7lu\n",
+			   ip_vs_proto_name(cp->protocol),
+			   from, to, dest,
+			   ip_vs_state_name(cp->protocol, cp->state),
+			   (cp->timer.expires-jiffies)/HZ);
 	}
 	return 0;
 }
