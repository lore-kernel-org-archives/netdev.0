From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/7] net: dsa: hide dsa_uses_tagged_protocol code
Date: Tue, 30 May 2017 17:01:44 +0200
Message-ID: <20170530150144.GC22758@lunn.ch>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
 <20170530142131.23568-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170530142131.23568-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 10:21:25AM -0400, Vivien Didelot wrote:
> Hide the implementation of dsa_uses_tagged_protocol in dsa.c since this
> helper will be extended to access the opaque dsa_device_ops structure.
> 
> At the same time, fix the checkpatch comparison check:
> 
>     CHECK: Comparison to NULL could be written "dst->rcv"
>     #41: FILE: net/dsa/dsa.c:32:
>     +	return dst->rcv != NULL;
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  include/net/dsa.h | 5 +----
>  net/dsa/dsa.c     | 5 +++++
>  2 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index c0e567c0c824..cb5d668b265d 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -464,10 +464,7 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
>  
>  struct net_device *dsa_dev_to_net_device(struct device *dev);
>  
> -static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
> -{
> -	return dst->rcv != NULL;
> -}
> +bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst);
>  
>  static inline bool netdev_uses_dsa(struct net_device *dev)
>  {
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 3288a80d4d6c..7a8a0358299b 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -27,6 +27,11 @@
>  
>  #include "dsa_priv.h"
>  
> +bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
> +{
> +	return !!dst->rcv;
> +}
> +

Hi Vivien

You need to be careful here. This is in the hot path. Every frame
received uses this code. And think about a distro kernel, which might
have DSA enabled by default, yet is unlikely to have any switches. You
are adding a function call which can be called millions of times per
second....

     Andrew
