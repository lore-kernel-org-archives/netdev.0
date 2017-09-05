From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/master] tc actions: store and dump correct length of user cookies
Date: Tue,  5 Sep 2017 13:06:24 +0200
Message-ID: <1504609584-20026-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33651 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751710AbdIELGt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 07:06:49 -0400
Received: by mail-wm0-f46.google.com with SMTP id f145so10438569wme.0
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 04:06:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct two errors which cancel each other out:
* Do not send twice the length of the actual provided by the user to the kernel
* Do not dump half the length of the cookie provided by the kernel

As the cookie is now stored in the kernel at its correct length rather
than double the that length cookies of up to the maximum size of 16 bytes
may now be stored rather than a maximum of half that length.

Output of dump is the same before and after this change,
but the data stored in the kernel is now exactly the cookie
rather than the cookie + as many trailing zeros.

Before:
 # tc filter add dev eth0 protocol ip parent ffff: \
       flower ip_proto udp action drop \
       cookie 0123456789abcdef0123456789abcdef
 RTNETLINK answers: Invalid argument

After:
 # tc filter add dev eth0 protocol ip parent ffff: \
       flower ip_proto udp action drop \
       cookie 0123456789abcdef0123456789abcdef
 # tc filter show dev eth0 ingress
   eth_type ipv4
   ip_proto udp
   not_in_hw
	 action order 1: gact action drop
	  random type none pass val 0
	  index 1 ref 1 bind 1 installed 1 sec used 1 sec
	 Action statistics:
	 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	 backlog 0b 0p requeues 0
	 cookie len 16 0123456789abcdef0123456789abcdef

Fixes: fd8b3d2c1b9b ("actions: Add support for user cookies")
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 tc/m_action.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index 6ebe85e1cbe3..397e9c5d4a7b 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -242,7 +242,7 @@ done0:
 					invarg("cookie must be a hex string\n",
 					       *argv);
 
-				act_ck_len = slen;
+				act_ck_len = slen / 2;
 				argc--;
 				argv++;
 			}
@@ -307,7 +307,7 @@ static int tc_print_one_action(FILE *f, struct rtattr *arg)
 		print_tcstats2_attr(f, tb[TCA_ACT_STATS], "\t", NULL);
 		if (tb[TCA_ACT_COOKIE]) {
 			int strsz = RTA_PAYLOAD(tb[TCA_ACT_COOKIE]);
-			char b1[strsz+1];
+			char b1[strsz * 2 + 1];
 
 			fprintf(f, "\n\tcookie len %d %s ", strsz,
 				hexstring_n2a(RTA_DATA(tb[TCA_ACT_COOKIE]),
-- 
2.1.4
