From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: Re: net: ucc: tbi phy detection broken by
 058112c7efc9ef43bb511c137293dddbe6e42908
Date: Wed, 25 Mar 2015 13:13:26 -0400
Message-ID: <20150325171326.GA29558@csclub.uwaterloo.ca>
References: <20141219034918.GX24110@csclub.uwaterloo.ca>
 <CAGVrzcbCCV_AL48R3iTGQqvdAM6NWuC1yDW5P+eh7rExE3fcow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	Li Yang <leoli@freescale.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGVrzcbCCV_AL48R3iTGQqvdAM6NWuC1yDW5P+eh7rExE3fcow@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 20, 2014 at 09:08:51AM -0800, Florian Fainelli wrote:
> 2014-12-18 19:49 GMT-08:00 Lennart Sorensen <lsorense@csclub.uwaterloo.ca>:
> > I have been trying to move an 8360 based system from a 3.0 kernel to a
> > 3.12 (on the way to 3.14 with ipipe/xenomai) kernel and encountered an
> > oops in the ucc_geth driver when using RTBI mode on one of the ucc
> > ports.  I haven't managed to find any commits to of_mdio or ucc_geth or
> > fsl_pq_mdio that would appear to address this problem, so I believe it
> > is still present in the latest kernel, but have not confirmed that with
> > testing yet.
> >
> > Commit 058112c7efc9ef43bb511c137293dddbe6e42908 appears to have broken
> > ucc support for tbi phy detection.
> >
> > With the patch in place, I am unable to get the mdio bus to create phy
> > devices for the tbi phy in the ucc on an 8360e, and the ucc_geth driver
> > causes a kernel oops, while with the patch reverted, it does create them
> > and the driver comes up and works.
> >
> > The tbi phy is needed when using a ucc in RTBI, TBI or SGMII mode.
> >
> > I am not convinced that the tbi phy really behaves quite like a real phy,
> > which may be why get_phy_device does not work with it.  Perhaps there
> > is a better way to deal with the tbi phy on the ucc for this purpose.
> 
> There are some comments in ucc_geth that also lead me to believe this
> is a just a hack instead of a real Ethernet PHY device. Part of what I
> think got broken is because of this comment:
> 
> /* Initialize TBI PHY interface for communicating with the
>  * SERDES lynx PHY on the chip.  We communicate with this PHY
>  * through the MDIO bus on each controller, treating it as a
>  * "normal" PHY at the address found in the UTBIPA register.  We assume
>  * that the UTBIPA register is valid.  Either the MDIO bus code will set
>  * it to a value that doesn't conflict with other PHYs on the bus, or the
>  * value doesn't matter, as there are no other PHYs on the bus.
>  */
> 
> In particular this one:
> 
> "Either the MDIO bus code will set
>  * it to a value that doesn't conflict with other PHYs on the bus, or the
>  * value doesn't matter, as there are no other PHYs on the bus."
> 
> and what Sebastian removed did exactly that, we used the special MDIO
> broadcast address 0 to provide this "whatever". If this is such a
> requirement from the ucc_geth driver and TBI PHYs, maybe we should
> have this hack somewhere in the actual MDIO driver used by the
> ucc_geth driver instead, or set a flag/read the PHY connection mode
> and do this in drivers/of/of_mdio.c
> 

I discovered a problem with the tbi address handling on ucc_geth.

In get_ucc_tbipa, the passed in pointer is expecting a pointer to a struct
fsl_pq_mdio, but on ucc the pointer is actually to the start of the mii
area, since it doesn't have all the stuff that the etsec2 has, so as a
result the address returned for tbipa is actually 1312 bytes too high,
which means the address never gets set of course.  In fact the driver
prints out cr=0 and sr=0, while with the older working driver it printed
cr=140 and sr=149.

As a quick test I did:

                        }

                        tbipa = data->get_tbipa(priv->map - offsetof(struct fsl_pq_mdio, mii));

                        out_be32(tbipa, be32_to_cpup(prop));

and that made it work, but of course is ugly and would break etsec2.

Any suggestion for a clean way to make get_ucc_tbipa able to dereference
the structure correctly?

I suppose I could do:

/*
 * Return the TBIPAR address for a QE MDIO node
 */
static uint32_t __iomem *get_ucc_tbipa(void __iomem *p)
{
        struct fsl_pq_mdio __iomem *mdio = p - offsetof(struct fsl_pq_mdio, mii);

        return &mdio->utbipar;
}

but it seems like just putting more hacks in place.  The use of the
mii_offset in the first place seems like a clue that defining one
structure for etsec2 and ucc and such even though it doesn't apply to
both is probably an error.  It would just be using mii_offset in reverse
for the ucc, versus the etsec2.

-- 
Len Sorensen
