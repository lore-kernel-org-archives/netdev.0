From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [net v3] veth: advertise peer link once both links are tied
 together
Date: Wed, 8 Jun 2016 16:30:49 -0400 (EDT)
Message-ID: <694175272.49661350.1465417849878.JavaMail.zimbra@redhat.com>
References: <574C6095.9050804@6wind.com> <1464623917-11536-1-git-send-email-vincent@bernat.im> <87bn3n358j.fsf@zoro.exoscale.ch> <574C69DE.3050305@6wind.com> <m3fusyg2pi.fsf@neo.luffy.cx> <574D56A0.3090606@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: nicolas dichtel <nicolas.dichtel@6wind.com>,
	Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:60311 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233AbcFHUa7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 16:30:59 -0400
In-Reply-To: <574D56A0.3090606@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> From: "Nicolas Dichtel" <nicolas.dichtel@6wind.com>
> To: "Vincent Bernat" <vincent@bernat.im>
> Cc: "David S. Miller" <davem@davemloft.net>, "Vijay Pandurangan" <vij=
ayp@vijayp.ca>, "Paolo Abeni"
> <pabeni@redhat.com>, netdev@vger.kernel.org
> Sent: Tuesday, May 31, 2016 5:17:20 AM
> Subject: Re: [net v3] veth: advertise peer link once both links are t=
ied together
>=20
> Le 31/05/2016 08:29, Vincent Bernat a =C3=A9crit :
> >  =E2=9D=A6 30 mai 2016 18:27 CEST, Nicolas Dichtel <nicolas.dichtel=
@6wind.com> :
> >=20
> >>>> +
> >>>> +	rtmsg_ifinfo(RTM_NEWLINK, peer, IFF_SLAVE, GFP_KERNEL);
> >>>
> >>> Maybe ~0U would be better than hijacking IFF_SLAVE?
> >> IFF_SLAVE is wrong. It's a flag here, that will be put in the ifi_=
change
> >> field
> >> not an attribute number.
> >=20
> > There are some use of IFF_SLAVE (in bonding/bond_main.c). But, I'll
> > update the patch nonetheless.
> Sorry, I read it too quickly, IFF_SLAVE is a flag, not an attribute.
> But this field indicates to the userland which flags has changed and =
this
> flag
> does not change here ;-)
>=20

I've been pondering how to fix this very problem off-and-on for a few m=
onths
now, without having arrived at any solution that was particularly satis=
fying.

The main constraints I've been trying to meet are:
   - User-space should be informed of veth pairing for both peers.
   - RTM_NEWLINK messages should not refer to interfaces that haven't
     been announced to user-space via previous RTM_NEWLINK messages.
   - The first (and only the first) RTM_NEWLINK message for a given
     interface should have ifi_changes set to ~0U, subsequent RTM_NEWLI=
NK
     messages should have ifi_changes set to reflect the flags that
     have changed.

This is the closest I've come to a satisfactory solution, it does meet
the above constraints but still seems a little unnatural to me:

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f37a6e6..9151686 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -466,8 +466,16 @@ static int veth_newlink(struct net *src_net, struc=
t net_device *dev,
=20
        priv =3D netdev_priv(peer);
        rcu_assign_pointer(priv->peer, dev);
+
+       err =3D rtnl_configure_link(dev, NULL);
+       if (err < 0)
+               goto err_configure_dev;
+
+       rtmsg_ifinfo(RTM_NEWLINK, peer, 0, GFP_KERNEL);
        return 0;
=20
+err_configure_dev:
+       /* nothing to do */
 err_register_dev:
        /* nothing to do */
 err_configure_peer:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d69c464..28ee417 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2165,6 +2165,7 @@ static int rtnl_dellink(struct sk_buff *skb, stru=
ct nlmsghdr *nlh)
 int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg=
 *ifm)
 {
        unsigned int old_flags;
+       unsigned int gchanges;
        int err;
=20
        old_flags =3D dev->flags;
@@ -2174,9 +2175,13 @@ int rtnl_configure_link(struct net_device *dev, =
const struct ifinfomsg *ifm)
                        return err;
        }
=20
-       dev->rtnl_link_state =3D RTNL_LINK_INITIALIZED;
+       if (dev->rtnl_link_state =3D=3D RTNL_LINK_INITIALIZING) {
+               dev->rtnl_link_state =3D RTNL_LINK_INITIALIZED;
+               gchanges =3D ~0U;
+       } else
+               gchanges =3D dev->flags ^ old_flags;
=20
-       __dev_notify_flags(dev, old_flags, ~0U);
+       __dev_notify_flags(dev, old_flags, gchanges);
        return 0;
 }
 EXPORT_SYMBOL(rtnl_configure_link);

Sample output:

# ip link add dev vm1 type veth peer name vm2
5: vm2@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN=20
    link/ether 36:a7:b4:dc:27:3b brd ff:ff:ff:ff:ff:ff
6: vm1@vm2: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN=
=20
    link/ether 72:78:30:f6:e6:3a brd ff:ff:ff:ff:ff:ff
5: vm2@vm1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN=
=20
    link/ether 36:a7:b4:dc:27:3b brd ff:ff:ff:ff:ff:ff
