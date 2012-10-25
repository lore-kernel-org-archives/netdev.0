From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/5] ss: Rename some tcp- names into inet-
Date: Thu, 25 Oct 2012 17:18:31 +0400
Message-ID: <50893C27.6030601@parallels.com>
References: <50893BAF.7030500@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44844 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759022Ab2JYNSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 09:18:33 -0400
In-Reply-To: <50893BAF.7030500@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sock-diag is capable to diag udp sockets as well. Prepare the
ss code for this by first renaming soon-to-be-generic tcp-s names
into inet-s.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 misc/ss.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index d00d3e7..3bceedf 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1431,7 +1431,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
 	}
 }
 
-static int tcp_show_sock(struct nlmsghdr *nlh, struct filter *f)
+static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 {
 	struct inet_diag_msg *r = NLMSG_DATA(nlh);
 	struct tcpstat s;
@@ -1495,7 +1495,7 @@ static int tcp_show_sock(struct nlmsghdr *nlh, struct filter *f)
 	return 0;
 }
 
-static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
+static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
 {
 	int fd;
 	struct sockaddr_nl nladdr;
@@ -1517,7 +1517,10 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 	nladdr.nl_family = AF_NETLINK;
 
 	req.nlh.nlmsg_len = sizeof(req);
-	req.nlh.nlmsg_type = socktype;
+	if (protocol == IPPROTO_TCP)
+		req.nlh.nlmsg_type = TCPDIAG_GETSOCK;
+	else
+		req.nlh.nlmsg_type = DCCPDIAG_GETSOCK;
 	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
 	req.nlh.nlmsg_pid = 0;
 	req.nlh.nlmsg_seq = 123456;
@@ -1626,7 +1629,7 @@ static int tcp_show_netlink(struct filter *f, FILE *dump_fp, int socktype)
 					h = NLMSG_NEXT(h, status);
 					continue;
 				}
-				err = tcp_show_sock(h, NULL);
+				err = inet_show_sock(h, NULL);
 				if (err < 0) {
 					close(fd);
 					return err;
@@ -1699,7 +1702,7 @@ static int tcp_show_netlink_file(struct filter *f)
 			return -1;
 		}
 
-		err = tcp_show_sock(h, f);
+		err = inet_show_sock(h, f);
 		if (err < 0)
 			return err;
 	}
@@ -1717,7 +1720,7 @@ static int tcp_show(struct filter *f, int socktype)
 		return tcp_show_netlink_file(f);
 
 	if (!getenv("PROC_NET_TCP") && !getenv("PROC_ROOT")
-	    && tcp_show_netlink(f, NULL, socktype) == 0)
+	    && inet_show_netlink(f, NULL, socktype) == 0)
 		return 0;
 
 	/* Sigh... We have to parse /proc/net/tcp... */
@@ -2980,7 +2983,7 @@ int main(int argc, char *argv[])
 				exit(-1);
 			}
 		}
-		tcp_show_netlink(&current_filter, dump_fp, TCPDIAG_GETSOCK);
+		inet_show_netlink(&current_filter, dump_fp, IPPROTO_TCP);
 		fflush(dump_fp);
 		exit(0);
 	}
@@ -3048,8 +3051,8 @@ int main(int argc, char *argv[])
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
-- 
1.7.1
