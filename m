From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 15:35:34 -0700
Message-ID: <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>
	 <alpine.DEB.1.10.0908251514190.17963@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, niv@linux.vnet.ibm.com,
	sri@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:57668 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756244AbZHYWff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2009 18:35:35 -0400
In-Reply-To: <alpine.DEB.1.10.0908251514190.17963@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-08-25 at 15:15 -0400, Christoph Lameter wrote:
> On Tue, 25 Aug 2009, David Stevens wrote:
> 
> > Christoph Lameter <cl@linux-foundation.org> wrote on 08/25/2009 06:48:24
> > AM:
> >
> > > On Mon, 24 Aug 2009, Sridhar Samudrala wrote:
> >
> > > > If we count these drops as qdisc drops, should we also count them as
> > IP OUTDISCARDS?
> > >
> > > Yes.
> >
> > Actually, no. (!)
> >
> > IP_OUTDISCARDS should count the packets IP dropped, not
> > anything dropped at a lower layer (which, in general, it
> > is not aware of). If you count these in multiple layers,
> > then you don't really know who dropped it.
> 
> You are right. I skipped that IP OUTDICARDS reference. They need to be
> accounted at the qdisc level though.

Yes. Now that we agree that drops at dev_queue_xmit level should be counted
under qdisc stats, the following patch should address 1 of the 3 places where
NET_XMIT_DROP is returned, but qdisc drop stats is not incremented.
The other 2 places are in ipsec output functions esp_output and esp6_output.
I am not sure where these drops should be accounted.

Could you check if the UDP packet losses you are seeing are accounted for in
qdisc drops with this patch. But i am not completely positive on this as this
case happens only if qdisc is deactivated.

diff --git a/net/core/dev.c b/net/core/dev.c
index 6a94475..8b6a075 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1864,8 +1864,7 @@ gso:
 		spin_lock(root_lock);
 
 		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
-			kfree_skb(skb);
-			rc = NET_XMIT_DROP;
+			rc = qdisc_drop(skb, q);
 		} else {
 			rc = qdisc_enqueue_root(skb, q);
 			qdisc_run(q);

Thanks
Sridhar

