From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH 2/2] ppp_generic: linearise skbs before passing them to pppd
Date: Fri, 30 Apr 2010 19:41:45 +0100
Message-ID: <4BDB2469.6020105@simon.arlott.org.uk>
References: <4BDB244D.40800@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4BDB244D.40800@simon.arlott.org.uk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frequently when using PPPoE with an interface MTU greater than 1500,
the skb is likely to be non-linear. If the skb needs to be passed to
pppd then the skb must be linearised first.

The previous commit fixes an issue with accidentally sending skbs
to pppd based on an invalid read of the protocol type. When that
error occurred pppd was reading invalid skb data too.

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
Tested with PPPoE over e1000 at MTU 16110.

 drivers/net/ppp_generic.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index fdd8deb..6855a7b 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1222,6 +1222,8 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 	if (ppp->flags & SC_LOOP_TRAFFIC) {
 		if (ppp->file.rq.qlen > PPP_MAX_RQLEN)
 			goto drop;
+		if (skb_linearize(skb))
+			goto drop;
 		skb_queue_tail(&ppp->file.rq, skb);
 		wake_up_interruptible(&ppp->file.rwait);
 		return;
@@ -1586,6 +1588,12 @@ ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
 	proto = PPP_PROTO(skb);
 	if (!pch->ppp || proto >= 0xc000 || proto == PPP_CCPFRAG) {
 		/* put it on the channel queue */
+		if (skb_linearise(skb)) {
+			kfree_skb(skb);
+			if (pch->ppp)
+				ppp_receive_error(pch->ppp);
+			goto done;
+		}
 		skb_queue_tail(&pch->file.rq, skb);
 		/* drop old frames if queue too long */
 		while (pch->file.rq.qlen > PPP_MAX_RQLEN &&
@@ -1733,6 +1741,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 	npi = proto_to_npindex(proto);
 	if (npi < 0) {
 		/* control or unknown frame - pass it to pppd */
+		if (skb_linearize(skb))
+			goto err;
 		skb_queue_tail(&ppp->file.rq, skb);
 		/* limit queue length by dropping old frames */
 		while (ppp->file.rq.qlen > PPP_MAX_RQLEN &&
-- 
1.7.0.4

-- 
Simon Arlott
