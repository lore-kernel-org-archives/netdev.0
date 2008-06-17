From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: PATCH: fix bridged 802.3ad bonding
Date: Tue, 17 Jun 2008 17:33:30 +0200
Message-ID: <20080617153329.GA9429@midget.suse.cz>
References: <20080604082425.GA3272@midget.suse.cz> <20080604090633.2a12cecc@extreme> <20080605101319.GA3756@midget.suse.cz> <20080610.154236.189971046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jbohac@suse.cz,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:43434 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758443AbYFQPdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 11:33:31 -0400
Content-Disposition: inline
In-Reply-To: <20080610.154236.189971046.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 10, 2008 at 03:42:36PM -0700, David Miller wrote:
> From: Jiri Bohac <jbohac@suse.cz> Date: Thu, 5 Jun 2008 12:13:20 +0200
> > Ah, I see. So can we get one of the patches in? I still think
> > that running the LACP frames through the bridging NF hooks does
> > not make sense, but it's your call.
> 
> Stephen, if prefer your approach, please repost your patch with full
> commit message and proper signoffs, thanks!

Stephen, I haven't seen a definitive answer from you - can you
please either ack my patch (underneath) or repost yours?

Thanks!


Fix bridged 802.3ad bonding

When a bonding master is added to a bridge, the bridging hook
will take over the LACP frames. The bonding ETH_P_SLOW ptype
handler will not get these, because the skb->dev is changed by
the bridging code. This breaks bonding in the 802.3ad mode.

ETH_P_SLOW frames should not be touched by the bridge.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

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

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

