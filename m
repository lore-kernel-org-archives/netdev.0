From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: have netlink per-protocol bind function
 return an error code.
Date: Sun, 23 Mar 2014 00:50:10 -0400 (EDT)
Message-ID: <20140323.005010.1898428719601246326.davem@davemloft.net>
References: <1239812af16a5c746772913ef68d3570383f2e50.1395419169.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eparis@redhat.com, sgrubb@redhat.com, hadi@mojatatu.com
To: rgb@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1239812af16a5c746772913ef68d3570383f2e50.1395419169.git.rgb@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Guy Briggs <rgb@redhat.com>
Date: Fri, 21 Mar 2014 12:39:11 -0400

> @@ -1441,6 +1441,17 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
>  	if (!nladdr->nl_groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
>  		return 0;
>  
> +	if (nlk->netlink_bind && nladdr->nl_groups) {
> +		int i;
> +
> +		for (i = 0; i < nlk->ngroups; i++)
> +			if (test_bit(i, (long unsigned int *)&nladdr->nl_groups)) {
> +				err = nlk->netlink_bind(i);
> +				if (err)
> +					return err;
> +			}
> +	}
> +

You can't just leave a partially set of completed bindings in place.

It's not valid to leave half-baked state like this.

If you return an error, all of the binding state changes must be
completely undone.

If you can't find a way to do this cleanly, you'll need to find
a way for the audit code to not return an error.
