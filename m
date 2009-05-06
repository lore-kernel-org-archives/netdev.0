From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-next] net: bridge: use device address list instead
 of	dev_addr (repost)
Date: Wed, 06 May 2009 17:08:06 +0200
Message-ID: <4A01A7D6.3030808@cosmosbay.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090415081720.GA21342@psychotron.englab.brq.redhat.com> <20090415082118.GC21342@psychotron.englab.brq.redhat.com> <20090506144624.GI28637@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, ivecera@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759049AbZEFPOZ@vger.kernel.org>
In-Reply-To: <20090506144624.GI28637@psychotron.englab.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Pirko a =E9crit :
> (repost, no modifications)

Well, some changes are welcome :)

>=20
> This patch changes the handling of mac addresses of bridge port devic=
es. Now
> it uses previously introduced list of device addresses. It allows the=
 bridge to
> know more then one local mac address per port which is mandatory for =
the right
> work in some cases.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  net/bridge/br_fdb.c     |  101 ++++++++++++++++++++++++++++++-------=
---------
>  net/bridge/br_if.c      |    2 +-
>  net/bridge/br_notify.c  |    2 +-
>  net/bridge/br_private.h |    4 +-
>  4 files changed, 70 insertions(+), 39 deletions(-)
>=20
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index a48f5ef..1e63f76 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -77,10 +77,26 @@ static inline void fdb_delete(struct net_bridge_f=
db_entry *f)
>  	br_fdb_put(f);
>  }
> =20
> -void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned cha=
r *newaddr)
> +static bool another_port_has_addr(const struct net_bridge_port *p,
> +				  struct net_bridge_fdb_entry *f)
> +{
> +	struct net_bridge *br =3D p->br;
> +	struct net_bridge_port *op;
> +
> +	list_for_each_entry(op, &br->port_list, list) {
> +		if (op !=3D p && is_etherdev_addr(op->dev, f->addr.addr)) {
> +			f->dst =3D op;
> +			return 1;
> +		}
> +	}
> +	return 0;
> +}
> +
> +void br_fdb_changeaddr(struct net_bridge_port *p, struct net_device =
*dev)
>  {
>  	struct net_bridge *br =3D p->br;
>  	int i;
> +	struct netdev_hw_addr *ha;
> =20
>  	spin_lock_bh(&br->hash_lock);
> =20
> @@ -92,26 +108,23 @@ void br_fdb_changeaddr(struct net_bridge_port *p=
, const unsigned char *newaddr)
> =20
>  			f =3D hlist_entry(h, struct net_bridge_fdb_entry, hlist);
>  			if (f->dst =3D=3D p && f->is_local) {
> -				/* maybe another port has same hw addr? */
> -				struct net_bridge_port *op;
> -				list_for_each_entry(op, &br->port_list, list) {
> -					if (op !=3D p &&
> -					    !compare_ether_addr(op->dev->dev_addr,
> -								f->addr.addr)) {
> -						f->dst =3D op;
> -						goto insert;
> -					}
> -				}
> -
> -				/* delete old one */
> -				fdb_delete(f);
> -				goto insert;
> +				/*
> +				 * maybe another port has same hw addr?,
> +				 * if not then delete it
> +				 */
> +				if (!another_port_has_addr(p, f))
> +					fdb_delete(f);
>  			}
>  		}
>  	}
> - insert:
> -	/* insert new address,  may fail if invalid address or dup. */
> -	fdb_insert(br, p, newaddr);
> +
> +	/* insert device addresses, may fail if invalid address. */
> +
> +	rcu_read_lock();

Same problem than a previous patch Jiri.

You should not use rcu_read_lock()/rcu_read_unlock() at all in this con=
text,
since you already own a lock.


