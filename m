From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking
 send_redirects
Date: Wed, 9 Apr 2014 01:03:29 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1404090022270.1554@ja.home.ssi.bg>
References: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Eric Biederman <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33938 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756232AbaDHWEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 18:04:04 -0400
In-Reply-To: <1396985482-30886-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 8 Apr 2014, Cong Wang wrote:

> From: Cong Wang <cwang@twopensource.com>
> 
> We have seen in a weird case we had to disable send_redirects in order
> to pass rp filter check even though we don't set forwarding at all.
> This looks wrong, at least according to ip-sysctl.txt send_redirects should
> only make sense when we enable forwarding.
> 
> Cc: Eric Biederman <ebiederm@xmission.com>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> 
> ---
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 1a629f8..3f9e324 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -321,7 +321,8 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
>  	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
>  
>  	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
> -	    (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev))) {
> +	    (dev->ifindex != oif || !IN_DEV_FORWARD(idev) ||
> +	     !IN_DEV_TX_REDIRECTS(idev))) {

	Very strange. Above IN_DEV_FORWARD matters only
when dev->ifindex == oif. And this can happen only for the
ip_route_input_slow -> ip_mkroute_input -> __mkroute_input
case. We are not supposed to reach fib_validate_source because
ip_mkroute_input is after the IN_DEV_FORWARD check in
ip_route_input_slow. This was for forwarding.

	If the case is not forwarding but local delivery,
the dev->ifindex != oif condition should be always true
because we provide 0 or LOOPBACK_IFINDEX for oif.

	So, the question is how we reach fib_validate_source
with dev->ifindex == oif and IN_DEV_FORWARD(idev) already
checked to be != 0 ?

>  		*itag = 0;
>  		return 0;
>  	}

Regards

--
Julian Anastasov <ja@ssi.bg>
