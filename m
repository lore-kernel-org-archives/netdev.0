From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [GIT net-next] Open vSwitch
Date: Sun, 3 Aug 2014 12:20:32 -0700
Message-ID: <CALnjE+rAXDpzkL9H9EAHKZ0yGCW3HHu+LgihwOj5Yx_5SASzsA@mail.gmail.com>
References: <1406851057-1593-1-git-send-email-pshelar@nicira.com>
	<20140802.151630.929949940730781279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:35538 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750965AbaHCTUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2014 15:20:33 -0400
Received: by mail-ig0-f174.google.com with SMTP id c1so4186817igq.1
        for <netdev@vger.kernel.org>; Sun, 03 Aug 2014 12:20:32 -0700 (PDT)
In-Reply-To: <20140802.151630.929949940730781279.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 2, 2014 at 3:16 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Thu, 31 Jul 2014 16:57:37 -0700
>
>> Following patch adds mask cache so that we do not need to iterate over
>> all entries in mask list on every packet. We have seen good performance
>> improvement with this patch.
>
> How much have you thought about the DoS'ability of openvswitch's
> datastructures?
>
This cache is populated by flow lookup in fast path. The mask cache is
fixed in size. Userspace or number of packets can not change its size.
Memory is statically allocated, no garbage collection. So DoS attack
can not exploit this cache to increase ovs memory footprint.

> What are the upper bounds for performance of packet switching?
>
Cache is keyed on packet RSS. Worst case scenario this cache adds one
extra flow-table lookup for the flow if RSS hash matches but packet
belong to different flow (hash collision).
This is designed to be lightweight, stateless cache (does not take any
reference on other data structures) to have least impact on
DoS'ability of Open vSwitch.

> To be quite honest, a lot of the openvswitch data structures
> adjustments that hit my inbox seem to me to only address specific
> situations that specific user configurations have run into.
>

Overall OVS DoS defense has improved since introduction of mega-flow.
Recently introduced OVS feature allows userspace to set multiple
sockets for upcall processing for given vport. This adds fairness by
separating upcall from different flows to a socket. Userspace process
upcall from these sockets in round-robin fashion. This helps to avoid
one port monopolize upcall communication path.

I agree there is scope for improving DoS defense and we will keep
working on this issue.

> It took us two decades, but we ripped out the ipv4 routing cache
> because external entities could provoke unreasonable worst case
> behavior in routing lookups.
>
> With openvswitch you guys have a unique opportunity to try and design
> all of your features such that they absolutely can use scalable
> datastructures from the beginning that provide reasonable performance
> in the common case and precise upper bounds for any possible sequence
> of incoming packets.
>
> New features tend to blind the developer to the eventual long term
> ramifications on performance.  Would you add a new feature if you
> could know ahead of time that you'll never be able to design a
> datastructure which supports that feature and is not DoS'able by a
> remote entity?
>
