From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 05/17] pppoatm: drop frames to not-ready vcc
Date: Fri, 30 Nov 2012 00:35:24 +0000
Message-ID: <1354235736-26833-6-git-send-email-dwmw2@infradead.org>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Cc: chas@cmf.nrl.navy.mil, krzysiek@podlesie.net,
	David Woodhouse <David.Woodhouse@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:47040
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755149Ab2K3Agl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 19:36:41 -0500
In-Reply-To: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Mazur <krzysiek@podlesie.net>

Patches "atm: detach protocol before closing vcc"
and "pppoatm: allow assign only on a connected socket" fixed
common cases where the pppoatm_send() crashes while sending
frame to not-ready vcc. However there are still some other cases
where we can send frames to vcc, which is flagged as ATM_VF_CLOSE
(for instance after vcc_release_async()) or it's opened but not
ready yet.

Now pppoatm_send(), like vcc_sendmsg(), checks for vcc flags that
indicate that vcc is not ready. If the vcc is not ready we just
drop frame. Queueing frames is much more complicated because we
don't have callbacks that inform us about vcc flags changes.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 net/atm/pppoatm.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index c4a57bc..aeb726c 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -284,6 +284,13 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 	bh_lock_sock(sk_atm(vcc));
 	if (sock_owned_by_user(sk_atm(vcc)))
 		goto nospace;
+	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
+	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
+	    !test_bit(ATM_VF_READY, &vcc->flags)) {
+		bh_unlock_sock(sk_atm(vcc));
+		kfree_skb(skb);
+		return DROP_PACKET;
+	}
 
 	switch (pvcc->encaps) {		/* LLC encapsulation needed */
 	case e_llc:
-- 
1.8.0
