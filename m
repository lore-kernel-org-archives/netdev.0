From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH RFT 0/8] Marvell PXA168 libphy handling and Berlin Ethernet
Date: Thu,  9 Oct 2014 14:38:58 +0200
Message-ID: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	=?UTF-8?q?Antoine=20T=C3=A9nart?=
	<antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eric Miao <eric.y.miao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Haojian Zhuang <haojian.zhuang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series deals with a removing a IP feature that can be found
on all currently supported Marvell Ethernet IP (pxa168_eth, mv643xx_eth=
,
mvneta). The MAC IP allows to automatically perform PHY auto-negotiatio=
n
without software interaction.

However, this feature (a) fundamentally clashes with the way libphy wor=
ks
and (b) is unable to deal with quirky PHYs that require special treatme=
nt.
In this series, pxa168_eth driver is rewritten to completely disable th=
at
feature and properly deal with libphy provided PHYs. The other two driv=
ers
are suspect to future patch sets, also removing the code related with i=
t.

Currently, the patches are based on next-20141009 and will be resent on=
ce
v3.18-rc1 drops. This is a Request-For-Test on both BG2Q and MMP/gplug =
as
these are the current users of pxa168_eth. A branch with this patches o=
n
top of next-20141009 can be found at

git://git.infradead.org/users/hesselba/linux-berlin.git devel/bg2-bg2cd=
-eth-v1

It would be great to get a Tested-byfrom MMP guys on gplug - if they
have that board somewhere. Also, BG2Q (Antoine) needs a phy-connection-=
type
property. My guess is that, if it is using internal PHY, it is "mii", t=
oo.

Patch 1 adds support for Marvell 88E3016 FastEthernet PHY that is also
integrated in Marvell Berlin BG2/BG2CD SoCs.

Patch 2 allows to pass phy_interface_t on pxa168_eth platform_data that
is only used by mach-mmp/gplug. From the board setup, I guessed gplug's
PHY is connected via RMII. The patch isn't even compile tested, so here
I need a Tested-by from MMP guys.

Patches 3-5 prepare proper libphy handling and finally remove all in-dr=
iver
PHY mangling related to the feature explained above.

Patches 6-8 add corresponding ethernet DT nodes to BG2, BG2CD, and
BG2-based Sony NSZ-GS7. I have tested all this on GS7 successfully with
ip=3Ddhcp on 100M FD.

Sebastian Hesselbarth (8):
  phy: marvell: Add support for 88E3016 FastEthernet PHY
  net: pxa168_eth: Provide phy_interface mode on platform_data
  net: pxa168_eth: Prepare proper libphy handling
  net: pxa168_eth: Remove HW auto-negotiaion
  net: pxa168_eth: Remove in-driver PHY mangling
  ARM: berlin: Add BG2 ethernet DT nodes
  ARM: berlin: Add BG2CD ethernet DT nodes
  ARM: berlin: Enable ethernet on Sony NSZ-GS7

 arch/arm/boot/dts/berlin2-sony-nsz-gs7.dts |   2 +
 arch/arm/boot/dts/berlin2.dtsi             |  36 +++++
 arch/arm/boot/dts/berlin2cd.dtsi           |  36 +++++
 arch/arm/mach-mmp/gplugd.c                 |   2 +
 drivers/net/ethernet/marvell/pxa168_eth.c  | 242 +++++++++++----------=
--------
 drivers/net/phy/marvell.c                  |  46 ++++++
 include/linux/marvell_phy.h                |   1 +
 include/linux/pxa168_eth.h                 |   1 +
 8 files changed, 218 insertions(+), 148 deletions(-)

---
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: "Antoine T=C3=A9nart" <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Eric Miao <eric.y.miao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Haojian Zhuang <haojian.zhuang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
--=20
2.1.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
