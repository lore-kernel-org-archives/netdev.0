From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Mon, 31 Jul 2006 22:08:22 -0700
Message-ID: <20060731220822.444f04e4@localhost.localdomain>
References: <44CDD631.5030008@snapgear.com>
	<20060731091423.3327f85e@dxpl.pdx.osdl.net>
	<44CEAB31.5090501@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64652 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161038AbWHAFIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 01:08:35 -0400
To: Philip Craig <philipc@snapgear.com>
In-Reply-To: <44CEAB31.5090501@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 01 Aug 2006 11:15:29 +1000
Philip Craig <philipc@snapgear.com> wrote:

> Stephen Hemminger wrote:
> > On Mon, 31 Jul 2006 20:06:41 +1000
> > Philip Craig <philipc@snapgear.com> wrote:
> > 
> >> This patch implements transparent ethernet bridging for gre tunnels.
> >> There are a few outstanding issues.
> > 
> > Why not use existing bridge code?
> 
> It does use the existing bridge code.  Perhaps the name is misleading.
> All it does is encapsulate the full ethernet header in a gre packet,
> rather than only layer 3.  That is, currently gre uses ARPHRD_IPGRE,
> but bridging requires ARPHRD_ETHER.
> 

I am not against making the bridge code smarter to handle other
encapsulation.

> >> Some routers set LLC_SAP_BSPAN in the gre protocol field, and then
> >> give the bpdu packet without any other ethernet/llc header. This patch
> >> currently tries to fake the ethernet/llc header before passing the
> >> packet up, but it is buggy (mac addresses are wrong at least). Maybe a
> >> better approach is to call directly into the bridging code. I didn't try
> >> that at first because it isn't modular, and may break other things that
> >> want to see the packet.
> > 
> > Existing bridge code already has spanning tree.
> 
> Yes, and I want to use that.  But this packet is a bit strange in
> that it does not have the ethernet header on it.   So what is the
> best way to pass it to existing code?  Either fake the ethernet
> header, or pass it directly?

Likewise if the bridge STP bpdu input code was smarter, it could
deal with it maybe?

> 
> >> +#if 0
> >>  	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
> >> +#else
> >> +	dev = alloc_netdev(sizeof(*t), name, ipgre_ether_tunnel_setup);
> >> +#endif
> > 
> > "Do, or do not there is no try"
> 
> I am looking for comments as to whether adding a netlink interface
> to control this is appropriate.

If we make bridge code type aware, then the ipgre tunnel wouldn't have to change.

> >> +__be16 ipgre_type_trans(struct sk_buff *skb, int offset)
> >> +{
> >> +	u8     *h = skb->data;
> >> +	__be16 flags = *(__be16*)h;
> >> +	__be16 proto = *(__be16*)(h + 2);
> >> +
> >> +	/* WCCP version 1 and 2 protocol decoding.
> >> +	 * - Change protocol to IP
> >> +	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
> >> +	 */
> >> +	if (flags == 0 &&
> >> +	    proto == __constant_htons(ETH_P_WCCP)) {
> >> +		proto = __constant_htons(ETH_P_IP);
> >> +		if ((*(h + offset) & 0xF0) != 0x40)
> >> +			offset += 4;
> >> +	}
> > 
> > Don't use __constant_htons() except in initializers and switch cases
> > (where gcc is too stupid to optimize the macro).
> > 
> 
> This is a problem in the existing code, which I am simply moving
> around.  Should I fix it at the same time?

Usually if a diff touches some code, I try to make it use current practice.
