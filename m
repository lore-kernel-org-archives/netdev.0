From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 4/6] netns: notify new nsid outside
 __peernet2id()
Date: Wed, 6 May 2015 13:48:32 +0200
Message-ID: <20150506114832.GF25248@pox.localdomain>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430906288-5108-5-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:34591 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbbEFLsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 07:48:35 -0400
Received: by wgso17 with SMTP id o17so8616053wgs.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 04:48:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430906288-5108-5-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/15 at 11:58am, Nicolas Dichtel wrote:
> -static int __peernet2id(struct net *net, struct net *peer, bool alloc)
> +static int __peernet2id(struct net *net, struct net *peer, bool *alloc)
>  {
>  	int id = idr_for_each(&net->netns_ids, net_eq_idr, peer);
> +	bool alloc_it = *alloc;
>  
>  	ASSERT_RTNL();
>  
> +	*alloc = false;
> +
>  	/* Magic value for id 0. */
>  	if (id == NET_ID_ZERO)
>  		return 0;
>  	if (id > 0)
>  		return id;
>  
> -	if (alloc) {
> +	if (alloc_it) {
>  		id = alloc_netid(net, peer, -1);
> +		*alloc = true;
>  		return id >= 0 ? id : NETNSA_NSID_NOT_ASSIGNED;
>  	}
>  
>  	return NETNSA_NSID_NOT_ASSIGNED;
>  }

Since you need the allocation behaviour from one call site only it
might be cleaner to add a __peernet2id_alloc() which is used from
the old __peernet2id() so you can call __peernet2id_alloc() from
peernet2id_alloc() and avoid putting these ugly bool alloc = false
in all other call sites.

Otherwise this looks good.
