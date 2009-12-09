From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] llc: convert the socket list to RCU locking (was
 Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast
 delivery)
Date: Wed, 09 Dec 2009 21:19:24 +0100
Message-ID: <4B20064C.7070301@gmail.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <200912040130.54966.opurdila@ixiacom.com> <4B184F4C.3060407@gmail.com> <200912082310.45846.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45617 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbZLIUTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 15:19:25 -0500
In-Reply-To: <200912082310.45846.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/12/2009 22:10, Octavian Purdila a =E9crit :
> On Friday 04 December 2009 01:52:44 you wrote:
>=20
>>> Since at this point we are using UP ports contention is not really =
an
>>> issue for us. I've extrapolated this (lock per hash bucket) based o=
n how
>>> locking is done in other places, like UDP.
>>
>> Yes but you know we want to remove those locks per UDP hash bucket, =
since
>>  we dont really need them anymore. ;)
>>
>>
>> If you remember, we had in the past one rwlock for the whole UDP tab=
le.
>>
>> Then this was converted to one spinlock per hash slot (128 slots) + =
RCU
>>  lookups for unicast RX
>>
>> Then we dynamically sized udp table at boot (up to 65536 slots)
>>
>> multicast optimization (holding lock for small duration + double has=
hing)
>>
>> bind optimization (thanks to double hashing)
>>
>> To be done :
>>
>> 1) multicast RX can be done without taking any lock, and RCU lookups
>> 2) zap all locks and use one lock, or a small array of hashed spinlo=
cks
>>
>=20
> OK, here is my first try at llc RCU-fication.=20
>=20
> One doubt before pasting the code: In slab.h comment and in udp.c I s=
ee the lookup is restarted if an improper object is returned. Is that r=
eally required?
>=20
> Thanks!
> tavi
> =20
> [RFC PATCH] llc: convert the socket list to RCU locking
>    =20
> For the reclamation phase we use the SLAB_DESTROY_BY_RCU mechanism,
> which require some extra checks in the lookup code:
>    =20
> a) Since socket can be free while looking it up, or getting a
> reference to it, we need to check the socket reference counter to mak=
e
> sure the reference we got points to a live socket
>    =20
> b) It can also happen that the reference we got during lookup will be
> freed and the memory reused by another socket. Thus, after getting th=
e
> reference, we must check again that we got the right socket.
>    =20
> Note that the /proc code was not yet converted to RCU, it still uses
> spinlocks for protection.
>    =20
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  include/net/llc.h  |    7 ++--
>  net/llc/af_llc.c   |    1 +
>  net/llc/llc_conn.c |   89 ++++++++++++++++++++++++++++++++++--------=
----------
>  net/llc/llc_core.c |    5 ++-
>  net/llc/llc_proc.c |   20 ++++++------
>  net/llc/llc_sap.c  |   72 ++++++++++++++++++++++++++++-------------
>  6 files changed, 124 insertions(+), 70 deletions(-)
>=20
> diff --git a/include/net/llc.h b/include/net/llc.h
> index 7940da1..1559cf1 100644
> --- a/include/net/llc.h
> +++ b/include/net/llc.h
> @@ -16,6 +16,7 @@
>  #include <linux/if_ether.h>
>  #include <linux/list.h>
>  #include <linux/spinlock.h>
> +#include <linux/rculist_nulls.h>
> =20
>  #include <asm/atomic.h>
> =20
> @@ -53,10 +54,8 @@ struct llc_sap {
>  				     struct net_device *orig_dev);
>  	struct llc_addr	 laddr;
>  	struct list_head node;
> -	struct {
> -		rwlock_t	  lock;
> -		struct hlist_head list;
> -	} sk_list;
> +	spinlock_t sk_lock;
> +	struct hlist_nulls_head sk_list;
>  };
> =20
>  #define LLC_DEST_INVALID         0      /* Invalid LLC PDU type */
> diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
> index ffc96d3..baefb4f 100644
> --- a/net/llc/af_llc.c
> +++ b/net/llc/af_llc.c
> @@ -140,6 +140,7 @@ static struct proto llc_proto =3D {
>  	.name	  =3D "LLC",
>  	.owner	  =3D THIS_MODULE,
>  	.obj_size =3D sizeof(struct llc_sock),
> +	.slab_flags =3D SLAB_DESTROY_BY_RCU,
>  };
> =20
>  /**
> diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
> index c6bab39..8331fc8 100644
> --- a/net/llc/llc_conn.c
> +++ b/net/llc/llc_conn.c
> @@ -468,6 +468,19 @@ static int llc_exec_conn_trans_actions(struct so=
ck *sk,
>  	return rc;
>  }
> =20
> +static inline bool llc_estab_match(const struct llc_sap *sap,
> +				   const struct llc_addr *daddr,
> +				   const struct llc_addr *laddr,
> +				   const struct sock *sk)
> +{
> +	struct llc_sock *llc =3D llc_sk(sk);
> +
> +	return llc->laddr.lsap =3D=3D laddr->lsap &&
> +		llc->daddr.lsap =3D=3D daddr->lsap &&
> +		llc_mac_match(llc->laddr.mac, laddr->mac) &&
> +		llc_mac_match(llc->daddr.mac, daddr->mac);
> +}
> +
>  /**
>   *	__llc_lookup_established - Finds connection for the remote/local =
sap/mac
>   *	@sap: SAP
> @@ -484,23 +497,24 @@ static struct sock *__llc_lookup_established(st=
ruct llc_sap *sap,
>  					     struct llc_addr *laddr)
>  {
>  	struct sock *rc;
> -	struct hlist_node *node;
> -
> -	read_lock(&sap->sk_list.lock);
> -	sk_for_each(rc, node, &sap->sk_list.list) {
> -		struct llc_sock *llc =3D llc_sk(rc);
> -
> -		if (llc->laddr.lsap =3D=3D laddr->lsap &&
> -		    llc->daddr.lsap =3D=3D daddr->lsap &&
> -		    llc_mac_match(llc->laddr.mac, laddr->mac) &&
> -		    llc_mac_match(llc->daddr.mac, daddr->mac)) {
> -			sock_hold(rc);
> +	struct hlist_nulls_node *node;
> +
> +	rcu_read_lock();
> +	sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
> +		if (llc_estab_match(sap, daddr, laddr, rc)) {
> +			/* Extra checks required by SLAB_DESTROY_BY_RCU */
> +			if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
> +				continue;

Hmm, this wont work in fact, because if we have several llc_sap allocat=
ed on machine,
we have no guarantee a freed socket wont be reused and inserted in anot=
her llc_sap list.

So before calling llc_estab_match() (and/or llc_listener_match()) you s=
hould
check if 'rc' really belong to current sap.

If not, you must restart the lookup (you hit a socket that was moved to=
 another sap)


> +			if (unlikely(!llc_estab_match(sap, daddr, laddr, rc))) {
> +				sock_put(rc);
> +				continue;
> +			}
>  			goto found;
>  		}
>  	}
>  	rc =3D NULL;
>  found:
> -	read_unlock(&sap->sk_list.lock);
> +	rcu_read_unlock();
>  	return rc;
>  }
> =20

