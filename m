From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Fri, 24 Sep 2004 16:44:38 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096010078.4414.91.camel@andromache>
References: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
	 <20040921203118.734a0a7e.davem@davemloft.net>
	 <20040922111447.GP3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040922111447.GP3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-09-22 at 20:44, Harald Welte wrote:

> And I still want to address the "all complete entries flushed due to
> lots of bogus incomplete entires" issue somehow.  As stated before, I
> have seen this on happen on live systems.  
> 
> Do you agree that this is an existing problem?
> 
> I think just having a certain 'reserve' for complete entries (or a let's
> say 80% limit for incomplete ones) should address this issue.

Or two other ideas:

1)
Recognising that there are two classes of incomplete entries, those that
are recently-issued and those that are very unlikely to complete (as
you've allowed enough time for a handful of serialisation delays,
latencies and answering host turn-around (say 0.7s).

You can pretty safely aggressively flush the "unlikely to complete"
class of incomplete entries. The older the more aggressively.

Completed entries should be flushed before the first of the "recently
issued" incomplete entries, to stop repeated ARPing.

This gets less useful as your address allocation grows and scanning
rates rise, but is much better than the current algorithm or a
straight-forward least-recently-used algorithm.

2)
Record the source interface of the traffic which is causing this ARP.
When flushing the cache, apply a penalty to entries where that entry's
source interfaces has a large numbers of incomplete ARPs.

The effect of this is that scanning from an Internet-facing interface
won't succeed in pushing large numbers of entries generated from
local-to-local (eg, local file, print, intranet) traffic out of the
table.

A combination of (1) and (2) should be pretty solid. If it falls apart
under extreme scanning then hard-coding the ARP info for
externally-facing servers (such as web servers) is needed.  Currently
hard-coding all machines would be needed in the extreme scanning case.

Hope this helps,
Glen

-- 
Glen Turner          Tel: (08) 8303 3936 or +61 8 8303 3936
Australia's Academic & Research Network   www.aarnet.edu.au
