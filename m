From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net v4 1/2] sfc: use 64-bit writes for PIO.
Date: Tue, 03 Jun 2014 10:55:23 -0700
Message-ID: <1401818123.18833.17.camel@joe-AO725>
References: <538D9D1E.3090608@solarflare.com>
	 <538D9DB3.4080905@solarflare.com> <538DFBAF.2030703@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shradha Shah <sshah@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0198.hostedemail.com ([216.40.44.198]:40068 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751607AbaFCRz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 13:55:26 -0400
In-Reply-To: <538DFBAF.2030703@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-03 at 20:45 +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 06/03/2014 02:04 PM, Shradha Shah wrote:
> 
> > From: Jon Cooper <jcooper@solarflare.com>
> 
> > Patch to open-code the memory copy routines.
> > 32bit writes over the PCI bus causes data corruption.
> 
> > Fixes:ee45fd92c739
> > ("sfc: Use TX PIO for sufficiently small packets")
> 
> > Signed-off-by: Shradha Shah <sshah@solarflare.com>
> > ---
> >   drivers/net/ethernet/sfc/tx.c | 24 +++++++++++++++++++-----
> >   1 file changed, 19 insertions(+), 5 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
> > index fa94753..d2c9ca0 100644
> > --- a/drivers/net/ethernet/sfc/tx.c
> > +++ b/drivers/net/ethernet/sfc/tx.c
> > @@ -189,6 +189,20 @@ struct efx_short_copy_buffer {
> >   	u8 buf[L1_CACHE_BYTES];
> >   };
> >
> > +/* Copy in explicit 64-bit writes. */
> > +static void efx_memcpy_64(void __iomem *dest, void *src, size_t len)
> > +{
> > +	u64 *src64 = src, __iomem *dest64 = dest;
> > +	size_t i, l64 = len / 8;
> > +
> > +	WARN_ON_ONCE(len % 8 != 0);
> > +	WARN_ON_ONCE(((u8 __iomem *)dest - (u8 __iomem *)0) % 8 != 0);
> > +	BUILD_BUG_ON(sizeof(uint64_t) != 8);
> > +
> > +	for (i = 0; i < l64; ++i)
> > +		writeq(src64[i], dest64+i);
> 
>     Could you please surround + by spaces for consistency?
> 
> > +}
> > +

The BUILD_BUG_ON seems unnecessary.
The separate WARN_ON_ONCEs could be combined.
The subtraction of 0 just seems odd.

Would this be clearer as:

static void efx_memcpy_64(void __iomem *dest, void *src, size_t len)
{
	u64 *src64 = src,
	u64 __iomem *dest64 = dest;
	size_t l64 = len / 8;
	size_t i;

	WARN_ON_ONCE(len % 8 || dest64 % 8);

	for (i = 0; i < l64; i++)
		writeq(src64[i], &dest64[i]);
 }
