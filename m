From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure
 adjust_link() works
Date: Thu, 5 Sep 2013 11:11:47 +0200
Message-ID: <20130905091147.GA28658@1wt.eu>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130904163245.GI20552@1wt.eu>
 <CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
 <20130905051223.GB26000@1wt.eu> <20130905092808.617da416@skate>
 <20130905074426.GD26000@1wt.eu> <20130905102659.25a0f064@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>,
 Jochen De Smet <jochen.armkernel@leahnim.org>,
 Simon Guinot <simon.guinot@sequanux.org>, Ryan Press <ryan@presslab.us>,
 netdev@vger.kernel.org, vdonnefort@lacie.com,
 Ethan Tuttle <ethan@ethantuttle.com>, stable@vger.kernel.org,
 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 =?iso-8859-1?Q?Ch=E9ny?= Yves-Gael <yves@cheny.fr>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Peter Sanford <psanford@nearbuy.io>, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org, Jason Cooper <jason@lakedaemon.net>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20130905102659.25a0f064@skate>
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

On Thu, Sep 05, 2013 at 10:26:59AM +0200, Thomas Petazzoni wrote:
> > One simpler solution for them could be to slightly modify the boot loader
> > so that it sets the MAC address on the two ethernet controllers prior to
> > boot. Then your code which checks if a MAC is already set will simply
> > work.
> 
> This works when the network driver is compiled 'statically' inside the
> kernel. When compiled as a module, then the gatable clock of the
> network interface will be gated at the end of the kernel boot, before
> the mvneta module is probe. And gating the network interface clocks
> means that it will loose its state, including its MAC address. So it's
> not an entirely perfect solution either, but I admit that on such
> platforms, the network driver is most likely compiled statically, so it
> would probably suit the needs of most people.

Agreed.

> Note that this can be done without doing any change in the bootloader.
> For example, on a Mirabox, you can do:
> 
>    mw.l 0xD0072414 0x5C93; mw.l 0xD0072418 0xF0AD4E01; mw.l 0xD0076414 0x5C94; mw.l 0xD0076418 0xF0AD4E01; bootm
> 
> to boot your kernel. This will program the MAC addresses for both
> network interfaces in the network controllers, so that when booting
> Linux, you get:
> 
> [   42.122881] mvneta d0070000.ethernet eth0: Using hardware mac address f0:ad:4e:01:5c:93
> [   42.385398] mvneta d0074000.ethernet eth1: Using hardware mac address f0:ad:4e:01:5c:94
> 
> You add that to your default U-Boot boot script, and that's it, you
> have stable MAC addresses.

Hmmm that's quite interesting. Unfortunately I don't see an easy way to
make this directly rely on the ethaddr/eth1addr so that end users can
simply cut-n-paste a few lines into the u-boot config. But anyway that
can be useful.

> > A last one would be to have the mvneta module accept an array of addresses
> > as a module parameter. This way it would just require a minor change in the
> > kernel's cmdline to pass the MAC addresses. I remember seeing this in the
> > past, I don't remember the platform (maybe the NSLU2 but I could be wrong).
> 
> The situation of module parameters to pass MAC addresses was a bit
> fuzzy. There was once a proposal to add a generic kernel parameter to
> do this, but it was rejected by David Miller (I believe not on specific
> implementation details, but on the general idea). However, there are
> numerous drivers in the tree that do provide a custom module parameter
> to set MAC addresses.

Yes, I remember using this with the sunhme driver many years ago when
we did not have access to the onboard rom to retrieve the MAC address.

> However, with the above suggestion of U-Boot scripting, I believe we
> have a relatively easy solution for people to use.

We could provide a script to do it more conveniently for the user :-)

Best regards,
Willy
