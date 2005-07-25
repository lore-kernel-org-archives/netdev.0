From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: Re: drop counts
Date: Mon, 25 Jul 2005 10:47:39 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0507251041150.832@jbrandeb-desk.amr.corp.intel.com>
References: <42DCDCAF.1060005@draigBrady.com> <42DCF0F7.6000704@draigBrady.com>
 <Pine.WNT.4.63.0507201505370.1936@jbrandeb-desk.amr.corp.intel.com>
 <42DFA4E9.5060602@draigBrady.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: P@draigBrady.com
In-Reply-To: <42DFA4E9.5060602@draigBrady.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On Thu, 21 Jul 2005, P@draigBrady.com wrote:
> > dropped: rnbc does not mean dropped, see above.  mpc means dropped.
> >
> > fifo: mpc means the fifo overflowed, and the packet was dropped (the
> > only time we drop).
> >
> > missed: this should also be mpc because it shows we missed the packet.
> 
> Wow, thanks! So there we were reporting drops prior
> to 2.6.12 when there possibly were none!

yeah, that was kind of ugly.

> It's interesting that at about 1Mpps sustained for 10s,
> mpc was 548,888, while rnbc was 4,331,730 suggesting
> that the nic was trying to DMA to the buffer at a
> higher rate than the packet receive rate.

Not really that interesting because the NIC may have been trying multiple 
times internally to DMA the data (possibly as each packet was received) 
and failing each time.

> 2.6.11 stats were mapped like:
> 
> packets = gprc
> dropped = rnbc
> fifo = mpc
> missed = mpc
> 
> In 2.6.12 this changed to:
> 
> packets = gprc
> dropped = mpc
> fifo = mpc
> missed = mpc
> 
> > now, its debatable if we should be reporting the same stat 3 times, but
> > i still think it is correct, and its how our hardware maps stats and the
> > best we can overlay onto linux's definitions as we interpret them.
> 
> I think there still is a problem. Notice that /proc/net/dev
> reports rx_dropped + rx_missed_errors for the drop column,
> and so will be double counting drops currently.
> Therefore I think we should be doing:
> 
> packets = gprc
> dropped = 0
> fifo = rnbc
> missed = mpc

Double counting drops may be an issue, and I believe we should make that 
change.  but I don't think its the right thing to report rnbc in fifo 
errors (there was actually no error).

> I'm putting rnbc in fifo as it's not accumulated into
> anything else in the kernel. Also it's good to have
> it reported as one can see when there is pressure on
> the e1000 driver buffer. This is useful for tuning its size
> to protect against drops and latency.

Whenever I want the RNBC numbers I simply look into ethtool -S eth0, and 
that allows me to tune.  I see no reason to "reuse" the fifo errors stat 
with misleading data.

Once again, having clear guidelines on what these stats actually mean for 
drivers and when they should use them for ethernet would be *really* 
useful.

Jesse


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
