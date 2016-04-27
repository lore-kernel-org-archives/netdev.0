From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 12/20] net: dsa: rename dst->ds to dst->switches
Date: Thu, 28 Apr 2016 01:20:05 +0200
Message-ID: <20160427232005.GK29024@lunn.ch>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1461796217-18893-13-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461796217-18893-13-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2016 at 06:30:09PM -0400, Vivien Didelot wrote:
> dsa_switch stores the net_device pointers in a "ports" member. Be
> consistent and store the dsa_switch pointer in a "switches" member of
> the dsa_switch_tree structure.
> 
> This free us the "ds" member for a future dsa_switch list.

NACK.

Or you need to change ds absolutely everywhere, in all drivers and
APIs. We cannot have ds meaning two different things.

       Andrew

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  include/net/dsa.h     | 2 +-
>  net/dsa/dsa.c         | 8 ++++----
>  net/dsa/tag_brcm.c    | 2 +-
>  net/dsa/tag_dsa.c     | 2 +-
>  net/dsa/tag_edsa.c    | 2 +-
>  net/dsa/tag_trailer.c | 2 +-
>  6 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 5f2e7df..389227d 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -124,7 +124,7 @@ struct dsa_switch_tree {
>  	/*
>  	 * Data for the individual switch chips.
>  	 */
> -	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
> +	struct dsa_switch	*switches[DSA_MAX_SWITCHES];
>  };
>  
>  struct dsa_port {
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 3daffb6..aa4a61a 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -857,7 +857,7 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
>  			continue;
>  		}
>  
> -		dst->ds[i] = ds;
> +		dst->switches[i] = ds;
>  
>  		++configured;
>  	}
> @@ -953,7 +953,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
>  	wmb();
>  
>  	for (i = 0; i < dst->pd->nr_chips; i++) {
> -		struct dsa_switch *ds = dst->ds[i];
> +		struct dsa_switch *ds = dst->switches[i];
>  
>  		if (ds)
>  			dsa_switch_destroy(ds);
> @@ -1006,7 +1006,7 @@ static int dsa_suspend(struct device *d)
>  	int i, ret = 0;
>  
>  	for (i = 0; i < dst->pd->nr_chips; i++) {
> -		struct dsa_switch *ds = dst->ds[i];
> +		struct dsa_switch *ds = dst->switches[i];
>  
>  		if (ds != NULL)
>  			ret = dsa_switch_suspend(ds);
> @@ -1022,7 +1022,7 @@ static int dsa_resume(struct device *d)
>  	int i, ret = 0;
>  
>  	for (i = 0; i < dst->pd->nr_chips; i++) {
> -		struct dsa_switch *ds = dst->ds[i];
> +		struct dsa_switch *ds = dst->switches[i];
>  
>  		if (ds != NULL)
>  			ret = dsa_switch_resume(ds);
> diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
> index 3d5aabc..35fc75b 100644
> --- a/net/dsa/tag_brcm.c
> +++ b/net/dsa/tag_brcm.c
> @@ -102,7 +102,7 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
>  	if (unlikely(dst == NULL))
>  		goto out_drop;
>  
> -	ds = dst->ds[0];
> +	ds = dst->switches[0];
>  
>  	skb = skb_unshare(skb, GFP_ATOMIC);
>  	if (skb == NULL)
> diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
> index c870cfa..bf3eebf8 100644
> --- a/net/dsa/tag_dsa.c
> +++ b/net/dsa/tag_dsa.c
> @@ -109,7 +109,7 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
>  	 */
>  	if (source_device >= dst->pd->nr_chips)
>  		goto out_drop;
> -	ds = dst->ds[source_device];
> +	ds = dst->switches[source_device];
>  	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
>  		goto out_drop;
>  
> diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
> index 898f949d..4ddbb85 100644
> --- a/net/dsa/tag_edsa.c
> +++ b/net/dsa/tag_edsa.c
> @@ -122,7 +122,7 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
>  	 */
>  	if (source_device >= dst->pd->nr_chips)
>  		goto out_drop;
> -	ds = dst->ds[source_device];
> +	ds = dst->switches[source_device];
>  	if (source_port >= DSA_MAX_PORTS || ds->ports[source_port] == NULL)
>  		goto out_drop;
>  
> diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
> index eaa3440..ade0bbf 100644
> --- a/net/dsa/tag_trailer.c
> +++ b/net/dsa/tag_trailer.c
> @@ -67,7 +67,7 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
>  
>  	if (unlikely(dst == NULL))
>  		goto out_drop;
> -	ds = dst->ds[0];
> +	ds = dst->switches[0];
>  
>  	skb = skb_unshare(skb, GFP_ATOMIC);
>  	if (skb == NULL)
> -- 
> 2.8.0
> 
