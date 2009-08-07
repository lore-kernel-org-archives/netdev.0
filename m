From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [Socketcan-users] [PATCH] CAN: make checking in can_rcv less
 restrictive
Date: Fri, 07 Aug 2009 13:35:26 +0200
Message-ID: <4A7C117E.5010005@hartkopp.net>
References: <1249572295-7801-1-git-send-email-l.fu@pengutronix.de> <4A7B0957.5020808@hartkopp.net> <200908070952.56922.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"socketcan-users@lists.berlios.de" <socketcan-users@lists.berlios.de>,
	Michael Olbrich <m.olbrich@pengutronix.de>
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>, Luotao Fu <l.fu@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:43768 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757561AbZHGLfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 07:35:37 -0400
In-Reply-To: <200908070952.56922.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=E9mi Denis-Courmont wrote:
> Moving to netdev....
>=20
> On Thursday 06 August 2009 19:48:23 ext Oliver Hartkopp wrote:
>> The CAN applications can rely on getting proper CAN frames with this=
 check.
>> It was introduced some time ago together with several other sanity c=
hecks -
>> even on the TX path.
>>
>> The CAN core *only* consumes skbuffs originated from a CAN netdevice
>> (ARPHRD_CAN).
>>
>> When this BUG() triggers, someone provided a definitely broken *CAN*
>> network driver, and this needs to be fixed on that level. It is real=
ly not
>> that problematic to ensure proper CAN frames on driver level ... thi=
s
>> sanity check should not be needed to be performed by every single
>> application.
>=20
> AFAIK, the TUN driver can inject layer-2 frames of any type, any size=
 and any=20
> content from userspace into the packet type handler. Sure enough, you=
 need=20
> CAP_NET_ADMIN and r/w access to /dev/net/tun but is it sufficient to =
bring the=20
> system down?
>=20

The complete code section currently looks like this:


static int can_rcv(struct sk_buff *skb, struct net_device *dev,
                   struct packet_type *pt, struct net_device *orig_dev)
{
        struct dev_rcv_lists *d;
        struct can_frame *cf =3D (struct can_frame *)skb->data;
        int matches;

        if (dev->type !=3D ARPHRD_CAN || !net_eq(dev_net(dev), &init_ne=
t)) {
                kfree_skb(skb);
                return 0;
        }

        BUG_ON(skb->len !=3D sizeof(struct can_frame) || cf->can_dlc > =
8);

(..)

So you would need to have an originating interface with ARPHRD_CAN ...

Do you think, it's still possible with the TUN driver?


@Luotao: I talked to Urs and we discussed to prepare a patch that only =
creates
a warning and drops the skb afterwards, as the problem is not critical =
for a
proper ongoing kernel operation. I think, that was you original intenti=
on:

       if (!net_eq(dev_net(dev), &init_net) ||
           WARN_ON(dev->type !=3D ARPHRD_CAN) ||
           WARN_ON(skb->len !=3D sizeof(struct can_frame) || cf->can_dl=
c > 8)) {
               kfree_skb(skb);
               return NET_RX_BAD;
       }

Would this be ok for you?

Regards,
Oliver

