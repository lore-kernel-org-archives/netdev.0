From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2.6.33 2/2] jme: Adding lock to protect vlgrp
 structure.
Date: Tue, 16 Mar 2010 08:40:24 +0100
Message-ID: <1268725224.2824.22.camel@edumazet-laptop>
References: <1268630132-10410-2-git-send-email-cooldavid@cooldavid.org>
	 <97949e3e1003151122q68ce19f4ja7f53ad380d3033f@mail.gmail.com>
	 <20100315191339.M2560@cooldavid.org>
	 <20100315.155350.26952440.davem@davemloft.net>
	 <20100316071242.M65171@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, chavey@google.com,
	ethanhsiao@jmicron.com, netdev@vger.kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:48570 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757156Ab0CPHka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 03:40:30 -0400
Received: by bwz1 with SMTP id 1so3626105bwz.21
        for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 00:40:29 -0700 (PDT)
In-Reply-To: <20100316071242.M65171@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 mars 2010 =C3=A0 15:15 +0800, Guo-Fu Tseng a =C3=A9crit :
> On Mon, 15 Mar 2010 15:53:50 -0700 (PDT), David Miller wrote
> > From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
> > Date: Tue, 16 Mar 2010 03:13:33 +0800
> >=20
> > > The vlan_rx_register is called through ioctl.
> > > And the packet feeding is called in the tasklet.
> > > I see no lock in register_vlan_dev(), register_vlan_device(), and=
 vlan_ioctl_handler()
> > > which is related to the vlan_hwaccel_receive_skb(), vlan_hwaccel_=
rx().
> > >=20
> > > It prevents the vlgrp pointer be modified while trying to feed th=
e packet.
> >=20
> > This is not how you fix this.  Adding a new lock to your hot code
> > path of packet receiving is the last thing you should be doing.
> >=20
> > Instead, do what other drivers do, take down the device and bring i=
t
> > back up again when changing the ->vlgrp pointer.
> >=20
> > See drivers/net/tg3.c:tg3_vlan_rx_register() for an example.
> I see. I'll work on it.

Then if driver is NAPI enabled, another possibility would be to rely on
RCU, since vgrp are already freed after a RCU grace period.

Completely untested patch, for ease of discussion

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 0f31497..e19de8d 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -942,8 +942,10 @@ jme_alloc_and_feed_skb(struct jme_adapter *jme, in=
t idx)
 			skb->ip_summed =3D CHECKSUM_NONE;
=20
 		if (rxdesc->descwb.flags & cpu_to_le16(RXWBFLAG_TAGON)) {
-			if (jme->vlgrp) {
-				jme->jme_vlan_rx(skb, jme->vlgrp,
+			struct vlan_group *grp =3D rcu_dereference(jme->vlgrp);
+
+			if (grp) {
+				jme->jme_vlan_rx(skb, grp,
 					le16_to_cpu(rxdesc->descwb.vlan));
 				NET_STAT(jme).rx_bytes +=3D 4;
 			}


