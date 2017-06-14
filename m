From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Receiving raw packets (incl. VLAN tags) on raw sockets
Date: Wed, 14 Jun 2017 09:41:55 -0500
Message-ID: <877f0eaax8.fsf@xmission.com>
References: <e06dbb47-2d1c-03ca-4cd7-cc958b6a939e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, aeppert@gmail.com
To: Jan =?utf-8?Q?Grash=C3=B6fer?= <jan.grashoefer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46302 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752427AbdFNOsv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 10:48:51 -0400
In-Reply-To: <e06dbb47-2d1c-03ca-4cd7-cc958b6a939e@gmail.com> ("Jan
        \=\?utf-8\?Q\?Grash\=C3\=B6fer\=22's\?\= message of "Wed, 14 Jun 2017 14:47:56
 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Grashöfer <jan.grashoefer@gmail.com> writes:

> Hello,
>
> trying to ingest packets to a network monitoring tool using AF_Packet, I
> noticed that VLAN tags are stripped off even if VLAN offloading is
> disabled. As described in [1] the tags are stripped that early in the
> receive path that raw sockets do not receive the packets as seen on the
> wire. However, the man pages [2] state:
>
>> SOCK_RAW packets are passed to and from the device driver without any
>> changes in the packet data.
>
> So at least the docs are wrong here. While the VLAN information is
> present in the tpacket_hdr, the packets themselves are manipulated by
> the kernel. In my case, for example, I need to pass on each packet (in
> form of a packet) and thus would have to reinsert the tag manually,
> which is definitely undesirable.

My sympathies but that is pretty much what you are going to need to do.

> As I am dealing with a monitoring application, the following patch that
> disables untagging VLANs in promisc mode fixes the issue for me:
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 54f8c16..ec5b1c5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4104,8 +4104,9 @@ static int __netif_receive_skb_core(struct sk_buff
> *skb, bool pfmemalloc)
>
>         __this_cpu_inc(softnet_data.processed);
>
> -       if (skb->protocol == cpu_to_be16(ETH_P_8021Q) ||
> -           skb->protocol == cpu_to_be16(ETH_P_8021AD)) {
> +       if ((skb->protocol == cpu_to_be16(ETH_P_8021Q) ||
> +           skb->protocol == cpu_to_be16(ETH_P_8021AD)) &&
> +           skb->dev->promiscuity < 1) {
>                 skb = skb_vlan_untag(skb);
>                 if (unlikely(!skb))
>                         goto out;

That does not work.  That is is just the software fallback for when
the device driver does not have a special case the processing
vlan tagged packets.

There was a major inconsistency that for a long time the hardware
network drivers were stripping tags and the software ones were not.

The code you are playing with is the fix for the rare slow path
that does not happen to strip the tags.  Disabling the rare slow path
might temporarily solve your symptoms but it will be much more painful
when you are entrenched in your ways and discover that high performance
hardware behaves differently than your software device.

> --
>
> I tested the patch with tcpdump and suricata. As they are designed to
> handle VLAN tags anyway, both work as expected. Still there are two
> caveats regarding this patch: First, there might be software out there
> that does not work as expected anymore. Second, the semantics of raw
> sockets are even more cluttered than before. I could imagine the
> following solutions:
>
> 1) Disable VLAN untagging done by the kernel or move it up the receive
> path - probably least practicable.
>
> 2) Parse VLAN info into the tpacket_hdr but keep the packet as is (at
> least in promisc mode) - still, seems clumsy and error-prone to me.
>
> 3) Introduce a new socket option to disable VLAN untagging for raw
> sockets - maybe overkill.

Thinking in terms of disabling vlan untagging is not going to get you a
solution.

Eric
