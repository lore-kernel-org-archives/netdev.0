From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFS seems to have incompatiblities with bridged vlans
Date: Tue, 08 Jun 2010 16:18:41 +0200
Message-ID: <1276006721.2486.141.camel@edumazet-laptop>
References: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net>
	 <20100607145910.2458ac87@nehalam>  <4C0D7312.1020300@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Peter Lieven <pl@dlh.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40878 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354Ab0FHOSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 10:18:47 -0400
Received: by fxm8 with SMTP id 8so2921730fxm.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 07:18:45 -0700 (PDT)
In-Reply-To: <4C0D7312.1020300@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 juin 2010 =C3=A0 15:30 -0700, John Fastabend a =C3=A9crit :

> There is always a possibility that the underlying device sets the=20
> queue_mapping to be greater then num_cpus.  Also I suspect the same=20
> issue exists with bonding devices.  Maybe something like the followin=
g=20
> is worth while? compile tested only,
>=20
> [PATCH] 8021q: vlan reassigns dev without check queue_mapping
>=20
> recv path reassigns skb->dev without sanity checking the
> queue_mapping field.  This can result in the queue_mapping
> field being set incorrectly if the new dev supports less
> queues then the underlying device.
>=20
> This patch just resets the queue_mapping to 0 which should
> resolve this issue?  Any thoughts?
>=20
> The same issue could happen on bonding devices as well.
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>=20
>   net/8021q/vlan_core.c |    6 ++++++
>   1 files changed, 6 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index bd537fc..ad309f8 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -21,6 +21,9 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct=20
> vlan_group *grp,
>   	if (!skb->dev)
>   		goto drop;
>=20
> +	if (unlikely(skb->queue_mapping >=3D skb->dev->real_num_tx_queues))
> +		skb_set_queue_mapping(skb, 0);
> +
>   	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
>=20
>   drop:
> @@ -93,6 +96,9 @@ vlan_gro_common(struct napi_struct *napi, struct=20
> vlan_group *grp,
>   	if (!skb->dev)
>   		goto drop;
>=20
> +	if (unlikely(skb->queue_mapping >=3D skb->dev->real_num_tx_queues))
> +		skb_set_queue_mapping(skb, 0);
> +
>   	for (p =3D napi->gro_list; p; p =3D p->next) {
>   		NAPI_GRO_CB(p)->same_flow =3D
>   			p->dev =3D=3D skb->dev && !compare_ether_header(
> --

Only a workaround, added in hot path in a otherwise 'good' driver
(multiqueue enabled and ready)

eth0  -------> bond / bridge ---------> vlan.id
(nbtxq=3D8)      (ntxbq=3D1)        (nbtxq=3DX)

X is capped to 1 because of bond/bridge, while bond has no "queue"
(LLTX driver)

Solutions :

1) queue_mapping could be silently tested in get_rps_cpu()...

diff --git a/net/core/dev.c b/net/core/dev.c
index 6f330ce..3a3f7f6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2272,14 +2272,11 @@ static int get_rps_cpu(struct net_device *dev, =
struct sk_buff *skb,
=20
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index =3D skb_get_rx_queue(skb);
-		if (unlikely(index >=3D dev->num_rx_queues)) {
-			if (net_ratelimit()) {
-				pr_warning("%s received packet on queue "
-					"%u, but number of RX queues is %u\n",
-					dev->name, index, dev->num_rx_queues);
-			}
-			goto done;
-		}
+		if (WARN_ONCE(index >=3D dev->num_rx_queues,
+				KERN_WARNING "%s received packet on queue %u, "
+				"but number of RX queues is %u\n",
+				dev->name, index, dev->num_rx_queues))
+			index %=3D dev->num_rx_queues;
 		rxqueue =3D dev->_rx + index;
 	} else
 		rxqueue =3D dev->_rx;



2) bond/bridge should setup more queues, just in case.
   We probably need to be able to make things more dynamic,
   (propagate nbtxq between layers) but not for 2.6.35



diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 5e12462..ce813dd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5012,8 +5012,8 @@ int bond_create(struct net *net, const char *name=
)
=20
 	rtnl_lock();
=20
-	bond_dev =3D alloc_netdev(sizeof(struct bonding), name ? name : "",
-				bond_setup);
+	bond_dev =3D alloc_netdev_mq(sizeof(struct bonding), name ? name : ""=
,
+				   bond_setup, max(64, nr_cpu_ids));
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
 		rtnl_unlock();


