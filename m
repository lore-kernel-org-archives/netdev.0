From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/3] [TCP] Make tcpdiag_bc_run take tcpdiag_entry
Date: Fri, 15 Oct 2004 07:33:47 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041014213347.GB18433@gondor.apana.org.au>
References: <4164F60C.6080807@cosmosbay.com> <E1CFTUz-0007V6-00@gondolin.me.apana.org.au> <20041014213030.GA18433@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GID0FwUMdk1T2AWN"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <20041014213030.GA18433@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch adds a tcpdiag_entry struct and makes tcpdiag_bc_run use it
instead of a struct sock.  This will allow us to use tcpdiag_bc_run on
struct open_request in the next patch.

Please note that I've left the CONFIG_IPV6 defines in as to support
ipv6 modules we'll need to modularise tcpdiag itself.  I'll probably
do that after this is all fixed.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--GID0FwUMdk1T2AWN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p2

===== net/ipv4/tcp_diag.c 1.20 vs 1.21 =====
--- 1.20/net/ipv4/tcp_diag.c	2004-10-14 21:11:20 +10:00
+++ 1.21/net/ipv4/tcp_diag.c	2004-10-14 21:15:04 +10:00
@@ -29,6 +29,16 @@
 
 #include <linux/tcp_diag.h>
 
+struct tcpdiag_entry
+{
+	u32 *saddr;
+	u32 *daddr;
+	u16 sport;
+	u16 dport;
+	u16 family;
+	u16 userlocks;
+};
+
 static struct sock *tcpnl;
 
 
@@ -324,11 +334,11 @@
 }
 
 
-static int tcpdiag_bc_run(const void *bc, int len, struct sock *sk)
+static int tcpdiag_bc_run(const void *bc, int len,
+			  const struct tcpdiag_entry *entry)
 {
 	while (len > 0) {
 		int yes = 1;
-		struct inet_opt *inet = inet_sk(sk);
 		const struct tcpdiag_bc_op *op = bc;
 
 		switch (op->code) {
@@ -338,19 +348,19 @@
 			yes = 0;
 			break;
 		case TCPDIAG_BC_S_GE:
-			yes = inet->num >= op[1].no;
+			yes = entry->sport >= op[1].no;
 			break;
 		case TCPDIAG_BC_S_LE:
-			yes = inet->num <= op[1].no;
+			yes = entry->dport <= op[1].no;
 			break;
 		case TCPDIAG_BC_D_GE:
-			yes = ntohs(inet->dport) >= op[1].no;
+			yes = entry->dport >= op[1].no;
 			break;
 		case TCPDIAG_BC_D_LE:
-			yes = ntohs(inet->dport) <= op[1].no;
+			yes = entry->dport <= op[1].no;
 			break;
 		case TCPDIAG_BC_AUTO:
-			yes = !(sk->sk_userlocks & SOCK_BINDPORT_LOCK);
+			yes = !(entry->userlocks & SOCK_BINDPORT_LOCK);
 			break;
 		case TCPDIAG_BC_S_COND:
 		case TCPDIAG_BC_D_COND:
@@ -360,7 +370,7 @@
 
 			if (cond->port != -1 &&
 			    cond->port != (op->code == TCPDIAG_BC_S_COND ?
-					     inet->num : ntohs(inet->dport))) {
+					     entry->sport : entry->dport)) {
 				yes = 0;
 				break;
 			}
@@ -368,26 +378,14 @@
 			if (cond->prefix_len == 0)
 				break;
 
-#ifdef CONFIG_IPV6
-			if (sk->sk_family == AF_INET6) {
-				struct ipv6_pinfo *np = inet6_sk(sk);
-
-				if (op->code == TCPDIAG_BC_S_COND)
-					addr = (u32*)&np->rcv_saddr;
-				else
-					addr = (u32*)&np->daddr;
-			} else
-#endif
-			{
-				if (op->code == TCPDIAG_BC_S_COND)
-					addr = &inet->rcv_saddr;
-				else
-					addr = &inet->daddr;
-			}
+			if (op->code == TCPDIAG_BC_S_COND)
+				addr = entry->saddr;
+			else
+				addr = entry->daddr;
 
 			if (bitstring_match(addr, cond->addr, cond->prefix_len))
 				break;
-			if (sk->sk_family == AF_INET6 &&
+			if (entry->family == AF_INET6 &&
 			    cond->family == AF_INET) {
 				if (addr[0] == 0 && addr[1] == 0 &&
 				    addr[2] == htonl(0xffff) &&
@@ -472,8 +470,28 @@
 	struct tcpdiagreq *r = NLMSG_DATA(cb->nlh);
 
 	if (cb->nlh->nlmsg_len > 4 + NLMSG_SPACE(sizeof(*r))) {
+		struct tcpdiag_entry entry;
 		struct rtattr *bc = (struct rtattr *)(r + 1);
-		if (!tcpdiag_bc_run(RTA_DATA(bc), RTA_PAYLOAD(bc), sk))
+		struct inet_opt *inet = inet_sk(sk);
+
+		entry.family = sk->sk_family;
+#ifdef CONFIG_IPV6
+		if (entry.family == AF_INET6) {
+			struct ipv6_pinfo *np = inet6_sk(sk);
+
+			entry.saddr = np->rcv_saddr.s6_addr32;
+			entry.daddr = np->daddr.s6_addr32;
+		} else
+#endif
+		{
+			entry.saddr = &inet->rcv_saddr;
+			entry.daddr = &inet->daddr;
+		}
+		entry.sport = inet->num;
+		entry.dport = ntohs(inet->dport);
+		entry.userlocks = sk->sk_userlocks;
+
+		if (!tcpdiag_bc_run(RTA_DATA(bc), RTA_PAYLOAD(bc), &entry))
 			return 0;
 	}
 

--GID0FwUMdk1T2AWN--
