From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: use %*ph[C] to dump small buffers
Date: Fri, 28 Sep 2012 11:41:19 -0500
Message-ID: <5065D32F.9090107@lwfinger.net>
References: <1348667852-5957-1-git-send-email-andriy.shevchenko@linux.intel.com> <1348677946.15175.8.camel@joe-AO722> <5064D318.6090705@lwfinger.net> <1348802023.3030.11.camel@joe-AO722> <AE90C24D6B3A694183C094C60CF0A2F6026B700D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B700D-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/28/2012 04:04 AM, David Laight wrote:
>>> Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
>>> ===================================================================
>>> --- wireless-testing-new.orig/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
>>> +++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
>>> @@ -1964,8 +1965,9 @@ static void rtl92ce_update_hal_rate_mask
>>>
>>>           RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
>>>                    "ratr_bitmap :%x\n", ratr_bitmap);
>>> -       *(u32 *)&rate_mask = (ratr_bitmap & 0x0fffffff) |
>>> -                                    (ratr_index << 28);
>>> +       for (i = 0; i < 3; i++)
>>> +               rate_mask[i] = ratr_bitmap & (0xff << (i * 4));
>>
>> rate_mask is u8, doesn't this needs (calc) >> (i * 8)
>>
>>> +       rate_mask[3] = (ratr_bitmap & 0x0f000000) | (ratr_index << 28);
>>
>> Perhaps you meant:
>>
>> 		((ratr_bitmap & 0x0f000000) >> 24) | (ratr_index << 4)
>
> I'd just do:
> 	rate_mask[0] = ratr_bitmap;
> 	rate_mask[1] = ratr_bitmap >>= 8;
> 	rate_mask[2] = ratr_bitmap >>= 8;
> 	rate_mask[3] = (ratr_bitmap >> 8) & 0xf | ratr_index << 4;
> which is, of course, little endian.
> Which means it is different from the original code on big-endian systems.
> So changing this here ought to require a change when the data is read.
> So this either fixes, or adds, an endianness bug.

Yes, the rate_mask array is little endian after this fragment is run, but the 
only use of the byte array is to write it to the device, and LE is what it needs 
no matter the platform. This change fixes an endianness bug.

As I tend to get confused when doing these things, I wrote a small test program 
and ran it on x86_64 and PPC-32 to confirm the result.

Thanks for teaching me about a = b >>= 8. I was not aware that C could do that.

Larry


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
