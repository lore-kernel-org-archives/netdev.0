From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH net][v2] bpf: fix states equal logic for varlen access
Date: Tue, 29 Nov 2016 12:27:09 -0500
Message-ID: <1480440429-2531-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <ast@kernel.org>,
        <jannh@google.com>, <daniel@iogearbox.net>, <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59273 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750795AbcK2R1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:27:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we have a branch that looks something like this

int foo = map->value;
if (condition) {
  foo += blah;
} else {
  foo = bar;
}
map->array[foo] = baz;

We will incorrectly assume that the !condition branch is equal to the condition
branch as the register for foo will be UNKNOWN_VALUE in both cases.  We need to
adjust this logic to only do this if we didn't do a varlen access after we
processed the !condition branch, otherwise we have different ranges and need to
check the other branch as well.

Fixes: 484611357c19 ("bpf: allow access into map value arrays")
Reported-by: Jann Horn <jannh@google.com>
Signed-off-by: Josef Bacik <jbacik@fb.com>
---
v1->v2:
- renamed and moved varlen_map_access variable.
- dropped the extra () in the second if statement.
- added the Fixes and Reported-by tag.

 kernel/bpf/verifier.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 6a93615..8199821 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2454,6 +2454,7 @@ static bool states_equal(struct bpf_verifier_env *env,
 			 struct bpf_verifier_state *old,
 			 struct bpf_verifier_state *cur)
 {
+	bool varlen_map_access = env->varlen_map_value_access;
 	struct bpf_reg_state *rold, *rcur;
 	int i;
 
@@ -2467,12 +2468,17 @@ static bool states_equal(struct bpf_verifier_env *env,
 		/* If the ranges were not the same, but everything else was and
 		 * we didn't do a variable access into a map then we are a-ok.
 		 */
-		if (!env->varlen_map_value_access &&
+		if (!varlen_map_access &&
 		    rold->type == rcur->type && rold->imm == rcur->imm)
 			continue;
 
+		/* If we didn't map access then again we don't care about the
+		 * mismatched range values and it's ok if our old type was
+		 * UNKNOWN and we didn't go to a NOT_INIT'ed reg.
+		 */
 		if (rold->type == NOT_INIT ||
-		    (rold->type == UNKNOWN_VALUE && rcur->type != NOT_INIT))
+		    (!varlen_map_access && rold->type == UNKNOWN_VALUE &&
+		     rcur->type != NOT_INIT))
 			continue;
 
 		if (rold->type == PTR_TO_PACKET && rcur->type == PTR_TO_PACKET &&
-- 
2.7.4
