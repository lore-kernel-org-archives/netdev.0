From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2] ip, realms: also allow to pass in raw realms value
Date: Thu,  8 Oct 2015 12:22:39 +0200
Message-ID: <7b438e1a9424209d64fbb77911a05af37038c74d.1444297002.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56617 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754666AbbJHKWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 06:22:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If get_rt_realms() fails, try to get a possible raw u32 realms
value for the u32 RTA_FLOW/FRA_FLOW attribute, as it might be
useful to directly configure the hex value itself. And only if
that fails, then bail out.

The source realm is provided in the upper u16 (mask: 0xffff0000)
and the destination realm through the lower u16 part (mask:
0x0000ffff). This can be useful for tc's bpf realm matcher, but
also a full hex/mask param can be provided already for matching
through iptables' --realm cmdline option, for example.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/rtm_map.h |  3 +--
 ip/iproute.c      |  6 +++---
 ip/iprule.c       |  2 +-
 ip/rtm_map.c      | 10 +++++++++-
 4 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/rtm_map.h b/include/rtm_map.h
index 70bda7d..d6e5885 100644
--- a/include/rtm_map.h
+++ b/include/rtm_map.h
@@ -4,7 +4,6 @@
 char *rtnl_rtntype_n2a(int id, char *buf, int len);
 int rtnl_rtntype_a2n(int *id, char *arg);
 
-int get_rt_realms(__u32 *realms, char *arg);
-
+int get_rt_realms_or_raw(__u32 *realms, char *arg);
 
 #endif /* __RTM_MAP_H__ */
diff --git a/ip/iproute.c b/ip/iproute.c
index b0cd299..40e6ebe 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -749,7 +749,7 @@ static int parse_one_nh(struct rtmsg *r, struct rtattr *rta,
 		} else if (matches(*argv, "realms") == 0) {
 			__u32 realm;
 			NEXT_ARG();
-			if (get_rt_realms(&realm, *argv))
+			if (get_rt_realms_or_raw(&realm, *argv))
 				invarg("\"realm\" value is invalid\n", *argv);
 			rta_addattr32(rta, 4096, RTA_FLOW, realm);
 			rtnh->rtnh_len += sizeof(struct rtattr) + 4;
@@ -1050,7 +1050,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 		} else if (matches(*argv, "realms") == 0) {
 			__u32 realm;
 			NEXT_ARG();
-			if (get_rt_realms(&realm, *argv))
+			if (get_rt_realms_or_raw(&realm, *argv))
 				invarg("\"realm\" value is invalid\n", *argv);
 			addattr32(&req.n, sizeof(req), RTA_FLOW, realm);
 		} else if (strcmp(*argv, "onlink") == 0) {
@@ -1383,7 +1383,7 @@ static int iproute_list_flush_or_save(int argc, char **argv, int action)
 		} else if (matches(*argv, "realms") == 0) {
 			__u32 realm;
 			NEXT_ARG();
-			if (get_rt_realms(&realm, *argv))
+			if (get_rt_realms_or_raw(&realm, *argv))
 				invarg("invalid realms\n", *argv);
 			filter.realm = realm;
 			filter.realmmask = ~0U;
diff --git a/ip/iprule.c b/ip/iprule.c
index 714278a..128b16a 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -305,7 +305,7 @@ static int iprule_modify(int cmd, int argc, char **argv)
 		} else if (matches(*argv, "realms") == 0) {
 			__u32 realm;
 			NEXT_ARG();
-			if (get_rt_realms(&realm, *argv))
+			if (get_rt_realms_or_raw(&realm, *argv))
 				invarg("invalid realms\n", *argv);
 			addattr32(&req.n, sizeof(req), FRA_FLOW, realm);
 		} else if (matches(*argv, "table") == 0 ||
diff --git a/ip/rtm_map.c b/ip/rtm_map.c
index 21e818b..1d7d2c7 100644
--- a/ip/rtm_map.c
+++ b/ip/rtm_map.c
@@ -93,7 +93,7 @@ int rtnl_rtntype_a2n(int *id, char *arg)
 	return 0;
 }
 
-int get_rt_realms(__u32 *realms, char *arg)
+static int get_rt_realms(__u32 *realms, char *arg)
 {
 	__u32 realm = 0;
 	char *p = strchr(arg, '/');
@@ -114,3 +114,11 @@ int get_rt_realms(__u32 *realms, char *arg)
 	*realms |= realm;
 	return 0;
 }
+
+int get_rt_realms_or_raw(__u32 *realms, char *arg)
+{
+	if (!get_rt_realms(realms, arg))
+		return 0;
+
+	return get_unsigned(realms, arg, 0);
+}
-- 
1.9.3
