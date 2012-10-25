From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/5] ss: Support sock-diag
Date: Thu, 25 Oct 2012 17:23:36 +0400
Message-ID: <50893D58.3030808@parallels.com>
References: <50893BAF.7030500@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38445 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759434Ab2JYNXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 09:23:37 -0400
In-Reply-To: <50893BAF.7030500@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That is -- write the code, that sends diag request in new format. It's
mostly copied from tcp-diag code. Plus, sock-diag differentiates sockets
by families, thus we have to send two requests sequentially.

If we fail to submit new sock-diag request, try to fall-back and submit
the legacy tcp-diag one.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 misc/ss.c |   95 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 87 insertions(+), 8 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 27feeb8..1ceb026 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1561,9 +1561,76 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
 	return 0;
 }
 
+static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
+{
+	struct sockaddr_nl nladdr;
+	struct {
+		struct nlmsghdr nlh;
+		struct inet_diag_req_v2 r;
+	} req;
+	char    *bc = NULL;
+	int	bclen;
+	struct msghdr msg;
+	struct rtattr rta;
+	struct iovec iov[3];
+
+	if (family == PF_UNSPEC)
+		return tcpdiag_send(fd, protocol, f);
+
+	memset(&nladdr, 0, sizeof(nladdr));
+	nladdr.nl_family = AF_NETLINK;
+
+	req.nlh.nlmsg_len = sizeof(req);
+	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
+	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
+	req.nlh.nlmsg_pid = 0;
+	req.nlh.nlmsg_seq = 123456;
+	memset(&req.r, 0, sizeof(req.r));
+	req.r.sdiag_family = family;
+	req.r.sdiag_protocol = protocol;
+	req.r.idiag_states = f->states;
+	if (show_mem) {
+		req.r.idiag_ext |= (1<<(INET_DIAG_MEMINFO-1));
+		req.r.idiag_ext |= (1<<(INET_DIAG_SKMEMINFO-1));
+	}
+
+	if (show_tcpinfo) {
+		req.r.idiag_ext |= (1<<(INET_DIAG_INFO-1));
+		req.r.idiag_ext |= (1<<(INET_DIAG_VEGASINFO-1));
+		req.r.idiag_ext |= (1<<(INET_DIAG_CONG-1));
+	}
+
+	iov[0] = (struct iovec){
+		.iov_base = &req,
+		.iov_len = sizeof(req)
+	};
+	if (f->f) {
+		bclen = ssfilter_bytecompile(f->f, &bc);
+		rta.rta_type = INET_DIAG_REQ_BYTECODE;
+		rta.rta_len = RTA_LENGTH(bclen);
+		iov[1] = (struct iovec){ &rta, sizeof(rta) };
+		iov[2] = (struct iovec){ bc, bclen };
+		req.nlh.nlmsg_len += RTA_LENGTH(bclen);
+	}
+
+	msg = (struct msghdr) {
+		.msg_name = (void*)&nladdr,
+		.msg_namelen = sizeof(nladdr),
+		.msg_iov = iov,
+		.msg_iovlen = f->f ? 3 : 1,
+	};
+
+	if (sendmsg(fd, &msg, 0) < 0) {
+		close(fd);
+		return -1;
+	}
+
+	return 0;
+}
+
 static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
 {
-	int fd;
+	int fd, family;
 	struct sockaddr_nl nladdr;
 	struct msghdr msg;
 	char	buf[8192];
@@ -1572,7 +1639,9 @@ static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
 	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
 		return -1;
 
-	if (tcpdiag_send(fd, protocol, f))
+	family = PF_INET;
+again:
+	if (sockdiag_send(family, fd, protocol, f))
 		return -1;
 
 	memset(&nladdr, 0, sizeof(nladdr));
@@ -1620,15 +1689,19 @@ static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
 			    h->nlmsg_seq != 123456)
 				goto skip_it;
 
-			if (h->nlmsg_type == NLMSG_DONE) {
-				close(fd);
-				return 0;
-			}
+			if (h->nlmsg_type == NLMSG_DONE)
+				goto done;
+
 			if (h->nlmsg_type == NLMSG_ERROR) {
 				struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
 				if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
 					fprintf(stderr, "ERROR truncated\n");
 				} else {
+					if (family != PF_UNSPEC) {
+						family = PF_UNSPEC;
+						goto again;
+					}
+
 					errno = -err->error;
 					if (errno == EOPNOTSUPP) {
 						close(fd);
@@ -1636,8 +1709,8 @@ static int inet_show_netlink(struct filter *f, FILE *dump_fp, int protocol)
 					}
 					perror("TCPDIAG answers");
 				}
-				close(fd);
-				return 0;
+
+				goto done;
 			}
 			if (!dump_fp) {
 				if (!(f->families & (1<<r->idiag_family))) {
@@ -1663,6 +1736,12 @@ skip_it:
 			exit(1);
 		}
 	}
+done:
+	if (family == PF_INET) {
+		family = PF_INET6;
+		goto again;
+	}
+
 	close(fd);
 	return 0;
 }
-- 
1.7.1
