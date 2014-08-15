From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: phy: smsc: move smsc_phy_config_init reset part
 in a soft_reset function
Date: Fri, 15 Aug 2014 08:02:36 -0700
Message-ID: <CAGVrzcYqRXqmQp5T8ULfP9PdUWWbTg0g+NbWuSt9VzcRQcAoQg@mail.gmail.com>
References: <1408107638-96143-1-git-send-email-gwenhael.goavec-merou@armadeus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Gwenhael Goavec-Merou <gwenhael.goavec-merou@armadeus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408107638-96143-1-git-send-email-gwenhael.goavec-merou@armadeus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-08-15 6:00 GMT-07:00 Gwenhael Goavec-Merou
<gwenhael.goavec-merou@armadeus.com>:
> On the one hand, phy_device.c provides a generic reset function if the phy
> driver does not provide a soft_reset pointer. This generic reset does not take
> into account the state of the phy, with a potential failure if the phy is in
> powerdown mode. On the other hand, smsc driver provides a function with both
> correct reset behaviour and configuration.
>
> This patch moves the reset part into a new smsc_phy_reset function and provides
> the soft_reset pointer to have a correct reset behaviour by default.
>
> Signed-off-by: Gwenhael Goavec-Merou <gwenhael.goavec-merou@armadeus.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
> Changes since v1 (as advised by Sergei Shtylyov):
>  * fix '=' alignment
>
>  drivers/net/phy/smsc.c | 33 +++++++++++++++++++++------------
>  1 file changed, 21 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> index 180c494..a4b0819 100644
> --- a/drivers/net/phy/smsc.c
> +++ b/drivers/net/phy/smsc.c
> @@ -43,6 +43,22 @@ static int smsc_phy_ack_interrupt(struct phy_device *phydev)
>
>  static int smsc_phy_config_init(struct phy_device *phydev)
>  {
> +       int rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
> +
> +       if (rc < 0)
> +               return rc;
> +
> +       /* Enable energy detect mode for this SMSC Transceivers */
> +       rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
> +                      rc | MII_LAN83C185_EDPWRDOWN);
> +       if (rc < 0)
> +               return rc;
> +
> +       return smsc_phy_ack_interrupt(phydev);
> +}
> +
> +static int smsc_phy_reset(struct phy_device *phydev)
> +{
>         int rc = phy_read(phydev, MII_LAN83C185_SPECIAL_MODES);
>         if (rc < 0)
>                 return rc;
> @@ -66,18 +82,7 @@ static int smsc_phy_config_init(struct phy_device *phydev)
>                         rc = phy_read(phydev, MII_BMCR);
>                 } while (rc & BMCR_RESET);
>         }
> -
> -       rc = phy_read(phydev, MII_LAN83C185_CTRL_STATUS);
> -       if (rc < 0)
> -               return rc;
> -
> -       /* Enable energy detect mode for this SMSC Transceivers */
> -       rc = phy_write(phydev, MII_LAN83C185_CTRL_STATUS,
> -                      rc | MII_LAN83C185_EDPWRDOWN);
> -       if (rc < 0)
> -               return rc;
> -
> -       return smsc_phy_ack_interrupt (phydev);
> +       return 0;
>  }
>
>  static int lan911x_config_init(struct phy_device *phydev)
> @@ -142,6 +147,7 @@ static struct phy_driver smsc_phy_driver[] = {
>         .config_aneg    = genphy_config_aneg,
>         .read_status    = genphy_read_status,
>         .config_init    = smsc_phy_config_init,
> +       .soft_reset     = smsc_phy_reset,
>
>         /* IRQ related */
>         .ack_interrupt  = smsc_phy_ack_interrupt,
> @@ -164,6 +170,7 @@ static struct phy_driver smsc_phy_driver[] = {
>         .config_aneg    = genphy_config_aneg,
>         .read_status    = genphy_read_status,
>         .config_init    = smsc_phy_config_init,
> +       .soft_reset     = smsc_phy_reset,
>
>         /* IRQ related */
>         .ack_interrupt  = smsc_phy_ack_interrupt,
> @@ -186,6 +193,7 @@ static struct phy_driver smsc_phy_driver[] = {
>         .config_aneg    = genphy_config_aneg,
>         .read_status    = genphy_read_status,
>         .config_init    = smsc_phy_config_init,
> +       .soft_reset     = smsc_phy_reset,
>
>         /* IRQ related */
>         .ack_interrupt  = smsc_phy_ack_interrupt,
> @@ -230,6 +238,7 @@ static struct phy_driver smsc_phy_driver[] = {
>         .config_aneg    = genphy_config_aneg,
>         .read_status    = lan87xx_read_status,
>         .config_init    = smsc_phy_config_init,
> +       .soft_reset     = smsc_phy_reset,
>
>         /* IRQ related */
>         .ack_interrupt  = smsc_phy_ack_interrupt,
> --
> 1.8.5.5
>



-- 
Florian
