From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 13/13] ixgbe: use per NUMA node lock for FCoE DDP
Date: Sat, 11 Jun 2011 07:18:02 +0200
Message-ID: <1307769482.2872.62.camel@edumazet-laptop>
References: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1307761341-5267-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Vasu Dev <vasu.dev@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63935 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab1FKFSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 01:18:07 -0400
Received: by wwa36 with SMTP id 36so3365369wwa.1
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 22:18:06 -0700 (PDT)
In-Reply-To: <1307761341-5267-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 juin 2011 =C3=A0 20:02 -0700, Jeff Kirsher a =C3=A9crit =
:
> From: Vasu Dev <vasu.dev@intel.com>
>=20
> Adds per NUMA node lock to have CPU pass thru its NUMA lock
> first before contending for global DDP fcoe->lock to setup
> DDP lock, this is to reduce contentions across NUMA nodes.
>=20
> Allocates and initialize per NUMA node lock in added
> ixgbe_fcoe_lock_init and then have current CPU's numa_node_id
> based NUMA node lock acquired before taking global fcoe->lock.
>=20
> The node lock is allocated from its NUMA node using kzalloc_node.
>=20
> Signed-off-by: Vasu Dev <vasu.dev@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ixgbe/ixgbe_fcoe.c |   50 ++++++++++++++++++++++++++++++=
++++++++-
>  drivers/net/ixgbe/ixgbe_fcoe.h |    1 +
>  2 files changed, 49 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe=
_fcoe.c
> index f5f39ed..aadff4f 100644
> --- a/drivers/net/ixgbe/ixgbe_fcoe.c
> +++ b/drivers/net/ixgbe/ixgbe_fcoe.c
> @@ -109,6 +109,7 @@ int ixgbe_fcoe_ddp_put(struct net_device *netdev,=
 u16 xid)
>  	len =3D ddp->len;
>  	/* if there an error, force to invalidate ddp context */
>  	if (ddp->err) {
> +		spin_lock(fcoe->node_lock[numa_node_id()]);
>  		spin_lock_bh(&fcoe->lock);
>  		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCFLT, 0);
>  		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCFLTRW,
> @@ -122,6 +123,7 @@ int ixgbe_fcoe_ddp_put(struct net_device *netdev,=
 u16 xid)
>  				(xid | IXGBE_FCDMARW_RE));
>  		fcbuff =3D IXGBE_READ_REG(&adapter->hw, IXGBE_FCBUFF);
>  		spin_unlock_bh(&fcoe->lock);
> +		spin_unlock(fcoe->node_lock[numa_node_id()]);
>  		if (fcbuff & IXGBE_FCBUFF_VALID)
>  			udelay(100);
>  	}
> @@ -294,6 +296,7 @@ static int ixgbe_fcoe_ddp_setup(struct net_device=
 *netdev, u16 xid,
> =20
>  	/* program DMA context */
>  	hw =3D &adapter->hw;
> +	spin_lock(fcoe->node_lock[numa_node_id()]);
>  	spin_lock_bh(&fcoe->lock);
> =20
>  	/* turn on last frame indication for target mode as FCP_RSPtarget i=
s
> @@ -315,6 +318,7 @@ static int ixgbe_fcoe_ddp_setup(struct net_device=
 *netdev, u16 xid,
>  	IXGBE_WRITE_REG(hw, IXGBE_FCFLTRW, fcfltrw);
> =20
>  	spin_unlock_bh(&fcoe->lock);
> +	spin_unlock(fcoe->node_lock[numa_node_id()]);
> =20
>  	return 1;
> =20
> @@ -634,6 +638,42 @@ static void ixgbe_fcoe_ddp_pools_alloc(struct ix=
gbe_adapter *adapter)
>  	}
>  }
> =20
> +static void ixgbe_fcoe_locks_free(struct ixgbe_fcoe *fcoe)
> +{
> +	int node;
> +
> +	if (!fcoe->node_lock)
> +		return;
> +
> +	for_each_node_with_cpus(node)
> +			kfree(fcoe->node_lock[node]);
> +
> +	kfree(fcoe->node_lock);
> +	fcoe->node_lock =3D NULL;
> +}
> +
> +static void ixgbe_fcoe_lock_init(struct ixgbe_fcoe *fcoe)
> +{
> +	int node;
> +	spinlock_t *node_lock;
> +
> +	fcoe->node_lock =3D kzalloc(sizeof(node_lock) * num_possible_nodes(=
),
> +				  GFP_KERNEL);

Hmm...

1) Think of what happens if some machine has 3 possible nodes : 0, 2, 3

	-> You should use nr_node_ids instead of num_possible_nodes()=20

2) Make sure this block cant have false sharing : Allocate at least a
full cache line : On a typical 2 node machine, you currently allocate
16bytes of memory, and this small block could share a contended cache
line.


> +	if (!fcoe->node_lock)
> +		return;
> +
> +	for_each_node_with_cpus(node) {
> +		node_lock =3D kzalloc_node(sizeof(*node_lock) , GFP_KERNEL, node);
> +		if (!node_lock) {
> +			ixgbe_fcoe_locks_free(fcoe);
> +			return;
> +		}
> +		spin_lock_init(node_lock);
> +		fcoe->node_lock[node] =3D node_lock;
> +	}
> +	spin_lock_init(&fcoe->lock);
> +}
> +

=2E..

> =20
>  /**
> diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe=
_fcoe.h
> index d876e7a..8618892 100644
> --- a/drivers/net/ixgbe/ixgbe_fcoe.h
> +++ b/drivers/net/ixgbe/ixgbe_fcoe.h
> @@ -69,6 +69,7 @@ struct ixgbe_fcoe {
>  	struct pci_pool **pool;
>  	atomic_t refcnt;
>  	spinlock_t lock;
> +	struct spinlock **node_lock;

Wont this read_mostly pointer sits in often modified cache line ?

>  	struct ixgbe_fcoe_ddp ddp[IXGBE_FCOE_DDP_MAX];
>  	unsigned char *extra_ddp_buffer;
>  	dma_addr_t extra_ddp_buffer_dma;


