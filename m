From: Julian Anastasov <ja@ssi.bg>
Subject: Re: neigh use-after-free
Date: Sat, 4 Apr 2015 19:06:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1504041828030.2943@ja.home.ssi.bg>
References: <20150403202753.GF32724@Sligo.logfs.org>  <35adab927f1bade6afd57e62a8720205@mail.gmail.com>  <1428104053.25985.192.camel@edumazet-glaptop2.roam.corp.google.com>  <5f0a512c725fbaf8f38dbc1bdd9d1b47@mail.gmail.com>
 <1428108249.25985.197.camel@edumazet-glaptop2.roam.corp.google.com>  <520964f8c9b65ad9a49545a30ecf6065@mail.gmail.com>  <1428109844.25985.202.camel@edumazet-glaptop2.roam.corp.google.com> <1428110406.25985.203.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexei Potashnik <alexei@purestorage.com>,
	Joern Engel <joern@purestorage.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53134 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752244AbbDDQHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Apr 2015 12:07:03 -0400
In-Reply-To: <1428110406.25985.203.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 3 Apr 2015, Eric Dumazet wrote:

> > Problem is __neigh_event_send() is ignoring n->dead
> > 
> > 
> 
> Please try following patch :
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 3de6542560288b3896ab243879a7b4a9b098ca0d..3a2928332b31bfd421ca409ba9bc4e82f82b3552 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -957,7 +957,8 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
>  	rc = 0;
>  	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
>  		goto out_unlock_bh;

	At this point we can have NUD_STALE, NUD_INCOMPLETE or
NUD_FAILED. Not sure about NUD_STALE but for others we should
call kfree_skb(skb) and to return rc = 1. It is possible that
we never resolved this entry, so rc = 0 is not correct for all
cases.

	When n->dead = 1 the neigh is unlinked but the
option to call somehow __neigh_create() looks complex.
As result, in a rare case we can drop packets while
neigh_periodic_work is removing NUD_STALE entry. May be
it can take a RCU grace period.

> -
> +	if (neigh->dead)
> +		goto out_unlock_bh;
>  	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
>  		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
>  		    NEIGH_VAR(neigh->parms, APP_PROBES)) {

Regards

--
Julian Anastasov <ja@ssi.bg>
