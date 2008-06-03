From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: PATCH: fix bridged 802.3ad bonding
Date: Tue, 3 Jun 2008 21:32:27 +0200
Message-ID: <20080603193227.GA4050@midget.suse.cz>
References: <20080603132106.GA3256@midget.suse.cz> <20080603094604.6a7dfe7d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:54373 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753922AbYFCTc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 15:32:28 -0400
Content-Disposition: inline
In-Reply-To: <20080603094604.6a7dfe7d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jun 03, 2008 at 09:46:04AM -0700, Stephen Hemminger wrote:
> On Tue, 3 Jun 2008 15:21:06 +0200 Jiri Bohac <jbohac@suse.cz> wrote:
> 
> > Bonding in 802.3ad mode breaks when the bond interface is added
> > to a bridge (which makes 802.3ad unusable in XEN, for example).
> > 
> > The problem is that br_pass_frame_up() will change the skb's dev
> > pointer to point to the bridge interface. As a result, the LACP
> > packets will not reach the bond_3ad_lacpdu_recv() protocol
> > handler registered on the bonding device. Even if they did, the
> > handler won't work with the changed skb->dev.

... actually, now I realized the above statement is wrong. The
bridging code does not change the LACP frames, it just drops
them, because the LACP frames always have the link-local
destination MAC address.
 
> The packets do arrive on the bridge
> interface which is an aggregation of all the interfaces in the bridge.
> 
> The LACPDU's are received via now on the bond device. If you moved
> the packet type handler down to the physical interface, this problem
> would go away because the packets would be handled to bond_3ad_lacpdu_recv
> prior to being handled by the bridge.

This wouldn't really work, because with bonding the packet only
passes through netif_receive_skb() once, it just has the skb->dev
modified by skb_bond() at the very beginning.

But I think I found a much nicer fix for the problem:

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -136,6 +136,10 @@ struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
 		if (skb->protocol == htons(ETH_P_PAUSE))
 			goto drop;
 
+		/* Don't touch SLOW frames (LACP, etc.) */
+		if (skb->protocol == htons(ETH_P_SLOW))
+			return skb;
+
 		/* Process STP BPDU's through normal netif_receive_skb() path */
 		if (p->br->stp_enabled != BR_NO_STP) {
 			if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,

The LACP frames always have the link-local destination MAC
address and so they are not handled by the bridge anyway. They
are only dropped, unless STP is turned on. So let's just not drop
the SLOW packets. Does this look better?

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

