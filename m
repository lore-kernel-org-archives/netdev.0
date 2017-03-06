From: Jouni Malinen <jouni@codeaurora.org>
Subject: Re: [PATCH] bridge: Add support for IEEE 802.11 Proxy ARP for IPv6
Date: Mon, 6 Mar 2017 19:05:25 +0200
Message-ID: <20170306170525.GA14234@jouni.qca.qualcomm.com>
References: <1487961581-20683-1-git-send-email-jouni@codeaurora.org>
 <20170224115537.160609db@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40606 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754269AbdCFRFg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 12:05:36 -0500
Content-Disposition: inline
In-Reply-To: <20170224115537.160609db@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 24, 2017 at 11:55:37AM -0800, Stephen Hemminger wrote:
> The concept is fine.

Thanks for taking a look.

> Please add some comments to the code about what is happening and why.
> The proposed patch is too sparse and has no comments.

Sure, will do that for the next version.

> > +	skb = alloc_skb(hlen + sizeof(struct ipv6hdr) + sizeof(*msg) +
> > +			ndisc_opt_addr_space(dev,
> > +					     NDISC_NEIGHBOUR_ADVERTISEMENT) +
> > +			tlen, GFP_ATOMIC);
> > +	if (!skb)
> > +		return;
> 
> Why not netdev_alloc_skb which takes care of padding and setting skb->dev? 

This implementation in br_ndisc_send_na() was trying to follow
ndisc_send_na() design for the operations.. If this function remains
(see below), I can clean this up further.

> Rather than doing copy/paste of the code to generate a ND message, it would
> be better to have one function in IPv6 code that handles that. That would keep
> from having to fix code in two places in the future. Is there some way
> to extend ndisc_send_na?

That was the original plan and adding the target_lladdr part would be
straightforward. The part that gets complex is in figuring out how to
use a foreign link layer source address (the MAC address on behalf of
which the local device is replying) in the outgoing NA when using the
IEEE 802.11/Hotspot 2.0 design.

ndisc_send_na() uses the full IPv6 stack for building the frame when
calling ndisc_send_skb(). dst_output() ends up sending this through
ip6_output(), I'd assume, and after building the IPv6 header, the local
MAC address of the outgoing interface gets assigned to the Ethernet
header. I'm not sure how to override that functionality in any clean
way. The dev_hard_header() call in the mostly copy-pasted version in
br_ndisc_send_na() followed by use of the custom
br_ndisc_send_na_finish() to call dev_queue_xmit(skb) was done to allow
the link layer source address to be modified.

The normal path in the net stack seemed to use dev_hard_header() with
saddr = NULL which maps to eth_header() saddr = NULL case to use device
source address. Either those would need to be somehow modified for this
special skb containing the NA with different source address requirement
or something after these calls would need to modify the frame to change
the source address.

Would you happen to know any convenient means for modifying the IPv6
stack behavior for ndisc_send_skb() cases conditionally to allow the
link layer source address to be modified while still being able to use
the existing IPv6 header and the Ethernet header construction function?

-- 
Jouni Malinen                                            PGP id EFC895FA
