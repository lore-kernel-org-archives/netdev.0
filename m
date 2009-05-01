From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: [RFC] [IPROUTE2] Filter class output by classid
Date: Sat, 2 May 2009 02:59:15 +0300
Message-ID: <200905020259.15089.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Tz4+JyO6Dz/ARvA"
To: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43739 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbZEBAAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 20:00:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_Tz4+JyO6Dz/ARvA
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Sometimes while dividing bandwidth by classes it is useful to see how some 
specific class doing things live.

Which my simple patch it is possible to do
watch -n1 "tc -s -d class show dev eth0.2022 classid 1:1520"
and to get live statistics, how packets queued or dropped, and how much 
bandwidth used (if estimator defined) for specific class.

Signed-off-by: Denys Fedoryshchenko <denys@visp.net.lb>

--Boundary-00=_Tz4+JyO6Dz/ARvA
Content-Type: text/x-diff;
  charset="us-ascii";
  name="iproute2-showclass_clean.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="iproute2-showclass_clean.patch"

--- a/iproute2/tc/tc_class.c
+++ b/iproute2-denys/tc/tc_class.c
@@ -146,6 +146,7 @@ int tc_class_modify(int cmd, unsigned flags, int argc, char **argv)
 
 int filter_ifindex;
 __u32 filter_qdisc;
+__u32 filter_classid;
 
 int print_class(const struct sockaddr_nl *who,
 		       struct nlmsghdr *n, void *arg)
@@ -169,6 +170,9 @@ int print_class(const struct sockaddr_nl *who,
 	if (filter_qdisc && TC_H_MAJ(t->tcm_handle^filter_qdisc))
 		return 0;
 
+	if (filter_classid && t->tcm_handle != filter_classid)
+		return 0;
+
 	memset(tb, 0, sizeof(tb));
 	parse_rtattr(tb, TCA_MAX, TCA_RTA(t), len);
 
@@ -249,6 +253,12 @@ int tc_class_list(int argc, char **argv)
 				duparg("qdisc", *argv);
 			if (get_qdisc_handle(&filter_qdisc, *argv))
 				invarg(*argv, "invalid qdisc ID");
+		} else if (strcmp(*argv, "classid") == 0) {
+			NEXT_ARG();
+			if (filter_classid)
+				duparg("classid", *argv);
+			if (get_tc_classid(&filter_classid, *argv))
+				invarg(*argv, "invalid class ID");
 		} else if (strcmp(*argv, "root") == 0) {
 			if (t.tcm_parent) {
 				fprintf(stderr, "Error: \"root\" is duplicate parent ID\n");

--Boundary-00=_Tz4+JyO6Dz/ARvA--
