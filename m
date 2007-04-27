From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] export SAD info
Date: Fri, 27 Apr 2007 10:21:45 -0400
Message-ID: <1177683705.4059.29.camel@localhost>
References: <1177516490.9923.7.camel@localhost>
	 <20070426.001850.55508944.davem@davemloft.net>
	 <1177593010.4077.18.camel@localhost>
	 <20070426.141847.10298516.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:15906 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911AbXD0OVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 10:21:49 -0400
Received: by wr-out-0506.google.com with SMTP id 76so980860wra
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 07:21:47 -0700 (PDT)
In-Reply-To: <20070426.141847.10298516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-26-04 at 14:18 -0700, David Miller wrote:

> I wouldn't mind if it actually helped anything.
> 
> The SMP cache line transactions are more expensive than the
> execution of the code blocks they are protecting.  rwlock's
> rarely help, and when they do (the execution path is more
> expensive than the SMP atomic operations) then you're holding
> the lock too long :-)
> 

Ok ;->
So if i was to make any change, it would be for consistency
with SPD. If this is sufficiently compelling i will send a patch.

> I would prefer a dynamic algorithm that reacts to system memory
> pressure and yet-another-knob that people will get wrong and
> there is no sane default for.
> 

This would certainly be a better approach if doable.

> I plan to do away with all the GC threshold madness in the
> routing cache, for example, and just let the MM layer call
> back into us when there is memory pressure to trigger GC.
> 
> See set_shrinker() and friends.  The MM calls into these
> handlers in response to memory pressure.  There is no
> reason the networking can't hook into this and do things
> properly instead of the ad-hoc manner we currently use.

Scanning the kernel ... 
I wasnt aware of this, neat; not many areas in the kernel seem to use
it. I find this stuff interesting, so i may get too verbose ;->

One approach i tried was to write an oom_handler - but it seemed to
get invoked a little too late, i.e when shit has already hit the fan.
If only i could get notified just before swap kicks in or just when some
preconfigured (by me) memmory threshold is hit.... This may do it? I
will experiment. Actually for it to work well, I will need to know when
the memory threshold is crossed as it goes down and when it is going up
as more memory gets freed.

I can see the shrinker working well with dynamically createable 
entries (route cache, arp cache, contrack etc); shrinking a SAD, SPD,
FIB etc that was created by some user space app without user space
consent or at least notification may be unacceptable (imagine Quagga/BGP
adding FIB entries and the kernel deciding its gonna run out of mem and
starting to delete entries; worse deleting SAD entries may be a security
risk etc etc). My problem is more related to these sorts of user
controlled tables.  
One approach that may work to address the above is to send a signal to
user space when the low mem threshold is approaching.. User space then
uses that info to slow down its abuse of memory. I think that signaling
maybe achievable by a genlmsg being sent to a multicast group which a
user space app will have to subscribe to.
Another approach is to use the shrinker callback to set a lowmem
condition to start rejecting any new table additions. A timer to 
retry would take it back; a callback from the VM to say "you can go
ahead and alloc more now" would be better of course - i couldnt see this
anywhere in the VM code, but it is one of those subsystem i dont pay
attention to, it may be there.

Thoughts? ;->

cheers,
jamal


