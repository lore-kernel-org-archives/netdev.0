From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 19 Jul 2006 15:42:43 +0100
Message-ID: <44BE44E3.9080100@andyfurniss.entadsl.com>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2>	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>	 <1151158431.6716.95.camel@jzny2>	 <1153188409.13145.5.camel@ras.pc.brisbane.lube>	 <44BD56A4.9090002@andyfurniss.entadsl.com> <1153270932.4242.60.camel@ras.pc.brisbane.lube>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:12779 "EHLO mail.ukfsn.org")
	by vger.kernel.org with ESMTP id S964838AbWGSOlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 10:41:47 -0400
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
> 
> 
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

Hmm - I was just looking at the kernel changes to htb. The only 
difference is the len - I am blindly assuming that it does/will return 
the link lengths properly for atm.

So for atm, qdisc_tx_len(skb) will always return lengths that are 
multiples of 53.

If nothing else were done we would suffer innacuarcy from the cell_log 
just like eth.

But no other kernel hack would be needed to do it perfectly - rather 
like we (who patch for atm already) just fill the tc generated rate 
table with what we like, that would be an option.

> 
> - A bit of effort was put into making this current
>   ATM patch both backwards and forwards compatible.
>   Patricks patch would work with newer kernels,
>   obviously.  Older kernels, and in particular the
>   kernel that Debian is Etch is likely to distribute
>   would miss out.
> 
> If Patrick did intend remove RTAB entirely then he
> needs to add a fair bit more into his patch.  Since 
> RTAB is just STAB scaled, its certainly possible.
> The kernel will have to do a shift and a division
> for each packet, which I assume is permissible.

I guess that is for others to decide :-) I think Patrick has a point 
about sfq/htb drr, Like you I guess, I thought that alot of extra per 
packet calculations would have got an instant NO.

> 
>>As you say, I think mpu should be added aswell - so eth/other can benefit.
> 
> 
> Not really.  The MPU is reflected in the STAB table,
> just as it is for RTAB.

OK, I was thinking of what Jamal said about helping others, so 
everything TC should be capable of accepting mpu and overhead with these 
patches - or is more work needed?

It will be good to be able to say

tc ... police rate 500kbit mpu 60 overhead 24 ... for eth.
(Assuming eth mpu/overhead are really 46/38 - p in mpu is payload AIUI 
so 60 and 24 come from allowing for skb->len being IP+14)

or for ATM + pppoa something like

tc ... police rate 500kbit overhead 10 atm ...

In the case of eth someone already added mpu/overhead for HTB and it 
doesn't need any extra per packet calcs. I guess this way it would.

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

I agree less accuracy will not be nice. But as an option it could be the 
only way you can do 1/10Gig + jumbo frames.

Andy.
