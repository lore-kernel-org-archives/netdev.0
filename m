From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: reflect the fwmark for replies with no socket
Date: Mon, 17 Mar 2014 14:24:57 +0900
Message-ID: <CAKD1Yr2rSwpzSdvjsO-=QUkivAkw2gnj+_mvydtR8OfAnsTicg@mail.gmail.com>
References: <1394536541-25702-1-git-send-email-lorenzo@google.com> <20140312.161737.1125059989320204564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:46615 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbaCQFZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 01:25:17 -0400
Received: by mail-ig0-f171.google.com with SMTP id hl1so4547851igb.4
        for <netdev@vger.kernel.org>; Sun, 16 Mar 2014 22:25:17 -0700 (PDT)
In-Reply-To: <20140312.161737.1125059989320204564.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 13, 2014 at 5:17 AM, David Miller <davem@davemloft.net> wrote:
>> Kernel-originated IP packets that have no user socket associated
>> with them (e.g., ICMP errors and echo replies, TCP RSTs, etc.)
>> are emitted with a mark of zero. Instead, make them have the
>> same mark as the packet they are replying to.
>>
>> This is consistent with TOS, which is also reflected from the
>> incoming packet, and it allows the administrator to use
>> mark-based routing, firewalling, etc. for these replies by
>> marking the original packets inbound.
>>
>> Also fix the IPv6 code to reflect the tclass in replies like the
>> IPv4 code does.
>>
>> Change-Id: Ifd8dd75016e60dc982e7860f720d45c27dcaf04c
>> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
>
> I don't think it's safe to change this behavior after all of this
> time.

Fair enough. My bad.

> And incoming marks absolutely do not have any automatic relation
> to what an administartor might want to use for output packets.

In general, that's true. Still - currently the mark on these packets
is 0, period, and the administrator can't do anything about that at
all. The idea was that some control is better than zero control, and
since these packets are always in reply to other packets, then marking
responses based on the packets that provoked them made sense, since
the input marking can be as flexible as the administrator desires.

If this was optional behaviour (e.g., controlled by
/proc/sys/net/ipv{4,6}/reflect_fwmark), would that be acceptable?
That way, even if it doesn't work for everyone, at least some
environments will be able to use it. I'm happy to send in a new patch
that does that.

If not, do you see another way to do this? If you use mark-based
routing, there doesn't currently seem to be a good way of sending
these packets where they need to go. iptables doesn't really work,
because it can only touch the packet after a lot of it has been
decided. You can override some of those decisions via NAT / MSS
rewrite / ..., but it gets messy, and it seems better to send the
right packet off the bat rather than send the wrong one and then
rewrite it without updating any of the socket structures.

Regards,
Lorenzo
