From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: adds backplane driver for Freescale's PCS PHY
Date: Mon, 28 Dec 2015 19:54:03 -0800
Message-ID: <568203DB.20701@gmail.com>
References: <1450431054-5227-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: shh.xie@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34833 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbbL2DyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 22:54:07 -0500
Received: by mail-oi0-f54.google.com with SMTP id l9so154743970oia.2
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2015 19:54:07 -0800 (PST)
In-Reply-To: <1450431054-5227-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/12/2015 01:30, shh.xie@gmail.com a =C3=A9crit :
[snip]

> +struct training_state_machine {
> +	bool bin_m1_late_early;
> +	bool bin_long_late_early;
> +	bool bin_m1_stop;
> +	bool bin_long_stop;
> +	bool tx_complete;
> +	bool an_ok;
> +	bool link_up;
> +	bool running;
> +	bool sent_init;
> +	int m1_min_max_cnt;
> +	int long_min_max_cnt;

Can you change this into a succession of enum values to make it clear
how many states there are, and how to get from one to the other?

[snip]

> +
> +static void init_state_machine(struct training_state_machine *s_m)
> +{
> +	s_m->bin_m1_late_early =3D true;
> +	s_m->bin_long_late_early =3D false;
> +	s_m->bin_m1_stop =3D false;
> +	s_m->bin_long_stop =3D false;
> +	s_m->tx_complete =3D false;
> +	s_m->an_ok =3D false;
> +	s_m->link_up =3D false;
> +	s_m->running =3D false;
> +	s_m->sent_init =3D false;
> +	s_m->m1_min_max_cnt =3D 0;
> +	s_m->long_min_max_cnt =3D 0;

That alone is a good indication that your state machine is not readable=
=2E

> +}
> +
> +void tune_tecr0(struct fsl_xgkr_inst *inst)
> +{
> +	struct per_lane_ctrl_status *reg_base;
> +	u32 val;
> +
> +	reg_base =3D (struct per_lane_ctrl_status *)inst->reg_base;

Typical practice is not to cast a register base address into a pointer
to a structure, but instead use offsets to the base register address,
which is less error prone and more readable, anything that uses
inst->reg_base in this driver is modeled after a structure pattern,
please fix that.

> +
> +	val =3D TECR0_INIT |
> +		inst->adpt_eq << ZERO_COE_SHIFT |
> +		inst->ratio_preq << PRE_COE_SHIFT |
> +		inst->ratio_pst1q << POST_COE_SHIFT;
> +
> +	/* reset the lane */
> +	iowrite32be(ioread32be(&reg_base->gcr0) & ~GCR0_RESET_MASK,
> +		    &reg_base->gcr0);
> +	udelay(1);
> +	iowrite32be(val, &reg_base->tecr0);
> +	udelay(1);
> +	/* unreset the lane */
> +	iowrite32be(ioread32be(&reg_base->gcr0) | GCR0_RESET_MASK,
> +		    &reg_base->gcr0);
> +	udelay(1);

Since this is a reset control register, you might want to explore using
the reset controller subsystem in case this register serves multiple
peripherals.

[snip]

I skipped through all the state machine logic, but you should consider
trying to simplify it using different enum values and a switch() case()
statements to make it easy to audit and understand.

> +
> +static int fsl_backplane_probe(struct phy_device *phydev)
> +{
> +	struct fsl_xgkr_inst *xgkr_inst;
> +	struct device_node *child, *parent, *lane_node;
> +	const char *lane_name;
> +	int len;
> +	int ret;
> +	u32 mode;
> +	u32 lane[2];
> +
> +	child =3D phydev->dev.of_node;
> +	parent =3D of_get_parent(child);
> +	if (!parent) {
> +		dev_err(&phydev->dev, "could not get parent node");
> +		return 0;
> +	}
> +
> +	lane_name =3D of_get_property(parent, "lane-instance", &len);
> +	if (!lane_name)
> +		return 0;
> +
> +	if (strstr(lane_name, "1000BASE-KX"))
> +		mode =3D BACKPLANE_1G_KX;
> +	else
> +		mode =3D BACKPLANE_10G_KR;

That seems like I could put whatever value in "lane-instance" and as
long as it contains 1000BASE-KX we are golden, that does not sound very
robust nor well defined.

> +
> +	lane_node =3D of_parse_phandle(child, "lane-handle", 0);
> +	if (lane_node) {

Treat this as an error so you can return early and reduce indentation.

> +		struct resource res_lane;
> +
> +		ret =3D of_address_to_resource(lane_node, 0, &res_lane);
> +		if (ret) {
> +			dev_err(&phydev->dev, "could not obtain memory map\n");
> +			return ret;
> +		}
> +
> +		ret =3D of_property_read_u32_array(child, "lane-range",
> +						 (u32 *)&lane, 2);
> +		if (ret) {
> +			dev_info(&phydev->dev, "could not get lane-range\n");
> +			return -EINVAL;
> +		}

Is not the standard "ranges" property usable here?

> +
> +		phydev->priv =3D devm_ioremap_nocache(&phydev->dev,
> +						    res_lane.start + lane[0],
> +						    lane[1]);

What about the "reg" property here?

> +
> +		if (!phydev->priv) {
> +			of_node_put(lane_node);
> +			return -EINVAL;
> +		}
> +		of_node_put(lane_node);
> +	} else {
> +		return -EINVAL;
> +	}
> +
> +	if (mode =3D=3D BACKPLANE_1G_KX) {
> +		phydev->speed =3D SPEED_1000;
> +		/* configure the lane for 1000BASE-KX */
> +		lane_set_1gkx(phydev->priv);
> +		return 0;
> +	}
> +
> +	xgkr_inst =3D kzalloc(sizeof(*xgkr_inst), GFP_KERNEL);
> +	if (!xgkr_inst)
> +		goto mem_err1;

devm_kzalloc()?

> +
> +	xgkr_inst->reg_base =3D phydev->priv;
> +	xgkr_inst->bus =3D phydev->bus;
> +	xgkr_inst->phydev =3D phydev;
> +	phydev->priv =3D xgkr_inst;
> +
> +	if (mode =3D=3D BACKPLANE_10G_KR) {
> +		phydev->speed =3D SPEED_10000;
> +		init_inst(xgkr_inst, 1);
> +		INIT_DELAYED_WORK(&xgkr_inst->xgkr_wk, xgkr_wq_state_machine);
> +	}
> +
> +	return 0;
> +mem_err1:
> +	dev_err(&phydev->dev, "failed to allocate memory\n");
> +	return -ENOMEM;
> +}
> +
> +static int fsl_backplane_aneg_done(struct phy_device *phydev)
> +{
> +	return 1;
> +}
> +
> +static int fsl_backplane_config_aneg(struct phy_device *phydev)
> +{
> +	struct fsl_xgkr_inst *xgkr_inst =3D (struct fsl_xgkr_inst *)phydev-=
>priv;

No casting needed from void *

[snip]

> +
> +static int fsl_backplane_read_status(struct phy_device *phydev)
> +{
> +	int val;
> +
> +	phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
> +	val =3D phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
> +
> +	if (val & AN_LNK_UP_MASK)
> +		phydev->link =3D 1;
> +	else
> +		phydev->link =3D 0;

This sounds fairly generic, candidate for a helper function?


--=20
=46lorian
