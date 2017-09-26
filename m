From: Paul Burton <paul.burton@imgtec.com>
Subject: Re: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Tue, 26 Sep 2017 11:48:19 -0700
Message-ID: <71740323.RRBhnhefTi@np-p-burton>
References: <1506078833-14002-1-git-send-email-matt.redfearn@imgtec.com> <587dc9a8-b974-e222-95b4-93c2a8f2aba2@imgtec.com> <20170926.103400.1009342814128022820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1593612.t0nK0YYSNi";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Cc: <matt.redfearn@imgtec.com>, <netdev@vger.kernel.org>,
        <alexandre.torgue@st.com>, <peppe.cavallaro@st.com>,
        <linux-kernel@vger.kernel.org>, <linux-mips@linux-mips.org>,
        <james.hogan@imgtec.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926.103400.1009342814128022820.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1593612.t0nK0YYSNi
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi David,

On Tuesday, 26 September 2017 10:34:00 PDT David Miller wrote:
> From: Matt Redfearn <matt.redfearn@imgtec.com>
> Date: Tue, 26 Sep 2017 14:57:39 +0100
> 
> > Since the MIPS architecture requires software cache management,
> > performing a dma_map_single(TO_DEVICE) will writeback and invalidate
> > the cachelines for the required region. To comply with (our
> > interpretation of) the DMA API documentation, the MIPS implementation
> > expects a cacheline aligned & sized buffer, so that it can writeback a
> > set of complete cachelines. Indeed a recent patch
> > (https://patchwork.linux-mips.org/patch/14624/) causes the MIPS dma
> > mapping code to emit warnings if the buffer it is requested to sync is
> > not cachline aligned. This driver, as is, fails this test and causes
> > thousands of warnings to be emitted.
> 
> For a device write, if the device does what it is told and does not
> access bytes outside of the periphery of the DMA mapping, nothing bad
> can happen.
> 
> When the DMA buffer is mapped, the cpu side cachelines are flushed (even
> ones which are partially part of the requsted mapping, this is _fine_).

This is not fine. Let's presume we writeback+invalidate the cache lines that 
are only partially covered by the DMA mapping at its beginning or end, and 
just invalidate all the lines that are wholly covered by the mapping. So far 
so good.

> The device writes into only the bytes it was given access to, which
> starts at the DMA address.

OK - still fine but *only* if we don't write to anything that happens to be 
part of the cache lines that are only partially covered by the DMA mapping & 
make them dirty. If we do then any writeback of those lines will clobber data 
the device wrote, and any invalidation of them will discard data the CPU 
wrote.

How would you have us ensure that such writes don't occur?

This really does not feel to me like something to leave up to drivers without 
any means of checking or enforcing correctness. The requirement to align DMA 
mappings at cache-line boundaries, as outlined in Documentation/DMA-API.txt, 
allows this to be enforced. If you want to ignore this requirement then there 
is no clear way to verify that we aren't writing to cache lines involved in a 
DMA transfer whilst the transfer is occurring, and no sane way to handle those 
cache lines if we do.

> The unmap and/or sync operation after the DMA transfer needs to do
> nothing on the cpu side since the map operation flushed the cpu side
> caches already.
> 
> When the cpu reads, it will pull the cacheline from main memory and
> see what the device wrote.

This is not true, because:

1) CPUs may speculatively read data. In between the invalidations that we did
   earlier & the point at which the transfer completes, the CPU may have
   speculatively read any arbitrary part of the memory mapped for DMA.

2) If we wrote to any lines that are only partially covered by the DMA mapping
   then of course they're valid & dirty, and an access won't fetch from main
   memory.

We therefore need to perform cache invalidation again at the end of the 
transfer - on MIPS you can grep for cpu_needs_post_dma_flush to find this. 
>From a glance ARM has similar post-DMA invalidation in 
__dma_page_dev_to_cpu(), ARM64 in __dma_unmap_area() etc etc.

At this point what would you have us do with cache lines that are only 
partially covered by the DMA mapping? As above - if we writeback+invalidate we 
risk clobbering data written by the device. If we just invalidate we risk 
discarding data written by the CPU. And this is even ignoring the risk that a 
writeback of one of these lines happens due to eviction during the DMA 
transfer, which we have no control over at all.

> It's not like the device can put "garbage" into the bytes earlier in
> the cacheline it was given partial access to.

Right - but the CPU can "put garbage" into the bytes the device was given 
access to, simply by fetching stale bytes from main memory before the device 
overwrites them.

> I really don't see what the problem is and why MIPS needs special
> handling.  You will have to give specific examples, step by step,
> where things can go wrong before I will be able to consider your
> changes.

MIPS doesn't need special handling - it just needs the driver to obey a 
documented restriction when using the DMA API. One could argue that it ought 
to be you who justifies why you feel networking drivers can ignore the 
documentation, and that if you disagree with the documented API you should aim 
to change it rather than ignore it.

Thanks,
    Paul
--nextPart1593612.t0nK0YYSNi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEELIGR03D5+Fg+69wPgiDZ+mk8HGUFAlnKoPMACgkQgiDZ+mk8
HGXqvxAAtN9mvTk0NIvzxT+Wb2lLAQ2fAz/3gFohPJe+nhLD/UQ2FCXerpnGIF2L
VLpP8hi5+yrnsyY0Kc2Y/Flm5OSAR7jn+fUhxbiZZfPANxZZj/pw6L2jwFQsuVLz
xTlA/vm5j4vbqvL3aEZtxZwQRt8r4JaXo4jqibvoUkxIhwmVkN9Dq8T+PJXL+bNw
5TMI5kg/Huv6bgDZA/1HrrVJSmBHoa4FV+zK29YzmhTQUTqejqTnQwRG8G9Bqril
mahjX5UdL6SxH+sXfQG71pcM3VyARAmQ+zhFTnSAdmaUlWXp+k7drcH8QpEM0jdS
z37BgPMqxjsSMMZUcBkyfZpMpuMNiOaSbABwM41Aut19ioqF32KX1L/zpdJGdT/W
rJcA1mcr2hSAatGMecn5Km1jiKLQ0DFkJ0RS1BozWVIwUGvW514ZeZ5qXlRdc1cG
kUA7U+ypj3QJlCr6Myr7/xscGLAaRPk6FD4h87U+Sk5zEwTFWk+9Fnx/fkprCy8K
usw0m3qGbqHSr6ng4jiTAANtQIp8vZmXrJ/gBWGMkN6Vf15ciR8ExoaZ9hlHRJiw
ZsX1aTqLgwOSTEfocF9tu1bgp5BTqQJa6OFAzWdBQXgm6YnZ4meoEnmGUc9THKeG
4SQUTZLgFC8Kck5gVUSX28d1olGu4diQ8Fl3J7BGtwGoR4JRwKo=
=nA9f
-----END PGP SIGNATURE-----

--nextPart1593612.t0nK0YYSNi--
