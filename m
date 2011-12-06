From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] iproute: Use SOCK_DIAG_BY_FAMILY messages
Date: Tue, 06 Dec 2011 22:02:00 +0400
Message-ID: <4EDE5898.5090809@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:34610 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778Ab1LFSCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 13:02:05 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applies to cd72dcf13c8a4948ee5706794714287eeff62c90 commit of the
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git tree

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index de6f1fc..7b6113a 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -6,6 +6,7 @@
 /* Just some random number */
 #define TCPDIAG_GETSOCK 18
 #define DCCPDIAG_GETSOCK 19
+#define SOCK_DIAG_BY_FAMILY 20
 
 #define INET_DIAG_GETSOCK_MAX 24
 
@@ -22,7 +23,7 @@ struct inet_diag_sockid {
 
 /* Request structure */
 
-struct inet_diag_req {
+struct inet_diag_req_compat {
 	__u8	idiag_family;		/* Family of addresses. */
 	__u8	idiag_src_len;
 	__u8	idiag_dst_len;
@@ -34,6 +35,15 @@ struct inet_diag_req {
 	__u32	idiag_dbs;		/* Tables to dump (NI) */
 };
 
+struct inet_diag_req {
+	__u8	sdiag_family;
+	__u8	sdiag_protocol;
+	__u8	idiag_ext;
+	__u8	pad;
+	__u32	idiag_states;
+	struct inet_diag_sockid id;
+};
+
 enum {
 	INET_DIAG_REQ_NONE,
 	INET_DIAG_REQ_BYTECODE,
diff --git a/misc/ss.c b/misc/ss.c
index 5ce40c0..49afd4a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1474,7 +1474,7 @@ static int tcp_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	return 0;
 }
 
-static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
+static int __tcp_show_netlink(struct filter *f, FILE *dump_fp, int family, int socktype)
 {
 	int fd;
 	struct sockaddr_nl nladdr;
@@ -1496,12 +1496,13 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 	nladdr.nl_family = AF_NETLINK;
 
 	req.nlh.nlmsg_len = sizeof(req);
-	req.nlh.nlmsg_type = socktype;
+	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
 	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
 	req.nlh.nlmsg_pid = 0;
 	req.nlh.nlmsg_seq = 123456;
 	memset(&req.r, 0, sizeof(req.r));
-	req.r.idiag_family = AF_INET;
+	req.r.sdiag_family = family;
+	req.r.sdiag_protocol = socktype;
 	req.r.idiag_states = f->states;
 	if (show_mem)
 		req.r.idiag_ext |= (1<<(INET_DIAG_MEMINFO-1));
@@ -1589,10 +1590,6 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 				return 0;
 			}
 			if (!dump_fp) {
-				if (!(f->families & (1<<r->idiag_family))) {
-					h = NLMSG_NEXT(h, status);
-					continue;
-				}
 				err = tcp_show_sock(h, NULL);
 				if (err < 0)
 					return err;
@@ -1613,6 +1610,18 @@ skip_it:
 	return 0;
 }
 
+static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
+{
+	int err = 0;
+
+	if (f->families & (1 << AF_INET))
+		err |= __tcp_show_netlink(f, dump_fp, AF_INET, socktype);
+	if (f->families & (1 << AF_INET6))
+		err |= __tcp_show_netlink(f, dump_fp, AF_INET6, socktype);
+
+	return err;
+}
+
 static int tcp_show_netlink_file(struct filter *f)
 {
 	FILE	*fp;
@@ -2789,7 +2798,7 @@ int main(int argc, char *argv[])
 				exit(-1);
 			}
 		}
-		tcp_show_netlink(&current_filter, dump_fp, TCPDIAG_GETSOCK);
+		tcp_show_netlink(&current_filter, dump_fp, IPPROTO_TCP);
 		fflush(dump_fp);
 		exit(0);
 	}
@@ -2857,8 +2866,8 @@ int main(int argc, char *argv[])
 	if (current_filter.dbs & (1<<UDP_DB))
 		udp_show(&current_filter);
 	if (current_filter.dbs & (1<<TCP_DB))
-		tcp_show(&current_filter, TCPDIAG_GETSOCK);
+		tcp_show(&current_filter, IPPROTO_TCP);
 	if (current_filter.dbs & (1<<DCCP_DB))
-		tcp_show(&current_filter, DCCPDIAG_GETSOCK);
+		tcp_show(&current_filter, IPPROTO_DCCP);
 	return 0;
 }
