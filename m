From: "David S. Miller" <davem@redhat.com>
Subject: Re: pskb change in dst->output
Date: Fri, 9 Jul 2004 14:21:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709142144.483369ec.davem@redhat.com>
References: <20040709081443.GA11101@gondor.apana.org.au>
	<Xine.LNX.4.44.0407091001460.3887-100000@thoron.boston.redhat.com>
	<20040709123608.1f9f9265.davem@redhat.com>
	<20040709204228.GA3015@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040709204228.GA3015@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 10 Jul 2004 06:42:28 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Fri, Jul 09, 2004 at 12:36:08PM -0700, David S. Miller wrote:
> >
> > > > If there are no objections, I'd like to create a version of
> > > > skb_checksum_help() that doesn't copy the packet, and call
> > > > that version from ah_output()/esp_output()/ipcomp_output().
> > > 
> > > This will break when cloned packets are passed to these functions.
> > 
> > James is right Herbert.  TCP will send clones down into these routines
> > all the time.
> 
> The first TCP transmission will always be a clone of a packet off
> its output queue.  However, the TCP code is written such that you
> can modify any part of the skb except the TCP payload.  This
> includes the TCP header which is where the TCP checksum is.
>
> If this weren't the case then you'd have to copy the packet much earlier.
> This assumption is already made by tcp_transmit_skb(), ip_queue_xmit()
> and all the functions called by dst_output().
> 
> When TCP retransmits the packet, it will do a pskb_copy() on it so
> it's no longer a clone.

Not necessarily true.  If the device has finished transmission,
which is true %99.9999 of the time when a retransmission happens,
another clone will be made against the original SKB sitting in
the write queue.

> So unless I've missed another case where someone will pass a clone
> down, it is safe to change the checksum on the TCP clones.

The hw checksumming state is what we care about.  And skb_cow()'s implementation
is:

1) Always copy all data if cloned

2) Allocate a unique data area, and even the shared private skb
   area becomes local to the skb.

In short only the data is uncloned.

However, skb_checksum_help() is doing something entirely different.
It makes a fully new skb, both data and sk_buff struct are uncloned.

This is particularly important for the very case which ah_output()
cares about, for example.  If the skb is CHECKSUM_HW we have to unclone
the full SKB.  ah_output() does not use things like skb_cow() like
ESP and others do.

I really think the dst->output() SKB pointer passing is truly needed.

You still won't be convinced, I know :-)  So propose a patch and we'll
shoot holes in it so we can discuss something concrete, ok? :)))
