From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net 2/3] bpf: fix check_map_func_compatibility logic
Date: Wed, 27 Apr 2016 18:56:21 -0700
Message-ID: <1461808582-1452466-3-git-send-email-ast@fb.com>
References: <1461808582-1452466-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jann Horn <jannh@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:42602 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752022AbcD1B42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 21:56:28 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u3S1tlXp014375
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 18:56:26 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 22k7x5rb76-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 18:56:26 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 68e20e460ce411e6a27d24be0595f910-13bf7c50 for <netdev@vger.kernel.org>;	Wed,
 27 Apr 2016 18:56:23 -0700
In-Reply-To: <1461808582-1452466-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 35578d798400 ("bpf: Implement function bpf_perf_event_read() that get the selected hardware PMU conuter")
introduced clever way to check bpf_helper<->map_type compatibility.
Later on commit a43eec304259 ("bpf: introduce bpf_perf_event_output() helper") adjusted
the logic and inadvertently broke it.
Get rid of the clever bool compare and go back to two-way check
from map and from helper perspective.

Fixes: a43eec304259 ("bpf: introduce bpf_perf_event_output() helper")
Reported-by: Jann Horn <jannh@google.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 65 +++++++++++++++++++++++++++++++--------------------
 1 file changed, 40 insertions(+), 25 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 89bcaa0966da..c5c17a62f509 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -239,16 +239,6 @@ static const char * const reg_type_str[] = {
 	[CONST_IMM]		= "imm",
 };
 
-static const struct {
-	int map_type;
-	int func_id;
-} func_limit[] = {
-	{BPF_MAP_TYPE_PROG_ARRAY, BPF_FUNC_tail_call},
-	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_read},
-	{BPF_MAP_TYPE_PERF_EVENT_ARRAY, BPF_FUNC_perf_event_output},
-	{BPF_MAP_TYPE_STACK_TRACE, BPF_FUNC_get_stackid},
-};
-
 static void print_verifier_state(struct verifier_env *env)
 {
 	enum bpf_reg_type t;
@@ -921,27 +911,52 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 
 static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 {
-	bool bool_map, bool_func;
-	int i;
-
 	if (!map)
 		return 0;
 
-	for (i = 0; i < ARRAY_SIZE(func_limit); i++) {
-		bool_map = (map->map_type == func_limit[i].map_type);
-		bool_func = (func_id == func_limit[i].func_id);
-		/* only when map & func pair match it can continue.
-		 * don't allow any other map type to be passed into
-		 * the special func;
-		 */
-		if (bool_func && bool_map != bool_func) {
-			verbose("cannot pass map_type %d into func %d\n",
-				map->map_type, func_id);
-			return -EINVAL;
-		}
+	/* We need a two way check, first is from map perspective ... */
+	switch (map->map_type) {
+	case BPF_MAP_TYPE_PROG_ARRAY:
+		if (func_id != BPF_FUNC_tail_call)
+			goto error;
+		break;
+	case BPF_MAP_TYPE_PERF_EVENT_ARRAY:
+		if (func_id != BPF_FUNC_perf_event_read &&
+		    func_id != BPF_FUNC_perf_event_output)
+			goto error;
+		break;
+	case BPF_MAP_TYPE_STACK_TRACE:
+		if (func_id != BPF_FUNC_get_stackid)
+			goto error;
+		break;
+	default:
+		break;
+	}
+
+	/* ... and second from the function itself. */
+	switch (func_id) {
+	case BPF_FUNC_tail_call:
+		if (map->map_type != BPF_MAP_TYPE_PROG_ARRAY)
+			goto error;
+		break;
+	case BPF_FUNC_perf_event_read:
+	case BPF_FUNC_perf_event_output:
+		if (map->map_type != BPF_MAP_TYPE_PERF_EVENT_ARRAY)
+			goto error;
+		break;
+	case BPF_FUNC_get_stackid:
+		if (map->map_type != BPF_MAP_TYPE_STACK_TRACE)
+			goto error;
+		break;
+	default:
+		break;
 	}
 
 	return 0;
+error:
+	verbose("cannot pass map_type %d into func %d\n",
+		map->map_type, func_id);
+	return -EINVAL;
 }
 
 static int check_call(struct verifier_env *env, int func_id)
-- 
2.8.0
