From: Vincent Palatin <vpalatin@chromium.org>
Subject: Re: net: stmmac: dwmac-rk: fixes for Wake-on-Lan on RK3288
Date: Wed, 15 Jun 2016 10:04:06 -0700
Message-ID: <CAP_ceTwbrx0vO8ufMO_SiwXFAxv5OUuQaYYS27gNqPTR6kRXyQ@mail.gmail.com>
References: <bd302fc6-feae-b99a-4632-a0ff9ead0123@st.com> <1465606839-7722-1-git-send-email-vpalatin@chromium.org>
 <3d278dd6-0b61-f618-b723-52f9c302c999@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Douglas Anderson <dianders@chromium.org>,
	=?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>,
	Shunqian Zheng <zhengsq@rock-chips.com>,
	David Miller <davem@davemloft.net>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34312 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbcFORE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 13:04:28 -0400
Received: by mail-io0-f174.google.com with SMTP id 5so26683633ioy.1
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 10:04:28 -0700 (PDT)
In-Reply-To: <3d278dd6-0b61-f618-b723-52f9c302c999@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 12, 2016 at 11:46 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> On 6/11/2016 3:00 AM, Vincent Palatin wrote:
>>
>> In order to support Wake-On-Lan when using the RK3288 integrated MAC
>> (with an external RGMII PHY), we need to avoid shutting down the regulator
>> of the external PHY when the MAC is suspended as it's currently done in
>> the MAC
>> platform code.
>> As a first step, create independant callbacks for suspend/resume rather
>> than
>> re-using exit/init callbacks. So the dwmac platform driver can behave
>> differently
>> on suspend where it might skip shutting the PHY and at module unloading.
>> Then update the dwmac-rk driver to switch off the PHY regulator only if we
>> are
>> not planning to wake up from the LAN.
>> Finally add the PMT interrupt to the MAC device tree configuration, so we
>> can
>> wake up the core from it when the PHY has received the magic packet.
>
>
> IMO these could be sent for net-next and also other glue logic
> files should be reworked in order to use the new API for coherence.

Given they will have the same set of functions for exit/init and
suspend/resume, you mean duplicating the callbacks like this :
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -359,6 +359,8 @@ static int sti_dwmac_probe(struct platform_device *pdev)
        plat_dat->bsp_priv = dwmac;
        plat_dat->init = sti_dwmac_init;
        plat_dat->exit = sti_dwmac_exit;
+       plat_dat->suspend = sti_dwmac_exit;
+       plat_dat->resume = sti_dwmac_init;
        plat_dat->fix_mac_speed = data->fix_retime_src;

        ret = sti_dwmac_init(pdev, plat_dat->bsp_priv);

Is this anyhow useful ?

-- 
Vincent
