From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] Fixes: 5943634fc559 ("ipv4: Maintain redirect and
 PMTU info in struct rtable again.")
Date: Mon, 07 Nov 2016 08:08:52 -0800
Message-ID: <1478534932.17367.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1478531058-12701-1-git-send-email-ssurya@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Suryaputra Lin <ssurya@ieee.org>
To: Stephen Suryaputra Lin <stephen.suryaputra.lin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33675 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932399AbcKGQJD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 11:09:03 -0500
Received: by mail-pf0-f196.google.com with SMTP id 144so8125276pfv.0
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 08:08:54 -0800 (PST)
In-Reply-To: <1478531058-12701-1-git-send-email-ssurya@ieee.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-11-07 at 10:04 -0500, Stephen Suryaputra Lin wrote:
> ICMP redirects behavior is different after the commit above. An email
> requesting the explanation on why the behavior needs to be different
> was sent earlier to netdev (https://patchwork.ozlabs.org/patch/687728/).
> Since there isn't a reply yet, I decided to prepare this formal patch.
> 
> In v2.6 kernel, it used to be that ip_rt_redirect() calls
> arp_bind_neighbour() which returns 0 and then the state of the neigh for
> the new_gw is checked. If the state isn't valid then the redirected
> route is deleted. This behavior is maintained up to v3.5.7 by
> check_peer_redirect() because rt->rt_gateway is assigned to
> peer->redirect_learned.a4 before calling ipv4_neigh_lookup().
> 
> After the commit, ipv4_neigh_lookup() is performed without the
> rt_gateway assigned to the new_gw. In the case when rt_gateway (old_gw)
> isn't zero, the function uses it as the key. The neigh is most likely valid
> since the old_gw is the one that sends the ICMP redirect message. Then the
> new_gw is assigned to fib_nh_exception. The problem is: the new_gw ARP may
> never gets resolved and the traffic is blackholed.
> 
> Signed-off-by: Stephen Suryaputra Lin <ssurya@ieee.org>
> ---
>  net/ipv4/route.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 62d4d90c1389..510045cefcab 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -753,7 +753,9 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
>  			goto reject_redirect;
>  	}
>  
> +	rt->rt_gateway = 0;
>  	n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
> +	rt->rt_gateway = old_gw;
>  	if (!IS_ERR(n)) {
>  		if (!(n->nud_state & NUD_VALID)) {
>  			neigh_event_send(n, NULL);

In any case, rt is a shared object at that time, so even temporarily
clearing/restoring rt_gateway seems wrong to me.

I would rather call __ipv4_neigh_lookup(dst->dev, new_gw) directly at
this point.
