From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] ss: allow to retrieve AF_PACKET info via netlink
Date: Fri, 17 May 2013 10:56:20 +0200
Message-ID: <1368780980-7601-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54236 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250Ab3EQI4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 04:56:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add support of netlink messages for AF_PACKET and thus it allows
to get filter information of this kind of sockets.
To dump these filters info the option --bfp must be specified and the user
must have admin rights.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/filter.h      | 138 ++++++++++++++++++++++++++++++++
 include/linux/packet_diag.h |  79 ++++++++++++++++++
 misc/ss.c                   | 190 +++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 406 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/filter.h
 create mode 100644 include/linux/packet_diag.h

diff --git a/include/linux/filter.h b/include/linux/filter.h
new file mode 100644
index 0000000..9a46cb6
--- /dev/null
+++ b/include/linux/filter.h
@@ -0,0 +1,138 @@
+/*
+ * Linux Socket Filter Data Structures
+ */
+
+#ifndef __LINUX_FILTER_H__
+#define __LINUX_FILTER_H__
+
+
+#include <linux/types.h>
+
+
+/*
+ * Current version of the filter code architecture.
+ */
+#define BPF_MAJOR_VERSION 1
+#define BPF_MINOR_VERSION 1
+
+/*
+ *	Try and keep these values and structures similar to BSD, especially
+ *	the BPF code definitions which need to match so you can share filters
+ */
+ 
+struct sock_filter {	/* Filter block */
+	__u16	code;   /* Actual filter code */
+	__u8	jt;	/* Jump true */
+	__u8	jf;	/* Jump false */
+	__u32	k;      /* Generic multiuse field */
+};
+
+struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
+	unsigned short		len;	/* Number of filter blocks */
+	struct sock_filter *filter;
+};
+
+/*
+ * Instruction classes
+ */
+
+#define BPF_CLASS(code) ((code) & 0x07)
+#define         BPF_LD          0x00
+#define         BPF_LDX         0x01
+#define         BPF_ST          0x02
+#define         BPF_STX         0x03
+#define         BPF_ALU         0x04
+#define         BPF_JMP         0x05
+#define         BPF_RET         0x06
+#define         BPF_MISC        0x07
+
+/* ld/ldx fields */
+#define BPF_SIZE(code)  ((code) & 0x18)
+#define         BPF_W           0x00
+#define         BPF_H           0x08
+#define         BPF_B           0x10
+#define BPF_MODE(code)  ((code) & 0xe0)
+#define         BPF_IMM         0x00
+#define         BPF_ABS         0x20
+#define         BPF_IND         0x40
+#define         BPF_MEM         0x60
+#define         BPF_LEN         0x80
+#define         BPF_MSH         0xa0
+
+/* alu/jmp fields */
+#define BPF_OP(code)    ((code) & 0xf0)
+#define         BPF_ADD         0x00
+#define         BPF_SUB         0x10
+#define         BPF_MUL         0x20
+#define         BPF_DIV         0x30
+#define         BPF_OR          0x40
+#define         BPF_AND         0x50
+#define         BPF_LSH         0x60
+#define         BPF_RSH         0x70
+#define         BPF_NEG         0x80
+#define		BPF_MOD		0x90
+#define		BPF_XOR		0xa0
+
+#define         BPF_JA          0x00
+#define         BPF_JEQ         0x10
+#define         BPF_JGT         0x20
+#define         BPF_JGE         0x30
+#define         BPF_JSET        0x40
+#define BPF_SRC(code)   ((code) & 0x08)
+#define         BPF_K           0x00
+#define         BPF_X           0x08
+
+/* ret - BPF_K and BPF_X also apply */
+#define BPF_RVAL(code)  ((code) & 0x18)
+#define         BPF_A           0x10
+
+/* misc */
+#define BPF_MISCOP(code) ((code) & 0xf8)
+#define         BPF_TAX         0x00
+#define         BPF_TXA         0x80
+
+#ifndef BPF_MAXINSNS
+#define BPF_MAXINSNS 4096
+#endif
+
+/*
+ * Macros for filter block array initializers.
+ */
+#ifndef BPF_STMT
+#define BPF_STMT(code, k) { (unsigned short)(code), 0, 0, k }
+#endif
+#ifndef BPF_JUMP
+#define BPF_JUMP(code, k, jt, jf) { (unsigned short)(code), jt, jf, k }
+#endif
+
+/*
+ * Number of scratch memory words for: BPF_ST and BPF_STX
+ */
+#define BPF_MEMWORDS 16
+
+/* RATIONALE. Negative offsets are invalid in BPF.
+   We use them to reference ancillary data.
+   Unlike introduction new instructions, it does not break
+   existing compilers/optimizers.
+ */
+#define SKF_AD_OFF    (-0x1000)
+#define SKF_AD_PROTOCOL 0
+#define SKF_AD_PKTTYPE 	4
+#define SKF_AD_IFINDEX 	8
+#define SKF_AD_NLATTR	12
+#define SKF_AD_NLATTR_NEST	16
+#define SKF_AD_MARK 	20
+#define SKF_AD_QUEUE	24
+#define SKF_AD_HATYPE	28
+#define SKF_AD_RXHASH	32
+#define SKF_AD_CPU	36
+#define SKF_AD_ALU_XOR_X	40
+#define SKF_AD_VLAN_TAG	44
+#define SKF_AD_VLAN_TAG_PRESENT 48
+#define SKF_AD_PAY_OFFSET	52
+#define SKF_AD_MAX	56
+#define SKF_NET_OFF   (-0x100000)
+#define SKF_LL_OFF    (-0x200000)
+
+
+#endif /* __LINUX_FILTER_H__ */
diff --git a/include/linux/packet_diag.h b/include/linux/packet_diag.h
new file mode 100644
index 0000000..b2cc0cd
--- /dev/null
+++ b/include/linux/packet_diag.h
@@ -0,0 +1,79 @@
+#ifndef __PACKET_DIAG_H__
+#define __PACKET_DIAG_H__
+
+#include <linux/types.h>
+
+struct packet_diag_req {
+	__u8	sdiag_family;
+	__u8	sdiag_protocol;
+	__u16	pad;
+	__u32	pdiag_ino;
+	__u32	pdiag_show;
+	__u32	pdiag_cookie[2];
+};
+
+#define PACKET_SHOW_INFO	0x00000001 /* Basic packet_sk information */
+#define PACKET_SHOW_MCLIST	0x00000002 /* A set of packet_diag_mclist-s */
+#define PACKET_SHOW_RING_CFG	0x00000004 /* Rings configuration parameters */
+#define PACKET_SHOW_FANOUT	0x00000008
+#define PACKET_SHOW_MEMINFO	0x00000010
+#define PACKET_SHOW_FILTER	0x00000020
+
+struct packet_diag_msg {
+	__u8	pdiag_family;
+	__u8	pdiag_type;
+	__u16	pdiag_num;
+
+	__u32	pdiag_ino;
+	__u32	pdiag_cookie[2];
+};
+
+enum {
+	PACKET_DIAG_INFO,
+	PACKET_DIAG_MCLIST,
+	PACKET_DIAG_RX_RING,
+	PACKET_DIAG_TX_RING,
+	PACKET_DIAG_FANOUT,
+	PACKET_DIAG_UID,
+	PACKET_DIAG_MEMINFO,
+	PACKET_DIAG_FILTER,
+
+	__PACKET_DIAG_MAX,
+};
+
+#define PACKET_DIAG_MAX (__PACKET_DIAG_MAX - 1)
+
+struct packet_diag_info {
+	__u32	pdi_index;
+	__u32	pdi_version;
+	__u32	pdi_reserve;
+	__u32	pdi_copy_thresh;
+	__u32	pdi_tstamp;
+	__u32	pdi_flags;
+
+#define PDI_RUNNING	0x1
+#define PDI_AUXDATA	0x2
+#define PDI_ORIGDEV	0x4
+#define PDI_VNETHDR	0x8
+#define PDI_LOSS	0x10
+};
+
+struct packet_diag_mclist {
+	__u32	pdmc_index;
+	__u32	pdmc_count;
+	__u16	pdmc_type;
+	__u16	pdmc_alen;
+	__u8	pdmc_addr[MAX_ADDR_LEN];
+};
+
+struct packet_diag_ring {
+	__u32	pdr_block_size;
+	__u32	pdr_block_nr;
+	__u32	pdr_frame_size;
+	__u32	pdr_frame_nr;
+	__u32	pdr_retire_tmo;
+	__u32	pdr_sizeof_priv;
+	__u32	pdr_features;
+};
+
+#endif
diff --git a/misc/ss.c b/misc/ss.c
index 5493630..2730cb2 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -36,6 +36,9 @@
 #include <linux/sock_diag.h>
 #include <linux/inet_diag.h>
 #include <linux/unix_diag.h>
