From: Dan Williams <dcbw@redhat.com>
Subject: Re: WEXT quality specification
Date: Sat, 5 Feb 2005 01:04:42 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0502050043300.7817@devserv.devel.redhat.com>
References: <Pine.LNX.4.58.0502042136060.1614@devserv.devel.redhat.com>
 <20050205052744.GD9685@jm.kir.nu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dan Williams <dcbw@redhat.com>, jt@hpl.hp.com, netdev@oss.sgi.com
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20050205052744.GD9685@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Feb 2005, Jouni Malinen wrote:
> On Fri, Feb 04, 2005 at 09:45:55PM -0500, Dan Williams wrote:
> 
> > I've taken the liberty of whipping up a long-winded patch to wireless.17.h in an 
> > attempt to concretely specify what drivers need to do for quality.
> 
> Nice to see more documentation on this area. I would consider moving
> this to somewhere else or adding a separate document
> (Documentation/networking/wireless/... ?) though, since I would hope to
> eventually see detailed (and in practice, quite long) explanation for
> all areas of the wireless extensions, not just signal quality. Comments
> in C header files may not be the nicest format for editing such
> specification..
> 
> > + * Explanation of WIRELESS QUALITY
> 
> Maybe change that to wireless signal quality?
> 
> > + * Wireless quality is may be measured in two methods, drivers must PICK ONE
> > + * and use it consistently throughout the driver->userspace API:
> 
> Unfortunately, this may not be possible with some (well, maybe even
> most) hardware models. It is quite common to configure TX power in dBm
> and report signal strength for received frames in RSSI. Even if this
> part is left out and this is only about signal strength/quality of
> received frames, some cards have different mechanism for reporting
> quality for 1) received packets, 2) current BSS (average), 3) scan
> results. Another common example is in reporting received signal strength
> in RSSI and noise level in dBm.

Note that I understand that determining a % value for "signal quality" is quite 
subjective, but the idea here is be able to give users a "your connection is x%" 
value (qual.qual), _in addition_ to being able to give them raw signal strength 
values (qual.level/qual.noise).

At this point we're just talking about received signal quality/level.  The point 
here is that there are two different "types" of quality that the driver must report, 
(1) subjective signal quality (qual.qual), and (2) electrical signal levels 
(qual.level).  WRT the different mechanisms, there _needs_ to be consistency 
among drivers.  Otherwise, user-space applications are left to guess what the 
heck each and every driver is using for units.  Which just doesn't work.

For your signal mechanisms, there is a place for all of them.  But there needs 
to be consistency between 2 & 3.  In the current WEXT API, there is no ability 
to set separate max quality & signal levels for each, there is only one max 
signal & quality level structure.

Reporting received signal strength in RSSI and noise level in dBm won't really 
work well.  Manufacturers usually provide an RSSI->dBm conversion, but where 
they don't, the driver needs to be able to provide a MAX_RSSI value.  Otherwise, 
there is no way for user applications to know the bounds of these values and 
determine a signal quality % from them.  Again, this is all about consistency, 
and we need a stable, well-defined API that doesn't depend on user-applications 
special-casing drivers just to get usable information out of them.  If the 
driver cannot provide usable information of some sort, it shouldn't even be 
trying to provide that information at all really.

> > + * 2) The second measure is decibel millivolts, or dBm.  This is calculated from
> 
> milliwatts (i.e., power, not potential)

Correct, it was late :)  My mistake.

> > + * is _always_ 0, and the lower bound is determined by the receiver sensitivity
> 
> When setting TX power, these numbers are (in most cases) positive, e.g.,
> 16 dBm. Again, this could be considered to be outside the scope of this
> description, but should be kept in mind for other parts of wireless
> extensions. Another example would be non-802.11 wireless device that
> could potentially receive signals with higher power than 0 dBm..

Again, we're not talking about TX power yet...  The non-802.11 point is valid, 
but at this time WEXT is so geared toward 802.11 devices that more significant 
changes would need to take place to apply WEXT to them.  I'm not sure that time 
has come yet.

