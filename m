From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH 1/2] netdev/fec: fix performance impact from mdio poll
	operation
Date: Sat, 8 May 2010 10:25:53 -0500
Message-ID: <AANLkTim8SJ0CzC_tRLhSqXdSXHwcDtx5qFy5A4qo3sae@mail.gmail.com>
References: <1273199239-11057-1-git-send-email-bryan.wu@canonical.com>
	 <1273199239-11057-2-git-send-email-bryan.wu@canonical.com>
	 <i2l2acbd3e41005070906me50416bapd8154a567406b886@mail.gmail.com>
	 <4BE537E2.6010809@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Greg Ungerer <gerg@uclinux.org>,
	Amit Kucheria <amit.kucheria@canonical.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "bryan.wu@canonical.com" <bryan.wu@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BE537E2.6010809@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, May 8, 2010, Bryan Wu <bryan.wu@canonical.com> wrote:
> On 05/08/2010 12:06 AM, Andy Fleming wrote:

> From the BugLink, we experienced a lot of error
>
> The Phy lib is not going to respond well if an mdio
> write times out without returning an error. =A0And returning an error
> means the whole state machine has to reset, as a failed write is not
> something we currently handle gracefully.
>
>
>
> Right, if we return error to phylib due to mdio read times out, the p=
erformance will drop a lot.


Yes, and if you *don't* return an error, you risk incorrect behavior.
This patch changes the driver to return the read result, after
detecting that the read result is invalid.  I don't know what the
value in that register will be, but it can't be correct.  If the
hardware is broken, then we need to find a workaround that doesn't
break things for chips which have working mdio.  It's also possible we
just need a longer timeout.  Does the mdio bus ever return correct
values?




>
>
> Is it possible to use an interrupt to get the phy state change? =A0Th=
is
> would allow the phy lib to stop its incessant polling. =A0It doesn't
> solve the question of why it's timing out, though.
>
>
>
> I'm going to try the interrupt, but fec driver is shared by several S=
oCs. It might be a little complicated and still cannot fix the timing o=
ut issue. Is there any example driver to use an interrupt to get the ph=
y state change?

Well, there are examples, but they may be only somewhat helpful.  From
the perspective of the PHY Lib, all you have to do is put a correct
value into the irqs array in the mdio bus struct for your bus.  The
part where you will probably have to solve a problem is in figuring
out how to convey that information to the bus driver.  On Power CPUs
and socs, we use a device tree, which has an interrupt associated with
each PHY.  Look at wherever your mdio bus *device* is registered.
That's probably where you'll have that information.

=46eel free to look at drivers/net/fsl_pq_mdio.c

Another possibility is to use the fixed link phy driver, which will
never attempt to use the mdio bus, and won't poll.
