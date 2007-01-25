From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [PATCH] net: decnet handle a failure in neigh_parms_alloc (take 2)
Date: Thu, 25 Jan 2007 11:43:18 +0000
Message-ID: <20070125114318.GA4612@fogou.chygwyn.com>
References: <m13b601917.fsf@ebiederm.dsl.xmission.com> <20070124.144511.56810202.davem@davemloft.net> <20070124.144952.02299886.davem@davemloft.net> <m1irevzovi.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick Caulfield <patrick@tykepenguin.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:47800 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965275AbXAYMd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 07:33:57 -0500
Content-Disposition: inline
In-Reply-To: <m1irevzovi.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Jan 24, 2007 at 09:55:45PM -0700, Eric W. Biederman wrote:
> 
> While enhancing the neighbour code to handle multiple network
> namespaces I noticed that decnet is assuming neigh_parms_alloc
> will allways succeed, which is clearly wrong.  So handle the
> failure.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Acked-by: Steven Whitehouse <steve@chygwyn.com>

Also you should cc Patrick as he is now the maintainer,

Steve.


> ---
>  net/decnet/dn_dev.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
> index 324eb47..913e25a 100644
> --- a/net/decnet/dn_dev.c
> +++ b/net/decnet/dn_dev.c
> @@ -1140,16 +1140,23 @@ struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
>  	init_timer(&dn_db->timer);
>  
>  	dn_db->uptime = jiffies;
> +
> +	dn_db->neigh_parms = neigh_parms_alloc(dev, &dn_neigh_table);
> +	if (!dn_db->neigh_parms) {
> +		dev->dn_ptr = NULL;
> +		kfree(dn_db);
> +		return NULL;
> +	}
> +
>  	if (dn_db->parms.up) {
>  		if (dn_db->parms.up(dev) < 0) {
> +			neigh_parms_release(&dn_neigh_table, dn_db->neigh_parms);
>  			dev->dn_ptr = NULL;
>  			kfree(dn_db);
>  			return NULL;
>  		}
>  	}
>  
> -	dn_db->neigh_parms = neigh_parms_alloc(dev, &dn_neigh_table);
> -
>  	dn_dev_sysctl_register(dev, &dn_db->parms);
>  
>  	dn_dev_set_timer(dev);
> -- 
> 1.4.4.1.g278f
> 
