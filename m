From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: [RFC] iproute2/tc caching proposal
Date: Thu, 7 May 2009 01:03:37 +0300
Message-ID: <200905070103.37956.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_5kgAKmoTWHtYM0Z"
To: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43692 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762600AbZEFWDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 18:03:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_5kgAKmoTWHtYM0Z
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Since already someone did caching in iproute2, my changes is very trivial, but 
giving huge improvement in batch performance (30k rules 10minutes vs 30 
seconds).

ll_init_map is called in many places in tc, but since tc not changing 
anything, that can change this map, i think it is enough to call it only at 
the beginning, after rtnl_open().

Only one exclusion - tc monitor, because it is running long time, and things 
can change over this time, so we call ll_init_map on each received rtnetlink 
event.

Also please check "[RFC] [IPROUTE2] Filter class output by classid", if it is 
ok. Many people told it is useful patch.

--Boundary-00=_5kgAKmoTWHtYM0Z
Content-Type: text/x-diff;
  charset="us-ascii";
  name="tc_caching.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="tc_caching.diff"

index 67dd49c..38569ca 100644
--- a/iproute2/tc/f_route.c
+++ b/iproute2-test1/tc/f_route.c
@@ -83,7 +83,6 @@ static int route_parse_opt(struct filter_util *qu, char *handle, int argc, char
 		} else if (matches(*argv, "fromif") == 0) {
 			__u32 id;
 			NEXT_ARG();
-			ll_init_map(&rth);
 			if ((id=ll_name_to_index(*argv)) <= 0) {
 				fprintf(stderr, "Illegal \"fromif\"\n");
 				return -1;
index 226df4d..d7a9897 100644
--- a/iproute2/tc/m_mirred.c
+++ b/iproute2-test1/tc/m_mirred.c
@@ -146,8 +146,6 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, str
 
 	if (d[0])  {
 		int idx;
-		ll_init_map(&rth);
-
 		if ((idx = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
 			return -1;
index 8e362d2..0f26ab7 100644
--- a/iproute2/tc/tc.c
+++ b/iproute2-test1/tc/tc.c
@@ -235,6 +235,9 @@ static int batch(const char *name)
 		return -1;
 	}
 
+	ll_init_map(&rth);
+
+
 	cmdlineno = 0;
 	while (getcmdline(&line, &len, stdin) != -1) {
 		char *largv[100];
@@ -299,6 +302,7 @@ int main(int argc, char **argv)
 		argc--;	argv++;
 	}
 
+
 	if (do_batching)
 		return batch(batchfile);
 
@@ -313,6 +317,8 @@ int main(int argc, char **argv)
 		exit(1);
 	}
 
+	ll_init_map(&rth);
+
 	ret = do_cmd(argc-1, argv+1);
 	rtnl_close(&rth);
 
index 774497a..917f65c 100644
--- a/iproute2/tc/tc_class.c
+++ b/iproute2-test1/tc/tc_class.c
@@ -130,8 +130,6 @@ int tc_class_modify(int cmd, unsigned flags, int argc, char **argv)
 	}
 
 	if (d[0])  {
-		ll_init_map(&rth);
-
 		if ((req.t.tcm_ifindex = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
 			return 1;
@@ -273,8 +271,6 @@ int tc_class_list(int argc, char **argv)
 		argc--; argv++;
 	}
 
- 	ll_init_map(&rth);
-
 	if (d[0]) {
 		if ((t.tcm_ifindex = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
index 919c57c..91a1333 100644
--- a/iproute2/tc/tc_filter.c
+++ b/iproute2-test1/tc/tc_filter.c
@@ -159,8 +159,6 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 
 
 	if (d[0])  {
- 		ll_init_map(&rth);
-
 		if ((req.t.tcm_ifindex = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
 			return 1;
@@ -326,8 +324,6 @@ int tc_filter_list(int argc, char **argv)
 
 	t.tcm_info = TC_H_MAKE(prio<<16, protocol);
 
- 	ll_init_map(&rth);
-
 	if (d[0]) {
 		if ((t.tcm_ifindex = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
index bf58744..b2e6ec3 100644
--- a/iproute2/tc/tc_monitor.c
+++ b/iproute2-test1/tc/tc_monitor.c
@@ -39,6 +39,8 @@ int accept_tcmsg(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
 
+	ll_init_map(&rth);
+
 	if (n->nlmsg_type == RTM_NEWTFILTER || n->nlmsg_type == RTM_DELTFILTER) {
 		print_filter(who, n, arg);
 		return 0;
@@ -98,7 +100,7 @@ int do_tcmonitor(int argc, char **argv)
 	if (rtnl_open(&rth, groups) < 0)
 		exit(1);
 
-	ll_init_map(&rth);
+	
 
 	if (rtnl_listen(&rth, accept_tcmsg, (void*)stdout) < 0) {
 		rtnl_close(&rth);
index c7f2988..c86e52c 100644
--- a/iproute2/tc/tc_qdisc.c
+++ b/iproute2-test1/tc/tc_qdisc.c
@@ -177,8 +177,6 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 	if (d[0])  {
 		int idx;
 
- 		ll_init_map(&rth);
-
 		if ((idx = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
 			return 1;
@@ -308,8 +306,6 @@ int tc_qdisc_list(int argc, char **argv)
 		argc--; argv++;
 	}
 
- 	ll_init_map(&rth);
-
 	if (d[0]) {
 		if ((t.tcm_ifindex = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);

--Boundary-00=_5kgAKmoTWHtYM0Z--
