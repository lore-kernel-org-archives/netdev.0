From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/4] tc: pedit: Fix for big-endian systems
Date: Wed, 16 Mar 2016 22:48:33 +0100
Message-ID: <1458164915-31802-3-git-send-email-phil@nwl.cc>
References: <1458164915-31802-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35385 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965002AbcCPVsy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 17:48:54 -0400
In-Reply-To: <1458164915-31802-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was tricky to get right:
- The 'stride' value used for 8 and 16 bit values must behave inverse to
  the value's intra word offset to work correctly with big-endian data
  act_pedit is editing.
- The 'm' array's values are in host byte order, so they have to be
  converted as well (and the ordering was just inverse, for some
  reason).
- The only sane way of getting this right is to manipulate value/mask in
  host byte order and convert the output.
- TIPV4 (i.e. 'munge ip src/dst') had it's own pitfall: the address
  parser converts to network byte order automatically. This patch fixes
  this by converting it back before calling pack_key32, which is a hack
  but at least does not require to implement a completely separate code
  flow.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_pedit.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index a7960d524c29a..7de47800040bc 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -160,7 +160,7 @@ int
 pack_key16(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
 {
 	int ind, stride;
-	__u32 m[4] = {0xFFFF0000,0xFF0000FF,0x0000FFFF};
+	__u32 m[4] = {0x0000FFFF,0xFF0000FF,0xFFFF0000};
 
 	if (tkey->val > 0xFFFF || tkey->mask > 0xFFFF) {
 		fprintf(stderr, "pack_key16 bad value\n");
@@ -174,9 +174,9 @@ pack_key16(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
 		return -1;
 	}
 
-	stride = 8 * ind;
-	tkey->val = htons(tkey->val & retain) << stride;
-	tkey->mask = (htons(tkey->mask | ~retain) << stride) | m[ind];
+	stride = 8 * (2 - ind);
+	tkey->val = htonl((tkey->val & retain) << stride);
+	tkey->mask = htonl(((tkey->mask | ~retain) << stride) | m[ind]);
 
 	tkey->off &= ~3;
 
@@ -190,7 +190,7 @@ int
 pack_key8(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
 {
 	int ind, stride;
-	__u32 m[4] = {0xFFFFFF00,0xFFFF00FF,0xFF00FFFF,0x00FFFFFF};
+	__u32 m[4] = {0x00FFFFFF,0xFF00FFFF,0xFFFF00FF,0xFFFFFF00};
 
 	if (tkey->val > 0xFF || tkey->mask > 0xFF) {
 		fprintf(stderr, "pack_key8 bad value (val %x mask %x\n", tkey->val, tkey->mask);
@@ -199,9 +199,9 @@ pack_key8(__u32 retain,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey)
 
 	ind = tkey->off & 3;
 
-	stride = 8 * ind;
-	tkey->val = (tkey->val & retain) << stride;
-	tkey->mask = ((tkey->mask | ~retain) << stride) | m[ind];
+	stride = 8 * (3 - ind);
+	tkey->val = htonl((tkey->val & retain) << stride);
+	tkey->mask = htonl(((tkey->mask | ~retain) << stride) | m[ind]);
 
 	tkey->off &= ~3;
 
@@ -286,6 +286,9 @@ parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type,__u32 retain,struct t
 	tkey->val = val;
 	tkey->mask = mask;
 
+	if (type == TIPV4)
+		tkey->val = ntohl(tkey->val);
+
 	if (len == 1) {
 		res = pack_key8(retain,sel,tkey);
 		goto done;
-- 
2.7.2
