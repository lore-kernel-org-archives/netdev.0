From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH 2/2 v3] net/smsc911x: Add regulator support
Date: Thu, 27 Oct 2011 15:21:47 +0200
Message-ID: <CAJaTeTrzFwxsn22U-NHQ8iCiaUM+mj8PyicavR-DN0HgE08ZEQ@mail.gmail.com>
References: <1319719691-15799-1-git-send-email-linus.walleij@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Tony Lindgren <tony@atomide.com>, linux-omap@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Linus Walleij <linus.walleij@stericsson.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1319719691-15799-1-git-send-email-linus.walleij@stericsson.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2011 at 14:48, Linus Walleij wrote:
> Platforms that use regulators and the smsc911x and have no defined
> regulator for the smsc911x and claim complete regulator
> constraints with no dummy regulators will need to provide it, for
> example using a fixed voltage regulator. It appears that this may
> affect (apart from Ux500 Snowball) possibly these archs/machines
> that from some grep:s appear to define both CONFIG_SMSC911X and
> CONFIG_REGULATOR:
>
> - ARM Freescale mx3 and OMAP 2 plus, Raumfeld machines
> - Blackfin
> - Super-H

no Blackfin board in the tree uses regulators by default.  we do list
regulator resources with some boards so people can rebuild the
development system to support addon daughter cards.

my gut reaction: smsc911x is working just fine without regulator
support for many people, so why do we suddenly need to make it a
requirement ?  this is a fairly small amount of code, so adding a
smsc911x Kconfig symbol to control the regulator support seems like
overkill.  only other option would be to change the patch to not make
missing regulators non-fatal.  so i'd probably lean towards the latter
(and it sounds like you changed this with earlier versions).

> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
>
> +#define SMSC911X_NUM_SUPPLIES 2

this gets used once (to define the array), so i wonder if it shouldn't
just be inlined

> +static int smsc911x_enable_disable_resources(struct platform_device =
*pdev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0bool enable)
> +{
> ...
> + =A0 =A0 =A0 if (enable) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D regulator_bulk_enable(ARRAY_SIZ=
E(pdata->supplies),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata->=
supplies);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(ndev, "faile=
d to enable regulators %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 ret);
> ...
> static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> ...
> +       retval =3D smsc911x_request_free_resources(pdev, true);
> +       if (retval) {
> +               pr_err("Could request regulators needed aborting\n");

you warn twice here, and the grammar in the later error is broken, and
uses pr_err() instead of netdev_err().  i would simply drop the latter
pr_err().

> +static int smsc911x_request_free_resources(struct platform_device *p=
dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool request)
> +{
> ...
> + =A0 =A0 =A0 if (request) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D regulator_bulk_get(&pdev->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARRAY_S=
IZE(pdata->supplies),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata->=
supplies);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(ndev, "could=
n't get regulators %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 ret);
> static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> ...
> + =A0 =A0 =A0 retval =3D smsc911x_enable_disable_resources(pdev, true=
);
> + =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("Could enable regulators needed =
aborting\n");

same exact issues with the request/free helper

> +       retval =3D smsc911x_request_free_resources(pdev, false);
> +       /* ignore not all have regulators */

old comment ?
-mike
