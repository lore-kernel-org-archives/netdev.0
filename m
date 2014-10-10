From: Angelo Dureghello <angelo70@gmail.com>
Subject: Re: [PATCH] phy/micrel: KSZ8031RNL RMII clock reconfiguration bug
Date: Fri, 10 Oct 2014 12:02:40 +0200
Message-ID: <5437AEC0.9010209@gmail.com>
References: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Bruno Thomsen <bth@kamstrup.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:49593 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbaJJKCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 06:02:47 -0400
Received: by mail-wi0-f170.google.com with SMTP id hi2so3824812wib.1
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 03:02:45 -0700 (PDT)
In-Reply-To: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I add some useful info:
there is a carrier change after phy is attached, but link state arrives 
as zero.

[root@xb ~]# cat /sys/class/net/eth0/carrier
carrier          carrier_changes
[root@xb ~]# cat /sys/class/net/eth0/carrier
0
[root@xb ~]# cat /sys/class/net/eth0/carrier_changes
1

Regards,
Angelo


On 09/10/2014 16:48, Bruno Thomsen wrote:
> Bug: Unable to send and receive Ethernet packets with Micrel PHY.
>
> Affected devices:
> KSZ8031RNL (commercial temp)
> KSZ8031RNLI (industrial temp)
>
> Description:
> PHY device is correctly detected during probe.
> PHY power-up default is 25MHz crystal clock input
> and output 50MHz RMII clock to MAC.
> Reconfiguration of PHY to input 50MHz RMII clock from MAC
> causes PHY to become unresponsive if clock source is changed
> after Operation Mode Strap Override (OMSO) register setup.
>
> Cause:
> Long lead times on parts where clock setup match circuit design
> forces the usage of similar parts with wrong default setup.
>
> Solution:
> Swapped KSZ8031 register setup and added phy_write return code validation.
>
> Tested with Freescale i.MX28 Fast Ethernet Controler (fec).
>
> Signed-off-by: Bruno Thomsen <bth@kamstrup.dk>
> ---
>   drivers/net/phy/micrel.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 011dbda..ec3f646 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -194,8 +194,10 @@ static int ksz8021_config_init(struct phy_device *phydev)
>   	if (rc)
>   		dev_err(&phydev->dev, "failed to set led mode\n");
>   
> -	phy_write(phydev, MII_KSZPHY_OMSO, val);
>   	rc = ksz_config_flags(phydev);
> +	if (rc < 0)
> +		return rc;
> +	rc = phy_write(phydev, MII_KSZPHY_OMSO, val);
>   	return rc < 0 ? rc : 0;
>   }
>   
