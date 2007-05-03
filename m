From: jamal <hadi@cyberus.ca>
Subject: [RESEND][PATCH][IPROUTE2]  see SAD info
Date: Thu, 03 May 2007 19:09:41 -0400
Message-ID: <1178233781.4068.6.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-vuWSEkyKWO4rQoK/0ukZ"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:18731 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767466AbXECXJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 19:09:45 -0400
Received: by wx-out-0506.google.com with SMTP id h31so590050wxd
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 16:09:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-vuWSEkyKWO4rQoK/0ukZ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Stephen,
Use this patch instead of the one i sent yesterday.
As before, you will need to pull include/linux/xfrm.h from
net-2.6 once Dave applies the kernel patch.

cheers,
jamal


--=-vuWSEkyKWO4rQoK/0ukZ
Content-Disposition: attachment; filename=xfrmu_sadinfo-2
Content-Type: text/plain; name=xfrmu_sadinfo-2; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] see SAD info

i.e instead of something like ip xfrm state ls | grep -i src | wc -l
do:

ip xfrm state count
And you get the count; you can also pass -s to the command line and
get the hash info.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 7540e262b3d565e42c441524f9a236fb216af2dd
tree ee884918b8ea68daf3e70adc5c780cee26a78284
parent ab4c2f14fb93700c9aefeb02ed9918565ba332a1
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 03 May 2007 15:04:42 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 03 May 2007 15:04:42 -0400

 include/linux/xfrm.h |   74 ++++++++++++++++++++++++++++++++++++++++++++++
 ip/xfrm.h            |    1 +
 ip/xfrm_state.c      |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 155 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 1f64b68..81c95aa 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -178,6 +178,18 @@ enum {
 	XFRM_MSG_REPORT,
 #define XFRM_MSG_REPORT XFRM_MSG_REPORT
 
+	XFRM_MSG_MIGRATE,
+#define XFRM_MSG_MIGRATE XFRM_MSG_MIGRATE
+
+	XFRM_MSG_NEWSADINFO,
+#define XFRM_MSG_NEWSADINFO XFRM_MSG_NEWSADINFO
+	XFRM_MSG_GETSADINFO,
+#define XFRM_MSG_GETSADINFO XFRM_MSG_GETSADINFO
+
+	XFRM_MSG_NEWSPDINFO,
+#define XFRM_MSG_NEWSPDINFO XFRM_MSG_NEWSPDINFO
+	XFRM_MSG_GETSPDINFO,
+#define XFRM_MSG_GETSPDINFO XFRM_MSG_GETSPDINFO
 	__XFRM_MSG_MAX
 };
 #define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
@@ -256,11 +268,56 @@ enum xfrm_attr_type_t {
 	XFRMA_COADDR,		/* xfrm_address_t */
 	XFRMA_LASTUSED,
 	XFRMA_POLICY_TYPE,	/* struct xfrm_userpolicy_type */
+	XFRMA_MIGRATE,
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
 };
 
