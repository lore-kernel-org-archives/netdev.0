From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/5] bpf: split check_mem_access logic for map values
Date: Mon, 9 Jan 2017 10:19:46 -0800
Message-ID: <1483985990-1532850-2-git-send-email-ast@fb.com>
References: <1483985990-1532850-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Gianluca Borello <g.borello@gmail.com>,
        Josef Bacik <jbacik@fb.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50324 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1164061AbdAISTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:19:53 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v09IJfBF007392
        for <netdev@vger.kernel.org>; Mon, 9 Jan 2017 10:19:52 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 27v9y1959a-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:19:52 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 360f7642d69811e6a4630002c99293a0-751fca50 for <netdev@vger.kernel.org>;        Mon,
 09 Jan 2017 10:19:51 -0800
In-Reply-To: <1483985990-1532850-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gianluca Borello <g.borello@gmail.com>

Move the logic to check memory accesses to a PTR_TO_MAP_VALUE_ADJ from
check_mem_access() to a separate helper check_map_access_adj(). This
enables to use those checks in other parts of the verifier as well,
where boundaries on PTR_TO_MAP_VALUE_ADJ might need to be checked, for
example when checking helper function arguments. The same thing is
already happening for other types such as PTR_TO_PACKET and its
check_packet_access() helper.

The code has been copied verbatim, with the only difference of removing
the "off += reg->max_value" statement and moving the sum into the call
statement to check_map_access(), as that was only needed due to the
earlier common check_map_access() call.

Signed-off-by: Gianluca Borello <g.borello@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 88 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 49 insertions(+), 39 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 83ed2f8f6f22..8333fbcfbfe7 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -635,6 +635,51 @@ static int check_map_access(struct bpf_verifier_env *env, u32 regno, int off,
 	return 0;
 }
 
+/* check read/write into an adjusted map element */
+static int check_map_access_adj(struct bpf_verifier_env *env, u32 regno,
+				int off, int size)
+{
+	struct bpf_verifier_state *state = &env->cur_state;
+	struct bpf_reg_state *reg = &state->regs[regno];
+	int err;
+
+	/* We adjusted the register to this map value, so we
+	 * need to change off and size to min_value and max_value
+	 * respectively to make sure our theoretical access will be
+	 * safe.
+	 */
+	if (log_level)
+		print_verifier_state(state);
+	env->varlen_map_value_access = true;
+	/* The minimum value is only important with signed
+	 * comparisons where we can't assume the floor of a
+	 * value is 0.  If we are using signed variables for our
+	 * index'es we need to make sure that whatever we use
+	 * will have a set floor within our range.
+	 */
+	if (reg->min_value < 0) {
+		verbose("R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
+			regno);
+		return -EACCES;
+	}
+	err = check_map_access(env, regno, reg->min_value + off, size);
+	if (err) {
+		verbose("R%d min value is outside of the array range\n",
+			regno);
+		return err;
+	}
+
+	/* If we haven't set a max value then we need to bail
+	 * since we can't be sure we won't do bad things.
+	 */
+	if (reg->max_value == BPF_REGISTER_MAX_RANGE) {
+		verbose("R%d unbounded memory access, make sure to bounds check any array access into a map\n",
+			regno);
+		return -EACCES;
+	}
+	return check_map_access(env, regno, reg->max_value + off, size);
+}
+
 #define MAX_PACKET_OFF 0xffff
 
 static bool may_access_direct_pkt_data(struct bpf_verifier_env *env,
@@ -775,45 +820,10 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 			return -EACCES;
 		}
 
-		/* If we adjusted the register to this map value at all then we
-		 * need to change off and size to min_value and max_value
-		 * respectively to make sure our theoretical access will be
-		 * safe.
-		 */
-		if (reg->type == PTR_TO_MAP_VALUE_ADJ) {
-			if (log_level)
-				print_verifier_state(state);
-			env->varlen_map_value_access = true;
-			/* The minimum value is only important with signed
-			 * comparisons where we can't assume the floor of a
-			 * value is 0.  If we are using signed variables for our
-			 * index'es we need to make sure that whatever we use
-			 * will have a set floor within our range.
-			 */
-			if (reg->min_value < 0) {
-				verbose("R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
-					regno);
-				return -EACCES;
-			}
-			err = check_map_access(env, regno, reg->min_value + off,
-					       size);
-			if (err) {
-				verbose("R%d min value is outside of the array range\n",
-					regno);
-				return err;
-			}
-
-			/* If we haven't set a max value then we need to bail
-			 * since we can't be sure we won't do bad things.
-			 */
-			if (reg->max_value == BPF_REGISTER_MAX_RANGE) {
-				verbose("R%d unbounded memory access, make sure to bounds check any array access into a map\n",
-					regno);
-				return -EACCES;
-			}
-			off += reg->max_value;
-		}
-		err = check_map_access(env, regno, off, size);
+		if (reg->type == PTR_TO_MAP_VALUE_ADJ)
+			err = check_map_access_adj(env, regno, off, size);
+		else
+			err = check_map_access(env, regno, off, size);
 		if (!err && t == BPF_READ && value_regno >= 0)
 			mark_reg_unknown_value(state->regs, value_regno);
 
-- 
2.8.0
