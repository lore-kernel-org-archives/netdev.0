From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-2.6.25] [IPV6] ADDRLABEL: Fix double free on label deletion.
Date: Tue, 29 Jan 2008 12:59:13 -0800
Message-ID: <20080129205913.GE10525@linux.vnet.ibm.com>
References: <20080128.210222.07062540.yoshfuji@linux-ipv6.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, mitch@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:52117 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbYA2U7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 15:59:16 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0TKxGUp011674
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 15:59:16 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0TKxFb7165116
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 13:59:15 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0TKxFAI001307
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 13:59:15 -0700
Content-Disposition: inline
In-Reply-To: <20080128.210222.07062540.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 28, 2008 at 09:02:22PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> If an entry is being deleted because it has only one reference,=20
> we immediately delete it and blindly register the rcu handler for it,
> This results in oops by double freeing that object.
>=20
> This patch fixes it by consolidating the code paths for the deletion;
> let its rcu handler delete the object if it has no more reference.
>=20
> Bug was found by Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Good catch!!!

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>=20
> diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
> index 6f1ca60..7a706c4 100644
> --- a/net/ipv6/addrlabel.c
> +++ b/net/ipv6/addrlabel.c
> @@ -106,6 +106,11 @@ static inline void ip6addrlbl_free(struct ip6add=
rlbl_entry *p)
>  	kfree(p);
>  }
>=20
> +static void ip6addrlbl_free_rcu(struct rcu_head *h)
> +{
> +	ip6addrlbl_free(container_of(h, struct ip6addrlbl_entry, rcu));
> +}
> +
>  static inline int ip6addrlbl_hold(struct ip6addrlbl_entry *p)
>  {
>  	return atomic_inc_not_zero(&p->refcnt);
> @@ -114,12 +119,7 @@ static inline int ip6addrlbl_hold(struct ip6addr=
lbl_entry *p)
>  static inline void ip6addrlbl_put(struct ip6addrlbl_entry *p)
>  {
>  	if (atomic_dec_and_test(&p->refcnt))
> -		ip6addrlbl_free(p);
> -}
> -
> -static void ip6addrlbl_free_rcu(struct rcu_head *h)
> -{
> -	ip6addrlbl_free(container_of(h, struct ip6addrlbl_entry, rcu));
> +		call_rcu(&p->rcu, ip6addrlbl_free_rcu);
>  }
>=20
>  /* Find label */
> @@ -240,7 +240,6 @@ int __ip6addrlbl_add(struct ip6addrlbl_entry *new=
p, int replace)
>  				}
>  				hlist_replace_rcu(&p->list, &newp->list);
>  				ip6addrlbl_put(p);
> -				call_rcu(&p->rcu, ip6addrlbl_free_rcu);
>  				goto out;
>  			} else if ((p->prefixlen =3D=3D newp->prefixlen && !p->ifindex) |=
|
>  				   (p->prefixlen < newp->prefixlen)) {
> @@ -300,7 +299,6 @@ int __ip6addrlbl_del(const struct in6_addr *prefi=
x, int prefixlen,
>  		    ipv6_addr_equal(&p->prefix, prefix)) {
>  			hlist_del_rcu(&p->list);
>  			ip6addrlbl_put(p);
> -			call_rcu(&p->rcu, ip6addrlbl_free_rcu);
>  			ret =3D 0;
>  			break;
>  		}
>=20
> --=20
> YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
> GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
