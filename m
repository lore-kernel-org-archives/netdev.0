From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: create audit records for ebtables
 replaces
Date: Sun, 7 Sep 2014 18:07:28 +0200
Message-ID: <20140907160728.GA4589@salvia>
References: <1409907015-6145-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	stephen@networkplumber.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-audit@redhat.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1409907015-6145-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 05, 2014 at 10:50:15AM +0200, Nicolas Dichtel wrote:
> This is already done for x_tables (family AF_INET and AF_INET6), let's do it
> for AF_BRIDGE also.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/bridge/netfilter/ebtables.c | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
> index 6d69631b9f4d..4ba0c5c78778 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -26,6 +26,7 @@
>  #include <asm/uaccess.h>
>  #include <linux/smp.h>
>  #include <linux/cpumask.h>
> +#include <linux/audit.h>
>  #include <net/sock.h>
>  /* needed for logical [in,out]-dev filtering */
>  #include "../br_private.h"
> @@ -1126,6 +1127,20 @@ static int do_replace(struct net *net, const void __user *user,
>  	}
>  
>  	ret = do_replace_finish(net, &tmp, newinfo);
> +#ifdef CONFIG_AUDIT
> +	if (audit_enabled) {
> +		struct audit_buffer *ab;
> +
> +		ab = audit_log_start(current->audit_context, GFP_KERNEL,
> +				     AUDIT_NETFILTER_CFG);
> +		if (ab) {
> +			audit_log_format(ab, "table=%s family=%u entries=%u",
> +					 tmp.name, AF_BRIDGE,
> +					 tmp.nentries);
> +			audit_log_end(ab);
> +		}
> +	}
> +#endif

This chunks belongs to do_replace_finish(). We still need the audit
code for compat_do_replace() and iff there are no errors when
replacing the table.

>  	if (ret == 0)
>  		return ret;
>  free_entries:
> -- 
> 1.9.0
> 
