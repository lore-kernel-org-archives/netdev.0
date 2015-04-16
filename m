From: Erez Shitrit <erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH linux-next 1/4] infiniband/ipoib: fix possible NULL
 pointer dereference in ipoib_get_iflink
Date: Thu, 16 Apr 2015 14:27:59 +0300
Message-ID: <CAAk-MO9Y-k1Rw5OpmXu5eD=qVKNqcyuL6=KxO=MS6T+ujqqmgg@mail.gmail.com>
References: <1429024817-21561-1-git-send-email-honli@redhat.com>
	<1429024817-21561-2-git-send-email-honli@redhat.com>
	<CAAk-MO-O9sjHQvDfCEuzJJPvUMXJTuRaCzrCkB0xc1DUfK8Aew@mail.gmail.com>
	<20150414204133.GJ7682@obsidianresearch.com>
	<552E026A.4020200@dev.mellanox.co.il>
	<20150415160623.GA4653@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Honggang Li <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Alex Estrin <alex.estrin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	Mahesh Bandewar <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org,
	andrew-g2DYL2Zd6BY@public.gmane.org, Scott Feldman <sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150415160623.GA4653-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2015 at 7:06 PM, Jason Gunthorpe
<jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> On Wed, Apr 15, 2015 at 09:17:14AM +0300, Erez Shitrit wrote:
>> >>+       /* parent interface */
>> >>+       if (!test_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags))
>> >>+               return dev->ifindex;
>> >>+
>> >>+       /* child/vlan interface */
>> >>+       if (!priv->parent)
>> >>+               return -1;
>
>> >Like was said for other drivers, I can't see how parent can be null
>> >while IPOIB_FLAG_SUBINTERFACE is set. Drop the last if.
>
>> It can, at least for ipoib child interface (AKA "vlan"), you can't
>> control the call for that ndo and it can be called before the parent
>> was set.
>
> If the ndo can be called before the netdev private structures are fully
> prepared then we have another bug, and returning -1 or 0 is not the right
> answer anyhow.
>
> For safety, fold this into your patch.

OK, will do that.

>
> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
> index 9fad7b5ac8b9..e62b007adf5d 100644
> --- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
> @@ -58,6 +58,7 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
>         /* MTU will be reset when mcast join happens */
>         priv->dev->mtu   = IPOIB_UD_MTU(priv->max_ib_mtu);
>         priv->mcast_mtu  = priv->admin_mtu = priv->dev->mtu;
> +       priv->parent = ppriv->dev;
>         set_bit(IPOIB_FLAG_SUBINTERFACE, &priv->flags);
>
>         result = ipoib_set_dev_features(priv, ppriv->ca);
> @@ -84,8 +85,6 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
>                 goto register_failed;
>         }
>
> -       priv->parent = ppriv->dev;
> -
>         ipoib_create_debug_files(priv->dev);
>
>         /* RTNL childs don't need proprietary sysfs entries */
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
