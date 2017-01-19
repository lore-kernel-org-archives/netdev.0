From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] rtlwifi: rtl8192x: Enabling and disabling hardware
 interrupts after enabling local irq flags
Date: Thu, 19 Jan 2017 15:35:38 +0100
Message-ID: <trinity-12e38a0e-85af-457b-9d4e-3c40ab1f6fd1-1484836538110@3capp-gmx-bs75>
References: <1484820854-16719-1-git-send-email-bharatku@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        kvalo@codeaurora.org, netdev@vger.kernel.org, rgummal@xilinx.com,
        "Bharat Kumar Gogada" <bharatku@xilinx.com>
To: "Bharat Kumar Gogada" <bharat.kumar.gogada@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484820854-16719-1-git-send-email-bharatku@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

altek/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
> index a47be73..143766c4 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ce/hw.c
> @@ -1306,9 +1306,9 @@ void rtl92ce_enable_interrupt(struct ieee80211_hw *hw)
>  	struct rtl_priv *rtlpriv = rtl_priv(hw);
>  	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
>  
> +	rtlpci->irq_enabled = true;
>  	rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
>  	rtl_write_dword(rtlpriv, REG_HIMRE, rtlpci->irq_mask[1] & 0xFFFFFFFF);
> -	rtlpci->irq_enabled = true;
>  }
>  
>  void rtl92ce_disable_interrupt(struct ieee80211_hw *hw)
> @@ -1316,9 +1316,9 @@ void rtl92ce_disable_interrupt(struct ieee80211_hw *hw)
>  	struct rtl_priv *rtlpriv = rtl_priv(hw);
>  	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
>  
> +	rtlpci->irq_enabled = false;
>  	rtl_write_dword(rtlpriv, REG_HIMR, IMR8190_DISABLED);
>  	rtl_write_dword(rtlpriv, REG_HIMRE, IMR8190_DISABLED);
> -	rtlpci->irq_enabled = false;
>  }
>  

AFAIK you also have to use memory barriers here to ensure that
the concerning instructions are not reordered, and both irq handler
and process have a consistent perception of irq_enabled, e.g:

rtlpci->irq_enabled = true;
smp_wmb();
rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);

and in the irq handler

if (rtlpci->irq_enabled == 0) {
        smp_rmb();
	return ret;
}


Regards,
Lino
