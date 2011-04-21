From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bonding: fix bridged bonds in 802.3ad mode
Date: Thu, 21 Apr 2011 14:08:17 -0700
Message-ID: <20110421140817.1782b2a9@nehalam>
References: <20110421184748.GD23756@midget.suse.cz>
	<1303412899.3165.47.camel@bwh-desktop>
	<4DB096E0.4010407@polymtl.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Benjamin Poirier <benjamin.poirier@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45387 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754109Ab1DUVJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 17:09:21 -0400
In-Reply-To: <4DB096E0.4010407@polymtl.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Apr 2011 16:43:12 -0400
Benjamin Poirier <benjamin.poirier@polymtl.ca> wrote:

> On 21/04/11 03:08 PM, Ben Hutchings wrote:
> > On Thu, 2011-04-21 at 20:47 +0200, Jiri Bohac wrote:
> >> 802.3ad bonding inside a bridge is broken again. Originally fixed by
> >> 43aa1920117801fe9ae3d1fad886b62511e09bee, the bug was re-introduced by
> >> 1e253c3b8a1aeed51eef6fc366812f219b97de65.
> >>
> >> LACP frames must not have their skb->dev changed by the bridging hook.
> >>
> >> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> >>
> >> --- a/drivers/net/bonding/bond_main.c
> >> +++ b/drivers/net/bonding/bond_main.c
> >> @@ -1514,6 +1514,11 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
> >>  		memcpy(eth_hdr(skb)->h_dest, bond->dev->dev_addr, ETH_ALEN);
> >>  	}
> >>  
> >> +	/* prevent bridging code from mangling and forwarding LACP frames */
> >> +	if (bond->params.mode == BOND_MODE_8023AD &&
> >> +	    skb->protocol == htons(ETH_P_SLOW))
> >> +		return RX_HANDLER_PASS;
> >> +
> >>  	return RX_HANDLER_ANOTHER;
> >>  }
> >>  
> > 
> > It seems to me that 1e253c3b8a1aeed51eef6fc366812f219b97de65 is bogus
> 
> You bet, it's rubbish ;)
> 
> Any thoughts on how we could support a transparent bridging
> configuration without repurposing br->stp_enabled or adding another
> option to bridge-utils?
> 
> btw, the particular scenario I was trying to address is a virtual
> machine bridged to an ethernet interface connected to a switch port with
> 802.1x enabled.
> 
> -Benjamin
> 
> > and should be reverted, rather than worked around by other drivers.  We
> > shouldn't enable non-conformant forwarding behaviour by default just
> > because some people find it useful.  The administrator should have to
> > explicitly enable it.
> > 
> > Ben.
> > 
> 


The IEEE standard says bridge's shouldn't forward link-local addresses.
The problem is that people expect it to.


-- 
