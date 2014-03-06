From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [Bug] net/fec on i.MX28: promiscuous mode lost after reconnecting
 network cable
Date: Thu, 6 Mar 2014 07:30:34 -0300
Message-ID: <CAOMZO5B-1koJdQRdE7SQU07K9McZZaiPAa+rookdxVL5vvPJvA@mail.gmail.com>
References: <5318400C.8060508@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Shawn Guo <shawn.guo@linaro.org>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Duan Fugang-B38611 <B38611@freescale.com>,
	Sascha Hauer <kernel@pengutronix.de>
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f181.google.com ([209.85.220.181]:60016 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbaCFKaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 05:30:35 -0500
Received: by mail-vc0-f181.google.com with SMTP id lg15so2327519vcb.26
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 02:30:34 -0800 (PST)
In-Reply-To: <5318400C.8060508@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding some more folks on Cc.

On Thu, Mar 6, 2014 at 6:29 AM, Stefan Wahren <stefan.wahren@i2se.com> wrote:
> Hello,
>
> i'm using a i.MX28 custom board (I2SE Duckbill) with 2 different Ethernet
> interfaces. Both interfaces should be used as bridge using bridge utils. One
> Ethernet interface is the buildin fec and the other is connect by spi. The
> board runs under Linux mainline 3.10. But the following problem still occurs
> on 3.14-rc4.
>
> Here is the problem, if i disconnect and reconnect the Ethernet cable on the
> buildin fec (eth0), the bridge says the port comes up, but it doesn't work.
> After that any traffic to the fec is okay, but traffic "through" the bridge
> is lost. But i expect no traffic is lost, after reconnect the network cable.
>
> If i reset the board without disconnecting the cables, the traffic "through"
> the bridge works. If i force the promiscuous mode on the fec (eth0) after
> the reconnect, the bridge works too:
>
> ifconfig eth0 promisc
>
> After that, i made some research and probably found the cause of the
> problem. In the case that the bridge works (link state connected since
> reboot) the register HW_ENET_MAC_RCR of the i.MX28 returns 0x45EE011C
> (PROM=1, promiscuous mode on). Then I disconnect the ethernet cable and
> reconnect it. After that the register returns 0x45EE0114 (PROM=0,
> promiscuous mode off) and the bridge doesn't work.
>
> Based on this information, i created a patch against Linux 3.10. I'm not
> sure it's a good solution but it works. After a fec reset all register
> values of HW_ENET_MAC_RCR must be restored, but fec_restart do not handle
> them at all. So set_multicast_list is called after fec_restart to restore
> the promiscuous mode of the fec.
>
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index d48099f..cb6b66e 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1063,6 +1063,8 @@ static void fec_get_mac(struct net_device *ndev)
>
>  /*
> ------------------------------------------------------------------------- */
>
> +static void set_multicast_list(struct net_device *ndev);
> +
>  /*
>   * Phy section
>   */
> @@ -1093,8 +1095,10 @@ static void fec_enet_adjust_link(struct net_device
> *ndev)
>          }
>
>          /* if any of the above changed restart the FEC */
> -        if (status_change)
> +        if (status_change) {
>              fec_restart(ndev, phy_dev->duplex);
> +            set_multicast_list(ndev);
> +        }
>      } else {
>          if (fep->link) {
>              fec_stop(ndev);
>
> Is this solution correct?
>
> Do you need more information?
>
> Best regards
> Stefan Wahren
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
