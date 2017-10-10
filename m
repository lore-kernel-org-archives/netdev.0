From: David Ahern <dsahern@gmail.com>
Subject: Re: RIF/VRF overflow in spectrum and reporting errors back to user
Date: Tue, 10 Oct 2017 09:23:48 -0600
Message-ID: <779c2ba6-fd29-b260-f008-b41a607acd41@gmail.com>
References: <8d0df382-35d1-7991-1c39-9a2b5d5334e2@gmail.com>
 <20171009093110.GA5193@shredder.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ido Schimmel <idosch@mellanox.com>, Jiri Pirko <jiri@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:55481 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932262AbdJJPXu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 11:23:50 -0400
Received: by mail-pf0-f180.google.com with SMTP id 17so9227814pfn.12
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 08:23:50 -0700 (PDT)
In-Reply-To: <20171009093110.GA5193@shredder.mtl.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/9/17 3:31 AM, Ido Schimmel wrote:
> Hi David,
> 
> On Sun, Oct 08, 2017 at 02:10:33PM -0600, David Ahern wrote:
>> Jiri / Ido:
>>
>> I am looking at adding user messages for spectrum failures related to
>> RIF and VRF overflow coming from the inetaddr and inet6addr notifier
>> paths. The key is that if the notifiers fail the address add needs to
>> fail and an error reported to the user as to what happened.
> 
> Thanks for working on this. Very nice idea!
> 
>> Earlier this year 3ad7d2468f79f added in_validator_info and
>> in6_validator_info as a way for the notifiers to fail adding an address.
>> Adding support to spectrum for that notifier is complicated by the fact
>> that the validator notifier and address notifiers will come in back to
>> back for the NETDEV_UP case. Ignoring NETDEV_UP in
>> mlxsw_sp_inetaddr_event seems ok for IPv6 but not clear for IPv4 since
>> the NETDEV_UP case is emitted on an address delete that involves a
>> promotion. Handling the back to back NETDEV_UP is complicated since
>> functions invoked by __mlxsw_sp_inetaddr_event can take multiple
>> references. Specifically, in mlxsw_sp_port_vlan_router_join():
>>     fid = rif->ops->fid_get(rif);
>>
>> Can NETDEV_UP be ignored for the inetaddr notifier if it is handled by
>> the validator notitifer?
> 
> Yes. The case where we get a NETDEV_DOWN for an address delete and then
> a NETDEV_UP for a promotion is basically a NOP from the driver's
> perspective. When the NETDEV_DOWN is received, the RIF isn't destroyed
> because the address list isn't empty (there's an address to be
> promoted). When the NETDEV_UP is received, it's ignored because we
> already have a RIF.

You lost me on the RIF. Looking at the chain:

mlxsw_sp_inet6addr_event_work or mlxsw_sp_inetaddr_event
- __mlxsw_sp_inetaddr_event
  + mlxsw_sp_inetaddr_vlan_event
    * mlxsw_sp_inetaddr_port_vlan_event
      - NETDEV_UP: mlxsw_sp_port_vlan_router_join

mlxsw_sp_port_vlan_router_join does the rif lookup and if it exists
calls fid_get() which takes a reference. I read that to mean
back-to-back NETDEV_UP notifiers (the address validator and then the
address notifier) would lead to a reference count leak.

Based on your address delete comment, I take the IPv4 solution to be
adding the validator notifier to spectrum and then ignoring NETDEV_UP in
mlxsw_sp_inetaddr_event. That means IPv4 inetaddr work is done for the
validator notifier while NETDEV_DOWN is done through the inetaddr notifier.

> 
> Regarding IPv6, it's a bit more complicated actually, since we do the
> actual work in a workqueue, as the notification chain is atomic. I
> believe this is because the notifier can be called from softirq in
> response to RA packets.
> 
> However, this case isn't interesting for mlxsw, as the fact that you
> process an RA packet suggests you already have a link-local address and
> thus a RIF. Plus, the kernel won't even process such packets in our case
> as you most likely have forwarding enabled (unless you tweaked accept_ra
> for some reason).
> 
> Looking at ipvlan (the only user of inet6addr_validator_chain), I see
> that it ignores this specific case and returns NOTIFY_DONE. Maybe we can
> move this notification chain to be blocking and not call it in response
> to RA packets seeing that all its users ignore it?

Seems reasonable to me.

I have it coded. Let me test and send an rfc.