> 
> > + * The 'qual' fields are method independent, and are specified as follows:
> > + *
> > + * max_qual.qual:   (range is 0 -> 255) upper bound of subjective quality
> > + *                  levels.  Other .qual fields MUST be less than this number.
> > + *
> > + * qual.qual:       (range is 0 -> max_qual.qual) Quality of the received packet
> > + *                  as determined by the driver.  The only restriction is that
> > + *                  user applications MUST be able to derive a percentage value
> > + *                  by doing the following calculation:
> > + *                          percent =  100 * (qual.qual / max_qual.qual)
> > + *                  Drivers may factor other statistics, such as receive packet
> > + *                  errors, # collisions, noise levels, etc, into the value.
> 
> Is this restriction to linear value ok? Many other values are in
> logarithmic scale. What does this "percentage" really mean and what is
> it used for? The current wireless.h defines quality as percentage of
> retries or missed beacons, or SNR..

qual.qual must be linear (because it should be able to be converted to a 
percentage value, its a _subjective_ measure of quality composed of a number of 
different quality statistics).  qual.level & qual.noise may not necessarily be 
linear since they are measures of electrical power (either RSSI or dBm).

> 
> > + * Once a driver has PICKED ONE method of measurement, the quality fields must
> > + * be filled as follows.  Remember, all fields are 8-bits wide and are treated
> > + * as signed or unsigned based on the method of quality measurement above.
> > + *
> > + *
> > + * RSSI METHOD (set max_qual.level > 0 as explained below)
> > + *--------------------------------------------------------
> > + * max_qual.level:  (range is 1 -> 255) upper bound of the RSSI of any received
> > + *                  packet, determined by the card's hardware.  Usually
> > + *                  specified in technical literature from manufacturer, or
> > + *                  provided by registers on the card.
> > + *                    NOTE: to specify that values are in RSSI, max_qual.level
> > + *                          MUST be larger than 0.
> 
> So, if the hardware reports RSSI in 0..70, both values 0 and 1 should be
> stored as 1? Actually, I've seen one hardware where reported RSSI values
> are dropping below zero every now and then..

The current WEXT API provides _no_ way to specify whether the returned values 
are in dBm or RSSI, other than using max_qual.level == 0 (dBm) and 
max_qual.level != 0 (RSSI).  That's just the way the API is at this time.  I've 
brought that up with Jean and he's agreed that it may need some clarification.  
There isn't really a "qual.type = dBm" bit anywhere in the quality structures, 
though that would be quite helpful (and was my suggestion).

But here we're talking about max_qual.level, remember its the upper bound and 
will never have a value of 0.  If the card's MAX_RSSI is 0, something is 
horribly wrong with the card since that indicates that it cannot receieve any 
signal at all.  If the card actually has an interesting max_qual.level in dBm 
(say, -10 dBm), we cannot encode that value using WEXT at this time.

> 
> > + * max_qual.noise:  (range is 0 -> 255) lower bound of noise, ie the received
> 
> Why is there a different range for noise? Is only max_qual.level used to
> select the RSSI/dBm method and this max_qual.noise would be, e.g., the
> current noise floor (which, btw, is often presented in dBm, not RSSI).
> Is this a new mechanism for reporting noise floor? I don't remember
> seeing this kind of definition before.

See above, technically you could have a noise floor of 0 I guess, and the 
current WEXT API has no way of specifying different units for use in noise and 
level at this time.  Hence, the noise value can actually mean something when 
using dBm as your unit, unlike max_qual.level when using dBm (as it must be 0).

This is really an attempt to clarify the rules as I understand them (and after a 
couple discussions with Jean about the quality stuff).  I've looked over almost 
every wireless/802.11 driver that exists for Linux, and none of them 
implement the standard correctly, probably becuase its a bit ambiguous and 
nobody could quite understand what they were supposed to do in the quality 
space.  We need to bring some coherency to drivers in this regard, if only so 
that people can get their pretty little signal bars in the UI.

Dan
