From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] udp: Reset flow table for flows over
 unconnected sockets
Date: Mon, 27 Oct 2014 16:19:30 -0700
Message-ID: <1414451970.2922.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414432875-23795-1-git-send-email-therbert@google.com>
	 <1414432875-23795-2-git-send-email-therbert@google.com>
	 <1414435437.32624.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_V3WT1bbXY9F731GNdDdb3+ebHwj9hRyVEFynAPYhSXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:45893 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbaJ0XTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 19:19:31 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so2221996pdj.28
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 16:19:31 -0700 (PDT)
In-Reply-To: <CA+mtBx_V3WT1bbXY9F731GNdDdb3+ebHwj9hRyVEFynAPYhSXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-27 at 12:36 -0700, Tom Herbert wrote:

> Please try this patch and provide real data to support your points.
> 

Yep. This is not good, I confirm my fear.

Google servers are shifting to serve both TCP & UDP traffic (QUIC
protocol), with an increasing UDP load.

Millions of packets per second per host, from millions of different
sources...

And your patch voids the RFS table, adds another cache miss in fast path
for UDP rx path which is already too expensive.


> If a TCP connection is hot it will continually refresh the table for
> that connection, if connection becomes idle it only takes one received
> packet to restore the CPU. The only time there could be a persistent
> problem is if collision rate is high (which probably means table is
> too small).


RFS already has a low hit/miss rate, this patch does not help neither
UDP or TCP.

Ideally, RFS should be enabled on a protocol base, not an agnostic u32
flow hash.

Whatever strategy you implement, as long as different protocols share a
common hash table, it wont be perfect for mixed workloads.

Fundamental problem is that when an UDP packet comes, its not possible
to know if its a 'flow' or 'not', unless we perform an expensive lookup,
and then RPS/RFS cost becomes prohibitive.

While for TCP, the current RFS cache miss is good enough, because about
all packets are for connected flows. We eventually have bad steering for
<not yet established> flows where the stack performs poorly anyway.
