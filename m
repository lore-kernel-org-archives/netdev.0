From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: TCP and batching WAS(Re: [PATCH 00/10] Implement batching skb
 API
Date: Mon, 23 Jul 2007 10:44:08 +0100
Message-ID: <20070723104408.169b0724@oldman.hamilton.local>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
	<20070720081848.7cc652fb@oldman>
	<1185025579.5192.68.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, davem@davemloft.net,
	rdreier@cisco.com, johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	mcarlson@broadcom.com, xma@us.ibm.com, rick.jones2@hp.com,
	jeff@garzik.org, general@lists.openfabrics.org, mchan@broadcom.com,
	tgraf@suug.ch, netdev@vger.kernel.org, jagana@us.ibm.com,
	kaber@trash.net, sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54152 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759933AbXGWJqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 05:46:24 -0400
In-Reply-To: <1185025579.5192.68.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 21 Jul 2007 09:46:19 -0400
jamal <hadi@cyberus.ca> wrote:

> On Fri, 2007-20-07 at 08:18 +0100, Stephen Hemminger wrote:
> 
> > You may see worse performance with batching in the real world when
> > running over WAN's.  Like TSO, batching will generate back to back packet
> > trains that are subject to multi-packet synchronized loss. 
> 
> Has someone done any study on TSO effect? 
Not that I have seen, TCP research tends to turn of NAPI and TSO because it
causes other effects which are too confusing for measurement. The discussion
of TSO usually shows up in discussions of pacing. I have seen argument both
pro and con for pacing. The most convincing arguments are that pacing doesn't
help in the general case (and therefore TSO would be ok). 

> Doesnt ECN with a RED router
> help on something like this?
Yes, but RED is not deployed on backbone, and ECN only slightly.
Most common is over sized FIFO queues.

> I find it suprising that a single flow doing TSO would overwhelm a
> routers buffer. I actually think the value of batching as far as TCP is
> concerned is propotional to the number of flows. i.e the more flows you
> have the more batching you will end up doing. And if TCPs fairness is
> the legend talk it has been made to be, then i dont see this as
> problematic.

It is not that TSO would overwhelm the router by itself, just that any
congested link will have periods when there is only a small number of
available slots left. When this happens a TSO burst will get truncated.

The argument against pacing, and for TSO; is that the busy sender with
large congestion window is the one most likely to have send large bursts.
For fairness, the system works better if the busy sender gets penalized more,
and dropping the latter part of the burst does that.  With pacing, the sender
may be able to saturate the router more and not detect that it is monopolizing
the bandwidth.


> BTW, something i noticed regards to GSO when testing batching:
> For TCP packets slightly above MDU (upto 2K), GSO gives worse
> performance than non-GSO. Actually has nothing to do with batching,
> rather it works the same way with or without batching changes.
> 
> Another oddity:
> Looking at the flow rate from a purely packets/second (I know thats a
> router centric view, but i found it strange nevertheless) - you see that
> as packet size goes up, the pps also goes up. I tried mucking around
> with nagle etc, but saw no observable changes. Any insight?
> My expectation was that the pps would stay at least the same or get
> better with smaller packets (assuming theres less data to push around).
> 
> cheers,
> jamal
> 
> 
> 
