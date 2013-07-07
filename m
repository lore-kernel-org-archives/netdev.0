From: Jonas Gorski <jogo@openwrt.org>
Subject: Re: Second ethernet on kirkwood does not work when probed through
 DT
Date: Sun, 7 Jul 2013 13:26:07 +0200
Message-ID: <20130707132607.00007188@unknown>
References: <20130706215426.6e666d6af0dc6c9ea5fe32cd@openwrt.org>
	<51D88A8E.1060104@gmail.com>
	<20130706233912.00004044@unknown>
	<51D94884.4000204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D94884.4000204@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 07 Jul 2013 12:52:52 +0200
Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com> wrote:

> On 07/06/2013 11:39 PM, Jonas Gorski wrote:
> > On Sat, 06 Jul 2013 23:22:22 +0200
> > Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>  wrote:
> >> On 07/06/2013 09:54 PM, Jonas Gorski wrote:
> >>> Hello Sebastian,
> >>>
> >>> using your DT patches[1] (on top of 3.10) I can't get the second
> >>> ethernet to work on my kirkwood board.
> >>
> >> Hi Jonas,
> >>
> >> next time please name your board, because there are plenty of it.
> >> Kirkwood is just the SoC used on them.
> >
> > Oops, sorry. It's D-Link DIR-665, with a 6281. Currently not upstream,
> > but mostly supported (the switch isn't supported by DSA but works fine
> > without it).
> 
> Jonas,
> 
> sorry, I didn't realize you already sent your request on MLs. It was
> too late yesterday :P I also added Florian, Jason, and Andrew to the Cc
> list.
> 
> Ok, so the DIR665 has this switch configuration on both KW ethernet
> controllers. Just to make sure, the first one is working but the second
> isn't?

Right. Its a 7-Port switch (88E6171R) with two CPU ports, each
connected to one of the ethernet controllers. Then port vlans split the
switch into two groups; (lan1,lan2,lan3,lan4,eth0) and (wan,eth1).

The same setup is used on other kirkwood based routers (e.g. Linksys
EA4500).

> >>> (Both macs are connected to a switch, so use a fixed link, and no
> >>> phy).
> >>>
> >>> Eth1 gets probed fine, but never gets a link when brought up, and
> >>> trying to bring it down again hangs the board hard.
> >>>
> >>> Using Florian's older patches, it is brought up fine and works (after
> >>> adapting the node names of course).
> >>>
> >>> Also I noticed that you named eth1's ethernet1-port node wrongly in
> >>> (at least) your kirkwood conversion patch[2]; you used
> >>>
> >>> &eth1 { status = "okay"; ethernet1-port@0 { must be @1--^ phy-handle
> >>> =<&ethphy1>; }; };
> >>
> >> Can you please try to leave ethernet1-port@0 and match
> >> the one in kirkwood.dtsi?
> >>
> >> Both "ports" need reg =<0>  as there is two controllers
> >> with one port at 0 on Kirkwood.
> >
> > kirkwood.dtsi itself says ethernet1-port@1 with reg =<1>.
> >
> > Changing reg to 0 for eth1 brings:
> 
> The error below is a naming issue for the port. As there is only one
> port per controller, both reg properties of the port nodes of
> kirkwood.dtsi have to be <0> as they determine the register offset
> within the controller registers. As mentioned before, KW has a
> dual-controller, single port configuration.
> 
> So the wrong reg property in kirkwood.dtsi is a bug and I will update
> the patch.
> 
> Second, mv643xx_eth as in net-next does a
> platform_device_alloc(MV643XX_ETH_NAME, ppd.port_number)
> which will cause two devices named mv643xx_eth_port.0 if you change
> both of the reg property to <0>.
> 
> A quick fix would be to change the above to
> platform_device_alloc(pnp->name, ppd.port_number)
> so the port devices will be named after the device nodes name.
>
> Also, for this I will prepare a patch. But the rename of the port
> devices could again raise the clock gating/loosing MAC issue.

In my case it's a non-issue as the studid D-Link U-Boot doesn't even
setup a mac for eth1, so there's nothing to lose ;).

> (I know again, why I hate this shared/port separation of mv643xx_eth)
> 
> Anyway, can you please try to have both ports reg properties set
> to <0>, with nodes named ethernet0-port@0 and ethernet1-port@0,
> and the platform_device_alloc in mv643xx_eth modified?

In addition I added a static counter for the allocated devs (to not
overwrite the pointers in port_platdev[]).

That seems to work, as now eth1 comes up and works (successfully got a
IP through DHCP).


Regards
Jonas
