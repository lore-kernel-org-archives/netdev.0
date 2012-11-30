From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH 05/17] pppoatm: drop frames to not-ready vcc
Date: Fri, 30 Nov 2012 11:27:09 +0100
Message-ID: <20121130102709.GA29335@shrek.podlesie.net>
References: <1354235736-26833-1-git-send-email-dwmw2@infradead.org>
 <1354235736-26833-6-git-send-email-dwmw2@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil,
	David Woodhouse <David.Woodhouse@intel.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shrek-wifi.podlesie.net ([93.179.225.50]:43133 "EHLO
	shrek.podlesie.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932225Ab2K3K1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 05:27:12 -0500
Content-Disposition: inline
In-Reply-To: <1354235736-26833-6-git-send-email-dwmw2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2012 at 12:35:24AM +0000, David Woodhouse wrote:
> From: Krzysztof Mazur <krzysiek@podlesie.net>
> 
> Patches "atm: detach protocol before closing vcc"
> and "pppoatm: allow assign only on a connected socket" fixed
> common cases where the pppoatm_send() crashes while sending
> frame to not-ready vcc. However there are still some other cases
> where we can send frames to vcc, which is flagged as ATM_VF_CLOSE
> (for instance after vcc_release_async()) or it's opened but not
> ready yet.

We should update the paragraph above, with something like:

The vcc_destroy_socket() closes vcc before the protocol is detached
from vcc by calling vcc->push() with NULL skb. This leaves some time
window, where the protocol may call vcc->send() on closed vcc
and crash.

> 
> Now pppoatm_send(), like vcc_sendmsg(), checks for vcc flags that
> indicate that vcc is not ready. If the vcc is not ready we just
> drop frame. Queueing frames is much more complicated because we
> don't have callbacks that inform us about vcc flags changes.
> 
> Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

I'm sending the updated version. The only difference is the commit
message.

Krzysiek
-- >8 --
Subject: [PATCH 05/17] pppoatm: drop frames to not-ready vcc

The vcc_destroy_socket() closes vcc before the protocol is detached
from vcc by calling vcc->push() with NULL skb. This leaves some time
window, where the protocol may call vcc->send() on closed vcc
and crash.

Now pppoatm_send(), like vcc_sendmsg(), checks for vcc flags that
indicate that vcc is not ready. If the vcc is not ready we just
drop frame. Queueing frames is much more complicated because we
don't have callbacks that inform us about vcc flags changes.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
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
1.8.0.411.g71a7da8
