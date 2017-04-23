From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 net 5/8] tc/pedit: Support fields bigger than 32 bits
Date: Sun, 23 Apr 2017 15:53:53 +0300
Message-ID: <20170423125356.1298-6-amir@vadai.me>
References: <20170423125356.1298-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33784 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045451AbdDWMy4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 08:54:56 -0400
Received: by mail-wm0-f68.google.com with SMTP id y10so1432544wmh.0
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 05:54:55 -0700 (PDT)
In-Reply-To: <20170423125356.1298-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make parse_val() accept fields up to 128 bits long, this should be
enough for current use cases and involves a minimal change to code.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 tc/m_pedit.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 7af074a5a97c..d982c91a2585 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -256,7 +256,10 @@ int parse_val(int *argc_p, char ***argv_p, __u32 *val, int type)
 int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
 	      struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 {
-	__u32 mask = 0, val = 0;
+	__u32 mask[4] = { 0 };
+	__u32 val[4] = { 0 };
+	__u32 *m = &mask[0];
+	__u32 *v = &val[0];
 	__u32 o = 0xFF;
 	int res = -1;
 	int argc = *argc_p;
@@ -275,7 +278,7 @@ int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
 		o = 0xFFFFFFFF;
 
 	if (matches(*argv, "invert") == 0) {
-		val = mask = o;
+		*v = *m = o;
 	} else if (matches(*argv, "set") == 0 ||
 		   matches(*argv, "add") == 0) {
 		if (matches(*argv, "add") == 0)
@@ -287,7 +290,7 @@ int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
 		}
 
 		NEXT_ARG();
-		if (parse_val(&argc, &argv, &val, type))
+		if (parse_val(&argc, &argv, val, type))
 			return -1;
 	} else if (matches(*argv, "preserve") == 0) {
 		retain = 0;
@@ -307,8 +310,8 @@ int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
 		argv++;
 	}
 
-	tkey->val = val;
-	tkey->mask = mask;
+	tkey->val = *v;
+	tkey->mask = *m;
 
 	if (type == TIPV4)
 		tkey->val = ntohl(tkey->val);
-- 
2.12.0
