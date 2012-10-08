From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net 1/6] ipv4: fix sending of redirects
Date: Mon, 8 Oct 2012 23:43:45 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210082259180.12172@ja.ssi.bg>
References: <1349609168-9848-1-git-send-email-ja@ssi.bg> <1349609168-9848-2-git-send-email-ja@ssi.bg> <20121008.151633.753185005887436197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44325 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752144Ab2JHUiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 16:38:21 -0400
In-Reply-To: <20121008.151633.753185005887436197.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 8 Oct 2012, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Sun,  7 Oct 2012 14:26:03 +0300
> 
> > @@ -322,7 +322,8 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
> >  {
> >  	int r = secpath_exists(skb) ? 0 : IN_DEV_RPFILTER(idev);
> >  
> > -	if (!r && !fib_num_tclassid_users(dev_net(dev))) {
> > +	if (!r && !fib_num_tclassid_users(dev_net(dev)) &&
> > +	    dev->ifindex != oif) {
> >  		*itag = 0;
> >  		return 0;
> >  	}
> 
> Hmmm, won't this cause the slow path to be taken for locally
> destined traffic?

	In this case idev=eth0 and oif=lo. The only case
where we can see same input and output device is for
forwarding and loopback (but only output routes where
there is no such validation).

	Of course, it slows down on traffic that ignores
our redirects. We can save some cycles if IN_DEV_TX_REDIRECTS
is checked before setting RTCF_DOREDIRECT:

	(dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev)) {

	RTCF_DOREDIRECT is used just to call ip_rt_send_redirect
where all depends on IN_DEV_TX_REDIRECTS.

	The only difference can be that user space will
not see RTCF_DOREDIRECT flag if IN_DEV_TX_REDIRECTS is false.
But may be it is better to show "redirect" in ip route
only when IN_DEV_TX_REDIRECTS are enabled. The old way
is preferred only when there is routing cache and changes
in IN_DEV_TX_REDIRECTS do not flush cache in devinet_conf_proc().

> > +			  rt->rt_gateway ? : ip_hdr(skb)->daddr);
> 
> Please use the rt_nexthop() helper.
> 
> > +		__be32 gw = rt->rt_gateway ? : ip_hdr(skb)->daddr;

	Good idea.

Regards

--
Julian Anastasov <ja@ssi.bg>
