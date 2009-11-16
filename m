From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 1/2] Phonet: put protocols array under RCU
Date: Mon, 16 Nov 2009 09:26:17 -0800
Message-ID: <20091116172617.GC6746@linux.vnet.ibm.com>
References: <1258124479-1167-1-git-send-email-remi@remlab.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:45480 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753201AbZKPR0R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 12:26:17 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nAGHMHAP003967
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 12:22:17 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAGHQMae118224
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 12:26:22 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAGHQLei018862
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 12:26:21 -0500
Content-Disposition: inline
In-Reply-To: <1258124479-1167-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 05:01:18PM +0200, R=E9mi Denis-Courmont wrote:
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  net/phonet/af_phonet.c |   20 +++++++++++---------
>  1 files changed, 11 insertions(+), 9 deletions(-)
>=20
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index 8d3a55b..ed65da2 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -35,7 +35,6 @@
>=20
>  /* Transport protocol registration */
>  static struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mostl=
y;
> -static DEFINE_SPINLOCK(proto_tab_lock);
>=20
>  static struct phonet_protocol *phonet_proto_get(int protocol)
>  {
> @@ -44,11 +43,11 @@ static struct phonet_protocol *phonet_proto_get(i=
nt protocol)
>  	if (protocol >=3D PHONET_NPROTO)
>  		return NULL;
>=20
> -	spin_lock(&proto_tab_lock);
> +	rcu_read_lock();
>  	pp =3D proto_tab[protocol];

Don't we need an rcu_dereference() in here somewhere?

Perhaps something like the following?

	pp =3D rcu_dereference(proto_tab[protocol]);

							Thanx, Paul

>  	if (pp && !try_module_get(pp->prot->owner))
>  		pp =3D NULL;
> -	spin_unlock(&proto_tab_lock);
> +	rcu_read_unlock();
>=20
>  	return pp;
>  }
> @@ -439,6 +438,8 @@ static struct packet_type phonet_packet_type __re=
ad_mostly =3D {
>  	.func =3D phonet_rcv,
>  };
>=20
> +static DEFINE_MUTEX(proto_tab_lock);
> +
>  int __init_or_module phonet_proto_register(int protocol,
>  						struct phonet_protocol *pp)
>  {
> @@ -451,12 +452,12 @@ int __init_or_module phonet_proto_register(int =
protocol,
>  	if (err)
>  		return err;
>=20
> -	spin_lock(&proto_tab_lock);
> +	mutex_lock(&proto_tab_lock);
>  	if (proto_tab[protocol])
>  		err =3D -EBUSY;
>  	else
> -		proto_tab[protocol] =3D pp;
> -	spin_unlock(&proto_tab_lock);
> +		rcu_assign_pointer(proto_tab[protocol], pp);
> +	mutex_unlock(&proto_tab_lock);
>=20
>  	return err;
>  }
> @@ -464,10 +465,11 @@ EXPORT_SYMBOL(phonet_proto_register);
>=20
>  void phonet_proto_unregister(int protocol, struct phonet_protocol *p=
p)
>  {
> -	spin_lock(&proto_tab_lock);
> +	mutex_lock(&proto_tab_lock);
>  	BUG_ON(proto_tab[protocol] !=3D pp);
> -	proto_tab[protocol] =3D NULL;
> -	spin_unlock(&proto_tab_lock);
> +	rcu_assign_pointer(proto_tab[protocol], NULL);
> +	mutex_unlock(&proto_tab_lock);
> +	synchronize_rcu();
>  	proto_unregister(pp->prot);
>  }
>  EXPORT_SYMBOL(phonet_proto_unregister);
> --=20
> 1.6.3.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
