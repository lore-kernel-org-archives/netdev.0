From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: [PATCH -next] net/hsr: using kfree_rcu() to simplify the code
Date: Tue, 17 Dec 2013 01:56:01 +0100
Message-ID: <52AFA121.9000706@alten.se>
References: <CAPgLHd_doYrTYAHyR4OrDz9B84Abh1H0MBvmi8XfCqAEVFyS_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <yongjun_wei@trendmicro.com.cn>, <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam2.webland.se ([91.207.112.92]:64221 "EHLO spam2.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019Ab3LQBF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 20:05:57 -0500
In-Reply-To: <CAPgLHd_doYrTYAHyR4OrDz9B84Abh1H0MBvmi8XfCqAEVFyS_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks good to me, feel free to add=20

Acked-by: Arvid Brodin <arvid.brodin@alten.se>

Nice to have others look at the code! :)


On 2013-12-16 07:05, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> The callback function of call_rcu() just calls a kfree(), so we
> can use kfree_rcu() instead of call_rcu() + callback function.
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  net/hsr/hsr_framereg.c | 13 ++++---------
>  1 file changed, 4 insertions(+), 9 deletions(-)
>=20
> diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
> index 003f5bb..a758963 100644
> --- a/net/hsr/hsr_framereg.c
> +++ b/net/hsr/hsr_framereg.c
> @@ -127,11 +127,6 @@ int hsr_create_self_node(struct list_head *self_=
node_db,
>  	return 0;
>  }
> =20
> -static void node_entry_reclaim(struct rcu_head *rh)
> -{
> -	kfree(container_of(rh, struct node_entry, rcu_head));
> -}
> -
> =20
>  /* Add/merge node to the database of nodes. 'skb' must contain an HS=
R
>   * supervision frame.
> @@ -175,7 +170,7 @@ struct node_entry *hsr_merge_node(struct hsr_priv=
 *hsr_priv,
>  	if (node && !ether_addr_equal(node->MacAddressA, hsr_sp->MacAddress=
A)) {
>  		/* Node has changed its AddrA, frame was received from SlaveB */
>  		list_del_rcu(&node->mac_list);
> -		call_rcu(&node->rcu_head, node_entry_reclaim);
> +		kfree_rcu(node, rcu_head);
>  		node =3D NULL;
>  	}
> =20
> @@ -183,7 +178,7 @@ struct node_entry *hsr_merge_node(struct hsr_priv=
 *hsr_priv,
>  	    !ether_addr_equal(node->MacAddressB, hsr_ethsup->ethhdr.h_sourc=
e)) {
>  		/* Cables have been swapped */
>  		list_del_rcu(&node->mac_list);
> -		call_rcu(&node->rcu_head, node_entry_reclaim);
> +		kfree_rcu(node, rcu_head);
>  		node =3D NULL;
>  	}
> =20
> @@ -192,7 +187,7 @@ struct node_entry *hsr_merge_node(struct hsr_priv=
 *hsr_priv,
>  	    !ether_addr_equal(node->MacAddressA, hsr_ethsup->ethhdr.h_sourc=
e)) {
>  		/* Cables have been swapped */
>  		list_del_rcu(&node->mac_list);
> -		call_rcu(&node->rcu_head, node_entry_reclaim);
> +		kfree_rcu(node, rcu_head);
>  		node =3D NULL;
>  	}
> =20
> @@ -416,7 +411,7 @@ void hsr_prune_nodes(struct hsr_priv *hsr_priv)
>  			hsr_nl_nodedown(hsr_priv, node->MacAddressA);
>  			list_del_rcu(&node->mac_list);
>  			/* Note that we need to free this entry later: */
> -			call_rcu(&node->rcu_head, node_entry_reclaim);
> +			kfree_rcu(node, rcu_head);
>  		}
>  	}
>  	rcu_read_unlock();
>=20


--=20
Arvid Brodin | Consultant (Linux)
P: +46-8-56254286 | M: +46-70-9714286
ALTEN | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
