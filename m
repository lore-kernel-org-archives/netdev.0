From: Jeroen Hofstee <jhofstee@victronenergy.com>
Subject: Re: [PATCH v2] net: cpsw: fix obtaining mac address for am3517
Date: Fri, 28 Oct 2016 20:17:44 +0200
Message-ID: <d8ad5cab-5183-cddf-fa9a-4e7b9b8c9377@victronenergy.com>
References: <1477668756-2651-1-git-send-email-jhofstee@victronenergy.com>
 <20161028155213.2t3nwwe3lqaynaer@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>,
        "Grygorii Strashko" <grygorii.strashko@ti.com>,
        "open list:TI ETHERNET SWITCH DRIVER (CPSW)"
        <linux-omap@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0096.outbound.protection.outlook.com ([104.47.2.96]:26784
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S941632AbcJ1ScZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 14:32:25 -0400
In-Reply-To: <20161028155213.2t3nwwe3lqaynaer@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tony,

On 28-10-16 17:52, Tony Lindgren wrote:
> * Jeroen Hofstee <jhofstee@victronenergy.com> [161028 08:33]:
>> Commit b6745f6e4e63 ("drivers: net: cpsw: davinci_emac: move reading mac
>> id to common file") did not only move the code for an am3517, it also
>> added the slave parameter, resulting in an invalid (all zero) mac address
>> being returned for an am3517, since it only has a single emac and the slave
>> parameter is pointing to the second. So simply always read the first and
>> valid mac-address for a ti,am3517-emac.
> And others davinci_emac.c users can have more than one. So is the
> reason the slave parameter points to the second instance because
> of the location in the hardware?

Sort of, the slave parameter gets determined by the fact if there is one
or two register range(s) associated with the davinci_emac. In davinci_emac.c

     res_ctrl = platform_get_resource(pdev, IORESOURCE_MEM, 1);
     ...
     rc = davinci_emac_try_get_mac(pdev, res_ctrl ? 0 : 1,
                           priv->mac_addr);

So it there are two ranges, the slave param becomes 0. It there is only 
one, it
will be 1. Since the am3517 only has a single regs entry it ends up with 
slave 1,
while there is only a single davinci_emac.

Regards,
Jeroen

arch/arm/boot/dts/dm816x.dtsi
-----------------------------
eth0: ethernet@4a100000 {
     compatible = "ti,dm816-emac";
     ti,hwmods = "emac0";
     reg = <0x4a100000 0x800
            0x4a100900 0x3700>;
     clocks = <&sysclk24_ck>;
     syscon = <&scm_conf>;
     ti,davinci-ctrl-reg-offset = <0>;
     ti,davinci-ctrl-mod-reg-offset = <0x900>;
     ti,davinci-ctrl-ram-offset = <0x2000>;
     ti,davinci-ctrl-ram-size = <0x2000>;
     interrupts = <40 41 42 43>;
     phy-handle = <&phy0>;
};

eth1: ethernet@4a120000 {
     compatible = "ti,dm816-emac";
     ti,hwmods = "emac1";
     reg = <0x4a120000 0x4000>;
     clocks = <&sysclk24_ck>;
     syscon = <&scm_conf>;
     ti,davinci-ctrl-reg-offset = <0>;
     ti,davinci-ctrl-mod-reg-offset = <0x900>;
     ti,davinci-ctrl-ram-offset = <0x2000>;
     ti,davinci-ctrl-ram-size = <0x2000>;
     interrupts = <44 45 46 47>;
     phy-handle = <&phy1>;
};

arch/arm/boot/dts/am3517.dtsi
-------------------------------
davinci_emac: ethernet@0x5c000000 {
     compatible = "ti,am3517-emac";
     ti,hwmods = "davinci_emac";
     status = "disabled";
     reg = <0x5c000000 0x30000>;
     interrupts = <67 68 69 70>;
     syscon = <&scm_conf>;
     ti,davinci-ctrl-reg-offset = <0x10000>;
     ti,davinci-ctrl-mod-reg-offset = <0>;
     ti,davinci-ctrl-ram-offset = <0x20000>;
     ti,davinci-ctrl-ram-size = <0x2000>;
     ti,davinci-rmii-en = /bits/ 8 <1>;
     local-mac-address = [ 00 00 00 00 00 00 ];
};
