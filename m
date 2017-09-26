From: Paul Burton <paul.burton@imgtec.com>
Subject: Re: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Tue, 26 Sep 2017 14:30:33 -0700
Message-ID: <1752163.uYYNevmZpH@np-p-burton>
References: <587dc9a8-b974-e222-95b4-93c2a8f2aba2@imgtec.com> <71740323.RRBhnhefTi@np-p-burton> <20170926.133309.1916643567158187651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart6054573.djc1BQoO6N";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Cc: <matt.redfearn@imgtec.com>, <netdev@vger.kernel.org>,
        <alexandre.torgue@st.com>, <peppe.cavallaro@st.com>,
        <linux-kernel@vger.kernel.org>, <linux-mips@linux-mips.org>,
        <james.hogan@imgtec.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926.133309.1916643567158187651.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6054573.djc1BQoO6N
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi David,

On Tuesday, 26 September 2017 13:33:09 PDT David Miller wrote:
> From: Paul Burton <paul.burton@imgtec.com>
> Date: Tue, 26 Sep 2017 11:48:19 -0700
> 
> >> The device writes into only the bytes it was given access to, which
> >> starts at the DMA address.
> > 
> > OK - still fine but *only* if we don't write to anything that happens to
> > be
> > part of the cache lines that are only partially covered by the DMA mapping
> > & make them dirty. If we do then any writeback of those lines will
> > clobber data the device wrote, and any invalidation of them will discard
> > data the CPU wrote.
> > 
> > How would you have us ensure that such writes don't occur?
> > 
> > This really does not feel to me like something to leave up to drivers
> > without any means of checking or enforcing correctness. The requirement
> > to align DMA mappings at cache-line boundaries, as outlined in
> > Documentation/DMA-API.txt, allows this to be enforced. If you want to
> > ignore this requirement then there is no clear way to verify that we
> > aren't writing to cache lines involved in a DMA transfer whilst the
> > transfer is occurring, and no sane way to handle those cache lines if we
> > do.
> 
> The memory immediately before skb->data and immediately after
> skb->data+skb->len will not be accessed.  This is guaranteed.

This guarantee is not made known to the DMA API or the per-arch code backing 
it, nor can I see it documented anywhere. It's good to hear that it exists in 
some form though.

> I will request something exactly one more time to give you the benfit
> of the doubt that you want to show me why this is _really_ a problem
> and not a problem only in theory.

My previous message simply walked through your existing example & explained 
why your assumptions can be incorrect as far as the DMA API & interactions 
with caches go - I don't think that warrants the seemingly confrontational 
tone.

> Please show me an exact sequence, with current code, in a current driver
> that uses the DMA API properly, where corruption really can occur.

How about this:

  https://patchwork.kernel.org/patch/9423097/

Now this isn't networking code at fault, it was a problem with MMC. Given that 
you say there's a guarantee that networking code won't write to cache lines 
that partially include memory mapped for DMA, perhaps networking code is 
immune to this issue (though at a minimum I think that guarantee ought to be 
documented so that others know to keep it true).

The question remains though: what would you have us do to catch the broken 
uses of the DMA API with non-cacheline-aligned memory? By not obeying 
Documentation/DMA-API.txt you're preventing us from adding checks that catch 
others who also disobey the alignment requirement in ways that are not fine, 
and which result in otherwise difficult to track down memory corruption.

> The new restriction is absolutely not reasonable for this use case.
> It it furthermore impractical to require the 200+ drivers the use this
> technique to allocate and map networking buffers to abide by this new
> rule.  Many platforms with even worse cache problems that MIPS handle
> this just fine.
> 
> Thank you.

One disconnect here is that you describe a "new restriction" whilst the 
restriction we're talking about has been documented in Documentation/DMA-
API.txt since at least the beginning of the git era - it is not new at all.

The only thing that changed for us that I have intended to warn when the 
restriction is not met, because that often indicates genuine & otherwise 
difficult to detect bugs such as the MMC one I linked to above. FYI that 
warning has not gone into mainline yet anyway.

I'd suggest that at a minimum if you're unwilling to obey the API as described 
in Documentation/DMA-API.txt then it would be beneficial if you could propose 
a change to it such that it works for you, and perhaps we can extend the API & 
its documentation to allow your usage whilst also allowing us to catch broken 
uses.

Surely we can agree that the current situation wherein networking code clearly 
disobeys the documented API is not a good one, and that allowing other broken 
uses to slip by unnoticed except in rare difficult to track down corner cases 
is not good either.

Thanks,
    Paul
--nextPart6054573.djc1BQoO6N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEELIGR03D5+Fg+69wPgiDZ+mk8HGUFAlnKxvkACgkQgiDZ+mk8
HGWhfQ/+InIji/lEeAsZc85Oflp79+mWdmTAxBisZT14SdOQyPZJrkfVx0B3DX/N
fXOCTGeWYO2mvzLj3t/7TYnPyVRML+9VS5uM41f69y9610YRTwIRVjsPfVQa1Nky
kOIs1F+KEDx8OM4MI0zyN7WHSC7zsmqs2YHaC/clwxPNLYUT7OBfH+RTUtu89x/P
dR4nyGf1qLm04+oFzvy27LAuP7N7hpwGMAXd9p5PMAmasaa0KzcjlgddaCET09Ui
oD3ZrlVkYRSbV7lbiaCsvJiedpxVXg+W50EBdeF6U5eVngN6K7TGiLs0qSY6RKXF
ypdN9Ww06PG2SZo3Th/QtJfea+wvhWLXmEbSvi7xfU1LWvZA0mQJHFaDewk3iPG2
xqpWZt1lP/bI7cZfTYNOW0wlypTzSKyLQtOzmH8vkjKBhi3hpThlxlCWWXtXy6tB
cBDPGxzhuD8BiBriVS0z0v86WsiV6trTIImoVI03+dYeVByJGLIn7GRHlt3VrifL
QoP0NrnCn8VEbKfPqKaJsiEIO5zXvGRgcTP7dbP6CE71jSd707hd3Sa1eHxd0P8P
NUymbzKjTQ5wMVtSvUDhIu8ITwZW9B3kvyLAomWWc+rddezzTao/q8nlVnkH/yZe
4miKUrLljCaG5hqqzLfj2NmaCX0zvBZrIh64Tyz6k2BIErRDWlQ=
=ss+F
-----END PGP SIGNATURE-----

--nextPart6054573.djc1BQoO6N--
