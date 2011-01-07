From: Ben Hutchings <benh@debian.org>
Subject: Re: [PATCH] net/r8169: Update the function of parsing firmware
Date: Fri, 7 Jan 2011 15:17:55 +0000
Message-ID: <20110107151755.GN3702@decadent.org.uk>
References: <1294393509-3492-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1294393509-3492-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-01-07 at 17:45 +0800, Hayes Wang wrote:
> Update rtl_phy_write_fw function. The new function could
> parse the complex firmware which is used by RTL8111E and later.
> The new firmware may read data and do some operations, not just
> do writing only.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/r8169.c |  112 ++++++++++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 97 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 27a7c20..2115424 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
[...] 
> -	while (i-- != 0) {
> -		u32 action = le32_to_cpu(*phytable);
> -		u32 data = action & 0x0000ffff;
> -		u32 reg = (action & 0x0fff0000) >> 16;
> +	predata = 0;
> +	count = 0;
> +
> +	for (index = 0; index < fw->size / sizeof(*phytable); ) {
> +		u32 action = le32_to_cpu(phytable[index]);
> +		u32 data = action & 0x0000FFFF;
> +		u32 regno = (action & 0x0FFF0000) >> 16;
> +
> +		if (!action)
> +			break;
>  
> -		switch(action & 0xf0000000) {
> +		switch(action & 0xF0000000) {
[...]
> +		case PHY_BJMPN:
> +			index -= regno;
> +			break;
[...]

I'm concerned that this is being extended from a firmware upload
interface to a quite general interpreter for PHY initialisation.  I
realise that this will make it easier to fix PHY firmware bugs in
future but it also allows you to accidentally introduce infinite loops.
The initialisation programs will obviously not be subject to the same
sort of review on netdev that new C code is.

> +		case PHY_DELAY_MS:
> +			mdelay(data);
> +			index++;
> +			break;

Why mdelay() and not msleep()?  This is not an atomic context.

> +		case PHY_READ_MAC_BYTE:
> +		case PHY_WRITE_MAC_BYTE:
> +		case PHY_WRITE_ERI_WORD:
>  		default:
>  			BUG();
>  		}
> +
> +		if (index < 0)
> +			BUG();
[...]

index is unsigned so it can't be < 0.  It looks like the loop condition
should catch an out-of-range index, but really the range-checking should
be done in the first loop.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
