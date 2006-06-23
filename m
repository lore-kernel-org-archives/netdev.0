From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Fri, 23 Jun 2006 17:21:07 +0200
Message-ID: <449C06E3.3090406@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2> <1151066247.4217.254.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:14248 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751460AbWFWPVK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 11:21:10 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1151066247.4217.254.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> On Thu, 2006-06-22 at 14:29 -0400, jamal wrote: 
> 

> On Tue, 2006-06-20 at 03:04 +0200, Patrick McHardy wrote: 
> 
>>What about qdiscs like SFQ (which uses the packet size in quantum
>>calculations)? I guess it would make sense to use the wire-length
>>there as well.
> 
> 
> Being pedantic, SQF automatically assigns traffic to classes 
> and gives each class an equal share of the available bandwidth.  
> As I am sure you are aware SQF's trick is that it randomly 
> changes its classification algorithm - every second in the Linux 
> implementation.  If there are errors in rate calculation this 
> randomisation will ensure they are distributed equally between 
> the classes as time goes on.  So no, accurate packets sizes are 
> not that important to SQF.
> 
> But they are important to many other qdiscs, and I am sure 
> that was your point.  SQF just happened to be a bad example.

Not really. The randomization doesn't happen by default, but it doesn't
influence this anyway. SFQ allows flows to send up to "quantum" bytes
at a time before moving on to the next one. A flow that sends 75 * 20
byte will in the eyes of SFQ use 1500bytes, on the (ethernet) wire it
needs 4800bytes. A flow that sents 1500byte packets will only need
1504 bytes on the wire, but will be treated equally. So it does make
a different for SFQ.

> On Tue, 2006-06-20 at 16:45 +0200, Patrick McHardy wrote: 
> 
>>Handling all qdiscs would mean adding a pointer to a mapping table
>>to struct net_device and using something like "skb_wire_len(skb, dev)"
>>instead of skb->len in the queueing layer. That of course doesn't
>>mean that we can't still provide pre-adjusted ratetables for qdiscs
>>that use them.
> 
> 
> Yes, that would work well, and is probably how it should of
> been done when the kernel stuff was originally written.  As 
> it happens Jesper's original solution was closer to this.  The 
> reason we choose not to go that way it is would change the 
> kernel-userspace API.   The current patch solves the problem 
> and works well as possible on all kernel versions - both 
> patched and unpatched.

Not a problem as long as the new stuff doesn't break anything existing.
My patch introduces a TCA_STAB (for size table), similar to the _RTAB
attributes. Old iproute with new kernel and new iproute with old kernel
both work fine.

> Now that I think about to change things the way you suggest
> here does seem simple enough.  But it probably belongs in a 
> different patch.  We wrote this patch to fix a specific problem 
> with ATM links, and it should succeed or fail on the merits 
> of doing that.  Cleaning up the kernel code to do what you 
> suggest is a different issue.  Let whether it to should be 
> done, or not, be based on its own merits.

Its not about cleanup, its about providing the same capabilities
to all qdiscs instead of just a few selected ones and generalizing
it so it is also usable for non-ATM overhead calculations.
