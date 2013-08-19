From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Sun, 18 Aug 2013 17:00:25 -0700
Message-ID: <1376870425.4226.25.camel@edumazet-glaptop>
References: <521061B4.1030508@fatooh.org>
	 <1376839467.21329.36.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:53655 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755377Ab3HSAA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 20:00:27 -0400
In-Reply-To: <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-18 at 23:23 +0200, Jozsef Kadlecsik wrote:

> It's a PMTU related problem, so I'd suggest to check first the next ones:
> 
> Aren't the ICMP error messages (i.e. fragmentation-needed) filtered out?
> If not, does adding an explicit TCPMSS rule to the mangle table help?

Thats totally irrelevant. tcp conntrack should not care of ICMP messages
anyway.

> Isn't there SACK options involved? Maybe there's a "smart" sequence 
> number "anonymizer" device in the path which forgets about the SEQ numbers 
> in the SACK options and thus such packets are marked as INVALID.
> 

As I understood the report, they were no SACK at all, but plain ACK
messages, and conntrack believes these ACK are outside the window
because it remembers the @end sequence of the probe, and the @maxwin of
receiver.

Lets say the probe is 2000 bytes, seq 1:2001

conntrack records end = 2001

Of course this packet is lost.

The retransmit sends a 1000 bytes packet, seq 1:1001

conntrack pass the packet.

Receiver acks it using ack 1001

conntrack drops this ack because of some confusion about the prior 2001
end, and the window (might be as small as 1000)

Code like this seems very suspect to me :

before(sack, receiver->td_end + 1)

It basically says that conntrack doesn't deal with reorders on the
network.

> So tcpdumps captured at both sides could really help to tell what goes wrong.

We probably can reproduce this bug using packetdrill.
