From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: deliver skbs on inactive slaves to exact
 matches
Date: Mon, 14 Jun 2010 15:34:43 +0200
Message-ID: <1276522483.2478.88.camel@edumazet-laptop>
References: <20100603193011.4916.12354.stgit@jf-dev2-dcblab>
	 <20100614132120.GA24785@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>, fubar@us.ibm.com,
	davem@davemloft.net, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:53636 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab0FNNmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 09:42:32 -0400
Received: by wwb18 with SMTP id 18so3840093wwb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 06:42:31 -0700 (PDT)
In-Reply-To: <20100614132120.GA24785@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: John Fastabend <john.r.fastabend@intel.com>

Le lundi 14 juin 2010 =C3=A0 16:21 +0300, Michael S. Tsirkin a =C3=A9cr=
it :
> On Thu, Jun 03, 2010 at 12:30:11PM -0700, John Fastabend wrote:
> > Currently, the accelerated receive path for VLAN's will
> > drop packets if the real device is an inactive slave and
> > is not one of the special pkts tested for in
> > skb_bond_should_drop().  This behavior is different then
> > the non-accelerated path and for pkts over a bonded vlan.
> >=20
> > For example,
> >=20
> > vlanx -> bond0 -> ethx
> >=20
> > will be dropped in the vlan path and not delivered to any
> > packet handlers at all.  However,
> >=20
> > bond0 -> vlanx -> ethx
> >=20
> > and
> >=20
> > bond0 -> ethx
> >=20
> > will be delivered to handlers that match the exact dev,
> > because the VLAN path checks the real_dev which is not a
> > slave and netif_recv_skb() doesn't drop frames but only
> > delivers them to exact matches.
> >=20
> > This patch adds a sk_buff flag which is used for tagging
> > skbs that would previously been dropped and allows the
> > skb to continue to skb_netif_recv().  Here we add
> > logic to check for the deliver_no_wcard flag and if it
> > is set only deliver to handlers that match exactly.  This
> > makes both paths above consistent and gives pkt handlers
> > a way to identify skbs that come from inactive slaves.
> > Without this patch in some configurations skbs will be
> > delivered to handlers with exact matches and in others
> > be dropped out right in the vlan path.
> >=20
> > I have tested the following 4 configurations in failover modes
> > and load balancing modes.
> >=20
> > # bond0 -> ethx
> >=20
> > # vlanx -> bond0 -> ethx
> >=20
> > # bond0 -> vlanx -> ethx
> >=20
> > # bond0 -> ethx
> >             |
> >   vlanx -> --
> >=20
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>=20
> I am using qemu with both tap and slirp (userspace) networking.
> This works fine under 2.6.35-rc2 but breaks under 2.6.35-rc3:
> ssh over slirp stops working sometimes right away
> and sometimes after a bit of use, connection times out.
>=20
> Git bisect gave me this commit:
> 597a264b1a9c7e36d1728f677c66c5c1f7e3b837.
>=20
> Reverting 597a264b1a9c7e36d1728f677c66c5c1f7e3b837 fixes the issue
> for me.
>=20
> I'm short for time now so didn't debug this further.
> I opened a bugzilla to track this issue:
> https://bugzilla.kernel.org/show_bug.cgi?id=3D16204
>=20

A fix is already there, and bug is already opened multiple times.

http://lkml.org/lkml/2010/6/13/155

[PATCH] net: fix deliver_no_wcard regression on loopback device

deliver_no_wcard is not being set in skb_copy_header.
In the skb_cloned case it is not being cleared and
may cause the skb to be dropped when the loopback device
pushes it back up the stack.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9f07e74..bcf2fa3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -532,6 +532,7 @@ static void __copy_skb_header(struct sk_buff *new, =
const struct sk_buff *old)
 	new->ip_summed		=3D old->ip_summed;
 	skb_copy_queue_mapping(new, old);
 	new->priority		=3D old->priority;
+	new->deliver_no_wcard	=3D old->deliver_no_wcard;
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	new->ipvs_property	=3D old->ipvs_property;
 #endif


