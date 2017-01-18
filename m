From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: store CPU switch structure in the
 tree
Date: Wed, 18 Jan 2017 13:49:57 +0100
Message-ID: <20170118124957.GA7690@lunn.ch>
References: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2017 at 08:41:38PM -0500, Vivien Didelot wrote:
> Store a dsa_switch pointer to the CPU switch in the tree instead of only
> its index. This avoids the need to initialize it to -1.

Hi Vivien

A cover note would be nice.

I expect these patches are going to clash with Florians platform
device patches, but they are on hold for a while. Also John's rework
of the multi-cpu ports, but that has gone quite.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  include/net/dsa.h | 8 ++++----
>  net/dsa/dsa.c     | 7 +++----
>  net/dsa/dsa2.c    | 5 ++---
>  3 files changed, 9 insertions(+), 11 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 454667952d6d..82f7019f27f2 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -124,7 +124,7 @@ struct dsa_switch_tree {
>  	/*
>  	 * The switch and port to which the CPU is attached.
>  	 */
> -	s8			cpu_switch;
> +	struct dsa_switch	*cpu_switch;
>  	s8			cpu_port;
>  
>  	/*
> @@ -211,7 +211,7 @@ struct dsa_switch {
>  
>  static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
>  {
> -	return !!(ds->index == ds->dst->cpu_switch && p == ds->dst->cpu_port);
> +	return !!(ds == ds->dst->cpu_switch && p == ds->dst->cpu_port);
>  }
>  
>  static inline bool dsa_is_dsa_port(struct dsa_switch *ds, int p)
> @@ -234,10 +234,10 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
>  	 * Else return the (DSA) port number that connects to the
>  	 * switch that is one hop closer to the cpu.
>  	 */
> -	if (dst->cpu_switch == ds->index)
> +	if (dst->cpu_switch == ds)
>  		return dst->cpu_port;
>  	else
> -		return ds->rtable[dst->cpu_switch];
> +		return ds->rtable[dst->cpu_switch->index];
>  }
>  
>  struct switchdev_trans;
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 96d1544df518..cb42655ba7da 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -225,12 +225,12 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>  			continue;
>  
>  		if (!strcmp(name, "cpu")) {
> -			if (dst->cpu_switch != -1) {
> +			if (!dst->cpu_switch) {
>  				netdev_err(dst->master_netdev,
>  					   "multiple cpu ports?!\n");
>  				return -EINVAL;
>  			}
> -			dst->cpu_switch = index;
> +			dst->cpu_switch = ds;
>  			dst->cpu_port = i;
>  			ds->cpu_port_mask |= 1 << i;
>  		} else if (!strcmp(name, "dsa")) {
> @@ -254,7 +254,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>  	 * tagging protocol to the preferred tagging format of this
>  	 * switch.
>  	 */
> -	if (dst->cpu_switch == index) {
> +	if (dst->cpu_switch == ds) {
>  		enum dsa_tag_protocol tag_protocol;
>  
>  		tag_protocol = ops->get_tag_protocol(ds);
> @@ -757,7 +757,6 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
>  
>  	dst->pd = pd;
>  	dst->master_netdev = dev;
> -	dst->cpu_switch = -1;
>  	dst->cpu_port = -1;
>  
>  	for (i = 0; i < pd->nr_chips; i++) {
> diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
> index a1f26fc0f585..a9bf28d9f41f 100644
> --- a/net/dsa/dsa2.c
> +++ b/net/dsa/dsa2.c
> @@ -57,7 +57,6 @@ static struct dsa_switch_tree *dsa_add_dst(u32 tree)
>  	if (!dst)
>  		return NULL;
>  	dst->tree = tree;
> -	dst->cpu_switch = -1;
>  	INIT_LIST_HEAD(&dst->list);
>  	list_add_tail(&dsa_switch_trees, &dst->list);
>  	kref_init(&dst->refcount);
> @@ -456,8 +455,8 @@ static int dsa_cpu_parse(struct device_node *port, u32 index,
>  	if (!dst->master_netdev)
>  		dst->master_netdev = ethernet_dev;
>  
> -	if (dst->cpu_switch == -1) {
> -		dst->cpu_switch = ds->index;
> +	if (!dst->cpu_switch) {
> +		dst->cpu_switch = ds;
>  		dst->cpu_port = index;
>  	}
>  
> -- 
> 2.11.0
> 
