From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: am335x: cpsw: phy ignores max-speed setting
Date: Thu, 6 Nov 2014 17:25:13 +0100
Message-ID: <CAGm1_ktWK5ai85PZJTkq8Q1mAFH6JZ5XM1mDOHO3K_N2iGNLWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "N, Mugunthan V" <mugunthanvnm@ti.com>, mpa@pengutronix.de,
	lsorense@csclub.uwaterloo.ca, Daniel Mack <zonque@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:60536 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaKFQZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 11:25:34 -0500
Received: by mail-pd0-f178.google.com with SMTP id fp1so1432600pdb.9
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 08:25:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I' m trying to override max-speed setting for both CPSW connected
PHYs. This is my DTS section for configuring CPSW:

&mac {
        pinctrl-names = "default", "sleep";
        pinctrl-0 = <&cpsw_default>;
        pinctrl-1 = <&cpsw_sleep>;
        dual_emac = <1>;

        status = "okay";
};

&davinci_mdio {
        pinctrl-names = "default", "sleep";
        pinctrl-0 = <&davinci_mdio_default>;
        pinctrl-1 = <&davinci_mdio_sleep>;

        status = "okay";
};

&cpsw_emac0 {
        phy_id = <&davinci_mdio>, <0>;
        phy-mode = "rgmii-id";
        dual_emac_res_vlan = <1>;
        max-speed = <100>;
};

&cpsw_emac1 {
        phy_id = <&davinci_mdio>, <1>;
        phy-mode = "rgmii-id";
        dual_emac_res_vlan = <2>;
        max-speed = <100>;
};

But in drivers/net/phy/phy_device.c->of_set_phy_supported() routine I
don't get through node check, i.e. node == NULL. Any idea why?

static void of_set_phy_supported(struct phy_device *phydev)
{
        struct device_node *node = phydev->dev.of_node;
        u32 max_speed;

        if (!IS_ENABLED(CONFIG_OF_MDIO))
                return;

        if (!node)
                return;

        if (!of_property_read_u32(node, "max-speed", &max_speed)) {
                /* The default values for phydev->supported are
provided by the PHY
                 * driver "features" member, we want to reset to sane
defaults fist
                 * before supporting higher speeds.
                 */
                phydev->supported &= PHY_DEFAULT_FEATURES;

                switch (max_speed) {
                default:
                        return;

                case SPEED_1000:
                        phydev->supported |= PHY_1000BT_FEATURES;
                case SPEED_100:
                        phydev->supported |= PHY_100BT_FEATURES;
                case SPEED_10:
                        phydev->supported |= PHY_10BT_FEATURES;
                }
        }
}

Yegor
