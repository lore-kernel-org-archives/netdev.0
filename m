From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 13/17] batman-adv: Consume skb in receive
	handlers
Date: Tue, 08 Nov 2016 08:59:49 -0800
Message-ID: <1478624389.17367.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161108164526.7518-1-sw@simonwunderlich.de>
 <20161108164526.7518-14-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20161108164526.7518-14-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, 2016-11-08 at 17:45 +0100, Simon Wunderlich wrote:
> From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
> 
> Receiving functions in Linux consume the supplied skbuff. Doing the same in
> the batadv_rx_handler functions makes the behavior more similar to the rest
> of the Linux network code.
> 
> Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
> Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
> ---
>  net/batman-adv/bat_iv_ogm.c     |  17 +++--
>  net/batman-adv/bat_v_elp.c      |  25 ++++---
>  net/batman-adv/bat_v_ogm.c      |  10 +--
>  net/batman-adv/main.c           |  11 +--
>  net/batman-adv/network-coding.c |  11 +--
>  net/batman-adv/routing.c        | 149 +++++++++++++++++++++++++++-------------
>  6 files changed, 141 insertions(+), 82 deletions(-)
> 
> diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
> index 310f391..b9941bf 100644
> --- a/net/batman-adv/bat_iv_ogm.c
> +++ b/net/batman-adv/bat_iv_ogm.c
> @@ -1823,17 +1823,18 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
>  	struct batadv_ogm_packet *ogm_packet;
>  	u8 *packet_pos;
>  	int ogm_offset;
> -	bool ret;
> +	bool res;
> +	int ret = NET_RX_DROP;
>  
> -	ret = batadv_check_management_packet(skb, if_incoming, BATADV_OGM_HLEN);
> -	if (!ret)
> -		return NET_RX_DROP;
> +	res = batadv_check_management_packet(skb, if_incoming, BATADV_OGM_HLEN);
> +	if (!res)
> +		goto free_skb;
>  
>  	/* did we receive a B.A.T.M.A.N. IV OGM packet on an interface
>  	 * that does not have B.A.T.M.A.N. IV enabled ?
>  	 */
>  	if (bat_priv->algo_ops->iface.enable != batadv_iv_ogm_iface_enable)
> -		return NET_RX_DROP;
> +		goto free_skb;
>  
>  	batadv_inc_counter(bat_priv, BATADV_CNT_MGMT_RX);
>  	batadv_add_counter(bat_priv, BATADV_CNT_MGMT_RX_BYTES,
> @@ -1854,8 +1855,12 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
>  		ogm_packet = (struct batadv_ogm_packet *)packet_pos;
>  	}
>  
> +	ret = NET_RX_SUCCESS;
> +
> +free_skb:
>  	consume_skb(skb);
> -	return NET_RX_SUCCESS;
> +
> +	return ret;
>  }


Okay, but we do have kfree_skb() and consume_skb() and they should be
used appropriately.
