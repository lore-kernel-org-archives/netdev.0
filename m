From: Per Hedeland <per@hedeland.org>
Subject: Re: [Bonding-devel] [PATCH] [bonding 2.4] Add balance-xor-ip bonding mode
Date: Sun, 11 Jan 2004 22:45:16 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401112145.i0BLjGWJ095607@pluto.hedeland.org>
References: <200401111650.24305.amir.noam@intel.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: amir.noam@intel.com
In-Reply-To: <200401111650.24305.amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Amir Noam <amir.noam@intel.com> wrote:
>
>A possible way to have "limited" duplication would be to have two 
>seperate xmit functions, that call an inline function for the shared 
>code. This might be good enough, performance-wise, while avoiding 
>some code duplication.

Yes, I actually thought of that (after the previous post:-) - it would
at least avoid some *source* code duplication. And the reasonable thing
to break out into such a function would be the logic to find the slave
to xmit on given slave_no (perhaps also the actual xmit), I guess.

However when looking at this I realized that the xor mode has a pretty
serious bug/flaw in the fault-tolerance department: The modulus is done
with the total number of slaves, and slaves that are down are only
skipped in that find-slave logic. I.e. if you (e.g.) have a bond with 3
links where link 1 is down, link 2 will get 2/3 of the traffic and link
3 get 1/3 - not good I think.

Since fixing this would likely change the interface to the above
function, I guess it would be nice to do it at the same time as (or
before) the balance-xor-ip addition. Assuming I'm not the only one that
thinks it needs fixing, that is.:-)

The superficially obvious fix is to do the modulus with only the number
of slaves that are up, but I'm not sure about the best actual
implementation. That number isn't currently maintained, and traversing
the list of slaves just to find it for every packet doesn't make sense
of course. It seems straightforward to add another field to the bonding
struct for it, and maintain that in the monitoring functions, though.

But in addition to that, the actual slave selection logic would have to
always check the link state of each slave until it has found the
slave_no'th one that is up (though one could optimize for the case of
all slaves being up) - whereas currently it only starts checking at the
slave_no'th one, and if all slaves are up there is only one check. I'm
not sure if this is acceptable?

The only alternative I see is to also maintain a list of the slaves that
are up, but then we're perhaps getting too much complexity for these
"simple" modes. Any comments, other alternatives?

>But, like I've said, I'm not sure wout the best solution is. I'd like 
>to hear what Jay (and others) thinks about it.

Well, Jay said he would be out of email access for three weeks -
starting tomorrow and promising he would look over updated patches
first, but maybe he didn't have the time - or, given that you
objected:-), he (correctly) thought that a second update wouldn't arrive
in time.

I'm in no particular hurry to get this into the "official" source
though, since I'll be using an older kernel that I've already applied
the (original) patch to for a while anyway - it's just that it gets old
pretty quickly to keep reworking the patches against moving (and not
very easily accessible) targets...

--Per Hedeland
per@hedeland.org