+#include <linux/netdevice.h>	/* for MAX_ADDR_LEN */
+#include <linux/filter.h>
+#include <linux/packet_diag.h>
 
 int resolve_hosts = 0;
 int resolve_services = 1;
@@ -45,6 +48,7 @@ int show_details = 0;
 int show_users = 0;
 int show_mem = 0;
 int show_tcpinfo = 0;
+int show_bpf = 0;
 
 int netid_width;
 int state_width;
@@ -2389,6 +2393,181 @@ static int unix_show(struct filter *f)
 	return 0;
 }
 
+static int packet_show_sock(struct nlmsghdr *nlh, struct filter *f)
+{
+	struct packet_diag_msg *r = NLMSG_DATA(nlh);
+	struct rtattr *tb[PACKET_DIAG_MAX+1];
+	__u32 rq;
+
+	parse_rtattr(tb, PACKET_DIAG_MAX, (struct rtattr*)(r+1),
+		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
+
+	/* use /proc/net/packet if all info are not available */
+	if (!tb[PACKET_DIAG_MEMINFO])
+		return -1;
+
+	if (netid_width)
+		printf("%-*s ", netid_width,
+				r->pdiag_type == SOCK_RAW ? "p_raw" : "p_dgr");
+	if (state_width)
+		printf("%-*s ", state_width, "UNCONN");
+
+	if (tb[PACKET_DIAG_MEMINFO]) {
+		__u32 *skmeminfo = RTA_DATA(tb[PACKET_DIAG_MEMINFO]);
+
+		rq = skmeminfo[SK_MEMINFO_RMEM_ALLOC];
+	} else
+		rq = 0;
+	printf("%-6d %-6d ", rq, 0);
+
+	if (r->pdiag_num == 3) {
+		printf("%*s:", addr_width, "*");
+	} else {
+		char tb2[16];
+		printf("%*s:", addr_width,
+		       ll_proto_n2a(htons(r->pdiag_num), tb2, sizeof(tb2)));
+	}
+	if (tb[PACKET_DIAG_INFO]) {
+		struct packet_diag_info *pinfo = RTA_DATA(tb[PACKET_DIAG_INFO]);
+
+		if (pinfo->pdi_index == 0)
+			printf("%-*s ", serv_width, "*");
+		else
+			printf("%-*s ", serv_width, xll_index_to_name(pinfo->pdi_index));
+	} else
+		printf("%-*s ", serv_width, "*");
+
+	printf("%*s*%-*s",
+	       addr_width, "", serv_width, "");
+
+	if (show_users) {
+		char ubuf[4096];
+		if (find_users(r->pdiag_ino, ubuf, sizeof(ubuf)) > 0)
+			printf(" users:(%s)", ubuf);
+	}
+	if (show_details) {
+		__u32 uid = 0;
+
+		if (tb[PACKET_DIAG_UID])
+			uid = *(__u32 *)RTA_DATA(tb[PACKET_DIAG_UID]);
+
+		printf(" ino=%u uid=%u sk=", r->pdiag_ino, uid);
+		if (r->pdiag_cookie[1] != 0)
+			printf("%08x", r->pdiag_cookie[1]);
+		printf("%08x", r->pdiag_cookie[0]);
+	}
+
+	if (show_bpf && tb[PACKET_DIAG_FILTER]) {
+		struct sock_filter *fil =
+		       RTA_DATA(tb[PACKET_DIAG_FILTER]);
+		int num = RTA_PAYLOAD(tb[PACKET_DIAG_FILTER]) /
+			  sizeof(struct sock_filter);
+
+		printf("\n\tbpf filter (%d): ", num);
+		while (num) {
+			printf(" 0x%02x %u %u %u,",
+			      fil->code, fil->jt, fil->jf, fil->k);
+			num--;
+			fil++;
+		}
+	}
+	printf("\n");
+	return 0;
+}
+
+static int packet_show_netlink(struct filter *f, FILE *dump_fp)
+{
+	int fd;
+	struct {
+		struct nlmsghdr nlh;
+		struct packet_diag_req r;
+	} req;
+	char	buf[8192];
+
+	if ((fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_INET_DIAG)) < 0)
+		return -1;
+
+	memset(&req, 0, sizeof(req));
+	req.nlh.nlmsg_len = sizeof(req);
+	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
+	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
+	req.nlh.nlmsg_seq = 123456;
+
+	req.r.sdiag_family = AF_PACKET;
+	req.r.pdiag_show = PACKET_SHOW_INFO | PACKET_SHOW_MEMINFO | PACKET_SHOW_FILTER;
+
+	if (send(fd, &req, sizeof(req), 0) < 0) {
+		close(fd);
+		return -1;
+	}
+
+	while (1) {
+		ssize_t status;
+		struct nlmsghdr *h;
+		struct sockaddr_nl nladdr;
+		socklen_t slen = sizeof(nladdr);
+
+		status = recvfrom(fd, buf, sizeof(buf), 0,
+				  (struct sockaddr *) &nladdr, &slen);
+		if (status < 0) {
+			if (errno == EINTR)
+				continue;
+			perror("OVERRUN");
+			continue;
+		}
+		if (status == 0) {
+			fprintf(stderr, "EOF on netlink\n");
+			goto close_it;
+		}
+
+		if (dump_fp)
+			fwrite(buf, 1, NLMSG_ALIGN(status), dump_fp);
+
+		h = (struct nlmsghdr*)buf;
+		while (NLMSG_OK(h, status)) {
+			int err;
+
+			if (h->nlmsg_seq != 123456)
+				goto skip_it;
+
+			if (h->nlmsg_type == NLMSG_DONE)
+				goto close_it;
+
+			if (h->nlmsg_type == NLMSG_ERROR) {
+				struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
+				if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
+					fprintf(stderr, "ERROR truncated\n");
+				} else {
+					errno = -err->error;
+					if (errno != ENOENT)
+						fprintf(stderr, "UDIAG answers %d\n", errno);
+				}
+				close(fd);
+				return -1;
+			}
+			if (!dump_fp) {
+				err = packet_show_sock(h, f);
+				if (err < 0) {
+					close(fd);
+					return err;
+				}
+			}
+
+skip_it:
+			h = NLMSG_NEXT(h, status);
+		}
+
+		if (status) {
+			fprintf(stderr, "!!!Remnant of size %zd\n", status);
+			exit(1);
+		}
+	}
+
+close_it:
+	close(fd);
+	return 0;
+}
+
 
 static int packet_show(struct filter *f)
 {
@@ -2406,6 +2585,9 @@ static int packet_show(struct filter *f)
 	if (!(f->states & (1<<SS_CLOSE)))
 		return 0;
 
+	if (packet_show_netlink(f, NULL) == 0)
+		return 0;
+
 	if ((fp = net_packet_open()) == NULL)
 		return -1;
 	fgets(buf, sizeof(buf)-1, fp);
@@ -2730,6 +2912,7 @@ static void _usage(FILE *dest)
 "   -p, --processes	show process using socket\n"
 "   -i, --info		show internal TCP information\n"
 "   -s, --summary	show socket usage summary\n"
+"   -b, --bfp           show bpf filter socket information\n"
 "\n"
 "   -4, --ipv4          display only IP version 4 sockets\n"
 "   -6, --ipv6          display only IP version 6 sockets\n"
@@ -2800,6 +2983,7 @@ static const struct option long_opts[] = {
 	{ "memory", 0, 0, 'm' },
 	{ "info", 0, 0, 'i' },
 	{ "processes", 0, 0, 'p' },
+	{ "bpf", 0, 0, 'b' },
 	{ "dccp", 0, 0, 'd' },
 	{ "tcp", 0, 0, 't' },
 	{ "udp", 0, 0, 'u' },
@@ -2836,7 +3020,7 @@ int main(int argc, char *argv[])
 
 	current_filter.states = default_filter.states;
 
-	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spf:miA:D:F:vV",
+	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbf:miA:D:F:vV",
 				 long_opts, NULL)) != EOF) {
 		switch(ch) {
 		case 'n':
@@ -2862,6 +3046,10 @@ int main(int argc, char *argv[])
 			show_users++;
 			user_ent_hash_build();
 			break;
+		case 'b':
+			show_options = 1;
+			show_bpf++;
+			break;
 		case 'd':
 			current_filter.dbs |= (1<<DCCP_DB);
 			do_default = 0;
-- 
1.8.2.1
