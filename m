From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] rtlwifi: rtl8192x: Enabling and disabling hardware
 interrupts after enabling local irq flags
Date: Thu, 19 Jan 2017 23:13:12 +0100
Message-ID: <03a8a9e8-7a9e-b05e-97e5-32ab87be58ba@gmx.de>
References: <1484820854-16719-1-git-send-email-bharatku@xilinx.com>
 <trinity-12e38a0e-85af-457b-9d4e-3c40ab1f6fd1-1484836538110@3capp-gmx-bs75>
 <294d2858-2554-1b51-3142-b0470423537a@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chaoming_li@realsil.com.cn, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org, kvalo@codeaurora.org,
        netdev@vger.kernel.org, rgummal@xilinx.com,
        Bharat Kumar Gogada <bharatku@xilinx.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
        Bharat Kumar Gogada <bharat.kumar.gogada@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <294d2858-2554-1b51-3142-b0470423537a@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

On 19.01.2017 19:08, Larry Finger wrote:
> On 01/19/2017 08:35 AM, Lino Sanfilippo wrote:
>> Hi,
>>
>> altek/rtlwifi/rtl8192ce/hw.c 
>> b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
>>> index a47be73..143766c4 100644
>>> --- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
>>> +++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
>>> @@ -1306,9 +1306,9 @@ void rtl92ce_enable_interrupt(struct 
>>> ieee80211_hw *hw)
>>>      struct rtl_priv *rtlpriv = rtl_priv(hw);
>>>      struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
>>>
>>> +    rtlpci->irq_enabled = true;
>>>      rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 
>>> 0xFFFFFFFF);
>>>      rtl_write_dword(rtlpriv, REG_HIMRE, rtlpci->irq_mask[1] & 
>>> 0xFFFFFFFF);
>>> -    rtlpci->irq_enabled = true;
>>>  }
>>>
>>>  void rtl92ce_disable_interrupt(struct ieee80211_hw *hw)
>>> @@ -1316,9 +1316,9 @@ void rtl92ce_disable_interrupt(struct 
>>> ieee80211_hw *hw)
>>>      struct rtl_priv *rtlpriv = rtl_priv(hw);
>>>      struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
>>>
>>> +    rtlpci->irq_enabled = false;
>>>      rtl_write_dword(rtlpriv, REG_HIMR, IMR8190_DISABLED);
>>>      rtl_write_dword(rtlpriv, REG_HIMRE, IMR8190_DISABLED);
>>> -    rtlpci->irq_enabled = false;
>>>  }
>>>
>>
>> AFAIK you also have to use memory barriers here to ensure that
>> the concerning instructions are not reordered, and both irq handler
>> and process have a consistent perception of irq_enabled, e.g:
>>
>> rtlpci->irq_enabled = true;
>> smp_wmb();
>> rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
>>
>> and in the irq handler
>>
>> if (rtlpci->irq_enabled == 0) {
>>         smp_rmb();
>>     return ret;
>> }
>
> I can see the potential race condition between setting interrupts and 
> setting the flag, and I will likely accept Bharat's patch after testing.
>
> I am likely displaying my ignorance regarding instruction reordering, 
> but what compiler/cpu combination is likely to move a simple set 
> operation after a call to an external routine? Is the smp_wmb() 
> operation really needed?

I dont know if and when a specific compiler would actually do such a 
reordering. But the thing is, that you simply cant be sure
that it does not. As I wrote it is also not only reordering that could 
cause trouble, but also a different perception of the
flag value on different CPUs.
We guard against those issues in other drivers, too. See

http://lxr.free-electrons.com/source/drivers/net/ethernet/3com/typhoon.c#L1935

for example.

> I am also unsure of the smp_rmb() call in the interrupt handler. 
> Neither instruction should cause any problems, but I'm not sure they 
> are needed

The smp_rmb() is needed to ensure that the irq handler actually "sees" 
the most recent value of  irq_enabled even if the irq handler is
running on another CPU than the one that set this flag.

Regards,
Lino
