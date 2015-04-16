From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V1 net-next] IB/ipoib: Fix ndo_get_iflink
Date: Thu, 16 Apr 2015 22:08:13 +0300
Message-ID: <CAJ3xEMhauY9Rjaiyf4sGUKQjAnfszDK8WDsG17yXkxTRsv5TCg@mail.gmail.com>
References: <1429191274-11600-1-git-send-email-erezsh@mellanox.com>
	<1429200634.4333.9.camel@opteya.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1429200634.4333.9.camel-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 16, 2015, Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org> wrote:
> Hi,
>
> Le jeudi 16 avril 2015 =C3=A0 16:34 +0300, Erez Shitrit a =C3=A9crit =
:
>> Currently, iflink of the parent interface was always accessed, even
>> when interface didn't have a parent and hence we crashed there.
>
> + since commit 5aa7add8f14b ('infiniband/ipoib: implement
> ndo_get_iflink').
>
> as there was no crash here before AFAIK.

Disagree, it's redundant, as the Fixes tag below points to this commit


>> Handle the interface types properly: for a child interface, return
>> the ifindex of the parent, for parent interface, return its ifindex.
>>
>> For child devices, make sure to set the parent pointer prior to
>> invoking register_netdevice(), this allows the new ndo to be called
>> by the stack immediately after the child device is registered.
>>
>> Fixes: 5aa7add8f14b ('infiniband/ipoib: implement ndo_get_iflink')
>
> Cc: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>

Ditto, I find it enough to just copy Nicholas on the patch submission,
as we did here.

Or.

>> Reported-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>> Signed-off-by: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> ---
>>
>> changes from V0:
>>  - fixed two typos in the change-log
>>
>>  drivers/infiniband/ulp/ipoib/ipoib_main.c | 5 +++++
>>  drivers/infiniband/ulp/ipoib/ipoib_vlan.c | 3 +--
>>  2 files changed, 6 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/inf=
iniband/ulp/ipoib/ipoib_main.c
>> index 657b89b..915ad04 100644
>> --- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
>> +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
>> @@ -846,6 +846,11 @@ static int ipoib_get_iflink(const struct net_de=
vice *dev)
>>  {
>>       struct ipoib_dev_priv *priv =3D netdev_priv(dev);
>>
>> +     /* parent interface */
>> +     if (!test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags))
>> +             return dev->ifindex;
>> +
>> +     /* child/vlan interface */
>>       return priv->parent->ifindex;
>>  }
>>
>> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/inf=
iniband/ulp/ipoib/ipoib_vlan.c
>> index 4dd1313..fca1a88 100644
>> --- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
>> +++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
>> @@ -58,6 +58,7 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv,=
 struct ipoib_dev_priv *priv,
>>       /* MTU will be reset when mcast join happens */
>>       priv->dev->mtu   =3D IPOIB_UD_MTU(priv->max_ib_mtu);
>>       priv->mcast_mtu  =3D priv->admin_mtu =3D priv->dev->mtu;
>> +     priv->parent =3D ppriv->dev;
>>       set_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags);
>>
>>       result =3D ipoib_set_dev_features(priv, ppriv->ca);
>> @@ -84,8 +85,6 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv,=
 struct ipoib_dev_priv *priv,
>>               goto register_failed;
>>       }
>>
>> -     priv->parent =3D ppriv->dev;
>> -
>>       ipoib_create_debug_files(priv->dev);
>>
>>       /* RTNL childs don't need proprietary sysfs entries */
>
> Regards.
>
> --
> Yann Droneaud
> OPTEYA
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma"=
 in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
