From: Dan Williams <dcbw@redhat.com>
Subject: Re: WEXT quality specification
Date: Sat, 5 Feb 2005 09:37:07 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0502050930220.15329@devserv.devel.redhat.com>
References: <Pine.LNX.4.58.0502042136060.1614@devserv.devel.redhat.com>
 <20050205052744.GD9685@jm.kir.nu> <Pine.LNX.4.58.0502050043300.7817@devserv.devel.redhat.com>
 <20050205063854.GE9685@jm.kir.nu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dan Williams <dcbw@redhat.com>, jt@hpl.hp.com, netdev@oss.sgi.com
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20050205063854.GE9685@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Feb 2005, Jouni Malinen wrote:
> On Sat, Feb 05, 2005 at 01:04:42AM -0500, Dan Williams wrote:
> 
> > Reporting received signal strength in RSSI and noise level in dBm won't really 
> > work well.  Manufacturers usually provide an RSSI->dBm conversion, but where 
> > they don't, the driver needs to be able to provide a MAX_RSSI value.  Otherwise, 
> > there is no way for user applications to know the bounds of these values and 
> > determine a signal quality % from them.  Again, this is all about consistency, 
> > and we need a stable, well-defined API that doesn't depend on user-applications 
> > special-casing drivers just to get usable information out of them.  If the 
> > driver cannot provide usable information of some sort, it shouldn't even be 
> > trying to provide that information at all really.
> 
> Agreed, there should be no special cases based on driver in user space.
> However, the API definition should not make it too difficult for the
> drivers to implement the interface. If many cards use dBm for noise and
> RSSI for received frames, it would sound like the API definition should
> take this into account and not require the drivers either not to report
> values or do some conversion which may not always be that clear.
> 
> > qual.qual must be linear (because it should be able to be converted to a 
> > percentage value, its a _subjective_ measure of quality composed of a number of 
> > different quality statistics).  qual.level & qual.noise may not necessarily be 
> > linear since they are measures of electrical power (either RSSI or dBm).
> 
> How would this value be determined for cards that have RSSI for received
> packets and noise floor in dBm? Using a table of values?

AFAIK, most manufacturers provide either a conversion constant (Airo & 
Madwifi/Atheros) or a lookup table (airo) of some sort for their cards.  People 
on Windows want to get dBm too.  Unfortunately, given that Linux driver writers 
can't always get that information, you're probably right.

> > The current WEXT API provides _no_ way to specify whether the returned values 
> > are in dBm or RSSI, other than using max_qual.level == 0 (dBm) and 
> > max_qual.level != 0 (RSSI).  That's just the way the API is at this time.  I've 
> > brought that up with Jean and he's agreed that it may need some clarification.  
> > There isn't really a "qual.type = dBm" bit anywhere in the quality structures, 
> > though that would be quite helpful (and was my suggestion).
> 
> > See above, technically you could have a noise floor of 0 I guess, and the 
> > current WEXT API has no way of specifying different units for use in noise and 
> > level at this time.  Hence, the noise value can actually mean something when 
> > using dBm as your unit, unlike max_qual.level when using dBm (as it must be 0).
> 
> Isn't the 'max_qual.level == 0 means dBm' similar to saying
> 'max_qual.noise == 0 means dBm' for noise. In other words,
> max_qual.level == 70 and max_qual.noise == 0 could mean RSSI for signal
> strength and dBm for noise. Using max_qual.noise to report global noise
> value (noise floor?) sound somewhat confusing.

Yes, that's true, and would probably be more consistent.  If the suggestion is 
to go this far in changing the spec, then I'd suggest to actually make 
explicit fields in the iw_quality structure that specify what units are being 
used.

There are two unused bitfields in the .updated structure of the iw_quality 
structure, and if you want to keep API/ABI compatibility then those could be 
used to specify RSSI/dBm.  I've suggested some method of explicitly specifying 
this in the API, which Jean is considering.

Dan
