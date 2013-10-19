From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 4/9] x86/jump_label: expect default_nop if static_key gets enabled on boot-up
Date: Sat, 19 Oct 2013 21:48:54 +0200
Message-ID: <1382212139-20301-5-git-send-email-hannes@stressinduktion.org>
References: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Jason Baron <jbaron@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, x86@kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382212139-20301-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_get_random_once(intrduced in the next patch) uses static_keys in
a way that they get enabled on boot-up instead of replaced with an
ideal_nop. So check for default_nop on initial enabling.

Other architectures don't check for this.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Jason Baron <jbaron@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: x86@kernel.org
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 arch/x86/kernel/jump_label.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/arch/x86/kernel/jump_label.c b/arch/x86/kernel/jump_label.c
index ee11b7d..26d5a55 100644
--- a/arch/x86/kernel/jump_label.c
+++ b/arch/x86/kernel/jump_label.c
@@ -42,15 +42,27 @@ static void __jump_label_transform(struct jump_entry *entry,
 				   int init)
 {
 	union jump_code_union code;
+	const unsigned char default_nop[] = { STATIC_KEY_INIT_NOP };
 	const unsigned char *ideal_nop = ideal_nops[NOP_ATOMIC5];
 
 	if (type == JUMP_LABEL_ENABLE) {
-		/*
-		 * We are enabling this jump label. If it is not a nop
-		 * then something must have gone wrong.
-		 */
-		if (unlikely(memcmp((void *)entry->code, ideal_nop, 5) != 0))
-			bug_at((void *)entry->code, __LINE__);
+		if (init) {
+			/*
+			 * Jump label is enabled for the first time.
+			 * So we expect a default_nop...
+			 */
+			if (unlikely(memcmp((void *)entry->code, default_nop, 5)
+				     != 0))
+				bug_at((void *)entry->code, __LINE__);
+		} else {
+			/*
+			 * ...otherwise expect an ideal_nop. Otherwise
+			 * something went horribly wrong.
+			 */
+			if (unlikely(memcmp((void *)entry->code, ideal_nop, 5)
+				     != 0))
+				bug_at((void *)entry->code, __LINE__);
+		}
 
 		code.jump = 0xe9;
 		code.offset = entry->target -
@@ -63,7 +75,6 @@ static void __jump_label_transform(struct jump_entry *entry,
 		 * are converting the default nop to the ideal nop.
 		 */
 		if (init) {
-			const unsigned char default_nop[] = { STATIC_KEY_INIT_NOP };
 			if (unlikely(memcmp((void *)entry->code, default_nop, 5) != 0))
 				bug_at((void *)entry->code, __LINE__);
 		} else {
-- 
1.8.3.1
