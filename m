From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCH 1/2] Interface group: core (netlink) part
Date: Fri, 19 Oct 2007 10:57:43 +0200
Message-ID: <47187187.6090505@balabit.hu>
References: <11927025171404-git-send-email-panther@balabit.hu> <1192702517840-git-send-email-panther@balabit.hu> <471733D5.4000500@trash.net>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <471733D5.4000500@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy =EDrta:
> Laszlo Attila Toth wrote:
>> @@ -846,6 +850,12 @@ static int do_setlink(struct net_device *dev,=20
>> struct ifinfomsg *ifm,
>>          write_unlock_bh(&dev_base_lock);
>>      }
>> =20
>> +    if (tb[IFLA_IFGROUP]) {
>> +        write_lock_bh(&dev_base_lock);
>> +        dev->ifgroup =3D nla_get_u32(tb[IFLA_IFGROUP]);
>> +        write_unlock_bh(&dev_base_lock);
>> +    }
>=20
>=20
> So no notifications at all? Mhh .. I guess its OK for now, this stuff
> needs to be fixed to notify once for all changes anyway.
>=20

I'll resend the following patch with the new ifgroup patches. The=20
current changes: changes are now atomic and a notification will be send=
=20
later at the end of the function. If an address was changed, a=20
notification will be send and after that another which is always sent=20
when anyi modification happened.

This patch may not be complete.


diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4756d58..87ab3ff 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -819,6 +819,7 @@ static int do_setlink(struct net_device *dev, struc=
t=20
ifinfomsg *ifm,
         if (tb[IFLA_BROADCAST]) {
                 nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST],=20
dev->addr_len);
                 send_addr_notify =3D 1;
+               modified =3D 1;
         }

         if (ifm->ifi_flags || ifm->ifi_change) {
@@ -829,21 +830,35 @@ static int do_setlink(struct net_device *dev,=20
struct ifinfomsg *ifm,
                         flags =3D (flags & ifm->ifi_change) |
                                 (dev->flags & ~ifm->ifi_change);
                 dev_change_flags(dev, flags);
+               modified =3D 1;
         }

-       if (tb[IFLA_TXQLEN])
+       if (tb[IFLA_TXQLEN]) {
+               write_lock_bh(&dev_base_lock);
                 dev->tx_queue_len =3D nla_get_u32(tb[IFLA_TXQLEN]);
+               write_unlock_bh(&dev_base_lock);
+               modified =3D 1;
+       }

-       if (tb[IFLA_WEIGHT])
+       if (tb[IFLA_WEIGHT]) {
+               write_lock_bh(&dev_base_lock);
                 dev->weight =3D nla_get_u32(tb[IFLA_WEIGHT]);
+               write_unlock_bh(&dev_base_lock);
+               modified =3D 1;
+       }

-       if (tb[IFLA_OPERSTATE])
+       if (tb[IFLA_OPERSTATE]) {
+               write_lock_bh(&dev_base_lock);
                 set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
+               write_unlock_bh(&dev_base_lock);
+               modified =3D 1;
+       }

         if (tb[IFLA_LINKMODE]) {
                 write_lock_bh(&dev_base_lock);
                 dev->link_mode =3D nla_get_u8(tb[IFLA_LINKMODE]);
                 write_unlock_bh(&dev_base_lock);
+               modified =3D 1;
         }

         err =3D 0;
@@ -857,6 +872,8 @@ errout:

         if (send_addr_notify)
                 call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
+       if (modified)
+               rtmsg_ifinfo(RTM_NEWLINK, dev, 0)
         return err;
  }

-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
