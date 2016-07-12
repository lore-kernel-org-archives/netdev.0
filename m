From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH iproute2] ip route: restore route entries in correct order
Date: Tue, 12 Jul 2016 21:37:58 +0800
Message-ID: <db0478737a916791e56b8a5f4c6307143ea44c25.1468330678.git.lucien.xin@gmail.com>
To: network dev <netdev@vger.kernel.org>, stephen@networkplumber.org,
	phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35518 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbcGLNiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 09:38:05 -0400
Received: by mail-pf0-f196.google.com with SMTP id t190so1101164pfb.2
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 06:38:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes we cannot restore route entries, because in kernel
  [1] fib_check_nh()
  [2] fib_valid_prefsrc()
cause some routes to depend on existence of others while adding.

For example, we saved all the routes, and flushed all tables
  [a] default via 192.168.122.1 dev eth0
  [b] 192.168.122.0/24 dev eth0 src 192.168.122.21
  [c] broadcast 127.0.0.0 dev lo table local src 127.0.0.1
  [d] local 127.0.0.0/8 dev lo table local  src 127.0.0.1
  [e] local 127.0.0.1 dev lo table local src 127.0.0.1
  [f] broadcast 127.255.255.255 dev lo table local src 127.0.0.1
  [g] broadcast 192.168.122.0 dev eth0 table local src 192.168.122.21
  [h] local 192.168.122.21 dev eth0 table local src 192.168.122.21
  [i] broadcast 192.168.122.255 dev eth0 table local src 192.168.122.21

  Now start to restore them:
    If we want to add [a], we have to add [b] first, as [1] and
    'via 192.168.122.1' in [a].
    If we want to add [b], we have to add [h] first, as [2] and
    'src 192.168.122.21' in [b].

  So the correct order to restore should be like:
    [e][h] -> [b][c][d][f][g][i] -> [a]

This patch fixes it by traversing the file 3 times, it only restores
part of them in each run according to the following conditions, to
make sure every entry can be restored successfully.
  1. !gw && (!fib_prefsrc || fib_prefsrc == cfg->fc_dst)
  2. !gw && (fib_prefsrc != cfg->fc_dst)
  3. gw

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 ip/iproute.c | 47 +++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 24f6b01..c735000 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1810,12 +1810,42 @@ static int iproute_get(int argc, char **argv)
 	return 0;
 }
 
+static int rtattr_cmp(struct rtattr *rta1, struct rtattr *rta2)
+{
+	if (!rta1 || !rta2 || rta1->rta_len != rta2->rta_len)
+		return 1;
+
+	return memcmp(RTA_DATA(rta1), RTA_DATA(rta2), RTA_PAYLOAD(rta1));
+}
+
 static int restore_handler(const struct sockaddr_nl *nl,
 			   struct rtnl_ctrl_data *ctrl,
 			   struct nlmsghdr *n, void *arg)
 {
-	int ret;
+	struct rtmsg *r = NLMSG_DATA(n);
+	struct rtattr *tb[RTA_MAX+1];
+	int len = n->nlmsg_len - NLMSG_LENGTH(sizeof(*r));
+	int ret, prio = *(int *)arg;
+
+	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
 
+	/* Restore routes in correct order:
+	 * 0. ones for local addresses,
+	 * 1. ones for local networks,
+	 * 2. others (remote networks/hosts).
+	 */
+	if (!prio && !tb[RTA_GATEWAY] && (!tb[RTA_PREFSRC] ||
+	    !rtattr_cmp(tb[RTA_PREFSRC], tb[RTA_DST])))
+		goto restore;
+	else if (prio == 1 && !tb[RTA_GATEWAY] &&
+		 rtattr_cmp(tb[RTA_PREFSRC], tb[RTA_DST]))
+		goto restore;
+	else if (prio == 2 && tb[RTA_GATEWAY])
+		goto restore;
+
+	return 0;
+
+restore:
 	n->nlmsg_flags |= NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
 
 	ll_init_map(&rth);
@@ -1848,10 +1878,23 @@ static int route_dump_check_magic(void)
 
 static int iproute_restore(void)
 {
+	int pos, prio;
+
 	if (route_dump_check_magic())
 		exit(-1);
 
-	exit(rtnl_from_file(stdin, &restore_handler, NULL));
+	pos = ftell(stdin);
+	for (prio = 0; prio < 3; prio++) {
+		int err;
+
+		err = rtnl_from_file(stdin, &restore_handler, &prio);
+		if (err)
+			exit(err);
+
+		fseek(stdin, pos, SEEK_SET);
+	}
+
+	exit(0);
 }
 
 static int show_handler(const struct sockaddr_nl *nl,
-- 
2.1.0
