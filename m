From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: use %*ph[C] to dump small buffers
Date: Thu, 27 Sep 2012 20:13:43 -0700
Message-ID: <1348802023.3030.11.camel@joe-AO722>
References: <1348667852-5957-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1348677946.15175.8.camel@joe-AO722> <5064D318.6090705@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5064D318.6090705-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-09-27 at 17:28 -0500, Larry Finger wrote:
> On 09/26/2012 11:45 AM, Joe Perches wrote:
> > rate_mask uses:
> >
> > 	u32 ratr_bitmap = (u32) mac->basic_rates;
> > ...
> > 	u8 rate_mask[5];
> > ...
> > 	[sets ratr_bitmap as u32]
> > ...
> > 	*(u32 *)&rate_mask = ((ratr_bitmap & 0x0fffffff) |
> > 				      ratr_index << 28);
> > ...
> > 	rtl92c_fill_h2c_cmd(hw, H2C_RA_MASK, 5, rate_mask);
> >
> > Looks like a possible endian misuse to me.
> 
> After a second look at the code, I don't think this is an endian issue; however, 
> I am proposing the following changes to remove any doubt:

I believe if it wasn't an endian problem, then the new
code makes it one.

> Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> ===================================================================
> --- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> +++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
> @@ -1964,8 +1965,9 @@ static void rtl92ce_update_hal_rate_mask
> 
>          RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
>                   "ratr_bitmap :%x\n", ratr_bitmap);
> -       *(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) |
> -                                    (ratr_index << 28);
> +       for (i = 0; i < 3; i++)
> +               rate_mask[i] = ratr_bitmap & (0xff << (i * 4));

rate_mask is u8, doesn't this needs (calc) >> (i * 8)

> +       rate_mask[3] = (ratr_bitmap & 0x0f000000) | (ratr_index << 28);

Perhaps you meant:

		((ratr_bitmap & 0x0f000000) >> 24) | (ratr_index << 4)

>          rate_mask[4] = macid | (shortgi ? 0x20 : 0x00) | 0x80;
>          RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
>                   "Rate_index:%x, ratr_val:%x, %*phC\n",
> 
> The downstream routine uses this info as an array of u8, thus it is OK. A proper 
> patch will be sent later. At least we avoid that ugly cast.



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
