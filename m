From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH] bonding: fix arp_validate on bonds inside a bridge
Date: Wed, 5 May 2010 15:33:01 +0200
Message-ID: <20100505133301.GA18493@midget.suse.cz>
References: <20100503.155820.158442623.davem@davemloft.net>
 <10955.1272927779@death.nxdomain.ibm.com>
 <17907.1272935182@death.nxdomain.ibm.com>
 <20100504.161815.71114704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, jbohac@suse.cz,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51297 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757081Ab0EENdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 09:33:00 -0400
Content-Disposition: inline
In-Reply-To: <20100504.161815.71114704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 04, 2010 at 04:18:15PM -0700, David Miller wrote:
> From: Jay Vosburgh <fubar@us.ibm.com>
> > 	Tested and it looks to work as advertised.  I see only one minor
> > nit, there's a pr_debug that missed being renamed to the new function
> > name; here's the whole patch with that fixed.
> 
> I don't think you need the ugly arp hook.
> 
> Instead, it's much cleaner to provide a way for packet type taps to
> see the packet before bridge et al. decapsulation.  In fact this makes
> a lot of sense, wanting to see the device as __netif_receive_skb() saw
> it, with no changes whatsoever.
> 
> In fact ptype_all runs before bridging, ING, and MACVLAN decap the
> thing, so we could have a 'ptype_base_predecap[]' that we run over
> right after those.

I was considering exactly this, but I thought it would be
rejected because of the overhead for all packets received.

In fact, bonding could register the ARP handler in the ptype_all
list and check itself whether the packets were ARPs. This
would require no changes to __netif_receive_skb() at all, but
would cause an extra fuction call and a condition for _every_
packet once a bond with arp_validate would be up.

Having a ptype_base_predecap[] hashtable would still cause at
least a comparision for _every_ packet, even without bonding
being loaded (!).

The current patch causes an extra comparison only for packets
arriving on boding slaves.

If either of the ptype_all or ptype_base_predecap[] method is
preferred, I'll be happy to re-work the patch. I just thought
performance had bigger priority here.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

