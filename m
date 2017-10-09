From: Ido Schimmel <idosch@idosch.org>
Subject: Re: RIF/VRF overflow in spectrum and reporting errors back to user
Date: Mon, 9 Oct 2017 12:31:10 +0300
Message-ID: <20171009093110.GA5193@shredder.mtl.com>
References: <8d0df382-35d1-7991-1c39-9a2b5d5334e2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39605 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751636AbdJIJbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 05:31:12 -0400
Content-Disposition: inline
In-Reply-To: <8d0df382-35d1-7991-1c39-9a2b5d5334e2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sun, Oct 08, 2017 at 02:10:33PM -0600, David Ahern wrote:
> Jiri / Ido:
> 
> I am looking at adding user messages for spectrum failures related to
> RIF and VRF overflow coming from the inetaddr and inet6addr notifier
> paths. The key is that if the notifiers fail the address add needs to
> fail and an error reported to the user as to what happened.

Thanks for working on this. Very nice idea!

> Earlier this year 3ad7d2468f79f added in_validator_info and
> in6_validator_info as a way for the notifiers to fail adding an address.
> Adding support to spectrum for that notifier is complicated by the fact
> that the validator notifier and address notifiers will come in back to
> back for the NETDEV_UP case. Ignoring NETDEV_UP in
> mlxsw_sp_inetaddr_event seems ok for IPv6 but not clear for IPv4 since
> the NETDEV_UP case is emitted on an address delete that involves a
> promotion. Handling the back to back NETDEV_UP is complicated since
> functions invoked by __mlxsw_sp_inetaddr_event can take multiple
> references. Specifically, in mlxsw_sp_port_vlan_router_join():
>     fid = rif->ops->fid_get(rif);
> 
> Can NETDEV_UP be ignored for the inetaddr notifier if it is handled by
> the validator notitifer?

Yes. The case where we get a NETDEV_DOWN for an address delete and then
a NETDEV_UP for a promotion is basically a NOP from the driver's
perspective. When the NETDEV_DOWN is received, the RIF isn't destroyed
because the address list isn't empty (there's an address to be
promoted). When the NETDEV_UP is received, it's ignored because we
already have a RIF.

Regarding IPv6, it's a bit more complicated actually, since we do the
actual work in a workqueue, as the notification chain is atomic. I
believe this is because the notifier can be called from softirq in
response to RA packets.

However, this case isn't interesting for mlxsw, as the fact that you
process an RA packet suggests you already have a link-local address and
thus a RIF. Plus, the kernel won't even process such packets in our case
as you most likely have forwarding enabled (unless you tweaked accept_ra
for some reason).

Looking at ipvlan (the only user of inet6addr_validator_chain), I see
that it ignores this specific case and returns NOTIFY_DONE. Maybe we can
move this notification chain to be blocking and not call it in response
to RA packets seeing that all its users ignore it?

Please let me know if you need my help in any way.
