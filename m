From: Robin Murphy <robin.murphy@arm.com>
Subject: Re: [PATCH 11/22] net: thunder_bgx: avoid format string overflow
 warning
Date: Fri, 14 Jul 2017 13:33:28 +0100
Message-ID: <b741f219-c025-db9a-81ce-3c8e5ab33310@arm.com>
References: <20170714120720.906842-1-arnd@arndb.de>
 <20170714120720.906842-12-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: George Cherian <george.cherian@cavium.com>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        linux-scsi@vger.kernel.org,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        x86@kernel.org,
        Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
        Vadim Lomovtsev <Vadim.Lomovtsev@caviumnetworks.com>,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        Thanneeru Srinivasulu <tsrinivasulu@cavium.com>,
        akpm@linux-foundation.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        Guenter Roeck <linux@roeck-us.net>
To: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
        Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:47746 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753486AbdGNMdd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Jul 2017 08:33:33 -0400
In-Reply-To: <20170714120720.906842-12-arnd@arndb.de>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/07/17 13:07, Arnd Bergmann wrote:
> gcc warns that the temporary buffer might be too small here:
> 
> drivers/net/ethernet/cavium/thunder/thunder_bgx.c: In function 'bgx_probe':
> drivers/net/ethernet/cavium/thunder/thunder_bgx.c:1020:16: error: '%d' directive writing between 1 and 10 bytes into a region of size between 9 and 11 [-Werror=format-overflow=]
> sprintf(str, "BGX%d LMAC%d mode", bgx->bgx_id, lmacid);
>              ^~~~~~~~~~~~~~~~~~~
> drivers/net/ethernet/cavium/thunder/thunder_bgx.c:1020:16: note: directive argument in the range [0, 2147483647]
> drivers/net/ethernet/cavium/thunder/thunder_bgx.c:1020:3: note: 'sprintf' output between 16 and 27 bytes into a destination of size 20
> 
> This probably can't happen, but it can't hurt to make it long
> enough for the theoretical limit.

Probably indeed - both bgx_id and lmacid are u8 here, which would make
the maximum length of that string, including null terminator, exactly 20
characters.

So in this case the warning is not only silly, it's actively wrong;
sure, the arguments themselves are being promoted to ints at that point,
but GCC *knows* the original type, or it couldn't have generated the
correct code for the call :/

Robin.

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> index a0ca68ce3fbb..79112563a25a 100644
> --- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> +++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
> @@ -1008,7 +1008,7 @@ static void bgx_print_qlm_mode(struct bgx *bgx, u8 lmacid)
>  {
>  	struct device *dev = &bgx->pdev->dev;
>  	struct lmac *lmac;
> -	char str[20];
> +	char str[27];
>  
>  	if (!bgx->is_dlm && lmacid)
>  		return;
> 
