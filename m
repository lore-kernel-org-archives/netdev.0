From: Andy Fleming <afleming@gmail.com>
Subject: Re: [v9, 6/6] fsl/fman: Add FMan MAC driver
Date: Tue, 8 Dec 2015 14:18:16 -0600
Message-ID: <CAKWjMd7EDx8OnYGu-QJXM++fy=W5i2E74Fe4r9zNjUV_giyUKw@mail.gmail.com>
References: <1449127157-9400-1-git-send-email-igal.liberman@freescale.com>
	<1449127157-9400-7-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>,
	madalin.bucur@freescale.com, pebolle@tiscali.nl,
	Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	ppc@mindchasers.com, stephen@networkplumber.org,
	David Miller <davem@davemloft.net>
To: igal.liberman@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449127157-9400-7-git-send-email-igal.liberman@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 3, 2015 at 1:19 AM,  <igal.liberman@freescale.com> wrote:
> From: Igal Liberman <igal.liberman@freescale.com>
>
> This patch adds the Ethernet MAC driver supporting the three
> different types of MACs: dTSEC, tGEC and mEMAC.
>
> Signed-off-by: Igal Liberman <igal.liberman@freescale.com>

[...]

> +
> +MODULE_LICENSE("Dual BSD/GPL");
> +
> +MODULE_AUTHOR("Emil Medve <Emilian.Medve@Freescale.com>");

I imagine this email address doesn't exist anymore, or won't soon.
This is also an issue in the ethernet driver (with my old address).
I'm not sure what the right approach is, but we shouldn't be putting
obsolete email addresses in the kernel.

[...]

> +static void mac_exception(void *_mac_dev, enum fman_mac_exceptions ex)
> +{
> +       struct mac_device       *mac_dev;
> +       struct mac_priv_s       *priv;
> +
> +       mac_dev = (struct mac_device *)_mac_dev;


Don't cast a void *

[...]

> +static int mac_probe(struct platform_device *_of_dev)
> +{
> +       int                      err, i, lenp, nph;
> +       struct device           *dev;
> +       struct device_node      *mac_node, *dev_node, *tbi_node;
> +       struct mac_device       *mac_dev;
> +       struct platform_device  *of_dev;
> +       struct resource          res;
> +       struct mac_priv_s       *priv;
> +       const u8                *mac_addr;
> +       const char              *char_prop;

[...]

> +       /* Get the PHY connection type */
> +       char_prop = (const char *)of_get_property(mac_node,
> +                                               "phy-connection-type", NULL);
> +       if (!char_prop) {
> +               dev_warn(dev,
> +                        "of_get_property(%s, phy-connection-type) failed. Defaulting to MII\n",
> +                        mac_node->full_name);
> +               priv->phy_if = PHY_INTERFACE_MODE_MII;
> +       } else {
> +               priv->phy_if = str2phy(char_prop);
> +       }
> +
> +       priv->speed             = phy2speed[priv->phy_if];
> +       priv->max_speed         = priv->speed;
> +       mac_dev->if_support     = DTSEC_SUPPORTED;
> +       /* We don't support half-duplex in SGMII mode */
> +       if (strstr(char_prop, "sgmii"))

This causes a crash if the device tree does not have a
"phy-connection-type" for this node. Also, you already have parsed the
property, and put the result in priv->phy_if. Why not use this to do
all of these determinations?


> +               mac_dev->if_support &= ~(SUPPORTED_10baseT_Half |
> +                                       SUPPORTED_100baseT_Half);
> +
> +       /* Gigabit support (no half-duplex) */
> +       if (priv->max_speed == 1000)
> +               mac_dev->if_support |= SUPPORTED_1000baseT_Full;
> +
> +       /* The 10G interface only supports one mode */
> +       if (strstr(char_prop, "xgmii"))
> +               mac_dev->if_support = SUPPORTED_10000baseT_Full;

Here, too.


[...]

> +       err = mac_dev->init(mac_dev);
> +       if (err < 0) {
> +               dev_err(dev, "mac_dev->init() = %d\n", err);
> +               of_node_put(priv->phy_node);
> +               goto _return_dev_set_drvdata;
> +       }
> +
> +       /* pause frame autonegotiation enabled */
> +       mac_dev->autoneg_pause = true;
> +
> +       /* by intializing the values to false, force FMD to enable PAUSE frames
> +        * on RX and TX
> +        */

Minor comment format issue (leave blank line at top of block comment)

Andy
