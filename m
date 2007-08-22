From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: Re: [PATCH 6/7 v2] fs_enet: Be an of_platform device when
 CONFIG_PPC_CPM_NEW_BINDING is set.
Date: Thu, 23 Aug 2007 01:00:57 +0400
Message-ID: <20070823010057.74e1355a@localhost.localdomain>
References: <20070817181718.GA15792@ld0162-tx32.am.freescale.net>
 <20070821130155.43898b68@localhost.localdomain>
 <46CB172D.9010807@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57030 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763038AbXHVVB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 17:01:27 -0400
In-Reply-To: <46CB172D.9010807@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Aug 2007 11:47:41 -0500
Scott Wood <scottwood@freescale.com> wrote:

> Vitaly Bordug wrote:
> > On Fri, 17 Aug 2007 13:17:18 -0500
> > Scott Wood wrote:
> > 
> > 
> >>The existing OF glue code was crufty and broken.  Rather than fix
> >>it, it will be removed, and the ethernet driver now talks to the
> >>device tree directly.
> >>
> > 
> > A bit short description, I'd rather expect some specific
> > improvements list, that are now up and running using device tree.
> > Or if it is just move to new infrastucture, let's state that, too.
> 
> Some of specific binding changes (there are too many to exhaustively 
> list) are enumerated in the "new CPM binding" patch, which I'll send 
> after Kumar's include/asm-ppc patch goes in (since it modifies one of 
> those files).
> 
ok
> >>+#ifdef CONFIG_PPC_CPM_NEW_BINDING
> >>+static int __devinit find_phy(struct device_node *np,
> >>+                              struct fs_platform_info *fpi)
> >>+{
> >>+	struct device_node *phynode, *mdionode;
> >>+	struct resource res;
> >>+	int ret = 0, len;
> >>+
> >>+	const u32 *data = of_get_property(np, "phy-handle", &len);
> >>+	if (!data || len != 4)
> >>+		return -EINVAL;
> >>+
> >>+	phynode = of_find_node_by_phandle(*data);
> >>+	if (!phynode)
> >>+		return -EINVAL;
> >>+
> >>+	mdionode = of_get_parent(phynode);
> >>+	if (!phynode)
> >>+		goto out_put_phy;
> >>+
> >>+	ret = of_address_to_resource(mdionode, 0, &res);
> >>+	if (ret)
> >>+		goto out_put_mdio;
> >>+
> >>+	data = of_get_property(phynode, "reg", &len);
> >>+	if (!data || len != 4)
> >>+		goto out_put_mdio;
> >>+
> >>+	snprintf(fpi->bus_id, 16, PHY_ID_FMT, res.start, *data);
> >>+
> >>+out_put_mdio:
> >>+	of_node_put(mdionode);
> >>+out_put_phy:
> >>+	of_node_put(phynode);
> >>+	return ret;
> >>+}
> > 
> > And without phy node? 
> 
> It returns -EINVAL. :-)
> 
> >>+#ifdef CONFIG_FS_ENET_HAS_FEC
> >>+#define IS_FEC(match) ((match)->data == &fs_fec_ops)
> >>+#else
> >>+#define IS_FEC(match) 0
> >>+#endif
> >>+
> > 
> > Since we're talking directly with device tree, why bother with
> > CONFIG_ stuff? We are able to figure it out from dts..
> 
> We are figuring it out from the DTS (that's what match->data is).  I 
> just didn't want boards without a FEC to have to build in support for
> it and waste memory.

yes, wrong snippet
what about 

> #ifdef CONFIG_CPM2
> +	r = fs_enet_mdio_bb_init();
> +	if (r != 0)
> +		goto out_mdio_bb;
> +#endif
> +#ifdef CONFIG_8xx
> +	r = fs_enet_mdio_fec_init();
> +	if (r != 0)
> +		goto out_mdio_fec;
> +#endif

We had to pray and hope that 8xx would only have fec, and cpm2 has some bitbanged stuff. now we can inquire dts and know for sure, at least it seems so.



> 
> >>+	fpi->rx_ring = 32;
> >>+	fpi->tx_ring = 32;
> >>+	fpi->rx_copybreak = 240;
> >>+	fpi->use_napi = 0;
> >>+	fpi->napi_weight = 17;
> >>+
> > 
> > 
> > move params over to  dts?
> 
> No.  These aren't attributes of the hardware, they're choices the
> driver makes about how much memory to use and how to interact with
> the rest of the kernel.
> 
> >>+	ret = find_phy(ofdev->node, fpi);
> >>+	if (ret)
> >>+		goto out_free_fpi;
> >>+
> > 
> > so we're hosed without phy node.
> 
> How is that different from the old code, where you're hosed without 
> fep->fpi->bus_id?
> 

I wasn't defending old code, and consider "old code is POS, new one is just great" game meaningless.
I am just stating the problem, that we'll have to address later. On 8xx even reference boards may be 
without phy at all.

> >>+static struct of_device_id fs_enet_match[] = {
> >>+#ifdef CONFIG_FS_ENET_HAS_SCC
> > 
> > 
> > same nagging. Are we able to get rid of Kconfig arcane defining
> > which SoC currently plays the game for fs_enet?
> 
> No, it's still needed for mpc885ads to determine pin setup and 
> conflicting device tree node removal (though that could go away if
> the device tree is changed to reflect the jumper settings).
> 
> It's also useful for excluding unwanted code.  I don't like using 
> 8xx/CPM2 as the decision point for that -- why should I build in 
> mac-scc.c if I have no intention of using an SCC ethernet (either 
> because my board doesn't have one, or because it's slow and conflicts 
> with other devices)?

ok, agreed, size is most serious judge here. we'll definitely have to revisit pin problem later too
(because custom designs sometimes switch contradictory devices on-the-fly, disable soc parts for alternative function, etc.) QE-like pin encoding may be an option for this or not- I'm inclined to look at
most resource-safe approach.

> 
> -Scott

-- 
Sincerely, Vitaly
