From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] infiniband: remove dev_base_lock use
Date: Wed, 24 Nov 2010 14:47:48 +0100
Message-ID: <1290606468.3464.38.camel@edumazet-laptop>
References: <1288350226.2560.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1288350226.2560.11.camel@edumazet-laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Le vendredi 29 octobre 2010 =C3=A0 13:03 +0200, Eric Dumazet a =C3=A9cr=
it :
> dev_base_lock is the legacy way to lock the device list, and is plann=
ed
> to disappear. (writers hold RTNL, readers hold RCU lock)
>=20
> Convert rdma_translate_ip() to RCU locking.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/infiniband/core/addr.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core=
/addr.c
> index a5ea1bc..309b477 100644
> --- a/drivers/infiniband/core/addr.c
> +++ b/drivers/infiniband/core/addr.c
> @@ -130,8 +130,8 @@ int rdma_translate_ip(struct sockaddr *addr, stru=
ct rdma_dev_addr *dev_addr)
> =20
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>  	case AF_INET6:
> -		read_lock(&dev_base_lock);
> -		for_each_netdev(&init_net, dev) {
> +		rcu_read_lock();
> +		for_each_netdev_rcu(&init_net, dev) {
>  			if (ipv6_chk_addr(&init_net,
>  					  &((struct sockaddr_in6 *) addr)->sin6_addr,
>  					  dev, 1)) {
> @@ -139,7 +139,7 @@ int rdma_translate_ip(struct sockaddr *addr, stru=
ct rdma_dev_addr *dev_addr)
>  				break;
>  			}
>  		}
> -		read_unlock(&dev_base_lock);
> +		rcu_read_unlock();
>  		break;
>  #endif
>  	}
>=20

Here is a new version of patch.

David, it seems no infiniband guy commented this patch, could you take
it in your tree ?

Thanks

[PATCH] infiniband: remove dev_base_lock use

dev_base_lock is the legacy way to lock the device list, and is planned
to disappear. (writers hold RTNL, readers hold RCU lock)

Convert rdma_translate_ip() and update_ipv6_gids() to RCU locking.

Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/addr.c    |    6 +++---
 drivers/infiniband/hw/mlx4/main.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/a=
ddr.c
index c15fd2e..8aba0ba 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -130,8 +130,8 @@ int rdma_translate_ip(struct sockaddr *addr, struct=
 rdma_dev_addr *dev_addr)
=20
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
-		read_lock(&dev_base_lock);
-		for_each_netdev(&init_net, dev) {
+		rcu_read_lock();
+		for_each_netdev_rcu(&init_net, dev) {
 			if (ipv6_chk_addr(&init_net,
 					  &((struct sockaddr_in6 *) addr)->sin6_addr,
 					  dev, 1)) {
@@ -139,7 +139,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct=
 rdma_dev_addr *dev_addr)
 				break;
 			}
 		}
-		read_unlock(&dev_base_lock);
+		rcu_read_unlock();
 		break;
 #endif
 	}
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/=
mlx4/main.c
index bf3e20c..4e55a28 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -848,8 +848,8 @@ static int update_ipv6_gids(struct mlx4_ib_dev *dev=
, int port, int clear)
 		goto out;
 	}
=20
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, tmp) {
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, tmp) {
 		if (ndev && (tmp =3D=3D ndev || rdma_vlan_dev_real_dev(tmp) =3D=3D n=
dev)) {
 			gid.global.subnet_prefix =3D cpu_to_be64(0xfe80000000000000LL);
 			vid =3D rdma_vlan_dev_vlan_id(tmp);
@@ -884,7 +884,7 @@ static int update_ipv6_gids(struct mlx4_ib_dev *dev=
, int port, int clear)
 			}
 		}
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
=20
 	for (i =3D 0; i < 128; ++i)
 		if (!hits[i]) {


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
