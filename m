From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 17:03:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929170310.46c58095.davem@davemloft.net>
References: <20040929162923.796d142e.davem@davemloft.net>
	<Pine.NEB.4.33.0409291945100.3434-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, niv@us.ibm.com, herbert@gondor.apana.org.au,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409291945100.3434-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 19:51:21 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> On Wed, 29 Sep 2004, David S. Miller wrote:
> 
> > Let me know if this cures the issue, and if it does we can
> > move back to Andi's performance issue and the MSS stuff
> > John Heffner just discovered.
> 
> Seems to work for me.
> 
> Using iperf, I'm getting ~ the same speed to a slow p3 receiver (680
> Mbits) with TSO on or off right now.  Haven't tried netperf.

Great, thanks for testing.

I just pushed these changes into my tree at:

	bk://kernel.bkbits.net/davem/net-2.6

and asked Linus to pull them in.

I think I'm going to make tcp_tso_acked() call tcp_trim_head()
direclty so that skb->len and (end_seq - seq) are kept in sync.
This will also correct a bug in tcp_tso_acked() wrt. URG processing.
It uses the wrong sequence number currently.  Luckily that code never
runs currently because all URG packets are built non-TSO.  Better to
fix this than to let it bite us later.

I think there are some other things we can do to make TSO work
even better.  We turn off TSO currently when we get SACKs, that
stinks and is really unnecessary.  We can keep track of sacking
of sub-TSO frames by simply using a bitmask of some kind.  I will
have space for this if I move the tso_factor/tso_mss out of
tcp_skb_cb[] and just use the tso_{size,segs} in skb_shinfo(skb)

Anyways, I'll work on that stuff while the dust settles on the
current bug fix.
