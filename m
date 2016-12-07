From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] bpf: fix state equivalence
Date: Wed, 7 Dec 2016 10:57:59 -0800
Message-ID: <1481137079-2205635-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Josef Bacik <jbacik@fb.com>, Thomas Graf <tgraf@suug.ch>,
        <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46196 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753580AbcLGS6C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:58:02 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB7Is9iA001741
        for <netdev@vger.kernel.org>; Wed, 7 Dec 2016 10:58:01 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 276mx0a4pg-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 10:58:01 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 12e9eb5abcaf11e69fe924be05956610-fff7a50 for <netdev@vger.kernel.org>; Wed,
 07 Dec 2016 10:58:00 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commmits 57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers")
and 484611357c19 ("bpf: allow access into map value arrays") by themselves
are correct, but in combination they make state equivalence ignore 'id' field
of the register state which can lead to accepting invalid program.

Fixes: 57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers")
Fixes: 484611357c19 ("bpf: allow access into map value arrays")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
this fix has to be done before net-next closes next week,
so sending it now. Will add the test to test_verifier later.

 include/linux/bpf_verifier.h | 14 +++++++-------
 kernel/bpf/verifier.c        |  2 +-
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 7453c1281531..a13b031dc6b8 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -18,13 +18,6 @@
 
 struct bpf_reg_state {
 	enum bpf_reg_type type;
-	/*
-	 * Used to determine if any memory access using this register will
-	 * result in a bad access.
-	 */
-	s64 min_value;
-	u64 max_value;
-	u32 id;
 	union {
 		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
 		s64 imm;
@@ -40,6 +33,13 @@ struct bpf_reg_state {
 		 */
 		struct bpf_map *map_ptr;
 	};
+	u32 id;
+	/* Used to determine if any memory access using this register will
+	 * result in a bad access. These two fields must be last.
+	 * See states_equal()
+	 */
+	s64 min_value;
+	u64 max_value;
 };
 
 enum bpf_stack_slot_type {
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index da9fb2a9b7eb..5b14f85f45c6 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2528,7 +2528,7 @@ static bool states_equal(struct bpf_verifier_env *env,
 		 * we didn't do a variable access into a map then we are a-ok.
 		 */
 		if (!varlen_map_access &&
-		    rold->type == rcur->type && rold->imm == rcur->imm)
+		    memcmp(rold, rcur, offsetofend(struct bpf_reg_state, id)) == 0)
 			continue;
 
 		/* If we didn't map access then again we don't care about the
-- 
2.8.0
