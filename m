From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 problems on Intel Mac Mini
Date: Tue, 30 Jan 2007 11:15:20 -0800
Message-ID: <20070130111520.47e07a79@freekitty>
References: <DJgDe2E/Cvnb.CrmE6+LDxkzqNQTYvzH+WQ@sphinx.mythic-beasts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
To: Chris Lightfoot <chris@ex-parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43607 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbXA3TSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 14:18:00 -0500
In-Reply-To: <DJgDe2E/Cvnb.CrmE6+LDxkzqNQTYvzH+WQ@sphinx.mythic-beasts.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a couple problems here:

1) the transmitter is getting hung.
2) the recovery logic doesn't work. If I can reproduce hang,
   then maybe the recovery code could be fixable.

Let's address the transmitter hang first.
The transmitter has multiple stages so it could be either:
a) hardware flow control problems
   look at ethtool -S eth0 statistics, are there flow control packets
   showing up?
b) GMAC or ram buffer issues
   looking at 'ethtool -d eth0' output can help, but it is a needle in
   haystack finding these setup errors.
 
   The sky2 driver copies most of the stuff from vendor version of sk98lin,
   but if sk98lin works and sky2 doesn't then comparing register settings
   can give hints.

c) DMA problems
   For some problems, I have had luck adding a /proc interface and dumping
   the transmit ring after a hang.  Looking at the last control block that
   hung can help.  This found the case where IPV6 TSO was leaking through.

d) checksum problems
   Turning off tx scatter/gather forces non fragmented skb's. This hurts
   performance, but can tell if the problem is with fragment code.
   Turning off tx checksum turns off scatter/gather, checksumming and
   TSO.

e) possible alignment and flow control interaction
   Because the receive DMA engine has hardware bugs and requires alignment
   or it doesn't work with flow control. I still wonder if there are alignment
   bugs on Tx with flow control.

f) other driver bug

To save time, I'll go get a new Mac Mini and try and clone this setup.
Could you send me a full kernel config (and other setup information
like filesystem type, distro etc).


> -- I assume this is just the same problem exhibiting on a
> kernel with soft lockups detection enabled?
> 
> Hopefully I should be able to actually log into one of
> these machines over an alternate connection next time the
> problem recurs, at which point I should be able to get
> ethtool -d output. Anything else I should do at that
> point?
> 
> Any suggestions for what to do next to chase this problem
> down? I haven't yet tried the sk98lin driver on this
> hardware; is that still worth doing? Are there any useful
> tests we should try? Unfortunately, though these crashes
> happen pretty frequently (several times per day
> typically), I don't have a test case to reproduce one;
> however, if it'd be useful, I can probably get a pcap
> trace of the period immediately before the interface falls
> over using port mirroring on the switch to which the
> machines are connected. Is that likely to be informative?
> 

The vendor driver does some slightly different setup, but it also
does a hardware reset when inactive (every 10ms).


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
