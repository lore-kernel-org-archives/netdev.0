From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Mon, 26 Jun 2006 13:10:39 +0200
Message-ID: <449FC0AF.1050904@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2>	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>	 <449C06E3.3090406@trash.net> <1151282720.4210.46.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:13722 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964994AbWFZLLm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 07:11:42 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1151282720.4210.46.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> On Fri, 2006-06-23 at 17:21 +0200, Patrick McHardy wrote: 
> 
>>Not really. The randomization doesn't happen by default, but it doesn't
>>influence this anyway. SFQ allows flows to send up to "quantum" bytes
>>at a time before moving on to the next one. A flow that sends 75 * 20
>>byte will in the eyes of SFQ use 1500bytes, on the (ethernet) wire it
>>needs 4800bytes. A flow that sents 1500byte packets will only need
>>1504 bytes on the wire, but will be treated equally. So it does make
>>a different for SFQ.
> 
> 
> I hadn't even thought to check.  My bad.  The S in SFQ stands 
> for stochastic, so something that does without randomisation 
> the algorithm implemented couldn't really be called SFQ - 
> particularly as it weakens the algorithm considerably.  I 
> hope that most users do specify a perturb.

Its not as great as you think. Changing hash-functions on the
fly causes reordering for non-idle flows when bucket-lengths
aren't distributed even. I never use it.

> Your 20 byte example is hardly realistic.  skb->len includes 
> the 14 byte ethernet header, so there is a total of 6 data 
> bytes in a 20 byte packet.  The IP header alone is 20 bytes.  
> TCP as implemented on Linux adds another 32 bytes (20 + the 
> rtt option).  In other words I agree with Jamal's comments 
> elsewhere - optimising for MPU sized packets doesn't seem 
> like a win.

The point is that SFQ does care about packet sizes, and this is
true for both MPU-sized and other packets.

>>Its not about cleanup, its about providing the same capabilities
>>to all qdiscs instead of just a few selected ones and generalizing
>>it so it is also usable for non-ATM overhead calculations.
> 
> 
> Perhaps I chose my words poorly.
> 
> My intent was to contrast the size and goals of the two
> proposed patches.  The ATM patch is a 37 line patch.  It 
> includes some minor cleanups.  From the pseudo code you 
> have posted what you are proposing is a more ambitious and 
> much larger patch that moves a chunk of user space code 
> into the kernel.  I am a complete newbie when it comes to 
> getting code into the kernel, but that strikes me as 
> contentious.  I would rather not have the ATM patch 
> depend on it.
> 
> By the by, here are a couple of observations:
> 
> 1.  The entries in the current rtab are already very closely 
>     related to packet lengths.  They are actually the packet
>     length multiplied by a constant that converts the units
>     from "bytes" to "jiffies".  The constant is the same for
>     all entries in the table.
> 
> 2.  As such, the current rtab could already be used by SFQ
>     and any other qdisc that needs to know the packet length.
>     That SFQ doesn't do this is probably because it doesn't
>     effect its performance overly.

The rtab includes the transmission time, which is related to,
but still is something different than the length. You can't
calculate the transmission time without a rate, which is
not needed otherwise for SFQ for example. The way rtabs
are used also needs more space, my current size tables
only use as much space as needed, which is 16 entries for
ethernet instead of 256.

> 3.  Be that as it may, the current RTAB isn't in the most
>     convenient form for SFQ, and I am guessing it is in a 
>     very inconvenient form for HFSC.  Adding a new version 
>     that is identical except that it contains the raw packet 
>     length would be a simple change.  In that format it
>     could be used by all qdiscs.  The users of the existing
>     rtab would have to do the multiplication that converts
>     the packet length to jiffies in the kernel.  This means
>     the conceptually at least, should the gootput change
>     you need to change this one constant, not the entire
>     table.

Well, I don't care much whether we use rtabs or something new,
but rtabs are meant for something different and as such are not
optimally suited for this.

> 4.  Much as you seem to dislike having the rate / packet length
>     calculations in user space, having them there makes it easy 
>     to add new technologies such as ATM.  You just have to 
>     change a user space tool - not the kernel.

I don't dislike it for beeing in userspace, I dislike it for
a) beeing used for this since it only covers TBF-based qdiscs
b) beeing used for an ATM "special case" which is not special
   at all.

I should also note that my tables don't come out of the random
generator but are provided by userspace as well. Unless the
mechanism is unable to express the needs of a particular link
layer type all you have to do is to provide a different set
of values without touching any code at all.

> 5.  We still did have to modify the kernel for ATM.  That was
>     because of its rather unusual characteristics.  However,
>     it you look at the size of modifications made to the kernel
>     verses the size made to the user space tool, (37 lines
>     versus 303 lines,) the bulk of the work was does in user
>     space.

I'm sorry, but arguing that a limited special case solution is
better because it needs slightly less code is just not reasonable.

