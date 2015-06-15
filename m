From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: displayed name changed in ip link show for bridge- and other
 interfaces
Date: Mon, 15 Jun 2015 11:13:12 +0200
Message-ID: <557E9728.7080208@6wind.com>
References: <201506141200.20435.ulrich.gemkow@ikr.uni-stuttgart.de> <557DCD0A.5040500@hartkopp.net> <557DD20E.4080005@hartkopp.net> <557E7D89.30301@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35896 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754761AbbFOJNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 05:13:16 -0400
Received: by wigg3 with SMTP id g3so70409457wig.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 02:13:14 -0700 (PDT)
In-Reply-To: <557E7D89.30301@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/06/2015 09:23, Nicolas Dichtel a =E9crit :
> Le 14/06/2015 21:12, Oliver Hartkopp a =E9crit :
>> @Nicolas: Just saw that you were not responsible for the @NONE m)
>>
>> Sorry.
>>
>> Btw. do you know why this @NONE stuff just emerged in 4.1-rc ?
> Yes, it comes from the iflink cleanup in kernel:
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit=
/net/core/dev.c?id=3De1622baf54df8cc958bf29d71de5ad545ea7d93c
>
Theoretically, virtual interfaces should advertise an IFLA_LINK to 0.
I don't know what is the best fix:
  - patching iproute2 to avoid this '@NONE'
  - patching the kernel (see below).

As told in the commit log (see e1622baf54df) some other virtual interfa=
ces
are also impacted.

---8<---

 From c9e1d93960365cc5005e1b6c3ad73a8e5687824c Mon Sep 17 00:00:00 2001
=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 15 Jun 2015 10:52:16 +0200
Subject: [PATCH] bridge: don't set IFLA_LINK attribute for bridge iface=
s

Since commit e1622baf54df ("dev: set iflink to 0 for virtual interfaces=
"),
this attribute is set for bridge interface. A side effect is that iprou=
te2
now displays '@NONE' after the interface name, which may break existing
scripts:
13: br0@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode=
 DEFAULT=20
group default
     link/ether d2:b3:db:d6:d5:e1 brd ff:ff:ff:ff:ff:ff

To avoid that, let's set iflink to the interface ifindex.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
  net/bridge/br_device.c | 6 ++++++
  1 file changed, 6 insertions(+)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 4ff77a16956c..3576a257709c 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -314,6 +314,11 @@ static const struct ethtool_ops br_ethtool_ops =3D=
 {
  	.get_link	=3D ethtool_op_get_link,
  };

+int br_get_iflink(const struct net_device *dev)
+{
+	return dev->ifindex;
+}
+
  static const struct net_device_ops br_netdev_ops =3D {
  	.ndo_open		 =3D br_dev_open,
  	.ndo_stop		 =3D br_dev_stop,
@@ -339,6 +344,7 @@ static const struct net_device_ops br_netdev_ops =3D=
 {
  	.ndo_bridge_getlink	 =3D br_getlink,
  	.ndo_bridge_setlink	 =3D br_setlink,
  	.ndo_bridge_dellink	 =3D br_dellink,
+	.ndo_get_iflink		 =3D br_get_iflink,
  };

  static void br_dev_free(struct net_device *dev)
--=20
2.4.2
