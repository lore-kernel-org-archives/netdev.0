From: Rick Jones <rick.jones2@hp.com>
Subject: Re: on the wire behaviour of TSO on/off is supposed to be the same
 yes?
Date: Mon, 24 Jan 2005 12:33:23 -0800
Message-ID: <41F55B93.6040603@hp.com>
References: <41F1516D.5010101@hp.com> <200501211358.53783.jdmason@us.ibm.com>	<41F163AD.5070400@hp.com>	<20050121124441.76cbbfb9.davem@davemloft.net>	<41F17B7E.2020002@hp.com>	<20050121141820.7d59a2d1.davem@davemloft.net>	<41F186A8.9030805@hp.com> <20050121204948.034b2510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050121204948.034b2510.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The code can potentially get really messy and ugly if we start
> preemptively building larger frames "hoping" the cwnd will be
> large enough by the time we push it onto the wire.  Segmenting
> at send time is completely upside down to the way packets are
> built currently for transmission.  A bad guess also means that
> we'll spend significant cycles chopping up TSO packets and
> resegmenting the queue.

Just some pseudo-random thoughts which may or may not hold true in the context 
of Linux TSO, and may or may not show my utter ignorance of current cwnd 
behaviour :)

*) At present the code executed at time of user send knows about the cwnd at the 
time of user send.  It then builds some number of TSO-sized segements and queues 
them

*) "Classic" cwnd behaviour is either:

    a) Increasing rapidly to ssthresh
    b) Increasing slowly after ssthresh
    c) Restarting from initial values after timeout

(IIRC there is other cwnd manipulation for fast rtxes and the like)

*) If there is a timeout, any previously queued TSO-sized segments are going to 
have to be resegmented anyway no matter what their size was before the timeout. 
So conservative versus optimistic guesses there would not seem to matter.

*) If there is a fast rtx and the like, any previously queued TSO-sized segments 
may very likely (not certain though) have to be resegmented, particularly if 
they were queued when cwnd was >= ssthresh

*) If cwnd is < ssthresh, the next cwnd is going to be > current cwnd unless 
there is a retransmission of some sort.

*) If cwnd is >= ssthresh, cwnd will remain cwnd for some time (compared to 
otherwise)

It would seem that the segmentation code, if it knew ssthresh as well as cwnd 
_could_ make some reasonably optimistic guesses as to cwnd growth while doing 
its segmentation.  Guesses that wouldn't seem to be any worse than they would be 
at present if there is a full RTO at least.  And if the tcp_tso_win_divisor is > 
1, it is possible that even the onesey-twosies of fast rtx may not require all 
_that_ much resegmentation?

of have I just gone-off into the deep-end?

rick jones

BTW, speaking of tcp_tso_win_divisor, I've gone back through my traces and they 
do not support my recollection, so I must have been confused as to what I was 
looking-at when I got that impression.
