From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] iproute: Dump unix sockets via netlink
Date: Thu, 15 Dec 2011 17:28:15 +0400
Message-ID: <4EE9F5EF.8000101@parallels.com>
References: <4EE9EB2A.4040909@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2765 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544Ab1LON2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 08:28:23 -0500
In-Reply-To: <4EE9EB2A.4040909@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get the same info as from /proc file plus the peer inode.

Applies on top of new sock diag patch and udp diag patch.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
new file mode 100644
index 0000000..3f7afb0
--- /dev/null
+++ b/include/linux/unix_diag.h
@@ -0,0 +1,45 @@
+#ifndef __UNIX_DIAG_H__
+#define __UNIX_DIAG_H__
+
+struct unix_diag_req {
+	__u8	sdiag_family;
+	__u8	sdiag_protocol;
+	__u16	pad;
+	__u32	udiag_states;
+	__u32	udiag_ino;
+	__u32	udiag_show;
+	__u32	udiag_cookie[2];
+};
+
+#define UDIAG_SHOW_NAME		0x00000001	/* show name (not path) */
+#define UDIAG_SHOW_VFS		0x00000002	/* show VFS inode info */
+#define UDIAG_SHOW_PEER		0x00000004	/* show peer socket info */
+#define UDIAG_SHOW_ICONS	0x00000008	/* show pending connections */
+#define UDIAG_SHOW_RQLEN	0x00000010	/* show skb receive queue len */
+
+struct unix_diag_msg {
+	__u8	udiag_family;
+	__u8	udiag_type;
+	__u8	udiag_state;
+	__u8	pad;
+
+	__u32	udiag_ino;
+	__u32	udiag_cookie[2];
+};
+
+enum {
+	UNIX_DIAG_NAME,
+	UNIX_DIAG_VFS,
+	UNIX_DIAG_PEER,
+	UNIX_DIAG_ICONS,
+	UNIX_DIAG_RQLEN,
+
+	UNIX_DIAG_MAX,
+};
+
+struct unix_diag_vfs {
+	__u32	udiag_vfs_ino;
+	__u32	udiag_vfs_dev;
+};
+
+#endif
diff --git a/misc/ss.c b/misc/ss.c
index a5e232b..6f2995e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -35,6 +35,7 @@
 
 #include <netinet/tcp.h>
 #include <linux/inet_diag.h>
+#include <linux/unix_diag.h>
 
 int resolve_hosts = 0;
 int resolve_services = 1;
@@ -2011,6 +2012,179 @@ void unix_list_print(struct unixstat *list, struct filter *f)
 	}
 }
 
