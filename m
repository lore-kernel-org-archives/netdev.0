From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0xd2b/0x191f()
Date: Sun, 18 May 2008 00:25:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805172345440.17738@wrl-59.cs.helsinki.fi>
References: <651806990805170819j5fdd42eeq805bfc31776ac897@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: int 986 <int986@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52491 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715AbYEQVZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 17:25:57 -0400
In-Reply-To: <651806990805170819j5fdd42eeq805bfc31776ac897@mail.gmail.com>
Content-ID: <Pine.LNX.4.64.0805172345442.17738@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 17 May 2008, int 986 wrote:

> i am hitting this ops regularly on my web servers, when bandwidth
> exceeds 250mbit/s
> both with intel and broadcom nic. I've tried with tso and without it -
> there is no diference.

Not related to hardware or config, it's extremely likely that its a plain 
bug is in core TCP. 

> gcc version: 4.2.3 (Debian 4.2.3-1)
> kernel: 2.6.25.3
> 
> oops with broadcom nic
> 
> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:2539 tcp_ack+0xd2b/0x191f()

We're already tracking down these warnings with a debug patch that adds 
considerable amount of processing per ACK to validate "cached" state 
variables nearly everywhere in TCP code, sadly enough the first output we 
got had its head cut due to insufficient buffering space (and for some 
reason it has been harder to reproduce for the second time). ...I doubt 
that you would want to run such processing expensive debug patch on your 
servers because you expect such high speeds. I'm currently still out of 
ideas really what could cause it though I've read the relevant parts of 
TCP code tens of times through (only "bug" I've found so far was a 
false-positive :-/). But thanks for reproducing it w/o TSO, it may exclude 
some possibilities in future when I have to do the hard work and figure 
out the occuring events (backwards) from the debug patch's response I
hope to get soon.

Anyway, this warning is pretty harmless, nothing should get corrupted or 
so. It's only a minor miscount of fackets_out, which is mostly used when 
determinating the time when to enter fast recovery (while most people 
wouldn't notice even if TCP would do no fast recoveries at all but relay 
on RTO alone), and also reordering metric calculations might be slightly 
off if they ever occur during that period of miscount (which is not too 
likely). Neither of those is a dramatic event. And, once you see that 
WARNING printed out, TCP has just fixed the miscount for you :-). So 
mainly it just tells me that there's still some miscount bug to solve.
I could miss some performance related aspects here because the actual
bug is still unknown to me but I doubt it has any significance as rare
as it is (usually the event is resolved in less than couple of 
round-trips, ie., when TCP gets back to "forward transmission mode" 
without any holes that need to be reported which normally takes about a 
round-trip, so the timescale is typically very very short).

This has been very hard to track down, I've no idea how to reproduce it 
and people often get it just once, if ever, or see it couple of times per 
week but run high performing servers that cannot do such heavy debugging I 
need for tracking it down.

The only other helpful thing I could think of ATM (besides running the 
debug patch) would be to share some details with us if you have something 
particularly "special" things in your network setup, e.g., something that 
affects MSS/MTU, reorders packets, causes losses, etc.

...Thanks for the report anyway.


-- 
 i.
