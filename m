From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pskb change in dst->output
Date: Sat, 10 Jul 2004 07:43:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709214310.GA3474@gondor.apana.org.au>
References: <20040709081443.GA11101@gondor.apana.org.au> <Xine.LNX.4.44.0407091001460.3887-100000@thoron.boston.redhat.com> <20040709123608.1f9f9265.davem@redhat.com> <20040709204228.GA3015@gondor.apana.org.au> <20040709142144.483369ec.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040709142144.483369ec.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 09, 2004 at 02:21:44PM -0700, David S. Miller wrote:
>
> > When TCP retransmits the packet, it will do a pskb_copy() on it so
> > it's no longer a clone.
> 
> Not necessarily true.  If the device has finished transmission,
> which is true %99.9999 of the time when a retransmission happens,
> another clone will be made against the original SKB sitting in
> the write queue.

You're right.  But that case is identical to the clone during the
initial transmission.

> The hw checksumming state is what we care about.  And skb_cow()'s implementation
> is:
> 
> 1) Always copy all data if cloned
> 
> 2) Allocate a unique data area, and even the shared private skb
>    area becomes local to the skb.
> 
> In short only the data is uncloned.
> 
> However, skb_checksum_help() is doing something entirely different.
> It makes a fully new skb, both data and sk_buff struct are uncloned.

I completely agree with these facts.

> This is particularly important for the very case which ah_output()
> cares about, for example.  If the skb is CHECKSUM_HW we have to unclone
> the full SKB.  ah_output() does not use things like skb_cow() like
> ESP and others do.
>
> I really think the dst->output() SKB pointer passing is truly needed.

That's where we disagree.  The very first thing ah_output() does after
the *conditional* skb_checksum_help() call is skb_push().  This cannot
be done on a shared skb.  Therefore the skb must be totally private
or at most cloned.

This is the fundamental reason why there is no need to make a completely
new skb because we already have (or assume to have) exlucsive access
to the fields in the sk_buff struct.

Now whether we need to unclone the data or not is a different question.
My opinion is that we don't, but I'm not to fussed over that.

> You still won't be convinced, I know :-)  So propose a patch and we'll
> shoot holes in it so we can discuss something concrete, ok? :)))

OK, that's what I'll do once I finish working on the IPv4 IPsec
encapsulation stuff.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
