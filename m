From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] ebpf: verifier: check that call reg with ARG_ANYTHING is initialized
Date: Thu, 12 Mar 2015 17:21:42 +0100
Message-ID: <8bb5d2d9c8d471c1161ae60ea92141aef00a4fc8.1426172976.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, challa@noironetworks.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46538 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932419AbbCLQVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 12:21:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed that a helper function with argument type ARG_ANYTHING does
not need to have an initialized value (register).

This can worst case lead to unintented stack memory leakage in future
helper functions if they are not carefully designed, or unintended
application behaviour in case the application developer was not careful
enough to match a correct helper function signature in the API.

The underlying issue is that ARG_ANYTHING should actually be split
into two different semantics:

  1) ARG_DONTCARE for function arguments that the helper function
     does not care about (in other words: the default for unused
     function arguments), and

  2) ARG_ANYTHING that is an argument actually being used by a
     helper function and *guaranteed* to be an initialized register.

The current risk is low: ARG_ANYTHING is only used for the 'flags'
argument (r4) in bpf_map_update_elem() that internally does strict
checking.

Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 I'm fine with this going to net-next, but it also applies to net.

 include/linux/bpf.h   | 4 +++-
 kernel/bpf/verifier.c | 5 ++++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index b36a09e..b3a6f84 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -44,7 +44,7 @@ struct bpf_map_type_list {
 
 /* function argument constraints */
 enum bpf_arg_type {
-	ARG_ANYTHING = 0,	/* any argument is ok */
+	ARG_DONTCARE = 0,	/* unused argument in helper function */
 
 	/* the following constraints used to prototype
 	 * bpf_map_lookup/update/delete_elem() functions
@@ -58,6 +58,8 @@ enum bpf_arg_type {
 	 */
 	ARG_PTR_TO_STACK,	/* any pointer to eBPF program stack */
 	ARG_CONST_STACK_SIZE,	/* number of bytes accessed from stack */
+
+	ARG_ANYTHING,		/* any (initialized) argument is ok */
 };
 
 /* type of values returned from helper functions */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index bdf4192..e6b5224 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -755,7 +755,7 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 	enum bpf_reg_type expected_type;
 	int err = 0;
 
-	if (arg_type == ARG_ANYTHING)
+	if (arg_type == ARG_DONTCARE)
 		return 0;
 
 	if (reg->type == NOT_INIT) {
@@ -763,6 +763,9 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		return -EACCES;
 	}
 
+	if (arg_type == ARG_ANYTHING)
+		return 0;
+
 	if (arg_type == ARG_PTR_TO_STACK || arg_type == ARG_PTR_TO_MAP_KEY ||
 	    arg_type == ARG_PTR_TO_MAP_VALUE) {
 		expected_type = PTR_TO_STACK;
-- 
1.9.3
