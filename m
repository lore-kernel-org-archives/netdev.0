From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 1/1] iproute2: rsvp classifier support for multiple actions
Date: Sun, 28 Sep 2014 12:49:53 -0400
Message-ID: <1411922993-5828-1-git-send-email-jhs@emojatatu.com>
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:55637 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbaI1QuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 12:50:12 -0400
Received: by mail-ie0-f171.google.com with SMTP id rp18so75645iec.16
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 09:50:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Example setup:

sudo tc qdisc del dev eth0 root handle 1:0 prio
sudo tc qdisc add dev eth0 root handle 1:0 prio

sudo tc filter add dev eth0 pref 10 proto ip parent 1:0 \
rsvp session 10.0.0.1 ipproto icmp \
classid 1:1  \
action police rate 1kbit burst 90k pipe \
action ok

tc -s filter show dev eth0 parent 1:0

filter protocol ip pref 10 rsvp
filter protocol ip pref 10 rsvp fh 0x0001100a flowid 1:1 session
10.0.0.1 ipproto icmp
        action order 1:  police 0x5 rate 1Kbit burst 23440b mtu 2Kb
action pipe overhead 0b
ref 1 bind 1
        Action statistics:
        Sent 98000 bytes 1000 pkt (dropped 0, overlimits 761 requeues 0)
        backlog 0b 0p requeues 0

        action order 2: gact action pass
         random type none pass val 0
         index 2 ref 1 bind 1 installed 60 sec used 3 sec
        Action statistics:
        Sent 74578 bytes 761 pkt (dropped 0, overlimits 0 requeues 0)
        backlog 0b 0p requeues 0

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_rsvp.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/tc/f_rsvp.c b/tc/f_rsvp.c
index 44d3bdf..14f24b1 100644
--- a/tc/f_rsvp.c
+++ b/tc/f_rsvp.c
@@ -261,6 +261,13 @@ static int rsvp_parse_opt(struct filter_util *qu, char *handle, int argc, char *
 			}
 			pinfo.tunnelhdr = tid;
 			pinfo_ok++;
+		} else if (matches(*argv, "action") == 0) {
+			NEXT_ARG();
+			if (parse_action(&argc, &argv, TCA_RSVP_ACT, n)) {
+				fprintf(stderr, "Illegal \"action\"\n");
+				return -1;
+			}
+			continue;
 		} else if (matches(*argv, "police") == 0) {
 			NEXT_ARG();
 			if (parse_police(&argc, &argv, TCA_RSVP_POLICE, n)) {
@@ -385,6 +392,10 @@ static int rsvp_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, _
 		SPRINT_BUF(b2);
 		fprintf(f, "sender [NONE]%s ", sprint_spi(&pinfo->spi, 0, b2));
 	}
+
+	if (tb[TCA_RSVP_ACT]) {
+		tc_print_action(f, tb[TCA_RSVP_ACT]);
+	}
 	if (tb[TCA_RSVP_POLICE])
 		tc_print_police(f, tb[TCA_RSVP_POLICE]);
 	return 0;
-- 
1.7.9.5
