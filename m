From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 4/4] sh_eth: Fix serialisation of interrupt disable
 with interrupt & NAPI handlers
Date: Thu, 22 Jan 2015 16:50:37 +0300
Message-ID: <54C1002D.7090508@cogentembedded.com>
References: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk> <1421930648.1222.289.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	"David S.Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:58995 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbbAVNun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 08:50:43 -0500
Received: by mail-lb0-f175.google.com with SMTP id 10so410470lbg.6
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 05:50:41 -0800 (PST)
In-Reply-To: <1421930648.1222.289.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/22/2015 3:44 PM, Ben Hutchings wrote:

> In order to stop the RX path accessing the RX ring while it's being
> stopped or resized, we clear the interrupt mask (EESIPR) and then call
> free_irq() or synchronise_irq().  This is insufficient because the
> interrupt handler or NAPI poller may set EESIPR again after we clear
> it.

    Hm, how come the interrupt handler gets called when we have disabled all 
interrupts? Is it unmaskable EESR.ECI interrupt? BTW, I'm not seeing where the 
interrupt handler enables interrupts again; only NAPI poller does that AFAIK.

> Also, in sh_eth_set_ringparam() we currently don't disable NAPI
> polling at all.

> I could easily trigger a crash by running the loop:

>     while ethtool -G eth0 rx 128 && ethtool -G eth0 rx 64; do echo -n .; done

    Oh, never done any 'ethtool' tests...

> and 'ping -f' toward the sh_eth port from another machine.

To fix this:
> - Add a software flag (irq_enabled) to signal whether interrupts
>    should be enabled
> - In the interrupt handler, if the flag is clear then clear EESIPR
>    and return
> - In the NAPI poller, if the flag is clear then don't set EESIPR
> - Set the flag before enabling interrupts in sh_eth_dev_init() and
>    sh_eth_set_ringparam()
> - Clear the flag and serialise with the interrupt and NAPI
>    handlers before clearing EESIPR in sh_eth_close() and
>    sh_eth_set_ringparam()

> After this, I could run the loop for 100,000 iterations successfully.

> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>

[...]

> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> index 7bfaf1c..259d03f 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.h
> +++ b/drivers/net/ethernet/renesas/sh_eth.h
> @@ -513,6 +513,7 @@ struct sh_eth_private {
>   	u32 rx_buf_sz;			/* Based on MTU+slack. */
>   	int edmac_endian;
>   	struct napi_struct napi;
> +	bool irq_enabled;
>   	/* MII transceiver section. */
>   	u32 phy_id;			/* PHY ID */
>   	struct mii_bus *mii_bus;	/* MDIO bus control */

    In order to conserve space, I'd have added that field after 
'vlan_num_ids', just before the 1-bit fields...

WBR, Sergei
