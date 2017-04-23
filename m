From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 net 4/8] tc/pedit: p_ip: introduce editing ttl header
Date: Sun, 23 Apr 2017 15:53:52 +0300
Message-ID: <20170423125356.1298-5-amir@vadai.me>
References: <20170423125356.1298-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34826 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045427AbdDWMyn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 08:54:43 -0400
Received: by mail-wr0-f193.google.com with SMTP id l44so17772594wrc.2
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 05:54:43 -0700 (PDT)
In-Reply-To: <20170423125356.1298-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable user to edit IP header ttl field.

For example, to forward any TCP packet and decrease its TTL by one:
$ tc filter add dev enp0s9 protocol ip parent ffff: \
    flower \
      ip_proto tcp \
    action pedit ex munge \
      ip ttl add 0xff pipe \
    action mirred egress \
      redirect dev veth0

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 man/man8/tc-pedit.8 | 17 +++++++++++++++++
 tc/p_ip.c           |  6 ++++++
 2 files changed, 23 insertions(+)

diff --git a/man/man8/tc-pedit.8 b/man/man8/tc-pedit.8
index 6bba741956f1..c98d95cb0021 100644
--- a/man/man8/tc-pedit.8
+++ b/man/man8/tc-pedit.8
@@ -28,6 +28,8 @@ pedit - generic packet editor action
 .ti -8
 .IR EXTENDED_LAYERED_OP " := { "
 .BI ip " IPHDR_FIELD"
+|
+.BI ip " EX_IPHDR_FIELD"
 .RI } " CMD_SPEC"
 
 .ti -8
@@ -40,6 +42,10 @@ pedit - generic packet editor action
 .BR dport " | " sport " | " icmp_type " | " icmp_code " }"
 
 .ti -8
+.IR EX_IPHDR_FIELD " := { "
+.BR ttl " }"
+
+.ti -8
 .IR CMD_SPEC " := {"
 .BR clear " | " invert " | " set
 .IR VAL " | "
@@ -161,6 +167,17 @@ If it is not or the latter is bigger than the minimum of 20 bytes, this will do
 unexpected things. These fields are eight-bit values.
 .RE
 .TP
+.BI ip " EX_IPHDR_FIELD"
+Supported only when
+.I ex
+is used. The supported keywords for
+.I EX_IPHDR_FIELD
+are:
+.RS
+.TP
+.B ttl
+.RE
+.TP
 .B clear
 Clear the addressed data (i.e., set it to zero).
 .TP
diff --git a/tc/p_ip.c b/tc/p_ip.c
index e56eb39317ba..22fe6505e427 100644
--- a/tc/p_ip.c
+++ b/tc/p_ip.c
@@ -66,6 +66,12 @@ parse_ip(int *argc_p, char ***argv_p,
 		res = parse_cmd(&argc, &argv, 1, TU32, 0x0f, sel, tkey);
 		goto done;
 	}
+	if (strcmp(*argv, "ttl") == 0) {
+		NEXT_ARG();
+		tkey->off = 8;
+		res = parse_cmd(&argc, &argv, 1, TU32, RU8, sel, tkey);
+		goto done;
+	}
 	if (strcmp(*argv, "protocol") == 0) {
 		NEXT_ARG();
 		tkey->off = 9;
-- 
2.12.0
