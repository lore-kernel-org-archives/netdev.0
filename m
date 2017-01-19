From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: rtl8192x: Enabling and disabling hardware
 interrupts after enabling local irq flags
Date: Thu, 19 Jan 2017 12:08:34 -0600
Message-ID: <294d2858-2554-1b51-3142-b0470423537a@lwfinger.net>
References: <1484820854-16719-1-git-send-email-bharatku@xilinx.com>
 <trinity-12e38a0e-85af-457b-9d4e-3c40ab1f6fd1-1484836538110@3capp-gmx-bs75>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rgummal-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
        Bharat Kumar Gogada <bharatku-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>,
        Bharat Kumar Gogada <bharat.kumar.gogada-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <trinity-12e38a0e-85af-457b-9d4e-3c40ab1f6fd1-1484836538110@3capp-gmx-bs75>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/19/2017 08:35 AM, Lino Sanfilippo wrote:
> Hi,
>
> altek/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
>> index a47be73..143766c4 100644
>> --- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
>> +++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
>> @@ -1306,9 +1306,9 @@ void rtl92ce_enable_interrupt(struct ieee80211_hw *hw)
>>  	struct rtl_priv *rtlpriv = rtl_priv(hw);
>>  	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
>>
>> +	rtlpci->irq_enabled = true;
>>  	rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
>>  	rtl_write_dword(rtlpriv, REG_HIMRE, rtlpci->irq_mask[1] & 0xFFFFFFFF);
>> -	rtlpci->irq_enabled = true;
>>  }
>>
>>  void rtl92ce_disable_interrupt(struct ieee80211_hw *hw)
>> @@ -1316,9 +1316,9 @@ void rtl92ce_disable_interrupt(struct ieee80211_hw *hw)
>>  	struct rtl_priv *rtlpriv = rtl_priv(hw);
>>  	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
>>
>> +	rtlpci->irq_enabled = false;
>>  	rtl_write_dword(rtlpriv, REG_HIMR, IMR8190_DISABLED);
>>  	rtl_write_dword(rtlpriv, REG_HIMRE, IMR8190_DISABLED);
>> -	rtlpci->irq_enabled = false;
>>  }
>>
>
> AFAIK you also have to use memory barriers here to ensure that
> the concerning instructions are not reordered, and both irq handler
> and process have a consistent perception of irq_enabled, e.g:
>
> rtlpci->irq_enabled = true;
> smp_wmb();
> rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
>
> and in the irq handler
>
> if (rtlpci->irq_enabled == 0) {
>         smp_rmb();
> 	return ret;
> }

I can see the potential race condition between setting interrupts and setting 
the flag, and I will likely accept Bharat's patch after testing.

I am likely displaying my ignorance regarding instruction reordering, but what 
compiler/cpu combination is likely to move a simple set operation after a call 
to an external routine? Is the smp_wmb() operation really needed? I am also 
unsure of the smp_rmb() call in the interrupt handler. Neither instruction 
should cause any problems, but I'm not sure they are needed.

Larry
