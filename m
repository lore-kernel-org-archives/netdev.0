From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC] net/fs_enet: send a reset request to the PHY on init
Date: Thu, 3 Sep 2009 10:48:34 -0600
Message-ID: <fa686aa40909030948h4acf6d3x1c318baa2fdefe1f@mail.gmail.com>
References: <20090902110410.GC15401@www.tglx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Vitaly Bordug <vbordug@ru.mvista.com>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20090902110410.GC15401@www.tglx.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 2, 2009 at 5:04 AM, Sebastian Andrzej
Siewior<bigeasy@linutronix.de> wrote:
> Usually u-boot sends a phy request in its network init routine. An uboot
> without network support doesn't do it and I endup without working
> network. I still can switch between 10/100Mbit (according to the LED on
> the hub and phy registers) but I can't send or receive any data.
>
> At this point I'm not sure if the PowerON Reset takes the PHY a few
> nsecs too early out of reset or if this reset is required and everyone
> relies on U-boot performing this reset.
>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
> This is done on a custom mpc512x board. Unfortunately I don't have other
> boards to check. The PHY is a AMD Am79C874, phylib uses the generic one.
>
> =A0drivers/net/fs_enet/fs_enet-main.c | =A0 =A03 ++-
> =A01 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_=
enet-main.c
> index ee15402..a3c962b 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -823,7 +823,8 @@ static int fs_init_phy(struct net_device *dev)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0fep->phydev =3D phydev;
> -
> + =A0 =A0 =A0 phy_write(phydev, MII_BMCR, BMCR_RESET);
> + =A0 =A0 =A0 udelay(1);

What version of the kernel are you using?  The line numbers don't
match up with kernel mainline, so I wonder if this is before or after
the OF MDIO rework changes.

Regardless, this doesn't look right.  It certainly isn't right for the
driver to do an unconditional PHY reset when it doesn't actually know
what phy is attached.  For most boards I'm sure this is not desirable
because it will cause a delay while the PHY auto negotiates.
Depending on when the first network traffic begins, can cause several
seconds of boot delay.

Best would be to do this in U-Boot.  Otherwise, I think I would rather
see it at phy_device probe time.  At least then it would be on a
per-phy basis, or could be controlled by a property in the device tree
so that all boards don't get the same impact.

g.

-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
