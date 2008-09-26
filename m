From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/1] Use RCU for the UDP hash lock
Date: Fri, 26 Sep 2008 05:46:00 +0000
Message-ID: <20080926054600.GA4141@ff.dom.local>
References: <20080926031832.GA27289@minyard.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	shemminger@vyatta.com
To: Corey Minyard <minyard@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:27666 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbYIZFqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 01:46:08 -0400
Received: by fg-out-1718.google.com with SMTP id 19so537633fgg.17
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 22:46:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080926031832.GA27289@minyard.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2008 at 10:18:33PM -0500, Corey Minyard wrote:
...
> This patch is the second try; I believe I fixed all issues that people
> raised.

Actually, you've skipped my first question, so I still don't know, why
you don't use an _init version of sk_del_node (even if it's safe in the
current implementation), while the non-rcu code uses only this?

...
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 06c5259..65110a6 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
...
>  static inline int sk_unhashed(const struct sock *sk)
>  {
>  	return hlist_unhashed(&sk->sk_node);
> @@ -361,6 +374,27 @@ static __inline__ int sk_del_node_init(struct sock *sk)
>  	return rc;
>  }
>  
> +static inline int __sk_del_node_rcu(struct sock *sk)
> +{
> +	if (sk_hashed(sk)) {
> +		hlist_del_rcu(&sk->sk_node);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static inline int sk_del_node_rcu(struct sock *sk)
> +{
> +	int rc = __sk_del_node_rcu(sk);
> +
> +	if (rc) {
> +		/* paranoid for a while -acme */
> +		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
> +		__sock_put(sk);
> +	}
> +	return rc;
> +}
...

Jarek P.
