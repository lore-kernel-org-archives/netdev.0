From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH] gianfar: prevent fragmentation in DSA environments
Date: Fri, 19 Aug 2016 18:43:49 +0200
Message-ID: <c1cda2ea-21e8-0265-e1c3-687f2396a7f1@neratec.com>
References: <1471598174-16938-1-git-send-email-zefir.kurtisi@neratec.com>
 <20160819145900.GD7343@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:18610 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751599AbcHSQnx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 12:43:53 -0400
In-Reply-To: <20160819145900.GD7343@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2016 04:59 PM, Andrew Lunn wrote:
> On Fri, Aug 19, 2016 at 11:16:14AM +0200, Zefir Kurtisi wrote:
>> The eTSEC register MRBLR defines the maximum space in
>> the RX buffers and is set to 1536 by gianfar. This
>> reasonably covers the common use case where the MTU
>> is kept at default 1500.
>>
>> Alas, if the eTSEC is attached to a DSA enabled switch,
>> the DSA header extension causes every maximum sized
>> frame to be fragmented by the hardware (1536 + 4).
>>
>> This patch increases the maximum RX buffer size by
>> RBUF_ALIGNMENT (64) octets. Since the driver uses a
>> half-page memory schema, this change does not
>> increase allocated memory but allows the hardware to
>> use 1600 bytes of the totally available 2048.
>>
>> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
>> ---
>>  drivers/net/ethernet/freescale/gianfar.h | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
>> index 373fd09..02b794b 100644
>> --- a/drivers/net/ethernet/freescale/gianfar.h
>> +++ b/drivers/net/ethernet/freescale/gianfar.h
>> @@ -100,7 +100,8 @@ extern const char gfar_driver_version[];
>>  #define DEFAULT_RX_LFC_THR  16
>>  #define DEFAULT_LFC_PTVVAL  4
>>  
>> -#define GFAR_RXB_SIZE 1536
>> +/* prevent fragmenation by HW in DSA environments */
>> +#define GFAR_RXB_SIZE (1536 + RXBUF_ALIGNMENT)
> 
> Hi Zefir
> 
> Using RXBUF_ALIGNMENT suggests this has something to do with
> alignment, not extra headers.
> 
> How about
> 
> /* Prevent fragmenation by HW when using extra headers like DSA */
> #define GFAR_RXB_SIZE (1536 + 8)
> 
> 	Andrew
> 
Hi Andrew,

the MRBLR has to be written with multiples of 64 (lower 6 bits reserved as 0),
therefore (1536 + 64) is the next valid value to chose.

As noted in the commit message, this is an artificial limitation, since the RX
buffers are essentially 2048 bytes (GFAR_RXB_TRUESIZE) long. I don't fully
understand why GFAR_RXB_SIZE has to be lower than that, preventing
the HW using all available memory - the freescale guys most probably do.


Cheers,
Zefir
