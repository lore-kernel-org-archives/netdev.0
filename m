From: Mason <slash.tmp@free.fr>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 16:33:48 +0100
Message-ID: <5829D95C.6060509@free.fr>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
 <5828C452.6050808@free.fr> <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
 <5829BBFC.7040800@free.fr> <20161114133428.GF26710@lunn.ch>
 <5829D10F.30206@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Zach Brown <zach.brown@ni.com>,
        Shaohui Xie <shaohui.xie@nxp.com>,
        Tim Beale <tim.beale@alliedtelesis.co.nz>,
        Brian Hill <brian@houston-radar.com>,
        Vince Bridgers <vbridgers2013@gmail.com>,
        Balakumaran Kannan <kumaran.4353@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sebastian Frias <sf84@laposte.net>,
        Kirill Kapranov <kapranoff@inbox.ru>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:34631 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751662AbcKNPeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 10:34:25 -0500
In-Reply-To: <5829D10F.30206@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/11/2016 15:58, Mason wrote:

> nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
> vs
> nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control off
> 
> I'm not sure whether "flow control" is relevant...

Based on phy_print_status()
phydev->pause ? "rx/tx" : "off"
I added the following patch.

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index defc22a15f67..4e758c1cfa4e 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -667,6 +667,8 @@ static void nb8800_link_reconfigure(struct net_device *dev)
        struct phy_device *phydev = priv->phydev;
        int change = 0;
 
+       printk("%s from %pf\n", __func__, __builtin_return_address(0));
+
        if (phydev->link) {
                if (phydev->speed != priv->speed) {
                        priv->speed = phydev->speed;
@@ -1274,9 +1276,9 @@ static int nb8800_hw_init(struct net_device *dev)
        nb8800_writeb(priv, NB8800_PQ2, val & 0xff);
 
        /* Auto-negotiate by default */
-       priv->pause_aneg = true;
-       priv->pause_rx = true;
-       priv->pause_tx = true;
+       priv->pause_aneg = false;
+       priv->pause_rx = false;
+       priv->pause_tx = false;
 
        nb8800_mc_init(dev, 0);
 

Connected to 1000 Mbps switch:

# time udhcpc | while read LINE; do date; echo $LINE; done
Thu Jan  1 00:00:22 UTC 1970
udhcpc (v1.22.1) started
Thu Jan  1 00:00:22 UTC 1970
Sending discover...
[   24.565346] nb8800_link_reconfigure from phy_state_machine
Thu Jan  1 00:00:25 UTC 1970
Sending discover...
[   26.575402] nb8800_link_reconfigure from phy_state_machine
[   26.580972] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
Thu Jan  1 00:00:28 UTC 1970
Sending discover...
Thu Jan  1 00:00:29 UTC 1970
Sending select for 172.27.64.58...
Thu Jan  1 00:00:29 UTC 1970
Lease of 172.27.64.58 obtained, lease time 604800
Thu Jan  1 00:00:29 UTC 1970
deleting routers
Thu Jan  1 00:00:29 UTC 1970
adding dns 172.27.0.17

real    0m7.388s
user    0m0.040s
sys     0m0.090s



Connected to 100 Mbps switch:

# time udhcpc | while read LINE; do date; echo $LINE; done
Thu Jan  1 00:00:14 UTC 1970
udhcpc (v1.22.1) started
Thu Jan  1 00:00:15 UTC 1970
Sending discover...
[   16.968621] nb8800_link_reconfigure from phy_state_machine
[   17.975359] nb8800_link_reconfigure from phy_state_machine
[   17.980923] nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
Thu Jan  1 00:00:18 UTC 1970
Sending discover...
Thu Jan  1 00:00:19 UTC 1970
Sending select for 172.27.64.58...
Thu Jan  1 00:00:19 UTC 1970
Lease of 172.27.64.58 obtained, lease time 604800
Thu Jan  1 00:00:19 UTC 1970
deleting routers
Thu Jan  1 00:00:19 UTC 1970
adding dns 172.27.0.17

real    0m4.355s
user    0m0.043s
sys     0m0.083s



OK, so now it works (by accident?) even on 100 Mbps switch, but it still
prints "flow control rx/tx"...

# ethtool -a eth0
Pause parameters for eth0:
Autonegotiate:  off
RX:             off
TX:             off

These values make sense considering my changes in the driver.

Are 100 Mbps switches supposed to support these pause features,
and are they supposed to be able to auto-negotiate them?

Regards.
