From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 1/1] actions: keyword flowid or classid terminates action pipeline
Date: Sat, 24 May 2014 08:48:41 -0400
Message-ID: <1400935721-13558-1-git-send-email-jhs@emojatatu.com>
Cc: seann@herdejurgen.com, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:44484 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbaEXMsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 08:48:52 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so5339498pab.19
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 05:48:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

scenario testcase:

TC="sudo ./tc/tc"
DEV="dev eth0"
$TC qdisc del $DEV ingress
$TC qdisc add $DEV ingress
$TC filter add $DEV parent ffff: protocol ip u32 match ip src 10.0.0.0/24 action police rate 6Mbit burst 6Mbit drop flowid :1
$TC filter add $DEV parent ffff: protocol ip u32 match ip dst 10.0.0.0/24 action police rate 1Gbit burst 1Gbit pass flowid :1
$TC -s filter ls $DEV parent ffff: protocol ip
$TC qdisc del $DEV ingress
$TC qdisc add $DEV ingress
$TC filter add $DEV parent ffff: protocol ip u32 match ip src 10.0.0.0/24 flowid 1:1 action police rate 6Mbit burst 6Mbit drop
$TC filter add $DEV parent ffff: protocol ip u32 match ip dst 10.0.0.0/24 flowid 1:2 action police rate 1Gbit burst 1Gbit pass

$TC -s filter ls $DEV parent ffff: protocol ip
$TC qdisc del $DEV ingress
$TC qdisc add $DEV ingress
$TC filter add $DEV parent ffff: protocol ip pref 10 \
u32 match ip protocol 1 0xff \
flowid 1:10 \
action skbedit mark 11 \
action police rate 10kbit burst 10k pipe index 1 \
action skbedit mark 12 \
action police rate 20kbit burst 20k pipe index 2 \
action mirred egress mirror dev dummy0

$TC -s filter ls $DEV parent ffff: protocol ip
$TC qdisc del $DEV ingress
$TC qdisc add $DEV ingress
$TC filter add $DEV parent ffff: protocol ip pref 10 \
u32 match ip protocol 1 0xff \
action skbedit mark 11 \
action police rate 10kbit burst 10k pipe index 1 \
action skbedit mark 12 \
action police rate 20kbit burst 20k pipe index 2 \
action mirred egress mirror dev dummy0 \
flowid 1:10

$TC -s filter ls $DEV parent ffff: protocol ip

Reported-by: Seann Herdejurgen <seann@herdejurgen.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_action.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tc/m_action.c b/tc/m_action.c
index 77479d6..5cd5e67 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -185,6 +185,10 @@ parse_action(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
 			}
 #endif
 			continue;
+		} else if (strcmp(*argv, "flowid") == 0) {
+			break;
+		} else if (strcmp(*argv, "classid") == 0) {
+			break;
 		} else if (strcmp(*argv, "help") == 0) {
 			return -1;
 		} else if (new_cmd(argv)) {
-- 
1.7.9.5
