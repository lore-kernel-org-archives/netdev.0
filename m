From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Tue, 09 Sep 2014 15:26:02 -0700
Message-ID: <1410301562.13298.35.camel@jarvis.lan>
References: <20140905141241.GC10455@mtj.dyndns.org>
	 <20140905164405.GA28964@core.coreip.homeip.net>
	 <20140905174925.GA12991@mtj.dyndns.org>
	 <CAB=NE6VPTV39pNujOgO422wbUvU44HZ7s=aaxPVraNECqA6e4Q@mail.gmail.com>
	 <20140905224047.GC15723@mtj.dyndns.org>
	 <CAB=NE6Uz1VD5qpMFSBfQRV8ih9FQcCUhNtWMvD38t5hdDvix4Q@mail.gmail.com>
	 <20140909011059.GB11706@mtj.dyndns.org>
	 <1410241109.2028.22.camel@jarvis.lan>
	 <CAB=NE6WGAMvffGDTkN5x5Cd+YOtD-Cmo3v7_8FmJ5cvCRbFEpw@mail.gmail.com>
	 <1410291346.13298.16.camel@jarvis.lan>
	 <20140909214240.GA3154@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare@suse.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <pravee
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140909214240.GA3154@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-09-10 at 06:42 +0900, Tejun Heo wrote:
> Hey, James.
> 
> On Tue, Sep 09, 2014 at 12:35:46PM -0700, James Bottomley wrote:
> > I don't have very strong views on this one.  However, I've got to say
> > from a systems point of view that if the desire is to flag when the
> > module is having problems, probing and initializing synchronously in a
> > thread spawned by init which the init process can watchdog and thus can
> > flash up warning messages seems to be more straightforwards than an
> > elaborate asynchronous mechanism with completion signalling which
> > achieves the same thing in a more complicated (and thus bug prone)
> > fashion.
> 
> We no longer report back error on probe failure on module load.

Yes, we do; for every probe failure of a device on a driver we'll print
a warning (see drivers/base/dd.c).  Now if someone is proposing we
should report this in a better fashion, that's probably a good idea, but
I must have missed that patch.

>   It
> used to make sense to indicate error for module load on probe failure
> when the hardware was a lot simpler and drivers did their own device
> enumeration.  With the current bus / device setup, it doesn't make any
> sense and driver core silently suppresses all probe failures.  There's
> nothing the probing thread can monitor anymore.

Except the length of time taken to probe.  That seems to be what systemd
is interested in, hence this whole thread, right?

> In that sense, we already separated out device probing from module
> loading simply because the hardware reality mandated it and we have
> dynamic mechanisms to listen for device probes exactly for the same
> reason, so I think it makes sense to separate out the waiting too, at
> least in the long term.  In a modern dynamic setup, the waits are
> essentially arbitrary and doesn't buy us anything.

But that's nothing to do with sync or async.  Nowadays we register a
driver, the driver may bind to multiple devices.  If one of those
devices encounters an error during probe, we just report the fact in
dmesg and move on.  The module_init thread currently returns when all
the probe routines for all enumerated devices have been called, so
module_init has no indication of any failures (because they might be
mixed with successes); successes are indicated as the device appears but
we have nothing other than the kernel log to indicate the failures.  How
does moving to async probing alter this?  It doesn't as far as I can
see, except that module_init returns earlier but now we no longer have
an indication of when the probe completes, so we have to add yet another
mechanism to tell us if we're interested in that.  I really don't see
what this buys us.

James
