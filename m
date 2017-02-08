From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net-next 1/7] openvswitch: Use inverted tuple in ovs_ct_find_existing() if NATted.
Date: Tue, 7 Feb 2017 21:30:41 -0800
Message-ID: <204B738D-24D8-4F48-BE69-9229B39CDA8D@ovn.org>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <CAOrHB_BnAKxmexSvE-wGiO=AqL3X_YB1x9mk_PVKCqRUOhp7mg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32774 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751698AbdBHFao (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 00:30:44 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so10822951pfg.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 21:30:44 -0800 (PST)
In-Reply-To: <CAOrHB_BnAKxmexSvE-wGiO=AqL3X_YB1x9mk_PVKCqRUOhp7mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 6, 2017, at 9:07 AM, Pravin Shelar <pshelar@ovn.org> wrote:
> 
> On Thu, Feb 2, 2017 at 5:10 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
>> When looking for an existing conntrack entry, the packet 5-tuple
>> must be inverted if NAT has already been applied, as the current
>> packet headers do not match any conntrack tuple.  For
>> example, if a packet from private address X to a public address B is
>> source-NATted to A, the conntrack entry will have the following tuples
>> (ignoring the protocol and port numbers) after the conntrack entry is
>> committed:
>> 
>> Original direction tuple: (X,B)
>> Reply direction tuple: (B,A)
>> 
>> Now, if a reply packet is already transformed back to the private
>> address space (e.g., with a CT(nat) action), the tuple corresponding
>> to the current packet headers is:
>> 
>> Current packet tuple: (B,X)
>> 
>> This does not match either of the conntrack tuples above.  Normally
>> this does not matter, as the conntrack lookup was already done using
>> the tuple (B,A), but if the current packet does not match any flow in
>> the OVS datapath, the packet is sent to userspace via an upcall,
>> during which the packet's skb is freed, and the conntrack entry
>> pointer in the skb is lost.  When the packet is reintroduced to the
>> datapath, any further conntrack action will need to perform a new
>> conntrack lookup to find the entry again.  Prior to this patch this
>> second lookup failed for NATted packets.  The datapath flow setup
>> corresponding to the upcall can succeed, however, allowing all further
>> packets in the reply direction to re-use the conntrack entry pointer
>> in the skb, so typically the lookup failure only causes a packet drop.
>> 
>> The solution is to invert the tuple derived from the current packet
>> headers in case the conntrack state stored in the packet metadata
>> indicates that the packet has been transformed by NAT:
>> 
>> Inverted tuple: (X,B)
>> 
>> With this the conntrack entry can be found, matching the original
>> direction tuple.
>> 
>> This same logic also works for the original direction packets:
>> 
>> Current packet tuple (after NAT): (A,B)
>> Inverted tuple: (B,A)
>> 
>> While the current packet tuple (A,B) does not match either of the
>> conntrack tuples, the inverted one (B,A) does match the reply
>> direction tuple.
>> 
>> Since the inverted tuple matches the reverse direction tuple the
>> direction of the packet must be reversed as well.
>> 
>> Fixes: 05752523e565 ("openvswitch: Interface with NAT.")
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> 
> I could not apply this patch series to net-next branch. But it does
> applies to net, which branch are you targeting it for?

The patches were against net-next, but there likely was a merge from netfilter around the time of me sending the email out causing the difficulty. Will address all comments, rebase and post a v2 later today.

 Jarno
