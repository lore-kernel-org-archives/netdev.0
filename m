From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: PATCH: fix bridged 802.3ad bonding
Date: Tue, 3 Jun 2008 21:55:19 -0700
Message-ID: <20080603215519.298c0cd3@extreme>
References: <20080603132106.GA3256@midget.suse.cz>
	<20080603094604.6a7dfe7d@extreme>
	<20080603193227.GA4050@midget.suse.cz>
	<20080603131326.1f70915e@extreme>
	<18105.1212528128@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37896 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751090AbYFDFC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 01:02:29 -0400
In-Reply-To: <18105.1212528128@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Jun 2008 14:22:08 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
> >On Tue, 3 Jun 2008 21:32:27 +0200
> >Jiri Bohac <jbohac@suse.cz> wrote:
> [...]
> >> But I think I found a much nicer fix for the problem:
> >> 
> >> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> >> --- a/net/bridge/br_input.c
> >> +++ b/net/bridge/br_input.c
> >> @@ -136,6 +136,10 @@ struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
> >>  		if (skb->protocol == htons(ETH_P_PAUSE))
> >>  			goto drop;
> >>  
> >> +		/* Don't touch SLOW frames (LACP, etc.) */
> >> +		if (skb->protocol == htons(ETH_P_SLOW))
> >> +			return skb;
> >> +
> >>  		/* Process STP BPDU's through normal netif_receive_skb() path */
> >>  		if (p->br->stp_enabled != BR_NO_STP) {
> >>  			if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> >> 
> >> The LACP frames always have the link-local destination MAC
> >> address and so they are not handled by the bridge anyway. They
> >> are only dropped, unless STP is turned on. So let's just not drop
> >> the SLOW packets. Does this look better?
> >> 


I prefer the following because it process all link-local frames through
the normal input path. This means the frames will:
	* be filterable by netfilter
	* processed by af_packet users
	* not forwarded across bridge (this is important).


--- a/net/bridge/br_input.c	2008-06-03 21:44:54.000000000 -0700
+++ b/net/bridge/br_input.c	2008-06-03 21:52:20.000000000 -0700
@@ -135,15 +135,12 @@ struct sk_buff *br_handle_frame(struct n
 		/* Pause frames shouldn't be passed up by driver anyway */
 		if (skb->protocol == htons(ETH_P_PAUSE))
 			goto drop;
-
-		/* Process STP BPDU's through normal netif_receive_skb() path */
-		if (p->br->stp_enabled != BR_NO_STP) {
-			if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-				    NULL, br_handle_local_finish))
-				return NULL;
-			else
-				return skb;
-		}
+
+		if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
+			    NULL, br_handle_local_finish))
+			return NULL;	/* frame consumed by filter */
+		else
+			return skb;	/* continue processing */
 	}
 
 	switch (p->state) {
