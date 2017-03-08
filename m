From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH v2 2/2] iproute2: add support for invisible qdisc dumping
Date: Wed, 8 Mar 2017 13:04:42 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1703081303490.31814@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>

Support the new TCA_DUMP_INVISIBLE netlink attribute that allows asking 
kernel to perform 'full qdisc dump', as for historical reasons some of the 
default qdiscs are being hidden by the kernel.

The command syntax is being extended by voluntary 'invisible' argument to
'tc qdisc show'.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---

v1 -> v2: fix the format of help message

 tc/tc_qdisc.c | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index 3a3701c2..1e9d9097 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -34,7 +34,7 @@ static int usage(void)
 	fprintf(stderr, "       [ stab [ help | STAB_OPTIONS] ]\n");
 	fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
 	fprintf(stderr, "\n");
-	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ ingress | clsact ]\n");
+	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ ingress | clsact ] [ invisible ]\n");
 	fprintf(stderr, "Where:\n");
 	fprintf(stderr, "QDISC_KIND := { [p|b]fifo | tbf | prio | cbq | red | etc. }\n");
 	fprintf(stderr, "OPTIONS := ... try tc qdisc add <desired QDISC_KIND> help\n");
@@ -292,6 +292,7 @@ static int tc_qdisc_list(int argc, char **argv)
 {
 	struct tcmsg t = { .tcm_family = AF_UNSPEC };
 	char d[16] = {};
+	bool dump_invisible = false;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
@@ -306,6 +307,8 @@ static int tc_qdisc_list(int argc, char **argv)
 			t.tcm_parent = TC_H_INGRESS;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
+		} else if (strcmp(*argv, "invisible") == 0) {
+			dump_invisible = true;
 		} else {
 			fprintf(stderr, "What is \"%s\"? Try \"tc qdisc help\".\n", *argv);
 			return -1;
@@ -325,7 +328,25 @@ static int tc_qdisc_list(int argc, char **argv)
 		filter_ifindex = t.tcm_ifindex;
 	}
 
-	if (rtnl_dump_request(&rth, RTM_GETQDISC, &t, sizeof(t)) < 0) {
+	if (dump_invisible) {
+		struct {
+			struct nlmsghdr n;
+			struct tcmsg t;
+			char buf[256];
+		} req = {
+			.n.nlmsg_type = RTM_GETQDISC,
+			.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg)),
+		};
+
+		req.t.tcm_family = AF_UNSPEC;
+
+		addattr(&req.n, 256, TCA_DUMP_INVISIBLE);
+		if (rtnl_dump_request_n(&rth, &req.n) < 0) {
+			perror("Cannot send dump request");
+			return 1;
+		}
+
+	} else if (rtnl_dump_request(&rth, RTM_GETQDISC, &t, sizeof(t)) < 0) {
 		perror("Cannot send dump request");
 		return 1;
 	}
-- 
Jiri Kosina
SUSE Labs
