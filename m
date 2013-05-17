From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netlabel: improve domain mapping validation
Date: Fri, 17 May 2013 23:23:03 +0400
Message-ID: <51968397.6010808@cogentembedded.com>
References: <20130517190850.11148.51057.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	vlad.halilov@gmail.com, selinux@tycho.nsa.gov
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20130517190850.11148.51057.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/17/2013 11:08 PM, Paul Moore wrote:

> The net/netlabel/netlabel_domainhash.c:netlbl_domhsh_add() function
> does not properly validate new domain hash entries resulting in
> potential problems when an administrator attempts to add an invalid
> entry.  One such problem, as reported by Vlad Halilov, is a kernel
> BUG (found in netlabel_domainhash.c:netlbl_domhsh_audit_add()) when
> adding an IPv6 outbound mapping with a CIPSO configuration.
>
> This patch corrects this problem by adding the necessary validation
> code to netlbl_domhsh_add() via the newly created
> netlbl_domhsh_validate() function.
>
> Ideally this patch should also be pushed to the currently active
> -stable trees.
>
> Reported-by: Vlad Halilov <vlad.halilov@gmail.com>
> Signed-off-by: Paul Moore <pmoore@redhat.com>
> ---
>   net/netlabel/netlabel_domainhash.c |   69 ++++++++++++++++++++++++++++++++++++
>   1 file changed, 69 insertions(+)
>
> diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
> index d8d4243..6bb1d42 100644
> --- a/net/netlabel/netlabel_domainhash.c
> +++ b/net/netlabel/netlabel_domainhash.c
> @@ -245,6 +245,71 @@ static void netlbl_domhsh_audit_add(struct netlbl_dom_map *entry,
>   	}
>   }
>   
> +/**
> + * netlbl_domhsh_validate - Validate a new domain mapping entry
> + * @entry: the entry to validate
> + *
> + * This function validates the new domain mapping entry to ensure that it is
> + * a valid entry.  Returns zero on success, negative values on failure.
> + *
> + */
> +static int netlbl_domhsh_validate(const struct netlbl_dom_map *entry)
> +{
> +	struct netlbl_af4list *iter4;
> +	struct netlbl_domaddr4_map *map4;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	struct netlbl_af6list *iter6;
> +	struct netlbl_domaddr6_map *map6;
> +#endif /* IPv6 */
> +
> +	if (entry == NULL)
> +		return -EINVAL;
> +
> +	switch (entry->type) {
> +	case NETLBL_NLTYPE_UNLABELED:
> +		if (entry->type_def.cipsov4 != NULL ||
> +		    entry->type_def.addrsel != NULL)
> +			return -EINVAL;
> +		break;
> +	case NETLBL_NLTYPE_CIPSOV4:
> +		if (entry->type_def.cipsov4 == NULL)
> +			return -EINVAL;
> +		break;
> +	case NETLBL_NLTYPE_ADDRSELECT:
> +		netlbl_af4list_foreach(iter4, &entry->type_def.addrsel->list4) {
> +			map4 = netlbl_domhsh_addr4_entry(iter4);
> +			switch (map4->type) {
> +			case NETLBL_NLTYPE_UNLABELED:
> +				if (map4->type_def.cipsov4 != NULL)
> +					return -EINVAL;
> +				break;
> +			case NETLBL_NLTYPE_CIPSOV4:
> +				if (map4->type_def.cipsov4 == NULL)
> +					return -EINVAL;
> +				break;
> +			default:
> +				return -EINVAL;
> +			}
> +		}
> +#if IS_ENABLED(CONFIG_IPV6)

   Why not:

         if (IS_ENABLED(CONFIG_IPV6))

    #if's in the function body are frowned upon.

> +		netlbl_af6list_foreach(iter6, &entry->type_def.addrsel->list6) {
> +			map6 = netlbl_domhsh_addr6_entry(iter6);
> +			switch (map6->type) {
> +			case NETLBL_NLTYPE_UNLABELED:
> +				break;
> +			default:
> +				return -EINVAL;
> +			}
> +		}
> +#endif /* IPv6 */
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +

WBR, Sergei

