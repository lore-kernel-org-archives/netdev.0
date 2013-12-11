From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH -next 2/3] batman-adv: Use seq_overflow
Date: Wed, 11 Dec 2013 07:55:26 +0000
Message-ID: <20131211075526.GR10323@ZenIV.linux.org.uk>
References: <cover.1386738050.git.joe@perches.com>
 <e7104b35287b1e1ec456734c1b5e1aa98dac99f8.1386738050.git.joe@perches.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <e7104b35287b1e1ec456734c1b5e1aa98dac99f8.1386738050.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
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

On Tue, Dec 10, 2013 at 09:12:43PM -0800, Joe Perches wrote:

> diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
> index 2449afa..dfa5d2d 100644
> --- a/net/batman-adv/gateway_client.c
> +++ b/net/batman-adv/gateway_client.c
> @@ -517,29 +517,28 @@ static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
>  {
>  	struct batadv_gw_node *curr_gw;
>  	struct batadv_neigh_node *router;
> -	int ret = -1;
>  
>  	router = batadv_orig_node_get_router(gw_node->orig_node);
>  	if (!router)
> -		goto out;
> +		return -1;

This (as well as the original) means "fail read(2) with -EINVAL", which
might or might not be correct behaviour.

>  	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
>  
> -	ret = seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
> -			 (curr_gw == gw_node ? "=>" : "  "),
> -			 gw_node->orig_node->orig,
> -			 router->bat_iv.tq_avg, router->addr,
> -			 router->if_incoming->net_dev->name,
> -			 gw_node->bandwidth_down / 10,
> -			 gw_node->bandwidth_down % 10,
> -			 gw_node->bandwidth_up / 10,
> -			 gw_node->bandwidth_up % 10);
> +	seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
> +		   (curr_gw == gw_node ? "=>" : "  "),
> +		   gw_node->orig_node->orig,
> +		   router->bat_iv.tq_avg, router->addr,
> +		   router->if_incoming->net_dev->name,
> +		   gw_node->bandwidth_down / 10,
> +		   gw_node->bandwidth_down % 10,
> +		   gw_node->bandwidth_up / 10,
> +		   gw_node->bandwidth_up % 10);
>  
>  	batadv_neigh_node_free_ref(router);
>  	if (curr_gw)
>  		batadv_gw_node_free_ref(curr_gw);
> -out:
> -	return ret;
> +
> +	return seq_overflow(seq);

... and this is utter junk.

This sucker should return 0.  Insufficiently large buffer will be handled
by caller, TYVM, if you give that caller a chance to do so.  Returning 1
from ->show() is a bug in almost all cases, and definitely so in this one.

Just in case somebody decides that above is worth copying: It Is Not.
Original code is buggy, plain and simple.  This one trades the older
bug ("fail with -EINVAL whenever the buffer is too small") with just as buggy
"silently skip an entry entirely whenever the buffer is too small".

Don't Do That.