+static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
+{
+	struct unix_diag_msg *r = NLMSG_DATA(nlh);
+	struct rtattr *tb[UNIX_DIAG_MAX+1];
+	char name[128];
+	int peer_ino;
+	int rqlen;
+
+	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
+		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
+
+	if (netid_width)
+		printf("%-*s ", netid_width,
+				r->udiag_type == SOCK_STREAM ? "u_str" : "u_dgr");
+	if (state_width)
+		printf("%-*s ", state_width, sstate_name[r->udiag_state]);
+
+	if (tb[UNIX_DIAG_RQLEN])
+		rqlen = *(int *)RTA_DATA(tb[UNIX_DIAG_RQLEN]);
+	else
+		rqlen = 0;
+
+	printf("%-6d %-6d ", rqlen, 0);
+
+	if (tb[UNIX_DIAG_NAME]) {
+		int len = RTA_PAYLOAD(tb[UNIX_DIAG_NAME]);
+
+		memcpy(name, RTA_DATA(tb[UNIX_DIAG_NAME]), len);
+		name[len] = '\0';
+		if (name[0] == '\0')
+			name[0] = '@';
+	} else
+		sprintf(name, "*");
+
+	if (tb[UNIX_DIAG_PEER])
+		peer_ino = *(int *)RTA_DATA(tb[UNIX_DIAG_PEER]);
+	else
+		peer_ino = 0;
+
+	printf("%*s %-*d %*s %-*d",
+			addr_width, name,
+			serv_width, r->udiag_ino,
+			addr_width, "*", /* FIXME */
+			serv_width, peer_ino);
+
+	if (show_users) {
+		char ubuf[4096];
+		if (find_users(r->udiag_ino, ubuf, sizeof(ubuf)) > 0)
+			printf(" users:(%s)", ubuf);
+	}
+
+	printf("\n");
+
+	return 0;
+}
+
+static int unix_show_netlink(struct filter *f, FILE *dump_fp)
+{
+	int fd;
+	struct sockaddr_nl nladdr;
+	struct {
+		struct nlmsghdr nlh;
+		struct unix_diag_req r;
+	} req;
+	struct msghdr msg;
+	char	buf[8192];
+	struct iovec iov[3];
+
+	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
+		return -1;
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
+	req.r.sdiag_family = AF_UNIX;
+	req.r.sdiag_protocol = 0; /* ignored */
+	req.r.udiag_states = f->states;
+	req.r.udiag_show = UDIAG_SHOW_NAME | UDIAG_SHOW_PEER | UDIAG_SHOW_RQLEN;
+
+	iov[0] = (struct iovec){
+		.iov_base = &req,
+		.iov_len = sizeof(req)
+	};
+
+	msg = (struct msghdr) {
+		.msg_name = (void*)&nladdr,
+		.msg_namelen = sizeof(nladdr),
+		.msg_iov = iov,
+		.msg_iovlen = f->f ? 3 : 1,
+	};
+
+	if (sendmsg(fd, &msg, 0) < 0)
+		return -1;
+
+	iov[0] = (struct iovec){
+		.iov_base = buf,
+		.iov_len = sizeof(buf)
+	};
+
+	while (1) {
+		int status;
+		struct nlmsghdr *h;
+
+		msg = (struct msghdr) {
+			(void*)&nladdr, sizeof(nladdr),
+			iov,	1,
+			NULL,	0,
+			0
+		};
+
+		status = recvmsg(fd, &msg, 0);
+
+		if (status < 0) {
+			if (errno == EINTR)
+				continue;
+			perror("OVERRUN");
+			continue;
+		}
+		if (status == 0) {
+			fprintf(stderr, "EOF on netlink\n");
+			return 0;
+		}
+
+		if (dump_fp)
+			fwrite(buf, 1, NLMSG_ALIGN(status), dump_fp);
+
+		h = (struct nlmsghdr*)buf;
+		while (NLMSG_OK(h, status)) {
+			int err;
+
+			if (/*h->nlmsg_pid != rth->local.nl_pid ||*/
+			    h->nlmsg_seq != 123456)
+				goto skip_it;
+
+			if (h->nlmsg_type == NLMSG_DONE)
+				return 0;
+			if (h->nlmsg_type == NLMSG_ERROR) {
+				struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
+				if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
+					fprintf(stderr, "ERROR truncated\n");
+				} else {
+					errno = -err->error;
+					perror("TCPDIAG answers");
+				}
+				return 0;
+			}
+			if (!dump_fp) {
+				err = unix_show_sock(h, f);
+				if (err < 0)
+					return err;
+			}
+
+skip_it:
+			h = NLMSG_NEXT(h, status);
+		}
+		if (msg.msg_flags & MSG_TRUNC) {
+			fprintf(stderr, "Message truncated\n");
+			continue;
+		}
+		if (status) {
+			fprintf(stderr, "!!!Remnant of size %d\n", status);
+			exit(1);
+		}
+	}
+	return 0;
+}
+
 int unix_show(struct filter *f)
 {
 	FILE *fp;
@@ -2020,6 +2194,10 @@ int unix_show(struct filter *f)
 	int  cnt;
 	struct unixstat *list = NULL;
 
+	if (!getenv("PROC_NET_UNIX") && !getenv("PROC_ROOT")
+	    && unix_show_netlink(f, NULL) == 0)
+		return 0;
+
 	if ((fp = net_unix_open()) == NULL)
 		return -1;
 	fgets(buf, sizeof(buf)-1, fp);
