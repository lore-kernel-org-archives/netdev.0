From: David Miller <davem@davemloft.net>
Subject: Re: TCP socket buffer autotuning
Date: Sun, 22 Oct 2006 20:51:25 -0700 (PDT)
Message-ID: <20061022.205125.21596474.davem@davemloft.net>
References: <45398FD3.8050003@psc.edu>
	<20061020.234228.68158300.davem@davemloft.net>
	<20061021123608.495a9dba@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, hkjerry.chu@gmail.com, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: shemminger@osdl.org
In-Reply-To: <20061021123608.495a9dba@localhost.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Sat, 21 Oct 2006 12:36:08 -0700

> On Fri, 20 Oct 2006 23:42:28 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > @@ -170,6 +170,8 @@ static int netem_enqueue(struct sk_buff 
> >  		return NET_XMIT_BYPASS;
> >  	}
> >  
> > +	skb_orphan(skb);
> > +
 ...
> Yeah, that's good. I run netem on an intermediate machine (bridge or router)
> when running tests to avoid this and other local feedback scenario's.

I'll put this into 2.6.19 as a fix for now, but I am so tempted
to just kill off that skb_set_owner_w() call in tcp_transmit_skb().

That call is totally pointless, even for the case where we pskb_copy()
a data SKB at the beginning of tcp_transmit_skb().  The socket is
charged for the memory, and the SKB clone itself is transient and
owned by entirely the IP{4,6} output path, queueing layer, and device.

We have discussed before how it probably makes sense for UDP, which
is in a similar situation, because otherwise a very aggressive
UDP socket can essentially flood the device without letting other
sockets to send traffic.

But here in this TCP clone situation, that doesn't apply.  The socket
has already had the data charged to it properly.

It is something to seriously consider for 2.6.20, anyways, because it
would kill off some expensive atomics and accounting in our TCP
transmit path as well.
