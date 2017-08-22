From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 3/4] bpf/verifier: when pruning a branch, ignore its
 write marks
Date: Tue, 22 Aug 2017 14:27:11 +0100
Message-ID: <d1a5b78a-8f5c-50d9-08a2-eb7c4829a478@solarflare.com>
References: <f25f46bd-27cb-2182-2551-2887757c1e0f@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:46877 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932791AbdHVN1Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 09:27:24 -0400
In-Reply-To: <f25f46bd-27cb-2182-2551-2887757c1e0f@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fact that writes occurred in reaching the continuation state does
 not screen off its reads from us, because we're not really its parent.
So detect 'not really the parent' in do_propagate_liveness, and ignore
 write marks in that case.

Fixes: dc503a8ad984 ("bpf/verifier: track liveness for pruning")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 kernel/bpf/verifier.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 1e3f56c..711bdbd 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3420,6 +3420,7 @@ static bool states_equal(struct bpf_verifier_env *env,
 static bool do_propagate_liveness(const struct bpf_verifier_state *state,
 				  struct bpf_verifier_state *parent)
 {
+	bool writes = parent == state->parent; /* Observe write marks */
 	bool touched = false; /* any changes made? */
 	int i;
 
@@ -3431,7 +3432,9 @@ static bool do_propagate_liveness(const struct bpf_verifier_state *state,
 	for (i = 0; i < BPF_REG_FP; i++) {
 		if (parent->regs[i].live & REG_LIVE_READ)
 			continue;
-		if (state->regs[i].live == REG_LIVE_READ) {
+		if (writes && (state->regs[i].live & REG_LIVE_WRITTEN))
+			continue;
+		if (state->regs[i].live & REG_LIVE_READ) {
 			parent->regs[i].live |= REG_LIVE_READ;
 			touched = true;
 		}
@@ -3444,7 +3447,9 @@ static bool do_propagate_liveness(const struct bpf_verifier_state *state,
 			continue;
 		if (parent->spilled_regs[i].live & REG_LIVE_READ)
 			continue;
-		if (state->spilled_regs[i].live == REG_LIVE_READ) {
+		if (writes && (state->spilled_regs[i].live & REG_LIVE_WRITTEN))
+			continue;
+		if (state->spilled_regs[i].live & REG_LIVE_READ) {
 			parent->spilled_regs[i].live |= REG_LIVE_READ;
 			touched = true;
 		}
