From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] net: disallow drivers with buggy VLAN accel
 to register_netdevice()
Date: Tue, 29 Jan 2013 20:17:45 -0500
Message-ID: <510874B9.5000208@redhat.com>
References: <c7fdfc32f69e7a4c3bfcaa8b2ee842aa9b286c91.1359507017.git.mirq-linux@rere.qmqm.pl>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, shemminger@vyatta.com
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35773 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751586Ab3A3BRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 20:17:53 -0500
In-Reply-To: <c7fdfc32f69e7a4c3bfcaa8b2ee842aa9b286c91.1359507017.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2013 08:14 PM, Micha=C5=82 Miros=C5=82aw wrote:
> Instead of jumping aroung bugs that are easily fixed just don't let t=
hem in:
> affected drivers should be either fixed or have NETIF_F_HW_VLAN_FILTE=
R
> removed from advertised features.
>
> Quick grep in drivers/net shows two drivers that have NETIF_F_HW_VLAN=
_FILTER
> but not ndo_vlan_rx_add/kill_vid(), but those are false-positives (fe=
atures
> are commented out).
>
> OTOH two drivers have ndo_vlan_rx_add/kill_vid() implemented but don'=
t
> advertise NETIF_F_HW_VLAN_FILTER. Those are:

I am a bit hesitant to completely disable drivers, but I guess it would=
=20
force people to fix their drivers if this is applied.

-vlad

>
> +ethernet/cisco/enic/enic_main.c
> +ethernet/qlogic/qlcnic/qlcnic_main.c
>
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>   net/8021q/vlan.c      |    7 -------
>   net/8021q/vlan_core.c |    6 ++----
>   net/core/dev.c        |    8 ++++++++
>   3 files changed, 10 insertions(+), 11 deletions(-)
>
> Not run-tested. Survived make allmodconfig && make net/ drivers/net/
>
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index babfde9..addc578 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -117,19 +117,12 @@ void unregister_vlan_dev(struct net_device *dev=
, struct list_head *head)
>   int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
>   {
>   	const char *name =3D real_dev->name;
> -	const struct net_device_ops *ops =3D real_dev->netdev_ops;
>
>   	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
>   		pr_info("VLANs not supported on %s\n", name);
>   		return -EOPNOTSUPP;
>   	}
>
> -	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
> -	    (!ops->ndo_vlan_rx_add_vid || !ops->ndo_vlan_rx_kill_vid)) {
> -		pr_info("Device %s has buggy VLAN hw accel\n", name);
> -		return -EOPNOTSUPP;
> -	}
> -
>   	if (vlan_find_dev(real_dev, vlan_id) !=3D NULL)
>   		return -EEXIST;
>
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 380440b..71b64fd 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -224,8 +224,7 @@ static int __vlan_vid_add(struct vlan_info *vlan_=
info, unsigned short vid,
>   	if (!vid_info)
>   		return -ENOMEM;
>
> -	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
> -	    ops->ndo_vlan_rx_add_vid) {
> +	if (dev->features & NETIF_F_HW_VLAN_FILTER) {
>   		err =3D  ops->ndo_vlan_rx_add_vid(dev, vid);
>   		if (err) {
>   			kfree(vid_info);
> @@ -282,8 +281,7 @@ static void __vlan_vid_del(struct vlan_info *vlan=
_info,
>   	unsigned short vid =3D vid_info->vid;
>   	int err;
>
> -	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
> -	     ops->ndo_vlan_rx_kill_vid) {
> +	if (dev->features & NETIF_F_HW_VLAN_FILTER) {
>   		err =3D ops->ndo_vlan_rx_kill_vid(dev, vid);
>   		if (err) {
>   			pr_warn("failed to kill vid %d for device %s\n",
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a83375d..a87bc74 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6054,6 +6054,14 @@ int register_netdevice(struct net_device *dev)
>   		}
>   	}
>
> +	if (((dev->hw_features | dev->features) & NETIF_F_HW_VLAN_FILTER) &=
&
> +	    (!dev->netdev_ops->ndo_vlan_rx_add_vid ||
> +	     !dev->netdev_ops->ndo_vlan_rx_kill_vid)) {
> +		netdev_WARN(dev, "Buggy VLAN acceleration in driver!\n");
> +		ret =3D -EINVAL;
> +		goto err_uninit;
> +	}
> +
>   	ret =3D -EBUSY;
>   	if (!dev->ifindex)
>   		dev->ifindex =3D dev_new_index(net);
>
