From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] ppp: fix xmit recursion detection on ppp channels
Date: Tue, 8 Aug 2017 11:43:24 +0200
Message-ID: <e45ed6ea02e2665ec8b868279ad9afcb9b34fc81.1502185216.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gao Feng <gfree.wind@vip.163.com>,
        Liu Jianying <jianying.liu@ikuai8.com>,
        David Miller <davem@davemloft.net>, linux-ppp@vger.kernel.org,
        Paul Mackerras <paulus@samba.org>
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit e5dadc65f9e0 ("ppp: Fix false xmit recursion detect with two ppp
devices") dropped the xmit_recursion counter incrementation in
ppp_channel_push() and relied on ppp_xmit_process() for this task.
But __ppp_channel_push() can also send packets directly (using the
.start_xmit() channel callback), in which case the xmit_recursion
counter isn't incremented anymore. If such packets get routed back to
the parent ppp unit, ppp_xmit_process() won't notice the recursion and
will call ppp_channel_push() on the same channel, effectively creating
the deadlock situation that the xmit_recursion mechanism was supposed
to prevent.

This patch re-introduces the xmit_recursion counter incrementation in
ppp_channel_push(). Since the xmit_recursion variable is now part of
the parent ppp unit, incrementation is skipped if the channel doesn't
have any. This is fine because only packets routed through the parent
unit may enter the channel recursively.

Finally, we have to ensure that pch->ppp is not going to be modified
while executing ppp_channel_push(). Instead of taking this lock only
while calling ppp_xmit_process(), we now have to hold it for the full
ppp_channel_push() execution. This respects the ppp locks ordering
which requires locking ->upl before ->downl.

Fixes: e5dadc65f9e0 ("ppp: Fix false xmit recursion detect with two ppp devices")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index bd4303944e44..a404552555d4 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1915,21 +1915,23 @@ static void __ppp_channel_push(struct channel *pch)
 	spin_unlock(&pch->downl);
 	/* see if there is anything from the attached unit to be sent */
 	if (skb_queue_empty(&pch->file.xq)) {
-		read_lock(&pch->upl);
 		ppp = pch->ppp;
 		if (ppp)
-			ppp_xmit_process(ppp);
-		read_unlock(&pch->upl);
+			__ppp_xmit_process(ppp);
 	}
 }
 
 static void ppp_channel_push(struct channel *pch)
 {
-	local_bh_disable();
-
-	__ppp_channel_push(pch);
-
-	local_bh_enable();
+	read_lock_bh(&pch->upl);
+	if (pch->ppp) {
+		(*this_cpu_ptr(pch->ppp->xmit_recursion))++;
+		__ppp_channel_push(pch);
+		(*this_cpu_ptr(pch->ppp->xmit_recursion))--;
+	} else {
+		__ppp_channel_push(pch);
+	}
+	read_unlock_bh(&pch->upl);
 }
 
 /*
-- 
2.14.0

