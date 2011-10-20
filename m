From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] route: fix ICMP redirect validation
Date: Thu, 20 Oct 2011 15:47:02 -0200
Message-ID: <20111020154702.13f69021@asterix.rh>
References: <1317824404-9513-1-git-send-email-fbl@redhat.com>
	<20111017.194344.510280595317217573.davem@davemloft.net>
	<20111019160537.4aeedef8@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754314Ab1JTRrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Oct 2011 13:47:06 -0400
In-Reply-To: <20111019160537.4aeedef8@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Oct 2011 16:05:37 -0200
Flavio Leitner <fbl@redhat.com> wrote:

> On Mon, 17 Oct 2011 19:43:44 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Flavio Leitner <fbl@redhat.com>
> > Date: Wed,  5 Oct 2011 11:20:04 -0300
> > 
> > > The commit f39925dbde7788cfb96419c0f092b086aa325c0f
> > > (ipv4: Cache learned redirect information in inetpeer.)
> > > removed some ICMP packet validations which are required by
> > > RFC 1122, section 3.2.2.2:
> > 
> > The reason for putting this into the inetpeer cache was so that we
> > didn't need to consult the routing cache at all.  We're working to
> > remove it at some point, so every dependency matters.
> > 
> > Can you implement this such that only an inetpeer cache probe is
> > necessary?
> > 
> 
> Sure, I have reviewed your patch series to remove the routing
> cache and I believe this version works with and without it, though
> I have tested only with current net-next code.
> 
> Thanks for your time reviewing, I appreciate it.
...
> @@ -1331,13 +1337,40 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
>  			goto reject_redirect;
>  	}
>  
> -	peer = inet_getpeer_v4(daddr, 1);
> -	if (peer) {
> -		peer->redirect_learned.a4 = new_gw;
> +	memset(&fl4, 0, sizeof(fl4));
> +	fl4.daddr = daddr;
> +	for (s = 0; s < 2; s++) {
> +		for (i = 0; i < 2; i++) {
> +			fl4.flowi4_oif = ikeys[i];
> +			fl4.saddr = skeys[s];
> +			rt = __ip_route_output_key(net, &fl4);
> +			if (IS_ERR(rt))
> +				continue;
>  
> -		inet_putpeer(peer);
> +			if (rt->dst.error || rt->dst.dev != dev ||
> +			    rt->rt_gateway != old_gw) {
> +				ip_rt_put(rt);
> +				continue;
> +			}
>  
> -		atomic_inc(&__rt_peer_genid);
> +			peer = rt->peer;
> +			if (!peer) {
> +				peer = inet_getpeer_v4(daddr, 1);
> +				putpeer = true;
> +			}

I was reviewing this again and instead of doing the above, it would
be better to use rt_bind_peer() to update rt->peer as well.

                        if (!rt->peer)
                                rt_bind_peer(rt, rt->rt_dst, 1);

                        peer = rt->peer;
                        if (peer) {
                                peer->redirect_learned.a4 = new_gw;
                                atomic_inc(&__rt_peer_genid);
                        }


but I am not sure if I understood you completely when you say
to do such that only an inetpeer cache probe is necessary.

thanks again,
fbl
