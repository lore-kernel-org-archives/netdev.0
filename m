From: Ido Schimmel <idosch@idosch.org>
Subject: Re: RIF/VRF overflow in spectrum and reporting errors back to user
Date: Tue, 10 Oct 2017 18:47:05 +0300
Message-ID: <20171010154705.GA16622@shredder.mtl.com>
References: <8d0df382-35d1-7991-1c39-9a2b5d5334e2@gmail.com>
 <20171009093110.GA5193@shredder.mtl.com>
 <779c2ba6-fd29-b260-f008-b41a607acd41@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57819 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755866AbdJJPrI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 11:47:08 -0400
Content-Disposition: inline
In-Reply-To: <779c2ba6-fd29-b260-f008-b41a607acd41@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 09:23:48AM -0600, David Ahern wrote:
> On 10/9/17 3:31 AM, Ido Schimmel wrote:
> >> Can NETDEV_UP be ignored for the inetaddr notifier if it is handled by
> >> the validator notitifer?
> > 
> > Yes. The case where we get a NETDEV_DOWN for an address delete and then
> > a NETDEV_UP for a promotion is basically a NOP from the driver's
> > perspective. When the NETDEV_DOWN is received, the RIF isn't destroyed
> > because the address list isn't empty (there's an address to be
> > promoted). When the NETDEV_UP is received, it's ignored because we
> > already have a RIF.
> 
> You lost me on the RIF. Looking at the chain:
> 
> mlxsw_sp_inet6addr_event_work or mlxsw_sp_inetaddr_event
> - __mlxsw_sp_inetaddr_event
>   + mlxsw_sp_inetaddr_vlan_event
>     * mlxsw_sp_inetaddr_port_vlan_event
>       - NETDEV_UP: mlxsw_sp_port_vlan_router_join
> 
> mlxsw_sp_port_vlan_router_join does the rif lookup and if it exists
> calls fid_get() which takes a reference. I read that to mean
> back-to-back NETDEV_UP notifiers (the address validator and then the
> address notifier) would lead to a reference count leak.
> 
> Based on your address delete comment, I take the IPv4 solution to be
> adding the validator notifier to spectrum and then ignoring NETDEV_UP in
> mlxsw_sp_inetaddr_event. That means IPv4 inetaddr work is done for the
> validator notifier while NETDEV_DOWN is done through the inetaddr notifier.

Exactly. The only NETDEV_UP we "miss" is the one sent for the promoted
address in the inetaddr chain, but it's irrelevant because when we got
the preceding NETDEV_DOWN for the deleted primary address we didn't
destroy the RIF as the address list wasn't empty (see
mlxsw_sp_rif_should_config() which is called by both top functions in
your call chain).

> > Regarding IPv6, it's a bit more complicated actually, since we do the
> > actual work in a workqueue, as the notification chain is atomic. I
> > believe this is because the notifier can be called from softirq in
> > response to RA packets.
> > 
> > However, this case isn't interesting for mlxsw, as the fact that you
> > process an RA packet suggests you already have a link-local address and
> > thus a RIF. Plus, the kernel won't even process such packets in our case
> > as you most likely have forwarding enabled (unless you tweaked accept_ra
> > for some reason).
> > 
> > Looking at ipvlan (the only user of inet6addr_validator_chain), I see
> > that it ignores this specific case and returns NOTIFY_DONE. Maybe we can
> > move this notification chain to be blocking and not call it in response
> > to RA packets seeing that all its users ignore it?
> 
> Seems reasonable to me.
> 
> I have it coded. Let me test and send an rfc.

Great. Looking forward to it.
