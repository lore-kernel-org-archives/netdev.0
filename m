From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net/r8169: Update the function of parsing firmware
Date: Fri, 7 Jan 2011 12:44:39 +0100
Message-ID: <20110107114439.GA1830@electric-eye.fr.zoreil.com>
References: <1294393509-3492-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1294393509-3492-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
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
> @@ -1632,39 +1632,121 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
>  {
>  	__le32 *phytable = (__le32 *)fw->data;
>  	struct net_device *dev = tp->dev;
> -	size_t i;
> +	size_t index;

...

> +	u32 predata, count;
>  
>  	if (fw->size % sizeof(*phytable)) {
> -		netif_err(tp, probe, dev, "odd sized firmware %zd\n", fw->size);
> +		netif_err(tp, probe, dev, "odd sized firmware %zd\n",
> +			  fw->size);

It fits within 80 columns, please keep it as is.

>  		return;
>  	}
>  
> -	for (i = 0; i < fw->size / sizeof(*phytable); i++) {
> -		u32 action = le32_to_cpu(phytable[i]);
> +	for (index = 0; index < fw->size / sizeof(*phytable); index++) {
> +		u32 action = le32_to_cpu(phytable[index]);
>  
> -		if (!action)
> +		switch(action & 0xF0000000) {

Please don't add uppercase hex.

> +		case PHY_READ:
> +		case PHY_DATA_OR:
> +		case PHY_DATA_AND:
> +		case PHY_BJMPN:
> +		case PHY_READ_EFUSE:
> +		case PHY_CLEAR_READCOUNT:
> +		case PHY_WRITE:
> +		case PHY_READCOUNT_EQ_SKIP:
> +		case PHY_COMP_EQ_SKIPN:
> +		case PHY_COMP_NEQ_SKIPN:
> +		case PHY_WRITE_PREVIOUS:
> +		case PHY_SKIPN:
> +		case PHY_DELAY_MS:
>  			break;
[...]
> +	for (index = 0; index < fw->size / sizeof(*phytable); ) {
[...]
> +
> +		if (index < 0)
> +			BUG();

It could imho validate a bit harder.

-- 
Ueimor
