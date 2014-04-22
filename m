From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] netlink: have netlink per-protocol bind function
 return an error code.
Date: Tue, 22 Apr 2014 16:19:04 -0400 (EDT)
Message-ID: <20140422.161904.1187535812839850973.davem@davemloft.net>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
	<cover.1397831970.git.rgb@redhat.com>
	<c9a8a0879bc9f375bb3484f8e86189a8af5aa142.1397831970.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, eparis@redhat.com,
	netfilter-devel@vger.kernel.org, hadi@mojatatu.com,
	sgrubb@redhat.com
To: rgb@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c9a8a0879bc9f375bb3484f8e86189a8af5aa142.1397831970.git.rgb@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Guy Briggs <rgb@redhat.com>
Date: Fri, 18 Apr 2014 13:34:06 -0400

> @@ -1449,6 +1453,26 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
>  	if (!nladdr->nl_groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
>  		return 0;
>  
> +	if (nlk->netlink_bind && nladdr->nl_groups) {
> +		int i;
> +
> +		for (i = 0; i < nlk->ngroups; i++) {
> +			int undo;
> +
> +			if (!test_bit(i, (long unsigned int *)&nladdr->nl_groups))
> +				continue;
> +			err = nlk->netlink_bind(i);
> +			if (!err)
> +				continue;
> +			if (!nlk->portid)
> +				netlink_remove(sk);
> +			for (undo = 0; undo < i; undo++)
> +				if (nlk->netlink_unbind)
> +					nlk->netlink_unbind(undo);
> +			return err;
> +		}
> +	}
> +

It took me a while to figure out why you need to do the netlink_remove() in
the error path.

I think it's really asking for trouble to allow the socket to have temporary
visibility if we end up signalling an error.

It seems safest if we only do the autobind/insert once we are absolutely
certain that the bind() will fully succeed.  This means that you have to
do this bind validation loop before autobind/insert.

Please make this change and resubmit this series, thanks.
