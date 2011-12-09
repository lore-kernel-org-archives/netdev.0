From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] iproute: Dump UDP sockets via netlink
Date: Fri, 09 Dec 2011 20:26:27 +0400
Message-ID: <4EE236B3.2090808@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:13284 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758Ab1LIQ0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:26:32 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since for UDP the same binary API is used, just rename tcp_show_netlink and others
into inet_show_netlink (and others) and wire the calls into udp-related paths.

Applies on top of previous patch with support for the new sock_diag api.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff -u b/misc/ss.c b/misc/ss.c
--- b/misc/ss.c
+++ b/misc/ss.c
@@ -1410,7 +1410,7 @@
 	}
 }
 
-static int tcp_show_sock(struct nlmsghdr *nlh, struct filter *f)
+static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 {
 	struct inet_diag_msg *r = NLMSG_DATA(nlh);
 	struct tcpstat s;
@@ -1474,7 +1474,7 @@
 	return 0;
 }
 
-static int __tcp_show_netlink(struct filter *f, FILE *dump_fp, int family, int socktype)
+static int __inet_show_netlink(struct filter *f, FILE *dump_fp, int family, int socktype)
 {
 	int fd;
 	struct sockaddr_nl nladdr;
@@ -1590,7 +1590,7 @@
 				return 0;
 			}
 			if (!dump_fp) {
-				err = tcp_show_sock(h, NULL);
+				err = inet_show_sock(h, NULL);
 				if (err < 0)
 					return err;
 			}
@@ -1610,19 +1610,19 @@
 	return 0;
 }
 
-static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
+static int inet_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 {
 	int err = 0;
 
 	if (f->families & (1 << AF_INET))
-		err |= __tcp_show_netlink(f, dump_fp, AF_INET, socktype);
+		err |= __inet_show_netlink(f, dump_fp, AF_INET, socktype);
 	if (f->families & (1 << AF_INET6))
-		err |= __tcp_show_netlink(f, dump_fp, AF_INET6, socktype);
+		err |= __inet_show_netlink(f, dump_fp, AF_INET6, socktype);
 
 	return err;
 }
 
-static int tcp_show_netlink_file(struct filter *f)
+static int inet_show_netlink_file(struct filter *f)
 {
 	FILE	*fp;
 	char	buf[8192];
@@ -1672,7 +1672,7 @@
 			return -1;
 		}
 
-		err = tcp_show_sock(h, f);
+		err = inet_show_sock(h, f);
 		if (err < 0)
 			return err;
 	}
@@ -1687,10 +1687,10 @@
 	dg_proto = TCP_PROTO;
 
 	if (getenv("TCPDIAG_FILE"))
-		return tcp_show_netlink_file(f);
+		return inet_show_netlink_file(f);
 
 	if (!getenv("PROC_NET_TCP") && !getenv("PROC_ROOT")
-	    && tcp_show_netlink(f, NULL, socktype) == 0)
+	    && inet_show_netlink(f, NULL, socktype) == 0)
 		return 0;
 
 	/* Sigh... We have to parse /proc/net/tcp... */
@@ -1852,6 +1852,15 @@
 {
 	FILE *fp = NULL;
 
+	if (getenv("TCPDIAG_FILE"))
+		return inet_show_netlink_file(f);
+
+	if (!getenv("PROC_NET_TCP") && !getenv("PROC_ROOT")
+	    && inet_show_netlink(f, NULL, IPPROTO_UDP) == 0)
+		return 0;
+
+	/* legacy proc files parse */
+
 	dg_proto = UDP_PROTO;
 
 	if (f->families&(1<<AF_INET)) {
@@ -2787,7 +2796,7 @@
 
 	if (dump_tcpdiag) {
 		FILE *dump_fp = stdout;
-		if (!(current_filter.dbs & (1<<TCP_DB))) {
+		if (!(current_filter.dbs & ((1<<TCP_DB) | (1<<UDP_DB)))) {
 			fprintf(stderr, "ss: tcpdiag dump requested and no tcp in filter.\n");
 			exit(0);
 		}
@@ -2798,7 +2807,13 @@
 				exit(-1);
 			}
 		}
-		tcp_show_netlink(&current_filter, dump_fp, IPPROTO_TCP);
+
+		if (current_filter.dbs & (1<<UDP_DB))
+			inet_show_netlink(&current_filter, dump_fp, IPPROTO_UDP);
+
+		if (current_filter.dbs & (1<<TCP_DB))
+			inet_show_netlink(&current_filter, dump_fp, IPPROTO_TCP);
+
 		fflush(dump_fp);
 		exit(0);
 	}
