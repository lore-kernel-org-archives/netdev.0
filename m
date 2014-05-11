From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] neigh: set nud_state to NUD_INCOMPLETE when probing
 router reachability
Date: Sun, 11 May 2014 15:04:23 -0700
Message-ID: <1399845863.17976.116165369.3E7E2F36@webmail.messagingengine.com>
References: <536C64C0.5050204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@redhat.com>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:60543 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755478AbaEKWEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 18:04:24 -0400
In-Reply-To: <536C64C0.5050204@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 8, 2014, at 22:16, Duan Jiong wrote:
> 
> Since commit 7e98056964("ipv6: router reachability probing"), a router falls
> into NUD_FAILED will be probed.
> 
> Now if function rt6_select() selects a router which neighbour state is NUD_FAILED,
> and at the same time function rt6_probe() changes the neighbour state to NUD_PROBE,
> then function dst_neigh_output() can directly send packets, but actually the
> neighbour still is unreachable. If we set nud_state to NUD_INCOMPLETE instead
> NUD_PROBE, packets will not be sent out until the neihbour is reachable.
> 
> In addition, because the route should be probes with a single NS, so we must
> set neigh->probes to neigh_max_probes(), then the neigh timer timeout and function
> neigh_timer_handler() will not send other NS Messages.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
> Changes from v1:
> 	*modify changelog to explain in detail why use neigh_max_probes().
> 
>  net/core/neighbour.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 8f8a96e..32d872e 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -1248,8 +1248,8 @@ void __neigh_set_probe_once(struct neighbour *neigh)
>  	neigh->updated = jiffies;
>  	if (!(neigh->nud_state & NUD_FAILED))
>  		return;
> -	neigh->nud_state = NUD_PROBE;
> -	atomic_set(&neigh->probes, NEIGH_VAR(neigh->parms, UCAST_PROBES));
> +	neigh->nud_state = NUD_INCOMPLETE;
> +	atomic_set(&neigh->probes, neigh_max_probes(neigh));

Wouldn't it be better if we neigh_suspect the neighbour and leaving the state in NUD_PROBE? We call down to ->output in case neighbour is in NUD_PROBE state, so we must just disable connected 'fast-path'.

Greetings,

  Hannes
