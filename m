From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V7 4/8] posix clocks: hook dynamic clocks into system
 calls
Date: Fri, 17 Dec 2010 08:04:50 +0100
Message-ID: <20101217070450.GB2982@riccoc20.at.omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <6241238a1df55033e50b151ec9d35ba957e43d53.1292512461.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1012162156580.12146@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1012162156580.12146@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 17, 2010 at 12:20:44AM +0100, Thomas Gleixner wrote:
> On Thu, 16 Dec 2010, Richard Cochran wrote:
> > +
> > +static inline bool clock_is_static(const clockid_t id)
> > +{
> > +	if (0 == (id & ~CLOCKFD_MASK))
> > +		return true;
> > +	if (CLOCKFD == (id & CLOCKFD_MASK))
> > +		return false;
> 
> Please use the usual kernel notation.

Sorry, what do you mean?

> >  	return CLOCK_DISPATCH(which_clock, clock_set, (which_clock, &new_tp));
> 
> I really start to wonder whether we should cleanup that whole
> CLOCK_DISPATCH macro magic and provide real inline functions for
> each of the clock functions instead.

I'm glad you suggested that.

IMHO, the CLOCK_DISPATCH thing is calling out to be eliminated, but I
didn't dare to take that upon myself.

> Please don't tell me now that we could even hack this into
> CLOCK_DISPATCH. *shudder*

;^)

> > +int pc_clock_adjtime(struct posix_clock *clk, struct timex *tx)
> > +{
> > +	int err;
> > +
> > +	mutex_lock(&clk->mux);
> > +
> > +	if (clk->zombie)
> 
> Uuurgh. That explains the zombie thing. That's really horrible and we
> can be more clever. When we leave the file lookup to the pc_timer_*
> functions, then we can simply do:
...
> That get's rid of your life time problems, of clk->mutex, clock->zombie
> and makes the code simpler and more robust. And it avoids the whole
> mess in posix-timers.c as well.

The code in the patch set is modeled after a USB driver, namely
drivers/usb/class/usbtmc.c. Alan Cox had brought up the example of a
PTP Hardware Clock appearing as a USB device. So the device might
suddenly disappear, and the zombie field is supposed to cover the case
where the hardware no longer exists, but the file pointer is still
valid.

I'll take a closer look at your suggestion...

> The whole point of this exercise is to provide dynamic clock ids and
> make them available via the standard posix timer interface and aside
> of that have standard file operations for these clocks to provide
> special purpose ioctls, mmap and whatever. And to make it a bit more
> complex these must be removable modules.

Yes, and hot pluggable, too.
 
> I need to read back the previous discussions, but maybe someone can
> fill me in why we can't make these dynamic things not just live in
> posix_clocks[MAX_CLOCKS ... MAX_DYNAMIC_CLOCKS] (there is no
> requirement to have an unlimited number of those) and just get a
> mapping from the fd to the clock_id? That creates a different set of
> life time problems, but no real horrible ones.

I would summarize the discussion like this:

Alan Cox was strongly in favor of using a regular file descriptor as
the reference to the dynamic clock.

John Stultz thought it wouldn't be too bad to cycle though a number of
static ids, being careful not to every assign the same static id (in
series) to two different clocks.

I implemented Alan's idea, since it seemed like maintaining the
mapping between clocks and static ids would be extra work, but without
any real benefit.

Thanks again for your review,
Richard
