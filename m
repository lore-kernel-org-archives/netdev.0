From: jamal <hadi@cyberus.ca>
Subject: Re: LLTX and netif_stop_queue
Date: 03 Jan 2005 10:04:21 -0500
Message-ID: <1104764660.1048.578.camel@jzny.localdomain>
References: <52llbwoaej.fsf@topspin.com>
	 <20041217214432.07b7b21e.davem@davemloft.net>
	 <1103484675.1050.158.camel@jzny.localdomain>
	 <5cac192f04122210491d64d4b6@mail.gmail.com>
	 <20041222202919.057b8331.davem@davemloft.net>
	 <5cac192f0412230110628749e3@mail.gmail.com> <41CAF444.3000305@trash.net>
	 <5cac192f04122408102129af43@mail.gmail.com>
	 <1104240717.1100.66.camel@jzny.localdomain>
	 <5cac192f0501021530672a908a@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        roland@topspin.com, netdev@oss.sgi.com, openib-general@openib.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <eric.lemoine@gmail.com>, Andi Kleen <ak@suse.de>
In-Reply-To: <5cac192f0501021530672a908a@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this piece:
-----
+
+                       /* And release queue */
+                       spin_unlock(&dev->queue_lock);
                }
---------

Isnt there a possibility (higher as you increase number of processors)
that you will spin for a long time in _the driver_ waiting for the queue
lock? 

Maybe we need a flag "the queue lock" is already been grabbed passed
to the driver. LLTX is a good  alias but insufficient (if you run your
driver in an old kernels which support LLTX but not the idea of locking
the queue for you).

Andi or anyone else - has anyone really done perfomance analysis of LLTX
(with anything other than loopback) and shown it has any value? Maybe
time to just shoot the damn thing.

cheers,
jamal

On Sun, 2005-01-02 at 18:30, Eric Lemoine wrote:
> On 28 Dec 2004 08:31:57 -0500, jamal <hadi@cyberus.ca> wrote:
> > On Fri, 2004-12-24 at 11:10, Eric Lemoine wrote:
> > 
> > > Yes but requiring drivers to release a lock that they should not even
> > > be aware of doesn't sound good. Another way would be to keep
> > > dev->queue_lock grabbed when entering start_xmit() and let the driver
> > > drop it (and re-acquire it before it returns) only if it wishes so.
> > > Although I don't like this too much either, that's the best way I can
> > > think of up to now...
> > 
> > I am not a big fan of that patch either, but i cant think of a cleaner
> > way to do it.
> > The violation already happens with the LLTX flag. So maybe a big warning
> > that says "Do this only if you driver is LLTX enabled". The other way to
> > do it is put a check to see if LLTX is enabled before releasing that
> > lock - but why the extra cycles? Driver writer should know.
> 
> Two (untested) patches implementing what I described above.
> 
> The first pach (sch_generic.patch) keeps queue_lock held in
> qdisc_restart() when calling hard_start_xmit() of a LLTX driver. The
> second (sungem.patch) makes sungem release queue_lock after grabbing
> its private tx lock.
> 
> Note that the modifications made to qdisc_restart() are not compatible
> with the current LLTX drivers. All LLTX drivers must be modified along
> sungem.patch's lines. Take sungem.patch as an example of how things
> must be done.
> 
> Patches apply to current davem bk snapshot.
