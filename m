From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.9-rc2] 3c59x: do not mask reset of aism logic at rmmod
Date: Thu, 7 Oct 2004 13:46:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007134601.B29517@tuxdriver.com>
References: <20040928145455.C12480@tuxdriver.com> <Pine.LNX.4.44.0409291253510.1746-100000@training.scyld.com> <20040930091407.A10417@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>, netdev@oss.sgi.com, akpm@osdl.org,
        jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040930091407.A10417@tuxdriver.com>; from linville@tuxdriver.com on Thu, Sep 30, 2004 at 09:14:07AM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bad form to reply to oneself, but someone needs to... :-)

Jeff/Andrew/Don,

Long message follows -- basically, I'm 100% convinced that at least
certain cards covered by the 3c59x driver need to have the aismReset
bit unmasked in the TotalReset command.

I'm looking for some advice as to how to rework my patch in order for it
to be accepted.  I enumerate a few possible variations.

For details, see below...

On Thu, Sep 30, 2004 at 09:14:07AM -0400, John W. Linville wrote:
> On Wed, Sep 29, 2004 at 01:16:01PM -0400, Donald Becker wrote:
> 
> > > module).  Changing vortex_remove_one() to allow the auto-initialize
> > > state machine logic to be reset when the module is removed alleviates
> > > this problem.
> > 
> > ...and creates a new problem: resetting the link causes operational
> > problems on many networks.  The most obvious example is spanning tree
> > detection delays on switches, where the switch does not pass traffic.

> Does allowing the aismReset to occur cause the link to go down?  I guess
> I presumed that was what the networkReset bit was there to prevent.

It appears that aismReset does not cause the link to go down.

Here is the setup I used to test this:

	 "domestic"                "partner"
	+---------+               +---------+
	|         |eth2       eth1|         |
	|  3c905  |<------------->| ns83820 |
	|         |               |         |
	+---------+               +---------+

The ns83820 driver gets an interrupt on link state changes.  For the
test, the ns83820 driver was modified to log those interrupts to the
system console.  To verify that was working, the link was reset w/ this
command on "domestic":

	mii-tool -r eth2

As expected, this resulted in entries in /var/log/messages on "partner"
immediately after every time the command was issued.

Next, I applied my patch to un-mask the aismReset bit in the TotalReset
command during rmmod of the 3c59x driver (handling the 3c905).  To test
this, I executed the following series of comands on "domestic":

	ifconfig eth2 0.0.0.0 down
	modprobe -r 3c59x
	ifup 3c59x

I repeated the sequence many times, and /var/log/messages on "partner"
showed none of the link status interrupts.  This indicates that
unmasking aismReset does NOT result in resetting the link.

> Even if the link does go down, is that really such a bit deal on an
> rmmod?  I can see wanting to avoid it on a normal close, but an rmmod
> would seem like a more rare event.

BTW, I still think the above is a good point...

> P.S.  The current state of the reset at rmmod seems to have come in the
> 2.4.9 timeframe.  Prior to that, FWIW all but one card left the aismReset
> bit unmasked just as in my patch.

Which brings me to "how do we want to fix this?"  I think there are (at
least) three options:

	-- apply (some version) of the patch I submitted a few days ago;
	-- add a flag to the drv_flags field to indicate which cards need
	   the aismReset bit to be unmasked; or,
	-- key the reset off the IS_BOOMERANG filed of the drv_flags field.

The first option is the cleanest, althought I think it would be most
prudent to reimplent the patch to reinstate the EEPROM_NORESET flag that
was eliminited in version LK1.1.16 of the driver.  The testing I
described above would suggest that the aismReset bit is not related to
the "reset the interface logic on open/close/rmmod" changes that were
also added in that revision.

The second version would be a lot like the old EEPROM_NORESET field in
reverse -- only cards w/ the flag would get the aismReset flag unmasked.
This is the most flexible in case it turns-out that multiple card
variations have this problem.

The third version is what my gut tells me we need, but I don't have
enough card variations to be sure that all/only Boomerang cards are
prone to this problem.  It would be less flexible than the second
version if it turned-out the some Boomerang cards don't have the problem
or if some Cyclone cards do, etc.

I've done a lot of searching for references to this problem, and none of
them go back further than 2.4.9, which is when the aismReset bit first
started getting masked at rmmod (for all cards but one).  I'm sure that
at least certain cards (e.g. the 3c905) NEED this fix, and it seems to be
safe to make it.  I'm looking for some guidance on how to fix this problem
in a way that makes people comfortable.

I appreciate your attention and response!

John
-- 
John W. Linville
linville@tuxdriver.com
