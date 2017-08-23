From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v2 net-next 2/5] bpf/verifier: when pruning a
 branch, ignore its write marks
Date: Wed, 23 Aug 2017 15:10:03 +0100
Message-ID: <ec2ee579-8391-c023-348a-770faa6bc5c7@solarflare.com>
References: <f9208b68-466e-c6cb-4d0c-c567e40bdc15@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <f9208b68-466e-c6cb-4d0c-c567e40bdc15-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

The fact that writes occurred in reaching the continuation state does
 not screen off its reads from us, because we're not really its parent.
So detect 'not really the parent' in do_propagate_liveness, and ignore
 write marks in that case.

Fixes: dc503a8ad984 ("bpf/verifier: track liveness for pruning")
Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
 kernel/bpf/verifier.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index e42c096..fdbaa60 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3436,6 +3436,7 @@ static bool states_equal(struct bpf_verifier_env *env,
 static bool do_propagate_liveness(const struct bpf_verifier_state *state,
 				  struct bpf_verifier_state *parent)
 {
+	bool writes = parent == state->parent; /* Observe write marks */
 	bool touched = false; /* any changes made? */
 	int i;
 
@@ -3447,7 +3448,9 @@ static bool do_propagate_liveness(const struct bpf_verifier_state *state,
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
@@ -3460,7 +3463,9 @@ static bool do_propagate_liveness(const struct bpf_verifier_state *state,
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
