From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v2] act_mirred: Fix bogus header when redirecting from VLAN
Date: Fri, 17 Apr 2015 13:32:09 +0800
Message-ID: <20150417053209.GA23855@gondor.apana.org.au>
References: <20150417010216.GA22415@gondor.apana.org.au>
 <20150417013401.GA4335@Alexeis-MacBook-Pro.local>
 <20150417021501.GB22835@gondor.apana.org.au>
 <20150417024029.GA6718@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54975 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbbDQFcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 01:32:13 -0400
Content-Disposition: inline
In-Reply-To: <20150417024029.GA6718@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2015 at 07:40:30PM -0700, Alexei Starovoitov wrote:
> On Fri, Apr 17, 2015 at 10:15:01AM +0800, Herbert Xu wrote:
> > > seems the cleaner fix will be to push skb->mac_len instead?
> > 
> > No skb->mac_len is the same as skb2->dev->hard_header_len.
> 
> hmm. please help me understand the problem then.
> In the commit log you mentioned that your vlan dev and ifb
> have unequal hard header length. I think that can only happen if
> your master dev used to create vlan, didn't have vlan offload,
> so vlandev->hhl = 18 and ifb->hhl = 14. Then when tagged packet
> arrives on master device we call skb_vlan_untag() and
> skb->mac_len becomes 14, then vlan_do_receive() will do

You are right.  I should've just used mac_len.

---8<---
When you redirect a VLAN device to any device, you end up with
crap in af_packet on the xmit path because hard_header_len is
not equal to skb->mac_len.  So the redirected packet contains
four extra bytes at the start which then gets interpreted as
part of the MAC address.

This patch fixes this by only pushing skb->mac_len.  We also
need to fix ifb because it tries to undo the pushing done by
act_mirred.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 34f846b..94570aa 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -105,7 +105,7 @@ static void ri_tasklet(unsigned long dev)
 		if (from & AT_EGRESS) {
 			dev_queue_xmit(skb);
 		} else if (from & AT_INGRESS) {
-			skb_pull(skb, skb->dev->hard_header_len);
+			skb_pull(skb, skb->mac_len);
 			netif_receive_skb(skb);
 		} else
 			BUG();
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 5953517..3f63cea 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -157,7 +157,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 
 	if (!(at & AT_EGRESS)) {
 		if (m->tcfm_ok_push)
-			skb_push(skb2, skb2->dev->hard_header_len);
+			skb_push(skb2, skb->mac_len);
 	}
 
 	/* mirror is always swallowed */

-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
