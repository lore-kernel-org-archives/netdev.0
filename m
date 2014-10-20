From: James Carlson <carlsonj@workingcode.com>
Subject: Re: Routing BUG with ppp over l2tp
Date: Mon, 20 Oct 2014 16:22:45 -0400
Message-ID: <54456F15.9070206@workingcode.com>
References: <Pine.LNX.4.44L0.1410201414500.2403-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1410201414500.2403-100000@iolanthe.rowland.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/14 15:45, Alan Stern wrote:
> On Mon, 20 Oct 2014, James Carlson wrote:
>> Indeed!  That's pretty darned lame behavior by that peer.  It would
>> probably be workable if you had a virtual router instance and were able
>> to put the L2TP connection in one routing instance and the PPP
>> connection in another routing instance, but that's likely not at all
>> simple to achieve.
> 
> I'd like to find the simplest solution.  Ideally it should "just work", 
> like the Windows and OS-X clients do.

I'm not an expert on Windows networking internals.  I assume OS X is BSD
+ whatever the folks in Cupertino have done to it.  :-/

At a guess, it's living on the edge.  It works because the L2TP
connection establishment caches a pointer to the output forwarding table
entry ("route") and just keeps living with it no matter what actually
happens down the line.

On Linux (and likely many other systems), the output computation is a
bit more dynamic, and the establishment of a direct point-to-point link
to a given IP address (as the PPP link represents) causes existing
cached pointers to get flushed away.  Future packets to that destination
(IP _always_ forwards based on destination, not source) go down the most
direct path.  Point-to-point is as direct as you can get.

It may be possible to modify the L2TP code to use flags to avoid the PPP
link (MSG_DONTROUTE?), but I suspect that's probably a bad rather than a
good thing to do.

>>> Unfortunately, I can't work around this problem by reconfiguring the
>>> VPN server -- there's no way to tell it to use a different IP address
>>> for its end of the VPN tunnel.  Furthermore, the server works just fine
>>> with clients running Windows or OS-X.
>>
>> Really?  That seems ... improbable.
> 
> I guess that depends on how you judge probabilities.  :-)

:-/

> Internet:
> Destination        Gateway            Flags    Refs      Use  Netif Expire
> default            140.247.233.37     UGSc        2        4   ppp0
> 10                 ppp0               USc         1        0   ppp0

That's *quite* interesting!  The PPP link doesn't have an interface
route as you'd find on most other systems.  Instead, it has what appears
to be an effectively unnumbered link.  Note the "ppp0" there instead of
an actual output address and the happy use of "10" for the local address
+ mask.

For what it's worth, the forced IP address option I've suggested is
morally equivalent to what's being done here on OS X, so that's a fair
reason to recommend it.

I checked out the pppd on Mac OS X (Darwin 13.4.0; Mavericks), and it
looks to be a variant of the SAMBA/ANU/CMU pppd, but I'm not sure what's
different with it, and I know of no contributions from them.  And the
BSD support is long gone from the main source base ...

> I don't understand (and can't be bothered to look up) those arcane
> symbols in the netstat output.  The IP address used for the ping test
> (10.160.0.2) is a system on the VPN's private network.

The flags aren't all that interesting.  "Up" "Gateway" "Static"
"cloning" are all expected in this context.

>> As long as you don't need to contact that specific remote server using
>> the badly-assigned "internal" VPN address and can live with the fact
>> that you'll either go through the regular Internet to that address or be
>> forced to use some other address configured on that server, you should
>> be good.
>>
>> (The address I used above is 10.160.0.2.  That was one of the internal
>> DNS server addresses provided in the log you posted.  It's not necessary
>> that the address used here is exactly that, but it may well be helpful.)
> 
> That might work.  But using a nonstandard version of pppd would be
> awkward, and I would prefer to avoid it.

What's "non-standard?"

Having the ability to force a given remote IP address looks to me like a
perfectly reasonable thing to do.  We allow the remote IP address to be
set arbitrarily when the peer (for whatever reason) refuses to divulge
its address, and this is just an extension of that idea.

>> If you can't do that for some reason, then I suppose it would be
>> possible to use IP Chains (or whatever the packet-modification tool du
>> jure is used in your Linux distribution) to nail up an exception so that
>> the outside packets go to the outside interface and the inside ones go
>> to the PPP interface.  Doing that likely requires selecting on (at
>> least!) source address, so it's messy and ugly and possibly error-prone,
>> but it might be doable.
> 
> That sounds like a fairly easy thing to try.  But it would still 
> require manual intervention instead of just working.  Fixing the kernel 
> would be preferable, IMO.

I don't quite agree that it's necessarily "broken."

I do agree that it's bad to crash due to this misconfiguration.  That's
certainly a bug of some sort.  But making the kernel "naturally" accept
that the same unicast remote IP address refers to different outputs
depending on phase-of-moon in order to make this weird server happy
sounds like adding a bug rather than fixing one.

Routing based on destination is a good thing.

>> Otherwise, contact the maintainer of that VPN server.  It's just plain
>> old broken, and life's too short for broken software.
> 
> It is an old Cisco security appliance, no doubt well past End-Of-Life.  
> I'm starting to think it might be preferable to throw the thing away 
> and start up a VPN server on the department's firewall (which is a 
> Linux box) instead.

That sounds like a good (and easier to support) solution.

-- 
James Carlson         42.703N 71.076W         <carlsonj@workingcode.com>
