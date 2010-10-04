From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: powerpc, fs_enet: scanning PHY after Linux is up
Date: Mon, 4 Oct 2010 10:20:41 -0600
Message-ID: <AANLkTinSersREjDnvg=8Gvpa6YmLuzgF1H8eEXRyCpW0@mail.gmail.com>
References: <4CA9830A.2030605@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Holger Brunck <holger.brunck@keymile.com>,
	Detlev Zundel <dzu@denx.de>
To: hs@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62480 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315Ab0JDQVC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 12:21:02 -0400
Received: by gye5 with SMTP id 5so1596053gye.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 09:21:01 -0700 (PDT)
In-Reply-To: <4CA9830A.2030605@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 4, 2010 at 1:32 AM, Heiko Schocher <hs@denx.de> wrote:
> Hello all,
>
> we have on the mgcoge arch/powerpc/boot/dts/mgcoge.dts 3 fs_enet
> devices. The first is accessible on boot, and so get correct
> probed and works fine. For the other two fs_enet devices the PHYs
> are on startup in reset, and gets later, through userapplikations,
> out of reset ... so, on bootup, this 2 fs_enet devices could
> not detect the PHY in drivers/of/of_mdio.c of_mdiobus_register(),
> and if we want to use them later, we get for example:
>
> -bash-3.2# ifconfig eth2 172.31.31.33
> net eth2: Could not attach to PHY
> SIOCSIFFLAGS: No such device
>
> So the problem is, that we cannot rescan the PHYs, if they are
> accessible. Also we could not load the fs_enet driver as a module,
> because the first port is used fix.
>
> So, first question which comes in my mind, is:
>
> Is detecting the phy in drivers/of/of_mdio.c of_mdiobus_register()
> the right place, or should it not better be done, when really
> using the port?
>
> But we found another way to solve this issue:
>
> After the PHYs are out of reset, we just have to rescan the PHYs
> with (for example PHY with addr 1)
>
> err =3D mdiobus_scan(bus, 1);
>
> and
>
> of_find_node_by_path("/soc@f0000000/cpm@119c0/mdio@10d40/ethernet-phy=
@1");
> of_node_get(np);
> dev_archdata_set_node(&err->dev.archdata, np);
>
> but thats just a hack ...

Yeah, that's a hack.  It really needs to be done via the of_mdio
mechanisms so that dt <--> phy_device linkages remain consistent.

> So, the question is, is there a possibility to solve this problem?
>
> If there is no standard option, what would be with adding a
> "scan_phy" file in
>
> /proc/device-tree/soc\@f0000000/cpm\@119c0/mdio\@10d40
> (or better destination?)
>
> which with we could rescan a PHY with
> "echo addr > /proc/device-tree/soc\@f0000000/cpm\@119c0/mdio\@10d40/s=
can_phy"
> (so there is no need for using of_find_node_by_path(), as we should
> =A0have the associated device node here, and can step through the chi=
ld
> =A0nodes with "for_each_child_of_node(np, child)" and check if reg =3D=
=3D addr)
>
> or shouldn;t be at least, if the phy couldn;t be found when opening
> the port, retrigger a scanning, if the phy now is accessible?

One option would be to still register a phy_device for each phy
described in the device tree, but defer binding a driver to each phy
that doesn't respond.  Then at of_phy_find_device() time, if it
matches with a phy_device that isn't bound to a driver yet, then
re-trigger the binding operation.  At which point the phy id can be
probed and the correct driver can be chosen.  If binding succeeds,
then return the phy_device handle.  If not, then fail as it currently
does.

g.
