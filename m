From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next v5 2/2] bridge: vlan: signal if
 anything changed on vlan add
Date: Fri, 27 Oct 2017 17:24:27 +0900
Message-ID: <9dd7d80a-1afb-0d22-eb35-73023e65a881@lab.ntt.co.jp>
References: <1509025309-10165-1-git-send-email-nikolay@cumulusnetworks.com>
	<1509025309-10165-3-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org,
	mrv@mojatatu.com, dsa@cumulusnetworks.com, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1509025309-10165-3-git-send-email-nikolay@cumulusnetworks.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 2017/10/26 22:41, Nikolay Aleksandrov wrote:
> Before this patch there was no way to tell if the vlan add operation
> actually changed anything, thus we would always generate a notification
> on adds. Let's make the notifications more precise and generate them
> only if anything changed, so use the new bool parameter to signal that the
> vlan was updated. We cannot return an error because there are valid use
> cases that will be broken (e.g. overlapping range add) and also we can't
> risk masking errors due to calls into drivers for vlan add which can
> potentially return anything.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Thanks for the explanation in the previous mail.

> ---
...
> @@ -576,8 +592,11 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
>  			refcount_inc(&vlan->refcnt);
>  			vlan->flags |= BRIDGE_VLAN_INFO_BRENTRY;
>  			vg->num_vlans++;
> +			*changed = true;
>  		}
> -		__vlan_add_flags(vlan, flags);
> +		if (__vlan_add_flags(vlan, flags))
> +			*changed = true;
> +
>  		return 0;
>  	}
>  
> @@ -601,6 +620,7 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
>  		free_percpu(vlan->stats);
>  		kfree(vlan);

We should not set changed=true in this failure case?

>  	}
> +	*changed = true;
>  
>  	return ret;
>  }
...
> @@ -1050,6 +1083,7 @@ int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
>  	ret = __vlan_add(vlan, flags);
>  	if (ret)
>  		kfree(vlan);

Likewise.

> +	*changed = true;
>  
>  	return ret;
>  }
> 

-- 
Toshiaki Makita
