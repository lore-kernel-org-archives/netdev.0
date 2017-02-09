From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/2] testsuite: Generate nlmsg blob at runtime
Date: Thu,  9 Feb 2017 11:50:54 +0100
Message-ID: <20170209105055.2477-2-phil@nwl.cc>
References: <20170209105055.2477-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45415 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752249AbdBILAh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 06:00:37 -0500
In-Reply-To: <20170209105055.2477-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since netlink messages are in host byte order, shipping a pre-generated
nlmsg blob won't suffice on systems with different endianness. Therefore
generate the blob at runtime, so it's content fits the hosts endianness.

Note that the generated message will contain only a single interface
featuring two VFs instead of the full list before. Yet this is
sufficient, as it triggers the crash with iproute versions prior to
commit 8c29ae7cc2494 ("ip link: Fix crash on older kernels when show VF
dev").

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Dropped the previous workaround altogether.
- Instead implemented this simple nlmsg generator.
---
 .gitignore                                |   2 +
 testsuite/Makefile                        |   2 +
 testsuite/tests/ip/link/dev_wo_vf_rate.nl | Bin 14076 -> 0 bytes
 testsuite/tools/Makefile                  |   2 +
 testsuite/tools/generate_nlmsg.c          | 116 ++++++++++++++++++++++++++++++
 5 files changed, 122 insertions(+)
 delete mode 100644 testsuite/tests/ip/link/dev_wo_vf_rate.nl
 create mode 100644 testsuite/tools/Makefile
 create mode 100644 testsuite/tools/generate_nlmsg.c

diff --git a/.gitignore b/.gitignore
index 74a5496ddf7aa..c3b8d386450bf 100644
--- a/.gitignore
+++ b/.gitignore
@@ -36,6 +36,8 @@ series
 # tests
 testsuite/results
 testsuite/iproute2/iproute2-this
+testsuite/tools/generate_nlmsg
+testsuite/tests/ip/link/dev_wo_vf_rate.nl
 
 # doc files generated at runtime
 doc/*.aux
diff --git a/testsuite/Makefile b/testsuite/Makefile
index 2027650051d48..fa7ddb8620754 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -43,6 +43,8 @@ $(TESTS): clean
 ifeq (,$(HAVE_UNSHARED_UTIL))
 	$(error Please install util-linux tools to run tests in separated network namespace)
 endif
+	@./tools/generate_nlmsg
+
 	@mkdir -p $(RESULTS_DIR)
 	
 	@for d in $(TESTS_DIR); do \
diff --git a/testsuite/tests/ip/link/dev_wo_vf_rate.nl b/testsuite/tests/ip/link/dev_wo_vf_rate.nl
deleted file mode 100644
index 40fa87ff1b158fb972e064efb38f76b0e9a56697..0000000000000000000000000000000000000000
GIT binary patch
literal 0
HcmV?d00001

literal 14076
zcmeI2QD_`h6o$|4X4B1fZMT}ns!(GsCQqft8lx5o_Nk#2gn}Z4n3_#@VcVp2BSi%l
zK`m6<ASk{l3L;Xdtzh4LXw?UwEWQ;H>|<XAeW{rB{P)gj@7$T$&U9yYCpZUo?##V+
z&N*}MnQzaXnJq-Lk$)l|{C)nwxqpi^KR{HbES=`#u}x?l$YprDm#`&TM>(o55*6q!
zb)4tkkUXi*T+a%)Z-E|A^#$7Mln*Km1sYXlo*q(Vi3aKD;<4q*a)q|j2GuucGkCJq
zDyp+|k0Sdi@-ln2m0iT|)VKO4ZE=*})4fVJbioD$cFa;AC2zZuy`N6-ST&5X6EATo
z_D|Z(Qu>&6?e@!KMAvgf!`ULof*!D8j*?c3=uZxngEPAQq%()pN?GQnhhmRa(B~Ye
z(A8pTJ~c$m=QA9IL@)C6>*%|64N6VG20Ecbn#D)dZ_ng7{!(c-0=xKL9c<UZr)`+;
zOIvp4ZN_9&6znPMI2q#Etu(4TaUM8>c>-r(+vLpn!)W(%rl8In<u>%!oLR?bA34VJ
ztQhmlKitHza7C5aH$^e#k$UUmB_c2eF@vZ9V+O7g?SGr-@R?S2`HvUO)6{;^Q==<_
z>do$84D>@_0|GlJ{cNG$mN0hAbE5V)&o%c8v{}vJPc*{gl%a9wPJSu7_~x%4nmyh7
z_^&agr0#58Q&RsW`ra<_Op1tpM9YpZCUc_~rNvu9zm6*12K{mj{n*D3`lUV&UV1%g
zUn49sc-a(QK6ek%rHYrAh=1`}t|P~0gqN_`DKAAobcv6sGkGaYxZrel&nWIuE#r2B
zQ{U?X846^*F1%akI<{ai+lX9uP#2Sz_NB|1*yo1jC0w(3`6zUChnGJ%y!^2}FE4v}
zc^~`4;Y(kR5Iyaa-ff1{cPQW`^h00+0y_{tTe`))?Zm!YQ?#QXUVc;E_S@cCu&z#d
zdFYwH@;|S(*YAYC>a-Sl`4vy<)WPKPQdrOom<Gw1u9*`N(6<-W;%^Wy<vPl@;ic#a
z^4a92-ABg6uJ_|*!?T9Xs7xa3EEb&nass-*ORO!BU&22#zx<t34!`^o(_*e;p=TrK
zmrDz^g~i#0xmO#KXQCxokY`GMWapU}Yh3fbA)*<df$Jo112<(ZWn5tg;%7^@xVN3y
zcWa7v1a3kSlB1F2Xjs#Jeag!m#E{&^DDlH>((4>evgfMfjQGT^D3Lh0ZZ}AW9+z?D
zXmZ^_?wic9FI~pOJ~u3LVB2EOW6;%a=E$1Kk2%Oo5Afy_nE*KKh=T|@j8vM;k=z${
zAbz%Vi+kINeYd7)M@eSR)Y+6d(PlHaw}ia>H+p(HfVkbdu%FDqn$%*>E?h?+nbSm`
zBkLNQIT&+rc8UjWMkW9b#~|u?nxjWp4m*%2w(S1}t)aWyBr|8__2e=~QsrjA^hg|B
z>&K+}_#|!wF=yI2C&_CojH$(($KiG#nZwWRGbGPC{FsB(11wnSB6B3q5#~g(C2@gq
z?3E;$In!rS=EM~T5?gD9IZJ$x;_1w-ZxZl*frmMh7@s>~&a^sjlu+V*A;kT@P*nwP
z)ceBsZ)C3Q^FIF$JSm0-<Tq<ogf#>FzA%Z;a&|wPT;8nJIq$aL=Chozw)~#u`0)nM
z9;_Va3E1c>Z}z9W2|Le8=S_7_%A2rrnUsEU@uumM-{Ad<yx-r%Zw!`}57le0%+A%9
zs&lx0a0lY|{bktqR>%XRe18dh$aOw@YwX6@yD57x9$}<Rck}x;UXLEH%^$8L=H1oJ
z?~6wGmD=tEudl+4@&B<;T>LrV!yl{-g+KTPWWMs+?8L;AedW&T$F&Wg?nt>4HrA8Q
zozu*nt1D^V6Lvn6(yyD`DH+^Z&)jJouhr}PC3rvcoyj*o+V<UhDR;ugU(&g=%G@cv
PlX55Qd?uw|T-^B&_@nmR

diff --git a/testsuite/tools/Makefile b/testsuite/tools/Makefile
new file mode 100644
index 0000000000000..9581de51fd358
--- /dev/null
+++ b/testsuite/tools/Makefile
@@ -0,0 +1,2 @@
+generate_nlmsg: generate_nlmsg.c ../../lib/libnetlink.c
+	$(CC) -o $@ $^
diff --git a/testsuite/tools/generate_nlmsg.c b/testsuite/tools/generate_nlmsg.c
new file mode 100644
index 0000000000000..fe96f26220471
--- /dev/null
+++ b/testsuite/tools/generate_nlmsg.c
@@ -0,0 +1,116 @@
+/*
+ * generate_nlmsg.c	Testsuite helper generating nlmsg blob
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Phil Sutter <phil@nwl.cc>
+ */
+
+#include <netinet/ether.h>
+#include <libnetlink.h>
+#include <sys/socket.h>
+#include <linux/if.h>
+#include <errno.h>
+#include <stdio.h>
+
+int fill_vf_rate_test(void *buf, size_t buflen)
+{
+	char bcmac[6] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+	struct ifla_vf_mac vf_mac = {
+		.mac = { 0x0, 0x26, 0x6c, 0xff, 0xb5, 0xc0 },
+	};
+	struct ifla_vf_link_state vf_link_state = { 0 };
+	struct ifla_vf_tx_rate vf_tx_rate = { 0 };
+	struct ifla_vf_spoofchk vf_spoofchk = {
+		.setting = 1,
+	};
+	struct ifla_vf_vlan vf_vlan = { 0 };
+	struct rtattr *vfinfo_list, *vfinfo;
+	struct nlmsghdr *h = buf;
+	struct ifinfomsg *ifi;
+
+	h->nlmsg_type = RTM_NEWLINK;
+	h->nlmsg_len = NLMSG_LENGTH(sizeof(*ifi));
+
+	ifi = NLMSG_DATA(h);
+	ifi->ifi_type = ARPHRD_ETHER;
+	ifi->ifi_index = 1;
+	ifi->ifi_flags = IFF_RUNNING | IFF_BROADCAST |
+			 IFF_MULTICAST | IFF_UP | IFF_LOWER_UP;
+
+#define ASSERT(x) if (x < 0) return -1
+#define ATTR_L(t, v, l)	ASSERT(addattr_l(h, buflen, t, v, l))
+#define ATTR_8(t, v)	ASSERT(addattr8(h, buflen, t, v))
+#define ATTR_32(t, v)	ASSERT(addattr32(h, buflen, t, v))
+#define ATTR_STRZ(t, v)	ASSERT(addattrstrz(h, buflen, t, v))
+
+#define NEST(t) addattr_nest(h, buflen, t)
+#define NEST_END(t) addattr_nest_end(h, t)
+
+	ATTR_STRZ(IFLA_IFNAME, "eth0");
+	ATTR_32(IFLA_TXQLEN, 10000);
+	ATTR_8(IFLA_OPERSTATE, 6);
+	ATTR_8(IFLA_LINKMODE, 0);
+	ATTR_32(IFLA_MTU, 9000);
+	ATTR_32(IFLA_GROUP, 0);
+	ATTR_32(IFLA_PROMISCUITY, 0);
+	ATTR_32(IFLA_NUM_TX_QUEUES, 8);
+	ATTR_32(IFLA_NUM_RX_QUEUES, 8);
+	ATTR_8(IFLA_CARRIER, 1);
+	ATTR_STRZ(IFLA_QDISC, "mq");
+	ATTR_L(IFLA_ADDRESS, vf_mac.mac, ETH_ALEN);
+	ATTR_L(IFLA_BROADCAST, bcmac, sizeof(bcmac));
+	ATTR_32(IFLA_NUM_VF, 2);
+
+	vfinfo_list = NEST(IFLA_VFINFO_LIST);
+
+	vfinfo = NEST(IFLA_VF_INFO);
+	ATTR_L(IFLA_VF_MAC, &vf_mac, sizeof(vf_mac));
+	ATTR_L(IFLA_VF_VLAN, &vf_vlan, sizeof(vf_vlan));
+	ATTR_L(IFLA_VF_TX_RATE, &vf_tx_rate, sizeof(vf_tx_rate));
+	ATTR_L(IFLA_VF_SPOOFCHK, &vf_spoofchk, sizeof(vf_spoofchk));
+	ATTR_L(IFLA_VF_LINK_STATE, &vf_link_state, sizeof(vf_link_state));
+	NEST_END(vfinfo);
+
+	vf_mac.vf = vf_vlan.vf = vf_tx_rate.vf = 1;
+	vf_spoofchk.vf = vf_link_state.vf = 1;
+
+	vfinfo = NEST(IFLA_VF_INFO);
+	ATTR_L(IFLA_VF_MAC, &vf_mac, sizeof(vf_mac));
+	ATTR_L(IFLA_VF_VLAN, &vf_vlan, sizeof(vf_vlan));
+	ATTR_L(IFLA_VF_TX_RATE, &vf_tx_rate, sizeof(vf_tx_rate));
+	ATTR_L(IFLA_VF_SPOOFCHK, &vf_spoofchk, sizeof(vf_spoofchk));
+	ATTR_L(IFLA_VF_LINK_STATE, &vf_link_state, sizeof(vf_link_state));
+	NEST_END(vfinfo);
+
+	NEST_END(vfinfo_list);
+
+	return h->nlmsg_len;
+}
+
+int main(void)
+{
+	char buf[16384] = { 0 };
+	int msglen;
+	FILE *fp;
+
+	msglen = fill_vf_rate_test(buf, sizeof(buf));
+	if (msglen < 0) {
+		fprintf(stderr, "fill_vf_rate_test() failed!\n");
+		return 1;
+	}
+	fp = fopen("tests/ip/link/dev_wo_vf_rate.nl", "w");
+	if (!fp) {
+		perror("fopen()");
+		return 1;
+	}
+	if (fwrite(buf, msglen, 1, fp) != 1) {
+		perror("fwrite()");
+		return 1;
+	}
+	fclose(fp);
+	return 0;
+}
-- 
2.11.0
