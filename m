From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/3] tc: pedit: Fix parse_cmd()
Date: Wed,  2 Mar 2016 12:20:30 +0100
Message-ID: <1456917631-18447-3-git-send-email-phil@nwl.cc>
References: <1456917631-18447-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60312 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754995AbcCBLUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 06:20:51 -0500
In-Reply-To: <1456917631-18447-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was horribly broken:
* pack_key8() and pack_key16() ...
  * missed to invert retain value when applying it to the mask,
  * did not sanitize val by ANDing it with retain,
  * and ignored the mask which is necessary for 'invert' command.
* pack_key16() did not convert mask to network byte order.
* Changing the retain value for 'invert' or 'retain' operation seems
  just plain wrong.
* While here, also got rid of unnecessary offset sanitization in
  pack_key32().
* Simplify code a bit by always assigning the local mask variable to
  tkey->mask before calling any of the pack_key*() variants.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_pedit.c | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 455e4ffd4b2bb..a314f482cd9c0 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -152,8 +152,6 @@ pack_key32(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
 
 	tkey->val = htonl(tkey->val & retain);
 	tkey->mask = htonl(tkey->mask | ~retain);
-	/* jamal remove this - it is not necessary given the if check above */
-	tkey->off &= ~3;
 	return pack_key(sel,tkey);
 }
 
@@ -176,11 +174,8 @@ pack_key16(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
 	}
 
 	stride = 8 * ind;
-	tkey->val = htons(tkey->val);
-	tkey->val <<= stride;
-	tkey->mask <<= stride;
-	retain <<= stride;
-	tkey->mask = retain|m[ind];
+	tkey->val = htons(tkey->val & retain) << stride;
+	tkey->mask = (htons(tkey->mask | ~retain) << stride) | m[ind];
 
 	tkey->off &= ~3;
 
@@ -204,10 +199,8 @@ pack_key8(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
 	ind = tkey->off & 3;
 
 	stride = 8 * ind;
-	tkey->val <<= stride;
-	tkey->mask <<= stride;
-	retain <<= stride;
-	tkey->mask = retain|m[ind];
+	tkey->val = (tkey->val & retain) << stride;
+	tkey->mask = ((tkey->mask | ~retain) << stride) | m[ind];
 
 	tkey->off &= ~3;
 
@@ -268,13 +261,13 @@ parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type,__u32 retain,struct t
 		o = 0xFFFFFFFF;
 
 	if (matches(*argv, "invert") == 0) {
-		retain = val = mask = o;
+		val = mask = o;
 	} else if (matches(*argv, "set") == 0) {
 		NEXT_ARG();
 		if (parse_val(&argc, &argv, &val, type))
 			return -1;
 	} else if (matches(*argv, "preserve") == 0) {
-		retain = mask = o;
+		retain = 0;
 	} else {
 		if (matches(*argv, "clear") != 0)
 			return -1;
@@ -290,19 +283,17 @@ parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type,__u32 retain,struct t
 	}
 
 	tkey->val = val;
+	tkey->mask = mask;
 
 	if (len == 1) {
-		tkey->mask = 0xFF;
 		res = pack_key8(retain,sel,tkey);
 		goto done;
 	}
 	if (len == 2) {
-		tkey->mask = mask;
 		res = pack_key16(retain,sel,tkey);
 		goto done;
 	}
 	if (len == 4) {
-		tkey->mask = mask;
 		res = pack_key32(retain,sel,tkey);
 		goto done;
 	}
-- 
2.7.2
