From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 02/18] netlabel: Add an address family to domain hash entries.
Date: Sun, 07 Feb 2016 14:55:54 -0500
Message-ID: <6071141.OZEtCjc0a7@sifl>
References: <1452246774-13241-3-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Huw Davies <huw@codeweavers.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1452246774-13241-3-git-send-email-huw@codeweavers.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, January 08, 2016 09:52:38 AM Huw Davies wrote:
> The reason is to allow different labelling protocols for
> different address families with the same domain.
> 
> This requires the addition of an address family attribute
> in the netlink communication protocol.  It is used in several
> messages:
> 
> NLBL_MGMT_C_ADD and NLBL_MGMT_C_ADDDEF take it as an optional
> attribute for the unlabelled protocol.  It may be one of AF_INET,
> AF_INET6 and AF_UNSPEC (to specify both address families).  If is
> it missing, it defaults to AF_UNSPEC.
> 
> NLBL_MGMT_C_LISTALL and NLBL_MGMT_C_LISTDEF return it as part of
> the enumeration of each item.  Addtionally, it may be sent to
> LISTDEF to specify which address family to return.
> 
> Signed-off-by: Huw Davies <huw@codeweavers.com>

...

> -static struct netlbl_dom_map *netlbl_domhsh_search_def(const char *domain)
> +static struct netlbl_dom_map *netlbl_domhsh_search_def(const char *domain,
> +						       u16 family)
>  {
>  	struct netlbl_dom_map *entry;
> 
> -	entry = netlbl_domhsh_search(domain);
> +	entry = netlbl_domhsh_search(domain, family);
>  	if (entry == NULL) {
> -		entry = netlbl_domhsh_rcu_deref(netlbl_domhsh_def);
> -		if (entry != NULL && !entry->valid)
> -			entry = NULL;
> +		if (family == AF_INET || family == AF_UNSPEC) {
> +			entry = netlbl_domhsh_rcu_deref(netlbl_domhsh_def_ipv4);
> +			if (entry != NULL && !entry->valid)
> +				entry = NULL;

If entry is non-NULL and valid, why not return immediately?

> +		}
> +		if (entry == NULL &&
> +		    (family == AF_INET6 || family == AF_UNSPEC)) {
> +			entry = netlbl_domhsh_rcu_deref(netlbl_domhsh_def_ipv6);
> +			if (entry != NULL && !entry->valid)
> +				entry = NULL;
> +		}
>  	}

...

> @@ -264,13 +285,19 @@ static int netlbl_domhsh_validate(const struct
> netlbl_dom_map *entry) if (entry == NULL)
>  		return -EINVAL;
> 
> +	if (entry->family != AF_INET && entry->family != AF_INET6)
> +		if (entry->def.type != NETLBL_NLTYPE_UNLABELED ||
> +		    entry->family != AF_UNSPEC)
> +			return -EINVAL;

There really is no need for a nested if-then in the above code, granted the 
combined conditional would be a bit more complex, but I would rather see that 
than this.

> @@ -385,9 +415,10 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
>  	rcu_read_lock();
>  	spin_lock(&netlbl_domhsh_lock);
>  	if (entry->domain != NULL)
> -		entry_old = netlbl_domhsh_search(entry->domain);
> +		entry_old = netlbl_domhsh_search(entry->domain, entry->family);
>  	else
> -		entry_old = netlbl_domhsh_search_def(entry->domain);
> +		entry_old = netlbl_domhsh_search_def(entry->domain,
> +						     entry->family);
>  	if (entry_old == NULL) {
>  		entry->valid = 1;
> 
> @@ -397,7 +428,37 @@ int netlbl_domhsh_add(struct netlbl_dom_map *entry,
>  				    &rcu_dereference(netlbl_domhsh)->tbl[bkt]);
>  		} else {
>  			INIT_LIST_HEAD(&entry->list);
> -			rcu_assign_pointer(netlbl_domhsh_def, entry);
> +			switch (entry->family) {
> +				struct netlbl_dom_map *entry2;

I'm not a fan of declaring variable here, move it up to the top of the 
function, or if you must, make it local to the AF_UNSPEC case below.  Also, 
while I'm being nit-picky, I dislike numbers in variable names unless we are 
dealing with something that honestly uses numbers as part of the name, e.g. 
ipv6, rename "entry2" to "entry_b" (or something along those lines) please.

> +			case AF_INET:
> +				rcu_assign_pointer(netlbl_domhsh_def_ipv4,
> +						   entry);
> +				break;
> +			case AF_INET6:
> +				rcu_assign_pointer(netlbl_domhsh_def_ipv6,
> +						   entry);
> +				break;
> +			case AF_UNSPEC:
> +				if (entry->def.type != NETLBL_NLTYPE_UNLABELED)
> +					return -EINVAL;
> +				entry2 = kzalloc(sizeof(*entry2), GFP_ATOMIC);
> +				if (!entry2)
> +					return -ENOMEM;
> +				entry2->family = AF_INET6;
> +				entry2->def.type = NETLBL_NLTYPE_UNLABELED;
> +				entry2->valid = 1;
> +				entry->family = AF_INET;
> +				rcu_assign_pointer(netlbl_domhsh_def_ipv4,
> +						   entry);
> +				rcu_assign_pointer(netlbl_domhsh_def_ipv6,
> +						   entry2);
> +				break;
> +			default:
> +				/* Already checked in
> +				 * netlbl_domhsh_validate()
> +				 */

Another style point - unless were talking about function header comment 
blocks, don't place a multi-line comment terminator on a separate line.  For 
example, instead of the above, so something like this:

  /* already checked in
   * netlbl_domhsh_validate() */

> +				return -EINVAL;
> +			}
>  		}

-- 
paul moore
security @ redhat
