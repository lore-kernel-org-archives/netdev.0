From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen patch available for perusal.
Date: Fri, 03 Nov 2006 12:41:59 -0800
Message-ID: <454BA997.1060401@candelatech.com>
References: <45468F2E.4060809@candelatech.com>	<17736.54766.657083.873206@robur.slu.se>	<4548F166.1020001@candelatech.com>	<17739.9326.620495.394705@robur.slu.se>	<454B6F9D.8030300@candelatech.com> <17739.42375.80475.907057@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:64182 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932085AbWKCUmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 15:42:02 -0500
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17739.42375.80475.907057@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Ben Greear writes:
> 
>  > It requires a hook in dev.c, or at least that is the only way I can 
>  > think to implement it.
> 
> Well the hook be placed along the packet path even in drivers. In tulip I didn't 
> even take packet of the ring in some experiments. 
> 
> And there plenty of existing hooks already i.e PRE_ROUTE?

For my particular application the hook needs to be right
after the bridge hook.  My dev.c hook looks like this:

#if defined(CONFIG_NET_PKTGEN) || defined(CONFIG_NET_PKTGEN_MODULE)
#include "pktgen.h"

#warning "Compiling dev.c for pktgen.";

int (*handle_pktgen_hook)(struct sk_buff *skb) = NULL;
EXPORT_SYMBOL(handle_pktgen_hook);

static __inline__ int handle_pktgen_rcv(struct sk_buff* skb) {
	if (handle_pktgen_hook) {
		return handle_pktgen_hook(skb);
	}
	return -1;
}
#endif

.....

#if defined(CONFIG_NET_PKTGEN) || defined(CONFIG_NET_PKTGEN_MODULE)
	if ((skb->dev->pkt_dev) &&
	    (handle_pktgen_rcv(skb) >= 0)) {
		/* Pktgen may consume the packet, no need to send
		 * to further protocols.
		 */
		goto out;
	}
#endif


If the rx-hook logic is already in pktgen module, and it's symbol
exported, perhaps a second hook module could be written that
would just be the bridge between a driver or a PRE-ROUTE hook
and pktgen?  The hook module would probably not be much larger
than the code above...


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

