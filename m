From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Sun, 26 Sep 2004 21:00:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040926210029.22750d47.davem@davemloft.net>
References: <20040923164149.5368d291.davem@davemloft.net>
	<E1CBkIW-0001dF-00@gondolin.me.apana.org.au>
	<20040927025048.GA6723@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040927025048.GA6723@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2004 12:50:48 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Sep 27, 2004 at 11:27:24AM +1000, Herbert Xu wrote:
> > 
> > Indeed, I think the new code means that Minshall's check will disable
> > Nagle which is what was keeping TSO working properly.
> > 
> > Anton, could you please try this patch which disables Minshall's check
> > and see what it does?
> 
> Never mind.  Minshall is innocent :)
> 
> We set the maximum TSO factor bounded by the congestion window.  But
> when the congestion window is raised, we don't call tcp_sync_mss
> which is the only place that can raise the TSO factor.
> 
> So the TSO factor never grows above what we start with.

The very next time we check to see if we can
make forward progress on the send queue we'll call tcp_current_mss()
which causes the right things to happen.

Something else is wrong.  I think part of it is that we need to
make tcp_clean_rtx_queue() return FLAG_DATA_ACKED even when a
partial TSO packet is ACK'd by the other end.  This will make
RTO etc. calculations actually occur, among other things.  But
I have no idea if that will clear up the performance problems
TSO is having with the new code.
