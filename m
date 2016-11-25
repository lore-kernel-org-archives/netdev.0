From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: fix unbalanced dsa_switch_tree reference
 counting
Date: Fri, 25 Nov 2016 17:14:15 +0100
Message-ID: <20161125161415.GJ26806@lunn.ch>
References: <1480090133-30412-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        John Crispin <john@phrozen.org>,
        Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Chris Healy <cphealy@gmail.com>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1480090133-30412-1-git-send-email-nikita.yoush@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 25, 2016 at 07:08:53PM +0300, Nikita Yushchenko wrote:
> _dsa_register_switch() gets a dsa_switch_tree object either via
> dsa_get_dst() or via dsa_add_dst(). Former path does not increase kref
> in returned object (resulting into caller not owning a reference),
> while later path does create a new object (resulting into caller owning
> a reference).
> 
> The rest of _dsa_register_switch() assumes that it owns a reference, and
> calls dsa_put_dst().
> 
> This causes a memory breakage if first switch in the tree initialized
> successfully, but second failed to initialize. In particular, freed
> dsa_swith_tree object is left referenced by switch that was initialized,
> and later access to sysfs attributes of that switch cause OOPS.
> 
> To fix, need to add kref_get() call to dsa_get_dst().
> 
> Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>

Hi Nikita

What tree is this against? It should be net. Please make the subject
[patch net] ... so it is clear what tree this is for.

And it should have a fixes-tag

Fixes: 83c0afaec7b7 ("net: dsa: Add new binding implementation")

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew

> ---
>  net/dsa/dsa2.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
> index f8a7d9aab437..5fff951a0a49 100644
> --- a/net/dsa/dsa2.c
> +++ b/net/dsa/dsa2.c
> @@ -28,8 +28,10 @@ static struct dsa_switch_tree *dsa_get_dst(u32 tree)
>  	struct dsa_switch_tree *dst;
>  
>  	list_for_each_entry(dst, &dsa_switch_trees, list)
> -		if (dst->tree == tree)
> +		if (dst->tree == tree) {
> +			kref_get(&dst->refcount);
>  			return dst;
> +		}
>  	return NULL;
>  }
>  
> -- 
> 2.1.4
> 
