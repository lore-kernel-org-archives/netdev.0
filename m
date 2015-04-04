From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: neigh use-after-free
Date: Fri, 03 Apr 2015 18:20:06 -0700
Message-ID: <1428110406.25985.203.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150403202753.GF32724@Sligo.logfs.org>
	 <35adab927f1bade6afd57e62a8720205@mail.gmail.com>
	 <1428104053.25985.192.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5f0a512c725fbaf8f38dbc1bdd9d1b47@mail.gmail.com>
	 <1428108249.25985.197.camel@edumazet-glaptop2.roam.corp.google.com>
	 <520964f8c9b65ad9a49545a30ecf6065@mail.gmail.com>
	 <1428109844.25985.202.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joern Engel <joern@purestorage.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Potashnik <alexei@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34976 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbbDDBUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 21:20:10 -0400
Received: by patj18 with SMTP id j18so132150022pat.2
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 18:20:10 -0700 (PDT)
In-Reply-To: <1428109844.25985.202.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-03 at 18:10 -0700, Eric Dumazet wrote:
> On Fri, 2015-04-03 at 17:57 -0700, Alexei Potashnik wrote:
> 
> > 
> > My understanding of the state when issue occurs is:
> >  - neigh_destroy() has finished executing
> >  - no timer for this neigh entry is pending or running
> >     (which makes neigh_timer_handler behavior irrelevant)
> >  - but kfree_rcu callback for the neigh entry has not executed yet
> >  - at this point IP code finds the entry with __ipv4_neigh_lookup_noref
> >     and starts operating on it.
> > 
> 
> Right. So far no rule here seems to be violated.
> 
> As long as IP code finds a neighbor, it is allowed to use it.
> 
> Freeing of the neighbor should not happen before rcu grace period.
> 
> Problem is __neigh_event_send() is ignoring n->dead
> 
> 

Please try following patch :

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 3de6542560288b3896ab243879a7b4a9b098ca0d..3a2928332b31bfd421ca409ba9bc4e82f82b3552 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -957,7 +957,8 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 	rc = 0;
 	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
 		goto out_unlock_bh;
-
+	if (neigh->dead)
+		goto out_unlock_bh;
 	if (!(neigh->nud_state & (NUD_STALE | NUD_INCOMPLETE))) {
 		if (NEIGH_VAR(neigh->parms, MCAST_PROBES) +
 		    NEIGH_VAR(neigh->parms, APP_PROBES)) {
