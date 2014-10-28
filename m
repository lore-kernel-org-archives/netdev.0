From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 2/2] udp: Reset flow table for flows over
 unconnected sockets
Date: Mon, 27 Oct 2014 18:09:25 -0700
Message-ID: <CA+mtBx_eQKOkM-0PEXG2WEMosXDtqHgwT3j7NnQpP62KdZeJKQ@mail.gmail.com>
References: <1414432875-23795-1-git-send-email-therbert@google.com>
	<1414432875-23795-2-git-send-email-therbert@google.com>
	<1414435437.32624.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_V3WT1bbXY9F731GNdDdb3+ebHwj9hRyVEFynAPYhSXg@mail.gmail.com>
	<1414451970.2922.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:45251 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbaJ1BJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 21:09:26 -0400
Received: by mail-ig0-f175.google.com with SMTP id a13so1566847igq.14
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 18:09:25 -0700 (PDT)
In-Reply-To: <1414451970.2922.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2014 at 4:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-10-27 at 12:36 -0700, Tom Herbert wrote:
>
>> Please try this patch and provide real data to support your points.
>>
>
> Yep. This is not good, I confirm my fear.
>
> Google servers are shifting to serve both TCP & UDP traffic (QUIC
> protocol), with an increasing UDP load.
>
> Millions of packets per second per host, from millions of different
> sources...
>
This indicates nothing about the merits of this patch. Nevertheless,
in order to avoid further rat-holing and since this patch does change
a long standing behavior I'll will respin to make it enabled only by
sysctl.

Tom

> And your patch voids the RFS table, adds another cache miss in fast path
> for UDP rx path which is already too expensive.
>
>
>> If a TCP connection is hot it will continually refresh the table for
>> that connection, if connection becomes idle it only takes one received
>> packet to restore the CPU. The only time there could be a persistent
>> problem is if collision rate is high (which probably means table is
>> too small).
>
>
> RFS already has a low hit/miss rate, this patch does not help neither
> UDP or TCP.
>
> Ideally, RFS should be enabled on a protocol base, not an agnostic u32
> flow hash.
>
> Whatever strategy you implement, as long as different protocols share a
> common hash table, it wont be perfect for mixed workloads.
>
> Fundamental problem is that when an UDP packet comes, its not possible
> to know if its a 'flow' or 'not', unless we perform an expensive lookup,
> and then RPS/RFS cost becomes prohibitive.
>
> While for TCP, the current RFS cache miss is good enough, because about
> all packets are for connected flows. We eventually have bad steering for
> <not yet established> flows where the stack performs poorly anyway.
>
>
>
