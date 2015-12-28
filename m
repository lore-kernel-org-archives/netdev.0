From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH stable-3.2 stable-3.12] net: fix checksum check in
 skb_copy_and_csum_datagram_iovec()
Date: Mon, 28 Dec 2015 12:10:10 -0500
Message-ID: <1451322610.8255.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151228140157.6F592A0C7D@unicorn.suse.cz>
	 <20151228142942.GA7394@bistromath.redhat.com>
	 <20151228153836.GA28529@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sabrina Dubroca <sd@queasysnail.net>, stable@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>,
	Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20151228153836.GA28529@unicorn.suse.cz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-12-28 at 16:38 +0100, Michal Kubecek wrote:
> On Mon, Dec 28, 2015 at 03:29:42PM +0100, Sabrina Dubroca wrote:
> > 2015-12-28, 15:01:57 +0100, Michal Kubecek wrote:
> > > Recent fix "net: add length argument to
> > > skb_copy_and_csum_datagram_iovec" added to some pre-3.19 stable
> > > branches, namely
> > > 
> > >   stable-3.2.y: commit 127500d724f8
> > >   stable-3.12.y: commit 3e1ac3aafbd0
> > > 
> > > doesn't handle truncated reads correctly. If read length is shorter than
> > > incoming datagram (but non-zero) and first segment of target iovec is
> > > sufficient for read length, skb_copy_and_csum_datagram() is used to copy
> > > checksum the data while copying it. For truncated reads this means only
> > > the copied part is checksummed (rather than the whole datagram) so that
> > > the check almost always fails.
> > 
> > I just ran into this issue too, sorry I didn't notice it earlier :(
> > 
> > > Add checksum of the remaining part so that the proper checksum of the
> > > whole datagram is computed and checked. Special care must be taken if
> > > the copied length is odd.
> > > 
> > > For zero read length, we don't have to copy anything but we still should
> > > check the checksum so that a peek doesn't return with a datagram which
> > > is invalid and wouldn't be returned by an actual read.
> > > 
> > > Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> > > ---
> > >  net/core/datagram.c | 26 +++++++++++++++++++++-----
> > >  1 file changed, 21 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/net/core/datagram.c b/net/core/datagram.c
> > > index f22f120771ef..af4bf368257c 100644
> > > --- a/net/core/datagram.c
> > > +++ b/net/core/datagram.c
> > > @@ -809,13 +809,14 @@ int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb,
> > >  				     int hlen, struct iovec *iov, int len)
> > >  {
> > >  	__wsum csum;
> > > -	int chunk = skb->len - hlen;
> > > +	int full_chunk = skb->len - hlen;
> > > +	int chunk = min_t(int, full_chunk, len);
> > >  
> > > -	if (chunk > len)
> > > -		chunk = len;
> > > -
> > > -	if (!chunk)
> > > +	if (!chunk) {
> > > +		if (__skb_checksum_complete(skb))
> > > +			goto csum_error;
> > >  		return 0;
> > > +	}
> > >  
> > >  	/* Skip filled elements.
> > >  	 * Pretty silly, look at memcpy_toiovec, though 8)
> > > @@ -833,6 +834,21 @@ int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb,
> > >  		if (skb_copy_and_csum_datagram(skb, hlen, iov->iov_base,
> > >  					       chunk, &csum))
> > >  			goto fault;
> > > +		if (full_chunk > chunk) {
> > > +			if (chunk % 2) {
> > > +				__be16 odd = 0;
> > > +
> > > +				if (skb_copy_bits(skb, hlen + chunk,
> > > +						  (char *)&odd + 1, 1))
> > > +					goto fault;
> > > +				csum = add32_with_carry(odd, csum);
> > > +				csum = skb_checksum(skb, hlen + chunk + 1,
> > > +						    full_chunk - chunk - 1,
> > > +						    csum);
> > > +			} else
> > > +				csum = skb_checksum(skb, hlen + chunk,
> > > +						    full_chunk - chunk, csum);
> > > +		}
> > >  		if (csum_fold(csum))
> > >  			goto csum_error;
> > >  		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
> > > -- 
> > > 2.6.4
> > 
> > 
> > This adds quite a bit of complexity.
> 
> I'm not really happy about it either. :-( Most of the complexity comes
> from the corner case when one 16-bit word is divided between the copied
> part and the rest - but I can't see a nicer way to handle it.
> 
> There is another option: in the case of truncated read, we could simply
> take the first branch where copying is separated from checksumming. This
> would be less efficient, obviously, but I must admit I have no idea how
> much.
> 
> > I am considering a revert of my
> > buggy patch, and use what Eric Dumazet suggested instead:
> > 
> > https://patchwork.ozlabs.org/patch/543562/
> > 
> > What do you think?
> 
> I believe that would work. I have a little bad feeling about such
> solution as it would keep the function broken and just rely on not
> hitting it in the case when it matters. But it worked that way for quite
> some time so it's probably safe.

For the record, this is what we are using here at Google on our prod
kernel.

Sabrina, I certainly can send the patch for net-next kernel, as this
does not fix a bug for current kernels, but backporting it would be
indeed a way to fix the issue for old kernels.
