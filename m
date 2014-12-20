From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: Re: net: ucc: tbi phy detection broken by
 058112c7efc9ef43bb511c137293dddbe6e42908
Date: Sat, 20 Dec 2014 12:40:06 -0500
Message-ID: <20141220174006.GG24110@csclub.uwaterloo.ca>
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

Well it used to be that it would look for an unused address and assign
that, but that was changed to just use 0 unless the dtb specified an
address (essentially making specifying the address in the dtb mandetory).
Unfortunately after this patch, specifying it in the dtb isn't enough,
and the ucc_geth actually hits a null pointer because the tbi phy no
longer exists.

Before commit 28d8ea2d568534026ccda3e8936f5ea1e04a86a1, the tbi address
was in fact _not_ 0.  So yes it used to set it to a non conflicting
address, but no longer does.  It used to pick the highest unused address
for the tbi.  Now it uses 0 unless the dtb specifies the address.

Unfortunately no one ever fixed that comment.  It appears to be entirely
inaccurate.

In the case of the board I am dealing with, setting the address to 0
when it isn't used (port is not in SGMII or RTBI mode) actually breaks
things because we have a switch chip at address 0 on the MDIO bus that we
now can't reach.  Adding explicit addresses for the tbi phy on each ucc
solves that though so that is no big deal.  The fact that the ucc that
needs to actually use the tbi phy for SGMII or RTBI though can't find it
anymore because it is no longer created does seem like a problem, and it
isn't being created no matter what the address (it is not 0 in this case).

So right now it is broken with ucc_geth segfaulting if you use SGMII or
RTBI mode.  I would love a clean solution to fixing it, although for
now reverting this patch has solved the problem.

-- 
Len Sorensen