> +	for_each_dev_addr(dev, ha) {
> +		fdb_insert(br, p, ha->addr);
> +	}
> +	rcu_read_unlock();
> =20
>  	spin_unlock_bh(&br->hash_lock);
>  }
> @@ -189,20 +202,9 @@ void br_fdb_delete_by_port(struct net_bridge *br=
,
>  			 * then when one port is deleted, assign
>  			 * the local entry to other port
>  			 */
> -			if (f->is_local) {
> -				struct net_bridge_port *op;
> -				list_for_each_entry(op, &br->port_list, list) {
> -					if (op !=3D p &&
> -					    !compare_ether_addr(op->dev->dev_addr,
> -								f->addr.addr)) {
> -						f->dst =3D op;
> -						goto skip_delete;
> -					}
> -				}
> -			}
> -
> -			fdb_delete(f);
> -		skip_delete: ;
> +			if (!f->is_local ||
> +			    !another_port_has_addr(p, f))
> +				fdb_delete(f);
>  		}
>  	}
>  	spin_unlock_bh(&br->hash_lock);
> @@ -338,7 +340,7 @@ static struct net_bridge_fdb_entry *fdb_create(st=
ruct hlist_head *head,
>  }
> =20
>  static int fdb_insert(struct net_bridge *br, struct net_bridge_port =
*source,
> -		  const unsigned char *addr)
> +		      const unsigned char *addr)
>  {
>  	struct hlist_head *head =3D &br->hash[br_mac_hash(addr)];
>  	struct net_bridge_fdb_entry *fdb;
> @@ -366,13 +368,42 @@ static int fdb_insert(struct net_bridge *br, st=
ruct net_bridge_port *source,
>  	return 0;
>  }
> =20
> +static int fdb_insert_dev(struct net_bridge *br, struct net_bridge_p=
ort *source,
> +			  struct net_device *dev)
> +{
> +	struct netdev_hw_addr *ha, *ha2;
> +	struct net_bridge_fdb_entry *fdb;
> +	struct hlist_head *head;
> +	int ret =3D 0;
> +
> +	rcu_read_lock();


You should not use rcu_read_lock()/rcu_read_unlock() at all in this con=
text


> +	for_each_dev_addr(dev, ha) {
> +		ret =3D fdb_insert(br, source, ha->addr);
> +		if (ret)
> +			goto unroll;
> +	}
> +	goto unlock;
> +unroll:
> +	for_each_dev_addr(dev, ha2) {
> +		if (ha2 =3D=3D ha)
> +			break;
> +		head =3D &br->hash[br_mac_hash(ha2->addr)];
> +		fdb =3D fdb_find(head, ha2->addr);
> +		if (fdb && fdb->is_local)
> +			fdb_delete(fdb);
> +	}
> +unlock:
> +	rcu_read_unlock();
> +	return ret;
> +}
> +
>  int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *sou=
rce,
> -		  const unsigned char *addr)
> +		  struct net_device *dev)
>  {
>  	int ret;
> =20
>  	spin_lock_bh(&br->hash_lock);
> -	ret =3D fdb_insert(br, source, addr);
> +	ret =3D fdb_insert_dev(br, source, dev);
>  	spin_unlock_bh(&br->hash_lock);
>  	return ret;
>  }
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 8a96672..789cb30 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -392,7 +392,7 @@ int br_add_if(struct net_bridge *br, struct net_d=
evice *dev)
>  	if (err)
>  		goto err0;
> =20
> -	err =3D br_fdb_insert(br, p, dev->dev_addr);
> +	err =3D br_fdb_insert(br, p, dev);
>  	if (err)
>  		goto err1;
> =20
> diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
> index 763a3ec..1423541 100644
> --- a/net/bridge/br_notify.c
> +++ b/net/bridge/br_notify.c
> @@ -48,7 +48,7 @@ static int br_device_event(struct notifier_block *u=
nused, unsigned long event, v
> =20
>  	case NETDEV_CHANGEADDR:
>  		spin_lock_bh(&br->lock);
> -		br_fdb_changeaddr(p, dev->dev_addr);
> +		br_fdb_changeaddr(p, dev);
>  		br_stp_recalculate_bridge_id(br);
>  		spin_unlock_bh(&br->lock);
>  		break;
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index b6c3b71..65ffe3d 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -148,7 +148,7 @@ extern int br_fdb_init(void);
>  extern void br_fdb_fini(void);
>  extern void br_fdb_flush(struct net_bridge *br);
>  extern void br_fdb_changeaddr(struct net_bridge_port *p,
> -			      const unsigned char *newaddr);
> +			      struct net_device *dev);
>  extern void br_fdb_cleanup(unsigned long arg);
>  extern void br_fdb_delete_by_port(struct net_bridge *br,
>  				  const struct net_bridge_port *p, int do_all);
> @@ -161,7 +161,7 @@ extern int br_fdb_fillbuf(struct net_bridge *br, =
void *buf,
>  			  unsigned long count, unsigned long off);
>  extern int br_fdb_insert(struct net_bridge *br,
>  			 struct net_bridge_port *source,
> -			 const unsigned char *addr);
> +			 struct net_device *dev);
>  extern void br_fdb_update(struct net_bridge *br,
>  			  struct net_bridge_port *source,
>  			  const unsigned char *addr);
>=20
>=20