+enum xfrm_sadattr_type_t {
+	XFRMA_SADUNSPEC,
+	XFRMA_SADCNT,
+	XFRMA_SADHINFO,
+	__XFRMA_SAD_MAX
+
+#define XFRMA_SAD_MAX (__XFRMA_SAD_MAX - 1)
+};
+
+struct xfrmu_sadhinfo {
+	__u32 sadhcnt; /* current hash bkts */
+	__u32 sadhmcnt; /* max allowed hash bkts */
+};
+
+/* SPD Table filter flags  */
+enum xfrm_spd_ftype_t {
+	XFRM_SPD_UNSPEC,
+	XFRM_SPD_HMASK=1,
+	XFRM_SPD_HMAX=2,
+	XFRM_SPD_ICNT=4,
+	XFRM_SPD_OCNT=8,
+	XFRM_SPD_FCNT=16,
+	XFRM_SPD_ISCNT=32,
+	XFRM_SPD_OSCNT=64,
+	XFRM_SPD_FSCNT=128,
+	__XFRM_SPD_MAX
+
+#define XFRM_SPD_MAX (__XFRM_SPD_MAX - 1)
+};
+enum xfrm_spdattr_type_t {
+	XFRMA_SPD_UNSPEC,
+	XFRMA_SPDHMASK,
+	XFRMA_SPDHMAX,
+	XFRMA_SPDICNT,
+	XFRMA_SPDOCNT,
+	XFRMA_SPDFCNT,
+	XFRMA_SPDISCNT,
+	XFRMA_SPDOSCNT,
+	XFRMA_SPDFSCNT,
+	__XFRMA_SPD_MAX
+
+#define XFRMA_SPD_MAX (__XFRMA_SPD_MAX - 1)
+};
+
 struct xfrm_usersa_info {
 	struct xfrm_selector		sel;
 	struct xfrm_id			id;
@@ -351,12 +408,27 @@ struct xfrm_user_report {
 	struct xfrm_selector		sel;
 };
 
+struct xfrm_user_migrate {
+	xfrm_address_t			old_daddr;
+	xfrm_address_t			old_saddr;
+	xfrm_address_t			new_daddr;
+	xfrm_address_t			new_saddr;
+	__u8				proto;
+	__u8				mode;
+	__u16				reserved;
+	__u32				reqid;
+	__u16				old_family;
+	__u16				new_family;
+};
+
+#ifndef __KERNEL__
 /* backwards compatibility for userspace */
 #define XFRMGRP_ACQUIRE		1
 #define XFRMGRP_EXPIRE		2
 #define XFRMGRP_SA		4
 #define XFRMGRP_POLICY		8
 #define XFRMGRP_REPORT		0x20
+#endif
 
 enum xfrm_nlgroups {
 	XFRMNLGRP_NONE,
@@ -373,6 +445,8 @@ enum xfrm_nlgroups {
 #define XFRMNLGRP_AEVENTS	XFRMNLGRP_AEVENTS
 	XFRMNLGRP_REPORT,
 #define XFRMNLGRP_REPORT	XFRMNLGRP_REPORT
+	XFRMNLGRP_MIGRATE,
+#define XFRMNLGRP_MIGRATE	XFRMNLGRP_MIGRATE
 	__XFRMNLGRP_MAX
 };
 #define XFRMNLGRP_MAX	(__XFRMNLGRP_MAX - 1)
diff --git a/ip/xfrm.h b/ip/xfrm.h
index d1959bb..71345b9 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -57,6 +57,7 @@
 
 #define XFRMREP_RTA(x)	((struct rtattr*)(((char*)(x)) + NLMSG_ALIGN(sizeof(struct xfrm_user_report))))
 
+#define XFRMSAPD_RTA(x)	((struct rtattr*)(((char*)(x)) + NLMSG_ALIGN(sizeof(__u32))))
 #define XFRM_FLAG_PRINT(fp, flags, f, s) \
 	do { \
 		if (flags & f) { \
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 42e3949..39b0f27 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -64,6 +64,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm state { deleteall | list } [ ID ] [ mode MODE ] [ reqid REQID ]\n");
 	fprintf(stderr, "        [ flag FLAG_LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm state flush [ proto XFRM_PROTO ]\n");
+	fprintf(stderr, "Usage: ip xfrm state count \n");
 
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
 	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | comp ]\n");
@@ -933,6 +934,82 @@ static int xfrm_state_list_or_deleteall(int argc, char **argv, int deleteall)
 	exit(0);
 }
 
+int print_sadinfo(struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	__u32 *f = NLMSG_DATA(n);
+	struct rtattr *tb[XFRMA_SAD_MAX+1];
+	struct rtattr *rta;
+	struct xfrmu_sadhinfo *si;	
+	__u32 *cnt;
+
+	int len = n->nlmsg_len;
+
+	len -= NLMSG_LENGTH(sizeof(__u32));
+	if (len < 0) {
+		fprintf(stderr, "SADinfo: Wrong len %d\n", len);
+		return -1;
+	}
+
+	rta = XFRMSAPD_RTA(f);
+	parse_rtattr(tb, XFRMA_SAD_MAX, rta, len);
+
+	if (tb[XFRMA_SADCNT]) {
+		fprintf(fp,"\t SAD");
+		cnt = (__u32 *)RTA_DATA(tb[XFRMA_SADCNT]);
+		fprintf(fp," count %d", *cnt);
+	} else {
+		fprintf(fp,"BAD SAD info returned\n");
+		return -1;
+	}
+
+	if (show_stats) {
+		if (!tb[XFRMA_SADHINFO]) {
+		}
+		if (RTA_PAYLOAD(tb[XFRMA_SADHINFO]) < sizeof(*si)) {
+			fprintf(fp,"BAD SAD length returned\n");
+			return -1;
+		}
+
+		si = (struct xfrmu_sadhinfo *)RTA_DATA(tb[XFRMA_SADHINFO]);
+		fprintf(fp," (buckets ");
+		fprintf(fp,"count %d", si->sadhcnt);
+		fprintf(fp," Max %d", si->sadhmcnt);
+		fprintf(fp,")");
+	}
+	fprintf(fp,"\n");
+
+        return 0;
+}
+
+static int xfrm_sad_getinfo(int argc, char **argv)
+{
+	struct rtnl_handle rth;
+	struct {
+		struct nlmsghdr			n;
+		__u32				flags;
+		char				ans[64];
+	} req;
+
+	memset(&req, 0, sizeof(req));
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.flags));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = XFRM_MSG_GETSADINFO;
+	req.flags = 0XFFFFFFFF;
+
+	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
+		exit(1);
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, &req.n, NULL, NULL) < 0)
+		exit(2);
+
+	print_sadinfo(&req.n, (void*)stdout);
+
+	rtnl_close(&rth);
+
+	return 0;
+}
+
 static int xfrm_state_flush(int argc, char **argv)
 {
 	struct rtnl_handle rth;
@@ -1010,6 +1087,9 @@ int do_xfrm_state(int argc, char **argv)
 		return xfrm_state_get_or_delete(argc-1, argv+1, 0);
 	if (matches(*argv, "flush") == 0)
 		return xfrm_state_flush(argc-1, argv+1);
+	if (matches(*argv, "count") == 0) {
+		return xfrm_sad_getinfo(argc, argv);
+	}
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip xfrm state help\".\n", *argv);

--=-vuWSEkyKWO4rQoK/0ukZ--

