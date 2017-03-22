From: Keyur Chudgar <kchudgar@apm.com>
Subject: RE: [PATCH net-next 1/4] drivers: net: xgene-v2: Add MDIO support
Date: Tue, 21 Mar 2017 17:08:49 -0700
Message-ID: <e9bb420df0c62d49c0fce1bf45f8c686@mail.gmail.com>
References: <1490124283-10371-1-git-send-email-isubramanian@apm.com>
 <1490124283-10371-2-git-send-email-isubramanian@apm.com>
 <20170321203550.GD30655@lunn.ch>
 <CAKh23Fn_re2CmT_XDD7YgqAGEa61rfaL5XHHqaPujzhMx9XVeg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev <netdev@vger.kernel.org>,
 patches <patches@apm.com>, David Laight <David.Laight@aculab.com>,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Iyappan Subramanian <isubramanian@apm.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAKh23Fn_re2CmT_XDD7YgqAGEa61rfaL5XHHqaPujzhMx9XVeg@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Iyappan,

I agree with Andrew.

Let's re-post the patch after addressing Andrew's comment.

Thanks,
Keyur

> -----Original Message-----
> From: Iyappan Subramanian [mailto:isubramanian@apm.com]
> Sent: Tuesday, March 21, 2017 4:19 PM
> To: Andrew Lunn
> Cc: David Miller; netdev; Florian Fainelli; David Laight; linux-arm-
> kernel@lists.infradead.org; patches; Keyur Chudgar
> Subject: Re: [PATCH net-next 1/4] drivers: net: xgene-v2: Add MDIO
> support
>
> On Tue, Mar 21, 2017 at 1:35 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> >> @@ -511,9 +512,9 @@ static int xge_close(struct net_device *ndev)  {
> >>       struct xge_pdata *pdata = netdev_priv(ndev);
> >>
> >> -     netif_carrier_off(ndev);
> >>       netif_stop_queue(ndev);
> >>       xge_mac_disable(pdata);
> >> +     phy_stop(ndev->phydev);
> >>
> >>       xge_intr_disable(pdata);
> >>       xge_free_irq(ndev);
> >> @@ -683,9 +684,14 @@ static int xge_probe(struct platform_device
> *pdev)
> >>       if (ret)
> >>               goto err;
> >>
> >> +     spin_lock_init(&pdata->mdio_lock);
> >> +
> >
> > ...
> >
> >> +static int xge_mdio_write(struct mii_bus *bus, int phy_id, int reg,
> >> +u16 data) {
> >> +     struct xge_pdata *pdata = bus->priv;
> >> +     u32 done, val = 0;
> >> +     u8 wait = 10;
> >> +     int ret = 0;
> >> +
> >> +     spin_lock(&pdata->mdio_lock);
> >> +
> >> +     SET_REG_BITS(&val, PHY_ADDR, phy_id);
> >> +     SET_REG_BITS(&val, REG_ADDR, reg);
> >> +     xge_wr_csr(pdata, MII_MGMT_ADDRESS, val);
> >> +
> >> +     xge_wr_csr(pdata, MII_MGMT_CONTROL, data);
> >> +     do {
> >> +             usleep_range(5, 10);
> >> +             done = xge_rd_csr(pdata, MII_MGMT_INDICATORS);
> >> +     } while ((done & MII_MGMT_BUSY) && wait--);
> >> +
> >> +     if (done & MII_MGMT_BUSY) {
> >> +             dev_err(&bus->dev, "MII_MGMT write failed\n");
> >> +             ret = -ETIMEDOUT;
> >> +     }
> >> +
> >> +     spin_unlock(&pdata->mdio_lock);
> >> +
> >> +     return ret;
> >> +}
> >> +
> >> +static int xge_mdio_read(struct mii_bus *bus, int phy_id, int reg)
> {
> >> +     struct xge_pdata *pdata = bus->priv;
> >> +     u32 data, done, val = 0;
> >> +     u8 wait = 10;
> >> +
> >> +     spin_lock(&pdata->mdio_lock);
> >> +
> >
> > Hi Iyappan
> >
> > Please could you explain what this lock is protecting which the
> > mii_bus mdio_lock in mdio_bus.c is not protecting?
>
> Hi Keyur,
>
> Please could you explain what this lock is protecting which the mii_bus
> mdio_lock in mdio_bus.c is not protecting?
>
> I agree with him.  Actually there is a mutex on mdio_bus.  So the mdio
> bus read and write are locked.  we don't need the lock.
>
> Do you agree ?
>
>
> >
> > Thanks
> >         Andrew
