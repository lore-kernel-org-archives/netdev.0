From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 19 Jul 2006 16:50:14 +0200
Message-ID: <44BE46A6.8000207@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2>	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>	 <1151158431.6716.95.camel@jzny2>	 <1153188409.13145.5.camel@ras.pc.brisbane.lube>	 <44BD56A4.9090002@andyfurniss.entadsl.com> <1153270932.4242.60.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lists@andyfurniss.entadsl.com, hadi@cyberus.ca,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:15863 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964844AbWGSOuR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 10:50:17 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1153270932.4242.60.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> On Tue, 2006-07-18 at 22:46 +0100, Andy Furniss wrote: 
> 
>>FWIW I think it may be possible to do it Patricks' way, as if I read it 
>>properly he will end up with the ATM cell train length which gets 
>>shifted by cell_log and looked up as before. The ATM length will be in 
>>steps of 53 so with cell_log 3 or 4 I think there will be no collisions 
>>- so special rate tables for ATM can still be made perfect.

Please excuse my silence, I was travelling and am still catching up
with my mails.

> Patrick is proposing that the packet lengths be sent to 
> the kernel in a similar way to how transmission times (ie
> RTAB) is sent now.  I agree that is how things should be 
> done - but it doesn't have much to do with the ATM patch, 
> other than he has allowed for ATM in the way he does the 
> calculation in the kernel [1].
> 
> In particular:
> 
> - As it stands, it doesn't help the qdiscs that use 
>   RTAB.  So unless he proposes to remove RTAB entirely 
>   the ATM patch as it will still have to go in.

Why? The length calculated by my STABs (or something similar)
is used by _all_ qdiscs. Not only for transmission time calculation,
but also for statistics and estimators. If the length calculation
doesn't fit for ATM, that can be fixed.

> - A bit of effort was put into making this current
>   ATM patch both backwards and forwards compatible.
>   Patricks patch would work with newer kernels,
>   obviously.  Older kernels, and in particular the
>   kernel that Debian is Etch is likely to distribute
>   would miss out.

True, but it provides more consistency, and making current
kernels behave better is more important than old kernels.

> If Patrick did intend remove RTAB entirely then he
> needs to add a fair bit more into his patch.  Since 
> RTAB is just STAB scaled, its certainly possible.
> The kernel will have to do a shift and a division
> for each packet, which I assume is permissible.

You seem to have misunderstood my patch. It doesn't need to
touch RTABs, it just calculates the packet length as seen
on the wire (whereever it is) and uses that thoughout the
entire qdisc layer.

>>As you say, I think mpu should be added aswell - so eth/other can benefit.
> 
> 
> Not really.  The MPU is reflected in the STAB table,
> just as it is for RTAB.
> 
> One other point - the optimisation Patrick proposes
> for STAB (over RTAB) was to make the number of entries
> variable.  This seems like a good idea.  However there 
> is no such thing as a free lunch, and if you did 
> indeed reduce the number of entries to 16 for Ethernet 
> (as I think Patrick suggested), then each entry would
> cover 1500/16 = 93 different packet lengths.  Ie,
> entry 0 would cover packet lengths 0..93, entry 1
> 94..186, and so on.  A single entry can't be right
> for all those packet lengths, so again we are back
> to a average 30% error for typical VOIP length
> packets.

My patch doesn't uses fixed sized cells, so it can deal
with anything, worst case is you use one cell per packet
size. Optimizing size and lookup speed for ethernet makes
a lot more sense than optimizing for ADSL.
