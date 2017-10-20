From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 2/2] net: netrom: refactor code in nr_add_node
Date: Fri, 20 Oct 2017 10:57:10 +0200
Message-ID: <59E9BA66.4000707@bfs.de>
References: <20171019172746.GA15332@embeddedor.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20171019172746.GA15332@embeddedor.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 19.10.2017 19:27, schrieb Gustavo A. R. Silva:
> Code refactoring in order to make the code easier to read and maintain.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
> This code was tested by compilation only (GCC 7.2.0 was used).
> 
>  net/netrom/nr_route.c | 63 ++++++++++++++++-----------------------------------
>  1 file changed, 20 insertions(+), 43 deletions(-)
> 
> diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
> index fc9cadc..1e5165f 100644
> --- a/net/netrom/nr_route.c
> +++ b/net/netrom/nr_route.c
> @@ -80,6 +80,23 @@ static struct nr_neigh *nr_neigh_get_dev(ax25_address *callsign,
>  
>  static void nr_remove_neigh(struct nr_neigh *);
>  
> +/*      re-sort the routes in quality order.    */
> +static inline void re_sort_routes(struct nr_node *nr_node, int ix_x, int ix_y)
> +{
> +	struct nr_route nr_route;
> +
> +	if (nr_node->routes[ix_y].quality > nr_node->routes[ix_x].quality) {
> +		if (nr_node->which == ix_x)
> +			nr_node->which = ix_y;
> +		else if (nr_node->which == ix_y)
> +			nr_node->which = ix_x;
> +
> +		nr_route              = nr_node->routes[ix_x];
> +		nr_node->routes[ix_x] = nr_node->routes[ix_y];
> +		nr_node->routes[ix_y] = nr_route;
> +	}
> +}
> +


Good idea, a bit of nit picking ..
does ix_ has a special meaning ? otherwise x,y would be sufficient.
>From the code below i can see: y=x+1 Perhaps that can be used.

kernel.h has a swap() macro. so you can swap(nr_node->routes[x],nr_node->routes[y]);

hope that helps,
re,
 wh

>  /*
>   *	Add a new route to a node, and in the process add the node and the
>   *	neighbour if it is new.
> @@ -90,7 +107,6 @@ static int __must_check nr_add_node(ax25_address *nr, const char *mnemonic,
>  {
>  	struct nr_node  *nr_node;
>  	struct nr_neigh *nr_neigh;
> -	struct nr_route nr_route;
>  	int i, found;
>  	struct net_device *odev;
>  
> @@ -251,50 +267,11 @@ static int __must_check nr_add_node(ax25_address *nr, const char *mnemonic,
>  	/* Now re-sort the routes in quality order */
>  	switch (nr_node->count) {
>  	case 3:
> -		if (nr_node->routes[1].quality > nr_node->routes[0].quality) {
> -			switch (nr_node->which) {
> -			case 0:
> -				nr_node->which = 1;
> -				break;
> -			case 1:
> -				nr_node->which = 0;
> -				break;
> -			}
> -			nr_route           = nr_node->routes[0];
> -			nr_node->routes[0] = nr_node->routes[1];
> -			nr_node->routes[1] = nr_route;
> -		}
> -		if (nr_node->routes[2].quality > nr_node->routes[1].quality) {
> -			switch (nr_node->which) {
> -			case 1:  nr_node->which = 2;
> -				break;
> -
> -			case 2:  nr_node->which = 1;
> -				break;
> -
> -			default:
> -				break;
> -			}
> -			nr_route           = nr_node->routes[1];
> -			nr_node->routes[1] = nr_node->routes[2];
> -			nr_node->routes[2] = nr_route;
> -		}
> +		re_sort_routes(nr_node, 0, 1);
> +		re_sort_routes(nr_node, 1, 2);
>  		/* fall through */
>  	case 2:
> -		if (nr_node->routes[1].quality > nr_node->routes[0].quality) {
> -			switch (nr_node->which) {
> -			case 0:  nr_node->which = 1;
> -				break;
> -
> -			case 1:  nr_node->which = 0;
> -				break;
> -
> -			default: break;
> -			}
> -			nr_route           = nr_node->routes[0];
> -			nr_node->routes[0] = nr_node->routes[1];
> -			nr_node->routes[1] = nr_route;
> -			}
> +		re_sort_routes(nr_node, 0, 1);
>  	case 1:
>  		break;
>  	}
