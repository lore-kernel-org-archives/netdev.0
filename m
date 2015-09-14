From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH] net: bridge: fix for bridging 802.1Q without
 REORDER_HDR
Date: Mon, 14 Sep 2015 22:06:48 +0200
Message-ID: <20150914200648.GH30501@orbit.nwl.cc>
References: <1441999323-29381-1-git-send-email-phil@nwl.cc>
 <20150911122445.53cdfbcf@urahara>
 <20150911202033.GE7029@orbit.nwl.cc>
 <55F71016.7060202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:55436 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752008AbbINUGu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2015 16:06:50 -0400
Content-Disposition: inline
In-Reply-To: <55F71016.7060202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2015 at 02:21:10PM -0400, Vlad Yasevich wrote:
> On 09/11/2015 04:20 PM, Phil Sutter wrote:
> > On Fri, Sep 11, 2015 at 12:24:45PM -0700, Stephen Hemminger wrote:
> >> On Fri, 11 Sep 2015 21:22:03 +0200
> >> Phil Sutter <phil@nwl.cc> wrote:
> >>
> >>> When forwarding packets from an 802.1Q interface with REORDER_HDR set to
> >>> zero, the VLAN header previously inserted by vlan_do_receive() needs to
> >>> be stripped from the packet and the mac_header adjustment undone,
> >>> otherwise a tagged frame with first four bytes missing will be
> >>> transmitted.
> >>>
> >>> Signed-off-by: Phil Sutter <phil@nwl.cc>
> >>> ---
> >>>  net/bridge/br_input.c | 10 ++++++++++
> >>>  1 file changed, 10 insertions(+)
> >>>
> >>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> >>> index f921a5d..e4e3fc7 100644
> >>> --- a/net/bridge/br_input.c
> >>> +++ b/net/bridge/br_input.c
> >>> @@ -288,6 +288,16 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
> >>>  	}
> >>>  
> >>>  forward:
> >>> +	if (is_vlan_dev(skb->dev) &&
> >>> +	    !(vlan_dev_priv(skb->dev)->flags & VLAN_FLAG_REORDER_HDR)) {
> >>> +		unsigned int offset = skb->data - skb_mac_header(skb);
> >>> +
> >>> +		skb_push(skb, offset);
> >>> +		memmove(skb->data + VLAN_HLEN, skb->data, 2 * ETH_ALEN);
> >>> +		skb->mac_header += VLAN_HLEN;
> >>> +		skb_pull(skb, offset);
> >>> +		skb_reset_mac_len(skb);
> >>> +	}
> >>>  	switch (p->state) {
> >>>  	case BR_STATE_FORWARDING:
> >>>  		rhook = rcu_dereference(br_should_route_hook);
> >>
> >> Thanks for finding this. Is this a new thing or has it always been there?
> > 
> > Sorry, I didn't check if this is a regression or not. Seen initially
> > with RHEL7's kernel-3.10.0-229.7.2, which due to the massive backporting
> > is by far not as old as it might seem. But it's surely not a brand new
> > problem of net-next or so.
> > 
> > Since nowadays no sane mind touches REORDER_HDR (there was originally a
> > bug in NetworkManager which defaulted this to 0), it may very well be
> > there for a long time already.
> > 
> >> Sorry, this looks so special case it doesn't seem like a good idea.
> >> Something is broken in VLAN handling if this is required.
> > 
> > It is so ugly, I wish I had found a better way to fix the problem. Well,
> > maybe I miss something:
> > 
> > - packet enters __netif_receive_skb_core():
> >   - skb->protocol is set to ETH_P_8021Q, so:
> >     - packet is untagged
> >     - skb->vlan_tci set
> >     - skb->protocol set to 'real' protocol
> >   - skb_vlan_tag_present(skb) == true, so:
> >     - vlan_do_receive() is called:
> >       - tags the packet again
> >       - zeroes vlan_tci
> >     - goto another_round
> > - __netif_receive_skb_core(), round 2:
> >   - skb->protocol is not ETH_P_8021Q -> no untagging
> >   - skb_vlan_tag_present(skb) == false -> no vlan_do_receive()
> >   - rx_handler handler (== br_handle_frame) is called
> > 
> > IMO the root of all evil is the existence of REORDER_HDR itself. It
> > causes an skb which should have been untagged to being passed along with
> > VLAN header present and code dealing with it needs to clean up the mess.
> 
> So the problem here appears the be the code the in br_dev_queue_push_xmit().
> It assumes that MAC_HLEN worth of data has been removed from the skb,
> which is normal in case of normal VLAN processing.  However, without
> REORDER_HEADER set this is no longer the case.  In this case, the ethernet
> header is shifted 4 bytes, and when we push the it back we miss the 4 bytes
> of the destination mac address...

Please note that vlan_do_receive() also inserts the VLAN header in
between ethernet header and IP header, therefore:

> I wonder if it would be safe to just use skb->mac_len.

Given this works, the bridge would still forward a tagged frame which
should have been untagged in the first place.

I just wondered where this added VLAN header is dropped if the interface
does not belong to a bridge, but then realized that further packet
processing simply ignores the ethernet header (and everything following
it). So unless I forget something, this should indeed be a
bridge-specific problem.

Cheers, Phil
